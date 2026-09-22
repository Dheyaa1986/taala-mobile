import 'package:flutter/material.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/design_system/theme/taala_tokens.dart';

class MessageViewText extends StatelessWidget {
  final String message;
  final VoidCallback? onRefresh;
  const MessageViewText({
    super.key,
    required this.message,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: onRefresh == null
          ? _buildText(context)
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildText(context),
                8.height,
                IconButton(
                  onPressed: onRefresh,
                  color: TaalaTokens.of(context).primary,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
    );
  }

  Text _buildText(BuildContext context) {
    final tokens = TaalaTokens.of(context);
    return Text(
      message,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: tokens.textSecondary,
          ),
    );
  }
}
