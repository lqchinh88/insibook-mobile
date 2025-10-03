import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/homepage_models.dart';
import '../../models/book_models.dart';
import '../../providers/book_api_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/book_api_service.dart';
import '../../utils/result.dart';
import '../horizontal_resume_reading_card.dart';
import 'section_header_widget.dart';

class HorizontalResumeReadingSectionWidget extends StatefulWidget {
  final HomepageSection section;

  const HorizontalResumeReadingSectionWidget({super.key, required this.section});

  @override
  State<HorizontalResumeReadingSectionWidget> createState() =>
      _HorizontalResumeReadingSectionWidgetState();
}

class _HorizontalResumeReadingSectionWidgetState
    extends State<HorizontalResumeReadingSectionWidget> {
  List<ResumeReadingBook> _resumeReadingBooks = [];
  bool _isLoading = false;
  late final BookApiService _bookApiService;

  @override
  void initState() {
    super.initState();
    _bookApiService = context.read<BookApiProvider>().bookApiService;
    _loadResumeReadingBooks();
  }

  Future<void> _loadResumeReadingBooks() async {
    if (_isLoading) return;

    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isAuthenticated) {
      // Don't show resume reading section for unauthenticated users
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    setState(() {
      _isLoading = true;
      _resumeReadingBooks.clear();
    });

    final content = widget.section.content as ResumeReadingSectionContent;
    final result = await _bookApiService.getResumeReadingBooks(
      limit: content.limit,
    );

    result.fold(
      (response) {
        if (mounted) {
          setState(() {
            _resumeReadingBooks = response.books;
            _isLoading = false;
          });
        }
      },
      (error) {
        if (mounted) {
          setState(() {
            // Hide on authentication errors
            if (error.toString().contains('401')) {
              _isLoading = false;
              return;
            }
            _isLoading = false;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Hide resume reading sections if user is not authenticated or no books available
    if (_resumeReadingBooks.isEmpty && !_isLoading) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeaderWidget(
          title: widget.section.title,
          subtitle: widget.section.subtitle,
          // Resume reading sections typically don't need "view all" functionality
          onViewAll: null,
        ),
        SizedBox(
          height: 280,
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
              scrollbars: false,
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const ClampingScrollPhysics(),
              clipBehavior: Clip.none,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _resumeReadingBooks.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= _resumeReadingBooks.length) {
                  // Loading indicator at the end
                  return Container(
                    width: 50,
                    alignment: Alignment.center,
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const SizedBox.shrink(),
                  );
                }

                return HorizontalResumeReadingCard(
                  resumeReadingBook: _resumeReadingBooks[index],
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}