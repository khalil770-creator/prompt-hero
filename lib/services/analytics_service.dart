import 'package:cloud_firestore/cloud_firestore.dart';

class AnalyticsService {
  final FirebaseFirestore _db;

  static const String _collection = 'usage_logs';

  AnalyticsService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _logsRef =>
      _db.collection(_collection);

  // ─────────────────────────────────────────────────────────────────
  // LOG EVENT
  // ─────────────────────────────────────────────────────────────────

  Future<void> logEvent({
    required String type,
    required String promptId,
    required String promptTitle,
    required String categoryId,
    required String categoryName,
    String? userId,
    String? platform,
    double? rating,
  }) async {
    try {
      await _logsRef.add({
        'type': type,
        'promptId': promptId,
        'promptTitle': promptTitle,
        'categoryId': categoryId,
        'categoryName': categoryName,
        'userId': userId,
        'platform': platform,
        'rating': rating,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // Swallow silently — analytics failures must never surface to users
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // DASHBOARD STATS
  // ─────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final results = await Future.wait([
        _db.collection('users').count().get(),
        _db.collection('categories').count().get(),
        _logsRef.where('type', isEqualTo: 'view').count().get(),
        _logsRef.where('type', isEqualTo: 'share').count().get(),
        _logsRef.where('type', isEqualTo: 'copy').count().get(),
        _logsRef.where('type', isEqualTo: 'rating').count().get(),
      ]);

      // Count all prompts across all categories
      int totalPrompts = 0;
      try {
        final categories = await _db.collection('categories').get();
        for (final cat in categories.docs) {
          final snap =
              await cat.reference.collection('prompts').count().get();
          totalPrompts += snap.count ?? 0;
        }
      } catch (_) {}

      return {
        'totalUsers': results[0].count ?? 0,
        'totalPrompts': totalPrompts,
        'totalCategories': results[1].count ?? 0,
        'totalViews': results[2].count ?? 0,
        'totalShares': results[3].count ?? 0,
        'totalCopies': results[4].count ?? 0,
        'totalRatings': results[5].count ?? 0,
      };
    } catch (_) {
      return {
        'totalUsers': 0,
        'totalPrompts': 0,
        'totalCategories': 0,
        'totalViews': 0,
        'totalShares': 0,
        'totalCopies': 0,
        'totalRatings': 0,
      };
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // MOST VIEWED PROMPTS
  // ─────────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getMostViewedPrompts(
      {int limit = 10}) async {
    return _aggregateByPrompt('view', limit: limit);
  }

  // ─────────────────────────────────────────────────────────────────
  // MOST SHARED PROMPTS
  // ─────────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getMostSharedPrompts(
      {int limit = 10}) async {
    return _aggregateByPrompt('share', limit: limit);
  }

  // ─────────────────────────────────────────────────────────────────
  // AGGREGATE HELPER
  // ─────────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> _aggregateByPrompt(String type,
      {int limit = 10}) async {
    try {
      final snap = await _logsRef
          .where('type', isEqualTo: type)
          .orderBy('timestamp', descending: true)
          .limit(500)
          .get();

      final counts = <String, Map<String, dynamic>>{};
      for (final doc in snap.docs) {
        final data = doc.data();
        final id = data['promptId'] as String? ?? '';
        if (id.isEmpty) continue;
        if (counts.containsKey(id)) {
          counts[id]!['count'] = (counts[id]!['count'] as int) + 1;
        } else {
          counts[id] = {
            'promptId': id,
            'promptTitle': data['promptTitle'] ?? '',
            'categoryName': data['categoryName'] ?? '',
            'count': 1,
          };
        }
      }

      final sorted = counts.values.toList()
        ..sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));
      return sorted.take(limit).toList();
    } catch (_) {
      return [];
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // RECENT ACTIVITY
  // ─────────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getRecentActivity(
      {int limit = 20}) async {
    try {
      final snap = await _logsRef
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();
      return snap.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'type': data['type'] ?? '',
          'promptTitle': data['promptTitle'] ?? '',
          'categoryName': data['categoryName'] ?? '',
          'platform': data['platform'],
          'timestamp': data['timestamp'],
        };
      }).toList();
    } catch (_) {
      return [];
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // EVENT COUNTS BY TYPE
  // ─────────────────────────────────────────────────────────────────

  Future<Map<String, int>> getEventCountsByType() async {
    try {
      final results = await Future.wait([
        _logsRef.where('type', isEqualTo: 'view').count().get(),
        _logsRef.where('type', isEqualTo: 'copy').count().get(),
        _logsRef.where('type', isEqualTo: 'share').count().get(),
        _logsRef.where('type', isEqualTo: 'rating').count().get(),
      ]);
      return {
        'views': results[0].count ?? 0,
        'copies': results[1].count ?? 0,
        'shares': results[2].count ?? 0,
        'ratings': results[3].count ?? 0,
      };
    } catch (_) {
      return {'views': 0, 'copies': 0, 'shares': 0, 'ratings': 0};
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // DAILY ACTIVITY
  // ─────────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getDailyActivity({int days = 7}) async {
    try {
      final now = DateTime.now();
      final since = now.subtract(Duration(days: days));
      final snap = await _logsRef
          .where('timestamp',
              isGreaterThanOrEqualTo: Timestamp.fromDate(since))
          .orderBy('timestamp')
          .get();

      // Build map keyed by date string yyyy-MM-dd
      final Map<String, int> daily = {};
      for (var i = 0; i < days; i++) {
        final d = now.subtract(Duration(days: days - 1 - i));
        final key =
            '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
        daily[key] = 0;
      }

      for (final doc in snap.docs) {
        final ts = doc.data()['timestamp'];
        if (ts == null) continue;
        final date = (ts as Timestamp).toDate();
        final key =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        if (daily.containsKey(key)) {
          daily[key] = daily[key]! + 1;
        }
      }

      return daily.entries
          .map((e) => {'date': e.key, 'count': e.value})
          .toList();
    } catch (_) {
      return [];
    }
  }
}
