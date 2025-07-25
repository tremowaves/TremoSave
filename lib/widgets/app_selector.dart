import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:auto_saver/models/app_state.dart';

class AppSelector extends StatefulWidget {
  const AppSelector({super.key});

  @override
  State<AppSelector> createState() => _AppSelectorState();
}

class _AppSelectorState extends State<AppSelector> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: state.isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header với nút Select All/Deselect All
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: state.isDarkMode ? Colors.grey[800] : Colors.grey[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.apps, 
                      size: 20, 
                      color: state.isDarkMode ? Colors.white70 : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Chọn ứng dụng cần tự động lưu:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: state.isDarkMode ? Colors.white70 : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: TextButton(
                        onPressed: () => state.selectAllApplications(),
                        child: Text(
                          'Chọn tất cả',
                          style: TextStyle(
                            fontSize: 12,
                            color: state.isDarkMode ? Colors.blue[300] : Colors.blue[600],
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      child: TextButton(
                        onPressed: () => state.deselectAllApplications(),
                        child: Text(
                          'Bỏ chọn tất cả',
                          style: TextStyle(
                            fontSize: 12,
                            color: state.isDarkMode ? Colors.blue[300] : Colors.blue[600],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Danh sách ứng dụng với scroll
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: state.isDarkMode ? Colors.grey[900] : Colors.white,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: state.applications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off, 
                          size: 48, 
                          color: state.isDarkMode ? Colors.grey[600] : Colors.grey,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Không tìm thấy ứng dụng nào',
                          style: TextStyle(
                            color: state.isDarkMode ? Colors.grey[500] : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : Scrollbar(
                    controller: _scrollController,
                    thumbVisibility: true,
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(8),
                      itemCount: state.applications.length,
                      itemBuilder: (context, index) {
                        final app = state.applications[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          decoration: BoxDecoration(
                            color: app.isSelected 
                                ? (state.isDarkMode ? Colors.blue[900]!.withOpacity(0.3) : Colors.blue[50])
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                            border: app.isSelected 
                                ? Border.all(
                                    color: state.isDarkMode ? Colors.blue[600]! : Colors.blue[200]!,
                                  )
                                : null,
                          ),
                          child: CheckboxListTile(
                            title: Text(
                              app.name,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: app.isSelected 
                                    ? FontWeight.w600 
                                    : FontWeight.normal,
                                color: app.isSelected 
                                    ? (state.isDarkMode ? Colors.blue[300] : Colors.blue[700])
                                    : (state.isDarkMode ? Colors.white : Colors.grey[800]),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              app.processName,
                              style: TextStyle(
                                fontSize: 11,
                                color: state.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            value: app.isSelected,
                            onChanged: (_) => state.toggleApplicationSelection(index),
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            dense: true,
                            checkboxShape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            activeColor: state.isDarkMode ? Colors.blue[400] : Colors.blue[600],
                            checkColor: state.isDarkMode ? Colors.white : Colors.white,
                          ),
                        );
                      },
                    ),
                  ),
          ),
          
          // Thông tin số lượng ứng dụng đã chọn
          if (state.applications.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: state.isDarkMode ? Colors.grey[800] : Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: state.selectedApplications.isNotEmpty 
                        ? (state.isDarkMode ? Colors.green[400] : Colors.green)
                        : (state.isDarkMode ? Colors.grey[600] : Colors.grey),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Đã chọn ${state.selectedApplications.length}/${state.applications.length} ứng dụng',
                      style: TextStyle(
                        fontSize: 12,
                        color: state.selectedApplications.isNotEmpty 
                            ? (state.isDarkMode ? Colors.green[300] : Colors.green[700])
                            : (state.isDarkMode ? Colors.grey[500] : Colors.grey[600]),
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
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