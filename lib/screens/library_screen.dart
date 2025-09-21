import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_book_request_models.dart';
import '../models/book_models.dart';
import '../models/bookmark_models.dart';
import '../models/saved_insight_models.dart';
import '../services/user_book_request_service.dart';
import '../services/book_api_service.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import '../lang/app_localizations.dart';
import '../widgets/book_request_card.dart';
import '../widgets/horizontal_book_card.dart';
import '../widgets/saved_insight_card.dart';
import '../utils/result.dart';
import '../utils/book_request_extensions.dart';
import '../constants/ui_constants.dart';
import '../constants/api_constants.dart';
import 'book_details_screen.dart';
import 'auth/login_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

enum LibraryTab { bookmarks, requests, insights }

class _LibraryScreenState extends State<LibraryScreen> {
  final UserBookRequestService _requestService = UserBookRequestService();
  final BookApiService _bookApiService = BookApiService();
  final ScrollController _scrollController = ScrollController();
  final ScrollController _bookmarksScrollController = ScrollController();
  final ScrollController _savedInsightsScrollController = ScrollController();

  LibraryTab _selectedTab = LibraryTab.bookmarks;

  // Requests state
  List<UserBookRequest> _requests = [];
  bool _isLoadingRequests = false;
  bool _hasMoreRequests = true;
  ApiError? _requestsError;
  BookRequestStatus? _selectedStatus;
  int _currentRequestsOffset = 0;
  bool _hasLoadedInitialRequestsData = false;

  // Bookmarks state
  List<InternalBookItem> _bookmarks = [];
  bool _isLoadingBookmarks = false;
  bool _hasMoreBookmarks = true;
  ApiError? _bookmarksError;
  int _currentBookmarksOffset = 0;
  bool _hasLoadedInitialBookmarksData = false;

  // Saved insights state
  List<SavedInsightWithBook> _savedInsights = [];
  bool _isLoadingSavedInsights = false;
  bool _hasMoreSavedInsights = true;
  ApiError? _savedInsightsError;
  int _currentSavedInsightsOffset = 0;
  bool _hasLoadedInitialSavedInsightsData = false;

