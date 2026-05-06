import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;
import 'package:record/record.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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
          .setTransports(['websocket', 'polling'])
          .setExtraHeaders({'authorization': token})
          .setAuth({'token': token})
          .disableAutoConnect()
          .build(),
    );

    socket!.connect();

    socket!.onConnect((_) {
      print("✅ Socket Connected: ${socket!.id}");
    });

    socket!.onDisconnect((reason) {
      print("❌ Socket Disconnected — reason: $reason");
    });

    socket!.onConnectError((err) {
      print("⚠️ Connect Error: $err");
    });

    socket!.on('connect_error', (err) {
      print("⚠️ connect_error: $err");
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
    socket?.off("newMessage");
    socket?.on("newMessage", callback);
  }

  void onHistory(Function(dynamic) callback) {
    socket?.off("chatHistory");
    socket?.on("chatHistory", (data) {
      print("📜 CHAT HISTORY received");
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

  /// Step 1: Caller يبعت طلب مكالمة
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

  /// Step 2 (Caller): بعد ما السيرفر يرد بـ callInitiated → ابعت Offer
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

  /// Step 3 (Callee): بعد ما يستقبل Offer → يبعت Answer
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

  /// ICE Candidate
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

  /// إنهاء المكالمة
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

  /// كول وارد جديد (الـ Callee يسمع ده)
  void onIncomingCall(Function(dynamic) callback) {
    socket?.off('incomingCall');
    socket?.on("incomingCall", (data) {
      print("📲 incomingCall received: $data");
      callback(data);
    });
  }

  /// السيرفر أكد بدء المكالمة (الـ Caller يسمع ده)
  /// بعده: الـ Caller يعمل createOffer ويبعت webrtcOffer
  void onCallInitiated(Function(dynamic) callback) {
    socket?.off('callInitiated');
    socket?.on("callInitiated", (data) {
      print("📞 callInitiated received: $data");
      callback(data);
    });
  }

  /// وصل webrtcOffer (الـ Callee يسمع ده)
  /// بعده: يعمل setRemoteDescription + createAnswer + يبعت webrtcAnswer
  void onWebrtcOffer(Function(dynamic) callback) {
    socket?.off('webrtcOffer');
    socket?.on("webrtcOffer", (data) {
      print("🔗 webrtcOffer received");
      callback(data);
    });
  }

  /// وصل webrtcAnswer (الـ Caller يسمع ده)
  /// بعده: يعمل setRemoteDescription → المكالمة شغالة
  void onWebrtcAnswer(Function(dynamic) callback) {
    socket?.off('webrtcAnswer');
    socket?.on("webrtcAnswer", (data) {
      print("🔗 webrtcAnswer received");
      callback(data);
    });
  }

  /// وصل ICE candidate (الطرفين يسمعوا ده)
  void onIceCandidate(Function(dynamic) callback) {
    socket?.off('iceCandidate');
    socket?.on("iceCandidate", (data) {
      print("🧊 iceCandidate received");
      callback(data);
    });
  }

  /// الطرف الثاني رفض المكالمة
  void onCallRejected(Function(dynamic) callback) {
    socket?.off('callRejected');
    socket?.on("callRejected", callback);
  }

  /// المكالمة انتهت (من أي طرف)
  void onCallEnded(Function(dynamic) callback) {
    socket?.off('callEnded');
    socket?.on("callEnded", (data) {
      print("📵 callEnded received");
      callback(data);
    });
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