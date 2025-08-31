import 'package:flutter/material.dart';
import '../config/app_config.dart';

class EnvironmentBanner extends StatelessWidget {
  final Widget child;

  const EnvironmentBanner({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (!AppConfig.showEnvironmentBanner) {
      return child;
    }

    return Banner(
      message: AppConfig.environmentDisplayName.toUpperCase(),
      location: BannerLocation.topStart,
      color: _getBannerColor(),
      child: child,
    );
  }

  Color _getBannerColor() {
    switch (AppConfig.environmentDisplayName.toLowerCase()) {
      case 'development':
        return Colors.green;
      case 'staging':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }
}