import 'package:dio/dio.dart';

import '../../app/constants.dart';
import '../errors/app_exception.dart';
import '../errors/error_handler.dart';
import '../storage/secure_storage_service.dart';

class ApiClient {
  final SecureStorageService _storage;
  late final Dio _dio;

  ApiClient(this._storage, {required void Function() onUnauthorized}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: AppConstants.apiConnectTimeout,
        receiveTimeout: AppConstants.apiReceiveTimeout,
        contentType: 'application/json',
        responseType: ResponseType.json,
      ),
    );
    _dio.interceptors.add(_AuthInterceptor(_storage, onUnauthorized));
  }

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? query,
    required T Function(dynamic) parse,
  }) =>
      _request('GET', path, query: query, parse: parse);

  Future<T> post<T>(
    String path, {
    dynamic data,
    required T Function(dynamic) parse,
  }) =>
      _request('POST', path, data: data, parse: parse);

  Future<T> put<T>(
    String path, {
    dynamic data,
    required T Function(dynamic) parse,
  }) =>
      _request('PUT', path, data: data, parse: parse);

  Future<T> patch<T>(
    String path, {
    dynamic data,
    required T Function(dynamic) parse,
  }) =>
      _request('PATCH', path, data: data, parse: parse);

  Future<T> delete<T>(
    String path, {
    required T Function(dynamic) parse,
  }) =>
      _request('DELETE', path, parse: parse);

  Future<T> _request<T>(
    String method,
    String path, {
    Map<String, dynamic>? query,
    dynamic data,
    required T Function(dynamic) parse,
  }) async {
    try {
      final response = await _dio.request<dynamic>(
        path,
        queryParameters: query,
        data: data,
        options: Options(method: method),
      );
      return parse(response.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(message: 'Beklenmeyen bir hata oluştu: $e');
    }
  }
}

class _AuthInterceptor extends Interceptor {
  final SecureStorageService _storage;
  final void Function() _onUnauthorized;

  _AuthInterceptor(this._storage, this._onUnauthorized);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // TODO(auth-refresh): introduce /auth/refresh endpoint + retry-once
      // with a refresh token before forcing logout. Today the access token
      // is short-lived and every expiry forces the user through full
      // OTP+login. Add a refresh token to the login response, store it in
      // secure storage, and call it from here before invoking _onUnauthorized.
      _storage.clearAll();
      _onUnauthorized();
    }
    handler.next(err);
  }
}
