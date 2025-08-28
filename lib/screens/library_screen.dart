import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_book_request_models.dart';
import '../services/user_book_request_service.dart';
import '../providers/auth_provider.dart';
import '../widgets/book_request_card.dart';
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

class _LibraryScreenState extends State<LibraryScreen> {
  final UserBookRequestService _requestService = UserBookRequestService();
  final ScrollController _scrollController = ScrollController();
  
  List<UserBookRequest> _requests = [];
  bool _isLoading = false;
  bool _hasMore = true;
  ApiError? _error;
  BookRequestStatus? _selectedStatus;
  int _currentOffset = 0;
  bool _hasLoadedInitialData = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Only load requests if user is authenticated
      final authProvider = context.read<AuthProvider>();
      if (authProvider.isAuthenticated) {
        _loadRequests();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - ApiConstants.scrollLoadThreshold) {
      _loadMoreRequests();
    }
  }

  Future<void> _loadRequests({bool refresh = false}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
      if (refresh) {
        _requests.clear();
        _currentOffset = 0;
        _hasMore = true;
      }
    });

    final result = await _requestService.getUserBookRequests(
      limit: ApiConstants.defaultPageSize,
      offset: refresh ? 0 : _currentOffset,
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
          _currentOffset += response.requests.length;
          _hasMore = response.requests.length == ApiConstants.defaultPageSize;
          _isLoading = false;
          _error = null;
        });
      },
      (error) {
        setState(() {
          _error = error;
          _isLoading = false;
        });
      },
    );
  }

  Future<void> _loadMoreRequests() async {
    if (!_hasMore || _isLoading) return;
    await _loadRequests();
  }

  Future<void> _refreshRequests() async {
    await _loadRequests(refresh: true);
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.libraryTitle),
        elevation: 0,
        actions: [
          PopupMenuButton<BookRequestStatus?>(
            icon: const Icon(Icons.filter_list),
            tooltip: AppStrings.filterByStatus,
            onSelected: _onStatusFilterChanged,
            itemBuilder: (context) => [
              const PopupMenuItem<BookRequestStatus?>(
                value: null,
                child: Text(AppStrings.allRequests),
              ),
              const PopupMenuItem<BookRequestStatus?>(
                value: BookRequestStatus.pending,
                child: Text(AppStrings.pending),
              ),
              const PopupMenuItem<BookRequestStatus?>(
                value: BookRequestStatus.processing,
                child: Text(AppStrings.processing),
              ),
              const PopupMenuItem<BookRequestStatus?>(
                value: BookRequestStatus.completed,
                child: Text(AppStrings.completed),
              ),
              const PopupMenuItem<BookRequestStatus?>(
                value: BookRequestStatus.failed,
                child: Text(AppStrings.failed),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (!authProvider.isAuthenticated) {
            // Reset the data loading flag when not authenticated
            _hasLoadedInitialData = false;
            return _buildNotAuthenticatedState();
          }

          // Load data when user becomes authenticated for the first time
          if (authProvider.isAuthenticated && !_hasLoadedInitialData) {
            _hasLoadedInitialData = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _loadRequests(refresh: true);
            });
          }

          return _buildLibraryContent();
        },
      ),
    );
  }

  Widget _buildNotAuthenticatedState() {
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
              AppStrings.signInToViewLibrary,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.darkGrey,
              ),
            ),
            const SizedBox(height: UIConstants.largeSpacing),
            Text(
              AppStrings.libraryDescription,
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

  Widget _buildLibraryContent() {
    if (_error != null && _requests.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refreshRequests,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height - 200,
            child: _buildErrorState(),
          ),
        ),
      );
    }

    if (_isLoading && _requests.isEmpty) {
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
            child: _buildEmptyState(),
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
        itemCount: _requests.length + (_isLoading && _hasMore ? 1 : 0),
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

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorState() {
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
              _error?.userFriendlyMessage ?? AppStrings.unknownError,
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

  Widget _buildEmptyState() {
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
              _selectedStatus != null 
                ? 'No ${_selectedStatus!.displayName} requests'
                : AppStrings.libraryEmpty,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.darkGrey,
              ),
            ),
            const SizedBox(height: UIConstants.largeSpacing),
            Text(
              _selectedStatus != null
                ? 'You don\'t have any ${_selectedStatus!.displayName.toLowerCase()} book requests yet.'
                : AppStrings.libraryEmptyDescription,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.mediumGrey,
              ),
              textAlign: TextAlign.center,
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