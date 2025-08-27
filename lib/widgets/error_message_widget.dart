import 'package:flutter/material.dart';
import '../constants/ui_constants.dart';

class ErrorMessageWidget extends StatelessWidget {
  final String errorMessage;

  const ErrorMessageWidget({
    super.key,
    required this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (errorMessage.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: UIConstants.errorContainerPadding,
      decoration: BoxDecoration(
        color: AppColors.errorBackground,
        borderRadius: BorderRadius.circular(UIConstants.errorContainerRadius),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: AppColors.failedColor,
            size: UIConstants.errorIconSize,
          ),
          const SizedBox(width: UIConstants.mediumSpacing),
          Expanded(
            child: Text(
              errorMessage,
              style: TextStyle(
                color: AppColors.errorText,
                fontSize: UIConstants.errorFontSize,
              ),
            ),
          ),
        ],
      ),
    );
  }
}