  // Flag to prevent repeated loading in Consumer
  bool _hasTriggeredAuthLoad = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onRequestsScroll);
    _bookmarksScrollController.addListener(_onBookmarksScroll);
    _savedInsightsScrollController.addListener(_onSavedInsightsScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Only load data if user is authenticated
      final authProvider = context.read<AuthProvider>();
      if (authProvider.isAuthenticated) {
        _loadCurrentTabData();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _bookmarksScrollController.dispose();
    _savedInsightsScrollController.dispose();
    super.dispose();
  }

  void _onRequestsScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - ApiConstants.scrollLoadThreshold) {
      _loadMoreRequests();
    }
  }

  void _onBookmarksScroll() {
    if (_bookmarksScrollController.position.pixels >=
        _bookmarksScrollController.position.maxScrollExtent - ApiConstants.scrollLoadThreshold) {
      _loadMoreBookmarks();
    }
  }

  void _onSavedInsightsScroll() {
    if (_savedInsightsScrollController.position.pixels >=
        _savedInsightsScrollController.position.maxScrollExtent - ApiConstants.scrollLoadThreshold) {
      _loadMoreSavedInsights();
    }
  }

  void _loadCurrentTabData() {
    switch (_selectedTab) {
      case LibraryTab.bookmarks:
        if (!_hasLoadedInitialBookmarksData) {
          _loadBookmarks();
        }
        break;
      case LibraryTab.requests:
        if (!_hasLoadedInitialRequestsData) {
          _loadRequests();
        }
        break;
      case LibraryTab.insights:
        if (!_hasLoadedInitialSavedInsightsData) {
          _loadSavedInsights();
        }
        break;
    }
  }

  Future<void> _loadRequests({bool refresh = false}) async {
    if (_isLoadingRequests) return;

    setState(() {
      _isLoadingRequests = true;
      _requestsError = null;
      if (refresh) {
        _requests.clear();
        _currentRequestsOffset = 0;
        _hasMoreRequests = true;
      }
    });

    final result = await _requestService.getUserBookRequests(
      limit: ApiConstants.defaultPageSize,
      offset: refresh ? 0 : _currentRequestsOffset,
      status: _selectedStatus,
    );

    result.fold(
      (response) {
        setState(() {
          if (refresh) {
            _requests = response.requests;
          } else {
            _requests.addAll(response.requests);
          }
          _currentRequestsOffset += response.requests.length;
          _hasMoreRequests = response.requests.length == ApiConstants.defaultPageSize;
          _isLoadingRequests = false;
          _requestsError = null;
          _hasLoadedInitialRequestsData = true;
        });
      },
      (error) {
        setState(() {
          _requestsError = error;
          _isLoadingRequests = false;
        });
      },
    );
  }

  Future<void> _loadMoreRequests() async {
    if (!_hasMoreRequests || _isLoadingRequests) return;
    await _loadRequests();
  }

  Future<void> _refreshRequests() async {
    await _loadRequests(refresh: true);
  }

  Future<void> _loadBookmarks({bool refresh = false}) async {
    if (_isLoadingBookmarks) return;

    setState(() {
      _isLoadingBookmarks = true;
      _bookmarksError = null;
      if (refresh) {
        _bookmarks.clear();
        _currentBookmarksOffset = 0;
        _hasMoreBookmarks = true;
      }
    });

    final result = await _bookApiService.getUserBookmarks(
      limit: ApiConstants.defaultPageSize,
      offset: refresh ? 0 : _currentBookmarksOffset,
    );

    result.fold(
      (response) {
        setState(() {
          if (refresh) {
            _bookmarks = response.books;
          } else {
            _bookmarks.addAll(response.books);
          }
          _currentBookmarksOffset += response.books.length;
          _hasMoreBookmarks = response.books.length == response.limit;
          _isLoadingBookmarks = false;
          _bookmarksError = null;
          _hasLoadedInitialBookmarksData = true;
        });
      },
      (error) {
        setState(() {
          _bookmarksError = error;
          _isLoadingBookmarks = false;
        });
      },
    );
  }

  Future<void> _loadMoreBookmarks() async {
    if (!_hasMoreBookmarks || _isLoadingBookmarks) return;
    await _loadBookmarks();
  }

  Future<void> _refreshBookmarks() async {
    await _loadBookmarks(refresh: true);
  }

  Future<void> _loadSavedInsights({bool refresh = false}) async {
    if (_isLoadingSavedInsights) return;

    setState(() {
      _isLoadingSavedInsights = true;
      _savedInsightsError = null;
      if (refresh) {
        _savedInsights.clear();
        _currentSavedInsightsOffset = 0;
        _hasMoreSavedInsights = true;
      }
    });

    final result = await _bookApiService.getUserSavedInsights(
      limit: ApiConstants.defaultPageSize,
      offset: refresh ? 0 : _currentSavedInsightsOffset,
    );

    result.fold(
      (response) {
        setState(() {
          if (refresh) {
            _savedInsights = response.insights;
          } else {
            _savedInsights.addAll(response.insights);
          }
          _currentSavedInsightsOffset += response.insights.length;
          _hasMoreSavedInsights = response.insights.length == response.limit;
          _isLoadingSavedInsights = false;
          _savedInsightsError = null;
          _hasLoadedInitialSavedInsightsData = true;
        });
      },
      (error) {
        setState(() {
          _savedInsightsError = error;
          _isLoadingSavedInsights = false;
        });
      },
    );
  }

  Future<void> _loadMoreSavedInsights() async {
    if (!_hasMoreSavedInsights || _isLoadingSavedInsights) return;
    await _loadSavedInsights();
  }

  Future<void> _refreshSavedInsights() async {
    await _loadSavedInsights(refresh: true);
  }

  void _onTabChanged(LibraryTab tab) {
    setState(() {
      _selectedTab = tab;
    });
    _loadCurrentTabData();
  }

  Future<void> _refreshCurrentTab() async {
    switch (_selectedTab) {
      case LibraryTab.bookmarks:
        await _refreshBookmarks();
        break;
      case LibraryTab.requests:
        await _refreshRequests();
        break;
      case LibraryTab.insights:
        await _refreshSavedInsights();
        break;
    }
  }

  void _onStatusFilterChanged(BookRequestStatus? status) {
    setState(() {
      _selectedStatus = status;
    });
    _loadRequests(refresh: true);
  }

  void _navigateToBookDetail(UserBookRequest request) {
    if (!request.isCompleted) return;
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BookDetailsScreen(book: request.book),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        final l10n = languageProvider.l10n;

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n['library'] ?? AppStrings.libraryTitle),
            elevation: 0,
        actions: [
          if (_selectedTab == LibraryTab.requests)
            PopupMenuButton<BookRequestStatus?>(
              icon: const Icon(Icons.filter_list),
              tooltip: l10n['filter_by_status'] ?? AppStrings.filterByStatus,
              onSelected: _onStatusFilterChanged,
              itemBuilder: (context) => [
                PopupMenuItem<BookRequestStatus?>(
                  value: null,
                  child: Text(l10n['all_requests'] ?? AppStrings.allRequests),
                ),
                PopupMenuItem<BookRequestStatus?>(
                  value: BookRequestStatus.pending,
                  child: Text(l10n['pending'] ?? AppStrings.pending),
                ),
                PopupMenuItem<BookRequestStatus?>(
                  value: BookRequestStatus.processing,
                  child: Text(l10n['processing'] ?? AppStrings.processing),
                ),
                PopupMenuItem<BookRequestStatus?>(
                  value: BookRequestStatus.completed,
                  child: Text(l10n['completed'] ?? AppStrings.completed),
                ),
                PopupMenuItem<BookRequestStatus?>(
                  value: BookRequestStatus.failed,
                  child: Text(l10n['failed'] ?? AppStrings.failed),
                ),
              ],
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Consumer<LanguageProvider>(
              builder: (context, langProvider, child) {
                return SegmentedButton<LibraryTab>(
                  segments: [
                    ButtonSegment<LibraryTab>(
                      value: LibraryTab.bookmarks,
                      label: Text(langProvider.l10n['bookmarks_tab'] ?? AppStrings.bookmarksTab),
                      icon: const Icon(Icons.bookmark_outline),
                    ),
                    ButtonSegment<LibraryTab>(
                      value: LibraryTab.requests,
                      label: Text(langProvider.l10n['requests_tab'] ?? AppStrings.requestsTab),
                      icon: const Icon(Icons.history),
                    ),
                    ButtonSegment<LibraryTab>(
                      value: LibraryTab.insights,
                      label: Text(langProvider.l10n['insights_tab'] ?? AppStrings.insightsTab),
                      icon: const Icon(Icons.insights_outlined),
                    ),
                  ],
                  selected: {_selectedTab},
                  onSelectionChanged: (Set<LibraryTab> newSelection) {
                    _onTabChanged(newSelection.first);
                  },
                  style: SegmentedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.onSurface,
                    selectedForegroundColor: Colors.white,
                    selectedBackgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                );
              },
            ),
          ),
        ),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (!authProvider.isAuthenticated) {
            // Reset the data loading flags when not authenticated
            _hasLoadedInitialRequestsData = false;
            _hasLoadedInitialBookmarksData = false;
            _hasLoadedInitialSavedInsightsData = false;
            _hasTriggeredAuthLoad = false;
            return Consumer<LanguageProvider>(
              builder: (context, languageProvider, child) {
                return _buildNotAuthenticatedState(languageProvider.l10n);
              },
            );
          }

          // Load data when user becomes authenticated for the first time
          if (authProvider.isAuthenticated && !_hasTriggeredAuthLoad) {
            _hasTriggeredAuthLoad = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _loadCurrentTabData();
            });
          }

          return _buildTabContent();
        },
      ),
        );
      },
    );
  }

  Widget _buildNotAuthenticatedState(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: UIConstants.screenPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.library_books_outlined,
              size: UIConstants.emptyStateIconSize,
              color: AppColors.lightGrey,
            ),
            const SizedBox(height: UIConstants.xLargeSpacing),
            Text(
              l10n['sign_in_to_view_library'] ?? AppStrings.signInToViewLibrary,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.darkGrey,
              ),
            ),
            const SizedBox(height: UIConstants.largeSpacing),
            Text(
              l10n['library_description'] ?? AppStrings.libraryDescription,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.mediumGrey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: UIConstants.xLargeSpacing),
            // Login button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case LibraryTab.bookmarks:
        return _buildBookmarksContent();
      case LibraryTab.requests:
        return _buildRequestsContent();
      case LibraryTab.insights:
        return _buildInsightsContent();
    }
  }

  Widget _buildBookmarksContent() {
    if (_bookmarksError != null && _bookmarks.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refreshBookmarks,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height - 200,
            child: _buildBookmarksErrorState(),
          ),
        ),
      );
    }

    if (_isLoadingBookmarks && _bookmarks.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refreshBookmarks,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height - 200,
            child: _buildLoadingState(),
          ),
        ),
      );
    }

    if (_bookmarks.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refreshBookmarks,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height - 200,
            child: _buildBookmarksEmptyState(),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshBookmarks,
      child: GridView.builder(
        controller: _bookmarksScrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(UIConstants.mediumSpacing),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.6,
          crossAxisSpacing: UIConstants.mediumSpacing,
          mainAxisSpacing: UIConstants.mediumSpacing,
        ),
        itemCount: _bookmarks.length + (_isLoadingBookmarks && _hasMoreBookmarks ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _bookmarks.length) {
            return _buildLoadingIndicator();
          }

          final book = _bookmarks[index];
          return HorizontalBookCard(book: book);
        },
      ),
    );
  }

  Widget _buildRequestsContent() {
    if (_requestsError != null && _requests.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refreshRequests,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height - 200,
            child: _buildRequestsErrorState(),
          ),
        ),
      );
    }

    if (_isLoadingRequests && _requests.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refreshRequests,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height - 200,
            child: _buildLoadingState(),
          ),
        ),
      );
    }

    if (_requests.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refreshRequests,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height - 200,
            child: _buildRequestsEmptyState(),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshRequests,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: UIConstants.mediumSpacing),
        itemCount: _requests.length + (_isLoadingRequests && _hasMoreRequests ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _requests.length) {
            return _buildLoadingIndicator();
          }

          final request = _requests[index];
          return BookRequestCard(
            request: request,
            onTap: () => _navigateToBookDetail(request),
          );
        },
      ),
    );
  }

  Widget _buildInsightsContent() {
    if (_savedInsightsError != null && _savedInsights.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refreshSavedInsights,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height - 200,
            child: _buildSavedInsightsErrorState(),
          ),
        ),
      );
    }

    if (_isLoadingSavedInsights && _savedInsights.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refreshSavedInsights,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height - 200,
            child: _buildLoadingState(),
          ),
        ),
      );
    }

    if (_savedInsights.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refreshSavedInsights,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height - 200,
            child: _buildSavedInsightsEmptyState(),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshSavedInsights,
      child: ListView.builder(
        controller: _savedInsightsScrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          vertical: UIConstants.mediumSpacing,
          horizontal: UIConstants.mediumSpacing,
        ),
        itemCount: _savedInsights.length + (_isLoadingSavedInsights && _hasMoreSavedInsights ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _savedInsights.length) {
            return _buildLoadingIndicator();
          }

          final insight = _savedInsights[index];
          return SavedInsightCard(
            insight: insight,
            onRemoved: () => _onInsightRemoved(insight),
          );
        },
      ),
    );
  }

  void _onInsightRemoved(SavedInsightWithBook insight) {
    setState(() {
      _savedInsights.removeWhere((item) => item.id == insight.id);
    });
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildRequestsErrorState() {
    return Center(
      child: Padding(
        padding: UIConstants.screenPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: UIConstants.emptyStateIconSize,
              color: AppColors.failedColor.withValues(alpha: UIConstants.mediumOpacity),
            ),
            const SizedBox(height: UIConstants.xLargeSpacing),
            Text(
              AppStrings.errorLoadingLibrary,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.failedColor,
              ),
            ),
            const SizedBox(height: UIConstants.largeSpacing),
            Text(
              _requestsError?.userFriendlyMessage ?? AppStrings.unknownError,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.mediumGrey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: UIConstants.xLargeSpacing),
            ElevatedButton(
              onPressed: () => _loadRequests(refresh: true),
              child: const Text(AppStrings.retryButton),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookmarksErrorState() {
    return Center(
      child: Padding(
        padding: UIConstants.screenPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: UIConstants.emptyStateIconSize,
              color: AppColors.failedColor.withValues(alpha: UIConstants.mediumOpacity),
            ),
            const SizedBox(height: UIConstants.xLargeSpacing),
            Text(
              AppStrings.errorLoadingBookmarks,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.failedColor,
              ),
            ),
            const SizedBox(height: UIConstants.largeSpacing),
            Text(
              _bookmarksError?.userFriendlyMessage ?? AppStrings.unknownError,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.mediumGrey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: UIConstants.xLargeSpacing),
            ElevatedButton(
              onPressed: () => _loadBookmarks(refresh: true),
              child: const Text(AppStrings.retryButton),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestsEmptyState() {
    return Center(
      child: Padding(
        padding: UIConstants.screenPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.library_books_outlined,
              size: UIConstants.emptyStateIconSize,
              color: AppColors.lightGrey,
            ),
            const SizedBox(height: UIConstants.xLargeSpacing),
            Consumer<LanguageProvider>(
              builder: (context, langProvider, child) => Text(
                _selectedStatus != null
                  ? '${langProvider.l10n['no_requests_with_status'] ?? 'No'} ${_selectedStatus!.displayName} ${langProvider.l10n['requests'] ?? 'requests'}'
                  : langProvider.l10n['no_requests_yet'] ?? 'No requests yet',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.darkGrey,
                ),
              ),
            ),
            const SizedBox(height: UIConstants.largeSpacing),
            Consumer<LanguageProvider>(
              builder: (context, langProvider, child) => Text(
                _selectedStatus != null
                  ? '${langProvider.l10n['no_status_requests_description'] ?? 'You don\'t have any'} ${_selectedStatus!.displayName.toLowerCase()} ${langProvider.l10n['book_requests_yet'] ?? 'book requests yet.'}'
                  : langProvider.l10n['requests_empty_description'] ?? 'Your book summary requests will appear here.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.mediumGrey,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookmarksEmptyState() {
    return Center(
      child: Padding(
        padding: UIConstants.screenPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_outline,
              size: UIConstants.emptyStateIconSize,
              color: AppColors.lightGrey,
            ),
            const SizedBox(height: UIConstants.xLargeSpacing),
            Consumer<LanguageProvider>(
              builder: (context, langProvider, child) => Text(
                langProvider.l10n['no_bookmarks_yet'] ?? 'No bookmarks yet',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.darkGrey,
                ),
              ),
            ),
            const SizedBox(height: UIConstants.largeSpacing),
            Consumer<LanguageProvider>(
              builder: (context, langProvider, child) => Text(
                langProvider.l10n['bookmarks_empty_description'] ?? 'Books you bookmark will appear here for easy access.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.mediumGrey,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedInsightsErrorState() {
    return Center(
      child: Padding(
        padding: UIConstants.screenPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: UIConstants.emptyStateIconSize,
              color: AppColors.failedColor.withValues(alpha: UIConstants.mediumOpacity),
            ),
            const SizedBox(height: UIConstants.xLargeSpacing),
            Text(
              'Error loading saved insights',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.failedColor,
              ),
            ),
            const SizedBox(height: UIConstants.largeSpacing),
            Text(
              _savedInsightsError?.userFriendlyMessage ?? AppStrings.unknownError,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.mediumGrey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: UIConstants.xLargeSpacing),
            ElevatedButton(
              onPressed: () => _loadSavedInsights(refresh: true),
              child: const Text(AppStrings.retryButton),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedInsightsEmptyState() {
    return Center(
      child: Padding(
        padding: UIConstants.screenPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lightbulb_outline,
              size: UIConstants.emptyStateIconSize,
              color: AppColors.lightGrey,
            ),
            const SizedBox(height: UIConstants.xLargeSpacing),
            Consumer<LanguageProvider>(
              builder: (context, langProvider, child) => Text(
                langProvider.l10n['no_saved_insights_yet'] ?? 'No saved insights yet',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.darkGrey,
                ),
              ),
            ),
            const SizedBox(height: UIConstants.largeSpacing),
            Consumer<LanguageProvider>(
              builder: (context, langProvider, child) => Text(
                langProvider.l10n['insights_empty_description'] ?? 'Insights you save will appear here for easy access.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.mediumGrey,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.all(UIConstants.largeSpacing),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}