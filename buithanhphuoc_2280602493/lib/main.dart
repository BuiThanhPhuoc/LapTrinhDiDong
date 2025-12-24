import 'package:flutter/material.dart';
// Đảm bảo đường dẫn import này là chính xác
import 'package:buithanhphuoc_2280602493/home_screen.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Widget này là gốc của ứng dụng (Root of the application)
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ứng dụng Chuyển Đổi Đa Năng',
      // Tắt banner "Debug" ở góc phải màn hình
      debugShowCheckedModeBanner: false, 
      
      // Định nghĩa chủ đề (Theme) của ứng dụng
      theme: ThemeData(
        // Sử dụng màu Indigo làm màu chính (Primary color) để đồng bộ với HomeScreen
        primarySwatch: Colors.indigo, 
        // Thiết lập màu sắc và phông chữ mặc định cho toàn ứng dụng
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.indigo)
            .copyWith(secondary: Colors.teal), // Màu secondary (Accent)
        useMaterial3: true, // Bật sử dụng Material 3 design
      ),
      
      // Trang chủ của ứng dụng
      home: const HomeScreen(),
    );
  }
}