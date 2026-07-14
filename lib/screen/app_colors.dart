import 'package:flutter/material.dart';

class AppColors {
  // Private constructor để không ai có thể khởi tạo instance của class này
  AppColors._();

  // Định nghĩa các màu sắc sử dụng chung trong toàn bộ app dựa trên Figma
  static const Color primaryPurple = Color.fromARGB(255, 123, 30, 157);
  static const Color lightPurple = Color.fromARGB(255, 166, 93, 230);
  static const Color darkBackground = Color(0xFF121212);
  static const Color accentGreen = Colors.green;
  
  // Bạn có thể yêu cầu Designer cung cấp Palette màu và thêm tiếp vào đây
}