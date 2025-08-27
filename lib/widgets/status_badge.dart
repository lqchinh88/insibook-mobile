import 'package:flutter/material.dart';
import '../models/user_book_request_models.dart';
import '../utils/book_request_extensions.dart';
import '../constants/ui_constants.dart';

class StatusBadge extends StatelessWidget {
  final BookRequestStatus status;
  final double fontSize;
  final EdgeInsets padding;

  const StatusBadge({
    super.key,
    required this.status,
    this.fontSize = UIConstants.statusBadgeFontSize,
    this.padding = UIConstants.statusBadgePadding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: UIConstants.lowOpacity),
        borderRadius: BorderRadius.circular(UIConstants.statusBadgeRadius),
        border: Border.all(
          color: status.color.withValues(alpha: UIConstants.mediumOpacity),
          width: 1,
        ),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          color: status.color,
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}