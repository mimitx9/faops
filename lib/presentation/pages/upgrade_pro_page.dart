import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import '../../core/theme/design_system.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/role_constants.dart';
import '../widgets/common/fa_button.dart';
import '../widgets/common/fa_bubble_chip.dart';
import '../widgets/common/function_page_layout.dart';
import '../providers/upgrade_provider.dart';
import '../providers/profile_provider.dart';
import '../../domain/upgrade/entities/upgrade_entity.dart';
import '../../data/upgrade/services/reset_password_service.dart';
import '../../data/upgrade/services/user_action_service.dart';
import '../../data/upgrade/services/upgrade_account_service.dart';

class UpgradeProPage extends ConsumerStatefulWidget {
  const UpgradeProPage({super.key});

  @override
  ConsumerState<UpgradeProPage> createState() => _UpgradeProPageState();
}

class _UpgradeProPageState extends ConsumerState<UpgradeProPage> {
  bool _isYearly = false;
  final List<Map<String, dynamic>> _messages = [];
  final ScrollController _scrollController = ScrollController();
  
  // State cho form upgrade
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _keyController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _planController = TextEditingController();
  Set<String> _selectedApps = {}; // 'quiz', 'streak', 'class', 'hack', 'vstep'
  String? _selectedDuration; // '1', '3', '12', 'forever', '0'
  bool _isInstallment = false;
  bool _isStreakClass = false;
  bool _isVstep = false;
  int _selectedTabIndex = 1; // Mặc định là tab "Thủ công"

  List<Map<String, dynamic>> _getAvailableDurationsForApps(Set<String> apps) {
    final allDurations = [
      {'label': '1 tháng', 'key': '1', 'isRed': false},
      {'label': '3 tháng', 'key': '3', 'isRed': false},
      {'label': '12 tháng', 'key': '12', 'isRed': false},
      {'label': 'vĩnh viễn', 'key': 'forever', 'isRed': false},
      {'label': '0 ngày', 'key': '0', 'isRed': true},
    ];

    if (apps.isEmpty) {
      return allDurations;
    }

    final hasQuiz = apps.contains('quiz');
    final hasStreak = apps.contains('streak');
    final hasClass = apps.contains('class');
    final hasHack = apps.contains('hack');
    final hasVstep = apps.contains('vstep');

    // Nếu có VSTEP, chỉ hiển thị 1 tháng, 3 tháng, 0 ngày
    if (hasVstep) {
      return allDurations.where((d) => 
        d['key'] == '1' || d['key'] == '3' || d['key'] == '0'
      ).toList();
    }

    // Combo 4 app (Quiz, Streak, Hack, Class)
    if (hasQuiz && hasStreak && hasHack && hasClass && apps.length == 4) {
      return allDurations.where((d) => 
        d['key'] == '1' || d['key'] == '12' || d['key'] == 'forever' || d['key'] == '0'
      ).toList();
    }

    // Nếu chỉ có Streak, chỉ hiển thị vĩnh viễn và 0 ngày
    if (apps.length == 1 && hasStreak) {
      return allDurations.where((d) => 
        d['key'] == 'forever' || d['key'] == '0'
      ).toList();
    }

    // Các combo khác hoặc single app
    Set<String> validKeys = {};
    if (hasQuiz) {
      validKeys.addAll(['1', '12', 'forever', '0']);
    }
    if (hasStreak) {
      validKeys.addAll(['forever', '0']);
    }
    if (hasClass) {
      validKeys.addAll(['3', '12', 'forever', '0']);
    }
    if (hasHack) {
      validKeys.addAll(['1', '12', 'forever', '0']);
    }

    return allDurations.where((d) => validKeys.contains(d['key'])).toList();
  }

  List<Map<String, dynamic>> _getAvailableDurations() {
    final allDurations = [
      {'label': '1 tháng', 'key': '1', 'isRed': false},
      {'label': '3 tháng', 'key': '3', 'isRed': false},
      {'label': '12 tháng', 'key': '12', 'isRed': false},
      {'label': 'vĩnh viễn', 'key': 'forever', 'isRed': false},
      {'label': '0 ngày', 'key': '0', 'isRed': true},
    ];

    if (_selectedApps.isEmpty) {
      return allDurations;
    }

    // Nếu chọn nhiều app (combo), chỉ hiển thị các duration phù hợp với combo
    final hasQuiz = _selectedApps.contains('quiz');
    final hasStreak = _selectedApps.contains('streak');
    final hasClass = _selectedApps.contains('class');
    final hasHack = _selectedApps.contains('hack');
    final hasVstep = _selectedApps.contains('vstep');

    // Nếu có VSTEP, chỉ hiển thị 1 tháng, 3 tháng, 0 ngày
    if (hasVstep) {
      return allDurations.where((d) => 
        d['key'] == '1' || d['key'] == '3' || d['key'] == '0'
      ).toList();
    }

    // Combo 4 app (Quiz, Streak, Hack, Class)
    if (hasQuiz && hasStreak && hasHack && hasClass && _selectedApps.length == 4) {
      return allDurations.where((d) => 
        d['key'] == '1' || d['key'] == '12' || d['key'] == 'forever' || d['key'] == '0'
      ).toList();
    }

    // Nếu chỉ có Streak, chỉ hiển thị vĩnh viễn và 0 ngày
    if (_selectedApps.length == 1 && hasStreak) {
      return allDurations.where((d) => 
        d['key'] == 'forever' || d['key'] == '0'
      ).toList();
    }

    // Các combo khác hoặc single app
    Set<String> validKeys = {};
    if (hasQuiz) {
      validKeys.addAll(['1', '12', 'forever', '0']);
    }
    if (hasStreak) {
      validKeys.addAll(['forever', '0']);
    }
    if (hasClass) {
      validKeys.addAll(['3', '12', 'forever', '0']);
    }
    if (hasHack) {
      validKeys.addAll(['1', '12', 'forever', '0']);
    }

    return allDurations.where((d) => validKeys.contains(d['key'])).toList();
  }

