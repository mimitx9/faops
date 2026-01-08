import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import '../../core/theme/design_system.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../domain/task/entities/task_entity.dart';
import '../../domain/task/entities/task_comment_entity.dart';
import '../../domain/task/repositories/task_repository.dart';
import '../../core/di/injectable.dart';

class TaskDetailSwiperPage extends ConsumerStatefulWidget {
  final List<TaskEntity> tasks;
  final int initialIndex;

  const TaskDetailSwiperPage({
    super.key,
    required this.tasks,
    this.initialIndex = 0,
  });

  @override
  ConsumerState<TaskDetailSwiperPage> createState() =>
      _TaskDetailSwiperPageState();
}

class _TaskDetailSwiperPageState
    extends ConsumerState<TaskDetailSwiperPage> {
  final CardSwiperController _controller = CardSwiperController();
  int _currentIndex = 0;
  Map<String, List<TaskCommentEntity>> _commentsByTask = {};
  bool _isLoadingComments = false;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _loadCommentsForCurrentTask();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  TaskEntity get _currentTask => widget.tasks[_currentIndex];

  Future<void> _loadCommentsForCurrentTask() async {
    final task = _currentTask;
    if (_commentsByTask.containsKey(task.taskCode)) return;

    setState(() {
      _isLoadingComments = true;
    });

    try {
      final repo = getIt<TaskRepository>();
      final result =
          await repo.getTaskComments(taskCode: task.taskCode);
      result.fold(
        (failure) {
          // Xử lý lỗi - có thể log hoặc hiển thị thông báo
          print('Error loading comments: ${failure.message}');
          // Không set comments nếu lỗi, để tránh crash
        },
        (comments) {
          setState(() {
            _commentsByTask[task.taskCode] = comments;
          });
        },
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingComments = false;
        });
      }
    }
  }

  Future<void> _handleSendComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final task = _currentTask;

    try {
      final repo = getIt<TaskRepository>();
      final result = await repo.createTaskComment(
        taskCode: task.taskCode,
        content: text,
      );
      result.fold(
        (_) {},
        (comment) {
          setState(() {
            final list =
                List<TaskCommentEntity>.from(_commentsByTask[task.taskCode] ?? []);
            list.add(comment);
            _commentsByTask[task.taskCode] = list;
            _commentController.clear();
          });
        },
      );
    } catch (_) {
      // ignore
    }
  }

  double _computeProgress(TaskEntity task) {
    if (task.expiredDate == null) return 0;
    final expired =
        DateTime.fromMillisecondsSinceEpoch(task.expiredDate! * 1000);
    final created =
        DateTime.fromMillisecondsSinceEpoch(task.createdAt * 1000);
    final now = DateTime.now();

    final total = expired.difference(created).inSeconds;
    if (total <= 0) return 1;
    final passed = now.difference(created).inSeconds;
    return (passed / total).clamp(0.0, 1.0);
  }

  String _remainingLabel(TaskEntity task) {
    if (task.expiredDate == null) return '';
    final expired =
        DateTime.fromMillisecondsSinceEpoch(task.expiredDate! * 1000);
    final now = DateTime.now();
    final diff = expired.difference(now);
    if (diff.isNegative) {
      return 'Đã quá hạn';
    }
    if (diff.inHours >= 1) {
      return 'Còn ${diff.inHours} giờ';
    }
    if (diff.inMinutes >= 1) {
      return 'Còn ${diff.inMinutes} phút';
    }
    return 'Sắp đến hạn';
  }

  @override
  Widget build(BuildContext context) {
    final totalTasks = widget.tasks.length;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: DesignSystem.spacingLG,
                vertical: DesignSystem.spacingMD,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$totalTasks TASK',
                    style: AppTypography.titleMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CardSwiper(
                controller: _controller,
                cardsCount: widget.tasks.length,
                initialIndex: widget.initialIndex,
                onSwipe: (prevIndex, nextIndex, direction) {
                  setState(() {
                    _currentIndex = nextIndex ?? _currentIndex;
                  });
                  _loadCommentsForCurrentTask();
                  return true;
                },
                cardBuilder: (context, index, _, __) {
                  final task = widget.tasks[index];
                  return _buildTaskCard(context, task);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, TaskEntity task) {
    final comments = _commentsByTask[task.taskCode] ?? [];
    final progress = _computeProgress(task);
    final remaining = _remainingLabel(task);

    // Chọn attachment image đầu tiên (nếu có)
    final imageAttachment = task.metaInfo.attachments
        .where((a) => a.type.toLowerCase().contains('image'))
        .cast<TaskAttachment>()
        .toList();

    return Container(
      margin: EdgeInsets.all(DesignSystem.spacingLG),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.all(DesignSystem.spacingLG),
            child: Text(
              task.title,
              style: AppTypography.titleLarge.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (imageAttachment.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  imageAttachment.first.link,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(DesignSystem.spacingLG),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (remaining.isNotEmpty) ...[
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: AppColors.taskPrimarySoft,
                              valueColor:
                                  const AlwaysStoppedAnimation<Color>(
                                AppColors.taskPrimary,
                              ),
                              minHeight: 32,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          remaining,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.taskPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (task.metaInfo.content != null &&
                      task.metaInfo.content!.isNotEmpty) ...[
                    Text(
                      task.metaInfo.content!,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Flexible(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.3,
                      ),
                      child: _isLoadingComments && comments.isEmpty
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : comments.isEmpty
                              ? Center(
                                  child: Text(
                                    'Chưa có bình luận',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: comments.length,
                                  itemBuilder: (context, index) {
                                    final c = comments[index];
                                    return Padding(
                                      padding: EdgeInsets.only(
                                        bottom: DesignSystem.spacingSM,
                                      ),
                                      child: Text(
                                        c.metaInfo.content ?? '',
                                        style: AppTypography.bodyMedium.copyWith(
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildCommentInput(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: DesignSystem.spacingMD,
        vertical: DesignSystem.spacingSM,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'Viết...',
                hintStyle: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textHint,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
              minLines: 1,
              maxLines: 3,
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.send,
              size: 20,
              color: AppColors.taskPrimary,
            ),
            onPressed: _handleSendComment,
          ),
        ],
      ),
    );
  }
}


