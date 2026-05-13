import 'package:flutter/material.dart';
import 'package:smart_shield/core/constants/app_colors.dart';
import 'package:smart_shield/core/services/local_storage_service.dart';
import 'package:smart_shield/features/auth/login_screen.dart';
import 'package:smart_shield/features/payment/payment_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localStorage = LocalStorageService();
    final email = localStorage.getUserData('email') ?? 'غير محدد';
    final name = localStorage.getUserData('name') ?? 'المستخدم';
    final isVip = localStorage.getIsVip();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          title: const Text('الإعدادات',
              style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold)),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Profile Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person,
                          color: Colors.white, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name.toString(),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Cairo',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18)),
                          Text(email.toString(),
                              style: const TextStyle(
                                  color: Colors.white70,
                                  fontFamily: 'Cairo',
                                  fontSize: 13)),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isVip
                                  ? Colors.amber
                                  : Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              isVip ? '⭐ مشترك' : '🆓 تجريبي',
                              style: TextStyle(
                                  color: isVip
                                      ? AppColors.primary
                                      : Colors.white,
                                  fontFamily: 'Cairo',
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Settings Options
              _buildSection('الاشتراك', [
                _buildOption(
                  context,
                  Icons.star_outline,
                  'ترقية الاشتراك',
                  'اشترك للوصول لكل الميزات',
                  Colors.amber,
                  () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const PaymentScreen())),
                ),
              ]),
              const SizedBox(height: 16),

              _buildSection('التطبيق', [
                _buildOption(context, Icons.notifications_outlined,
                    'الإشعارات', 'إدارة إشعارات الانتهاء', AppColors.primary,
                    () {}),
                _buildOption(context, Icons.language, 'اللغة', 'العربية',
                    AppColors.primary, () {}),
                _buildOption(context, Icons.info_outline, 'عن التطبيق',
                    'الإصدار 1.0.0', AppColors.primary, () {}),
              ]),
              const SizedBox(height: 16),

              _buildSection('الحساب', [
                _buildOption(
                  context,
                  Icons.logout,
                  'تسجيل الخروج',
                  'الخروج من الحساب',
                  AppColors.danger,
                  () async {
                    await localStorage.clearAll();
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    }
                  },
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8, right: 4),
            child: Text(title,
                style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                    fontSize: 13)),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(children: children),
          ),
        ],
      );

  Widget _buildOption(BuildContext context, IconData icon, String title,
      String subtitle, Color color, VoidCallback onTap) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                    Text(subtitle,
                        style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            color: AppColors.textSecondary)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios,
                  size: 14, color: AppColors.textSecondary),
            ],
          ),
        ),
      );
}