  void _autoFillValues() {
    if (_selectedApps.isEmpty || _selectedDuration == null) {
      return;
    }

    String timeValue = '';
    String priceValue = '';
    String keyValue = '';
    String noteValue = '';

    final hasQuiz = _selectedApps.contains('quiz');
    final hasStreak = _selectedApps.contains('streak');
    final hasClass = _selectedApps.contains('class');
    final hasHack = _selectedApps.contains('hack');
    final hasVstep = _selectedApps.contains('vstep');

    // Xử lý combo trước
    // Combo 4 app (Quiz, Streak, Hack, Class)
    if (hasQuiz && hasStreak && hasHack && hasClass && _selectedApps.length == 4) {
      switch (_selectedDuration) {
        case '1':
          timeValue = '31';
          priceValue = '1099000';
          noteValue = 'Combo 4 app FA Quiz, FA Streak, FA Hack, FA Class 1 tháng';
          break;
        case '12':
          timeValue = '365';
          priceValue = '3899000';
          noteValue = 'Combo 4 app FA Quiz, FA Streak, FA Hack, FA Class 12 tháng';
          break;
        case 'forever':
          timeValue = '2200';
          priceValue = '8888000';
          noteValue = 'Combo 4 app FA Quiz, FA Streak, FA Hack, FA Class vĩnh viễn';
          break;
        case '0':
          timeValue = '0';
          priceValue = '';
          noteValue = 'Reset TK Combo 4 app';
          break;
      }
    }
    // Combo Quiz + Hack
    else if (hasQuiz && hasHack && _selectedApps.length == 2 && !hasStreak && !hasClass) {
      if (_selectedDuration == 'forever') {
        timeValue = '2200';
        priceValue = '2999000';
        noteValue = 'Combo FA Quiz, FA Hack vĩnh viễn';
      } else if (_selectedDuration == '0') {
        timeValue = '0';
        priceValue = '';
        noteValue = 'Reset TK Combo Quiz Hack';
      }
    }
    // Combo Quiz + Streak
    else if (hasQuiz && hasStreak && _selectedApps.length == 2 && !hasHack && !hasClass) {
      if (_selectedDuration == 'forever') {
        timeValue = '2200';
        priceValue = '2599000';
        noteValue = 'Combo FA Quiz, FA Streak vĩnh viễn';
      } else if (_selectedDuration == '0') {
        timeValue = '0';
        priceValue = '';
        noteValue = 'Reset TK Combo Quiz Streak';
      }
    }
    // Combo Quiz + Class
    else if (hasQuiz && hasClass && _selectedApps.length == 2 && !hasHack && !hasStreak) {
      if (_selectedDuration == 'forever') {
        timeValue = '2200';
        priceValue = '6999000';
        noteValue = 'Combo FA Quiz, FA Class vĩnh viễn';
      } else if (_selectedDuration == '0') {
        timeValue = '0';
        priceValue = '';
        noteValue = 'Reset TK Combo Quiz Class';
      }
    }
    // Combo Quiz + Class + Streak
    else if (hasQuiz && hasClass && hasStreak && _selectedApps.length == 3 && !hasHack) {
      if (_selectedDuration == 'forever') {
        timeValue = '2200';
        priceValue = '7599000';
        noteValue = 'Combo FA Quiz, FA Class, FA Streak vĩnh viễn';
      } else if (_selectedDuration == '0') {
        timeValue = '0';
        priceValue = '';
        noteValue = 'Reset TK Combo Quiz Class Streak';
      }
    }
    // Combo Quiz + Class + Hack
    else if (hasQuiz && hasClass && hasHack && _selectedApps.length == 3 && !hasStreak) {
      if (_selectedDuration == 'forever') {
        timeValue = '2200';
        priceValue = '7899000';
        noteValue = 'Combo FA Quiz, FA Class, FA Hack vĩnh viễn';
      } else if (_selectedDuration == '0') {
        timeValue = '0';
        priceValue = '';
        noteValue = 'Reset TK Combo Quiz Class Hack';
      }
    }
    // Combo Quiz + Hack + Streak
    else if (hasQuiz && hasHack && hasStreak && _selectedApps.length == 3 && !hasClass) {
      if (_selectedDuration == 'forever') {
        timeValue = '2200';
        priceValue = '3899000';
        noteValue = 'Combo FA Quiz, FA Hack, FA Streak vĩnh viễn';
      } else if (_selectedDuration == '0') {
        timeValue = '0';
        priceValue = '';
        noteValue = 'Reset TK Combo Quiz Hack Streak';
      }
    }
    // Single app hoặc combo không khớp
    else if (_selectedApps.length == 1) {
      final app = _selectedApps.first;
      switch (app) {
        case 'quiz':
          switch (_selectedDuration) {
            case '1':
              timeValue = '31';
              priceValue = '159000';
              noteValue = 'Quiz 1 tháng';
              break;
            case '12':
              timeValue = '365';
              priceValue = '999000';
              noteValue = 'Quiz 12 tháng';
              break;
            case 'forever':
              timeValue = '2200';
              priceValue = '1899000';
              noteValue = 'Quiz vĩnh viễn';
              break;
            case '0':
              timeValue = '0';
              priceValue = '';
              noteValue = 'Reset TK Quiz';
              break;
          }
          break;
        case 'streak':
          switch (_selectedDuration) {
            case 'forever':
              timeValue = '';
              priceValue = '999000';
              keyValue = '999';
              noteValue = 'Streak vĩnh viễn';
              break;
            case '0':
              timeValue = '0';
              priceValue = '';
              noteValue = 'Reset TK Streak';
              break;
          }
          break;
        case 'class':
          switch (_selectedDuration) {
            case '3':
              timeValue = '90';
              priceValue = '799000';
              noteValue = 'Class 3 tháng';
              break;
            case '12':
              timeValue = '365';
              priceValue = '1499000';
              noteValue = 'Class 12 tháng';
              break;
            case 'forever':
              timeValue = '2200';
              priceValue = '10000000';
              noteValue = 'Class vĩnh viễn';
              break;
            case '0':
              timeValue = '0';
              priceValue = '';
              noteValue = 'Reset TK Class';
              break;
          }
          break;
        case 'hack':
          switch (_selectedDuration) {
            case '1':
              timeValue = '31';
              priceValue = '99000';
              noteValue = 'Hack 1 tháng';
              break;
            case '12':
              timeValue = '365';
              priceValue = '699000';
              noteValue = 'Hack 12 tháng';
              break;
            case 'forever':
              timeValue = '2200';
              priceValue = '1299000';
              noteValue = 'Hack vĩnh viễn';
              break;
            case '0':
              timeValue = '0';
              priceValue = '';
              noteValue = 'Reset TK Hack';
              break;
          }
          break;
        case 'vstep':
          switch (_selectedDuration) {
            case '1':
              timeValue = '31';
              priceValue = '699000';
              noteValue = 'VStep 1 tháng';
              break;
            case '3':
              timeValue = '90';
              priceValue = '899000';
              noteValue = 'VStep 3 tháng';
              break;
            case '0':
              timeValue = '0';
              priceValue = '';
              noteValue = 'Reset TK VStep';
              break;
          }
          break;
      }
    }

    setState(() {
      if (timeValue.isNotEmpty) {
        _timeController.text = timeValue;
      } else {
        _timeController.clear();
      }

      if (priceValue.isNotEmpty) {
        try {
          final number = int.parse(priceValue);
          final formatter = NumberFormat('#,###', 'vi_VN');
          _priceController.text = formatter.format(number);
        } catch (e) {
          _priceController.text = priceValue;
        }
      } else {
        _priceController.clear();
      }

      if (keyValue.isNotEmpty) {
        _keyController.text = keyValue;
      } else {
        // Clear key nếu không phải streak
        if (!_selectedApps.contains('streak') || _selectedApps.length > 1) {
          _keyController.text = '0';
        }
      }

      if (noteValue.isNotEmpty) {
        // Xử lý các option đã chọn
        String finalNote = noteValue;
        
        // Nếu "Lớp Streak" được chọn, thay thế note bằng "Combo Streak A-Z"
        if (_isStreakClass) {
          finalNote = 'Combo Streak A-Z';
        }
        // Nếu "VSTEP" được chọn, thay thế note bằng "Tặng TK VSTEP 1 tháng"
        else if (_isVstep) {
          finalNote = 'Tặng TK VSTEP 1 tháng';
        }
        // Nếu "Trả góp" được chọn, append vào note
        else if (_isInstallment) {
          finalNote = '$noteValue / Trả góp lần 1/3 - fb';
        }
        
        _planController.text = finalNote;
      } else {
        // Nếu không có noteValue nhưng có option được chọn
        if (_isStreakClass) {
          _planController.text = 'Combo Streak A-Z';
        } else if (_isVstep) {
          _planController.text = 'Tặng TK VSTEP 1 tháng';
        } else if (_isInstallment) {
          _planController.text = 'Trả góp lần 1/3 - fb';
        } else {
          _planController.clear();
        }
      }
    });
  }


  @override
  void initState() {
    super.initState();
    // Set giá trị mặc định
    _timeController.text = '30';
    _keyController.text = '0';
    // Tự động paste số điện thoại từ clipboard khi khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndPasteClipboard();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _phoneController.dispose();
    _timeController.dispose();
    _keyController.dispose();
    _priceController.dispose();
    _planController.dispose();
    super.dispose();
  }

