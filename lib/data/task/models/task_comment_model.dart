import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../domain/task/entities/task_comment_entity.dart';

part 'task_comment_model.freezed.dart';
part 'task_comment_model.g.dart';

@freezed
class TaskCommentModel with _$TaskCommentModel {
  const factory TaskCommentModel({
    required int id,
    @JsonKey(name: 'createdAt') required int createdAt,
    @JsonKey(name: 'updatedAt') required int updatedAt,
    @JsonKey(name: 'metaInfo') required TaskCommentMetaInfoModel metaInfo,
    required int member,
    @JsonKey(name: 'taskCode') required String taskCode,
  }) = _TaskCommentModel;

  factory TaskCommentModel.fromJson(Map<String, dynamic> json) =>
      _$TaskCommentModelFromJson(json);
}

extension TaskCommentModelX on TaskCommentModel {
  TaskCommentEntity toEntity() {
    return TaskCommentEntity(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt,
      metaInfo: metaInfo.toEntity(),
      member: member,
      taskCode: taskCode,
    );
  }
}

@freezed
class TaskCommentMetaInfoModel with _$TaskCommentMetaInfoModel {
  const factory TaskCommentMetaInfoModel({
    String? content,
    @Default([]) List<TaskCommentAttachmentModel> attachments,
  }) = _TaskCommentMetaInfoModel;

  factory TaskCommentMetaInfoModel.fromJson(Map<String, dynamic> json) =>
      _$TaskCommentMetaInfoModelFromJson(json);
}

extension TaskCommentMetaInfoModelX on TaskCommentMetaInfoModel {
  TaskCommentMetaInfo toEntity() {
    return TaskCommentMetaInfo(
      content: content,
      attachments: attachments.map((a) => a.toEntity()).toList(),
    );
  }
}

@freezed
class TaskCommentAttachmentModel with _$TaskCommentAttachmentModel {
  const factory TaskCommentAttachmentModel({
    required String type,
    required String link,
  }) = _TaskCommentAttachmentModel;

  factory TaskCommentAttachmentModel.fromJson(Map<String, dynamic> json) =>
      _$TaskCommentAttachmentModelFromJson(json);
}

extension TaskCommentAttachmentModelX on TaskCommentAttachmentModel {
  TaskCommentAttachment toEntity() {
    return TaskCommentAttachment(
      type: type,
      link: link,
    );
  }
}


