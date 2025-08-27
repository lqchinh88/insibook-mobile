import 'package:flutter/material.dart';
import '../models/user_book_request_models.dart';
import '../utils/book_request_extensions.dart';
import '../constants/ui_constants.dart';

class ProgressIndicatorWidget extends StatelessWidget {
  final UserBookRequest request;

  const ProgressIndicatorWidget({
    super.key,
    required this.request,
  });

  @override
  Widget build(BuildContext context) {
    if (request.isProcessing) {
      return SizedBox(
        width: UIConstants.progressIndicatorSize,
        height: UIConstants.progressIndicatorSize,
        child: CircularProgressIndicator(
          strokeWidth: UIConstants.progressIndicatorStrokeWidth,
          value: request.progress / 100,
          backgroundColor: AppColors.lightGrey,
          valueColor: AlwaysStoppedAnimation<Color>(request.status.color),
        ),
      );
    } else {
      return Icon(
        request.status.icon,
        color: request.status.color,
        size: UIConstants.progressIndicatorSize,
      );
    }
  }
}

class ProgressBarWidget extends StatelessWidget {
  final UserBookRequest request;

  const ProgressBarWidget({
    super.key,
    required this.request,
  });

  @override
  Widget build(BuildContext context) {
    if (!request.isProcessing) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.progress,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.mediumGrey,
              ),
            ),
            Text(
              '${request.progress}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: UIConstants.smallSpacing),
        LinearProgressIndicator(
          value: request.progress / 100,
          backgroundColor: AppColors.lightGrey,
          valueColor: AlwaysStoppedAnimation<Color>(request.status.color),
        ),
      ],
    );
  }
}