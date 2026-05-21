import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ShareUtils {
  ShareUtils._();

  /// Share a prompt via WhatsApp.
  /// On web: opens wa.me deep link via url_launcher.
  /// On mobile: uses share_plus native share sheet.
  static Future<void> shareViaWhatsApp({
    required BuildContext context,
    required String promptTitle,
    required String promptText,
  }) async {
    final shareText =
        '✨ *$promptTitle*\n\n$promptText\n\n_Shared from Prompt Hero_';

    if (kIsWeb) {
      final encoded = Uri.encodeComponent(shareText);
      final uri = Uri.parse('https://wa.me/?text=$encoded');
      try {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          _showError(context, 'Could not open WhatsApp. Make sure it is installed.');
        }
      } catch (e) {
        _showError(context, 'Failed to open WhatsApp: ${e.toString()}');
      }
    } else {
      try {
        await Share.share(
          shareText,
          subject: promptTitle,
        );
      } catch (e) {
        _showError(context, 'Failed to share: ${e.toString()}');
      }
    }
  }

  /// Copy prompt text to clipboard and show snack bar confirmation.
  static Future<void> copyToClipboard({
    required BuildContext context,
    required String text,
    String? successMessage,
  }) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(successMessage ?? 'Copied to clipboard!'),
              ],
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        _showError(context, 'Failed to copy: ${e.toString()}');
      }
    }
  }

  /// Share a prompt via the native share sheet (non-WhatsApp).
  static Future<void> shareGeneral({
    required BuildContext context,
    required String promptTitle,
    required String promptText,
  }) async {
    final shareText =
        '$promptTitle\n\n$promptText\n\nShared from Prompt Hero';

    if (kIsWeb) {
      // Fallback: copy to clipboard on web when no specific target
      await copyToClipboard(
        context: context,
        text: shareText,
        successMessage: 'Prompt copied to clipboard for sharing!',
      );
    } else {
      try {
        await Share.share(
          shareText,
          subject: promptTitle,
        );
      } catch (e) {
        if (context.mounted) {
          _showError(context, 'Failed to share: ${e.toString()}');
        }
      }
    }
  }

  static void _showError(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
