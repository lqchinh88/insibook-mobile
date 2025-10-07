import 'package:flutter/material.dart';
import '../widgets/scrolling_book_reveal_widget.dart';

class BookData {
  final String title;
  final String author;
  final String coverUrl;

  BookData({
    required this.title,
    required this.author,
    required this.coverUrl,
  });
}

class CuratedCollectionScrollSpinningScreen extends StatefulWidget {
  const CuratedCollectionScrollSpinningScreen({super.key});

  @override
  State<CuratedCollectionScrollSpinningScreen> createState() => _CuratedCollectionScrollSpinningScreenState();
}

class _CuratedCollectionScrollSpinningScreenState extends State<CuratedCollectionScrollSpinningScreen> {
  late ScrollController _scrollController;
  double _scrollProgress = 0.0;
  bool _contentRevealed = false;

  // Test book data - multiple books
  final List<BookData> _books = [
    BookData(
      title: "The Great Gatsby",
      author: "F. Scott Fitzgerald",
      coverUrl: "https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=300&h=450&fit=crop",
    ),
    BookData(
      title: "To Kill a Mockingbird",
      author: "Harper Lee",
      coverUrl: "https://images.unsplash.com/photo-1589829085413-56a89862cdbf?w=300&h=450&fit=crop",
    ),
    BookData(
      title: "1984",
      author: "George Orwell",
      coverUrl: "https://images.unsplash.com/photo-1543002588-bfa74002ed7e?w=300&h=450&fit=crop",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_updateScrollProgress);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollProgress);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateScrollProgress() {
    if (!_scrollController.hasClients) return;

    final currentScroll = _scrollController.offset;
    final screenHeight = MediaQuery.of(context).size.height;

    // Total sections: book covers (screenHeight each) + book details (estimated 400px each) + collection summary
    final totalSections = _books.length * 2; // cover + details for each book
    final totalHeight = (screenHeight * _books.length) + (400 * _books.length) + 600; // summary section
    final newProgress = (currentScroll / totalHeight).clamp(0.0, 1.0);

    if (mounted) {
      setState(() {
        _scrollProgress = newProgress;
      });
    }
  }

  // Helper methods for individual book section progress calculation
  double _calculateBookSectionProgress(int sectionIndex) {
    final screenHeight = MediaQuery.of(context).size.height;
    final currentScroll = _scrollController.offset;

    // Each book cover gets full screen height
    final sectionHeight = screenHeight;
    final sectionStartOffset = sectionIndex ~/ 2 * (screenHeight + 400); // Every other section is a cover
    final sectionEndOffset = sectionStartOffset + sectionHeight;

    if (currentScroll <= sectionStartOffset) return 0.0;
    if (currentScroll >= sectionEndOffset) return 1.0;

    return ((currentScroll - sectionStartOffset) / sectionHeight).clamp(0.0, 1.0);
  }

  // Widget for individual book details
  Widget _buildBookDetails(BookData book, int sectionIndex) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Book title
          Text(
            book.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 8),

