import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ResultBottomBar extends StatefulWidget {
  const ResultBottomBar({
    super.key,
    required this.onOpenActions,
    this.onRegenerate,
    this.loading = false,
  });

  final Future<void> Function() onOpenActions;
  final Future<void> Function()? onRegenerate;
  final bool loading;

  @override
  State<ResultBottomBar> createState() => _ResultBottomBarState();
}

class _ResultBottomBarState extends State<ResultBottomBar> {
  bool _altPressed = false;
  bool _regenPressed = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Row(
        children: [
          Expanded(
            child: Listener(
              onPointerDown: (_) => setState(() => _altPressed = true),
              onPointerUp: (_) => setState(() => _altPressed = false),
              onPointerCancel: (_) => setState(() => _altPressed = false),
              child: AnimatedScale(
                scale: _altPressed ? 0.98 : 1.0,
                duration: const Duration(milliseconds: 110),
                curve: Curves.easeOut,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await HapticFeedback.selectionClick();
                    await widget.onOpenActions();
                  },
                  icon: const Icon(Icons.more_horiz),
                  label: const Text('Alternativ'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white38),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          if (widget.onRegenerate != null)
            Expanded(
              child: Listener(
                onPointerDown: (_) {
                  if (widget.loading) return;
                  setState(() => _regenPressed = true);
                },
                onPointerUp: (_) => setState(() => _regenPressed = false),
                onPointerCancel: (_) => setState(() => _regenPressed = false),
                child: AnimatedScale(
                  scale: (_regenPressed && !widget.loading) ? 0.98 : 1.0,
                  duration: const Duration(milliseconds: 110),
                  curve: Curves.easeOut,
                  child: FilledButton.icon(
                    onPressed: widget.loading ? null : widget.onRegenerate,
                    icon: widget.loading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh),
                    label: Text(widget.loading ? 'Genererar…' : 'Nytt'),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
