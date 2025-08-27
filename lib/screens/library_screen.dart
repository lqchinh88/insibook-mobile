import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_book_request_models.dart';
import '../services/user_book_request_service.dart';
import '../providers/auth_provider.dart';
import '../widgets/book_request_card.dart';
import 'book_details_screen.dart';

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
  String? _error;
  BookRequestStatus? _selectedStatus;
  int _currentOffset = 0;
  static const int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRequests();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
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

    try {
      final response = await _requestService.getUserBookRequests(
        limit: _pageSize,
        offset: refresh ? 0 : _currentOffset,
        status: _selectedStatus,
      );

      if (response != null) {
        setState(() {
          if (refresh) {
            _requests = response.requests;
          } else {
            _requests.addAll(response.requests);
          }
          _currentOffset += response.requests.length;
          _hasMore = response.requests.length == _pageSize;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load book requests';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load book requests: ${e.toString()}';
        _isLoading = false;
      });
    }
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
        title: const Text('Library'),
        elevation: 0,
        actions: [
          PopupMenuButton<BookRequestStatus?>(
            icon: Icon(Icons.filter_list),
            tooltip: 'Filter by status',
            onSelected: _onStatusFilterChanged,
            itemBuilder: (context) => [
              PopupMenuItem<BookRequestStatus?>(
                value: null,
                child: Text('All Requests'),
              ),
              PopupMenuItem<BookRequestStatus?>(
                value: BookRequestStatus.pending,
                child: Text('Pending'),
              ),
              PopupMenuItem<BookRequestStatus?>(
                value: BookRequestStatus.processing,
                child: Text('Processing'),
              ),
              PopupMenuItem<BookRequestStatus?>(
                value: BookRequestStatus.completed,
                child: Text('Completed'),
              ),
              PopupMenuItem<BookRequestStatus?>(
                value: BookRequestStatus.failed,
                child: Text('Failed'),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (!authProvider.isAuthenticated) {
            return _buildNotAuthenticatedState();
          }

          return _buildLibraryContent();
        },
      ),
    );
  }

  Widget _buildNotAuthenticatedState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.library_books_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'Sign in to view your library',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Your book requests and progress will appear here once you\'re signed in.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLibraryContent() {
    if (_error != null && _requests.isEmpty) {
      return _buildErrorState();
    }

    if (_isLoading && _requests.isEmpty) {
      return _buildLoadingState();
    }

    if (_requests.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _refreshRequests,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        itemCount: _requests.length + (_hasMore ? 1 : 0),
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
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red[300],
            ),
            const SizedBox(height: 24),
            Text(
              'Error loading library',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _error ?? 'Unknown error occurred',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _loadRequests(refresh: true),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.library_books_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              _selectedStatus != null 
                ? 'No ${_selectedStatus!.name} requests'
                : 'Your library is empty',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _selectedStatus != null
                ? 'You don\'t have any ${_selectedStatus!.name} book requests yet.'
                : 'You haven\'t requested any book summaries yet. Start exploring books and request summaries to see them here.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      alignment: Alignment.center,
      child: const CircularProgressIndicator(),
    );
  }
}