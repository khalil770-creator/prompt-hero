import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  /// Stream of Firebase auth state changes.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Current Firebase user (nullable).
  User? get currentUser => _auth.currentUser;

  /// Stream of the current user's Firestore document.
  Stream<UserModel?> currentUserModelStream() {
    return _auth.authStateChanges().asyncExpand((firebaseUser) {
      if (firebaseUser == null) return Stream.value(null);
      return _firestore
          .collection(AppConstants.usersCollection)
          .doc(firebaseUser.uid)
          .snapshots()
          .map((snap) => snap.exists ? UserModel.fromFirestore(snap) : null);
    });
  }

  /// Sign in with email and password.
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    // Create user doc if it doesn't exist (e.g. registered before Firestore was set up)
    final uid = credential.user!.uid;
    final docRef = _firestore.collection(AppConstants.usersCollection).doc(uid);
    final doc = await docRef.get();
    if (!doc.exists) {
      await docRef.set({
        'email': email.trim(),
        'role': AppConstants.roleUser,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    return credential;
  }

  /// Register new user; creates Firestore user doc with role='user'.
  Future<UserCredential> register({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    // Create user document in Firestore
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(credential.user!.uid)
        .set({
      'email': email.trim(),
      'role': AppConstants.roleUser,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return credential;
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Send password reset email.
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  /// Fetch user model from Firestore by UID.
  Future<UserModel?> getUserModel(String uid) async {
    final doc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  /// Check if currently signed-in user is an admin.
  Future<bool> isCurrentUserAdmin() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    final model = await getUserModel(user.uid);
    return model?.isAdmin ?? false;
  }
}
