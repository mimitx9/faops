import '../entities/chat_entity.dart';
import '../repositories/chat_repository.dart';
import '../../core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@injectable
class SendMessageUseCase {
  final ChatRepository _repository;

  SendMessageUseCase(this._repository);

  Future<Either<Failure, ChatMessageEntity>> call(SendMessageRequest request) {
    return _repository.sendMessage(request);
  }
}





