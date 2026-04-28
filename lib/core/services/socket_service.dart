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
          .setTransports(['polling', 'websocket'])
          .setExtraHeaders({'authorization': token})
          .setAuth({'token': token})
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
    // socket?.disconnect();
    // socket = null;
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
  // 📞 CALL EVENTS — EMIT
  // =========================

  /// ابعت طلب مكالمة للطرف الثاني
  void initiateCall({
    required String receiverId,
    String callType = 'voice',
  }) {
    socket?.emit('initiateCall', {
      'receiverId': receiverId,
      'callType': callType,
    });
    print("📞 initiateCall → $receiverId ($callType)");
  }

  /// ابعت WebRTC Offer
  void sendWebrtcOffer({
    required String receiverId,
    required Map<String, dynamic> offer,
    String? callId,
  }) {
    socket?.emit('webrtcOffer', {
      'receiverId': receiverId,
      'offer': offer,
      if (callId != null) 'callId': callId,
    });
    print("🔗 webrtcOffer → $receiverId");
  }

  /// ابعت WebRTC Answer
  void sendWebrtcAnswer({
    required String receiverId,
    required Map<String, dynamic> answer,
    String? callId,
  }) {
    socket?.emit('webrtcAnswer', {
      'receiverId': receiverId,
      'answer': answer,
      if (callId != null) 'callId': callId,
    });
    print("🔗 webrtcAnswer → $receiverId");
  }

  /// ابعت ICE Candidate
  void sendIceCandidate({
    required String receiverId,
    required Map<String, dynamic> candidate,
  }) {
    socket?.emit('iceCandidate', {
      'receiverId': receiverId,
      'candidate': candidate,
    });
    print("🧊 iceCandidate → $receiverId");
  }

  /// رفض مكالمة واردة
  void rejectCall({required String callerId}) {
    socket?.emit('rejectCall', {'callerId': callerId});
    print("❌ rejectCall ← $callerId");
  }

  /// إنهاء المكالمة الحالية
  void endCall({required String receiverId, String? callId, int? duration}) {
    socket?.emit('endCall', {
      'receiverId': receiverId,
      if (callId != null) 'callId': callId,
      if (duration != null) 'duration': duration,
    });
    print("📴 endCall → $receiverId");
  }

  // =========================
  // 📡 CALL EVENTS — LISTEN
  // =========================

  /// كول وارد جديد
  void onIncomingCall(Function(dynamic) callback) {
    socket?.off('incomingCall'); // avoid duplicates
    socket?.on("incomingCall", callback);
  }

  /// السيرفر أكد بدء المكالمة (بعد initiateCall)
  void onCallInitiated(Function(dynamic) callback) {
    socket?.off('callInitiated');
    socket?.on("callInitiated", callback);
  }

  /// وصل webrtcOffer من الطرف الثاني
  void onWebrtcOffer(Function(dynamic) callback) {
    socket?.off('webrtcOffer');
    socket?.on("webrtcOffer", callback);
  }

  /// وصل webrtcAnswer من الطرف الثاني
  void onWebrtcAnswer(Function(dynamic) callback) {
    socket?.off('webrtcAnswer');
    socket?.on("webrtcAnswer", callback);
  }

  /// وصل ICE candidate
  void onIceCandidate(Function(dynamic) callback) {
    socket?.off('iceCandidate');
    socket?.on("iceCandidate", callback);
  }

  /// الطرف الثاني رفض المكالمة
  void onCallRejected(Function(dynamic) callback) {
    socket?.off('callRejected');
    socket?.on("callRejected", callback);
  }

  /// المكالمة انتهت (من أي طرف)
  void onCallEnded(Function(dynamic) callback) {
    socket?.off('callEnded');
    socket?.on("callEnded", callback);
  }

  /// الطرف الثاني قبل المكالمة
  void onCallAccepted(Function(dynamic) callback) {
    socket?.off('callAccepted');
    socket?.on("callAccepted", callback);
  }

  // =========================
  // 🧠 UTIL
  // =========================
  bool get isConnected => socket?.connected ?? false;
}