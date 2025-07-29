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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    
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
            padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
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
                      size: isSmallScreen ? 18 : 20, 
                      color: state.isDarkMode ? Colors.white70 : Colors.grey,
                    ),
                    SizedBox(width: isSmallScreen ? 6 : 8),
                    Expanded(
                      child: Text(
                        'Chọn ứng dụng cần tự động lưu:',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 12 : 14,
                          fontWeight: FontWeight.w600,
                          color: state.isDarkMode ? Colors.white70 : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Search box
                Container(
                  decoration: BoxDecoration(
                    color: state.isDarkMode ? Colors.grey[700] : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: state.isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                    style: TextStyle(
                      fontSize: 14,
                      color: state.isDarkMode ? Colors.white : Colors.black87,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm ứng dụng...',
                      hintStyle: TextStyle(
                        color: state.isDarkMode ? Colors.grey[400] : Colors.grey[500],
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: state.isDarkMode ? Colors.grey[400] : Colors.grey[500],
                        size: 20,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: state.isDarkMode ? Colors.grey[400] : Colors.grey[500],
                                size: 20,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
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
                        child: _buildApplicationsList(state),
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
                      _buildSelectionText(state),
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

  Widget _buildApplicationsList(AppState state) {
    // Lọc ứng dụng theo từ khóa tìm kiếm
    final filteredApps = state.applications.where((app) {
      if (_searchQuery.isEmpty) return true;
      return app.name.toLowerCase().contains(_searchQuery) ||
             app.processName.toLowerCase().contains(_searchQuery);
    }).toList();

    if (state.applications.isEmpty) {
      return Center(
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
      );
    }

    if (filteredApps.isEmpty && _searchQuery.isNotEmpty) {
      return Center(
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
              'Không tìm thấy ứng dụng nào phù hợp',
              style: TextStyle(
                color: state.isDarkMode ? Colors.grey[500] : Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Thử tìm kiếm với từ khóa khác',
              style: TextStyle(
                fontSize: 12,
                color: state.isDarkMode ? Colors.grey[600] : Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(8),
        itemCount: filteredApps.length,
        itemBuilder: (context, index) {
          final app = filteredApps[index];
          // Tìm index thực tế trong danh sách gốc để toggle đúng
          final originalIndex = state.applications.indexOf(app);
          
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
                _buildSubtitleText(app.processName),
                style: TextStyle(
                  fontSize: 11,
                  color: state.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
                overflow: TextOverflow.ellipsis,
              ),
              value: app.isSelected,
              onChanged: (_) => state.toggleApplicationSelection(originalIndex),
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
         );
   }

   String _buildSelectionText(AppState state) {
     // Lọc ứng dụng theo từ khóa tìm kiếm
     final filteredApps = state.applications.where((app) {
       if (_searchQuery.isEmpty) return true;
       return app.name.toLowerCase().contains(_searchQuery) ||
              app.processName.toLowerCase().contains(_searchQuery);
     }).toList();

     // Đếm số ứng dụng đã chọn trong danh sách được lọc
     final selectedInFiltered = filteredApps.where((app) => app.isSelected).length;

     if (_searchQuery.isEmpty) {
       return 'Đã chọn ${state.selectedApplications.length}/${state.applications.length} ứng dụng';
     } else {
       return 'Đã chọn $selectedInFiltered/${filteredApps.length} ứng dụng (đã lọc)';
     }
   }

   String _buildSubtitleText(String processNames) {
     final processes = processNames.split(', ');
     if (processes.length == 1) {
       return processes[0];
     } else {
       return '${processes.length} processes: ${processes.take(2).join(', ')}${processes.length > 2 ? '...' : ''}';
     }
   }
} 