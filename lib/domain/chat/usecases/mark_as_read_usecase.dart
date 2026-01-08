import '../repositories/chat_repository.dart';
import '../../core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@injectable
class MarkAsReadUseCase {
  final ChatRepository _repository;

  MarkAsReadUseCase(this._repository);

  Future<Either<Failure, void>> call(String conversationId) {
    return _repository.markAsRead(conversationId);
  }
}