          // Author
          Text(
            'by ${book.author}',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              fontStyle: FontStyle.italic,
            ),
          ),

          const SizedBox(height: 16),

          // Decorative divider
          Container(
            width: 60,
            height: 3,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 20),

          // Book description (different for each book)
          _buildBookDescription(book),

          const SizedBox(height: 24),

          // Rating and reading time
          Row(
            children: [
              Icon(Icons.star_rounded, color: Colors.amber, size: 20),
              const SizedBox(width: 4),
              Text(
                _getBookRating(book),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 20),
              Icon(Icons.schedule_rounded, color: Colors.blue, size: 20),
              const SizedBox(width: 4),
              Text(
                _getBookReadingTime(book),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Quote specific to this book
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                  theme.colorScheme.secondaryContainer.withValues(alpha: 0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.format_quote_rounded,
                  color: theme.colorScheme.primary, size: 20),
                const SizedBox(height: 8),
                Text(
                  _getBookQuote(book),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getBookAuthor(book),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods for scroll-based content reveal
  Widget _buildScrollRevealedContent({
    required Widget child,
    required double opacity,
    required double yOffset,
    required double delay,
  }) {
    return AnimatedContainer(
      duration: Duration(milliseconds: (200 + delay).round()),
      transform: Matrix4.translationValues(0, yOffset, 0),
      child: Opacity(
        opacity: opacity,
        child: child,
      ),
    );
  }

  double _calculateContentOpacity(double startThreshold) {
    if (_scrollProgress <= startThreshold) return 0.0;

    final fadeDuration = 0.2; // 20% of scroll for fade in
    final endThreshold = (startThreshold + fadeDuration).clamp(0.0, 1.0);

    if (_scrollProgress >= endThreshold) return 1.0;

    // Linear interpolation from startThreshold to endThreshold
    return (_scrollProgress - startThreshold) / fadeDuration;
  }

  double _calculateContentYOffset(double startThreshold) {
    if (_scrollProgress <= startThreshold) return 50.0; // Start position

    final moveDuration = 0.15; // 15% of scroll for movement
    final endThreshold = (startThreshold + moveDuration).clamp(0.0, 1.0);

    if (_scrollProgress >= endThreshold) return 0.0; // Final position

    // Linear interpolation from 50px to 0px
    final progress = (_scrollProgress - startThreshold) / moveDuration;
    return 50.0 * (1.0 - progress);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.1),
                  theme.colorScheme.surface,
                  theme.colorScheme.surface,
                ],
                stops: const [0.0, 0.3, 1.0],
              ),
            ),
          ),

          // Main scrollable content
          CustomScrollView(
            controller: _scrollController,
            physics: const ClampingScrollPhysics(), // Changed from BouncingScrollPhysics
            slivers: [
              // Linear book flow: cover animation → details → next book
              ...List.generate(_books.length * 2, (index) {
                final bookIndex = index ~/ 2; // Each book gets 2 sections: cover + details
                final isCoverSection = index % 2 == 0;

                if (isCoverSection) {
                  // Book cover animation section
                  return SliverToBoxAdapter(
                    child: SizedBox(
                      height: screenHeight, // Full screen height for book animation
                      child: Center(
                        child: ScrollingBookRevealWidget(
                          bookCoverUrl: _books[bookIndex].coverUrl,
                          bookTitle: _books[bookIndex].title,
                          bookAuthor: _books[bookIndex].author,
                          scrollProgress: _calculateBookSectionProgress(index),
                          screenHeight: screenHeight,
                        ),
                      ),
                    ),
                  );
                } else {
                  // Book details section
                  return SliverToBoxAdapter(
                    child: _buildBookDetails(_books[bookIndex], index),
                  );
                }
              }),

              // Final collection summary section
              SliverToBoxAdapter(
                child: _buildCollectionSummary(),
              ),

              // Footer
              SliverToBoxAdapter(
                child: SizedBox(height: 100), // Extra padding at bottom
              ),
            ],
          ),

          // Scroll indicator (visible only at start)
          if (_scrollProgress < 0.1)
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: Center(
                child: AnimatedOpacity(
                  opacity: 1.0 - (_scrollProgress * 10), // Fade out as we scroll
                  duration: const Duration(milliseconds: 300),
                  child: Column(
                    children: [
                      Text(
                        'Scroll to reveal',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 24,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBookHeader() {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          // Header title
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 30 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: Text(
                    'Featured Collection',
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // List of book titles
          ..._books.asMap().entries.map((entry) {
            final index = entry.key;
            final book = entry.value;
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 1000 + (index * 200)),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        '${index + 1}. ${book.title} — ${book.author}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              },
            );
          }).toList(),

          const SizedBox(height: 32),

          // Decorative divider
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 1400),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Container(
                  width: 100,
                  height: 3,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.secondary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Helper methods for book-specific data
  Widget _buildBookDescription(BookData book) {
    final theme = Theme.of(context);
    final descriptions = {
      'The Great Gatsby': 'A 1925 novel by American writer F. Scott Fitzgerald. Set in the Jazz Age on Long Island, the novel depicts narrator Nick Carraway\'s interactions with mysterious millionaire Jay Gatsby and Gatsby\'s obsession to reunite with his former lover, Daisy Buchanan.',
      'To Kill a Mockingbird': 'A powerful story of racial injustice and childhood innocence set in the Depression-era South. Through the eyes of Scout Finch, we witness her father, lawyer Atticus Finch, defend a black man falsely accused of rape.',
      '1984': 'A dystopian social science fiction novel by English novelist George Orwell. Published in 1949, it follows the life of Winston Smith, a low-ranking member of the Party in Oceania, where independent thinking is a crime.',
    };

    return Text(
      descriptions[book.title] ?? 'A classic literary masterpiece that continues to captivate readers worldwide.',
      style: theme.textTheme.bodyLarge?.copyWith(
        height: 1.6,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
      ),
    );
  }

  String _getBookRating(BookData book) {
    final ratings = {
      'The Great Gatsby': '4.7 / 5.0',
      'To Kill a Mockingbird': '4.8 / 5.0',
      '1984': '4.6 / 5.0',
    };
    return ratings[book.title] ?? '4.5 / 5.0';
  }

  String _getBookReadingTime(BookData book) {
    final times = {
      'The Great Gatsby': '3-4 hours',
      'To Kill a Mockingbird': '6-8 hours',
      '1984': '5-7 hours',
    };
    return times[book.title] ?? '4-6 hours';
  }

  String _getBookQuote(BookData book) {
    final quotes = {
      'The Great Gatsby': '"So we beat on, boats against the current, borne back ceaselessly into the past."',
      'To Kill a Mockingbird': '"You never really understand a person until you consider things from his point of view... until you climb into his skin and walk around in it."',
      '1984': '"War is peace. Freedom is slavery. Ignorance is strength."',
    };
    return quotes[book.title] ?? '"A timeless quote from this literary masterpiece."';
  }

  String _getBookAuthor(BookData book) {
    return '— ${book.author}';
  }

  Widget _buildCollectionSummary() {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.1),
            theme.colorScheme.secondary.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.collections_bookmark_rounded,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Collection Complete',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'You\'ve explored three remarkable works that have shaped literature and continue to influence readers worldwide. Each book offers unique insights into the human experience.',
            style: theme.textTheme.bodyLarge?.copyWith(
              height: 1.6,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Starting to read the collection...'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                elevation: 8,
                shadowColor: theme.colorScheme.primary.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Start Reading Collection',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuotesSection() {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            theme.colorScheme.secondaryContainer.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.format_quote_rounded,
            color: theme.colorScheme.primary,
            size: 32,
          ),
          const SizedBox(height: 16),
          ..._books.asMap().entries.map((entry) {
            final index = entry.key;
            final quotes = [
              '"So we beat on, boats against the current, borne back ceaselessly into the past."',
              '"You never really understand a person until you consider things from his point of view... until you climb into his skin and walk around in it."',
              '"War is peace. Freedom is slavery. Ignorance is strength."',
            ];
            final authors = [
              '— F. Scott Fitzgerald',
              '— Harper Lee',
              '— George Orwell',
            ];

            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quotes[index],
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontStyle: FontStyle.italic,
                      height: 1.6,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    authors[index],
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  if (index < _books.length - 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              theme.colorScheme.outline.withValues(alpha: 0.3),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildDetailsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          _buildDetailCard(
            icon: Icons.star_rounded,
            title: 'Rating',
            content: '4.7 / 5.0',
            subtitle: '2.3M reviews',
            color: Colors.amber,
          ),
          const SizedBox(height: 16),
          _buildDetailCard(
            icon: Icons.schedule_rounded,
            title: 'Reading Time',
            content: '3-4 hours',
            subtitle: '180 pages',
            color: Colors.blue,
          ),
          const SizedBox(height: 16),
          _buildDetailCard(
            icon: Icons.category_rounded,
            title: 'Genre',
            content: 'Classic Fiction',
            subtitle: 'Literary Novel',
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String title,
    required String content,
    required String subtitle,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                Text(
                  content,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionSection() {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Starting to read the collection...'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                elevation: 8,
                shadowColor: theme.colorScheme.primary.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Start Reading',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: theme.colorScheme.outline),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Back to Library',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}