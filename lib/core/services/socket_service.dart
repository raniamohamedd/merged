import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  IO.Socket? socket;

  void connect(String url, String token) {
    socket = IO.io(
      "$url/chat",
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setExtraHeaders({'authorization': token})
          .disableAutoConnect()
          .build(),
    );

    socket!.connect();

    socket!.onConnect((_) => print("Connected"));
  }

  void onMessage(Function(dynamic) callback) {
    socket?.on("newMessage", callback);
  }

  void onHistory(Function(dynamic) callback) {
    socket?.on("chatHistory", callback);
  }

  void sendMessage({
    required String receiverId,
    required String message,
  }) {
    socket?.emit("sendMessage", {
      "receiverId": receiverId,
      "message": message,
    });
  }

  void getHistory(String userId) {
    socket?.emit("getHistory", {
      "withUserId": userId,
      "page": 1,
      "limit": 50,
    });
  }

  void disconnect() {
    socket?.disconnect();
    socket = null;
  }
}