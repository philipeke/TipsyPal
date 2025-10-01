import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/result_theme.dart';

class ResultAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ResultAppBar({
    super.key,
    required this.category,
    required this.wordCount,
    required this.onBack,
    required this.onCopy,
    required this.onShare,
    this.onRegenerate,
    this.isLoading = false,
  });

  final String category;
  final int wordCount;
  final VoidCallback onBack;
  final VoidCallback onCopy;
  final VoidCallback onShare;
  final Future<void> Function()? onRegenerate;
  final bool isLoading;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final color = colorForCategory(category);
    final icon = iconForCategory(category);

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(
        tooltip: 'Tillbaka',
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: () async {
          await HapticFeedback.lightImpact();
          await Future.delayed(const Duration(milliseconds: 80));
          onBack();
        },
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.35)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 8),
                Text(
                  category,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            "$wordCount ord",
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
      actions: [
        IconButton(onPressed: onCopy, icon: const Icon(Icons.copy)),
        IconButton(onPressed: onShare, icon: const Icon(Icons.share)),
        if (onRegenerate != null)
          IconButton(
            tooltip: 'Generera nytt',
            onPressed: isLoading ? null : () async => onRegenerate!(),
            icon: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
          ),
      ],
    );
  }
}
