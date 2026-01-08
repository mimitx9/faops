import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/design_system.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../widgets/common/function_page_layout.dart';
import 'task_detail_swiper_page.dart';
import '../../domain/task/repositories/task_repository.dart';
import '../../domain/task/entities/task_entity.dart';
import '../../core/error/failures.dart';
import 'package:dartz/dartz.dart' show Either, Right;
import '../../core/di/injectable.dart';

enum _DaySummaryStatus { none, done, inProgress, overdue }

class TaskPage extends ConsumerStatefulWidget {
  const TaskPage({super.key});

  @override
  ConsumerState<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends ConsumerState<TaskPage> {
  final List<Map<String, dynamic>> _messages = [];
  final ScrollController _scrollController = ScrollController();
  int _selectedTabIndex = 0; // 0: Tự động, 1: Thủ công
  bool _isLoading = false;

  // State cho tab "Thủ công"
  DateTime get _currentWeekStart {
    final today = _dateOnly(DateTime.now());
    return _startOfWeek(today);
  }
  
  DateTime _selectedDate = DateTime.now(); // Sẽ được khởi tạo lại trong initState
  Map<DateTime, List<TaskEntity>> _tasksByDate = {};
  bool _isManualLoading = false;
  bool _hasLoadedManualTasks = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = _dateOnly(DateTime.now());
  }

