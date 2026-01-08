import '../entities/chat_entity.dart';
import '../repositories/chat_repository.dart';
import '../../core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetConversationsUseCase {
  final ChatRepository _repository;

  GetConversationsUseCase(this._repository);

  Future<Either<Failure, List<ChatConversationEntity>>> call() {
    return _repository.getConversations();
  }
}





