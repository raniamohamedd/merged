import 'dart:convert';
import 'dart:io';
import 'package:flutter_application_2/Features/patient_side/search/search_screen.dart';
import 'package:flutter_application_2/shared/user_session.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String authBaseUrl =
      "https://medpal-production-e325.up.railway.app/auth";
  static const String userBaseUrl =
      "https://medpal-production-e325.up.railway.app/user";

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

    final data =
        response.body.isNotEmpty ? jsonDecode(response.body) : <String, dynamic>{};

    if (response.statusCode == 200 || response.statusCode == 201) {
      return data;
    } else {
      throw Exception(
        data["message"] ??
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
    required String licenseNumbers,
    required String experienceYears,
    required String qualification,
    required String clinicLocation,
    required File proofDocument,
  }) async {
    final url = Uri.parse('$authBaseUrl/signupDoc');

    final request = http.MultipartRequest('POST', url);

    request.headers["Accept"] = "application/json";

    request.fields["fullName"] = fullName;
    request.fields["email"] = email;
    request.fields["password"] = password;
    request.fields["confirmPassword"] = confirmPassword;
    request.fields["userName"] = userName;
    request.fields["gender"] = gender.toLowerCase();
    request.fields["phone"] = phone;
    request.fields["DOB"] = dob;
    request.fields["licenseNumbers"] = licenseNumbers;
    request.fields["experienceYears"] = experienceYears;
    request.fields["qualification"] = qualification;
    request.fields["specialization"] = specialization;
    request.fields["clinicLocation"] = clinicLocation;
    request.fields["role"] = role;

    request.files.add(
      await http.MultipartFile.fromPath(
        "proofDocument",
        proofDocument.path,
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    final data =
        response.body.isNotEmpty ? jsonDecode(response.body) : <String, dynamic>{};

    if (response.statusCode == 200 || response.statusCode == 201) {
      return data;
    } else {
      throw Exception(
        data["message"] ??
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

    final data =
        response.body.isNotEmpty ? jsonDecode(response.body) : <String, dynamic>{};

    if (response.statusCode == 200 || response.statusCode == 201) {
      return data;
    } else {
      throw Exception(
        data["message"] ??
            "Failed to login: ${response.statusCode} - ${response.body}",
      );
    }
  }

static Future<List<Doctor>> getDoctors() async {
  final prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString("accessToken");
    final String? token2 = prefs.getString("refreshToken");

  print(token);
  print('huhubhuhbubh');
   print(token2);
  print('huhubhuhbubh');

  final url = Uri.parse('$userBaseUrl/getDoctors');

  final response = await http.get(
    url,
    headers: {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    },
  );
  print(response);

  final data =
      response.body.isNotEmpty ? jsonDecode(response.body) : null;

  if (response.statusCode == 200 || response.statusCode == 201) {
    // حسب شكل الريسبونس من الباك
    if (data is List) {
      return data.map((e) => Doctor.fromJson(e)).toList();
    } else if (data is Map<String, dynamic>) {
      if (data["doctors"] is List) {
        return (data["doctors"] as List)
            .map((e) => Doctor.fromJson(e))
            .toList();
      } else if (data["data"] is List) {
        return (data["data"] as List)
            .map((e) => Doctor.fromJson(e))
            .toList();
      }
    }

    throw Exception("Unexpected response format: $data");
  } else {
    throw Exception(
      data?["message"] ??
          "Failed to fetch doctors: ${response.statusCode} - ${response.body}",
    );
  }
}
  static Future<Map<String, dynamic>> logindoc({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$authBaseUrl/loginDoc');

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

    final data =
        response.body.isNotEmpty ? jsonDecode(response.body) : <String, dynamic>{};

    if (response.statusCode == 200 || response.statusCode == 201) {
      return data;
    } else {
      throw Exception(
        data["message"] ??
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