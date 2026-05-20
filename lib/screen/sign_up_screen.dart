
import '../colors/app_colors.dart';

import 'package:flutter/material.dart';
import '../models/Supabase_Service.dart';

import 'main_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
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

  void _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final error = await SupabaseService().signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        username: _nameController.text.trim(),
      );
      if (mounted) setState(() => _isLoading = false);

      if (error == null) {
        _showFriendlyMessage("Tạo tài khoản thành công! Khám phá âm nhạc thôi nào 🎉", false);
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const MainScreen()), (route) => false);
      } else {
        _showFriendlyMessage("Email này đã được đăng ký hoặc thông tin chưa hợp lệ.", true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, iconTheme: const IconThemeData(color: AppColors.textWhite)),
      extendBodyBehindAppBar: true,
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
              const SizedBox(height: 10),
              // LOGO CAO RIÊNG BIỆT ĐỒNG BỘ
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
                          const Text('Đăng Ký', style: TextStyle(color: AppColors.textWhite, fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                          const SizedBox(height: 25),

                          // Tên
                          TextFormField(
                            controller: _nameController,
                            style: const TextStyle(color: AppColors.textWhite),
                            decoration: _buildInputDecoration(label: 'Tên người dùng', hint: 'Ví dụ: Nguyễn Xuân Dũng', icon: Icons.person_outline),
                            validator: (val) => (val == null || val.trim().isEmpty) ? 'Vui lòng điền tên hiển thị' : null,
                          ),
                          const SizedBox(height: 20),

                          // Email
                          TextFormField(
                            controller: _emailController,
                            style: const TextStyle(color: AppColors.textWhite),
                            decoration: _buildInputDecoration(label: 'Email', hint: 'nhap@email.com', icon: Icons.email_outlined),
                            validator: (val) => (val == null || !val.contains("@")) ? 'Định dạng Email không chính xác' : null,
                          ),
                          const SizedBox(height: 20),

                          // Mật khẩu
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscureText,
                            style: const TextStyle(color: AppColors.textWhite),
                            decoration: _buildInputDecoration(label: 'Mật khẩu', hint: 'Tối thiểu 6 ký tự', icon: Icons.lock_outline).copyWith(
                              suffixIcon: IconButton(
                                icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, color: AppColors.textGrey),
                                onPressed: () => setState(() => _obscureText = !_obscureText),
                              ),
                            ),
                            validator: (val) => (val == null || val.length < 6) ? 'Mật khẩu bắt buộc từ 6 ký tự' : null,
                          ),
                          const SizedBox(height: 35),

                          // Nút tạo tài khoản
                          Container(
                            height: 52,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [AppColors.button, AppColors.primary]),
                              borderRadius: BorderRadius.circular(26),
                            ),
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleSignUp,
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26))),
                              child: _isLoading
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppColors.textWhite, strokeWidth: 2))
                                  : const Text('Đăng Ký', style: TextStyle(fontSize: 15, color: AppColors.textWhite, fontWeight: FontWeight.bold)),
                            ),
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