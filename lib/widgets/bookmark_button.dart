import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/book_api_service.dart';
import '../providers/book_api_provider.dart';
import '../providers/language_provider.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../utils/result.dart';

enum BookmarkButtonSize {
  small,  // For compact cards
  medium, // For regular cards
}

class BookmarkButton extends StatefulWidget {
  final String bookId;
  final bool initialBookmarkState;
  final BookmarkButtonSize size;
  final Function(bool isBookmarked)? onBookmarkChanged;

  const BookmarkButton({
    super.key,
    required this.bookId,
    required this.initialBookmarkState,
    this.size = BookmarkButtonSize.medium,
    this.onBookmarkChanged,
  });

  @override
  State<BookmarkButton> createState() => _BookmarkButtonState();
}

class _BookmarkButtonState extends State<BookmarkButton> {
  late bool _isBookmarked;
  bool _isLoading = false;
  late final BookApiService _bookApiService;

  @override
  void initState() {
    super.initState();
    _isBookmarked = widget.initialBookmarkState;
    _bookApiService = context.read<BookApiProvider>().bookApiService;
  }

  @override
  void didUpdateWidget(BookmarkButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialBookmarkState != widget.initialBookmarkState) {
      setState(() {
        _isBookmarked = widget.initialBookmarkState;
      });
    }
  }

  Future<void> _toggleBookmark() async {
    if (_isLoading) return;

    // Check authentication first
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isAuthenticated) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Store context references before async operation
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final langProvider = context.read<LanguageProvider>();

    try {
      final result = await _bookApiService.toggleBookmark(bookId: widget.bookId);

      result.fold(
        (bookmarkResponse) {
          setState(() {
            _isBookmarked = bookmarkResponse.isBookmarked;
            _isLoading = false;
          });

          // Notify parent widget of state change
          widget.onBookmarkChanged?.call(_isBookmarked);
        },
        (error) {
          setState(() {
            _isLoading = false;
          });

          // Show error feedback only
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(
                langProvider.l10n['bookmark_error'] ?? 'Failed to update bookmark',
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        },
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      // Show generic error
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
            langProvider.l10n['bookmark_error'] ?? 'Failed to update bookmark',
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final buttonSize = _getButtonSize();
    final iconSize = _getIconSize();

    return Positioned(
      top: -4,
      right: -4,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: buttonSize,
          height: buttonSize,
          decoration: BoxDecoration(
            color: _isBookmarked
                ? Theme.of(context).primaryColor
                : Colors.black.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(buttonSize / 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: InkWell(
            onTap: _isLoading ? null : _toggleBookmark,
            borderRadius: BorderRadius.circular(buttonSize / 2),
            child: Center(
              child: _isLoading
                  ? SizedBox(
                      width: iconSize * 0.8,
                      height: iconSize * 0.8,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(
                      _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      size: iconSize,
                      color: Colors.white,
                    ),
            ),
          ),
        ),
      ),
    );
  }

  double _getButtonSize() {
    switch (widget.size) {
      case BookmarkButtonSize.small:
        return 32;
      case BookmarkButtonSize.medium:
        return 40;
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case BookmarkButtonSize.small:
        return 16;
      case BookmarkButtonSize.medium:
        return 20;
    }
  }
}