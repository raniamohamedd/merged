import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_application_2/Features/doctor_side/screens/notification_screen.dart';
import 'package:flutter_application_2/Features/patient_side/search/search_screen.dart';
import 'package:flutter_application_2/shared/user_session.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String authBaseUrl =
      "https://medpal-production-01b6.up.railway.app/auth";
  static const String userBaseUrl =
      "https://medpal-production-01b6.up.railway.app/user";

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
    print(response.body);

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
  print(response.body);

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
        final prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString("accessToken");
    final String? token2 = prefs.getString("refreshToken");
  print(token);
  print('huhubhuhbubh');
   print(token2);
  print('huhubhuhbubh');
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
static Future<void> rejectRequest(String id) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString("accessToken");

  final url = Uri.parse(
    "https://medpal-production-01b6.up.railway.app/doctor/request/$id/reject"
  );

  final response = await http.patch(
    url,
    headers: {
      "Content-Type": "application/json",
      "Authorization": "System $token",
    },
  );

  if (response.statusCode != 200 && response.statusCode != 201) {
    throw Exception("Failed to reject request");
  }
}












static Future<Map<String, dynamic>> scanMedication(File imageFile) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString("accessToken");

  final url = Uri.parse(
    "https://medpal-production-01b6.up.railway.app/medication/scan",
  );

  // ضغط الصورة الأول
  final compressedBytes = await FlutterImageCompress.compressWithFile(
    imageFile.absolute.path,
    quality: 70,
    minWidth: 1024,
    minHeight: 1024,
  );

  // multipart request
  final request = http.MultipartRequest('POST', url);
  request.headers.addAll({
    "Authorization": "Bearer $token",
    "Accept": "application/json",
  });

  request.files.add(
    http.MultipartFile.fromBytes(
      'file',                         // اسم الـ field زي ما الـ backend بيتوقع
      compressedBytes!,
      filename: 'scan.jpg',
      contentType: http.MediaType('image', 'jpeg'),
    ),
  );

  final streamed = await request.send().timeout(const Duration(seconds: 90));
  final response = await http.Response.fromStream(streamed);

  print("SCAN: ${response.statusCode} - ${response.body}");

  final data = response.body.isNotEmpty
      ? jsonDecode(response.body)
      : <String, dynamic>{};

  if (response.statusCode == 200 || response.statusCode == 201) {
    return data;
  } else {
    throw Exception(data["message"] ?? "Failed: ${response.statusCode}");
  }
}







static Future<List<dynamic>> getChatHistory() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString("accessToken");

  final response = await http.get(
    Uri.parse("https://medpal-production-01b6.up.railway.app/chatbot/history"),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data["data"] ?? [];
  } else if (response.statusCode == 404) {
    return [];
  } else {
    throw Exception("Failed to load chat history");
  }
}







static Future<List<dynamic>> getMySos() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString("accessToken");

  final response = await http.get(
    Uri.parse("https://medpal-production-01b6.up.railway.app/sos/my"),
    headers: {
      "Authorization": "Bearer $token",
    },
  );

  print("MY SOS: ${response.body}");

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data["data"] ?? [];
  } else if (response.statusCode == 404) {
    return [];
  } else {
    throw Exception("Failed to load my SOS");
  }
}
static Future<List<dynamic>> getSos() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString("accessToken");

  final response = await http.get(
    Uri.parse("https://medpal-production-01b6.up.railway.app/sos"),
    headers: {
      "Authorization": "System $token",
    },
  );

  print("SOS LIST: ${response.body}");

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data["data"]; // ✅ list of SOS
  } else {
    throw Exception("Failed to load SOS");
  }
}



static Future<List<dynamic>> getPendingMedications() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString("accessToken");

  final response = await http.get(
    Uri.parse("https://medpal-production-01b6.up.railway.app/medication/pending"),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    },
  );

  print("PENDING: ${response.statusCode} - ${response.body}");

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data["data"] ?? [];
  } else if (response.statusCode == 404) {
    return [];
  } else {
    throw Exception("Failed to load pending medications");
  }
}

