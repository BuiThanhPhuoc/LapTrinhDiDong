import 'dart:convert';

import 'package:buithanhphuoc_2280602493/config/config_url.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // đường dẫn tới API login
  String get apiUrl => "${Config_URL.baseUrl}Authenticate/login";

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      print("🔍 DEBUG - BaseUrl: ${Config_URL.baseUrl}");
      print("🔍 DEBUG - Full API URL: $apiUrl");
      print("🔍 DEBUG - Username: $username");
      
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        //Lấy thông tin tên đăng nhập và password
        body: jsonEncode({
          "username": username,
          "password": password,
        }),
      );

      print("🔍 DEBUG - Status Code: ${response.statusCode}");
      print("🔍 DEBUG - Response Headers: ${response.headers}");
      print("🔍 DEBUG - Response Body: ${response.body}");
      print("🔍 DEBUG - Response Body Length: ${response.body.length}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("🔍 DEBUG - Parsed JSON: $data");
        print("🔍 DEBUG - Data Keys: ${data.keys}");
        
        // Match backend's response (lowercase keys)
        bool status = data['status'] ?? false;
        String message = data['message'] ?? 'Unknown error';
        String token = data['token'] ?? '';

        print("🔍 DEBUG - Status: $status, Message: $message, Token exists: ${token.isNotEmpty}");

        if (!status) {
          return {"success": false, "message": message};
        }
        
        // Decode token để lấy các thông tin đăng nhập: tên đăng nhập, role...
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        
        // Lấy thời hạn token (iat và exp)
        DateTime issuedAt = DateTime.fromMillisecondsSinceEpoch(
          (decodedToken['iat'] ?? 0) * 1000,
        );
        DateTime expiresAt = DateTime.fromMillisecondsSinceEpoch(
          (decodedToken['exp'] ?? 0) * 1000,
        );
        
        Duration tokenDuration = expiresAt.difference(issuedAt);
        
        print("🔍 TOKEN INFO:");
        print("   - Issued At: $issuedAt");
        print("   - Expires At: $expiresAt");
        print("   - Duration: ${tokenDuration.inHours} giờ ${tokenDuration.inMinutes % 60} phút");
        print("   - Decoded Token: $decodedToken");

        // Lưu token vào SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('jwt_token', token);  // Lưu token
        return {
          "success": true,
          "token": token,
          "decodedToken": decodedToken,
          "expiresAt": expiresAt.toString(),
          "duration": "${tokenDuration.inHours} giờ",
        };
      } else {
        // If status code is not 200, treat it as login failure
        print("🔍 DEBUG - Error Response: ${response.body}");
        return {"success": false, "message": "Failed to login: ${response.statusCode}"};
      }
    } catch (e) {
      // Handle network or parsing errors
      print("🔍 DEBUG - Exception: $e");
      print("🔍 DEBUG - Exception Type: ${e.runtimeType}");
      return {"success": false, "message": "Network error: $e"};
    }
  }
}
