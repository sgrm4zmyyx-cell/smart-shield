import 'package:flutter/material.dart';
import 'package:smart_shield/core/constants/app_colors.dart';
import 'package:smart_shield/core/services/local_storage_service.dart';
import 'package:smart_shield/core/services/notification_service.dart';
import 'package:smart_shield/features/auth/subscription_guard.dart';
import 'package:smart_shield/features/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageService.init();
  await NotificationService().init();
  runApp(const SmartShieldApp());
}

class SmartShieldApp extends StatelessWidget {
  const SmartShieldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Shield',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        fontFamily: 'Cairo',
        useMaterial3: true,
      ),
      home: const AppInitializer(),
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await Future.delayed(const Duration(seconds: 2));
    final localStorage = LocalStorageService();
    final guard = SubscriptionGuard(localStorage);
    final status = guard.checkStatus();
    if (!mounted) return;
    if (status == SubscriptionStatus.expired ||
        status == SubscriptionStatus.subscriptionExpired) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const TrialExpiredScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(subscriptionGuard: guard),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🛡️', style: TextStyle(fontSize: 64)),
            SizedBox(height: 16),
            Text(
              'Smart Shield',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
            SizedBox(height: 8),
            Text(
              'حماية منتجاتك الذكية',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontFamily: 'Cairo',
              ),
            ),
            SizedBox(height: 48),
            CircularProgressIndicator(color: Colors.white54),
          ],
        ),
      ),
    );
  }
}
