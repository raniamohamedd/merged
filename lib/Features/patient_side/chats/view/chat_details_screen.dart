// import 'dart:convert';
// import 'dart:io';
// import 'package:audioplayers/audioplayers.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_application_2/core/services/socket_service.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:record/record.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:http/http.dart' as http;

// // ─── Enums ──────────────────────────────────────────────────────────────────
// enum MessageType { text, image, audio, file }

// late SocketService patientChatService;

// // ─── Model ──────────────────────────────────────────────────────────────────
// class ChatMessage {
//   final String text;
//   final bool isMe;
//   final MessageType type;
//   final String time;
//   final DateTime rawTime;
//   final String? filePath;
//   final String? fileUrl;
//   final String? fileName;
//   final String? senderId;

//   ChatMessage({
//     required this.text,
//     required this.isMe,
//     required this.type,
//     required this.time,
//     required this.rawTime,
//     this.filePath,
//     this.fileUrl,
//     this.fileName,
//     this.senderId,
//   });
// }

// // ─── Colors ─────────────────────────────────────────────────────────────────
// class _AppColors {
//   static const blueColor = Color(0xFF1976D2);
//   static const whiteColor = Colors.white;
//   static const backgroundColor = Color(0xFFF7FAFC);
//   static const chatBubbleMe = Color(0xFF1976D2);
//   static const chatBubbleOther = Colors.white;
// }

// String _patientMyUserId = "";

// DateTime _parseDate(dynamic value) {
//   if (value == null) return DateTime.now();
//   if (value is DateTime) return value;
//   try {
//     return DateTime.parse(value.toString()).toLocal();
//   } catch (_) {
//     return DateTime.now();
//   }
// }

// String _formatTime(DateTime dt) =>
//     '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

// String _dateLabel(DateTime dt) {
//   final now = DateTime.now();
//   if (dt.year == now.year && dt.month == now.month && dt.day == now.day)
//     return 'Today';
//   final yesterday = now.subtract(const Duration(days: 1));
//   if (dt.year == yesterday.year &&
//       dt.month == yesterday.month &&
//       dt.day == yesterday.day) return 'Yesterday';
//   return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
// }

// // ─── Upload Helper ───────────────────────────────────────────────────────────
// Future<String?> _uploadFileToServer(File file, String token) async {
//   try {
//     final request = http.MultipartRequest(
//       'POST',
//       Uri.parse('https://medpal-production-e325.up.railway.app/upload'),
//     );
//     request.headers['Authorization'] = 'System $token';
//     request.files.add(await http.MultipartFile.fromPath('file', file.path));
//     final streamed = await request.send();
//     final response = await http.Response.fromStream(streamed);
//     if (response.statusCode == 200 || response.statusCode == 201) {
//       final data = jsonDecode(response.body);
//       return data['url'] ?? data['secure_url'] ?? data['data']?['url'];
//     }
//     return null;
//   } catch (_) {
//     return null;
//   }
// }

// MessageType _parseMessageType(dynamic val) {
//   final v = (val ?? '').toString().toLowerCase();
//   if (v.contains('image')) return MessageType.image;
//   if (v.contains('audio')) return MessageType.audio;
//   if (v.contains('file')) return MessageType.file;
//   return MessageType.text;
// }

// // ─── Screen ─────────────────────────────────────────────────────────────────
// class ChatsPagePatient extends StatefulWidget {
//   final String doctorName;
//   final String chatId;
//   final String? doctorImageUrl;

//   const ChatsPagePatient({
//     super.key,
//     required this.doctorName,
//     required this.chatId,
//     this.doctorImageUrl,
//   });

//   @override
//   State<ChatsPagePatient> createState() => _ChatsPagePatientState();
// }

// class _ChatsPagePatientState extends State<ChatsPagePatient>
//     with TickerProviderStateMixin {
//   final ScrollController _scrollController = ScrollController();
//   final ImagePicker _picker = ImagePicker();
//   final AudioPlayer _audioPlayer = AudioPlayer();
//   final AudioRecorder _audioRecorder = AudioRecorder();

//   String? _currentlyPlayingPath;
//   bool _isPlayingAudio = false;
//   bool _isRecording = false;
//   int _recordSeconds = 0;
//   bool _isSendingMedia = false;

//   String _accessToken = '';

