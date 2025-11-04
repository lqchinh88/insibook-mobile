import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/homepage_models.dart';
import '../utils/result.dart';
import '../providers/language_provider.dart';
import '../services/homepage_service.dart';
import '../widgets/homepage_sections/hero_section_widget.dart';
import '../widgets/homepage_sections/horizontal_books_section_widget.dart';
import '../widgets/homepage_sections/horizontal_resume_reading_section_widget.dart';
import '../widgets/homepage_sections/curated_collection_section_widget.dart';
import '../widgets/homepage_sections/all_categories_section_widget.dart';

class RichHomeScreen extends StatefulWidget {
  const RichHomeScreen({super.key});

  @override
  State<RichHomeScreen> createState() => _RichHomeScreenState();
}

class _RichHomeScreenState extends State<RichHomeScreen> {
  List<HomepageSection> _sections = [];
  bool _isLoading = false;
  String? _errorMessage;
  late final HomepageService _homepageService;

  // Section-specific loading states using ValueNotifier for targeted rebuilds
  final Map<String, ValueNotifier<bool>> _sectionLoadingNotifiers = {};

  @override
  void initState() {
    super.initState();
    _homepageService = HomepageService();
    _loadHomepage();
  }

  @override
  void dispose() {
    // Dispose all ValueNotifiers to prevent memory leaks
    for (final notifier in _sectionLoadingNotifiers.values) {
      notifier.dispose();
    }
    _sectionLoadingNotifiers.clear();
    super.dispose();
  }

  Future<void> _loadHomepage() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _sections.clear();
      });
      // Dispose old notifiers
      for (final notifier in _sectionLoadingNotifiers.values) {
        notifier.dispose();
      }
      _sectionLoadingNotifiers.clear();
    }

    final result = await _homepageService.getHomepage();

    result.fold(
      (homepageResponse) {
        if (mounted) {
          setState(() {
            _sections = homepageResponse.sections;
            _isLoading = false;
          });
          // Initialize ValueNotifiers for each section
          for (final section in _sections) {
            _sectionLoadingNotifiers[section.id] = ValueNotifier<bool>(true);
          }
          // Start staggered loading of sections
          _loadSectionsStaggered();
        }
      },
      (error) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Failed to load homepage content';
            _isLoading = false;
          });
        }
      },
    );
  }

  // Load sections with staggered delays to prevent main thread blocking
  void _loadSectionsStaggered() {
    for (int i = 0; i < _sections.length; i++) {
      final section = _sections[i];

      // Stagger the loading with increasing delays
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted && !_isLoading) {
          _triggerSectionLoad(section);
        }
      });
    }
  }

  // Trigger section widget to load its data using ValueNotifier
  void _triggerSectionLoad(HomepageSection section) {
    // Update section notifier to trigger data loading in child widgets
    final notifier = _sectionLoadingNotifiers[section.id];
    if (notifier != null && mounted) {
      notifier.value = false; // Set to false to indicate ready to load
    }
  }

  Widget _buildSection(HomepageSection section) {
    final loadingNotifier = _sectionLoadingNotifiers[section.id];
    if (loadingNotifier == null) return const SizedBox.shrink();

    try {
      switch (section.type) {
        case HomepageSectionType.hero:
          return ValueListenableBuilder<bool>(
            valueListenable: loadingNotifier,
            builder: (context, shouldLoad, child) {
              return HeroSectionWidget(
                key: GlobalObjectKey(section.id), // Use GlobalObjectKey to preserve widget instance
                section: section,
                shouldLoad: !shouldLoad, // shouldLoad when not loading
              );
            },
          );

        case HomepageSectionType.category:
        case HomepageSectionType.collection:
        case HomepageSectionType.custom:
          return ValueListenableBuilder<bool>(
            valueListenable: loadingNotifier,
            builder: (context, shouldLoad, child) {
              return HorizontalBooksSectionWidget(
                key: ValueKey('horizontal_${section.id}'),
                section: section,
                shouldLoad: !shouldLoad, // shouldLoad when not loading
              );
            },
          );

        case HomepageSectionType.curatedCollection:
          return ValueListenableBuilder<bool>(
            valueListenable: loadingNotifier,
            builder: (context, shouldLoad, child) {
              return CuratedCollectionSectionWidget(
                key: ValueKey('curated_collection_${section.id}'),
                section: section,
                shouldLoad: !shouldLoad, // shouldLoad when not loading
              );
            },
          );

        case HomepageSectionType.resumeReading:
          return ValueListenableBuilder<bool>(
            valueListenable: loadingNotifier,
            builder: (context, shouldLoad, child) {
              return HorizontalResumeReadingSectionWidget(
                key: ValueKey('resume_reading_${section.id}'),
                section: section,
                shouldLoad: !shouldLoad, // shouldLoad when not loading
              );
            },
          );

        case HomepageSectionType.allCategories:
          return ValueListenableBuilder<bool>(
            valueListenable: loadingNotifier,
            builder: (context, shouldLoad, child) {
              return AllCategoriesSectionWidget(
                key: ValueKey('all_categories_${section.id}'),
                section: section,
                shouldLoad: !shouldLoad, // shouldLoad when not loading (consistent with other sections)
              );
            },
          );
      }
    } catch (e) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Text('Error loading section: ${section.title}'),
      );
    }
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        final l10n = languageProvider.l10n;

        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadHomepage,
                  child: Text(l10n['retry']),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        final l10n = languageProvider.l10n;

        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.home_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  l10n['no_content_available'],
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadHomepage,
          child: _isLoading && _sections.isEmpty
              ? _buildLoadingState()
              : _errorMessage != null && _sections.isEmpty
              ? _buildErrorState(_errorMessage!)
              : _sections.isEmpty
              ? _buildEmptyState()
              : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ..._sections.map(_buildSection),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
