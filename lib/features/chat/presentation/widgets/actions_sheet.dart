import 'package:flutter/material.dart';

Future<void> showActionsSheet({
  required BuildContext context,
  required Future<void> Function() onCopy,
  required Future<void> Function() onShare,
}) async {
  if (!context.mounted) return;
  await showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) {
      return Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A1F2B),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Vad vill du göra?",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigoAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.copy),
                      label: const Text("Kopiera"),
                      onPressed: () async {
                        Navigator.pop(context);
                        await onCopy();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.share),
                      label: const Text("Dela"),
                      onPressed: () async {
                        Navigator.pop(context);
                        await onShare();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Stäng",
                  style: TextStyle(color: Colors.white54),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
