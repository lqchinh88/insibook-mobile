/// Data source types for paginated books screen
enum BooksDataSource {
  category('Books by Category'),
  collection('Books by Collection'),
  latest('Latest Books'),
  custom('Custom');

  const BooksDataSource(this.displayName);

  final String displayName;
}

/// Available sort options for books
enum BookSortBy {
  latest('latest', 'Latest'),
  random('random', 'Random'),
  rating('rating', 'Rating'),
  title('title', 'Title'),
  readCount('readCount', 'Read Count'),
  publishedDate('publishedDate', 'Published Date');

  const BookSortBy(this.value, this.displayName);

  final String value;
  final String displayName;

  static BookSortBy? fromString(String? value) {
    for (BookSortBy sortBy in BookSortBy.values) {
      if (sortBy.value == value) return sortBy;
    }
    return null;
  }
}

/// Available sort directions
enum BookSortDirection {
  asc('ASC', 'Ascending'),
  desc('DESC', 'Descending');

  const BookSortDirection(this.value, this.displayName);

  final String value;
  final String displayName;

  static BookSortDirection? fromString(String? value) {
    for (BookSortDirection direction in BookSortDirection.values) {
      if (direction.value == value) return direction;
    }
    return null;
  }
}

/// Configuration class for PaginatedBooksScreen
class BooksScreenConfig {
  /// The data source type
  final BooksDataSource source;

  /// Screen title displayed in app bar
  final String title;

  /// Category ID (required for category source)
  final String? categoryId;

  /// Collection ID (required for collection source)
  final String? collectionId;

  /// Custom endpoint path (required for custom source)
  final String? customEndpoint;

  /// Additional parameters for custom endpoint
  final Map<String, dynamic>? customParameters;

  /// Sort order for books (defaults to 'random' for variety)
  final String? sortBy;

  /// Sort direction (defaults to 'DESC' for most sort options, except title which defaults to 'ASC')
  final String? sortDirection;

  const BooksScreenConfig({
    required this.source,
    required this.title,
    this.categoryId,
    this.collectionId,
    this.customEndpoint,
    this.customParameters,
    this.sortBy,
    this.sortDirection,
  });

  /// Get the effective sort by value, defaulting to 'random'
  String get effectiveSortBy => sortBy ?? BookSortBy.random.value;

  /// Get the effective sort direction value with intelligent defaults
  String get effectiveSortDirection {
    if (sortDirection != null) return sortDirection!;

    // Smart defaults based on sort type
    switch (effectiveSortBy) {
      case 'title':
        return BookSortDirection.asc.value; // A-Z is more intuitive for titles
      case 'rating':
      case 'readCount':
      case 'publishedDate':
      case 'latest':
        return BookSortDirection.desc.value; // Highest/most recent first
      case 'random':
      default:
        return BookSortDirection.desc.value; // Direction doesn't matter for random, but DESC is safe default
    }
  }

  /// Validate configuration for the given source type
  bool isValid() {
    switch (source) {
      case BooksDataSource.category:
        return categoryId != null && categoryId!.isNotEmpty;
      case BooksDataSource.collection:
        return collectionId != null && collectionId!.isNotEmpty;
      case BooksDataSource.custom:
        return customEndpoint != null && customEndpoint!.isNotEmpty;
      case BooksDataSource.latest:
        return true; // Latest books don't require additional parameters
    }
  }

  @override
  String toString() {
    return 'BooksScreenConfig(source: $source, title: $title, sortBy: $effectiveSortBy, sortDirection: $effectiveSortDirection)';
  }
}