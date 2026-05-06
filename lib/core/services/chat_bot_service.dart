// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class ChatbotService {
//   static const String _baseUrl =
//       'https://medpal-production-01b6.up.railway.app/chatbot';

//   Future<String> sendMessage(String message) async {
//     try {
//       final response = await http.post(
//         Uri.parse(_baseUrl),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({'message': message}),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         // غيّر 'reply' لو الـ API بيرجع field تاني
//         return data['reply'] ??
//             data['response'] ??
//             data['message'] ??
//             'No response';
//       } else {
//         throw Exception('Server error: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Failed to connect: $e');
//     }
//   }
// }