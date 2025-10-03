import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/homepage_models.dart';
import '../utils/result.dart';
import '../providers/language_provider.dart';
import '../services/homepage_service.dart';
import '../widgets/homepage_sections/hero_section_widget.dart';
import '../widgets/homepage_sections/horizontal_books_section_widget.dart';
import '../widgets/homepage_sections/horizontal_resume_reading_section_widget.dart';

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
  int _refreshKey = 0;

  @override
  void initState() {
    super.initState();
    _homepageService = HomepageService();
    _loadHomepage();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadHomepage() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _refreshKey++; // Increment refresh key to force widget rebuilds
        _sections.clear(); // Clear existing sections to show loading state
      });
    }

    final result = await _homepageService.getHomepage();

    result.fold(
      (homepageResponse) {
        if (mounted) {
          setState(() {
            _sections = homepageResponse.sections;
            _isLoading = false;
          });
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

  Widget _buildSection(HomepageSection section) {
    try {
      switch (section.type) {
        case HomepageSectionType.hero:
          return HeroSectionWidget(
            key: ValueKey('hero_${section.id}_$_refreshKey'),
            section: section,
          );

        case HomepageSectionType.category:
        case HomepageSectionType.collection:
        case HomepageSectionType.custom:
          return HorizontalBooksSectionWidget(
            key: ValueKey('horizontal_${section.id}_$_refreshKey'),
            section: section,
          );

        case HomepageSectionType.resumeReading:
          return HorizontalResumeReadingSectionWidget(
            key: ValueKey('resume_reading_${section.id}_$_refreshKey'),
            section: section,
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
