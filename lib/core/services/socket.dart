// import 'dart:io' as IO;

// import 'package:socket_io_client/socket_io_client.dart' as IO;

// class SocketService {
//   IO.Socket socket;

//   SocketService(String jwtToken) : socket = IO.io('http://localhost:3000/chat', {
//     'transports': ['websocket'],
//     'extraHeaders': {'authorization': 'Bearer $jwtToken'}
//   });

//   void initializeSocket() {
//     socket.on('newMessage', (msg) {
//       print("رسالة جديدة: $msg");
//     });
//   }

//   void sendMessage(String receiverId, String message) {
//     socket.emit('sendMessage', {
//       'receiverId': receiverId,
//       'message': message,
//     });
//   }

//   void closeSocket() {
//     socket.disconnect();
//   }
// }