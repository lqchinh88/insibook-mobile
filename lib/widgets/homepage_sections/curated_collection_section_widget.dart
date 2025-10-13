import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/homepage_models.dart';
import '../../models/curated_collection_models.dart';
import '../../screens/curated_collection_scroll_spinning_screen.dart';
import '../../screens/curated_collection_journey_screen.dart';
import '../../providers/language_provider.dart';
import 'section_header_widget.dart';

class CuratedCollectionSectionWidget extends StatefulWidget {
  final HomepageSection section;

  const CuratedCollectionSectionWidget({super.key, required this.section});

  @override
  State<CuratedCollectionSectionWidget> createState() =>
      _CuratedCollectionSectionWidgetState();
}

class _CuratedCollectionSectionWidgetState
    extends State<CuratedCollectionSectionWidget> {
  CuratedCollection? _curatedCollection;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCuratedCollection();
  }

  Future<void> _loadCuratedCollection() async {
    final content = widget.section.content as CuratedCollectionSectionContent;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _curatedCollection = null;
    });

    try {
      // Use embedded collection data from the API response
      if (content.collection != null) {
        if (mounted) {
          setState(() {
            _curatedCollection = content.collection;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = context.read<LanguageProvider>().l10n['no_collection_data'];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = context.read<LanguageProvider>().l10n['failed_to_load_collection_card'];
          _isLoading = false;
        });
      }
    }
  }

  void _onCollectionTap() {
    if (_curatedCollection == null) return;

    final content = widget.section.content as CuratedCollectionSectionContent;

    Widget destinationScreen;

    switch (content.presentationType.toUpperCase()) {
      case 'SCROLL_SPIN':
        destinationScreen = CuratedCollectionScrollSpinningScreen(
          collectionId: _curatedCollection!.id,
        );
        break;
      case 'JOURNEY':
        destinationScreen = CuratedCollectionJourneyScreen(
          collectionId: _curatedCollection!.id,
        );
        break;
      default:
        // Default to scroll spinning if presentation type is unknown
        destinationScreen = CuratedCollectionScrollSpinningScreen(
          collectionId: _curatedCollection!.id,
        );
        break;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => destinationScreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeaderWidget(
          title: widget.section.title,
          subtitle: widget.section.subtitle,
          onViewAll: null, // Curated collections don't have "View All"
        ),
        const SizedBox(height: 16),

        if (_isLoading)
          _buildLoadingState()
        else if (_errorMessage != null)
          _buildErrorState()
        else if (_curatedCollection != null)
          _buildCollectionCard(_curatedCollection!)
        else
          _buildEmptyState(),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 200,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 200,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.error.withValues(alpha: 0.2),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? context.read<LanguageProvider>().l10n['failed_to_load_collection_card'],
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _loadCuratedCollection,
              child: Text(context.read<LanguageProvider>().l10n['retry_collection']),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 200,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.collections_bookmark_outlined,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              context.read<LanguageProvider>().l10n['no_collection_available'],
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollectionCard(CuratedCollection collection) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: _onCollectionTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Full-width Cover Image
              SizedBox(
                height: 160,
                width: double.infinity,
                child: _buildCoverImage(collection),
              ),

              // Content Section
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      collection.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 6),

                    // Curator Name
                    if (collection.curatorName != null) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 14,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${context.read<LanguageProvider>().l10n['curated_by']} ${collection.curatorName}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                    ],

                    // Description
                    if (collection.description != null) ...[
                      Text(
                        collection.description!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                    ],

                    // Bottom Row: Book Count and CTA
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Book Count
                        Row(
                          children: [
                            Icon(
                              Icons.menu_book,
                              size: 14,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${collection.bookCount} ${context.read<LanguageProvider>().l10n['books']}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),

                        // Call to Action
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                context.read<LanguageProvider>().l10n['explore_collection'],
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 3),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 10,
                                color: theme.colorScheme.onPrimary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoverImage(CuratedCollection collection) {
    final theme = Theme.of(context);

    if (collection.coverImageUrl != null && collection.coverImageUrl!.isNotEmpty) {
      return Image.network(
        collection.coverImageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderImage(theme);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.3),
                  theme.colorScheme.secondary.withValues(alpha: 0.3),
                ],
              ),
            ),
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                    : null,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
              ),
            ),
          );
        },
      );
    } else {
      return _buildPlaceholderImage(theme);
    }
  }

  Widget _buildPlaceholderImage(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.3),
            theme.colorScheme.secondary.withValues(alpha: 0.3),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.collections_bookmark_rounded,
          size: 40,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}