import '../models/homepage_models.dart';
import '../utils/result.dart';
import 'api_service.dart';

class HomepageService {
  /// Get homepage structure with dynamic sections
  Future<ApiResult<HomepageResponse>> getHomepage() {
    return ApiService.getWithResult(
      '/homepage',
      parser: HomepageResponse.fromJson,
    );
  }
}