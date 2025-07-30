// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'Tremo Save';

  @override
  String get welcomeTitle => 'Tự động lưu thông minh';

  @override
  String get welcomeSubtitle => 'Quản lý và bảo vệ công việc của bạn';

  @override
  String get welcomeDescription => 'Chọn các ứng dụng bạn muốn tự động lưu. Hệ thống sẽ theo dõi và lưu công việc khi bạn đang sử dụng các ứng dụng đã chọn.';

  @override
  String get selectApps => 'Chọn ứng dụng';

  @override
  String get autoSaveSettings => 'Cài đặt tự động lưu';

  @override
  String get saveInterval => 'Khoảng thời gian lưu tự động:';

  @override
  String minutes(int count) {
    return '$count phút';
  }

  @override
  String get startAutoSave => 'Bắt đầu tự động lưu';

  @override
  String get stopAutoSave => 'Dừng tự động lưu';

  @override
  String get applications => 'Ứng dụng';

  @override
  String get interval => 'Khoảng thời gian';

  @override
  String get status => 'Trạng thái';

  @override
  String get active => 'Hoạt động';

  @override
  String get paused => 'Tạm dừng';

  @override
  String get saveHistory => 'Lịch sử lưu tự động';

  @override
  String get latestTime => 'Thời gian gần nhất';

  @override
  String get appName => 'Tên ứng dụng';

  @override
  String get clearAllLogs => 'Xóa tất cả log';

  @override
  String get noSaveHistory => 'Chưa có lịch sử lưu';

  @override
  String get success => 'Thành công';

  @override
  String get error => 'Lỗi';

  @override
  String totalSaves(int count) {
    return 'Tổng cộng $count lần lưu';
  }

  @override
  String successCount(int success, int error) {
    return '$success thành công, $error lỗi';
  }

  @override
  String get selectAtLeastOneApp => 'Vui lòng chọn ít nhất một ứng dụng để bắt đầu tự động lưu';

  @override
  String get toggleDarkMode => 'Chuyển sang chế độ sáng';

  @override
  String get toggleLightMode => 'Chuyển sang chế độ tối';

  @override
  String get showSaveHistory => 'Hiển thị lịch sử lưu';

  @override
  String get refreshApps => 'Làm mới danh sách ứng dụng';

  @override
  String get settings => 'Cài đặt';

  @override
  String get testSaveAfter5s => 'Test Save After 5s';

  @override
  String get testNotifications => 'Test Notifications';

  @override
  String get startingTest => 'Starting 5-second test. Switch to target application now!';

  @override
  String get testingNotifications => 'Testing notification system...';
}