static Future<Map<String, dynamic>> addMedication({
  required String medicationName,
  required String dosage,
  required String repeat,
  int? repeatEveryHours,
  required String reminderTime,
  required List<String> sideEffects,
  required String warningLevel,
  required String startDate,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString("accessToken");

  final Map<String, dynamic> body = {
    "medicationName": medicationName,
    "dosage": dosage,
    "repeat": repeat,
    "reminderTime": reminderTime,
    "sideEffects": sideEffects,
    "warningLevel": warningLevel,
    "startDate": startDate,
  };

  if (repeat == "every_x_hours" && repeatEveryHours != null) {
    body["repeatEveryHours"] = repeatEveryHours;
  }

  print("═══════════════════════════════════");
  print("ADD MEDICATION REQUEST:");
  print("URL: https://medpal-production-01b6.up.railway.app/medication/add");
  print("TOKEN: ${token?.substring(0, 20)}...");
  print("BODY: ${jsonEncode(body)}");
  print("═══════════════════════════════════");

  final response = await http.post(
    Uri.parse("https://medpal-production-01b6.up.railway.app/medication/add"),
    headers: {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    },
    body: jsonEncode(body),
  );

  print("═══════════════════════════════════");
  print("ADD MEDICATION RESPONSE:");
  print("STATUS: ${response.statusCode}");
  print("BODY: ${response.body}");
  print("═══════════════════════════════════");

  // ✅ check مرة واحدة بس
  if (response.statusCode != 200 && response.statusCode != 201) {
    final data = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : <String, dynamic>{};
    throw Exception(
      data["message"] ??
          data["error"] ??
          "Failed to add medication: ${response.statusCode}",
    );
  }

  // ✅ رجّع الـ response
  return jsonDecode(response.body) as Map<String, dynamic>;
}
// ✅ الجديد
static Future<List<dynamic>> getMyMedications() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString("accessToken");

  final response = await http.get(
    Uri.parse("https://medpal-production-01b6.up.railway.app/medication/my"),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    },
  );

  print(response.body);

  // ✅ لو 404 = مفيش patient profile لسه = list فاضية
  if (response.statusCode == 404) {
    return [];
  }

  final data = jsonDecode(response.body);

  if (response.statusCode == 200) {
    return data["data"] ?? [];
  } else {
    throw Exception(data["message"] ?? "Failed to load medications");
  }
}
static Future<Map<String, dynamic>> getPatientReport() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString("accessToken");

  final response = await http.get(
    Uri.parse("https://medpal-production-01b6.up.railway.app/medication/report"),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    },
  );

  print("REPORT: ${response.statusCode} - ${response.body}");

  if (response.statusCode == 200) {
    return jsonDecode(response.body) as Map<String, dynamic>;
  } else {
    throw Exception("Failed to load report");
  }
}

static Future<void> resolveSos(String sosId) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString("accessToken");

  final response = await http.patch(
    Uri.parse("https://medpal-production-01b6.up.railway.app/sos/$sosId/resolve"),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "System $token",
    },
  );

  print("RESOLVE SOS: ${response.statusCode} - ${response.body}");

  if (response.statusCode != 200 && response.statusCode != 201) {
    final data = response.body.isNotEmpty ? jsonDecode(response.body) : {};
    throw Exception(data["message"] ?? "Failed to resolve SOS");
  }
}
static Future<void> takeMedication(String logId) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString("accessToken");

  final response = await http.post(
    Uri.parse("https://medpal-production-01b6.up.railway.app/medication/take/$logId"),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    },
  );

  print("TAKE MED: ${response.statusCode} - ${response.body}");

  if (response.statusCode != 200 && response.statusCode != 201) {
    final data = response.body.isNotEmpty ? jsonDecode(response.body) : {};
    throw Exception(data["message"] ?? "Failed to mark medication as taken");
  }
}
static Future<void> forceAddMedication({
  required String medicationName,
  required String dosage,
  required String repeat,
  required String reminderTime,
  required List<String> sideEffects,
  required String warningLevel,
  required String startDate,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString("accessToken");

  final body = {
    "medicationName": medicationName,
    "dosage": dosage,
    "repeat": repeat,
    "reminderTime": reminderTime,
    "sideEffects": sideEffects,
    "warningLevel": warningLevel,
    "startDate": startDate,
    "forceAdd": true, // ✅ bypass الـ warning
  };

  final response = await http.post(
    Uri.parse("https://medpal-production-01b6.up.railway.app/medication/add"),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    },
    body: jsonEncode(body),
  );

  if (response.statusCode != 200 && response.statusCode != 201) {
    final data = jsonDecode(response.body);
    throw Exception(data["message"] ?? "Failed to add medication");
  }
}

