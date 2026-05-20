
import '../colors/app_colors.dart';

import 'package:flutter/material.dart';
import '../models/Supabase_Service.dart';

import 'main_screen.dart';
import 'sign_up_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true;
  bool _isLoading = false;

  void _showFriendlyMessage(String message, bool isError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(isError ? Icons.error_outline : Icons.check_circle_outline, color: AppColors.textWhite),
            const SizedBox(width: 10),
            Expanded(child: Text(message, style: const TextStyle(color: AppColors.textWhite, fontSize: 14))),
          ],
        ),
        backgroundColor: isError ? Colors.redAccent : AppColors.primary,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _handleSignIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final error = await SupabaseService().signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (mounted) setState(() => _isLoading = false);

      if (error == null) {
        _showFriendlyMessage("Chào mừng bạn quay trở lại với Musify! 🎶", false);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainScreen()));
      } else {
        _showFriendlyMessage("Email hoặc mật khẩu chưa chính xác. Bạn kiểm tra lại nhé!", true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary, AppColors.background],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 30),
              // LOGO NẰM TRÊN CAO RIÊNG BIỆT
              const CircleAvatar(
                radius: 35,
                backgroundColor: Colors.white10,
                child: Icon(Icons.music_note_rounded, size: 40, color: AppColors.textWhite),
              ),
              const SizedBox(height: 12),
              const Text(
                'Musify',
                style: TextStyle(color: AppColors.textWhite, fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 1.2),
              ),

              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 28.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Đăng Nhập',
                            style: TextStyle(color: AppColors.textWhite, fontSize: 22, fontWeight: FontWeight.bold),
                            textAlign:TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Kết nối tài khoản để tiếp tục nghe nhạc',
                            style: TextStyle(color: AppColors.textGrey, fontSize: 13),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 35),

                          // Email
                          TextFormField(
                            controller: _emailController,
                            style: const TextStyle(color: AppColors.textWhite),
                            decoration: _buildInputDecoration(label: 'Email', hint: 'nhap@email.com', icon: Icons.email_outlined),
                            validator: (val) => (val == null || !val.contains("@")) ? 'Vui lòng nhập email hợp lệ' : null,
                          ),
                          const SizedBox(height: 20),

                          // Mật khẩu
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscureText,
                            style: const TextStyle(color: AppColors.textWhite),
                            decoration: _buildInputDecoration(label: 'Mật khẩu', hint: 'Nhập mật khẩu', icon: Icons.lock_outline).copyWith(
                              suffixIcon: IconButton(
                                icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, color: AppColors.textGrey),
                                onPressed: () => setState(() => _obscureText = !_obscureText),
                              ),
                            ),
                            validator: (val) => (val == null || val.length < 6) ? 'Mật khẩu yêu cầu từ 6 ký tự' : null,
                          ),
                          const SizedBox(height: 35),

                          // Nút Đăng Nhập
                          Container(
                            height: 52,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [AppColors.button, AppColors.primary]),
                              borderRadius: BorderRadius.circular(26),
                            ),
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleSignIn,
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26))),
                              child: _isLoading
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppColors.textWhite, strokeWidth: 2))
                                  : const Text('Đăng Nhập', style: TextStyle(fontSize: 15, color: AppColors.textWhite, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(height: 25),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Bạn chưa có tài khoản? ", style: TextStyle(color: AppColors.textGrey, fontSize: 14)),
                              GestureDetector(
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpScreen())),
                                child: const Text("Đăng ký ngay", style: TextStyle(color: AppColors.button, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ],
                      ),
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

  InputDecoration _buildInputDecoration({required String label, required String hint, required IconData icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textGrey, fontSize: 14),
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
      prefixIcon: Icon(icon, color: AppColors.textGrey, size: 22),
      filled: true,
      fillColor: const Color(0xFF1C1B1F),
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 18),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white10)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
      errorStyle: const TextStyle(color: Colors.redAccent),
    );
  }
}