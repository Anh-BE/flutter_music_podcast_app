import 'package:flutter/material.dart';
import '../colors/app_colors.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

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
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ô tìm kiếm
                TextField(
                  style: const TextStyle(color: AppColors.textWhite),
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm nhạc, nghệ sĩ, podcast...',
                    hintStyle: const TextStyle(color: AppColors.textGrey),
                    prefixIcon: const Icon(Icons.search, color: AppColors.textGrey),
                    filled: true,
                    fillColor: const Color(0xFF1C1B1F), // Màu nền ô input giống màn hình đăng nhập
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
                  ),
                ),
                // Các phần khác như "Lịch sử tìm kiếm", "Thể loại" sẽ được thêm vào đây
              ],
            ),
          ),
        ),
      ),
    );
  }
}