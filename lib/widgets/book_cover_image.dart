import 'package:flutter/material.dart';
import '../constants/ui_constants.dart';

class BookCoverImage extends StatelessWidget {
  final String? imageUrl;
  final String? fallbackImageUrl;
  final double width;
  final double height;
  final double borderRadius;

  const BookCoverImage({
    super.key,
    this.imageUrl,
    this.fallbackImageUrl,
    this.width = UIConstants.bookCoverWidth,
    this.height = UIConstants.bookCoverHeight,
    this.borderRadius = UIConstants.bookCoverRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.lightGrey,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: _buildImage(),
      ),
    );
  }

  Widget _buildImage() {
    // Try primary image URL first
    if (imageUrl?.isNotEmpty == true) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallbackImage(),
      );
    }
    
    // Try fallback image URL
    if (fallbackImageUrl?.isNotEmpty == true) {
      return Image.network(
        fallbackImageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
      );
    }
    
    // Show placeholder if no images available
    return _buildPlaceholderImage();
  }

  Widget _buildFallbackImage() {
    if (fallbackImageUrl?.isNotEmpty == true) {
      return Image.network(
        fallbackImageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
      );
    }
    return _buildPlaceholderImage();
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Icon(
        Icons.book,
        color: AppColors.mediumGrey,
        size: UIConstants.largeIconSize,
      ),
    );
  }
}