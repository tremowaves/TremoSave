import 'package:tremo_save/models/app_state.dart';
import 'package:tremo_save/widgets/app_selector.dart';
import 'package:tremo_save/widgets/log_panel.dart';
import 'package:tremo_save/screens/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    
    _fadeController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: state.isDarkMode ? Brightness.dark : Brightness.light,
        ).copyWith(
          surface: state.isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFFAFAFA),
          primary: const Color(0xFF6366F1),
          secondary: const Color(0xFF06B6D4),
        ),
      ),
             child: Scaffold(
         backgroundColor: state.isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFFAFAFA),
         appBar: _buildAppBar(context, state, isSmallScreen),
                   body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 8 : 16,
              vertical: 12,
            ),
           child: FadeTransition(
             opacity: _fadeAnimation,
             child: ScaleTransition(
               scale: _scaleAnimation,
               child: Column(
                                   children: [
                    _buildWelcomeCard(state, isSmallScreen),
                    const SizedBox(height: 12),
                    _buildQuickStats(state, isSmallScreen),
                    const SizedBox(height: 12),
                    _buildAppSelectorCard(state, isSmallScreen),
                    const SizedBox(height: 12),
                    _buildSettingsCard(state, isSmallScreen),
                    const SizedBox(height: 12),
                    const LogPanel(),
                    const SizedBox(height: 12),
                    _buildActionButton(state, isSmallScreen),
                    if (state.selectedApplications.isEmpty)
                      _buildInfoBanner(state, isSmallScreen),
                    const SizedBox(height: 12),
                  ],
               ),
             ),
           ),
         ),
       ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, AppState state, bool isSmallScreen) {
    return AppBar(
      elevation: 4,
      backgroundColor: state.isDarkMode ? const Color(0xFF0F172A) : const Color(0xFF1E293B),
      foregroundColor: Colors.white,
      title: Text(
        'Tremo Save',
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: isSmallScreen ? 20 : 24,
          letterSpacing: -0.5,
          color: Colors.white,
          shadows: [
            Shadow(
              offset: const Offset(0, 1),
              blurRadius: 2,
              color: Colors.black.withOpacity(0.3),
            ),
          ],
        ),
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: state.isDarkMode
                ? [
                    const Color(0xFF0F172A),
                    const Color(0xFF1E293B),
                  ]
                : [
                    const Color(0xFF1E293B),
                    const Color(0xFF334155),
                  ],
          ),
        ),
      ),
      actions: [
        _buildAppBarButton(
          icon: state.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          color: state.isDarkMode ? const Color(0xFFFDBA74) : Colors.white70,
          onPressed: state.toggleDarkMode,
          tooltip: state.isDarkMode ? 'Chuyển sang chế độ sáng' : 'Chuyển sang chế độ tối',
          isSmallScreen: isSmallScreen,
        ),
        _buildAppBarButton(
          icon: Icons.history_rounded,
          color: state.showLogs ? const Color(0xFF06B6D4) : Colors.white70,
          onPressed: state.toggleLogs,
          tooltip: 'Hiển thị lịch sử lưu',
          isSmallScreen: isSmallScreen,
        ),
        _buildAppBarButton(
          icon: Icons.refresh_rounded,
          color: Colors.white70,
          onPressed: state.refreshApplications,
          tooltip: 'Làm mới danh sách ứng dụng',
          isSmallScreen: isSmallScreen,
        ),
        _buildAppBarButton(
          icon: Icons.settings_rounded,
          color: Colors.white70,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SettingsPage()),
          ),
          tooltip: 'Cài đặt',
          isSmallScreen: isSmallScreen,
        ),
        _buildAppBarButton(
          icon: Icons.timer,
          color: Colors.orange[300]!,
          onPressed: () async {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Starting 5-second test. Switch to target application now!'),
                duration: Duration(seconds: 3),
                backgroundColor: Colors.orange,
              ),
            );
            await state.testSaveAfter5Seconds();
          },
          tooltip: 'Test Save After 5s',
          isSmallScreen: isSmallScreen,
        ),
        _buildAppBarButton(
          icon: Icons.notifications,
          color: Colors.blue[300]!,
          onPressed: () async {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Testing notification system...'),
                duration: Duration(seconds: 2),
                backgroundColor: Colors.blue,
              ),
            );
            await state.testNotificationSystem();
          },
          tooltip: 'Test Notifications',
          isSmallScreen: isSmallScreen,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildAppBarButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required String tooltip,
    required bool isSmallScreen,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Icon(
              icon,
              size: isSmallScreen ? 20 : 22,
              color: color,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(AppState state, bool isSmallScreen) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: state.isDarkMode
              ? [
                  const Color(0xFF6366F1).withOpacity(0.1),
                  const Color(0xFF06B6D4).withOpacity(0.1),
                ]
              : [
                  const Color(0xFF6366F1).withOpacity(0.05),
                  const Color(0xFF06B6D4).withOpacity(0.05),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: state.isDarkMode 
              ? const Color(0xFF6366F1).withOpacity(0.2)
              : const Color(0xFF6366F1).withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tự động lưu thông minh',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 18 : 20,
                        fontWeight: FontWeight.w700,
                        color: state.isDarkMode ? Colors.white : const Color(0xFF1E293B),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Quản lý và bảo vệ công việc của bạn',
                      style: TextStyle(
                        fontSize: 14,
                        color: state.isDarkMode 
                            ? const Color(0xFF94A3B8) 
                            : const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Chọn các ứng dụng bạn muốn tự động lưu. Hệ thống sẽ theo dõi và lưu công việc khi bạn đang sử dụng các ứng dụng đã chọn.',
            style: TextStyle(
              fontSize: 14,
              color: state.isDarkMode 
                  ? const Color(0xFF94A3B8) 
                  : const Color(0xFF64748B),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(AppState state, bool isSmallScreen) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.apps_rounded,
            label: 'Ứng dụng',
            value: '${state.selectedApplications.length}',
            color: const Color(0xFF06B6D4),
            state: state,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.timer_rounded,
            label: 'Khoảng thời gian',
            value: '${state.interval}m',
            color: const Color(0xFF10B981),
            state: state,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: state.isRunning ? Icons.play_circle_rounded : Icons.pause_circle_rounded,
            label: 'Trạng thái',
            value: state.isRunning ? 'Hoạt động' : 'Tạm dừng',
            color: state.isRunning ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
            state: state,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required AppState state,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: state.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: state.isDarkMode 
              ? const Color(0xFF334155) 
              : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: state.isDarkMode ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: state.isDarkMode 
                  ? const Color(0xFF94A3B8) 
                  : const Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAppSelectorCard(AppState state, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: state.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: state.isDarkMode 
              ? const Color(0xFF334155) 
              : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF06B6D4).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.apps_rounded,
                  color: Color(0xFF06B6D4),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Chọn ứng dụng',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: state.isDarkMode ? Colors.white : const Color(0xFF1E293B),
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const AppSelector(),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(AppState state, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: state.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: state.isDarkMode 
              ? const Color(0xFF334155) 
              : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  color: Color(0xFFF59E0B),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Cài đặt tự động lưu',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: state.isDarkMode ? Colors.white : const Color(0xFF1E293B),
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Icon(
                Icons.schedule_rounded,
                size: 20,
                color: state.isDarkMode 
                    ? const Color(0xFF94A3B8) 
                    : const Color(0xFF64748B),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Khoảng thời gian lưu tự động:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: state.isDarkMode ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF6366F1).withOpacity(0.1),
                      const Color(0xFF06B6D4).withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF6366F1).withOpacity(0.2),
                  ),
                ),
                child: Text(
                  '${state.interval} phút',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6366F1),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF6366F1),
              inactiveTrackColor: state.isDarkMode 
                  ? const Color(0xFF334155) 
                  : const Color(0xFFE2E8F0),
              thumbColor: const Color(0xFF6366F1),
              overlayColor: const Color(0xFF6366F1).withOpacity(0.1),
              valueIndicatorColor: const Color(0xFF6366F1),
              valueIndicatorTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
              trackHeight: 6,
            ),
            child: Slider(
              min: 1,
              max: 60,
              divisions: 59,
              value: state.interval.toDouble(),
              label: '${state.interval} phút',
              onChanged: state.setInterval,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(AppState state, bool isSmallScreen) {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: state.isRunning
              ? [const Color(0xFFEF4444), const Color(0xFFDC2626)]
              : [const Color(0xFF10B981), const Color(0xFF059669)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (state.isRunning 
                ? const Color(0xFFEF4444) 
                : const Color(0xFF10B981)).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: state.selectedApplications.isEmpty
              ? null
              : () {
                  if (state.isRunning) {
                    state.stopAutoSave();
                  } else {
                    state.startAutoSave();
                  }
                },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  state.isRunning 
                      ? Icons.stop_rounded 
                      : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  state.isRunning ? 'Dừng tự động lưu' : 'Bắt đầu tự động lưu',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.25,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBanner(AppState state, bool isSmallScreen) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 20,
            color: Color(0xFFF59E0B),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Vui lòng chọn ít nhất một ứng dụng để bắt đầu tự động lưu',
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFF92400E),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}