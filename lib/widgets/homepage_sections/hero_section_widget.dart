import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/homepage_models.dart';
import '../../models/book_models.dart';
import '../../utils/result.dart';
import '../../providers/book_api_provider.dart';
import '../../services/book_api_service.dart';
import '../../screens/book_details_screen.dart';
import '../hero_book_card.dart';

class HeroSectionWidget extends StatefulWidget {
  final HomepageSection section;
  final bool shouldLoad;

  const HeroSectionWidget({
    super.key,
    required this.section,
    this.shouldLoad = true,
  });

  @override
  State<HeroSectionWidget> createState() => _HeroSectionWidgetState();
}

class _HeroSectionWidgetState extends State<HeroSectionWidget> {
  InternalBookItem? _heroBook;
  bool _isLoading = false;
  late final BookApiService _bookApiService;

  @override
  void initState() {
    super.initState();
    _bookApiService = context.read<BookApiProvider>().bookApiService;

    // Load data immediately if widget should load initially
    if (widget.shouldLoad) {
      _loadHeroBook();
    }
  }

  @override
  void didUpdateWidget(HeroSectionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Reload when shouldLoad changes from false to true and we don't have data
    if (widget.shouldLoad && !oldWidget.shouldLoad && _heroBook == null && !_isLoading) {
      _loadHeroBook();
    }
  }

  Future<void> _loadHeroBook() async {
    if (_isLoading || _heroBook != null) return;

    setState(() {
      _isLoading = true;
    });

    final result = await _bookApiService.getHeroBook();

    result.fold(
      (book) {
        if (mounted) {
          setState(() {
            _heroBook = book;
            _isLoading = false;
          });
        }
      },
      (error) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      },
    );
  }


  void _navigateToBookDetails() {
    if (_heroBook != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BookDetailsScreen(book: _heroBook!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = widget.section.content as HeroSectionContent;

    if (_isLoading) {
      return Container(
        margin: const EdgeInsets.all(16),
        height: 240,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1F2937), // Dark gray-blue
              Color(0xFF374151), // Medium gray
              Color(0xFFF9FAFB), // Very light gray
            ],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }

    return HeroBookCard(
      book: _heroBook,
      imageUrl: content.imageUrl,
      ctaText: content.ctaText,
      onReadSummary: _navigateToBookDetails,
      onTap: _navigateToBookDetails,
    );
  }

}