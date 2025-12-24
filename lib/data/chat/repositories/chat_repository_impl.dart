import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:dio/dio.dart';
import '../../../domain/chat/entities/chat_entity.dart';
import '../../../domain/chat/repositories/chat_repository.dart';
import '../../../core/error/failures.dart';
import '../datasources/chat_remote_datasource.dart';
import '../models/chat_model.dart';

@LazySingleton(as: ChatRepository)
class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource _remoteDataSource;

  ChatRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<ChatConversationEntity>>> getConversations() async {
    try {
      final models = await _remoteDataSource.getConversations();
      return Right(models.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, List<ChatMessageEntity>>> getMessages(
    String conversationId,
  ) async {
    try {
      final models = await _remoteDataSource.getMessages(conversationId);
      return Right(models.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, ChatMessageEntity>> sendMessage(
    SendMessageRequest request,
  ) async {
    try {
      final typeString = request.type.name;
      final model = await _remoteDataSource.sendMessage(
        request.conversationId,
        request.content,
        typeString,
      );
      return Right(model.toEntity());
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(String conversationId) async {
    try {
      await _remoteDataSource.markAsRead(conversationId);
      return const Right(null);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMessage(String messageId) async {
    try {
      await _remoteDataSource.deleteMessage(messageId);
      return const Right(null);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteConversation(
    String conversationId,
  ) async {
    try {
      await _remoteDataSource.deleteConversation(conversationId);
      return const Right(null);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  Failure _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.response?.statusCode) {
        case 401:
          return const Failure.unauthorized(message: 'Unauthorized');
        case 403:
          return const Failure.forbidden(message: 'Forbidden');
        case 404:
          return const Failure.notFound(message: 'Not Found');
        case 408:
          return const Failure.timeout(message: 'Request Timeout');
        default:
          return Failure.server(
            message: error.response?.data['message'] ?? 'Server Error',
            statusCode: error.response?.statusCode,
          );
      }
    }
    return Failure.network(message: error.toString());
  }
}

