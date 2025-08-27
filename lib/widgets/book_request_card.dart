import 'package:flutter/material.dart';
import '../models/user_book_request_models.dart';
import '../utils/book_request_extensions.dart';
import '../constants/ui_constants.dart';
import 'book_cover_image.dart';
import 'status_badge.dart';
import 'progress_indicator_widget.dart';
import 'error_message_widget.dart';

class BookRequestCard extends StatelessWidget {
  final UserBookRequest request;
  final VoidCallback? onTap;

  const BookRequestCard({super.key, required this.request, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: UIConstants.cardMargin,
      elevation: 2,
      child: InkWell(
        onTap: request.isCompleted ? onTap : null,
        borderRadius: BorderRadius.circular(UIConstants.cardBorderRadius),
        child: Padding(
          padding: UIConstants.cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBookInfoRow(),
              _buildProgressSection(),
              _buildErrorSection(),
              _buildRequestDetailsSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookInfoRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Book cover
        BookCoverImage(
          imageUrl: request.book.displayImageUrl,
          fallbackImageUrl: null,
        ),
        const SizedBox(width: UIConstants.largeSpacing),

        // Book details
        Expanded(child: _buildBookDetails()),

        // Progress indicator
        ProgressIndicatorWidget(request: request),
      ],
    );
  }

  Widget _buildBookDetails() {
    return Builder(
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            request.book.title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: UIConstants.smallSpacing),

          // Authors
          if (request.book.authors.isNotEmpty)
            Text(
              request.book.authors.join(', '),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.mediumGrey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

          const SizedBox(height: UIConstants.mediumSpacing),

          // Status badge
          StatusBadge(status: request.status),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    if (!request.isProcessing) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        const SizedBox(height: UIConstants.largeSpacing),
        ProgressBarWidget(request: request),
      ],
    );
  }

  Widget _buildErrorSection() {
    if (!request.hasFailed || request.errorMessage?.isEmpty == true) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        const SizedBox(height: UIConstants.largeSpacing),
        ErrorMessageWidget(errorMessage: request.errorMessage!),
      ],
    );
  }

  Widget _buildRequestDetailsSection(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: UIConstants.largeSpacing),
        Row(
          children: [
            Icon(
              Icons.access_time,
              size: UIConstants.smallIconSize,
              color: AppColors.mediumGrey,
            ),
            const SizedBox(width: UIConstants.smallSpacing),
            Text(
              '${AppStrings.requested} ${request.createdAt.timeAgo}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.mediumGrey),
            ),
            if (request.isCompleted && request.completedAt != null) ...[
              Text(' • ', style: TextStyle(color: AppColors.mediumGrey)),
              Text(
                '${AppStrings.completedAt} ${request.completedAt!.timeAgo}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.mediumGrey),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
