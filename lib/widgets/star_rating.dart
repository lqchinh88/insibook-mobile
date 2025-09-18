import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final int reviewCount;
  final double size;
  final Color? starColor;
  final Color? textColor;
  final double fontSize;

  const StarRating({
    super.key,
    required this.rating,
    required this.reviewCount,
    this.size = 12,
    this.starColor,
    this.textColor,
    this.fontSize = 8,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveStarColor = starColor ?? Colors.amber[600];
    final effectiveTextColor = textColor ?? Colors.grey[600];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Star rating
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            if (index < rating.floor()) {
              // Full star
              return Icon(
                Icons.star,
                size: size,
                color: effectiveStarColor,
              );
            } else if (index < rating) {
              // Half star
              return Icon(
                Icons.star_half,
                size: size,
                color: effectiveStarColor,
              );
            } else {
              // Empty star
              return Icon(
                Icons.star_border,
                size: size,
                color: effectiveStarColor,
              );
            }
          }),
        ),
        const SizedBox(height: 2),
        // Rating number and review count
        Text(
          '${rating.toStringAsFixed(1)} (${_formatReviewCount(reviewCount)})',
          style: TextStyle(
            fontSize: fontSize,
            color: effectiveTextColor,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
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