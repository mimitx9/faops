import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../domain/chat/entities/chat_entity.dart';

part 'chat_model.freezed.dart';
part 'chat_model.g.dart';

@freezed
class ChatMessageModel with _$ChatMessageModel {
  const factory ChatMessageModel({
    required String id,
    @JsonKey(name: 'conversation_id') required String conversationId,
    @JsonKey(name: 'sender_id') required String senderId,
    @JsonKey(name: 'receiver_id') String? receiverId,
    required String content,
    @JsonKey(name: 'type') @Default('text') String typeString,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'is_read') @Default(false) bool isRead,
    @JsonKey(name: 'is_sent') @Default(true) bool isSent,
  }) = _ChatMessageModel;

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageModelFromJson(json);
}

extension ChatMessageModelX on ChatMessageModel {
  ChatMessageEntity toEntity() {
    MessageType messageType;
    switch (typeString.toLowerCase()) {
      case 'image':
        messageType = MessageType.image;
        break;
      case 'file':
        messageType = MessageType.file;
        break;
      default:
        messageType = MessageType.text;
    }

    return ChatMessageEntity(
      id: id,
      conversationId: conversationId,
      senderId: senderId,
      receiverId: receiverId,
      content: content,
      type: messageType,
      createdAt: createdAt,
      isRead: isRead,
      isSent: isSent,
    );
  }
}

@freezed
class ChatConversationModel with _$ChatConversationModel {
  const factory ChatConversationModel({
    required String id,
    String? title,
    @JsonKey(name: 'last_message') String? lastMessage,
    @JsonKey(name: 'last_message_at') DateTime? lastMessageAt,
    @JsonKey(name: 'unread_count') @Default(0) int unreadCount,
    @JsonKey(name: 'participant_ids') required List<String> participantIds,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _ChatConversationModel;

  factory ChatConversationModel.fromJson(Map<String, dynamic> json) =>
      _$ChatConversationModelFromJson(json);
}

extension ChatConversationModelX on ChatConversationModel {
  ChatConversationEntity toEntity() {
    return ChatConversationEntity(
      id: id,
      title: title,
      lastMessage: lastMessage,
      lastMessageAt: lastMessageAt,
      unreadCount: unreadCount,
      participantIds: participantIds,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}