static Future<Map<String, dynamic>> getPatients() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString("accessToken");

  final response = await http.get(
    Uri.parse("https://medpal-production-01b6.up.railway.app/doctor/patients"),
    headers: {
      "Authorization": "System $token",
    },
  );

  print("PATIENTS: ${response.body}");

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception("Failed to load patients");
  }
}

static Future<Map<String, dynamic>> updatePatientProfile({
  required List<Map<String, dynamic>> chronicDiseases,
  required String allergies,
  required String bloodType,
  required int height,
  required int weight,
  required String note,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString("accessToken");

  final url = Uri.parse(
    "https://medpal-production-01b6.up.railway.app/patient/profile",
  );

  final response = await http.patch(
    url,
    headers: {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    },
    body: jsonEncode({
      "chronicDiseases": chronicDiseases,
      "allergies": allergies,
      "bloodType": bloodType,
      "height": height,
      "weight": weight,
      "note": note,
    }),
  );

  print("UPDATE PROFILE: ${response.body}");

  final data = response.body.isNotEmpty ? jsonDecode(response.body) : {};

  if (response.statusCode == 200 || response.statusCode == 201) {
    return data;
  } else {
    throw Exception(
      data["message"] ??
          "Failed to update profile: ${response.statusCode} - ${response.body}",
    );
  }
}
static Future<void> createSos({
  required String doctorId,
  required String updateType,
  required String severity,
  required String details,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString("accessToken");

  final url = Uri.parse(
    "https://medpal-production-01b6.up.railway.app/sos",
  );

  final response = await http.post(
    url,
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    },
    body: jsonEncode({
      "doctorId": doctorId,
      "updateType": updateType,
      "severity": severity,
      "details": details,
    }),
  );
  print(response.body);
  if (response.statusCode != 200 && response.statusCode != 201) {
    throw Exception("Failed to send SOS");
  }

  final data = jsonDecode(response.body);
  print("SOS Response: $data");
}






static Future<void> acceptRequest(String id) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString("accessToken");

  final url = Uri.parse(
    "https://medpal-production-01b6.up.railway.app/doctor/request/$id/accept"
  );

  final response = await http.patch(
    url,
    headers: {
      "Content-Type": "application/json",
      "Authorization": "System $token",
    },
  );
print(response.body);
  if (response.statusCode != 200 && response.statusCode != 201) {
    throw Exception("Failed to accept request");
  }
}
static Future<List<DoctorNotificationItem>> getDoctorRequests() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString("accessToken");

  final url = Uri.parse(
    "https://medpal-production-01b6.up.railway.app/doctor/requests",
  );

  final response = await http.get(
    url,
    headers: {
      "Content-Type": "application/json",
      "Authorization": "System $token",
    },
  );
  print(response.body);
    print('dewdwedfwedw');

  
