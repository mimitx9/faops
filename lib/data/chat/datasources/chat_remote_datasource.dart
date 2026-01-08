import 'package:injectable/injectable.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../models/chat_model.dart';

abstract class ChatRemoteDataSource {
  Future<List<ChatConversationModel>> getConversations();
  Future<List<ChatMessageModel>> getMessages(String conversationId);
  Future<ChatMessageModel> sendMessage(
    String conversationId,
    String content,
    String type,
  );
  Future<void> markAsRead(String conversationId);
  Future<void> deleteMessage(String messageId);
  Future<void> deleteConversation(String conversationId);
}

@LazySingleton(as: ChatRemoteDataSource)
class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final DioClient _dioClient;

  ChatRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<ChatConversationModel>> getConversations() async {
    final response = await _dioClient.get(ApiEndpoints.chatConversations);
    final List<dynamic> data = response.data;
    return data.map((json) => ChatConversationModel.fromJson(json)).toList();
  }

  @override
  Future<List<ChatMessageModel>> getMessages(String conversationId) async {
    final response = await _dioClient.get(
      '${ApiEndpoints.chatMessages}/$conversationId',
    );
    final List<dynamic> data = response.data;
    return data.map((json) => ChatMessageModel.fromJson(json)).toList();
  }

  @override
  Future<ChatMessageModel> sendMessage(
    String conversationId,
    String content,
    String type,
  ) async {
    final response = await _dioClient.post(
      ApiEndpoints.chatSend,
      data: {
        'conversation_id': conversationId,
        'content': content,
        'type': type,
      },
    );
    return ChatMessageModel.fromJson(response.data);
  }

  @override
  Future<void> markAsRead(String conversationId) async {
    await _dioClient.post(
      ApiEndpoints.chatMarkRead,
      data: {'conversation_id': conversationId},
    );
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    await _dioClient.delete('${ApiEndpoints.chatDelete}/$messageId');
  }

  @override
  Future<void> deleteConversation(String conversationId) async {
    await _dioClient.delete('${ApiEndpoints.chatDelete}/$conversationId');
  }
}





