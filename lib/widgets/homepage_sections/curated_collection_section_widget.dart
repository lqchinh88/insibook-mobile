import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/homepage_models.dart';
import '../../models/curated_collection_models.dart';
import '../../screens/curated_collection_scroll_spinning_screen.dart';
import '../../screens/curated_collection_journey_screen.dart';
import '../../providers/language_provider.dart';
import '../cached_image.dart';

class CuratedCollectionSectionWidget extends StatefulWidget {
  final HomepageSection section;
  final bool shouldLoad;

  const CuratedCollectionSectionWidget({super.key, required this.section, this.shouldLoad = true});

  @override
  State<CuratedCollectionSectionWidget> createState() =>
      _CuratedCollectionSectionWidgetState();
}

class _CuratedCollectionSectionWidgetState
    extends State<CuratedCollectionSectionWidget> {
  CuratedCollection? _curatedCollection;
  bool _isLoading = false;
  bool _hasInitialized = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(CuratedCollectionSectionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Start loading when shouldLoad becomes true
    if (widget.shouldLoad && !oldWidget.shouldLoad && !_hasInitialized) {
      _loadCuratedCollection();
    }
  }

  Future<void> _loadCuratedCollection() async {
    if (_isLoading || _hasInitialized) return;

    final content = widget.section.content as CuratedCollectionSectionContent;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _curatedCollection = null;
      _hasInitialized = true;
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
    final currentLanguage = context.read<LanguageProvider>().currentLanguage;

    // Get localized content
    final title = collection.getTitle(currentLanguage);
    final description = collection.getDescription(currentLanguage);

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
              Container(
                width: double.infinity,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: _buildCoverImage(collection),
              ),

              // Content Section with Book Count at top right
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          title,
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
                        if (description.isNotEmpty) ...[
                          Text(
                            description,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              height: 1.3,
                            ),
                            // Removed maxLines and overflow to show full description
                          ),
                          const SizedBox(height: 8),
                        ],
                      ],
                    ),

                    // Book Count - positioned at top right of content area
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.menu_book,
                              size: 12,
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
                      ),
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
      return CachedImage(
        imageUrl: collection.coverImageUrl!,
        fit: BoxFit.fitWidth, // Full width, scale height to maintain aspect ratio
        errorWidget: _buildPlaceholderImage(theme),
        placeholder: Container(
          height: 200, // Fallback height for loading state
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
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
          ),
        ),
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