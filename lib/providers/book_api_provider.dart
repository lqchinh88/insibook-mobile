import 'package:flutter/foundation.dart';
import '../services/book_api_service.dart';

class BookApiProvider extends ChangeNotifier {
  final BookApiService _bookApiService;

  BookApiProvider({BookApiService? bookApiService}) 
      : _bookApiService = bookApiService ?? BookApiService();

  BookApiService get bookApiService => _bookApiService;
}