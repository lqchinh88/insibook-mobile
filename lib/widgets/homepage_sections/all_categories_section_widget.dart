import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/book_models.dart';
import '../../models/homepage_models.dart';
import '../../models/books_screen_config.dart';
import '../../utils/result.dart';
import '../../providers/book_api_provider.dart';
import '../../services/book_api_service.dart';
import '../category_card.dart';
import './section_header_widget.dart';
import '../../screens/paginated_books_screen.dart';

class AllCategoriesSectionWidget extends StatefulWidget {
  final HomepageSection section;
  final bool shouldLoad;

  const AllCategoriesSectionWidget({
    super.key,
    required this.section,
    required this.shouldLoad,
  });

  @override
  State<AllCategoriesSectionWidget> createState() => _AllCategoriesSectionWidgetState();
}

class _AllCategoriesSectionWidgetState extends State<AllCategoriesSectionWidget> {
  late final BookApiService _bookApiService;
  List<BookCategory> _categories = [];
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _bookApiService = context.read<BookApiProvider>().bookApiService;
    // Load immediately if shouldLoad is true
    if (widget.shouldLoad) {
      _loadCategories();
    }
  }

  @override
  void didUpdateWidget(AllCategoriesSectionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Load categories when shouldLoad becomes true
    if (widget.shouldLoad && !oldWidget.shouldLoad) {
      _loadCategories();
    }
  }

  Future<void> _loadCategories() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      final result = await _bookApiService.getAllCategories();

      if (mounted) {
        setState(() {
          _isLoading = false;

          if (result.isSuccess) {
            _categories = result.value as List<BookCategory>;

            // Apply limit from section content if specified
            final content = widget.section.content as AllCategoriesSectionContent;
            if (_categories.length > content.categoryCount) {
              _categories = _categories.take(content.categoryCount).toList();
            }
          } else if (result.isFailure) {
            _hasError = true;
            final error = result.error;
            if (error != null) {
              _errorMessage = '${error.message} (Code: ${error.statusCode})';
            } else {
              _errorMessage = 'Failed to load categories - Unknown error';
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Network error: ${e.toString()}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        SectionHeaderWidget(
          title: widget.section.title,
          subtitle: widget.section.subtitle ?? 'Browse all categories',
          onViewAll: _categories.isNotEmpty
              ? null // No "See All" for all categories section
              : null,
        ),

        const SizedBox(height: 16),

        // Content
        if (_isLoading)
          SizedBox(
            height: 160, // Reduced height for loading state
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        else if (_hasError)
          Container(
            height: 140, // Slightly reduced height for error state
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  color: Theme.of(context).colorScheme.error,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: Text(
                    _errorMessage ?? 'Failed to load categories',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _loadCategories,
                  child: const Text('Retry'),
                ),
              ],
            ),
          )
        else if (_categories.isEmpty)
          Container(
            height: 140, // Reduced height for empty state
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.category_outlined,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  'No categories available',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          // Categories grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              return CategoryCard(
                category: category,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaginatedBooksScreen(
                        config: BooksScreenConfig(
                          source: BooksDataSource.category,
                          title: category.name,
                          categoryId: category.id,
                          // sortBy defaults to 'random' for variety
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),

        const SizedBox(height: 24),
      ],
    );
  }
}