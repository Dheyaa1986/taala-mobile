import 'package:flutter/material.dart';
import 'package:taal/core/extensions/space_extension.dart';

import '../../app_config/app_colors.dart';


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
                  color: AppColors.primaryColor,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
    );
  }

  Text _buildText(BuildContext context) {
    return Text(
      message,
      style: Theme.of(context).textTheme.bodyLarge,
    );
  }
}
