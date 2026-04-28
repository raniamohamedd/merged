// import 'package:socket_io_client/socket_io_client.dart' as IO;

// class ChatSocketService {
//   IO.Socket? socket;

//   void connect(String token) {
//     socket = IO.io(
//       'https://medpal-production-e325.up.railway.app/chat',
//       IO.OptionBuilder()
//           .setTransports(['websocket'])
//           .disableAutoConnect()
//           .setAuth({'token': token})
//           .setExtraHeaders({'authorization': token})
//           .build(),
//     );

//     socket!.connect();

//     socket!.onConnect((_) {
//       print("✅ Connected: ${socket!.id}");
//     });

//     socket!.onDisconnect((_) {
//       print("❌ Disconnected");
//     });

//     socket!.onConnectError((err) {
//       print("⚠️ Error: $err");
//     });
//   }

//   void sendMessage(String receiverId, String message) {
//     socket?.emit('sendMessage', {
//       'receiverId': receiverId,
//       'message': message,
//     });
//   }

//   void getHistory(String receiverId) {
//     socket?.emit('getHistory', {
//       'withUserId': receiverId,
//       'page': '1',
//       'limit': '50',
//     });
//   }

//   void onNewMessage(Function(dynamic) callback) {
//     socket?.on('newMessage', callback);
//   }

//   void onMessageSent(Function(dynamic) callback) {
//     socket?.on('messageSent', callback);
//   }

//   void onHistory(Function(dynamic) callback) {
//     socket?.on('chatHistory', callback);
//   }

//   void disconnect() {
//     socket?.disconnect();
//   }
// }