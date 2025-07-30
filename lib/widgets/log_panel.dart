import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tremo_save/models/app_state.dart';

class LogPanel extends StatelessWidget {
  const LogPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    
    if (!state.showLogs) {
      return const SizedBox.shrink();
    }
    
    return Container(
      margin: const EdgeInsets.only(top: 12),
      height: 180,
      decoration: BoxDecoration(
        color: state.isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: state.isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
                     Container(
             padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: state.isDarkMode ? Colors.grey[800] : Colors.grey[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.history,
                  size: 20,
                  color: state.isDarkMode ? Colors.white70 : Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Lịch sử lưu tự động',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: state.isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                
                // Sort dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: state.isDarkMode ? Colors.grey[700] : Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: state.isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
                    ),
                  ),
                  child: DropdownButton<LogSortType>(
                    value: state.currentSortType,
                    underline: const SizedBox(),
                    icon: Icon(
                      Icons.sort,
                      size: 16,
                      color: state.isDarkMode ? Colors.white70 : Colors.grey[600],
                    ),
                    dropdownColor: state.isDarkMode ? Colors.grey[800] : Colors.white,
                    style: TextStyle(
                      color: state.isDarkMode ? Colors.white : Colors.black87,
                      fontSize: 12,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: LogSortType.time,
                        child: Text('Thời gian gần nhất'),
                      ),
                      DropdownMenuItem(
                        value: LogSortType.appName,
                        child: Text('Tên ứng dụng'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        state.setLogSortType(value);
                      }
                    },
                  ),
                ),
                
                const SizedBox(width: 8),
                
                // Clear logs button
                IconButton(
                  onPressed: state.saveLogs.isEmpty ? null : state.clearLogs,
                  icon: Icon(
                    Icons.clear_all,
                    size: 20,
                    color: state.saveLogs.isEmpty 
                        ? (state.isDarkMode ? Colors.grey[600] : Colors.grey[400])
                        : (state.isDarkMode ? Colors.red[300] : Colors.red[600]),
                  ),
                  tooltip: 'Xóa tất cả log',
                ),
              ],
            ),
          ),
          
          // Log list
          Expanded(
            child: state.saveLogs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history_toggle_off,
                          size: 48,
                          color: state.isDarkMode ? Colors.grey[600] : Colors.grey[400],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Chưa có lịch sử lưu',
                          style: TextStyle(
                            color: state.isDarkMode ? Colors.grey[500] : Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: state.sortedLogs.length,
                    itemBuilder: (context, index) {
                      final log = state.sortedLogs[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        decoration: BoxDecoration(
                          color: log.success
                              ? (state.isDarkMode ? Colors.green[900]!.withOpacity(0.3) : Colors.green[50])
                              : (state.isDarkMode ? Colors.red[900]!.withOpacity(0.3) : Colors.red[50]),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: log.success
                                ? (state.isDarkMode ? Colors.green[700]! : Colors.green[200]!)
                                : (state.isDarkMode ? Colors.red[700]! : Colors.red[200]!),
                            width: 1,
                          ),
                        ),
                        child: ListTile(
                          leading: Icon(
                            log.success ? Icons.check_circle : Icons.error,
                            color: log.success
                                ? (state.isDarkMode ? Colors.green[400] : Colors.green[600])
                                : (state.isDarkMode ? Colors.red[400] : Colors.red[600]),
                            size: 20,
                          ),
                          title: Text(
                            log.appName,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: state.isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                          subtitle: Text(
                            log.fullDateTime,
                            style: TextStyle(
                              fontSize: 11,
                              color: state.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: log.success
                                  ? (state.isDarkMode ? Colors.green[800] : Colors.green[100])
                                  : (state.isDarkMode ? Colors.red[800] : Colors.red[100]),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              log.success ? 'Thành công' : 'Lỗi',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: log.success
                                    ? (state.isDarkMode ? Colors.green[300] : Colors.green[700])
                                    : (state.isDarkMode ? Colors.red[300] : Colors.red[700]),
                              ),
                            ),
                          ),
                          dense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                        ),
                      );
                    },
                  ),
          ),
          
          // Footer with log count
          if (state.saveLogs.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: state.isDarkMode ? Colors.grey[800] : Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: state.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tổng cộng ${state.saveLogs.length} lần lưu',
                      style: TextStyle(
                        fontSize: 12,
                        color: state.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    '${state.saveLogs.where((log) => log.success).length} thành công, ${state.saveLogs.where((log) => !log.success).length} lỗi',
                    style: TextStyle(
                      fontSize: 12,
                      color: state.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
} 