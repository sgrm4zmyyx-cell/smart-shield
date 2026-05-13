import 'package:flutter/material.dart';
import 'package:smart_shield/core/constants/app_colors.dart';
import 'package:smart_shield/core/services/local_storage_service.dart';
import 'package:smart_shield/features/auth/subscription_guard.dart';
import 'package:smart_shield/features/home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 1));

    final localStorage = LocalStorageService();
    await localStorage.saveUserData({
      'email': _emailController.text.trim(),
      'registrationDate': DateTime.now().toIso8601String(),
    });

    if (!mounted) return;
    final guard = SubscriptionGuard(localStorage);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomeScreen(subscriptionGuard: guard),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              const Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('🛡️', style: TextStyle(fontSize: 72)),
                    SizedBox(height: 16),
                    Text(
                      'Smart Shield',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'حماية منتجاتك الذكية',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ),

              // Form
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'تسجيل الدخول',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Email
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(fontFamily: 'Cairo'),
                          validator: (v) =>
                              v!.isEmpty ? 'أدخل البريد الإلكتروني' : null,
                          decoration: InputDecoration(
                            labelText: 'البريد الإلكتروني',
                            labelStyle:
                                const TextStyle(fontFamily: 'Cairo'),
                            prefixIcon: const Icon(Icons.email_outlined,
                                color: AppColors.primary),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: AppColors.border)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: AppColors.primary, width: 2)),
                            filled: true,
                            fillColor: AppColors.surface,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Password
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: const TextStyle(fontFamily: 'Cairo'),
                          validator: (v) =>
                              v!.length < 6 ? 'كلمة المرور قصيرة' : null,
                          decoration: InputDecoration(
                            labelText: 'كلمة المرور',
                            labelStyle:
                                const TextStyle(fontFamily: 'Cairo'),
                            prefixIcon: const Icon(Icons.lock_outline,
                                color: AppColors.primary),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: AppColors.textSecondary,
                              ),
                              onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                            ),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: AppColors.border)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: AppColors.primary, width: 2)),
                            filled: true,
                            fillColor: AppColors.surface,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : const Text(
                                    'دخول',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontFamily: 'Cairo',
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Register
                        Center(
                          child: TextButton(
                            onPressed: () {},
                            child: const Text(
                              'مش عندك حساب؟ سجل دلوقتي',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