  void _handleSendMessage(String message) {
    setState(() {
      _messages.add({
        'text': message,
        'isUser': true,
        'timestamp': DateTime.now(),
      });
    });
    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleHelpBubbleTap(HelpBubble bubble) {
    String message = '';
    
    switch (bubble.label) {
      case 'Hôm nay':
        message = 'Nhiệm vụ hôm nay';
        break;
      case 'Ngày mai':
        message = 'Nhiệm vụ ngày mai';
        break;
      case 'Chưa xong':
        message = 'Nhiệm vụ chưa hoàn thành';
        break;
    }

    if (message.isNotEmpty) {
      _handleSendMessage(message);
      _fetchTasks(message);
    }
  }

  Future<void> _fetchTasks(String query) async {
    setState(() {
      _isLoading = true;
    });

    // Thêm loading message
    _addMessage('Đang tải...', false, isLoading: true);

    try {
      final taskRepository = getIt<TaskRepository>();
      Either<Failure, List<TaskEntity>> result;

      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
      final tomorrowStart = todayStart.add(Duration(days: 1));
      final tomorrowEnd = DateTime(tomorrowStart.year, tomorrowStart.month, tomorrowStart.day, 23, 59, 59);

      if (query == 'Nhiệm vụ hôm nay') {
        // Lấy tasks hôm nay (PROCESSING)
        final startDate = todayStart.millisecondsSinceEpoch ~/ 1000;
        final endDate = todayEnd.millisecondsSinceEpoch ~/ 1000;
        result = await taskRepository.getTasks(
          startDate: startDate,
          endDate: endDate,
          status: 'PROCESSING',
        );
      } else if (query == 'Nhiệm vụ ngày mai') {
        // Lấy tasks ngày mai (PROCESSING)
        final startDate = tomorrowStart.millisecondsSinceEpoch ~/ 1000;
        final endDate = tomorrowEnd.millisecondsSinceEpoch ~/ 1000;
        result = await taskRepository.getTasks(
          startDate: startDate,
          endDate: endDate,
          status: 'PROCESSING',
        );
      } else if (query == 'Nhiệm vụ chưa hoàn thành') {
        // Lấy tasks chưa hoàn thành (PROCESSING, không filter theo date)
        result = await taskRepository.getTasks(
          status: 'PROCESSING',
        );
      } else {
        result = const Right([]);
      }

      // Xóa loading message
      _removeLoadingMessage();

      result.fold(
        (failure) {
          _addMessage('Có lỗi xảy ra: ${failure.message}', false);
        },
        (tasks) {
          if (tasks.isEmpty) {
            _addMessage('Không có nhiệm vụ nào', false);
          } else {
            final formattedResponse = _formatTasksResponse(tasks, query);
            _addMessage(formattedResponse, false);
          }
        },
      );
    } catch (e) {
      _removeLoadingMessage();
      _addMessage('Có lỗi hệ thống', false);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // --------- TAB TỰ ĐỘNG (CHAT) ----------

  String _formatTasksResponse(List<TaskEntity> tasks, String query) {
    final buffer = StringBuffer();
    
    if (query == 'Nhiệm vụ hôm nay') {
      buffer.writeln('Nhiệm vụ hôm nay:\n');
    } else if (query == 'Nhiệm vụ ngày mai') {
      buffer.writeln('Nhiệm vụ ngày mai:\n');
    } else if (query == 'Nhiệm vụ chưa hoàn thành') {
      buffer.writeln('Nhiệm vụ chưa hoàn thành:\n');
    }

    for (var i = 0; i < tasks.length; i++) {
      final task = tasks[i];
      buffer.writeln('${i + 1}. ${task.title}');
      
      if (task.metaInfo.content != null && task.metaInfo.content!.isNotEmpty) {
        buffer.writeln('   ${task.metaInfo.content}');
      }

      if (task.expiredDate != null) {
        final expiredDate = DateTime.fromMillisecondsSinceEpoch(task.expiredDate! * 1000);
        final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
        buffer.writeln('   Hạn: ${dateFormat.format(expiredDate)}');
      }

      if (task.members.isNotEmpty) {
        final memberNames = task.members
            .where((m) => m.fullName != null)
            .map((m) => m.fullName!)
            .join(', ');
        if (memberNames.isNotEmpty) {
          buffer.writeln('   Thành viên: $memberNames');
        }
      }

      if (i < tasks.length - 1) {
        buffer.writeln('');
      }
    }

    return buffer.toString();
  }

  // --------- TAB THỦ CÔNG ----------

  DateTime _dateOnly(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  DateTime _startOfWeek(DateTime dateTime) {
    // Quy ước tuần bắt đầu từ Thứ 2
    final weekday = dateTime.weekday; // 1 = Mon, 7 = Sun
    return _dateOnly(dateTime.subtract(Duration(days: weekday - 1)));
  }

  List<DateTime> _currentWeekDays() {
    return List.generate(
      7,
      (index) => _currentWeekStart.add(Duration(days: index)),
    );
  }

  Future<void> _loadWeekTasksIfNeeded() async {
    if (_hasLoadedManualTasks) return;
    await _fetchWeekTasks();
  }

  Future<void> _fetchWeekTasks() async {
    setState(() {
      _isManualLoading = true;
    });

    try {
      final taskRepository = getIt<TaskRepository>();
      final weekStart = _currentWeekStart;
      final weekEnd =
          weekStart.add(const Duration(days: 7)).subtract(const Duration(seconds: 1));

      final startDate = weekStart.millisecondsSinceEpoch ~/ 1000;
      final endDate = weekEnd.millisecondsSinceEpoch ~/ 1000;

      final result = await taskRepository.getTasks(
        startDate: startDate,
        endDate: endDate,
      );

      result.fold(
        (failure) {
          // Có thể hiển thị message ở dưới nếu cần, tạm thời bỏ qua để tránh làm rối UI
        },
        (tasks) {
          final map = <DateTime, List<TaskEntity>>{};
          for (final task in tasks) {
            if (task.expiredDate == null) continue;
            final dateTime =
                DateTime.fromMillisecondsSinceEpoch(task.expiredDate! * 1000);
            final key = _dateOnly(dateTime);
            map.putIfAbsent(key, () => []).add(task);
          }
          setState(() {
            _tasksByDate = map;
            _hasLoadedManualTasks = true;
          });
        },
      );
    } catch (_) {
      // Bỏ qua lỗi, có thể log nếu cần
    } finally {
      if (mounted) {
        setState(() {
          _isManualLoading = false;
        });
      }
    }
  }

  void _addMessage(String text, bool isUser, {bool isLoading = false}) {
    setState(() {
      _messages.add({
        'text': text,
        'isUser': isUser,
        'timestamp': DateTime.now(),
        'isLoading': isLoading,
      });
    });
    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _removeLoadingMessage() {
    setState(() {
      _messages.removeWhere((msg) => msg['isLoading'] == true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FunctionPageLayout(
      placeholderText: 'Viết yêu cầu',
      onSendMessage: _handleSendMessage,
      showTabs: true,
      tabLabels: ['Tự động', 'Thủ công'],
      initialTabIndex: 0,
      alwaysShowHelpBubbles: _selectedTabIndex == 0, // Hiện bubbles luôn ở tab Tự động
      onHelpBubbleTapDirect: _selectedTabIndex == 0 ? _handleHelpBubbleTap : null,
      onTabChanged: (index) {
        setState(() {
          _selectedTabIndex = index;
        });
        if (index == 1) {
          _loadWeekTasksIfNeeded();
        }
      },
      helpBubbles: _selectedTabIndex == 0
          ? [
              HelpBubble(label: 'Hôm nay'),
              HelpBubble(label: 'Ngày mai'),
              HelpBubble(label: 'Chưa xong'),
            ]
          : null,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_selectedTabIndex == 0) {
      return _buildAutoBody();
    } else {
      return _buildManualBody();
    }
  }

  // Body cho tab "Tự động" (chat hiện tại)
  Widget _buildAutoBody() {
    if (_messages.isEmpty) {
      return SizedBox.shrink();
    }

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverPadding(
          padding: EdgeInsets.all(DesignSystem.spacingLG),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
              childCount: _messages.length,
            ),
          ),
        ),
      ],
    );
  }

  // Body cho tab "Thủ công"
  Widget _buildManualBody() {
    final weekDays = _currentWeekDays();
    final selectedDayKey = _dateOnly(_selectedDate);
    final tasksForSelectedDay = _tasksByDate[selectedDayKey] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        // Tháng hiện tại
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'THÁNG ${_selectedDate.month.toString().padLeft(2, '0')}',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.taskPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.taskPrimary,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Calendar 7 ngày trong tuần
        Padding(
          padding: EdgeInsets.symmetric(horizontal: DesignSystem.spacingLG),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: weekDays.map((day) => _buildDayItem(day)).toList(),
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: _isManualLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildManualTaskList(tasksForSelectedDay),
        ),
      ],
    );
  }

  String _weekdayLabel(DateTime day) {
    switch (day.weekday) {
      case DateTime.monday:
        return 'T2';
      case DateTime.tuesday:
        return 'T3';
      case DateTime.wednesday:
        return 'T4';
      case DateTime.thursday:
        return 'T5';
      case DateTime.friday:
        return 'T6';
      case DateTime.saturday:
        return 'T7';
      case DateTime.sunday:
      default:
        return 'CN';
    }
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  _DaySummaryStatus _getDayStatus(DateTime day) {
    final dayKey = _dateOnly(day);
    final tasks = _tasksByDate[dayKey] ?? [];
    if (tasks.isEmpty) return _DaySummaryStatus.none;

    final now = DateTime.now();
    final endOfDay =
        DateTime(dayKey.year, dayKey.month, dayKey.day, 23, 59, 59);

    bool hasProcessingNotExpired = false;
    bool hasOverdue = false;
    bool hasDone = false;

    for (final task in tasks) {
      final status = task.status.toUpperCase();
      if (status == 'DONE') {
        hasDone = true;
        continue;
      }
      if (status == 'CANCEL' || status == 'CANCELLED') {
        continue;
      }
      if (task.expiredDate == null) continue;

      final expired =
          DateTime.fromMillisecondsSinceEpoch(task.expiredDate! * 1000);
      if (expired.isBefore(endOfDay) && expired.isBefore(now)) {
        hasOverdue = true;
      } else {
        hasProcessingNotExpired = true;
      }
    }

    if (!hasProcessingNotExpired && !hasOverdue && hasDone) {
      // Tất cả đều hoàn thành (bỏ qua CANCEL)
      return _DaySummaryStatus.done;
    }

    if (!hasProcessingNotExpired && hasOverdue) {
      // Tất cả việc chưa hoàn thành đều quá hạn
      return _DaySummaryStatus.overdue;
    }

    if (hasProcessingNotExpired) {
      // Có ít nhất một việc đang xử lý và còn hạn
      return _DaySummaryStatus.inProgress;
    }

    return _DaySummaryStatus.none;
  }

  Widget _buildDayItem(DateTime day) {
    final isSelected = _isSameDate(day, _selectedDate);
    final status = _getDayStatus(day);

    Color borderColor = AppColors.border;
    Color fillColor = Colors.white;
    Widget? innerChild;

    switch (status) {
      case _DaySummaryStatus.done:
        borderColor = AppColors.taskPrimary;
        fillColor = AppColors.taskPrimary;
        innerChild = const Icon(
          Icons.check,
          size: 18,
          color: Colors.white,
        );
        break;
      case _DaySummaryStatus.overdue:
        borderColor = AppColors.accent;
        fillColor = Colors.white;
        innerChild = Icon(
          Icons.close,
          size: 18,
          color: AppColors.accent,
        );
        break;
      case _DaySummaryStatus.inProgress:
        borderColor = AppColors.taskPrimary;
        fillColor = Colors.white;
        innerChild = Icon(
          Icons.check,
          size: 16,
          color: AppColors.taskPrimary,
        );
        break;
      case _DaySummaryStatus.none:
        borderColor = AppColors.border;
        fillColor = Colors.white;
        innerChild = null;
        break;
    }

    if (isSelected) {
      borderColor = AppColors.taskPrimary;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDate = _dateOnly(day);
        });
      },
      child: Column(
        children: [
          Text(
            _weekdayLabel(day),
            style: AppTypography.bodySmall.copyWith(
              color: isSelected
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: fillColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: borderColor,
                width: 2,
              ),
            ),
            child: innerChild != null
                ? Center(child: innerChild)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildManualTaskList(List<TaskEntity> tasks) {
    if (tasks.isEmpty) {
      // Ngày chưa có nhiệm vụ
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: DesignSystem.spacingLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(top: DesignSystem.spacingLG),
              padding: EdgeInsets.all(DesignSystem.spacingLG),
              decoration: BoxDecoration(
                color: AppColors.taskEmpty,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                'Chưa có nhiệm vụ ngày này',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildAddTaskCard(),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: DesignSystem.spacingLG,
        vertical: DesignSystem.spacingLG,
      ),
      itemCount: tasks.length + 1,
      itemBuilder: (context, index) {
        if (index == tasks.length) {
          return _buildAddTaskCard();
        }
        final task = tasks[index];
        return Padding(
          padding: EdgeInsets.only(
            bottom: DesignSystem.spacingMD,
          ),
          child: GestureDetector(
            onTap: () => _openTaskDetail(tasks, index),
            child: _buildTaskCard(task),
          ),
        );
      },
    );
  }

  void _openTaskDetail(List<TaskEntity> tasks, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TaskDetailSwiperPage(
          tasks: tasks,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  Widget _buildTaskCard(TaskEntity task) {
    final status = task.status.toUpperCase();
    final isDone = status == 'DONE';
    final isCancelled = status == 'CANCEL' || status == 'CANCELLED';

    DateTime? expiredDate;
    String? expiredLabel;
    if (task.expiredDate != null) {
      expiredDate =
          DateTime.fromMillisecondsSinceEpoch(task.expiredDate! * 1000);
      final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
      expiredLabel = 'Hạn: ${dateFormat.format(expiredDate)}';
    }

    Color backgroundColor;
    TextStyle titleStyle = AppTypography.bodyLarge.copyWith(
      color: AppColors.taskPrimary,
      fontWeight: FontWeight.w600,
    );

    if (isDone) {
      backgroundColor = AppColors.taskPrimarySoft;
      titleStyle = titleStyle.copyWith(
        decoration: TextDecoration.lineThrough,
      );
    } else if (isCancelled) {
      backgroundColor = AppColors.background;
      titleStyle = AppTypography.bodyLarge.copyWith(
        color: AppColors.textSecondary,
        decoration: TextDecoration.lineThrough,
      );
    } else {
      backgroundColor = AppColors.surface;
    }

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
      padding: EdgeInsets.all(DesignSystem.spacingLG),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: titleStyle,
                ),
                if (expiredLabel != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    expiredLabel,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => _onToggleTaskStatus(task),
            child: _buildStatusTick(
              isDone: isDone,
              isCancelled: isCancelled,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onToggleTaskStatus(TaskEntity task) async {
    final currentStatus = task.status.toUpperCase();
    // Nếu đang CANCEL thì không cho đổi nhanh
    if (currentStatus == 'CANCEL') {
      return;
    }

    final isDone = currentStatus == 'DONE';
    final newStatus = isDone ? 'PROCESSING' : 'DONE';

    try {
      final taskRepository = getIt<TaskRepository>();
      final result = await taskRepository.updateTaskStatus(
        taskCode: task.taskCode,
        status: newStatus,
      );

      result.fold(
        (failure) {
          // Có thể show snackbar sau nếu cần
        },
        (updatedTask) {
          // Cập nhật lại map _tasksByDate
          if (updatedTask.expiredDate != null) {
            final date = DateTime.fromMillisecondsSinceEpoch(
              updatedTask.expiredDate! * 1000,
            );
            final key = _dateOnly(date);
            final list = List<TaskEntity>.from(_tasksByDate[key] ?? []);
            final index =
                list.indexWhere((element) => element.id == updatedTask.id);
            if (index != -1) {
              list[index] = updatedTask;
            }
            setState(() {
              _tasksByDate[key] = list;
            });
          } else {
            // Nếu không có expiredDate thì reload tuần
            _fetchWeekTasks();
          }
        },
      );
    } catch (_) {
      // Bỏ qua lỗi, có thể log nếu cần
    }
  }

  Widget _buildStatusTick({
    required bool isDone,
    required bool isCancelled,
  }) {
    Color borderColor;
    Color fillColor;
    Widget? icon;

    if (isDone) {
      borderColor = AppColors.taskPrimary;
      fillColor = AppColors.taskPrimary;
      icon = const Icon(
        Icons.check,
        size: 16,
        color: Colors.white,
      );
    } else if (isCancelled) {
      borderColor = AppColors.accent;
      fillColor = Colors.white;
      icon = Icon(
        Icons.close,
        size: 16,
        color: AppColors.accent,
      );
    } else {
      borderColor = AppColors.border;
      fillColor = Colors.white;
      icon = null;
    }

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: fillColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
      ),
      child: icon != null ? Center(child: icon) : null,
    );
  }

  Widget _buildAddTaskCard() {
    return GestureDetector(
      onTap: () {
        // TODO: điều hướng sang màn tạo task khi có route tương ứng
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.border,
            width: 1,
          ),
        ),
        padding: EdgeInsets.all(DesignSystem.spacingLG),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '+ Thêm',
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isUser = message['isUser'] as bool;
    final isLoading = message['isLoading'] as bool? ?? false;
    
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: DesignSystem.spacingMD),
        padding: EdgeInsets.all(DesignSystem.spacingMD),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser ? Color(0xFFF5F5F5) : AppColors.chatBubbleReceived,
          borderRadius: BorderRadius.circular(DesignSystem.radiusXL),
        ),
        child: isLoading
            ? _LoadingMessageWidget()
            : Text(
                message['text'] as String,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
      ),
    );
  }
}

class _LoadingMessageWidget extends StatefulWidget {
  @override
  State<_LoadingMessageWidget> createState() => _LoadingMessageWidgetState();
}

class _LoadingMessageWidgetState extends State<_LoadingMessageWidget> {
  int _dotCount = 1;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  void _startAnimation() {
    Future.delayed(Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _dotCount = (_dotCount % 3) + 1;
        });
        _startAnimation();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dots = '.' * _dotCount;
    return SizedBox(
      width: 100, // Width cố định để bubble không thay đổi size
      child: Text(
        'Đang xử lý$dots',
        style: AppTypography.bodyMedium.copyWith(
          color: Color(0xFF999999), // Màu xám
        ),
      ),
    );
  }
}
