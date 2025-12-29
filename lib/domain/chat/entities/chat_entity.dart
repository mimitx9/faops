class ChatMessageEntity {
  final String id;
  final String conversationId;
  final String senderId;
  final String? receiverId;
  final String content;
  final MessageType type;
  final DateTime createdAt;
  final bool isRead;
  final bool isSent;

  const ChatMessageEntity({
    required this.id,
    required this.conversationId,
    required this.senderId,
    this.receiverId,
    required this.content,
    this.type = MessageType.text,
    required this.createdAt,
    this.isRead = false,
    this.isSent = true,
  });
}

enum MessageType {
  text,
  image,
  file,
}

class ChatConversationEntity {
  final String id;
  final String? title;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final List<String> participantIds;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ChatConversationEntity({
    required this.id,
    this.title,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount = 0,
    required this.participantIds,
    required this.createdAt,
    this.updatedAt,
  });
}

class SendMessageRequest {
  final String conversationId;
  final String content;
  final MessageType type;

  const SendMessageRequest({
    required this.conversationId,
    required this.content,
    this.type = MessageType.text,
  });
}



