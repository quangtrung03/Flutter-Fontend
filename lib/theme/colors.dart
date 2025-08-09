import 'package:flutter/material.dart';

class AppColors {
  // 🌿 Màu chủ đạo - Xanh lá thiên nhiên
  static const Color primary = Color(0xFF4CAF50);  // Xanh lá tươi
  static const Color primaryLight = Color(0xFF81C784);  // Xanh lá nhạt
  static const Color primaryDark = Color(0xFF388E3C);  // Xanh lá đậm
  
  // 🍃 Màu phụ - Xanh mint dịu mắt
  static const Color secondary = Color(0xFF66BB6A);  // Xanh mint
  static const Color secondaryLight = Color(0xFFA5D6A7);  // Xanh mint nhạt
  static const Color secondaryDark = Color(0xFF43A047);  // Xanh mint đậm
  
  // 🍊 Màu nhấn - Cam cam tươi sáng
  static const Color accent = Color.fromARGB(255, 70, 229, 250);  // Cam tươi
  static const Color accentLight = Color.fromARGB(255, 252, 247, 240);  // Cam nhạt
  static const Color accentDark = Color.fromARGB(255, 238, 236, 235);  // Cam đậm
  
  // 🌱 Màu nền - Xanh mint rất nhạt
  static const Color background = Color(0xFFF1F8E9);  // Xanh mint rất nhạt
  static const Color scaffold = Color(0xFFFAFAFA);  // Trắng xám nhạt
  static const Color surface = Color(0xFFFFFFFF);  // Trắng tinh
  
  // 🎨 Màu cơ bản
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color transparent = Colors.transparent;
  
  // 📝 Màu chữ
  static const Color textPrimary = Color(0xFF2E7D32);  // Xanh lá đậm cho chữ chính
  static const Color textSecondary = Color(0xFF558B2F);  // Xanh lá nhạt cho chữ phụ
  static const Color textLight = Color(0xFF7CB342);  // Xanh lá sáng cho chữ nhỏ
  static const Color textHint = Color(0xFF9E9E9E);  // Xám cho placeholder
  
  // 🚨 Màu trạng thái
  static const Color error = Color(0xFFE53935);  // Đỏ báo lỗi
  static const Color success = Color(0xFF4CAF50);  // Xanh thành công
  static const Color warning = Color(0xFFFF9800);  // Cam cảnh báo
  static const Color info = Color(0xFF2196F3);  // Xanh thông tin
  
  // 🌈 Màu gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    colors: [primary, secondary], // Xanh lá sang mint
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [background, white],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  // 🎯 Màu đặc biệt cho nước uống
  static const Color coffee = Color(0xFF8D6E63);  // Màu cà phê
  static const Color tea = Color(0xFF7CB342);  // Màu trà xanh
  static const Color juice = Color(0xFFFF7043);  // Màu nước ép
  static const Color smoothie = Color(0xFF66BB6A);  // Màu smoothie
  
  // 🌟 Màu shadow và elevation
  static const Color shadow = Color(0x1A000000);  // Shadow nhẹ
  static const Color shadowMedium = Color(0x33000000);  // Shadow vừa
  static const Color shadowStrong = Color(0x4D000000);  // Shadow mạnh
}
