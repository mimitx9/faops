class TaskCommentEntity {
  final int id;
  final int createdAt;
  final int updatedAt;
  final TaskCommentMetaInfo metaInfo;
  final int member;
  final String taskCode;

  const TaskCommentEntity({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.metaInfo,
    required this.member,
    required this.taskCode,
  });
}

class TaskCommentMetaInfo {
  final String? content;
  final List<TaskCommentAttachment> attachments;

  const TaskCommentMetaInfo({
    this.content,
    required this.attachments,
  });
}

class TaskCommentAttachment {
  final String type;
  final String link;

  const TaskCommentAttachment({
    required this.type,
    required this.link,
  });
}


