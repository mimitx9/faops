import '../entities/chat_entity.dart';
import '../repositories/chat_repository.dart';
import '../../core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetMessagesUseCase {
  final ChatRepository _repository;

  GetMessagesUseCase(this._repository);

  Future<Either<Failure, List<ChatMessageEntity>>> call(String conversationId) {
    return _repository.getMessages(conversationId);
  }
}



