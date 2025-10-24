import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/homepage_models.dart';
import '../../models/book_models.dart';
import '../../providers/book_api_provider.dart';
import '../../services/book_api_service.dart';
import '../../utils/result.dart';
import '../horizontal_book_card.dart';
import 'section_header_widget.dart';
import '../../screens/grid_book_search_screen.dart';

class HorizontalBooksSectionWidget extends StatefulWidget {
  final HomepageSection section;
  final bool shouldLoad;

  const HorizontalBooksSectionWidget({super.key, required this.section, this.shouldLoad = true});

  @override
  State<HorizontalBooksSectionWidget> createState() =>
      _HorizontalBooksSectionWidgetState();
}

class _HorizontalBooksSectionWidgetState
    extends State<HorizontalBooksSectionWidget> {
  final ScrollController _scrollController = ScrollController();
  List<InternalBookItem> _books = [];
  bool _isLoading = false;
  bool _hasMoreBooks = true;
  bool _hasInitialized = false;
  int _currentOffset = 0;
  late final BookApiService _bookApiService;

  static const int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _bookApiService = context.read<BookApiProvider>().bookApiService;
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(HorizontalBooksSectionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Start loading when shouldLoad becomes true
    if (widget.shouldLoad && !oldWidget.shouldLoad && !_hasInitialized) {
      _loadInitialBooks();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMoreBooks) {
      _loadMoreBooks();
    }
  }

  Future<void> _loadInitialBooks() async {
    if (_isLoading || _hasInitialized) return;

    setState(() {
      _isLoading = true;
      _currentOffset = 0;
      _books.clear();
      _hasMoreBooks = true;
      _hasInitialized = true;
    });

    await _loadBooks();
  }

  Future<void> _loadMoreBooks() async {
    if (_isLoading || !_hasMoreBooks) return;

    setState(() {
      _isLoading = true;
    });

    await _loadBooks();
  }

  Future<void> _loadBooks() async {
    try {
      ApiResult<InternalBookSearchResponse> result;

      switch (widget.section.type) {
        case HomepageSectionType.category:
          final content = widget.section.content as CategorySectionContent;
          result = await _bookApiService.searchInternalBooks(
            categoryIds: [content.categoryId],
            sortBy: content.sortBy,
            limit: _pageSize,
            offset: _currentOffset,
          );
          break;

        case HomepageSectionType.collection:
          final content = widget.section.content as CollectionSectionContent;
          result = await _bookApiService.searchInternalBooks(
            collectionIds: [content.collectionId],
            sortBy: content.sortBy,
            limit: _pageSize,
            offset: _currentOffset,
          );
          break;

        case HomepageSectionType.custom:
          final content = widget.section.content as CustomSectionContent;
          result = await _bookApiService.getCustomSectionBooks(
            endpoint: content.endpoint,
            parameters: content.parameters,
            sortBy: content.sortBy,
            limit: _pageSize,
            offset: _currentOffset,
          );
          break;

        default:
          // Fallback to latest books for other types
          result = await _bookApiService.getLatestBooks(
            limit: _pageSize,
            offset: _currentOffset,
          );
          break;
      }

      result.fold(
        (response) {
          if (mounted) {
            setState(() {
              if (_currentOffset == 0) {
                _books = response.books;
              } else {
                _books.addAll(response.books);
              }
              _currentOffset += response.books.length;
              _hasMoreBooks = response.books.length == _pageSize;
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
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onViewAll() {
    final section = widget.section;

    switch (section.type) {
      case HomepageSectionType.category:
        final content = section.content as CategorySectionContent;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GridBookSearchScreen(
              title: section.title,
              categoryIds: [content.categoryId],
            ),
          ),
        );
        break;

      case HomepageSectionType.collection:
        final content = section.content as CollectionSectionContent;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GridBookSearchScreen(
              title: section.title,
              collectionIds: [content.collectionId],
            ),
          ),
        );
        break;

      case HomepageSectionType.custom:
        // Note: Custom sections may need a specialized grid screen implementation
        // For now, we'll navigate to a basic grid that shows the section title
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GridBookSearchScreen(
              title: section.title,
              // Custom endpoints would need special handling in GridBookSearchScreen
              // This is a basic implementation - may need enhancement
            ),
          ),
        );
        break;

      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeaderWidget(
          title: widget.section.title,
          subtitle: widget.section.subtitle,
          onViewAll: _onViewAll,
        ),
        SizedBox(
          height: 280,
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
              scrollbars: false,
            ),
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const ClampingScrollPhysics(),
              clipBehavior: Clip.none,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _books.length + (_hasMoreBooks ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= _books.length) {
                  // Loading indicator at the end
                  return Container(
                    width: 50,
                    alignment: Alignment.center,
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const SizedBox.shrink(),
                  );
                }

                return HorizontalBookCard(book: _books[index]);
              },
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
