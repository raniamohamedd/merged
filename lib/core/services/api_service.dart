import 'dart:convert';
import 'dart:io';

import 'package:flutter_application_2/shared/user_session.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String authBaseUrl =
      "https://medpal-production-2abe.up.railway.app/auth";
  static const String userBaseUrl =
      "https://medpal-production-2abe.up.railway.app/user";

  static Future<Map<String, dynamic>> signupPatient({
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
    final url = Uri.parse('$authBaseUrl/signup');

    final body = jsonEncode({
      "fullName": fullName,
      "userName": userName,
      "email": email,
      "password": password,
      "confirmPassword": confirmPassword,
      "gender": gender,
      "role": role,
      "DOB": dob,
      "phone": phone,
    });

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        "Failed to signup patient: ${response.statusCode} - ${response.body}",
      );
    }
  }

  static Future<Map<String, dynamic>> signupDoctor({
    required String fullName,
    required String userName,
    required String email,
    required String password,
    required String confirmPassword,
    required String gender,
    required String role,
    required String dob,
    required String phone,
    required String specialization,
    required String licenseNumber,
    required String yearsOfExperience,
    required String clinicAddress,
    required File proofFile,
  }) async {
    final url = Uri.parse('$authBaseUrl/doctor-signup');

    final request = http.MultipartRequest('POST', url);

    request.headers["Accept"] = "application/json";

    request.fields["fullName"] = fullName;
    request.fields["userName"] = userName;
    request.fields["email"] = email;
    request.fields["password"] = password;
    request.fields["confirmPassword"] = confirmPassword;
    request.fields["gender"] = gender;
    request.fields["role"] = role;
    request.fields["DOB"] = dob;
    request.fields["phone"] = phone;
    request.fields["specialization"] = specialization;
    request.fields["licenseNumber"] = licenseNumber;
    request.fields["yearsOfExperience"] = yearsOfExperience;
    request.fields["clinicAddress"] = clinicAddress;

    request.files.add(
      await http.MultipartFile.fromPath(
        "proofFile",
        proofFile.path,
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        "Failed to signup doctor: ${response.statusCode} - ${response.body}",
      );
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$authBaseUrl/login');

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        "Failed to login: ${response.statusCode} - ${response.body}",
      );
    }
  }

  static Future<Map<String, dynamic>> confirmEmail({
    required String email,
    required String otp,
  }) async {
    final url = Uri.parse('$authBaseUrl/confirmEmail');

    final response = await http.patch(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode({
        "email": email,
        "otp": otp,
      }),
    );

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
    final url = Uri.parse('$authBaseUrl/forgetPassword');

    final response = await http.patch(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
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
    final url = Uri.parse('$authBaseUrl/restPassword');

    final response = await http.patch(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
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
    final String? token = prefs.getString("accessToken");

    final url = Uri.parse("$userBaseUrl/profile");

    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load profile: ${response.body}");
    }
  }

  static Future<Map<String, dynamic>> uploadProfileImage(File imageFile) async {
    final uri = Uri.parse("$userBaseUrl/image");

    final request = http.MultipartRequest('PATCH', uri);

    request.headers['Authorization'] = 'Bearer ${UserSession.accessToken}';
    request.files.add(
      await http.MultipartFile.fromPath('image', imageFile.path),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to upload image: ${response.body}');
    }
  }
}