//   String get receiverId => widget.chatId;
//   final List<ChatMessage> messages = [];

//   // ── init socket ────────────────────────────────────────────────────────────
//   Future<void> _initSocket() async {
//     final prefs = await SharedPreferences.getInstance();
//     _accessToken = prefs.getString("accessToken") ?? "";
//     _patientMyUserId = prefs.getString("userId") ?? "";

//     patientChatService = SocketService();
//     patientChatService.connect(
//       "https://medpal-production-e325.up.railway.app",
//       "System $_accessToken",
//     );

//     patientChatService.onMessage((msg) {
//       if (!mounted) return;
//       final dt = _parseDate(msg['createdAt']);
//       final msgType = _parseMessageType(msg['messageType'] ?? msg['type']);
//       final attachment = msg['attachment'];
//       setState(() {
//         messages.insert(
//           0,
//           ChatMessage(
//             text: msg['message'] ?? msg['text'] ?? "",
//             isMe: msg['senderId'] != receiverId,
//             type: msgType,
//             time: _formatTime(dt),
//             rawTime: dt,
//             fileUrl: attachment != null
//                 ? attachment['secure_url']
//                 : msg['fileUrl'],
//             fileName: attachment != null
//                 ? attachment['fileName']
//                 : msg['fileName'],
//             senderId: msg['senderId'],
//           ),
//         );
//       });
//     });

//     patientChatService.onHistory((data) {
//       if (!mounted) return;
//       final list = data is List ? data : (data['messages'] ?? []);
//       final parsed = <ChatMessage>[];
//       for (final m in list) {
//         final dt = _parseDate(m['createdAt']);
//         final msgType = _parseMessageType(m['messageType'] ?? m['type']);
//         final attachment = m['attachment'];
//         parsed.add(ChatMessage(
//           text: m['message'] ?? m['text'] ?? "",
//           isMe: m['senderId'] != receiverId,
//           type: msgType,
//           time: _formatTime(dt),
//           rawTime: dt,
//           fileUrl: attachment != null
//               ? attachment['secure_url']
//               : m['fileUrl'],
//           fileName: attachment != null
//               ? attachment['fileName']
//               : m['fileName'],
//           senderId: m['senderId'],
//         ));
//       }
//       setState(() {
//         messages.clear();
//         messages.addAll(parsed.reversed.toList());
//       });
//     });

//     // ── incoming call ──────────────────────────────────────────────────────
//     patientChatService.onIncomingCall((data) {
//       if (!mounted) return;
//       _showIncomingCallDialog(data);
//     });

//     patientChatService.onCallEnded((_) {
//       if (!mounted) return;
//       Navigator.of(context, rootNavigator: true).popUntil(
//         (route) => route.isFirst || route.settings.name == '/chat',
//       );
//     });

//     patientChatService.getHistory(receiverId);
//   }

//   @override
//   void initState() {
//     super.initState();
//     _initSocket();
//     _audioPlayer.onPlayerStateChanged.listen((state) {
//       if (!mounted) return;
//       setState(() => _isPlayingAudio = state == PlayerState.playing);
//     });
//     _audioPlayer.onPlayerComplete.listen((_) {
//       if (!mounted) return;
//       setState(() {
//         _currentlyPlayingPath = null;
//         _isPlayingAudio = false;
//       });
//     });
//   }

//   @override
//   void dispose() {
//     patientChatService.disconnect();
//     _scrollController.dispose();
//     _audioPlayer.dispose();
//     _audioRecorder.dispose();
//     super.dispose();
//   }

//   // ── SEND TEXT ─────────────────────────────────────────────────────────────
//   void _sendTextMessage(String text) {
//     if (text.trim().isEmpty) return;
//     patientChatService.sendMessage(receiverId: receiverId, message: text);
//     final now = DateTime.now();
//     setState(() {
//       messages.insert(
//         0,
//         ChatMessage(
//           text: text,
//           isMe: true,
//           type: MessageType.text,
//           time: _formatTime(now),
//           rawTime: now,
//         ),
//       );
//     });
//   }

