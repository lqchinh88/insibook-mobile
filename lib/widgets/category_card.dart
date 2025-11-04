import 'package:flutter/material.dart';
import '../models/book_models.dart';
import 'cached_image.dart';

class CategoryCard extends StatefulWidget {
  final BookCategory category;
  final VoidCallback? onTap;

  const CategoryCard({super.key, required this.category, this.onTap});

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _elevationAnimation = Tween<double>(
      begin: 8.0,
      end: 12.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _animationController.reverse();
    widget.onTap?.call();
  }

  void _onTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            height: 200, // Fixed height for consistency
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: _elevationAnimation.value,
                  offset: Offset(0, _elevationAnimation.value / 2),
                ),
              ],
            ),
            child: Material(
              borderRadius: BorderRadius.circular(16),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTapDown: _onTapDown,
                onTapUp: _onTapUp,
                onTapCancel: _onTapCancel,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background image
                    _buildBackgroundImage(),

                    // Gradient overlay for text readability
                    _buildGradientOverlay(),

                    // Category content
                    _buildCategoryContent(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBackgroundImage() {
    if (widget.category.imageUrl != null && widget.category.imageUrl!.isNotEmpty) {
      return CachedImage(
        imageUrl: widget.category.imageUrl!,
        fit: BoxFit.cover,
        errorWidget: _buildFallbackBackground(),
        placeholder: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                Theme.of(context).colorScheme.secondary.withValues(alpha: 0.6),
              ],
            ),
          ),
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
        ),
      );
    } else {
      return _buildFallbackBackground();
    }
  }

  Widget _buildFallbackBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getCategoryColor().withValues(alpha: 0.8),
            _getCategoryColor().withValues(alpha: 0.6),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.category,
          size: 48,
          color: Colors.white.withValues(alpha: 0.8),
        ),
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.transparent,
            Colors.black.withValues(alpha: 0.3),
            Colors.black.withValues(alpha: 0.7),
          ],
          stops: const [0.0, 0.4, 0.7, 1.0],
        ),
      ),
    );
  }

  Widget _buildCategoryContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getCategoryIcon(),
              size: 24,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 12),

          // Category name
          Text(
            widget.category.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  blurRadius: 4,
                  offset: Offset(0, 2),
                  color: Colors.black45,
                ),
              ],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          // Category description (if available)
          if (widget.category.description != null && widget.category.description!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              widget.category.description!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.9),
                shadows: [
                  Shadow(
                    blurRadius: 2,
                    offset: Offset(0, 1),
                    color: Colors.black45,
                  ),
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Color _getCategoryColor() {
    // Generate consistent colors based on category ID
    final colors = [
      const Color(0xFF6366F1), // Indigo
      const Color(0xFF8B5CF6), // Violet
      const Color(0xFFEC4899), // Pink
      const Color(0xFF14B8A6), // Teal
      const Color(0xFFF59E0B), // Amber
      const Color(0xFF10B981), // Emerald
      const Color(0xFF3B82F6), // Blue
      const Color(0xFFEF4444), // Red
      const Color(0xFF8B5A2B), // Brown
      const Color(0xFF6B7280), // Gray
    ];

    final hash = widget.category.id.hashCode;
    final index = hash.abs() % colors.length;
    return colors[index];
  }

  IconData _getCategoryIcon() {
    // Map common categories to appropriate icons
    final name = widget.category.name.toLowerCase();

    if (name.contains('business') || name.contains('entrepreneur')) {
      return Icons.business;
    } else if (name.contains('art') || name.contains('design')) {
      return Icons.palette;
    } else if (name.contains('science') || name.contains('biology')) {
      return Icons.science;
    } else if (name.contains('history') || name.contains('biography')) {
      return Icons.history;
    } else if (name.contains('cooking') || name.contains('food')) {
      return Icons.restaurant;
    } else if (name.contains('travel') || name.contains('adventure')) {
      return Icons.flight;
    } else if (name.contains('technology') || name.contains('computer')) {
      return Icons.computer;
    } else if (name.contains('health') || name.contains('fitness')) {
      return Icons.fitness_center;
    } else if (name.contains('education') || name.contains('learning')) {
      return Icons.school;
    } else if (name.contains('romance') || name.contains('love')) {
      return Icons.favorite;
    } else if (name.contains('mystery') || name.contains('thriller')) {
      return Icons.psychology;
    } else if (name.contains('fantasy') || name.contains('magic')) {
      return Icons.auto_awesome;
    } else if (name.contains('sports') || name.contains('game')) {
      return Icons.sports;
    } else {
      return Icons.menu_book; // Default icon
    }
  }
}