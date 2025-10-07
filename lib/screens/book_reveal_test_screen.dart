import 'package:flutter/material.dart';
import '../widgets/scrolling_book_reveal_widget.dart';

class BookRevealTestScreen extends StatefulWidget {
  const BookRevealTestScreen({super.key});

  @override
  State<BookRevealTestScreen> createState() => _BookRevealTestScreenState();
}

class _BookRevealTestScreenState extends State<BookRevealTestScreen> {
  late ScrollController _scrollController;
  double _scrollProgress = 0.0;
  bool _contentRevealed = false;

  // Test book data
  final String _bookTitle = "The Great Gatsby";
  final String _bookAuthor = "F. Scott Fitzgerald";
  final String _bookCoverUrl = "https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=300&h=450&fit=crop";

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

    // Calculate progress for the first part of the screen (book reveal area)
    final revealHeight = screenHeight * 0.8; // 80% of screen height for smoother transition
    final newProgress = (currentScroll / revealHeight).clamp(0.0, 1.0);

    if (mounted) {
      setState(() {
        _scrollProgress = newProgress;
      });
    }
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
              // Book reveal area - takes up initial screen
              SliverToBoxAdapter(
                child: SizedBox(
                  height: screenHeight, // Full screen height for reveal
                  child: Center(
                    child: ScrollingBookRevealWidget(
                      bookCoverUrl: _bookCoverUrl,
                      bookTitle: _bookTitle,
                      bookAuthor: _bookAuthor,
                      scrollProgress: _scrollProgress,
                      screenHeight: screenHeight,
                    ),
                  ),
                ),
              ),

              // Content sections (appear based on scroll progress)
              SliverToBoxAdapter(
                child: _buildScrollRevealedContent(
                  opacity: _calculateContentOpacity(0.3), // Start appearing at 30% scroll
                  yOffset: _calculateContentYOffset(0.3),
                  delay: 0.0,
                  child: _buildBookHeader(),
                ),
              ),

              SliverToBoxAdapter(
                child: _buildScrollRevealedContent(
                  opacity: _calculateContentOpacity(0.5), // Start appearing at 50% scroll
                  yOffset: _calculateContentYOffset(0.5),
                  delay: 200,
                  child: _buildSynopsisSection(),
                ),
              ),

              SliverToBoxAdapter(
                child: _buildScrollRevealedContent(
                  opacity: _calculateContentOpacity(0.7), // Start appearing at 70% scroll
                  yOffset: _calculateContentYOffset(0.7),
                  delay: 400,
                  child: _buildQuotesSection(),
                ),
              ),

              SliverToBoxAdapter(
                child: _buildScrollRevealedContent(
                  opacity: _calculateContentOpacity(0.9), // Start appearing at 90% scroll
                  yOffset: _calculateContentYOffset(0.9),
                  delay: 600,
                  child: _buildDetailsSection(),
                ),
              ),

              SliverToBoxAdapter(
                child: _buildScrollRevealedContent(
                  opacity: _calculateContentOpacity(1.0), // Fully visible at 100% scroll
                  yOffset: _calculateContentYOffset(1.0),
                  delay: 800,
                  child: _buildActionSection(),
                ),
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
          // Book title with animated entrance
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
                    _bookTitle,
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

          // Author
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: Text(
                    'by $_bookAuthor',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 32),

          // Decorative divider
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 1200),
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

  Widget _buildSynopsisSection() {
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
          Row(
            children: [
              Icon(
                Icons.book_rounded,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Synopsis',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'The Great Gatsby is a 1925 novel by American writer F. Scott Fitzgerald. Set in the Jazz Age on Long Island, the novel depicts narrator Nick Carraway\'s interactions with mysterious millionaire Jay Gatsby and Gatsby\'s obsession to reunite with his former lover, Daisy Buchanan.',
            style: theme.textTheme.bodyLarge?.copyWith(
              height: 1.6,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
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
          Text(
            '"So we beat on, boats against the current, borne back ceaselessly into the past."',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontStyle: FontStyle.italic,
              height: 1.6,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '— F. Scott Fitzgerald',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
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
                    content: Text('Starting to read $_bookTitle...'),
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