//   // ── SEND MEDIA ────────────────────────────────────────────────────────────
//   Future<void> _sendMediaMessage({
//     required File file,
//     required MessageType type,
//     String? fileName,
//   }) async {
//     setState(() => _isSendingMedia = true);
//     try {
//       final url = await _uploadFileToServer(file, _accessToken);
//       if (url == null) {
//         _showSnack('Upload failed. Check your connection.');
//         return;
//       }
//       patientChatService.socket?.emitWithAck(
//         'sendMessage',
//         {
//           'receiverId': receiverId,
//           'message': fileName ?? _typeLabel(type),
//           'type': type.name,
//           'attachment': {
//             'secure_url': url,
//             'fileName': fileName ?? '',
//           }
//         },
//         ack: (response) {
//           print("📩 SEND RESPONSE: $response");
//         },
//       );
//       final now = DateTime.now();
//       setState(() {
//         messages.insert(
//           0,
//           ChatMessage(
//             text: fileName ?? _typeLabel(type),
//             isMe: true,
//             type: type,
//             time: _formatTime(now),
//             rawTime: now,
//             filePath: file.path,
//             fileUrl: url,
//             fileName: fileName,
//           ),
//         );
//       });
//     } catch (e) {
//       _showSnack('Error sending media: $e');
//     } finally {
//       if (mounted) setState(() => _isSendingMedia = false);
//     }
//   }

//   String _typeLabel(MessageType t) {
//     switch (t) {
//       case MessageType.image:
//         return '📷 Image';
//       case MessageType.audio:
//         return '🎤 Voice message';
//       case MessageType.file:
//         return '📎 File';
//       default:
//         return '';
//     }
//   }

//   // ── PICK IMAGE ────────────────────────────────────────────────────────────
//   Future<void> _pickImageFromGallery() async {
//     final image =
//         await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
//     if (image == null) return;
//     await _sendMediaMessage(file: File(image.path), type: MessageType.image);
//   }

//   Future<void> _captureImageFromCamera() async {
//     final image =
//         await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
//     if (image == null) return;
//     await _sendMediaMessage(file: File(image.path), type: MessageType.image);
//   }

//   // ── PICK FILE ─────────────────────────────────────────────────────────────
//   Future<void> _pickFile() async {
//     final result = await FilePicker.platform.pickFiles(
//       type: FileType.custom,
//       allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'xlsx', 'pptx'],
//     );
//     if (result == null) return;
//     final f = result.files.first;
//     if (f.path == null) return;
//     await _sendMediaMessage(
//       file: File(f.path!),
//       type: MessageType.file,
//       fileName: f.name,
//     );
//   }

//   // ── RECORDING ─────────────────────────────────────────────────────────────
//   Future<void> _startRecording() async {
//     final hasPermission = await _audioRecorder.hasPermission();
//     if (!hasPermission) return;
//     final dir = await getTemporaryDirectory();
//     final path =
//         '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
//     await _audioRecorder.start(const RecordConfig(), path: path);
//     setState(() {
//       _isRecording = true;
//       _recordSeconds = 0;
//     });
//     _tickRecordTimer();
//   }

//   void _tickRecordTimer() async {
//     while (_isRecording && mounted) {
//       await Future.delayed(const Duration(seconds: 1));
//       if (mounted && _isRecording) setState(() => _recordSeconds++);
//     }
//   }

//   Future<void> _stopRecording() async {
//     final path = await _audioRecorder.stop();
//     setState(() {
//       _isRecording = false;
//       _recordSeconds = 0;
//     });
//     if (path != null && File(path).existsSync()) {
//       await _sendMediaMessage(
//         file: File(path),
//         type: MessageType.audio,
//         fileName: 'voice_message.m4a',
//       );
//     }
//   }

//   Future<void> _cancelRecording() async {
//     await _audioRecorder.stop();
//     setState(() {
//       _isRecording = false;
//       _recordSeconds = 0;
//     });
//   }

//   // ── PLAY AUDIO ────────────────────────────────────────────────────────────
//   Future<void> _toggleAudio(ChatMessage msg) async {
//     final source =
//         msg.filePath != null && File(msg.filePath!).existsSync()
//             ? msg.filePath!
//             : msg.fileUrl;
//     if (source == null) return;

