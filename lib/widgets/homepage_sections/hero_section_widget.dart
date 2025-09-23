import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/homepage_models.dart';
import '../../providers/language_provider.dart';
import '../hero_book_card.dart';

class HeroSectionWidget extends StatelessWidget {
  final HomepageSection section;

  const HeroSectionWidget({
    super.key,
    required this.section,
  });

  @override
  Widget build(BuildContext context) {
    final content = section.content as HeroSectionContent;

    return HeroBookCard(
      imageUrl: content.imageUrl,
      ctaText: content.ctaText,
      onReadSummary: () {
        // TODO: Handle CTA action based on content.ctaAction
      },
      onBookmark: () {
        // TODO: Handle bookmark action
      },
    );
  }

}