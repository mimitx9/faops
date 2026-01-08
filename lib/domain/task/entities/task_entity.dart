class TaskEntity {
  final int id;
  final int createdAt;
  final int updatedAt;
  final String status; // PROCESSING, DONE, CANCEL
  final int? expiredDate;
  final TaskMetaInfo metaInfo;
  final String title;
  final String taskCode;
  final List<TaskMember> members;
  final int? createdBy;
  final int? finishedBy;
  final int? cancelledBy;

  const TaskEntity({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    this.expiredDate,
    required this.metaInfo,
    required this.title,
    required this.taskCode,
    required this.members,
    this.createdBy,
    this.finishedBy,
    this.cancelledBy,
  });
}

class TaskMetaInfo {
  final String? content;
  final List<TaskAttachment> attachments;

  const TaskMetaInfo({
    this.content,
    required this.attachments,
  });
}

class TaskAttachment {
  final String type;
  final String link;

  const TaskAttachment({
    required this.type,
    required this.link,
  });
}

class TaskMember {
  final int member;
  final bool isCreator;
  final String? fullName;
  final String? avatar;

  const TaskMember({
    required this.member,
    required this.isCreator,
    this.fullName,
    this.avatar,
  });
}


