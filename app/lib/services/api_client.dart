import 'package:http/http.dart' as http;
import 'api_config.dart';

class ApiClient {
  final http.Client _client;
  String? _authToken;

  ApiClient([http.Client? client, String? token])
    : _client = client ?? http.Client(),
      _authToken = token;

  void setAuthToken(String? token) => _authToken = token;

  Map<String, String> _buildHeaders(Map<String, String>? headers) {
    final result = <String, String>{'Accept': 'application/json'};
    if (_authToken != null && _authToken!.isNotEmpty) {
      result['Authorization'] = 'Bearer $_authToken';
    }
    if (headers != null) result.addAll(headers);
    return result;
  }

  Future<http.Response> get(String path, {Map<String, String>? headers}) async {
    final uri = Uri.parse(ApiConfig.baseUrl).resolve(path);
    return _client.get(uri, headers: _buildHeaders(headers));
  }

  Future<http.Response> post(
    String path, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final uri = Uri.parse(ApiConfig.baseUrl).resolve(path);
    return _client.post(uri, headers: _buildHeaders(headers), body: body);
  }

  void close() => _client.close();
}
