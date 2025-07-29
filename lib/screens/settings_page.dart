import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:auto_saver/models/app_state.dart';
import 'package:auto_saver/services/auto_start_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isAutoStartEnabled = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAutoStartStatus();
  }

  Future<void> _checkAutoStartStatus() async {
    try {
      final isEnabled = await AutoStartService.isAutoStartEnabled();
      setState(() {
        _isAutoStartEnabled = isEnabled;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cài đặt',
          style: TextStyle(fontSize: isSmallScreen ? 16 : 18),
        ),
        backgroundColor: state.isDarkMode ? Colors.grey[900] : Colors.grey[900],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        color: state.isDarkMode ? Colors.grey[900] : Colors.white,
        child: ListView(
          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
          children: [
            // Auto Save Settings
            _buildSection(
              context,
              title: 'Cài đặt Auto Save',
              children: [
                _buildSliderTile(
                  context,
                  title: 'Thời gian lưu tự động',
                  subtitle: '${state.interval} phút',
                  value: state.interval.toDouble(),
                  min: 1,
                  max: 60,
                  onChanged: (value) => state.setInterval(value),
                ),
                _buildSwitchTile(
                  context,
                  title: 'Chỉ lưu cửa sổ đang hoạt động',
                  subtitle: 'Chỉ lưu khi ứng dụng đang được focus',
                  value: state.onlyActiveWindow,
                  onChanged: (value) => state.setOnlyActiveWindow(value),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // System Settings
            _buildSection(
              context,
              title: 'Cài đặt hệ thống',
              children: [
                _buildSwitchTile(
                  context,
                  title: 'Tự động chạy khi khởi động Windows',
                  subtitle: _isLoading 
                      ? 'Đang kiểm tra...'
                      : _isAutoStartEnabled 
                          ? 'Đã bật auto-start trong Windows'
                          : 'Chưa bật auto-start trong Windows',
                  value: state.autoRun,
                  onChanged: (value) async {
                    state.setAutoRun(value);
                    // Cập nhật trạng thái sau khi thay đổi
                    await Future.delayed(const Duration(milliseconds: 500));
                    _checkAutoStartStatus();
                  },
                ),
                _buildSwitchTile(
                  context,
                  title: 'Ẩn vào system tray',
                  subtitle: 'Ứng dụng sẽ ẩn vào khay hệ thống khi minimize',
                  value: state.minimizeToTray,
                  onChanged: (value) => state.setMinimizeToTray(value),
                ),
                                     _buildSwitchTile(
                       context,
                       title: 'Hiển thị thông báo',
                       subtitle: 'Hiển thị notification khi auto save',
                       value: state.showNotifications,
                       onChanged: (value) => state.setShowNotifications(value),
                     ),
                     _buildSwitchTile(
                       context,
                       title: 'Sử dụng Windows notification',
                       subtitle: 'Sử dụng notification bar thay vì popup',
                       value: state.useWindowsNotification,
                       onChanged: (value) => state.setUseWindowsNotification(value),
                     ),
              ],
            ),
            const SizedBox(height: 24),

            // Theme Settings
            _buildSection(
              context,
              title: 'Giao diện',
              children: [
                _buildSwitchTile(
                  context,
                  title: 'Chế độ tối',
                  subtitle: 'Sử dụng giao diện tối',
                  value: state.isDarkMode,
                  onChanged: (value) => state.toggleDarkMode(),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // About Section
            _buildSection(
              context,
              title: 'Thông tin',
              children: [
                ListTile(
                  title: Text(
                    'Phiên bản',
                    style: TextStyle(
                      color: state.isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    '1.0.0',
                    style: TextStyle(
                      color: state.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ),
                ListTile(
                  title: Text(
                    'Nhà phát triển',
                    style: TextStyle(
                      color: state.isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    'Tremowaves',
                    style: TextStyle(
                      color: state.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ),
                ListTile(
                  title: Text(
                    'Website',
                    style: TextStyle(
                      color: state.isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    'https://tremowaves.com',
                    style: TextStyle(
                      color: Colors.blue[400],
                    ),
                  ),
                  onTap: () {
                    // TODO: Open website
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    final state = context.watch<AppState>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: state.isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: state.isDarkMode ? Colors.grey[800] : Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final state = context.watch<AppState>();

    return SwitchListTile(
      title: Text(
        title,
        style: TextStyle(
          color: state.isDarkMode ? Colors.white : Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: state.isDarkMode ? Colors.grey[400] : Colors.grey[600],
        ),
      ),
      value: value,
      onChanged: (bool? newValue) => onChanged(newValue ?? false),
      activeColor: Colors.blue[600],
    );
  }

  Widget _buildSliderTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    final state = context.watch<AppState>();

    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          color: state.isDarkMode ? Colors.white : Colors.black87,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subtitle,
            style: TextStyle(
              color: state.isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: (max - min).toInt(),
            onChanged: onChanged,
            activeColor: Colors.blue[600],
            inactiveColor: state.isDarkMode ? Colors.grey[700] : Colors.grey[300],
          ),
        ],
      ),
    );
  }

} 