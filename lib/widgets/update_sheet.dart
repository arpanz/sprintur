import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app/theme.dart';
import '../app/updates.dart';
import 'common.dart';

/// "Version x is out" with the release notes. Resolves true when the user
/// went to update, false on "Later".
Future<bool> showUpdateSheet(BuildContext context, Release release) async {
  final updated = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: SprintColors.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) => _UpdateSheet(release: release),
  );
  return updated ?? false;
}

class _UpdateSheet extends StatelessWidget {
  const _UpdateSheet({required this.release});

  final Release release;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: SprintColors.line,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: SprintColors.lime,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.download_rounded,
                    color: SprintColors.bg,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'VERSION ${release.version} IS OUT',
                    style: SprintText.display(28),
                  ),
                ),
              ],
            ),
            if (release.notes.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text("WHAT'S NEW", style: SprintText.label),
              const SizedBox(height: 10),
              for (final note in release.notes)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 7, right: 10),
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: SprintColors.lime,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          note,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.4,
                            color: SprintColors.textSoft,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
            const SizedBox(height: 20),
            BigButton(
              label: 'Update now',
              onPressed: () async {
                await launchUrl(
                  Uri.parse(release.url),
                  mode: LaunchMode.externalApplication,
                );
                if (context.mounted) Navigator.of(context).pop(true);
              },
            ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Later',
                style: TextStyle(color: SprintColors.textSoft),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
