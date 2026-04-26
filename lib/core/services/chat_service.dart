// import 'package:socket_io_client/socket_io_client.dart' as IO;

// class ChatService {
//   late IO.Socket socket;

//   void initSocket() {
//     socket = IO.io('http://localhost:3000', <String, dynamic>{
//       'transports': ['websocket'],
//       'autoConnect': false,
//     });

//     socket.connect();

//     // الاستماع للرسائل الجديدة
//     socket.on('newMessage', (data) {
//       print('Received message: $data');
//     });

//     // استقبال سجل المحادثة
//     socket.on('chatHistory', (data) {
//       print('Chat History: $data');
//     });
//   }

//   // إرسال رسالة
//   void sendMessage(String message, String receiverId) {
//     socket.emit('sendMessage', {
//       'receiverId': receiverId,
//       'message': message,
//     });
//   }

//   // جلب التاريخ
//   void getHistory(String userId) {
//     socket.emit('getHistory', {'withUserId': userId, 'page': '1'});
//   }

//   void closeConnection() {
//     socket.disconnect();
//   }
// }