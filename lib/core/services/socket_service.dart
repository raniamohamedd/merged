import 'dart:io';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;
import 'package:record/record.dart';
import 'package:image_picker/image_picker.dart';

class SocketService {
  IO.Socket? socket;

  final AudioRecorder _recorder = AudioRecorder();

  // =========================
  // 🔌 CONNECT
  // =========================
  void connect(String url, String token) {
    socket = IO.io(
      "$url/chat",
      IO.OptionBuilder()
          .setTransports(['polling', 'websocket']) // ← polling أول زي HTML Tester
          .setExtraHeaders({'authorization': token})
          .setAuth({'token': token})              // ← بيبعت التوكن في auth كمان
          .disableAutoConnect()
          .build(),
    );

    socket!.connect();

    socket!.onConnect((_) {
      print("✅ Connected: ${socket!.id}");
    });

    socket!.onDisconnect((reason) {
      print("❌ Disconnected — reason: $reason");
    });

    socket!.onConnectError((err) {
      print("⚠️ Connect Error: $err");
    });

    socket!.on('connect_error', (err) {
      print("⚠️ connect_error event: $err");
    });

    socket!.on('error', (err) {
      print("🔴 Socket error: $err");
    });
  }

  void disconnect() {
    socket?.disconnect();
    socket = null;
  }

  // =========================
  // 📩 MESSAGES
  // =========================
  void onMessage(Function(dynamic) callback) {
    socket?.on("newMessage", (data) {
      callback(data);
    });
  }

  void onHistory(Function(dynamic) callback) {
    socket?.on("chatHistory", (data) {
      print("📜 CHAT HISTORY RAW RESPONSE: $data");
      callback(data);
    });
  }

  void sendMessage({
    required String receiverId,
    required String message,
  }) {
    socket?.emit("sendMessage", {
      "receiverId": receiverId,
      "message": message,
      "type": "text",
    });
  }

  void getHistory(String userId) {
    socket?.emit("getHistory", {
      "withUserId": userId,
      "page": 1,
      "limit": 100000,
    });
  }

  // =========================
  // 📷 SEND IMAGE / FILE
  // =========================
  Future<void> sendImage({
    required String url,
    required String token,
    required String receiverId,
  }) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);

    if (file == null) return;

    var request = http.MultipartRequest(
      "POST",
      Uri.parse("$url/chat/upload/$receiverId"),
    );

    request.headers["authorization"] = token;
    request.files.add(await http.MultipartFile.fromPath("file", file.path));

    final response = await request.send();
    final res = await http.Response.fromStream(response);

    print("UPLOAD IMAGE RESPONSE: ${res.body}");
  }

  // =========================
  // 🎙️ RECORD AUDIO
  // =========================
  Future<void> startRecord() async {
    if (await _recorder.hasPermission()) {
      await _recorder.start(const RecordConfig(), path: 'audio.m4a');
      print("🎙️ Recording started");
    }
  }

  Future<void> stopRecord({
    required String url,
    required String token,
    required String receiverId,
  }) async {
    final path = await _recorder.stop();
    if (path == null) return;

    var request = http.MultipartRequest(
      "POST",
      Uri.parse("$url/chat/upload/$receiverId"),
    );

    request.headers["authorization"] = token;
    request.files.add(await http.MultipartFile.fromPath("file", path));

    final response = await request.send();
    final res = await http.Response.fromStream(response);

    print("🎙️ AUDIO UPLOADED: ${res.body}");
  }

  Future<void> cancelRecord() async {
    await _recorder.cancel();
    print("❌ Recording cancelled");
  }

  // =========================
  // 📞 CALL — INITIATE
  // =========================

  /// يبعت طلب كول للطرف الثاني
  void initiateCall({
    required String receiverId,
    String callType = 'audio', // 'audio' or 'video'
  }) {
    socket?.emit('initiateCall', {
      'receiverId': receiverId,
      'callType': callType,
    });
    print("📞 initiateCall → $receiverId ($callType)");
  }

  /// يقبل الكول الوارد
  void acceptCall({required String callerId}) {
    socket?.emit('acceptCall', {'callerId': callerId});
    print("✅ acceptCall ← $callerId");
  }

  /// يرفض الكول الوارد
  void rejectCall({required String callerId}) {
    socket?.emit('rejectCall', {'callerId': callerId});
    print("❌ rejectCall ← $callerId");
  }

  /// ينهي الكول الحالي
  void endCall({required String receiverId}) {
    socket?.emit('endCall', {'receiverId': receiverId});
    print("📴 endCall → $receiverId");
  }

  // =========================
  // 📡 CALL EVENTS — LISTENERS
  // =========================

  /// كول وارد جديد
  void onIncomingCall(Function(dynamic) callback) {
    socket?.on("incomingCall", callback);
  }

  /// الطرف الثاني قبل الكول
  void onCallAccepted(Function(dynamic) callback) {
    socket?.on("callAccepted", callback);
  }

  /// الطرف الثاني رفض الكول
  void onCallRejected(Function(dynamic) callback) {
    socket?.on("callRejected", callback);
  }

  /// الكول انتهى (من أي طرف)
  void onCallEnded(Function(dynamic) callback) {
    socket?.on("callEnded", callback);
  }

  // =========================
  // 🧠 UTIL
  // =========================
  bool get isConnected => socket?.connected ?? false;
}