  Future<void> _checkAndPasteClipboard() async {
    if (_phoneController.text.trim().isNotEmpty) {
      return;
    }

    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      final clipboardText = clipboardData?.text?.trim() ?? '';

      if (clipboardText.isNotEmpty &&
          clipboardText.length <= 20 &&
          RegExp(r'^\d+$').hasMatch(clipboardText)) {
        _phoneController.text = clipboardText;
      }
    } catch (e) {
      print('Error reading clipboard: $e');
    }
  }

  void _formatPriceOnChange(String value) {
    final text = value.replaceAll(RegExp(r'[^\d]'), '');
    if (text.isEmpty) {
      _priceController.text = '';
      return;
    }
    
    try {
      final number = int.parse(text);
      final formatter = NumberFormat('#,###', 'vi_VN');
      final formatted = formatter.format(number);
      
      if (_priceController.text != formatted) {
        final selection = _priceController.selection;
        final cursorPosition = selection.baseOffset;
        final textBeforeCursor = _priceController.text.substring(0, cursorPosition.clamp(0, _priceController.text.length));
        final digitsBeforeCursor = textBeforeCursor.replaceAll(RegExp(r'[^\d]'), '').length;
        
        _priceController.value = TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(
            offset: _getCursorPosition(formatted, digitsBeforeCursor),
          ),
        );
      }
    } catch (e) {
      // Ignore parse errors
    }
  }

  int _getCursorPosition(String formatted, int digitsBefore) {
    int digitCount = 0;
    for (int i = 0; i < formatted.length; i++) {
      if (RegExp(r'\d').hasMatch(formatted[i])) {
        digitCount++;
        if (digitCount >= digitsBefore) {
          return i + 1;
        }
      }
    }
    return formatted.length;
  }

  Future<void> _handlePurchase(String planId) async {
    final request = PurchaseRequest(
      planId: planId,
      isYearly: _isYearly,
    );
    await ref.read(purchaseNotifierProvider.notifier).purchase(request);
  }

  void _addMessage(String text, bool isUser, {Map<String, dynamic>? soiData, bool isLoading = false}) {
    setState(() {
      _messages.add({
        'text': text,
        'isUser': isUser,
        'timestamp': DateTime.now(),
        'isSoiInfo': soiData != null,
        'soiData': soiData,
        'isLoading': isLoading,
      });
    });
    // Scroll to bottom after adding message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
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

  void _handleSendMessage(String message) {
    _addMessage(message, true);
    
    final lowerMessage = message.toLowerCase().trim();
    final trimmedMessage = message.trim();
    
    // Kiểm tra nếu message là "Soi {sđt}"
    if (lowerMessage.startsWith('soi ')) {
      final phone = trimmedMessage.substring(3).trim();
      if (phone.isNotEmpty) {
        _handleSoi(phone);
      }
    }
    // Kiểm tra nếu message là "Reset {sđt}"
    else if (lowerMessage.startsWith('reset ')) {
      // Lấy phần sau "Reset " và loại bỏ khoảng trắng
      final phone = trimmedMessage.substring(5).trim();
      if (phone.isNotEmpty) {
        _handleResetPassword(phone);
      }
    }
    // Kiểm tra nếu message là "Enable {sđt}"
    else if (lowerMessage.startsWith('enable ')) {
      final phone = trimmedMessage.substring(6).trim();
      if (phone.isNotEmpty) {
        _handleUserAction(phone, 'enable');
      }
    }
    // Kiểm tra nếu message là "Disable {sđt}"
    else if (lowerMessage.startsWith('disable ')) {
      final phone = trimmedMessage.substring(7).trim();
      if (phone.isNotEmpty) {
        _handleUserAction(phone, 'disable');
      }
    }
    // Mặc định: xử lý như "Soi" nếu không khớp với bất kỳ pattern nào
    else if (trimmedMessage.isNotEmpty) {
      _handleSoi(trimmedMessage);
    }
  }

  Future<void> _handleResetPassword(String phone) async {
    try {
      // Tạo instance của ResetPasswordService
      final resetService = ResetPasswordService();
      final response = await resetService.resetPassword(phone);
      
      if (response.code == 200) {
        // Parse message để lấy một message ngẫu nhiên
        final randomMessage = ResetPasswordService.parseRandomMessage(response.message);
        _addMessage(randomMessage, false);
      } else {
        // Hiển thị message lỗi
        _addMessage(response.message, false);
      }
    } catch (e) {
      _addMessage('Đã xảy ra lỗi: ${e.toString()}', false);
    }
  }

  Future<void> _handleSoi(String phoneNumber) async {
    // Thêm loading message
    _addMessage('Đang xử lý', false, isLoading: true);
    
    try {
      final userActionService = UserActionService();
      final response = await userActionService.processUserAction(phoneNumber, 'info');
      
      // Xóa loading message
      _removeLoadingMessage();
      
      if (response.code == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final userInfo = data['userInfo'] as Map<String, dynamic>?;
        final daysSinceCreation = data['daysSinceCreation'] as int?;
        final activityLogs = data['activityLogs'] as List<dynamic>?;
        final grade = data['grade'] as Map<String, dynamic>?;
        final program = data['program'] as Map<String, dynamic>?;
        final devices = data['devices'] as List<dynamic>?;
        
        if (userInfo != null) {
          // Lưu data để render UI đặc biệt
          _addMessage('', false, soiData: {
            'userInfo': userInfo,
            'daysSinceCreation': daysSinceCreation,
            'activityLogs': activityLogs,
            'grade': grade,
            'program': program,
            'devices': devices,
          });
        } else {
          _addMessage('Không tồn tại thông tin cho user này', false);
        }
      } else {
        _addMessage('Không tồn tại thông tin cho user này', false);
      }
    } catch (e) {
      // Xóa loading message nếu có lỗi
      _removeLoadingMessage();
      _addMessage('Không tồn tại thông tin cho user này', false);
    }
  }

  String _formatUserInfo(Map<String, dynamic> userInfo, int? daysSinceCreation, List<dynamic>? activityLogs, Map<String, dynamic>? grade, Map<String, dynamic>? program, List<dynamic>? devices) {
    final buffer = StringBuffer();
    
    // Thông tin cơ bản
    buffer.writeln('📱 Thông tin User:');
    buffer.writeln('');
    
    if (userInfo['fullName'] != null) {
      buffer.writeln('👤 Họ tên: ${userInfo['fullName']}');
    }
    if (userInfo['username'] != null) {
      buffer.writeln('📞 SĐT: ${userInfo['username']}');
    }
    if (userInfo['email'] != null) {
      buffer.writeln('📧 Email: ${userInfo['email']}');
    }
    if (userInfo['userId'] != null) {
      buffer.writeln('🆔 User ID: ${userInfo['userId']}');
    }
    if (userInfo['university'] != null) {
      buffer.writeln('🏫 Trường: ${userInfo['university']}');
    }
    if (grade != null && grade['name'] != null) {
      buffer.writeln('📊 Khóa: ${grade['name']}');
    }
    if (program != null && program['name'] != null) {
      buffer.writeln('🎓 Chương trình: ${program['name']}');
    }
    if (daysSinceCreation != null) {
      buffer.writeln('📅 Số ngày tạo tài khoản: $daysSinceCreation ngày');
    }
    
    buffer.writeln('');
    
    // FA Streak Info
    if (userInfo['faStreakInfo'] != null) {
      final streakInfo = userInfo['faStreakInfo'] as Map<String, dynamic>;
      buffer.writeln('🔥 FA Streak: ${streakInfo['isPaid'] == true ? "Đã thanh toán" : "Chưa thanh toán"}');
      if (streakInfo['isPaid'] == true) {
        if (streakInfo['plan'] != null) {
          buffer.writeln('   Plan: ${streakInfo['plan']}');
        }
        if (streakInfo['expireTime'] != null) {
          final expireTime = streakInfo['expireTime'] as int;
          final expireDate = DateTime.fromMillisecondsSinceEpoch(expireTime * 1000);
          buffer.writeln('   Hết hạn: ${expireDate.day}/${expireDate.month}/${expireDate.year}');
        }
      }
    }
    
    // FA Hack Info
    if (userInfo['faHackInfo'] != null) {
      final hackInfo = userInfo['faHackInfo'] as Map<String, dynamic>;
      buffer.writeln('💻 FA Hack: ${hackInfo['isPaid'] == true ? "Đã thanh toán" : "Chưa thanh toán"}');
      if (hackInfo['isPaid'] == true) {
        if (hackInfo['plan'] != null) {
          buffer.writeln('   Plan: ${hackInfo['plan']}');
        }
        if (hackInfo['expireTime'] != null) {
          final expireTime = hackInfo['expireTime'] as int;
          final expireDate = DateTime.fromMillisecondsSinceEpoch(expireTime * 1000);
          buffer.writeln('   Hết hạn: ${expireDate.day}/${expireDate.month}/${expireDate.year}');
        }
      }
    }
    
    // FA Class Info
    if (userInfo['faClassInfo'] != null) {
      final classInfo = userInfo['faClassInfo'] as Map<String, dynamic>;
      buffer.writeln('📚 FA Class: ${classInfo['isPaid'] == true ? "Đã thanh toán" : "Chưa thanh toán"}');
      if (classInfo['isPaid'] == true) {
        if (classInfo['plan'] != null) {
          buffer.writeln('   Plan: ${classInfo['plan']}');
        }
        if (classInfo['expireTime'] != null) {
          final expireTime = classInfo['expireTime'] as int;
          final expireDate = DateTime.fromMillisecondsSinceEpoch(expireTime * 1000);
          buffer.writeln('   Hết hạn: ${expireDate.day}/${expireDate.month}/${expireDate.year}');
        }
      }
    }
    
    // FA Quiz Info
    if (userInfo['faQuizInfo'] != null) {
      final quizInfo = userInfo['faQuizInfo'] as Map<String, dynamic>;
      buffer.writeln('📝 FA Quiz: ${quizInfo['isPaid'] == true ? "Đã thanh toán" : "Chưa thanh toán"}');
      if (quizInfo['isPaid'] == true) {
        if (quizInfo['plan'] != null) {
          buffer.writeln('   Plan: ${quizInfo['plan']}');
        }
        if (quizInfo['expireTime'] != null) {
          final expireTime = quizInfo['expireTime'] as int;
          final expireDate = DateTime.fromMillisecondsSinceEpoch(expireTime * 1000);
          buffer.writeln('   Hết hạn: ${expireDate.day}/${expireDate.month}/${expireDate.year}');
        }
      }
    }
    
    // Activity Logs
    if (activityLogs != null && activityLogs.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('📋 Lịch sử hoạt động (${activityLogs.length}):');
      buffer.writeln('');
      
      // Hiển thị tối đa 20 hoạt động gần nhất
      final displayCount = activityLogs.length > 20 ? 20 : activityLogs.length;
      for (var i = 0; i < displayCount; i++) {
        final log = activityLogs[i] as Map<String, dynamic>;
        final createdAt = log['createdAt'] as String? ?? '';
        final actionDescription = log['actionDescription'] as String? ?? '';
        buffer.writeln('   [$createdAt] $actionDescription');
      }
      
      if (activityLogs.length > 20) {
        buffer.writeln('   ... và ${activityLogs.length - 20} hoạt động khác');
      }
    }
    
    // Devices
    if (devices != null && devices.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('📱 Danh sách thiết bị (${devices.length}):');
      buffer.writeln('');
      
      for (var i = 0; i < devices.length; i++) {
        final device = devices[i] as Map<String, dynamic>;
        final deviceName = device['deviceName'] as String? ?? '';
        final deviceType = device['deviceType'] as String? ?? '';
        final osVersion = device['osVersion'] as String? ?? '';
        final appVersion = device['appVersion'] as String? ?? '';
        final lastLogin = device['lastLogin'] as int?;
        
        final deviceTypeText = deviceType == 'ios' ? 'iOS' : (deviceType == 'android' ? 'Android' : deviceType);
        buffer.writeln('   ${i + 1}. $deviceName ($deviceTypeText)');
        buffer.writeln('      OS: $osVersion | App: $appVersion');
        if (lastLogin != null) {
          final lastLoginDate = DateTime.fromMillisecondsSinceEpoch(lastLogin * 1000);
          buffer.writeln('      Đăng nhập lần cuối: ${lastLoginDate.day}/${lastLoginDate.month}/${lastLoginDate.year} ${lastLoginDate.hour}:${lastLoginDate.minute.toString().padLeft(2, '0')}');
        }
        if (i < devices.length - 1) {
          buffer.writeln('');
        }
      }
    }
    
    return buffer.toString();
  }

  Future<void> _handleUserAction(String phoneNumber, String action) async {
    // Thêm loading message
    _addMessage('Đang xử lý', false, isLoading: true);
    
    try {
      final userActionService = UserActionService();
      final response = await userActionService.processUserAction(phoneNumber, action);
      
      // Xóa loading message
      _removeLoadingMessage();
      
      if (response.code == 200) {
        // Thành công
        final actionText = action == 'enable' ? 'enable' : 'disable';
        _addMessage('đã $actionText thành công', false);
      } else {
        // Lỗi hệ thống
        _addMessage('có lỗi hệ thống', false);
      }
    } catch (e) {
      // Xóa loading message nếu có lỗi
      _removeLoadingMessage();
      _addMessage('có lỗi hệ thống', false);
    }
  }

  void _handleHelpBubbleTap(String label, String inputText) {
    // Bắt đầu cuộc hội thoại mới - clear messages cũ
    setState(() {
      _messages.clear();
    });
    // Tạo message dạng "Soi {{sđt}}" hoặc "Tạo QR {{sđt}}"...
    final message = '$label $inputText';
    _handleSendMessage(message);
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isUser = message['isUser'] as bool;
    final isSoiInfo = message['isSoiInfo'] as bool? ?? false;
    final isLoading = message['isLoading'] as bool? ?? false;
    
    if (isSoiInfo && !isUser) {
      final soiData = message['soiData'] as Map<String, dynamic>?;
      if (soiData != null) {
        return Align(
          alignment: Alignment.centerLeft,
          child: Container(
            margin: EdgeInsets.only(bottom: DesignSystem.spacingMD),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.9,
            ),
            child: SoiInfoWidget(
              userInfo: soiData['userInfo'] as Map<String, dynamic>?,
              daysSinceCreation: soiData['daysSinceCreation'] as int?,
              activityLogs: soiData['activityLogs'] as List<dynamic>?,
              grade: soiData['grade'] as Map<String, dynamic>?,
              program: soiData['program'] as Map<String, dynamic>?,
              devices: soiData['devices'] as List<dynamic>?,
            ),
          ),
        );
      }
    }
    
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

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileNotifierProvider);
    final profile = profileState.valueOrNull;
    final hasAllRoles = profile?.roles.contains(RoleConstants.roleAll) ?? false;

    return FunctionPageLayout(
      placeholderText: 'Viết yêu cầu',
      onSendMessage: _handleSendMessage,
      showTabs: true,
      showSendButton: false,
      tabLabels: ['Khác', 'Thủ công'],
      initialTabIndex: 1, // Mặc định là tab "Thủ công"
      enableClipboardPaste: true,
      onHelpBubbleTap: _handleHelpBubbleTap,
      onTabChanged: (index) {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      helpBubbles: [
        const HelpBubble(
          label: 'Tạo QR',
        ),
        const HelpBubble(
          label: 'Soi',
        ),
        const HelpBubble(
          label: 'Reset',
        ),
        const HelpBubble(
          label: 'Disable',
        ),
        const HelpBubble(
          label: 'Enable',
        ),
      ],
      body: _selectedTabIndex == 1 
          ? Column(
              children: [
                Expanded(
                  child: _buildUpgradeForm(),
                ),
              ],
            )
          : Column(
              children: [
                Expanded(
                  child: CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      // Messages section
                      if (_messages.isNotEmpty)
                        SliverPadding(
                          padding: EdgeInsets.all(DesignSystem.spacingLG),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                return _buildMessageBubble(_messages[index]);
                              },
                              childCount: _messages.length,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
      showInputBox: _selectedTabIndex == 0, // Hiển thị input box khi tab "Khác" được chọn
      customBottomWidget: _selectedTabIndex == 1 ? _buildUpgradeButton() : null,
    );
  }

  Widget _buildUpgradeForm() {
    return SingleChildScrollView(
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Dòng 1: Input số điện thoại
            Padding(
              padding: EdgeInsets.symmetric(horizontal: DesignSystem.spacingLG),
              child: Column(
                children: [
                  _buildPhoneInput(),
                ],
              ),
            ),
            SizedBox(height: DesignSystem.spacingMD),
            // Dòng 2: Thời gian và Key
            Padding(
              padding: EdgeInsets.symmetric(horizontal: DesignSystem.spacingLG),
              child: Row(
              children: [
                Expanded(
                  child: _buildTimeInput(),
                ),
                SizedBox(width: DesignSystem.spacingMD),
                Expanded(
                  child: _buildKeyInput(),
                ),
              ],
            ),
            ),
            
            SizedBox(height: DesignSystem.spacingMD),
            // Dòng 3: Số tiền
            Padding(
              padding: EdgeInsets.symmetric(horizontal: DesignSystem.spacingLG),
              child: Column(
                children: [
                  _buildPriceInput(),
                ],
              ),
            ),
            SizedBox(height: DesignSystem.spacingLG),
            // Dòng 4: App selection (Quiz, Streak, Class, Hack)
            _buildAppSelection(),
            SizedBox(height: DesignSystem.spacingLG),
            // Dòng 5: Duration selection (1 tháng, 3 tháng, 12 tháng, vĩnh viễn)
            _buildDurationSelection(),
            SizedBox(height: DesignSystem.spacingXL),
            // Dòng 6: Plan textbox
            Padding(
              padding: EdgeInsets.symmetric(horizontal: DesignSystem.spacingLG),
              child: _buildPlanInput(),
            ),
            SizedBox(height: DesignSystem.spacingMD),
            // Dòng 7: Options (Trả góp, Lớp Streak, VSTEP)
            _buildOptionsSelection(),
          ],
        ),
    );
  }

  Widget _buildPhoneInput() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(DesignSystem.radiusFull),
        border: Border.all(
          color: Color(0xFFF5F5F5),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          SizedBox(width: DesignSystem.spacingLG),
          SvgPicture.asset(
            'assets/svg/usericon.svg',
            width: 18,
            height: 18,
            color: Colors.black12,
          ),
          SizedBox(width: DesignSystem.spacingMD),
          Expanded(
            child: TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: 'SĐT',
                hintStyle: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textHint,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  vertical: DesignSystem.spacingMD,
                ),
              ),
              style: AppTypography.bodyLarge,
            ),
          ),
          SizedBox(width: DesignSystem.spacingMD),
        ],
      ),
    );
  }

  Widget _buildTimeInput() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(DesignSystem.radiusFull),
        border: Border.all(
          color: Color(0xFFF5F5F5),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          SizedBox(width: DesignSystem.spacingLG),
          SvgPicture.asset(
            'assets/svg/hsd.svg',
            width: 18,
            height: 18,
            color: Colors.black38,
          ),
          SizedBox(width: DesignSystem.spacingMD),
          Expanded(
            child: TextField(
              controller: _timeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '30',
                hintStyle: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textHint,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  vertical: DesignSystem.spacingMD,
                ),
              ),
              style: AppTypography.bodyLarge,
            ),
          ),
          SizedBox(width: DesignSystem.spacingMD),
        ],
      ),
    );
  }

  Widget _buildKeyInput() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(DesignSystem.radiusFull),
        border: Border.all(
          color: Color(0xFFF5F5F5),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          SizedBox(width: DesignSystem.spacingLG),
          SvgPicture.asset(
            'assets/svg/key2.svg',
            width: 10,
            height: 21,
            color: Colors.black26,
          ),
          SizedBox(width: DesignSystem.spacingMD),
          Expanded(
            child: TextField(
              controller: _keyController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '0',
                hintStyle: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textHint,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  vertical: DesignSystem.spacingMD,
                ),
              ),
              style: AppTypography.bodyLarge,
            ),
          ),
          SizedBox(width: DesignSystem.spacingMD),
        ],
      ),
    );
  }

  Widget _buildPriceInput() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(DesignSystem.radiusFull),
        border: Border.all(
          color: Color(0xFFF5F5F5),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          SizedBox(width: DesignSystem.spacingLG),
          SvgPicture.asset(
            'assets/svg/money.svg',
            width: 18,  
            height: 18,
            color: Colors.black12,
          ),
          SizedBox(width: DesignSystem.spacingMD),
          Expanded(
            child: TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              onChanged: _formatPriceOnChange,
              decoration: InputDecoration(
                hintText: '159.000',
                hintStyle: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textHint,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  vertical: DesignSystem.spacingMD,
                ),
              ),
              style: AppTypography.bodyLarge,
            ),
          ),
          SizedBox(width: DesignSystem.spacingMD),
        ],
      ),
    );
  }

  Widget _buildAppSelection() {
    final apps = [
      {'label': 'Quiz', 'key': 'quiz', 'color': Color(0xFF685DFF)},
      {'label': 'Streak', 'key': 'streak', 'color': Color(0xFFFFC11C)},
      {'label': 'Class', 'key': 'class', 'color': Color(0xFF000000)},
      {'label': 'Hack', 'key': 'hack', 'color': Color(0xFFFF59EE)},
      {'label': 'VSTEP', 'key': 'vstep', 'color': Color(0xFF10B981)},
    ];

    return Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: apps.map((app) {
          final appKey = app['key'] as String;
          final isSelected = _selectedApps.contains(appKey);
          final color = app['color'] as Color;
          return Padding(
            padding: EdgeInsets.only(left: DesignSystem.spacingMD),
            child: GestureDetector(
              onTap: () {
                final newSelectedApps = Set<String>.from(_selectedApps);
                String? currentDuration = _selectedDuration;
                
                if (isSelected) {
                  newSelectedApps.remove(appKey);
                } else {
                  newSelectedApps.add(appKey);
                }
                
                // Kiểm tra duration có hợp lệ với combo mới không
                if (newSelectedApps.isNotEmpty && currentDuration != null) {
                  final availableDurations = _getAvailableDurationsForApps(newSelectedApps);
                  final isValid = availableDurations.any((d) => d['key'] == currentDuration);
                  if (!isValid) {
                    currentDuration = null;
                  }
                } else if (newSelectedApps.isEmpty) {
                  currentDuration = null;
                }
                
                setState(() {
                  _selectedApps = newSelectedApps;
                  _selectedDuration = currentDuration;
                });
                
                // Tự động điền giá trị nếu có app và duration được chọn
                if (newSelectedApps.isNotEmpty && currentDuration != null) {
                  // Gọi trực tiếp sau setState
                  Future.microtask(() {
                    if (mounted) {
                      _autoFillValues();
                    }
                  });
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: DesignSystem.spacingMD,
                  vertical: DesignSystem.spacingSM,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? color : color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(DesignSystem.radiusFull),
                ),
                child: Center(
                  child: Text(
                    app['label'] as String,
                    style: AppTypography.bodyMedium.copyWith(
                      color: isSelected ? Colors.white : color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
        ),
      ),
    );
  }

  Widget _buildDurationSelection() {
    final durations = _getAvailableDurations();

    return Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: durations.map((duration) {
          final isSelected = _selectedDuration == duration['key'];
          final isRed = duration['isRed'] as bool;
          final redColor = Color(0xFFFF3B30); // Màu đỏ
          
          return Padding(
            padding: EdgeInsets.only(left: DesignSystem.spacingMD),
            child: GestureDetector(
              onTap: () {
                final newDuration = isSelected ? null : duration['key'] as String;
                setState(() {
                  _selectedDuration = newDuration;
                });
                // Tự động điền giá trị khi chọn duration
                if (_selectedApps.isNotEmpty && newDuration != null) {
                  // Gọi trực tiếp sau setState
                  Future.microtask(() {
                    if (mounted) {
                      _autoFillValues();
                    }
                  });
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: DesignSystem.spacingMD,
                  vertical: DesignSystem.spacingSM,
                ),
                decoration: BoxDecoration(
                  color: isRed 
                      ? Colors.white
                      : (isSelected 
                          ? Color(0x0D000000) // 5% opacity black
                          : Colors.white),
                  border: Border.all(
                    color: isRed 
                        ? redColor
                        : Color(0x0D000000), // 5% opacity black
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(DesignSystem.radiusXL),
                ),
                child: Center(
                  child: Text(
                    duration['label'] as String,
                    style: AppTypography.bodyMedium.copyWith(
                      color: isRed 
                          ? redColor
                          : Colors.black,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
        ),
      ),
    );
  }

  Widget _buildPlanInput() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(DesignSystem.radiusFull),
        border: Border.all(
          color: Color(0xFFF5F5F5),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          SizedBox(width: DesignSystem.spacingLG),
          SvgPicture.asset(
            'assets/svg/content.svg',
            width: 20,
            height: 20,
            color: Colors.black12,
          ),
          SizedBox(width: DesignSystem.spacingMD),
          Expanded(
            child: TextField(
              controller: _planController,
              decoration: InputDecoration(
                hintText: 'Quiz 1 tháng',
                hintStyle: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textHint,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  vertical: DesignSystem.spacingMD,
                ),
              ),
              style: AppTypography.bodyLarge,
            ),
          ),
          SizedBox(width: DesignSystem.spacingMD),
        ],
      ),
    );
  }

  void _handleOptionToggle(String option, bool newValue) {
    // Lưu note hiện tại trước khi thay đổi
    String currentNote = _planController.text.trim();
    
    setState(() {
      // Nếu chọn một option, bỏ chọn các option khác (mutually exclusive)
      if (newValue) {
        _isInstallment = false;
        _isStreakClass = false;
        _isVstep = false;
        
        // Chỉ set option được chọn thành true
        switch (option) {
          case 'Trả góp':
            _isInstallment = true;
            break;
          case 'Lớp Streak':
            _isStreakClass = true;
            break;
          case 'VSTEP':
            _isVstep = true;
            break;
        }
      } else {
        // Nếu bỏ chọn, chỉ set option đó thành false
        switch (option) {
          case 'Trả góp':
            _isInstallment = false;
            break;
          case 'Lớp Streak':
            _isStreakClass = false;
            break;
          case 'VSTEP':
            _isVstep = false;
            break;
        }
      }
    });

    // Auto fill note logic
    String newNote = '';

    if (option == 'Trả góp') {
      if (newValue) {
        // Remove các note từ option khác trước
        String baseNote = currentNote
            .replaceAll('Combo Streak A-Z', '')
            .replaceAll('Tặng TK VSTEP 1 tháng', '')
            .replaceAll(' / Trả góp lần 1/3 - fb', '')
            .trim();
        
        // Append "Trả góp lần 1/3 - fb" vào note hiện tại
        if (baseNote.isNotEmpty) {
          newNote = '$baseNote / Trả góp lần 1/3 - fb';
        } else {
          newNote = 'Trả góp lần 1/3 - fb';
        }
      } else {
        // Remove "Trả góp lần 1/3 - fb" khỏi note
        newNote = currentNote.replaceAll(' / Trả góp lần 1/3 - fb', '').replaceAll('Trả góp lần 1/3 - fb', '').trim();
        // Nếu bắt đầu bằng " / " thì xóa
        if (newNote.startsWith(' / ')) {
          newNote = newNote.substring(3);
        }
        // Gọi lại auto fill nếu có app và duration được chọn
        if (_selectedApps.isNotEmpty && _selectedDuration != null) {
          Future.microtask(() {
            if (mounted) {
              _autoFillValues();
            }
          });
          return;
        }
      }
    } else if (option == 'Lớp Streak') {
      if (newValue) {
        newNote = 'Combo Streak A-Z';
      } else {
        // Nếu note hiện tại là "Combo Streak A-Z" thì gọi lại auto fill để lấy note từ app/duration
        if (currentNote == 'Combo Streak A-Z') {
          // Gọi lại auto fill nếu có app và duration được chọn
          if (_selectedApps.isNotEmpty && _selectedDuration != null) {
            Future.microtask(() {
              if (mounted) {
                _autoFillValues();
              }
            });
            return; // Return sớm vì _autoFillValues sẽ xử lý note
          } else {
            newNote = '';
          }
        } else {
          newNote = currentNote;
        }
      }
    } else if (option == 'VSTEP') {
      if (newValue) {
        newNote = 'Tặng TK VSTEP 1 tháng';
      } else {
        // Nếu note hiện tại là "Tặng TK VSTEP 1 tháng" thì gọi lại auto fill để lấy note từ app/duration
        if (currentNote == 'Tặng TK VSTEP 1 tháng') {
          // Gọi lại auto fill nếu có app và duration được chọn
          if (_selectedApps.isNotEmpty && _selectedDuration != null) {
            Future.microtask(() {
              if (mounted) {
                _autoFillValues();
              }
            });
            return; // Return sớm vì _autoFillValues sẽ xử lý note
          } else {
            newNote = '';
          }
        } else {
          newNote = currentNote;
        }
      }
    }

    setState(() {
      _planController.text = newNote;
    });
  }

  Widget _buildOptionsSelection() {
    return Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildOptionButton('Trả góp', _isInstallment, (value) {
              _handleOptionToggle('Trả góp', value);
            }),
            SizedBox(width: DesignSystem.spacingMD),
            _buildOptionButton('Lớp Streak', _isStreakClass, (value) {
              _handleOptionToggle('Lớp Streak', value);
            }),
            SizedBox(width: DesignSystem.spacingMD),
            _buildOptionButton('VSTEP', _isVstep, (value) {
              _handleOptionToggle('VSTEP', value);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(String label, bool isSelected, Function(bool) onTap) {
    return GestureDetector(
      onTap: () => onTap(!isSelected),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: DesignSystem.spacingMD,
          vertical: DesignSystem.spacingSM,
        ),
        decoration: BoxDecoration(
          color: isSelected 
              ? Colors.black
              : Colors.white,
          border: Border.all(
            color: Color(0x0D000000), // 5% opacity black
            width: 2,
          ),
          borderRadius: BorderRadius.circular(DesignSystem.radiusFull),
        ),
        child: Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildUpgradeButton() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: DesignSystem.spacingLG,
        vertical: DesignSystem.spacingMD,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(DesignSystem.radiusFull),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _handleUpgrade,
            borderRadius: BorderRadius.circular(DesignSystem.radiusFull),
            child: Center(
              child: Text(
                'NÂNG CẤP',
                style: AppTypography.button.copyWith(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleUpgrade() async {
    // Validate input
    final customerPhone = _phoneController.text.trim();
    if (customerPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng nhập số điện thoại'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedApps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng chọn ít nhất một ứng dụng'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedDuration == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng chọn thời hạn'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Get staff phone from profile
    final profileState = ref.read(profileNotifierProvider);
    final profile = profileState.valueOrNull;
    final staffPhone = profile?.phoneNumber ?? profile?.email ?? '';

    // Get values from form
    final timeValue = _timeController.text.trim();
    final priceValue = _priceController.text.trim().replaceAll(RegExp(r'[^\d]'), '');
    final keyValue = _keyController.text.trim();
    final noteValue = _planController.text.trim();

    if (priceValue.isEmpty && _selectedDuration != '0') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng nhập số tiền'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final upgradeService = UpgradeAccountService();
      final hasQuiz = _selectedApps.contains('quiz');
      final hasStreak = _selectedApps.contains('streak');
      final hasClass = _selectedApps.contains('class');
      final hasHack = _selectedApps.contains('hack');
      final hasVstep = _selectedApps.contains('vstep');

      // Determine package type and values
      String packageType = 'lifetime';
      int extendDay = 2200;
      int totalPrice = int.tryParse(priceValue) ?? 0;

      switch (_selectedDuration) {
        case '1':
          packageType = '1month';
          extendDay = 31;
          break;
        case '3':
          packageType = '3months';
          extendDay = 90;
          break;
        case '12':
          packageType = '12months';
          extendDay = 365;
          break;
        case 'forever':
          packageType = 'lifetime';
          extendDay = 2200;
          break;
        case '0':
          extendDay = 0;
          break;
      }

      // Determine transaction type and keys
      String transactionType;
      int transactionKeys = 0;
      
      if (_selectedDuration == '0') {
        transactionType = 'Combo';
      } else {
        switch (packageType) {
          case '1month':
            transactionType = '1 mo';
            break;
          case '3months':
            transactionType = '3 mo';
            break;
          case '12months':
            transactionType = 'YEAR';
            break;
          case 'lifetime':
            if (_selectedApps.length == 1) {
              transactionType = 'MAX';
            } else {
              transactionType = 'Combo';
            }
            if (hasStreak) {
              transactionKeys = 999;
            }
            break;
          default:
            transactionType = 'Combo';
        }
      }

      // Process each app
      bool isFirstTransaction = true;
      for (final app in _selectedApps) {
        if (_selectedDuration == '0') {
          // Reset case - skip upgrade, only create transaction
          continue;
        }

        // Upgrade account
        if (app == 'quiz') {
          // Quiz uses different API
          String actualDay = 'PRO';
          if (packageType == 'lifetime') {
            actualDay = 'MAX';
          }

          final quizResponse = await upgradeService.upgradeQuiz(
            phone: customerPhone,
            numberOfDay: extendDay,
            amount: totalPrice,
            actualDay: actualDay,
          );

          if (!quizResponse.isSuccess) {
            throw Exception('Lỗi nâng cấp Quiz: ${quizResponse.message}');
          }
        } else {
          // Streak, VSTEP, Class, Hack
          String plan = 'YEARLY';
          if (packageType == '1month') {
            plan = 'MONTHLY';
          } else if (packageType == '3months') {
            plan = 'QUARTERLY';
          } else if (packageType == '12months') {
            plan = 'YEARLY';
          } else if (packageType == 'lifetime') {
            plan = 'LIFETIME';
          }

          final upgradeResponse = await upgradeService.upgradeAccount(
            phone: customerPhone,
            numberOfDay: extendDay,
            plan: plan,
            action: app,
          );

          if (!upgradeResponse.isSuccess) {
            throw Exception('Lỗi nâng cấp ${app}: ${upgradeResponse.message}');
          }
        }

        // Create transaction for each app
        // Chỉ set key vào transaction đầu tiên khi có nhiều app (combo)
        int keysForTransaction = 0;
        if (_selectedApps.length > 1) {
          // Combo: chỉ set key vào transaction đầu tiên
          if (isFirstTransaction) {
            // Set key từ keyValue hoặc transactionKeys (Streak lifetime)
            if (keyValue.isNotEmpty && int.tryParse(keyValue) != null && int.parse(keyValue) > 0) {
              keysForTransaction = int.parse(keyValue);
            } else if (transactionKeys > 0) {
              keysForTransaction = transactionKeys;
            }
            isFirstTransaction = false;
          }
        } else {
          // Single app: set key vào transaction nếu có
          if (keyValue.isNotEmpty && int.tryParse(keyValue) != null && int.parse(keyValue) > 0) {
            keysForTransaction = int.parse(keyValue);
          } else if (transactionKeys > 0) {
            keysForTransaction = transactionKeys;
          }
        }

        final transactionResponse = await upgradeService.createTransaction(
          staffPhone: staffPhone,
          customerPhone: customerPhone,
          price: totalPrice,
          extendDay: extendDay,
          keys: keysForTransaction,
          type: transactionType,
          note: noteValue.isNotEmpty ? noteValue : 'Upgrade $app',
        );

        if (!transactionResponse.isSuccess) {
          throw Exception('Lỗi tạo transaction: ${transactionResponse.message}');
        }
      }

      // Apply key if provided - luôn luôn gọi API apply-key-streak nếu có key điền vào
      if (keyValue.isNotEmpty && int.tryParse(keyValue) != null && int.parse(keyValue) > 0) {
        final keyResponse = await upgradeService.applyKeyStreak(
          username: customerPhone,
          amount: int.parse(keyValue),
        );

        if (!keyResponse.isSuccess) {
          throw Exception('Lỗi áp dụng key: ${keyResponse.message}');
        }
      }

      // Close loading
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Nâng cấp thành công'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      // Close loading
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

class SoiInfoWidget extends StatefulWidget {
  final Map<String, dynamic>? userInfo;
  final int? daysSinceCreation;
  final List<dynamic>? activityLogs;
  final Map<String, dynamic>? grade;
  final Map<String, dynamic>? program;
  final List<dynamic>? devices;

  const SoiInfoWidget({
    super.key,
    this.userInfo,
    this.daysSinceCreation,
    this.activityLogs,
    this.grade,
    this.program,
    this.devices,
  });

  @override
  State<SoiInfoWidget> createState() => _SoiInfoWidgetState();
}

class _SoiInfoWidgetState extends State<SoiInfoWidget> {
  bool _isExpanded = false;
  static const int _maxVisibleActivities = 5;

  int _calculateDaysRemaining(int? expireTime) {
    if (expireTime == null) return 0;
    final expireDate = DateTime.fromMillisecondsSinceEpoch(expireTime * 1000);
    final now = DateTime.now();
    final difference = expireDate.difference(now).inDays;
    return difference > 0 ? difference : 0;
  }

  Widget _buildBlock({
    required Widget child,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: DesignSystem.spacingMD),
      padding: EdgeInsets.all(DesignSystem.spacingMD),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Color(0xFFF5F5F5),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(DesignSystem.radiusFull),
      ),
      child: child,
    );
  }

  Widget _buildUserInfoBlock() {
    final userName = widget.userInfo?['fullName'] as String? ?? '';
    final days = widget.daysSinceCreation ?? 0;
    final gradeName = widget.grade?['name'] as String? ?? '';
    final programName = widget.program?['name'] as String? ?? '';
    final university = widget.userInfo?['university'] as String? ?? '';

    return _buildBlock(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dòng 1: Tên user / số ngày hoạt động
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                userName,
                style: AppTypography.bodyMedium.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: DesignSystem.spacingXS),
              Text(
                '/ $days ngày',
                style: AppTypography.bodySmall.copyWith(
                  color: Color(0xFFCCCCCC),
                ),
              ),
            ],
          ),
          SizedBox(height: DesignSystem.spacingSM),
          // Dòng 2: Khoa và năm học
          Wrap(
            spacing: DesignSystem.spacingSM,
            runSpacing: DesignSystem.spacingSM,
            children: [
              if (programName.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: DesignSystem.spacingSM,
                    vertical: DesignSystem.spacingXS,
                  ),
                  decoration: BoxDecoration(
                    color: Color(0x1A2196F3), // 10% opacity
                    borderRadius: BorderRadius.circular(DesignSystem.radiusMD),
                  ),
                  child: Text(
                    programName,
                    style: AppTypography.bodySmall.copyWith(
                      color: Color(0xFF2196F3),
                    ),
                  ),
                ),
              if (gradeName.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: DesignSystem.spacingSM,
                    vertical: DesignSystem.spacingXS,
                  ),
                  decoration: BoxDecoration(
                    color: Color(0x1A2196F3), // 10% opacity
                    borderRadius: BorderRadius.circular(DesignSystem.radiusMD),
                  ),
                  child: Text(
                    gradeName,
                    style: AppTypography.bodySmall.copyWith(
                      color: Color(0xFF2196F3),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: DesignSystem.spacingSM),
          // Dòng 3: Tên trường
          if (university.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: DesignSystem.spacingSM,
                vertical: DesignSystem.spacingXS,
              ),
              decoration: BoxDecoration(
                color: Color(0x1A2196F3), // 10% opacity
                borderRadius: BorderRadius.circular(DesignSystem.radiusSM),
              ),
              child: Text(
                university,
                style: AppTypography.bodySmall.copyWith(
                  color: Color(0xFF2196F3),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPaymentChip({
    required String label,
    required Color color,
    required bool isPaid,
    int? daysRemaining,
  }) {
    if (isPaid) {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: DesignSystem.spacingSM,
          vertical: DesignSystem.spacingXS,
        ),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(DesignSystem.radiusMD),
        ),
        child: Text(
          daysRemaining != null ? '$label $daysRemaining ngày' : label,
          style: AppTypography.bodySmall.copyWith(
            color: Colors.white,
          ),
        ),
      );
    } else {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: DesignSystem.spacingSM,
          vertical: DesignSystem.spacingXS,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: color,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(DesignSystem.radiusMD),
        ),
        child: Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: color,
          ),
        ),
      );
    }
  }

  Widget _buildKeyChip(int keyCount) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: DesignSystem.spacingSM,
        vertical: DesignSystem.spacingXS,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Color(0x1AE05B00), // 10% opacity
          width: 2,
        ),
        borderRadius: BorderRadius.circular(DesignSystem.radiusMD),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            'assets/svg/key.svg',
            width: 12,
            height: 12,
          ),
          SizedBox(width: DesignSystem.spacingXS),
          Text(
            '$keyCount',
            style: AppTypography.bodySmall.copyWith(
              color: Color(0xFFE05B00),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfoBlock() {
    final faQuizInfo = widget.userInfo?['faQuizInfo'] as Map<String, dynamic>?;
    final faClassInfo = widget.userInfo?['faClassInfo'] as Map<String, dynamic>?;
    final faStreakInfo = widget.userInfo?['faStreakInfo'] as Map<String, dynamic>?;
    final faHackInfo = widget.userInfo?['faHackInfo'] as Map<String, dynamic>?;

    final paidApps = <Map<String, dynamic>>[];
    final unpaidApps = <Map<String, dynamic>>[];
    
    // Lấy tổng số key từ userBag trong userInfo
    final userBag = widget.userInfo?['userBag'] as Map<String, dynamic>?;
    final totalKeys = userBag?['key'] as int?;

    // FA Quiz
    if (faQuizInfo != null) {
      final isPaid = faQuizInfo['isPaid'] as bool? ?? false;
      if (isPaid) {
        final expireTime = faQuizInfo['expireTime'] as int?;
        paidApps.add({
          'label': 'Quiz',
          'color': Color(0xFF685DFF),
          'daysRemaining': _calculateDaysRemaining(expireTime),
        });
      } else {
        unpaidApps.add({
          'label': 'Quiz',
          'color': Color(0xFF685DFF),
        });
      }
    }

    // FA Class
    if (faClassInfo != null) {
      final isPaid = faClassInfo['isPaid'] as bool? ?? false;
      if (isPaid) {
        final expireTime = faClassInfo['expireTime'] as int?;
        paidApps.add({
          'label': 'Class',
          'color': Color(0xFF000000),
          'daysRemaining': _calculateDaysRemaining(expireTime),
        });
      } else {
        unpaidApps.add({
          'label': 'Class',
          'color': Color(0xFF000000),
        });
      }
    }

    // FA Streak
    if (faStreakInfo != null) {
      final isPaid = faStreakInfo['isPaid'] as bool? ?? false;
      if (isPaid) {
        final expireTime = faStreakInfo['expireTime'] as int?;
        paidApps.add({
          'label': 'Streak',
          'color': Color(0xFFFFC11C),
          'daysRemaining': _calculateDaysRemaining(expireTime),
        });
      } else {
        unpaidApps.add({
          'label': 'Streak',
          'color': Color(0xFFFFC11C),
        });
      }
    }

    // FA Hack
    if (faHackInfo != null) {
      final isPaid = faHackInfo['isPaid'] as bool? ?? false;
      if (isPaid) {
        final expireTime = faHackInfo['expireTime'] as int?;
        paidApps.add({
          'label': 'Hack',
          'color': Color(0xFFFF59EE),
          'daysRemaining': _calculateDaysRemaining(expireTime),
        });
      } else {
        unpaidApps.add({
          'label': 'Hack',
          'color': Color(0xFFFF59EE),
        });
      }
    }

    // Chỉ hiển thị block nếu có ít nhất 1 trong các phần
    final hasContent = paidApps.isNotEmpty || 
                      unpaidApps.isNotEmpty || 
                      (totalKeys != null && totalKeys > 0) ||
                      (widget.devices != null && widget.devices!.isNotEmpty);
    
    if (!hasContent) return SizedBox.shrink();

    return _buildBlock(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dòng 1: Ứng dụng đã thanh toán
          if (paidApps.isNotEmpty)
            Wrap(
              spacing: DesignSystem.spacingSM,
              runSpacing: DesignSystem.spacingSM,
              children: paidApps.map((app) {
                return _buildPaymentChip(
                  label: app['label'] as String,
                  color: app['color'] as Color,
                  isPaid: true,
                  daysRemaining: app['daysRemaining'] as int?,
                );
              }).toList(),
            ),
          // Dòng 2: Ứng dụng chưa thanh toán + Key
          if (unpaidApps.isNotEmpty || (totalKeys != null && totalKeys > 0)) ...[
            if (paidApps.isNotEmpty) SizedBox(height: DesignSystem.spacingSM),
            Wrap(
              spacing: DesignSystem.spacingSM,
              runSpacing: DesignSystem.spacingSM,
              children: [
                ...unpaidApps.map((app) {
                  return _buildPaymentChip(
                    label: app['label'] as String,
                    color: app['color'] as Color,
                    isPaid: false,
                  );
                }).toList(),
                if (totalKeys != null && totalKeys > 0)
                  _buildKeyChip(totalKeys),
              ],
            ),
          ],
          // Dòng 3: Danh sách thiết bị
          if (widget.devices != null && widget.devices!.isNotEmpty) ...[
            if (paidApps.isNotEmpty || unpaidApps.isNotEmpty || (totalKeys != null && totalKeys > 0))
              SizedBox(height: DesignSystem.spacingSM),
            Wrap(
              spacing: DesignSystem.spacingSM,
              runSpacing: DesignSystem.spacingSM,
              children: widget.devices!.map((device) {
                final deviceName = device['deviceName'] as String? ?? '';
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: DesignSystem.spacingSM,
                    vertical: DesignSystem.spacingXS,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: Color(0xFFF5F5F5),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(DesignSystem.radiusMD),
                  ),
                  child: Text(
                    deviceName,
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.black,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  String _formatFriendlyTime(String? createdAt) {
    if (createdAt == null || createdAt.isEmpty) return '';
    
    try {
      // Thử parse nhiều format khác nhau
      DateTime? dateTime;
      
      // Format ISO 8601: "2024-01-15T10:30:00Z" hoặc "2024-01-15T10:30:00.000Z"
      if (createdAt.contains('T')) {
        dateTime = DateTime.tryParse(createdAt);
      }
      // Format: "2024-01-15 10:30:00"
      else if (createdAt.contains(' ')) {
        dateTime = DateFormat('yyyy-MM-dd HH:mm:ss').tryParse(createdAt);
      }
      // Format: "15/01/2024 10:30"
      else if (createdAt.contains('/')) {
        dateTime = DateFormat('dd/MM/yyyy HH:mm').tryParse(createdAt);
      }
      
      if (dateTime == null) return createdAt;
      
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      
      // Nếu trong cùng ngày, chỉ hiển thị giờ
      if (difference.inDays == 0) {
        if (difference.inHours == 0) {
          if (difference.inMinutes == 0) {
            return 'Vừa xong';
          }
          return '${difference.inMinutes} phút trước';
        }
        return '${difference.inHours} giờ trước';
      }
      // Nếu trong cùng tuần
      else if (difference.inDays < 7) {
        return '${difference.inDays} ngày trước';
      }
      // Nếu trong cùng tháng
      else if (difference.inDays < 30) {
        final weeks = (difference.inDays / 7).floor();
        return '$weeks tuần trước';
      }
      // Nếu trong cùng năm
      else if (difference.inDays < 365) {
        final months = (difference.inDays / 30).floor();
        return '$months tháng trước';
      }
      // Quá 1 năm
      else {
        return DateFormat('dd/MM/yyyy').format(dateTime);
      }
    } catch (e) {
      return createdAt;
    }
  }

  Widget _buildActivityLogsBlock() {
    final logs = widget.activityLogs ?? [];
    if (logs.isEmpty) return SizedBox.shrink();

    // Sắp xếp từ mới nhất đến cũ nhất (giả sử logs đã được sắp xếp từ API, nếu không thì reverse)
    final sortedLogs = List.from(logs);
    
    final displayLogs = _isExpanded
        ? sortedLogs
        : sortedLogs.take(_maxVisibleActivities).toList();

    return _buildBlock(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...displayLogs.map((log) {
            final createdAt = log['createdAt'] as String? ?? '';
            final actionDescription = log['actionDescription'] as String? ?? '';
            final friendlyTime = _formatFriendlyTime(createdAt);
            return Padding(
              padding: EdgeInsets.only(bottom: DesignSystem.spacingXS),
              child: Text(
                actionDescription.isNotEmpty
                    ? '$actionDescription • $friendlyTime'
                    : friendlyTime,
                style: AppTypography.bodySmall.copyWith(
                  color: Colors.black,
                ),
              ),
            );
          }).toList(),
          if (logs.length > _maxVisibleActivities && !_isExpanded)
            GestureDetector(
              onTap: () {
                setState(() {
                  _isExpanded = true;
                });
              },
              child: Padding(
                padding: EdgeInsets.only(top: DesignSystem.spacingXS),
                child: Center(
                  child: Text(
                    'Xem thêm',
                    style: AppTypography.bodySmall.copyWith(
                      color: Color(0xFF685DFF),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Lấy width từ constraints để đảm bảo tất cả block có cùng width
        final blockWidth = constraints.maxWidth;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: blockWidth,
              child: _buildUserInfoBlock(),
            ),
            SizedBox(
              width: blockWidth,
              child: _buildPaymentInfoBlock(),
            ),
            SizedBox(
              width: blockWidth,
              child: _buildActivityLogsBlock(),
            ),
          ],
        );
      },
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
    Future.delayed(const Duration(milliseconds: 200), () {
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

