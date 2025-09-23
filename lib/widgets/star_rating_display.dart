import 'package:flutter/material.dart';

class StarRatingDisplay extends StatelessWidget {
  final double rating;
  final int reviewCount;
  final double starSize;
  final Color starColor;
  final Color emptyStarColor;
  final TextStyle? textStyle;

  const StarRatingDisplay({
    super.key,
    required this.rating,
    required this.reviewCount,
    this.starSize = 16,
    this.starColor = const Color(0xFFFFB347),
    this.emptyStarColor = const Color(0xFFE0E0E0),
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Stars
        ...List.generate(5, (index) {
          if (rating >= index + 1) {
            // Full star
            return Icon(
              Icons.star,
              size: starSize,
              color: starColor,
            );
          } else if (rating > index && rating < index + 1) {
            // Half star
            return Icon(
              Icons.star_half,
              size: starSize,
              color: starColor,
            );
          } else {
            // Empty star
            return Icon(
              Icons.star_border,
              size: starSize,
              color: emptyStarColor,
            );
          }
        }),

        const SizedBox(width: 8),

        // Rating text and review count
        Text(
          '${rating.toStringAsFixed(1)} (${_formatReviewCount(reviewCount)})',
          style: textStyle ?? TextStyle(
            fontSize: 14,
            color: const Color(0xFF2C3E50).withValues(alpha: 0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatReviewCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    } else {
      return count.toString();
    }
  }
}