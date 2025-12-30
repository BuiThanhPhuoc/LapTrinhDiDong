import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; 
// Import HomeScreen để dùng sau khi đăng nhập thành công
import 'package:buithanhphuoc_2280602493/home_screen.dart';
// QUAN TRỌNG: Import LoginScreen của bạn vào đây
import 'package:buithanhphuoc_2280602493/login_screen.dart';

Future<void> main() async {
  // Đảm bảo Flutter đã khởi tạo xong trước khi load dotenv
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print("Cảnh báo: Không tìm thấy file .env");
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ứng dụng Chuyển Đổi Đa Năng',
      debugShowCheckedModeBanner: false, 
      
      theme: ThemeData(
        primarySwatch: Colors.indigo, 
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.indigo)
            .copyWith(secondary: Colors.teal),
        useMaterial3: true,
      ),
      
      // THAY ĐỔI Ở ĐÂY: Chạy LoginScreen đầu tiên
      // Người dùng phải qua cửa này mới vào được bên trong
      home: const LoginScreen(), 
    );
  }
}