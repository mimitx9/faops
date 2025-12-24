import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../domain/chat/entities/chat_entity.dart';
import '../../../domain/chat/usecases/get_conversations_usecase.dart';
import '../../../domain/chat/usecases/get_messages_usecase.dart';
import '../../../domain/chat/usecases/send_message_usecase.dart';
import '../../../domain/chat/usecases/mark_as_read_usecase.dart';
import '../../../core/error/failures.dart';
import 'providers_setup.dart';

part 'chat_provider.g.dart';

@riverpod
class ChatConversationsNotifier extends _$ChatConversationsNotifier {
  GetConversationsUseCase? _getConversationsUseCase;

  @override
  Future<List<ChatConversationEntity>> build() async {
    _getConversationsUseCase = ref.read(getConversationsUseCaseProvider);
    await loadConversations();
    return [];
  }

  Future<void> loadConversations() async {
    state = const AsyncValue.loading();
    final result = await _getConversationsUseCase!();
    result.fold(
      (failure) {
        state = AsyncValue.error(
          Failure.unknown(message: failure.toString()),
          StackTrace.current,
        );
      },
      (conversations) {
        state = AsyncValue.data(conversations);
      },
    );
  }
}

@riverpod
class ChatMessagesNotifier extends _$ChatMessagesNotifier {
  GetMessagesUseCase? _getMessagesUseCase;
  SendMessageUseCase? _sendMessageUseCase;
  MarkAsReadUseCase? _markAsReadUseCase;

  @override
  Future<List<ChatMessageEntity>> build(String conversationId) async {
    _getMessagesUseCase = ref.read(getMessagesUseCaseProvider);
    _sendMessageUseCase = ref.read(sendMessageUseCaseProvider);
    _markAsReadUseCase = ref.read(markAsReadUseCaseProvider);
    await loadMessages(conversationId);
    return [];
  }

  Future<void> loadMessages(String conversationId) async {
    state = const AsyncValue.loading();
    final result = await _getMessagesUseCase!(conversationId);
    result.fold(
      (failure) {
        state = AsyncValue.error(
          Failure.unknown(message: failure.toString()),
          StackTrace.current,
        );
      },
      (messages) {
        state = AsyncValue.data(messages);
      },
    );
  }

  Future<void> sendMessage(
    String conversationId,
    SendMessageRequest request,
  ) async {
    final result = await _sendMessageUseCase!(request);
    result.fold(
      (failure) {
        throw Failure.unknown(message: failure.toString());
      },
      (message) async {
        await loadMessages(conversationId);
      },
    );
  }

  Future<void> markAsRead(String conversationId) async {
    final result = await _markAsReadUseCase!(conversationId);
    result.fold(
      (failure) {
        throw Failure.unknown(message: failure.toString());
      },
      (_) async {
        await loadMessages(conversationId);
      },
    );
  }
}


