import 'package:dio/dio.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/api_exception.dart';
import 'chat_models.dart';

class ChatRepository {
  ChatRepository(this._dio);
  final Dio _dio;

  Future<List<ChatColleague>> colleagues({String? query}) async {
    try {
      final r = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.chatColleagues,
        queryParameters: {
          'page': 1,
          'pageSize': 100,
          if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
        },
      );
      final data = r.data?['data'] as Map<String, dynamic>? ?? const {};
      final list = data['items'] as List<dynamic>? ?? const [];
      return list.map((e) => ChatColleague.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<ChatListData> conversations() async {
    try {
      final r = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.chatConversations,
        queryParameters: {'page': 1, 'pageSize': 50},
      );
      final data = r.data?['data'] as Map<String, dynamic>? ?? const {};
      final list = data['items'] as List<dynamic>? ?? const [];
      return ChatListData(
        items: list.map((e) => ChatConversation.fromJson(e as Map<String, dynamic>)).toList(),
        unreadTotal: (data['unreadTotal'] as num?)?.toInt() ?? 0,
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<ChatConversation> openDirect(String userId) async {
    try {
      final r = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.chatConversations,
        data: {'userId': userId},
      );
      return ChatConversation.fromJson(r.data!['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<ChatConversation> getConversation(String id) async {
    try {
      final r = await _dio.get<Map<String, dynamic>>('${ApiEndpoints.chatConversations}/$id');
      return ChatConversation.fromJson(r.data!['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<List<ChatMessage>> messages(String conversationId) async {
    try {
      final r = await _dio.get<Map<String, dynamic>>(
        '${ApiEndpoints.chatConversations}/$conversationId/messages',
        queryParameters: {'page': 1, 'pageSize': 100},
      );
      final data = r.data?['data'] as Map<String, dynamic>? ?? const {};
      final list = data['items'] as List<dynamic>? ?? const [];
      return list.map((e) => ChatMessage.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<ChatMessage> send(String conversationId, String body) async {
    try {
      final r = await _dio.post<Map<String, dynamic>>(
        '${ApiEndpoints.chatConversations}/$conversationId/messages',
        data: {'body': body},
      );
      return ChatMessage.fromJson(r.data!['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> markRead(String conversationId) async {
    try {
      await _dio.post<Map<String, dynamic>>('${ApiEndpoints.chatConversations}/$conversationId/read', data: {});
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
