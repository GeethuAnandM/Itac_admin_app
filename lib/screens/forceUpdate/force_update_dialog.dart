import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'force_update_service.dart';

class ForceUpdateDialog extends StatelessWidget {
  final VersionCheckResult result;

  // Replace these with your real store URLs when you publish
  static const String _iosStoreUrl =
      ''; // e.g. 'https://apps.apple.com/app/id...'
  static const String _androidStoreUrl =
      ''; // e.g. 'https://play.google.com/store/apps/details?id=...'

  const ForceUpdateDialog({super.key, required this.result});

  static Future<void> show(BuildContext context, VersionCheckResult result) {
    return showDialog(
      context: context,
      barrierDismissible: false, // user cannot tap outside to close
      builder: (_) => ForceUpdateDialog(result: result),
    );
  }

  Future<void> _openStore() async {
    final url = Platform.isIOS ? _iosStoreUrl : _androidStoreUrl;

    if (url.isEmpty) {
      // Store URL not set yet — safe during development
      debugPrint(
          'ForceUpdate: store URL not configured yet. Add it to ForceUpdateDialog when published.');
      return;
    }
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // blocks Android back button
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: EdgeInsets.zero,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ─────────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: const BoxDecoration(
                color: Color(0xFF1E88E5),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: const Column(
                children: [
                  Icon(Icons.system_update_alt, color: Colors.white, size: 56),
                  SizedBox(height: 8),
                  Text(
                    'Update Required',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // ── Body ───────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Version label
                  Center(
                    child: Text(
                      'Version ${result.latestVersionName} is available',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E88E5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Release notes from API  ← uses result.releaseNotes
                  Text(
                    result.releaseNotes,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 14, color: Colors.black87, height: 1.5),
                  ),
                  const SizedBox(height: 24),

                  // Update button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _openStore,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E88E5),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Update Now',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