//     if (_currentlyPlayingPath == source && _isPlayingAudio) {
//       await _audioPlayer.pause();
//       setState(() => _isPlayingAudio = false);
//     } else {
//       await _audioPlayer.stop();
//       if (msg.filePath != null && File(msg.filePath!).existsSync()) {
//         await _audioPlayer.play(DeviceFileSource(msg.filePath!));
//       } else if (msg.fileUrl != null) {
//         await _audioPlayer.play(UrlSource(msg.fileUrl!));
//       }
//       setState(() {
//         _currentlyPlayingPath = source;
//         _isPlayingAudio = true;
//       });
//     }
//   }

//   // ── CALL ──────────────────────────────────────────────────────────────────
//   void _initiateCall() {
//     patientChatService.socket?.emit('initiateCall', {
//       'receiverId': receiverId,
//       'callType': 'audio',
//     });
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => CallScreen(
//           callerName: widget.doctorName,
//           isIncoming: false,
//           onHangUp: () {
//             patientChatService.socket?.emit('endCall', {'receiverId': receiverId});
//           },
//         ),
//       ),
//     );
//   }

//   void _showIncomingCallDialog(dynamic data) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: const Text('Incoming Call'),
//         content: Text('${data['callerName'] ?? 'Doctor'} is calling you...'),
//         actions: [
//           TextButton.icon(
//             icon: const Icon(Icons.call_end, color: Colors.red),
//             label: const Text('Reject', style: TextStyle(color: Colors.red)),
//             onPressed: () {
//               patientChatService.socket
//                   ?.emit('rejectCall', {'callerId': data['callerId']});
//               Navigator.pop(context);
//             },
//           ),
//           ElevatedButton.icon(
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
//             icon: const Icon(Icons.call, color: Colors.white),
//             label:
//                 const Text('Accept', style: TextStyle(color: Colors.white)),
//             onPressed: () {
//               patientChatService.socket
//                   ?.emit('acceptCall', {'callerId': data['callerId']});
//               Navigator.pop(context);
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => CallScreen(
//                     callerName:
//                         data['callerName'] ?? widget.doctorName,
//                     isIncoming: true,
//                     onHangUp: () {
//                       patientChatService.socket?.emit(
//                           'endCall', {'receiverId': data['callerId']});
//                     },
//                   ),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   void _showSnack(String msg) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context)
//         .showSnackBar(SnackBar(content: Text(msg)));
//   }

//   String _formatRecordTime(int s) =>
//       '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

//   // ── BUILD ─────────────────────────────────────────────────────────────────
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: _AppColors.backgroundColor,
//       body: Column(
//         children: [
//           _buildHeader(),
//           if (_isSendingMedia)
//             const LinearProgressIndicator(
//                 backgroundColor: Color(0xFFE3F0FF),
//                 color: _AppColors.blueColor),
//           Expanded(
//             child: ListView.builder(
//               reverse: true,
//               controller: _scrollController,
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//               itemCount: _buildItems().length,
//               itemBuilder: (_, i) {
//                 final item = _buildItems()[i];
//                 if (item is String) return _buildDateDivider(item);
//                 return _buildMessage(item as ChatMessage);
//               },
//             ),
//           ),
//           if (_isRecording) _buildRecordingBar(),
//           _buildInputBar(),
//         ],
//       ),
//     );
//   }

//   List<dynamic> _buildItems() {
//     final items = <dynamic>[];
//     String? lastLabel;
//     for (final msg in messages) {
//       final label = _dateLabel(msg.rawTime);
//       if (label != lastLabel) {
//         items.add(label);
//         lastLabel = label;
//       }
//       items.add(msg);
//     }
//     return items;
//   }

//   // ── HEADER ────────────────────────────────────────────────────────────────
//   Widget _buildHeader() {
//     return Container(
//       padding: EdgeInsets.only(
//         top: MediaQuery.of(context).padding.top + 8,
//         bottom: 12,
//         left: 8,
//         right: 8,
//       ),
//       decoration: const BoxDecoration(
//         color: _AppColors.blueColor,
//         borderRadius: BorderRadius.only(
//           bottomLeft: Radius.circular(24),
//           bottomRight: Radius.circular(24),
//         ),
//       ),
//       child: Row(
//         children: [
//           IconButton(
//             onPressed: () => Navigator.pop(context),
//             icon: const Icon(Icons.arrow_back_ios_new,
//                 color: Colors.white, size: 18),
//             padding: EdgeInsets.zero,
//             constraints: const BoxConstraints(),
//           ),
//           const SizedBox(width: 10),
//           CircleAvatar(
//             radius: 20,
//             backgroundColor: Colors.white24,
//             backgroundImage: (widget.doctorImageUrl != null &&
//                     widget.doctorImageUrl!.isNotEmpty)
//                 ? NetworkImage(widget.doctorImageUrl!)
//                 : null,
//             child: (widget.doctorImageUrl == null ||
//                     widget.doctorImageUrl!.isEmpty)
//                 ? const Icon(Icons.person, color: Colors.white)
//                 : null,
//           ),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   widget.doctorName,
//                   style: const TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16),
//                 ),
//                 Row(
//                   children: [
//                     Container(
//                       width: 7,
//                       height: 7,
//                       decoration: const BoxDecoration(
//                           color: Color(0xFF69F0AE), shape: BoxShape.circle),
//                     ),
//                     const SizedBox(width: 4),
//                     const Text('Online',
//                         style:
//                             TextStyle(color: Colors.white70, fontSize: 12)),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           IconButton(
//             onPressed: _initiateCall,
//             icon: Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(.2),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: const Icon(Icons.call_rounded,
//                   color: Colors.white, size: 20),
//             ),
//             padding: EdgeInsets.zero,
//           ),
//         ],
//       ),
//     );
//   }

//   // ── DATE DIVIDER ──────────────────────────────────────────────────────────
//   Widget _buildDateDivider(String label) {
//     return Center(
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 8),
//         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
//         decoration: BoxDecoration(
//           color: Colors.black12,
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Text(label,
//             style: const TextStyle(fontSize: 12, color: Colors.black54)),
//       ),
//     );
//   }

//   // ── MESSAGE BUBBLE ────────────────────────────────────────────────────────
//   Widget _buildMessage(ChatMessage msg) {
//     final isMe = msg.isMe;
//     return Align(
//       alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 4),
//         constraints: BoxConstraints(
//             maxWidth: MediaQuery.of(context).size.width * 0.72),
//         decoration: BoxDecoration(
//           color: isMe ? _AppColors.chatBubbleMe : _AppColors.chatBubbleOther,
//           borderRadius: BorderRadius.only(
//             topLeft: const Radius.circular(18),
//             topRight: const Radius.circular(18),
//             bottomLeft: Radius.circular(isMe ? 18 : 4),
//             bottomRight: Radius.circular(isMe ? 4 : 18),
//           ),
//           boxShadow: [
//             BoxShadow(
//                 color: Colors.black.withOpacity(.07),
//                 blurRadius: 6,
//                 offset: const Offset(0, 2))
//           ],
//         ),
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildMessageContent(msg),
//             const SizedBox(height: 4),
//             Text(
//               msg.time,
//               style: TextStyle(
//                   fontSize: 10,
//                   color: isMe ? Colors.white60 : Colors.black38),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildMessageContent(ChatMessage msg) {
//     final isMe = msg.isMe;
//     switch (msg.type) {
//       case MessageType.image:
//         final src = msg.filePath != null && File(msg.filePath!).existsSync()
//             ? FileImage(File(msg.filePath!)) as ImageProvider
//             : (msg.fileUrl != null ? NetworkImage(msg.fileUrl!) : null);
//         return ClipRRect(
//           borderRadius: BorderRadius.circular(12),
//           child: src != null
//               ? Image(
//                   image: src,
//                   width: 200,
//                   height: 160,
//                   fit: BoxFit.cover,
//                 )
//               : const Icon(Icons.image_not_supported, color: Colors.grey),
//         );

//       case MessageType.audio:
//         final isThisPlaying = _currentlyPlayingPath != null &&
//             (_currentlyPlayingPath == msg.filePath ||
//                 _currentlyPlayingPath == msg.fileUrl) &&
//             _isPlayingAudio;
//         return GestureDetector(
//           onTap: () => _toggleAudio(msg),
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(
//                 isThisPlaying
//                     ? Icons.pause_circle_filled
//                     : Icons.play_circle_filled,
//                 color: isMe ? Colors.white : _AppColors.blueColor,
//                 size: 32,
//               ),
//               const SizedBox(width: 8),
//               Text(
//                 'Voice message',
//                 style: TextStyle(
//                     color: isMe ? Colors.white : Colors.black87,
//                     fontSize: 14),
//               ),
//             ],
//           ),
//         );

//       case MessageType.file:
//         return GestureDetector(
//           onTap: () async {
//             final url = msg.fileUrl;
//             if (url != null) {
//               final uri = Uri.parse(url);
//               if (await canLaunchUrl(uri)) await launchUrl(uri);
//             }
//           },
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(Icons.insert_drive_file,
//                   color: isMe ? Colors.white : _AppColors.blueColor),
//               const SizedBox(width: 8),
//               Flexible(
//                 child: Text(
//                   msg.fileName ?? 'File',
//                   style: TextStyle(
//                     color: isMe ? Colors.white : Colors.black87,
//                     decoration: TextDecoration.underline,
//                   ),
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//             ],
//           ),
//         );

//       default:
//         return Text(
//           msg.text,
//           style: TextStyle(
//               color: isMe ? Colors.white : Colors.black87, fontSize: 15),
//         );
//     }
//   }

//   // ── RECORDING BAR ─────────────────────────────────────────────────────────
//   Widget _buildRecordingBar() {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//       decoration: BoxDecoration(
//         color: Colors.red.shade50,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.red.shade200),
//       ),
//       child: Row(
//         children: [
//           const Icon(Icons.mic, color: Colors.red),
//           const SizedBox(width: 8),
//           Text(
//             'Recording ${_formatRecordTime(_recordSeconds)}',
//             style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
//           ),
//           const Spacer(),
//           IconButton(
//             icon: const Icon(Icons.close, color: Colors.red),
//             onPressed: _cancelRecording,
//             padding: EdgeInsets.zero,
//             constraints: const BoxConstraints(),
//           ),
//           const SizedBox(width: 8),
//           IconButton(
//             icon: const Icon(Icons.stop_circle, color: Colors.green, size: 28),
//             onPressed: _stopRecording,
//             padding: EdgeInsets.zero,
//             constraints: const BoxConstraints(),
//           ),
//         ],
//       ),
//     );
//   }

//   // ── INPUT BAR ─────────────────────────────────────────────────────────────
//   Widget _buildInputBar() {
//     return _PatientChatInput(
//       onSendText: _sendTextMessage,
//       onPickImage: _pickImageFromGallery,
//       onCamera: _captureImageFromCamera,
//       onPickFile: _pickFile,
//       onStartRecord: _startRecording,
//       isRecording: _isRecording,
//     );
//   }
// }

// // ─── Input Widget ─────────────────────────────────────────────────────────────
// class _PatientChatInput extends StatefulWidget {
//   final Function(String) onSendText;
//   final VoidCallback onPickImage;
//   final VoidCallback onCamera;
//   final VoidCallback onPickFile;
//   final VoidCallback onStartRecord;
//   final bool isRecording;

//   const _PatientChatInput({
//     required this.onSendText,
//     required this.onPickImage,
//     required this.onCamera,
//     required this.onPickFile,
//     required this.onStartRecord,
//     required this.isRecording,
//   });

//   @override
//   State<_PatientChatInput> createState() => _PatientChatInputState();
// }

// class _PatientChatInputState extends State<_PatientChatInput> {
//   final TextEditingController _controller = TextEditingController();
//   bool _hasText = false;

//   @override
//   void initState() {
//     super.initState();
//     _controller.addListener(() {
//       setState(() => _hasText = _controller.text.trim().isNotEmpty);
//     });
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   void _send() {
//     if (_controller.text.trim().isEmpty) return;
//     widget.onSendText(_controller.text.trim());
//     _controller.clear();
//   }

//   void _showAttachMenu() {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (_) => SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               _attachOption(
//                   Icons.photo_library, 'Gallery', widget.onPickImage),
//               _attachOption(
//                   Icons.camera_alt, 'Camera', widget.onCamera),
//               _attachOption(
//                   Icons.insert_drive_file, 'File', widget.onPickFile),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _attachOption(IconData icon, String label, VoidCallback onTap) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.pop(context);
//         onTap();
//       },
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           CircleAvatar(
//             radius: 28,
//             backgroundColor: const Color(0xFF1976D2).withOpacity(.1),
//             child: Icon(icon, color: const Color(0xFF1976D2), size: 26),
//           ),
//           const SizedBox(height: 6),
//           Text(label, style: const TextStyle(fontSize: 12)),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.only(
//         left: 8,
//         right: 8,
//         top: 8,
//         bottom: MediaQuery.of(context).padding.bottom + 8,
//       ),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//               color: Colors.black.withOpacity(.07),
//               blurRadius: 8,
//               offset: const Offset(0, -2))
//         ],
//       ),
//       child: Row(
//         children: [
//           IconButton(
//             icon: const Icon(Icons.attach_file,
//                 color: Color(0xFF1976D2)),
//             onPressed: _showAttachMenu,
//           ),
//           Expanded(
//             child: TextField(
//               controller: _controller,
//               textCapitalization: TextCapitalization.sentences,
//               decoration: InputDecoration(
//                 hintText: 'Type a message...',
//                 filled: true,
//                 fillColor: const Color(0xFFF0F4F8),
//                 contentPadding: const EdgeInsets.symmetric(
//                     horizontal: 16, vertical: 10),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(24),
//                   borderSide: BorderSide.none,
//                 ),
//               ),
//               onSubmitted: (_) => _send(),
//             ),
//           ),
//           const SizedBox(width: 6),
//           GestureDetector(
//             onTap: _hasText ? _send : widget.onStartRecord,
//             child: CircleAvatar(
//               radius: 22,
//               backgroundColor: const Color(0xFF1976D2),
//               child: Icon(
//                 _hasText ? Icons.send : Icons.mic,
//                 color: Colors.white,
//                 size: 20,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ─── Call Screen ─────────────────────────────────────────────────────────────
// class CallScreen extends StatefulWidget {
//   final String callerName;
//   final bool isIncoming;
//   final VoidCallback onHangUp;

//   const CallScreen({
//     super.key,
//     required this.callerName,
//     required this.isIncoming,
//     required this.onHangUp,
//   });

//   @override
//   State<CallScreen> createState() => _CallScreenState();
// }

// class _CallScreenState extends State<CallScreen> {
//   bool _muted = false;
//   bool _speakerOn = false;
//   int _seconds = 0;
//   late final _timer = Stream.periodic(const Duration(seconds: 1))
//       .listen((_) => mounted ? setState(() => _seconds++) : null);

//   @override
//   void dispose() {
//     _timer.cancel();
//     super.dispose();
//   }

//   String get _duration {
//     final m = (_seconds ~/ 60).toString().padLeft(2, '0');
//     final s = (_seconds % 60).toString().padLeft(2, '0');
//     return '$m:$s';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF1A237E),
//       body: SafeArea(
//         child: Column(
//           children: [
//             const SizedBox(height: 60),
//             const CircleAvatar(
//               radius: 60,
//               backgroundColor: Colors.white24,
//               child: Icon(Icons.person, size: 60, color: Colors.white),
//             ),
//             const SizedBox(height: 24),
//             Text(
//               widget.callerName,
//               style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 28,
//                   fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               widget.isIncoming ? _duration : 'Calling...',
//               style: const TextStyle(color: Colors.white60, fontSize: 16),
//             ),
//             const Spacer(),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 _callButton(
//                   icon: _muted ? Icons.mic_off : Icons.mic,
//                   label: _muted ? 'Unmute' : 'Mute',
//                   color: Colors.white24,
//                   onTap: () => setState(() => _muted = !_muted),
//                 ),
//                 _callButton(
//                   icon: Icons.call_end,
//                   label: 'End',
//                   color: Colors.red,
//                   onTap: () {
//                     widget.onHangUp();
//                     Navigator.pop(context);
//                   },
//                   size: 64,
//                 ),
//                 _callButton(
//                   icon: _speakerOn ? Icons.volume_up : Icons.volume_down,
//                   label: 'Speaker',
//                   color: Colors.white24,
//                   onTap: () => setState(() => _speakerOn = !_speakerOn),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 50),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _callButton({
//     required IconData icon,
//     required String label,
//     required Color color,
//     required VoidCallback onTap,
//     double size = 52,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Column(
//         children: [
//           CircleAvatar(
//             radius: size / 2,
//             backgroundColor: color,
//             child: Icon(icon, color: Colors.white, size: size * 0.5),
//           ),
//           const SizedBox(height: 8),
//           Text(label,
//               style:
//                   const TextStyle(color: Colors.white70, fontSize: 12)),
//         ],
//       ),
//     );
//   }
// }