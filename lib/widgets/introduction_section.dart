import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';
import '../providers/language_provider.dart';
import 'package:provider/provider.dart';

class IntroductionSection extends StatefulWidget {
  final String introduction;

  const IntroductionSection({
    super.key,
    required this.introduction,
  });

  @override
  State<IntroductionSection> createState() => _IntroductionSectionState();
}

class _IntroductionSectionState extends State<IntroductionSection> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with expand/collapse
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.zero,
            child: Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 16),
              child: Row(
                children: [
                  Icon(
                    Icons.description_outlined,
                    size: 24,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Consumer<LanguageProvider>(
                      builder: (context, langProvider, child) => Text(
                        langProvider.l10n['introduction'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                          fontFamily: AppTextStyles.fontFamily,
                        ),
                      ),
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    size: 24,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ],
              ),
            ),
          ),

          // Introduction content
          if (_isExpanded) ...[
            const Divider(height: 1, indent: 0, endIndent: 0),
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 16),
              child: Text(
                widget.introduction,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}