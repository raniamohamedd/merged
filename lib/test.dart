import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  await testLogin();
}
Future<void> testLogin() async {
  final url = Uri.parse("https://medpal-production-01b6.up.railway.app/auth/login");

  try {
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode({
        "email": "rashadsonbol987@gmail.com",
        "password": "Rashad#123",
      }),
    );

    print("Status code: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("Login successful!");
      print("Access Token: ${data['token']['accessToken']}");
      print("Refresh Token: ${data['token']['refreshToken']}");
    } else {
      print("Login failed with status: ${response.statusCode}");
    }
  } catch (e) {
    print("Login error: $e");
  }
}