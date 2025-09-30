import 'package:flutter/material.dart';

class ResponseBox extends StatelessWidget {
  const ResponseBox({
    super.key,
    required this.controller,
    required this.response,
  });

  final ScrollController controller;
  final String response;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        controller: controller,
        child: SelectableText(
          response.isEmpty ? "🧠 Svar från GPT visas här…" : response,
          style: theme.textTheme.bodyLarge,
        ),
      ),
    );
  }
}
