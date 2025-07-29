import 'package:auto_saver/models/app_state.dart';
import 'package:auto_saver/widgets/app_selector.dart';
import 'package:auto_saver/widgets/log_panel.dart';
import 'package:auto_saver/screens/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tremo Save',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: state.isDarkMode ? Colors.grey[900] : Colors.grey[900],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Dark mode toggle
          IconButton(
            icon: Icon(
              state.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: state.isDarkMode ? Colors.yellow[300] : Colors.white,
            ),
            onPressed: () => state.toggleDarkMode(),
            tooltip: state.isDarkMode ? 'Chuyển sang chế độ sáng' : 'Chuyển sang chế độ tối',
          ),
          // Show logs toggle
          IconButton(
            icon: Icon(
              Icons.history,
              color: state.showLogs ? Colors.blue[300] : Colors.white,
            ),
            onPressed: () => state.toggleLogs(),
            tooltip: 'Hiển thị lịch sử lưu',
          ),
                           // Refresh button
                 IconButton(
                   icon: const Icon(Icons.refresh),
                   onPressed: () => state.loadApplications(),
                   tooltip: 'Làm mới danh sách ứng dụng',
                 ),
                 // Settings button
                 IconButton(
                   icon: const Icon(Icons.settings),
                   onPressed: () {
                     Navigator.push(
                       context,
                       MaterialPageRoute(
                         builder: (context) => const SettingsPage(),
                       ),
                     );
                   },
                   tooltip: 'Cài đặt',
                 ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: state.isDarkMode 
                ? [
                    Colors.grey[900]!,
                    Colors.grey[850]!,
                  ]
                : [
                    Colors.grey[900]!,
                    Colors.grey[100]!,
                  ],
            stops: const [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: state.isDarkMode ? Colors.grey[850] : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.auto_fix_high,
                            size: 28,
                            color: state.isDarkMode ? Colors.blue[400] : Colors.blue[600],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Tự động lưu ứng dụng',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: state.isDarkMode ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Chọn các ứng dụng bạn muốn tự động lưu và thiết lập thời gian lưu',
                        style: TextStyle(
                          fontSize: 14,
                          color: state.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // App Selector
                const AppSelector(),
                
                const SizedBox(height: 24),
                
                // Settings section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: state.isDarkMode ? Colors.grey[850] : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.settings,
                            size: 24,
                            color: state.isDarkMode ? Colors.orange[400] : Colors.orange[600],
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Cài đặt',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: state.isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Interval setting
                      Row(
                        children: [
                          Icon(
                            Icons.timer,
                            size: 20,
                            color: state.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Thời gian lưu tự động:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: state.isDarkMode ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: state.isDarkMode ? Colors.blue[900]!.withOpacity(0.3) : Colors.blue[50],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: state.isDarkMode ? Colors.blue[600]! : Colors.blue[200]!,
                              ),
                            ),
                            child: Text(
                              '${state.interval} phút',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: state.isDarkMode ? Colors.blue[300] : Colors.blue[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: state.isDarkMode ? Colors.blue[400] : Colors.blue[600],
                          inactiveTrackColor: state.isDarkMode ? Colors.grey[700] : Colors.grey[300],
                          thumbColor: state.isDarkMode ? Colors.blue[400] : Colors.blue[600],
                          overlayColor: state.isDarkMode ? Colors.blue[200] : Colors.blue[200],
                          valueIndicatorColor: state.isDarkMode ? Colors.blue[400] : Colors.blue[600],
                          valueIndicatorTextStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: Slider(
                          min: 1,
                          max: 60,
                          divisions: 59,
                          value: state.interval.toDouble(),
                          label: '${state.interval} phút',
                          onChanged: (value) {
                            state.setInterval(value);
                          },
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Only active window option
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: state.isDarkMode ? Colors.grey[800] : Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: state.isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
                          ),
                        ),
                        child: CheckboxListTile(
                          title: Text(
                            'Chỉ lưu khi cửa sổ ứng dụng đang hoạt động',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: state.isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                          subtitle: Text(
                            'Tự động lưu chỉ khi bạn đang làm việc với ứng dụng',
                            style: TextStyle(
                              fontSize: 12,
                              color: state.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                          value: state.onlyActiveWindow,
                          onChanged: (value) {
                            state.setOnlyActiveWindow(value);
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                          activeColor: state.isDarkMode ? Colors.blue[400] : Colors.blue[600],
                          checkColor: state.isDarkMode ? Colors.white : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Log Panel
                const LogPanel(),
                
                const SizedBox(height: 24),
                
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: state.isRunning 
                              ? (state.isDarkMode ? Colors.red[700] : Colors.red[600])
                              : (state.isDarkMode ? Colors.green[700] : Colors.green[600]),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                        onPressed: state.selectedApplications.isEmpty
                            ? null
                            : () {
                                if (state.isRunning) {
                                  state.stopAutoSave();
                                } else {
                                  state.startAutoSave();
                                }
                              },
                        icon: Icon(
                          state.isRunning ? Icons.stop : Icons.play_arrow,
                          size: 24,
                        ),
                        label: Text(
                          state.isRunning ? 'Dừng tự động lưu' : 'Bắt đầu tự động lưu',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                if (state.selectedApplications.isEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: state.isDarkMode ? Colors.orange[900]!.withOpacity(0.3) : Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: state.isDarkMode ? Colors.orange[700]! : Colors.orange[200]!,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 20,
                          color: state.isDarkMode ? Colors.orange[300] : Colors.orange[700],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Vui lòng chọn ít nhất một ứng dụng để bắt đầu',
                            style: TextStyle(
                              fontSize: 14,
                              color: state.isDarkMode ? Colors.orange[300] : Colors.orange[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
