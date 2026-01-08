import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../domain/task/entities/task_entity.dart';

part 'task_model.freezed.dart';
part 'task_model.g.dart';

@freezed
class TaskModel with _$TaskModel {
  const factory TaskModel({
    required int id,
    @JsonKey(name: 'createdAt') required int createdAt,
    @JsonKey(name: 'updatedAt') required int updatedAt,
    required String status,
    @JsonKey(name: 'expiredDate') int? expiredDate,
    @JsonKey(name: 'metaInfo') required TaskMetaInfoModel metaInfo,
    required String title,
    @JsonKey(name: 'taskCode') required String taskCode,
    required List<TaskMemberModel> members,
    @JsonKey(name: 'createdBy') int? createdBy,
    @JsonKey(name: 'finishedBy') int? finishedBy,
    @JsonKey(name: 'cancelledBy') int? cancelledBy,
  }) = _TaskModel;

  factory TaskModel.fromJson(Map<String, dynamic> json) =>
      _$TaskModelFromJson(json);
}

extension TaskModelX on TaskModel {
  TaskEntity toEntity() {
    return TaskEntity(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt,
      status: status,
      expiredDate: expiredDate,
      metaInfo: metaInfo.toEntity(),
      title: title,
      taskCode: taskCode,
      members: members.map((m) => m.toEntity()).toList(),
      createdBy: createdBy,
      finishedBy: finishedBy,
      cancelledBy: cancelledBy,
    );
  }
}

@freezed
class TaskMetaInfoModel with _$TaskMetaInfoModel {
  const factory TaskMetaInfoModel({
    String? content,
    @Default([]) List<TaskAttachmentModel> attachments,
  }) = _TaskMetaInfoModel;

  factory TaskMetaInfoModel.fromJson(Map<String, dynamic> json) =>
      _$TaskMetaInfoModelFromJson(json);
}

extension TaskMetaInfoModelX on TaskMetaInfoModel {
  TaskMetaInfo toEntity() {
    return TaskMetaInfo(
      content: content,
      attachments: attachments.map((a) => a.toEntity()).toList(),
    );
  }
}

@freezed
class TaskAttachmentModel with _$TaskAttachmentModel {
  const factory TaskAttachmentModel({
    required String type,
    required String link,
  }) = _TaskAttachmentModel;

  factory TaskAttachmentModel.fromJson(Map<String, dynamic> json) =>
      _$TaskAttachmentModelFromJson(json);
}

extension TaskAttachmentModelX on TaskAttachmentModel {
  TaskAttachment toEntity() {
    return TaskAttachment(
      type: type,
      link: link,
    );
  }
}

@freezed
class TaskMemberModel with _$TaskMemberModel {
  const factory TaskMemberModel({
    required int member,
    @JsonKey(name: 'isCreator') required bool isCreator,
    @JsonKey(name: 'fullName') String? fullName,
    String? avatar,
  }) = _TaskMemberModel;

  factory TaskMemberModel.fromJson(Map<String, dynamic> json) =>
      _$TaskMemberModelFromJson(json);
}

extension TaskMemberModelX on TaskMemberModel {
  TaskMember toEntity() {
    return TaskMember(
      member: member,
      isCreator: isCreator,
      fullName: fullName,
      avatar: avatar,
    );
  }
}