String formatTimeAgo(String dateString) {
  final date = DateTime.parse(dateString).toLocal();
  final now = DateTime.now();

  final diff = now.difference(date);

  if (diff.inSeconds < 60) {
    return "Just now";
  } else if (diff.inMinutes < 60) {
    return "${diff.inMinutes} minutes ago";
  } else if (diff.inHours < 24) {
    return "${diff.inHours} hours ago";
  } else if (diff.inDays < 7) {
    return "${diff.inDays} days ago";
  } else {
    return "${date.day}/${date.month}/${date.year}";
  }
}
  final data = jsonDecode(response.body);

  if (response.statusCode == 200) {
    final List list = data["data"];

final allItems = list.map((e) {
  final sender = e["senderId"];
  return DoctorNotificationItem(
    id: e["_id"],
    title: "New Connection Request",
    subtitle: "${sender?["fullName"] ?? "Unknown Patient"} sent you a connection request",
    time: formatTimeAgo(e["createdAt"]),
    type: "request",
    isUnread: true,
    patientName: sender?["fullName"] ?? sender?["email"] ?? "Unknown Patient",
    chatId: sender?["_id"] ?? "",
  );
}).toList();

// ✅ خد آخر request لكل senderId
final Map<String, DoctorNotificationItem> unique = {};
for (final item in allItems) {
  unique[item.chatId] = item; // كل مرة بتعدل على نفس الـ key هياخد الأحدث
}

return unique.values.toList();
  } else {
    throw Exception("failed to load requests");
  }
}
 static Future<Map<String, dynamic>> getDoctorProfile() async {
  final prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString("accessToken");

  if (token == null) {
    throw Exception("Token not found");
  }

  final url = Uri.parse("https://medpal-production-01b6.up.railway.app/doctor/profile");

  final response = await http.get(
    url,
    headers: {
      "Content-Type": "application/json",
      "Authorization": "System $token",
    },
  );

  print(response.body);

  if (response.statusCode == 200) {
    final profileData = jsonDecode(response.body);

    // التأكد من وجود البيانات
    final userDetails = profileData['data']['user'];
    final doctorDetails = profileData['data']['doctor'];

    return {
      'message': 'Doctor profile loaded successfully',
      'data': {
        // بيانات المستخدم
        'fullName': userDetails['fullName'],
        'email': userDetails['email'],
        'phone': userDetails['phone'],
        // بيانات الطبيب
        'specialization': doctorDetails['specialization'],
        // 'clinicLocation': doctorDetails['clinicLocation'],
        // 'experienceYears': doctorDetails['experienceYears'],
        // 'qualification': doctorDetails['qualification'],
'profileImage': userDetails['image']?['secure_url'] ?? '',
       'licenseNumber': doctorDetails['licenseNumbers'], // رقم الترخيص
      }
    };
  } else {
    throw Exception("Failed to load doctor profile: ${response.body}");
  }
} static Future<Map<String, dynamic>> forgetpassword({
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
static Future<void> deleteMedication(String medicationId) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString("accessToken");

  final response = await http.delete(
    Uri.parse("https://medpal-production-01b6.up.railway.app/medication/remove/$medicationId"),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    },
  );

  print("DELETE MED: ${response.statusCode} - ${response.body}");

  if (response.statusCode != 200 && response.statusCode != 201) {
    final data = response.body.isNotEmpty ? jsonDecode(response.body) : {};
    throw Exception(data["message"] ?? "Failed to delete medication");
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
    print(response.body);

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return data;
    } else {
      throw Exception(data["message"] ?? "Reset password failed");
    }
  }




static Future<List<dynamic>> getmydoctors() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString("accessToken");

  final response = await http.get(
    Uri.parse("https://medpal-production-01b6.up.railway.app/patient/doctors"),
    headers: {
      "Authorization": "Bearer $token",
    },
  );
  print(response.body);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data["data"]; // ✅ list
  } else {
    throw Exception("Failed");
  }
}





