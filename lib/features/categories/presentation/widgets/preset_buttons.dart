import 'package:flutter/material.dart';

class PresetButtons extends StatelessWidget {
  const PresetButtons({
    super.key,
    required this.presets,
    required this.loading,
    required this.onTap,
  });

  final List<String> presets;
  final bool loading;
  final void Function(String) onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: presets.map((p) {
        return ElevatedButton(
          onPressed: loading ? null : () => onTap(p),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          child: Text(
            p.length > 28 ? "${p.substring(0, 28)}…" : p,
            textAlign: TextAlign.center,
          ),
        );
      }).toList(),
    );
  }
}
