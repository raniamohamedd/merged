// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class ApiService {
//   static const String baseUrl =
//       "https://medpal-production-2abe.up.railway.app";

//   static Future<Map<String, dynamic>> login(String email, String password) async {
//     var url = Uri.parse("$baseUrl/login");

//     var response = await http.post(
//       url,
//       headers: {"Content-Type": "application/json"},
//       body: jsonEncode({"email": email, "password": password}),
//     );

//     if (response.statusCode == 200) {
//       return jsonDecode(response.body);
//     } else {
//       throw Exception("Failed to login: ${response.statusCode}");
//     }
//   }
// }
// file: services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter_application_2/shared/user_session.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "https://medpal-production-2abe.up.railway.app/auth";

  static Future<Map<String, dynamic>> signup({
    required String fullName,
    required String userName,
    required String email,
    required String password,
    required String confirmPassword,
    required String gender,
    required String role,
    required String dob,
        required String phone,

  }) async {
    final url = Uri.parse('$baseUrl/signup'); // endpoint تسجيل حساب

    final body = jsonEncode({
      "fullName": fullName,
      "userName": userName,
      "email": email,
      "password": password,
      "confirmPassword": confirmPassword,
      "gender": gender,
      "role": role,
      "DOB": dob,
      'phone' :phone
    });

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to signup: ${response.statusCode} - ${response.body}");
    }
  }
 static Future confirmEmail({
  required String email,
  required String otp,
}) async {

  final url = Uri.parse('$baseUrl/confirmEmail');

  final response = await http.patch(
    url,
    headers: {
      "Content-Type": "application/json",
    },
    body: jsonEncode({
      "email": email,
      "otp": otp,
    }),
  );

  print("ConfirmEmail Status: ${response.statusCode}");
  print("ConfirmEmail Body: ${response.body}");

  final data = jsonDecode(response.body);

  if (response.statusCode == 200 || response.statusCode == 201) {
    return data;
  } else {
    throw Exception(data["message"] ?? "OTP verification failed");
  }
}

   static Future<Map<String, dynamic>> forgetpassword({
  required String email,
}) async {

  final url = Uri.parse('$baseUrl/forgetPassword');

  final response = await http.patch(
    url,
    headers: {
      "Content-Type": "application/json",
    },
    body: jsonEncode({
      "email": email,
    }),
  );

  final data = jsonDecode(response.body);

  if (response.statusCode == 200 || response.statusCode == 201) {
    return data;
  } else {
    throw Exception(data["message"] ?? "Forget Password failed");
  }
}
static Future<Map<String, dynamic>> resetPassword({
  required String email,
  required String otp,
  required String password,
  required String confirmPassword,
}) async {

  final url = Uri.parse('$baseUrl/restPassword');

  final response = await http.patch(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "email": email,
      "otp": otp,
      "password": password,
      "confirmPassword": confirmPassword,
    }),
  );

  final data = jsonDecode(response.body);

  if (response.statusCode == 200 || response.statusCode == 201) {
    return data;
  } else {
    throw Exception(data["message"] ?? "Reset password failed");
  }
}




static Future<Map<String, dynamic>> getProfile() async {

  final prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString("accessToken");

  final url = Uri.parse(
      "https://medpal-production-2abe.up.railway.app/user/profile");

  final response = await http.get(
    url,
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    },
  );

  print("Profile Status: ${response.statusCode}");
  print("Profile Body: ${response.body}");

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception("Failed to load profile");
  }
}

  // static Future<Map<String, dynamic>> uploadProfileImage(File imageFile) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   String? token = prefs.getString("accessToken");

  //   var request = http.MultipartRequest(
  //     'POST',
  //     Uri.parse('$baseUrl/user/image'),
  //   );

  //   request.headers['Authorization'] = 'Bearer $token';
  //   request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

  //   var streamedResponse = await request.send();
  //   var response = await http.Response.fromStream(streamedResponse);

  //   if (response.statusCode == 200) {
  //     return Map<String, dynamic>.from(jsonDecode(response.body));
  //   } else {
  //     throw Exception('Failed to upload image: ${response.body}');
  //   }
  // }




  static Future<Map<String, dynamic>> uploadProfileImage(File imageFile) async {
    final uri = Uri.parse("https://medpal-production-2abe.up.railway.app/user/image");

    var request = http.MultipartRequest('PATCH', uri);

    // إضافة ملف الصورة
    request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

    // إضافة هيدر التوكن
    request.headers['Authorization'] = 'Bearer ${UserSession.accessToken}';

    // إرسال الطلب
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to upload image: ${response.body}');
    }
  }
}

