import '../entities/chat_entity.dart';
import '../../core/error/failures.dart';
import 'package:dartz/dartz.dart';

abstract class ChatRepository {
  Future<Either<Failure, List<ChatConversationEntity>>> getConversations();
  Future<Either<Failure, List<ChatMessageEntity>>> getMessages(String conversationId);
  Future<Either<Failure, ChatMessageEntity>> sendMessage(SendMessageRequest request);
  Future<Either<Failure, void>> markAsRead(String conversationId);
  Future<Either<Failure, void>> deleteMessage(String messageId);
  Future<Either<Failure, void>> deleteConversation(String conversationId);
}