static Future<Map<String, dynamic>> completeSignup({
  required List<Map<String, dynamic>> chronicDiseases,
  required String allergies,
  required String bloodType,
  required int height,
  required int weight,
  required String note,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString("accessToken");

  final url = Uri.parse('$authBaseUrl/completeSignup');

  final response = await http.patch(
    url,
    headers: {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    },
    body: jsonEncode({
      "chronicDiseases": chronicDiseases,
      "allergies": allergies,
      "bloodType": bloodType,
      "height": height,
      "weight": weight,
      "note": note,
    }),
  );

  final data =
      response.body.isNotEmpty ? jsonDecode(response.body) : {};

  if (response.statusCode == 200 || response.statusCode == 201) {
    return data;
  } else {
    throw Exception(
      data["message"] ??
          "Failed to complete signup: ${response.statusCode} - ${response.body}",
    );
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
    static Future<Map<String, dynamic>> sendContactRequest(String doctorId) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString("accessToken");

    final url = Uri.parse('$userBaseUrl/sendReq/$doctorId');

    final response = await http.patch(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );
    print(response.body);

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return data; 
    } else {
      throw Exception('فشل إرسال طلب الاتصال: ${response.statusCode} - ${response.body}');
    }
  }// ✅ الجديد


  static Future<Map<String, dynamic>> getDoctorReport() async {
  final prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString("accessToken");

  final url = Uri.parse(
    "https://medpal-production-01b6.up.railway.app/doctor/report",
  );

  final response = await http.get(
    url,
    headers: {
      "Content-Type": "application/json",
      "Authorization": "System $token",
    },
  );

  final data = response.body.isNotEmpty ? jsonDecode(response.body) : {};
  print(response.body);

  // ✅ لو 404 = مفيش profile = مش مكتمل، مش error
  if (response.statusCode == 404) {
    return {};
  }

  if (response.statusCode == 200) {
    return data;
  } else {
    throw Exception(
      data["message"] ?? "Failed to load doc report: ${response.statusCode}",
    );
  }
}
static Future<Map<String, dynamic>> getPatientProfile() async {
  final prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString("accessToken");

  final url = Uri.parse(
    "https://medpal-production-01b6.up.railway.app/patient/profile",
  );

  final response = await http.get(
    url,
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    },
  );

  final data = response.body.isNotEmpty ? jsonDecode(response.body) : {};

  // ✅ لو 404 = مفيش profile = مش مكتمل، مش error
  if (response.statusCode == 404) {
    return {};
  }

  if (response.statusCode == 200) {
    return data;
  } else {
    throw Exception(
      data["message"] ?? "Failed to load patient profile: ${response.statusCode}",
    );
  }
}
static Future<Map<String, dynamic>> getPatientById(String patientId) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString("accessToken");

  final url = Uri.parse(
    "https://medpal-production-01b6.up.railway.app/doctor/patient/$patientId",
  );

  final response = await http.get(
    url,
    headers: {
      "Content-Type": "application/json",
      "Authorization": "System $token",
    },
  );
  print(response.body);

  final data =
      response.body.isNotEmpty ? jsonDecode(response.body) : {};

  if (response.statusCode == 200) {
    return data;
  } else {
    throw Exception("Failed to load patient");
  }
}
  // static Future<Map<String, dynamic>> uploadProfileImage(File imageFile) async {
  //   final uri = Uri.parse("$userBaseUrl/image");

  //   final request = http.MultipartRequest('PATCH', uri);

  //   request.headers['Authorization'] = 'Bearer ${UserSession.accessToken}';
  //   request.files.add(
  //     await http.MultipartFile.fromPath('image', imageFile.path),
  //   );

  //   final streamedResponse = await request.send();
  //   final response = await http.Response.fromStream(streamedResponse);

  //   if (response.statusCode == 200 || response.statusCode == 201) {
  //     return jsonDecode(response.body);
  //   } else {
  //     throw Exception('Failed to upload image: ${response.body}');
  //   }
  // }
   static Future<Map<String, dynamic>> uploadProfileImagedoc(File imageFile) async {
    final uri = Uri.parse("$userBaseUrl/image");

    final request = http.MultipartRequest('PATCH', uri);

    request.headers['Authorization'] = 'System ${UserSession.accessToken}';
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
