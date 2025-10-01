import 'package:flutter/material.dart';

class PromptInput extends StatelessWidget {
  const PromptInput({
    super.key,
    required this.controller,
    required this.loading,
    required this.onSubmit,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool loading;
  final void Function(String value) onSubmit;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            minLines: 1,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: "Skriv din prompt…",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
            onSubmitted: onSubmit,
          ),
        ),
        const SizedBox(width: 8),
        FilledButton.icon(
          onPressed: loading ? null : onSend,
          icon: loading
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.send),
          label: Text(loading ? "Skickar…" : "Skicka"),
        ),
      ],
    );
  }
}
