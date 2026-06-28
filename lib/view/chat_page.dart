import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:discuss/view/search_page.dart';
import 'package:mime/mime.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../model/group_participents.dart';
import '../provider/auth_provider.dart';
import '../provider/chat_provider.dart';
import '../provider/inbox_provider.dart';
import '../provider/marked_read_provider.dart';
import '../provider/reaction_provider.dart';
import '../provider/search_provider.dart';
import '../services/agora_call_invitation_service.dart';
import '../services/call_listener_service.dart';
import '../services/odoo_discuss_service.dart';
import 'agora_call_page.dart';

// class ChatPage extends StatefulWidget {
//   final int? memberId;
//   final List<int> partnerId;
//   final String title;
//   final String? image;
//   final String? email;
//   final String? phone;
//   final String? cookie;
//   final int channelId;
//
//   const ChatPage({
//     super.key,
//     required this.partnerId,
//     required this.title,
//     this.image,
//     this.email,
//     this.phone,
//     this.cookie,
//     required this.channelId,
//     this.memberId,
//   });
//
//   @override
//   State<ChatPage> createState() => _ChatPageState();
// }
//
// class _ChatPageState extends State<ChatPage> {
//   late final TextEditingController _controller;
//   bool _readStatusLoaded = false;
//   late final AgoraCallInvitationService agoraInviteService;
//   CallListenerService? _callListener;
//
//   // CRITICAL CONFIG: Put your App ID from the tokenless test project here
//   static const String testingAppId = "339050bec1fe49b8bc5e17ca9d739fba";
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = TextEditingController();
//
//     // Setup Odoo Call Service Architecture
//     agoraInviteService = AgoraCallInvitationService(
//       callKw: OdooDiscussService(baseUrl: 'http://192.168.250.26:8069').callKw,
//     );
//
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       final auth = context.read<AuthProvider>();
//       final cookie = auth.sessionCookie;
//       final chatProv = context.read<ChatProvider>();
//
//       if (cookie != null && cookie.isNotEmpty) {
//         await chatProv.loadChatMessages(
//           cookie: cookie,
//           channelId: widget.channelId,
//         );
//
//         if (chatProv.messages.isNotEmpty) {
//           final lastId = chatProv.messages.last.id;
//           await chatProv.service.markChannelAsRead(
//             cookie: cookie,
//             channelId: widget.channelId,
//             lastMessageId: lastId,
//           );
//         }
//
//         // Initialize Call Invitation Radar Loop for the Receiver
//         if (auth.partnerId != null) {
//           _callListener = CallListenerService(
//             inviteService: agoraInviteService,
//             cookie: cookie,
//             channelId: widget.channelId,
//             myPartnerId: auth.partnerId!,
//           );
//
//           _callListener!.startListening(
//             onIncomingCall: (inviteData) {
//               _showIncomingCallUi(inviteData);
//             },
//           );
//         }
//       }
//     });
//   }
//
//   void _showIncomingCallUi(Map<String, dynamic> invite) {
//     if (!mounted) return;
//
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           backgroundColor: const Color(0xff101828),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//           title: const Text(
//             "Incoming Call",
//             style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//             textAlign: TextAlign.center,
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Icon(Icons.phone_in_talk, color: Colors.greenAccent, size: 68),
//               const SizedBox(height: 20),
//               Text(
//                 "User ${invite['from_partner_id']} is calling you...",
//                 style: const TextStyle(color: Colors.white70, fontSize: 15),
//                 textAlign: TextAlign.center,
//               ),
//             ],
//           ),
//           actionsAlignment: MainAxisAlignment.spaceEvenly,
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text("Decline", style: TextStyle(color: Colors.redAccent, fontSize: 16)),
//             ),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.green,
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//                 padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
//               ),
//               onPressed: () {
//                 Navigator.pop(context); // Dismiss invitation alert
//
//                 // Receiver enters matching room channel using Agora UIKit
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => AgoraCallPage(
//                      // channelName: invite["agora_channel_name"],
//                       channelName: "test_discuss",
//                       callerName: "Incoming Call",
//                       appId: testingAppId,
//                       token: "007eJxTYOhd4hKf2P1tk69UJF+r1JLbt+adj7RdteKt6LrKH9ufaRspMBgbWxqYGiSlJhumpZpYJlkkJZumGponJ1qmmBtbpiUluotpZjUEMjLcE9jGxMgAgSA+D0NJanFJfEpmcXJpcTEDAwCl1COb",
//                     ),
//                   ),
//                 );
//               },
//               child: const Text("Answer", style: TextStyle(color: Colors.white, fontSize: 16)),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   @override
//   void dispose() {
//     _callListener?.stopListening();
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final prov = context.watch<ChatProvider>();
//     final auth = context.watch<AuthProvider>();
//     final messages = prov.messages;
//     final cookie = auth.sessionCookie;
//     final readProvider = context.watch<MessageReadStatusProvider>();
//
//     if (!_readStatusLoaded &&
//         cookie != null &&
//         cookie.isNotEmpty &&
//         messages.isNotEmpty) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (!mounted) return;
//         final myPartnerId = auth.partnerId;
//         final myMessageIds = messages
//             .where((m) => m.authorId == myPartnerId)
//             .map((m) => m.id)
//             .toList();
//
//         context.read<MessageReadStatusProvider>().loadReadStatus(
//           cookie: cookie,
//           channelId: widget.channelId,
//           messageIds: myMessageIds,
//           myPartnerId: myPartnerId!,
//           myPartnerIds: [],
//         );
//       });
//       _readStatusLoaded = true;
//     }
//
//     return Scaffold(
//       appBar: AppBar(
//         elevation: 0,
//         title: Row(
//           children: [
//             CircleAvatar(
//               radius: 20,
//               backgroundColor: Colors.grey.shade300,
//               child: ClipOval(
//                 child: (widget.image != null && widget.image!.isNotEmpty)
//                     ? Image.network(
//                   widget.image!,
//                   width: 40,
//                   height: 40,
//                   fit: BoxFit.cover,
//                   headers: {if (cookie != null) 'Cookie': cookie},
//                   errorBuilder: (_, __, ___) => const Icon(Icons.person, color: Colors.black54),
//                 )
//                     : const Icon(Icons.person, color: Colors.black54),
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Text(widget.title, overflow: TextOverflow.ellipsis),
//             ),
//             IconButton(
//               icon: const Icon(Icons.add),
//               onPressed: () {
//                 Navigator.of(context).push(
//                   MaterialPageRoute(
//                     builder: (_) => SearchPage(
//                       source: SearchSource.chat,
//                       channelId: widget.channelId,
//                     ),
//                   ),
//                 );
//               },
//             ),
//             IconButton(
//               icon: const Icon(Icons.phone),
//               onPressed: () async {
//                 if (widget.partnerId.isEmpty) return;
//
//                 final authProv = context.read<AuthProvider>();
//                 final myPartnerId = authProv.partnerId;
//                 final sessionCookie = authProv.sessionCookie;
//
//                 if (myPartnerId == null || sessionCookie == null || sessionCookie.isEmpty) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text("Session expired")),
//                   );
//                   return;
//                 }
//
//                 final remotePartnerId = widget.partnerId.firstWhere(
//                       (partnerId) => partnerId != myPartnerId,
//                   orElse: () => widget.partnerId.first,
//                 );
//
//                 // Unified tokenless test channel room string setup
//          //       final agoraChannelName = "discuss_test";
//
//                 await agoraInviteService.sendCallInvitation(
//                   cookie: sessionCookie,
//                   channelId: widget.channelId,
//                   fromPartnerId: myPartnerId,
//                   toPartnerId: remotePartnerId,
//                   agoraChannelName: "test_discuss",
//                 );
//
//                 if (!context.mounted) return;
//
//                 // Caller enters matching video/audio room channel using Agora UIKit
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => AgoraCallPage(
//                       channelName: "test_discuss",
//                       callerName: widget.title,
//                       appId: testingAppId,
//                      token: "007eJxTYOhd4hKf2P1tk69UJF+r1JLbt+adj7RdteKt6LrKH9ufaRspMBgbWxqYGiSlJhumpZpYJlkkJZumGponJ1qmmBtbpiUluotpZjUEMjLcE9jGxMgAgSA+D0NJanFJfEpmcXJpcTEDAwCl1COb"
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               itemCount: messages.length,
//               itemBuilder: (_, i) {
//                 final m = messages[i];
//
//                 // --- CRITICAL FILTER: Don't show raw invitation strings to chat layout users ---
//                 if (m.text.contains("AGORA_CALL::")) {
//                   return const SizedBox.shrink();
//                 }
//
//                 final isMe = m.authorId == auth.partnerId;
//                 final isRead = readProvider.isMessageRead(m.id);
//
//                 return Align(
//                   alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
//                   child: GestureDetector(
//                     onTap: () {
//                       showModalBottomSheet(
//                         context: context,
//                         builder: (_) {
//                           final emojis = ['👍', '❤️', '😂', '😮', '😢', '🙏'];
//                           return Padding(
//                             padding: const EdgeInsets.all(16),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                               children: emojis.map((emoji) {
//                                 return InkWell(
//                                   onTap: () async {
//                                     Navigator.pop(context);
//                                     final reactionProvider = context.read<ReactionProvider>();
//                                     await reactionProvider.reactToMessage(
//                                       cookie: cookie!,
//                                       messageId: m.id,
//                                       emoji: emoji,
//                                     );
//                                   },
//                                   child: Text(emoji, style: const TextStyle(fontSize: 32)),
//                                 );
//                               }).toList(),
//                             ),
//                           );
//                         },
//                       );
//                     },
//                     child: Column(
//                       crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//                       children: [
//                         Container(
//                           margin: const EdgeInsets.all(6),
//                           padding: const EdgeInsets.all(10),
//                           decoration: BoxDecoration(
//                             color: isMe ? Colors.blue : Colors.grey.shade300,
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           child: Text(
//                             m.text,
//                             style: TextStyle(color: isMe ? Colors.white : Colors.black),
//                           ),
//                         ),
//                         if (isMe)
//                           Padding(
//                             padding: const EdgeInsets.only(right: 14, bottom: 8),
//                             child: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Text(
//                                   isRead ? "Read" : "Sent",
//                                   style: TextStyle(
//                                     fontSize: 10,
//                                     color: Colors.grey.shade600,
//                                     fontWeight: isRead ? FontWeight.bold : FontWeight.normal,
//                                   ),
//                                 ),
//                                 const SizedBox(width: 4),
//                                 Icon(
//                                   isRead ? Icons.done_all : Icons.done,
//                                   size: 12,
//                                   color: isRead ? Colors.blue : Colors.grey,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         if (m.reactions.isNotEmpty)
//                           Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 8),
//                             child: Wrap(
//                               children: m.reactions.map((reaction) {
//                                 return Container(
//                                   padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                                   decoration: BoxDecoration(
//                                       color: Colors.white,
//                                       borderRadius: BorderRadius.circular(12),
//                                       boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 1)]
//                                   ),
//                                   child: Text(reaction.toString(), style: const TextStyle(fontSize: 14)),
//                                 );
//                               }).toList(),
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//           SafeArea(
//             child: Container(
//               padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
//               decoration: BoxDecoration(
//                 border: Border(top: BorderSide(color: Colors.grey.shade300)),
//               ),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: TextField(
//                       controller: _controller,
//                       decoration: InputDecoration(
//                         hintText: "Type a message",
//                         border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   CircleAvatar(
//                     child: IconButton(
//                       icon: const Icon(Icons.send),
//                       onPressed: () async {
//                         final text = _controller.text.trim();
//                         if (text.isEmpty) return;
//
//                         if (cookie == null || cookie.isEmpty) {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(content: Text("Session expired")),
//                           );
//                           return;
//                         }
//
//                         final success = await context.read<SearchProvider>().service.sendChatMessage(
//                           cookie: cookie,
//                           channelId: widget.channelId,
//                           text: text,
//                         );
//
//                         if (success) {
//                           _controller.clear();
//                           await context.read<ChatProvider>().loadChatMessages(
//                             cookie: cookie,
//                             channelId: widget.channelId,
//                           );
//                         } else {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(content: Text("Failed to send message")),
//                           );
//                         }
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

//
// class ChatPage extends StatefulWidget {
//   final int? memberId;
//   final List<int> partnerId;
//   final String title;
//   final String? image;
//   final String? email;
//   final String? phone;
//   final String? cookie;
//   final int channelId;
//
//   const ChatPage({
//     super.key,
//     required this.partnerId,
//     required this.title,
//     this.image,
//     this.email,
//     this.phone,
//     this.cookie,
//     required this.channelId,
//     this.memberId,
//   });
//
//   @override
//   State<ChatPage> createState() => _ChatPageState();
// }
//
// class _ChatPageState extends State<ChatPage> {
//   late final TextEditingController _controller;
//   bool _readStatusLoaded = false;
//   late final AgoraCallInvitationService agoraInviteService;
//   CallListenerService? _callListener;
//
//
//   static const String testingAppId = "339050bec1fe49b8bc5e17ca9d739fba";
//
//   @override
//   @override
//   void initState() {
//     super.initState();
//     _controller = TextEditingController();
//     debugPrint("=====> [INIT] ChatPage initState started.");
//
//     agoraInviteService = AgoraCallInvitationService(
//       callKw: OdooDiscussService(baseUrl: 'http://192.168.250.26:8069').callKw,
//     );
//
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       final auth = context.read<AuthProvider>();
//       final cookie = auth.sessionCookie;
//       final chatProv = context.read<ChatProvider>();
//
//       debugPrint("=====> [POST_FRAME] Auth Partner ID: ${auth.partnerId}");
//       debugPrint("=====> [POST_FRAME] Session Cookie length: ${cookie?.length ?? 0}");
//
//       if (cookie != null && cookie.isNotEmpty) {
//         debugPrint("=====> [POST_FRAME] Loading chat messages for channel: ${widget.channelId}");
//         await chatProv.loadChatMessages(
//           cookie: cookie,
//           channelId: widget.channelId,
//         );
//
//         if (chatProv.messages.isNotEmpty) {
//           final lastId = chatProv.messages.last.id;
//           debugPrint("=====> [POST_FRAME] Marking channel as read up to message: $lastId");
//           await chatProv.service.markChannelAsRead(
//             cookie: cookie,
//             channelId: widget.channelId,
//             lastMessageId: lastId,
//           );
//         }
//
//         // if (auth.partnerId != null) {
//         //   debugPrint("=====> [POST_FRAME] Instantiating CallListenerService...");
//         //   _callListener = CallListenerService(
//         //     inviteService: agoraInviteService,
//         //     cookie: cookie,
//         //     channelId: widget.channelId,
//         //     myPartnerId: auth.partnerId!,
//         //   );
//         //
//         //   debugPrint("=====> [RADAR] Starting call listener stream...");
//         //   _callListener!.startListening(
//         //     onIncomingCall: (inviteData) {
//         //       // LOG: Raw data received from the backend radar loop
//         //       debugPrint("=====> [RADAR_DATA] RAW PAYLOAD RECEIVED: $inviteData");
//         //
//         //       bool isAgoraCall = inviteData['agora_call'] == true;
//         //       bool isTypeIncoming = inviteData['type'] == 'incoming_call';
//         //
//         //       debugPrint("=====> [RADAR_DATA] Check conditions -> isAgoraCall: $isAgoraCall, isTypeIncoming: $isTypeIncoming");
//         //
//         //       if (isAgoraCall || isTypeIncoming) {
//         //         final int targetedId = int.tryParse(inviteData['to_partner_id'].toString()) ?? 0;
//         //         debugPrint("=====> [RADAR_DATA] Targeted Partner ID: $targetedId | My Partner ID: ${auth.partnerId}");
//         //
//         //         if (targetedId.toString() == auth.partnerId.toString()) {
//         //           debugPrint("=====> [RADAR_DATA] IDs MATCH! Directing to UI show block.");
//         //           _showIncomingCallUi(inviteData);
//         //         } else {
//         //           debugPrint("=====> [RADAR_DATA] ID MISMATCH. Call was meant for someone else.");
//         //         }
//         //       } else {
//         //         debugPrint("=====> [RADAR_DATA] Payload ignored: Not recognized as a valid call structure.");
//         //       }
//         //     },
//         //   );
//         // } else {
//         //   debugPrint("=====> [POST_FRAME] CRITICAL ERROR: auth.partnerId is NULL. Radar not started.");
//         // }
//       } else {
//         debugPrint("=====> [POST_FRAME] WARNING: Session Cookie is missing or empty.");
//       }
//     });
//   }
//   // void initState() {
//   //   super.initState();
//   //   _controller = TextEditingController();
//   //
//   //   // Setup Odoo Call Service Architecture
//   //   agoraInviteService = AgoraCallInvitationService(
//   //     callKw: OdooDiscussService(baseUrl: 'http://192.168.250.26:8069').callKw,
//   //   );
//   //
//   //   WidgetsBinding.instance.addPostFrameCallback((_) async {
//   //     final auth = context.read<AuthProvider>();
//   //     final cookie = auth.sessionCookie;
//   //     final chatProv = context.read<ChatProvider>();
//   //
//   //     if (cookie != null && cookie.isNotEmpty) {
//   //       await chatProv.loadChatMessages(
//   //         cookie: cookie,
//   //         channelId: widget.channelId,
//   //       );
//   //
//   //       if (chatProv.messages.isNotEmpty) {
//   //         final lastId = chatProv.messages.last.id;
//   //         await chatProv.service.markChannelAsRead(
//   //           cookie: cookie,
//   //           channelId: widget.channelId,
//   //           lastMessageId: lastId,
//   //         );
//   //       }
//   //
//   //       // Initialize Call Invitation Radar Loop for the Receiver
//   //       if (auth.partnerId != null) {
//   //         _callListener = CallListenerService(
//   //           inviteService: agoraInviteService,
//   //           cookie: cookie,
//   //           channelId: widget.channelId,
//   //           myPartnerId: auth.partnerId!,
//   //         );
//   //
//   //         _callListener!.startListening(
//   //           onIncomingCall: (inviteData) {
//   //             // Safely filter and catch incoming data right as it lands
//   //             if (inviteData['agora_call'] == true ||
//   //                 inviteData['type'] == 'incoming_call') {
//   //
//   //               final int targetedId = int.tryParse(inviteData['to_partner_id'].toString()) ?? 0;
//   //
//   //               // Only show UI overlay if the call is explicitly intended for Rumky
//   //               if (targetedId == auth.partnerId) {
//   //                 _showIncomingCallUi(inviteData);
//   //               }
//   //             }
//   //           },
//   //         );
//   //       }
//   //     }
//   //   });
//   // }
//
//   // void _showIncomingCallUi(Map<String, dynamic> invite) {
//   //   if (!mounted) return;
//   //
//   //  final String targetChannel = invite['agora_channel_name'] ?? 'test_discuss';
//   //
//   //
//   //   showDialog(
//   //     context: context,
//   //     barrierDismissible: false,
//   //     builder: (BuildContext dialogContext) {
//   //       return AlertDialog(
//   //         backgroundColor: const Color(0xff101828),
//   //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//   //         title: const Text(
//   //           "Incoming Call",
//   //           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//   //           textAlign: TextAlign.center,
//   //         ),
//   //         content: Column(
//   //           mainAxisSize: MainAxisSize.min,
//   //           children: [
//   //             const Icon(Icons.phone_in_talk, color: Colors.greenAccent, size: 68),
//   //             const SizedBox(height: 20),
//   //             Text(
//   //               "User ${invite['from_partner_id']} is calling you...",
//   //               style: const TextStyle(color: Colors.white70, fontSize: 15),
//   //               textAlign: TextAlign.center,
//   //             ),
//   //           ],
//   //         ),
//   //         actionsAlignment: MainAxisAlignment.spaceEvenly,
//   //         actions: [
//   //           TextButton(
//   //             onPressed: () => Navigator.pop(dialogContext),
//   //             child: const Text("Decline", style: TextStyle(color: Colors.redAccent, fontSize: 16)),
//   //           ),
//   //           // ElevatedButton(
//   //           //   style: ElevatedButton.styleFrom(
//   //           //     backgroundColor: Colors.green,
//   //           //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//   //           //     padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
//   //           //   ),
//   //           //   onPressed: () {
//   //           //     Navigator.pop(dialogContext); // Dismiss invitation alert alert smoothly
//   //           //
//   //           //     // Receiver enters matching room channel using Agora UIKit
//   //           //     Navigator.push(
//   //           //       context,
//   //           //       MaterialPageRoute(
//   //           //         builder: (_) => AgoraCallPage(
//   //           //           channelName: targetChannel,
//   //           //           callerName: "Incoming Call",
//   //           //           appId: testingAppId,
//   //           //           token: "007eJxTYOhd4hKf2P1tk69UJF+r1JLbt+adj7RdteKt6LrKH9ufaRspMBgbWxqYGiSlJhumpZpYJlkkJZumGponJ1qmmBtbpiUluotpZjUEMjLcE9jGxMgAgSA+D0NJanFJfEpmcXJpcTEDAwCl1COb",
//   //           //         ),
//   //           //       ),
//   //           //     );
//   //           //   },
//   //           //   child: const Text("Answer", style: TextStyle(color: Colors.white, fontSize: 16)),
//   //           // ),
//   //
//   //           ElevatedButton(
//   //             style: ElevatedButton.styleFrom(
//   //               backgroundColor: Colors.green,
//   //               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//   //               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
//   //             ),
//   //             onPressed: () {
//   //               Navigator.pop(dialogContext);
//   //
//   //               final authProv = context.read<AuthProvider>();
//   //
//   //
//   //               final String currentUserName = authProv.userName?? "User_${authProv.partnerId}";
//   //
//   //
//   //               Navigator.push(
//   //                 context,
//   //                 MaterialPageRoute(
//   //                   builder: (_) => AgoraCallPage(
//   //                     channelName: targetChannel,
//   //                     callerName: currentUserName,
//   //                     appId: testingAppId,
//   //                     token: "007eJxTYOhd4hKf2P1tk69UJF+r1JLbt+adj7RdteKt6LrKH9ufaRspMBgbWxqYGiSlJhumpZpYJlkkJZumGponJ1qmmBtbpiUluotpZjUEMjLcE9jGxMgAgSA+D0NJanFJfEpmcXJpcTEDAwCl1COb",
//   //                   ),
//   //                 ),
//   //               );
//   //             },
//   //             child: const Text("Answer", style: TextStyle(color: Colors.white, fontSize: 16)),
//   //           )
//   //         ],
//   //       );
//   //     },
//   //   );
//   // }
//
//   // void _showIncomingCallUi(Map<String, dynamic> invite) {
//   //   // LOG: Verify the UI method was entered
//   //   debugPrint("=====> [CALL_UI] _showIncomingCallUi triggered with data: $invite");
//   //
//   //   if (!mounted) {
//   //     debugPrint("=====> [CALL_UI] CRITICAL: Page is not mounted! Cannot show dialog.");
//   //     return;
//   //   }
//   //
//   //   final String targetChannel = invite['agora_channel_name'] ?? 'test_discuss';
//   //   debugPrint("=====> [CALL_UI] targetChannel resolved to: $targetChannel");
//   //
//   //   showDialog(
//   //     context: context,
//   //     barrierDismissible: false,
//   //     builder: (BuildContext dialogContext) {
//   //       debugPrint("=====> [CALL_UI] AlertDialog builder context running...");
//   //       return AlertDialog(
//   //         backgroundColor: const Color(0xff101828),
//   //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//   //         title: const Text(
//   //           "Incoming Call",
//   //           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//   //           textAlign: TextAlign.center,
//   //         ),
//   //         content: Column(
//   //           mainAxisSize: MainAxisSize.min,
//   //           children: [
//   //             const Icon(Icons.phone_in_talk, color: Colors.greenAccent, size: 68),
//   //             const SizedBox(height: 20),
//   //             Text(
//   //               "User ${invite['from_partner_id']} is calling you...",
//   //               style: const TextStyle(color: Colors.white70, fontSize: 15),
//   //               textAlign: TextAlign.center,
//   //             ),
//   //           ],
//   //         ),
//   //         actionsAlignment: MainAxisAlignment.spaceEvenly,
//   //         actions: [
//   //           TextButton(
//   //             onPressed: () {
//   //               debugPrint("=====> [CALL_UI] User clicked Decline");
//   //               Navigator.pop(dialogContext);
//   //             },
//   //             child: const Text("Decline", style: TextStyle(color: Colors.redAccent, fontSize: 16)),
//   //           ),
//   //           ElevatedButton(
//   //             style: ElevatedButton.styleFrom(
//   //               backgroundColor: Colors.green,
//   //               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//   //               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
//   //             ),
//   //             onPressed: () {
//   //               debugPrint("=====> [CALL_UI] User clicked Answer");
//   //               Navigator.pop(dialogContext);
//   //
//   //               final authProv = context.read<AuthProvider>();
//   //               final String currentUserName = authProv.userName ?? "User_${authProv.partnerId}";
//   //
//   //               debugPrint("=====> [CALL_UI] Navigating to AgoraCallPage as: $currentUserName");
//   //
//   //               Navigator.push(
//   //                 context,
//   //                 MaterialPageRoute(
//   //                   builder: (_) => AgoraCallPage(
//   //                     channelName: targetChannel,
//   //                     callerName: currentUserName,
//   //                     appId: testingAppId,
//   //                     token: "007eJxTYOhd4hKf2P1tk69UJF+r1JLbt+adj7RdteKt6LrKH9ufaRspMBgbWxqYGiSlJhumpZpYJlkkJZumGponJ1qmmBtbpiUluotpZjUEMjLcE9jGxMgAgSA+D0NJanFJfEpmcXJpcTEDAwCl1COb",
//   //                   ),
//   //                 ),
//   //               );
//   //             },
//   //             child: const Text("Answer", style: TextStyle(color: Colors.white, fontSize: 16)),
//   //           )
//   //         ],
//   //       );
//   //     },
//   //   );
//   // }
//
//   @override
//   void dispose() {
//     _callListener?.stopListening();
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final prov = context.watch<ChatProvider>();
//     final auth = context.watch<AuthProvider>();
//     final messages = prov.messages;
//     final cookie = auth.sessionCookie;
//     final readProvider = context.watch<MessageReadStatusProvider>();
//
//     if (!_readStatusLoaded &&
//         cookie != null &&
//         cookie.isNotEmpty &&
//         messages.isNotEmpty) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (!mounted) return;
//         final myPartnerId = auth.partnerId;
//         final myMessageIds = messages
//             .where((m) => m.authorId == myPartnerId)
//             .map((m) => m.id)
//             .toList();
//
//         context.read<MessageReadStatusProvider>().loadReadStatus(
//           cookie: cookie,
//           channelId: widget.channelId,
//           messageIds: myMessageIds,
//           myPartnerId: myPartnerId!,
//           myPartnerIds: [],
//         );
//       });
//       _readStatusLoaded = true;
//     }
//
//     return Scaffold(
//       appBar: AppBar(
//         elevation: 0,
//         title: Row(
//           children: [
//             CircleAvatar(
//               radius: 20,
//               backgroundColor: Colors.grey.shade300,
//               child: ClipOval(
//                 child: (widget.image != null && widget.image!.isNotEmpty)
//                     ? Image.network(
//                   widget.image!,
//                   width: 40,
//                   height: 40,
//                   fit: BoxFit.cover,
//                   headers: {if (cookie != null) 'Cookie': cookie},
//                   errorBuilder: (_, __, ___) => const Icon(Icons.person, color: Colors.black54),
//                 )
//                     : const Icon(Icons.person, color: Colors.black54),
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Text(widget.title, overflow: TextOverflow.ellipsis),
//             ),
//
//             // IconButton(
//             //   icon: const Icon(Icons.edit),
//             //   onPressed: () async {
//             //     final cookie = context.read<AuthProvider>().sessionCookie;
//             //     if (cookie == null || cookie.isEmpty) return;
//             //
//             //     final newNameController = TextEditingController(text: widget.title);
//             //
//             //     final result = await showDialog<String>(
//             //       context: context,
//             //       builder: (_) => AlertDialog(
//             //         title: const Text("Edit Group Name"),
//             //         content: TextField(
//             //           controller: newNameController,
//             //           decoration: const InputDecoration(
//             //             hintText: "Enter new group name",
//             //           ),
//             //         ),
//             //         actions: [
//             //           TextButton(
//             //             onPressed: () => Navigator.pop(context),
//             //             child: const Text("Cancel"),
//             //           ),
//             //           ElevatedButton(
//             //             onPressed: () {
//             //               Navigator.pop(context, newNameController.text.trim());
//             //             },
//             //             child: const Text("Save"),
//             //           ),
//             //         ],
//             //       ),
//             //     );
//             //
//             //     if (result != null && result.isNotEmpty) {
//             //       final success = await context.read<ChatProvider>().renameGroup(
//             //         cookie: cookie,
//             //         channelId: widget.channelId,
//             //         newName: result,
//             //       );
//             //
//             //
//             //         ScaffoldMessenger.of(context).showSnackBar(
//             //           const SnackBar(content: Text("Group name updated")),
//             //         );
//             //
//             //     }
//             //   },
//             // ),
//             IconButton(
//               icon: const Icon(Icons.add),
//               onPressed: () {
//                 Navigator.of(context).push(
//                   MaterialPageRoute(
//                     builder: (_) => SearchPage(
//                       source: SearchSource.chat,
//                       channelId: widget.channelId,
//                     ),
//                   ),
//                 );
//               },
//             ),
//             // IconButton(
//             //   icon: const Icon(Icons.phone),
//             //   onPressed: () async {
//             //     if (widget.partnerId.isEmpty) return;
//             //
//             //     final authProv = context.read<AuthProvider>();
//             //     final myPartnerId = authProv.partnerId;
//             //     final sessionCookie = authProv.sessionCookie;
//             //
//             //     if (myPartnerId == null || sessionCookie == null || sessionCookie.isEmpty) {
//             //       ScaffoldMessenger.of(context).showSnackBar(
//             //         const SnackBar(content: Text("Session expired")),
//             //       );
//             //       return;
//             //     }
//             //
//             //     final remotePartnerId = widget.partnerId.firstWhere(
//             //           (partnerId) => partnerId != myPartnerId,
//             //       orElse: () => widget.partnerId.first,
//             //     );
//             //
//             //     await agoraInviteService.sendCallInvitation(
//             //       cookie: sessionCookie,
//             //       channelId: widget.channelId,
//             //       fromPartnerId: myPartnerId,
//             //       toPartnerId: remotePartnerId,
//             //       agoraChannelName: "test_discuss",
//             //       callType: 'audio',
//             //     );
//             //
//             //     if (!context.mounted) return;
//             //
//             //
//             //     Navigator.push(
//             //       context,
//             //       MaterialPageRoute(
//             //         builder: (_) => AgoraCallPage(
//             //             channelName: "test_discuss",
//             //             callerName: widget.title,
//             //             appId: testingAppId,
//             //             token: "007eJxTYOhd4hKf2P1tk69UJF+r1JLbt+adj7RdteKt6LrKH9ufaRspMBgbWxqYGiSlJhumpZpYJlkkJZumGponJ1qmmBtbpiUluotpZjUEMjLcE9jGxMgAgSA+D0NJanFJfEpmcXJpcTEDAwCl1COb",
//             //           isAudioOnly: true,
//             //         ),
//             //       ),
//             //     );
//             //   },
//             // ),
//             // IconButton(
//             //   icon: const Icon(Icons.photo_camera_rounded),
//             //   onPressed: () async {
//             //     if (widget.partnerId.isEmpty) return;
//             //
//             //     final authProv = context.read<AuthProvider>();
//             //     final myPartnerId = authProv.partnerId;
//             //     final sessionCookie = authProv.sessionCookie;
//             //
//             //     if (myPartnerId == null || sessionCookie == null || sessionCookie.isEmpty) {
//             //       ScaffoldMessenger.of(context).showSnackBar(
//             //         const SnackBar(content: Text("Session expired")),
//             //       );
//             //       return;
//             //     }
//             //
//             //     final remotePartnerId = widget.partnerId.firstWhere(
//             //           (partnerId) => partnerId != myPartnerId,
//             //       orElse: () => widget.partnerId.first,
//             //     );
//             //
//             //     await agoraInviteService.sendCallInvitation(
//             //       cookie: sessionCookie,
//             //       channelId: widget.channelId,
//             //       fromPartnerId: myPartnerId,
//             //       toPartnerId: remotePartnerId,
//             //       agoraChannelName: "test_discuss",
//             //       callType: 'video',
//             //     );
//             //
//             //     if (!context.mounted) return;
//             //
//             //
//             //     Navigator.push(
//             //       context,
//             //       MaterialPageRoute(
//             //         builder: (_) => AgoraCallPage(
//             //             channelName: "test_discuss",
//             //             callerName: widget.title,
//             //             appId: testingAppId,
//             //             token: "007eJxTYOhd4hKf2P1tk69UJF+r1JLbt+adj7RdteKt6LrKH9ufaRspMBgbWxqYGiSlJhumpZpYJlkkJZumGponJ1qmmBtbpiUluotpZjUEMjLcE9jGxMgAgSA+D0NJanFJfEpmcXJpcTEDAwCl1COb",
//             //           isAudioOnly: false,
//             //
//             //         ),
//             //       ),
//             //     );
//             //   },
//             // ),
//
//             IconButton(
//               icon: const Icon(Icons.phone),
//               onPressed: () async {
//                 if (widget.partnerId.isEmpty) return;
//
//                 final authProv = context.read<AuthProvider>();
//                 final myPartnerId = authProv.partnerId;
//                 final sessionCookie = authProv.sessionCookie;
//
//                 if (myPartnerId == null || sessionCookie == null || sessionCookie.isEmpty) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text("Session expired")),
//                   );
//                   return;
//                 }
//
//                 final remotePartnerId = widget.partnerId.firstWhere(
//                       (partnerId) => partnerId != myPartnerId,
//                   orElse: () => widget.partnerId.first,
//                 );
//
//                 await agoraInviteService.sendCallInvitation(
//                   cookie: sessionCookie,
//                   channelId: widget.channelId,
//                   fromPartnerId: myPartnerId,
//                   toPartnerId: remotePartnerId,
//                   agoraChannelName: "test_discuss",
//                   callType: 'audio',
//                 );
//
//                 if (!context.mounted) return;
//
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => AgoraCallPage(
//                       channelName: "test_discuss",
//                       callerName: widget.title,
//                       appId: testingAppId,
//                       token: "007eJxTYIhMsAxf8+zf5Y1PpGdoy9jd1p3/Lv6Wvb78sg6Nu9vS/1YrMBgbWxqYGiSlJhumpZpYJlkkJZumGponJ1qmmBtbpiUlaq7SymoIZGR4WeHGwsgAgSA+D0NJanFJfEpmcXJpcTEDAwDAOSQV",
//                       isAudioOnly: true,
//                     ),
//                   ),
//                 );
//               },
//             ),
//
//
//             IconButton(
//               icon: const Icon(Icons.photo_camera_rounded),
//               onPressed: () async {
//                 if (widget.partnerId.isEmpty) return;
//
//                 final authProv = context.read<AuthProvider>();
//                 final myPartnerId = authProv.partnerId;
//                 final sessionCookie = authProv.sessionCookie;
//
//                 if (myPartnerId == null || sessionCookie == null || sessionCookie.isEmpty) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text("Session expired")),
//                   );
//                   return;
//                 }
//
//                 final remotePartnerId = widget.partnerId.firstWhere(
//                       (partnerId) => partnerId != myPartnerId,
//                   orElse: () => widget.partnerId.first,
//                 );
//
//                 await agoraInviteService.sendCallInvitation(
//                   cookie: sessionCookie,
//                   channelId: widget.channelId,
//                   fromPartnerId: myPartnerId,
//                   toPartnerId: remotePartnerId,
//                   agoraChannelName: "test_discuss",
//                   callType: 'video',
//                 );
//
//                 if (!context.mounted) return;
//
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => AgoraCallPage(
//                       channelName: "test_discuss",
//                       callerName: widget.title,
//                       appId: testingAppId,
//                       token: "007eJxTYIhMsAxf8+zf5Y1PpGdoy9jd1p3/Lv6Wvb78sg6Nu9vS/1YrMBgbWxqYGiSlJhumpZpYJlkkJZumGponJ1qmmBtbpiUlaq7SymoIZGR4WeHGwsgAgSA+D0NJanFJfEpmcXJpcTEDAwDAOSQV",
//                       isAudioOnly: false,
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               itemCount: messages.length,
//               itemBuilder: (_, i) {
//                 final m = messages[i];
//
//                 if (m.text.contains("AGORA_CALL::") || m.text.contains('"agora_call":')) {
//                   return const SizedBox.shrink();
//                 }
//
//                 final isMe = m.authorId == auth.partnerId;
//                 final isRead = readProvider.isMessageRead(m.id);
//
//                 return Align(
//                   alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
//                   child: GestureDetector(
//                     onTap: () {
//                       showModalBottomSheet(
//                         context: context,
//                         builder: (_) {
//                           final emojis = ['👍', '❤️', '😂', '😮', '😢', '🙏'];
//                           return Padding(
//                             padding: const EdgeInsets.all(16),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                               children: emojis.map((emoji) {
//                                 return InkWell(
//                                   onTap: () async {
//                                     Navigator.pop(context);
//                                     final reactionProvider = context.read<ReactionProvider>();
//                                     await reactionProvider.reactToMessage(
//                                       cookie: cookie!,
//                                       messageId: m.id,
//                                       emoji: emoji,
//                                     );
//                                   },
//                                   child: Text(emoji, style: const TextStyle(fontSize: 32)),
//                                 );
//                               }).toList(),
//                             ),
//                           );
//                         },
//                       );
//                     },
//                     child: Column(
//                       crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//                       children: [
//                         Container(
//                           margin: const EdgeInsets.all(6),
//                           padding: const EdgeInsets.all(10),
//                           decoration: BoxDecoration(
//                             color: isMe ? Colors.blue : Colors.grey.shade300,
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           child: Text(
//                             m.text,
//                             style: TextStyle(color: isMe ? Colors.white : Colors.black),
//                           ),
//                         ),
//                         if (isMe)
//                           Padding(
//                             padding: const EdgeInsets.only(right: 14, bottom: 8),
//                             child: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Text(
//                                   isRead ? "Read" : "Sent",
//                                   style: TextStyle(
//                                     fontSize: 10,
//                                     color: Colors.grey.shade600,
//                                     fontWeight: isRead ? FontWeight.bold : FontWeight.normal,
//                                   ),
//                                 ),
//                                 const SizedBox(width: 4),
//                                 Icon(
//                                   isRead ? Icons.done_all : Icons.done,
//                                   size: 12,
//                                   color: isRead ? Colors.blue : Colors.grey,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         if (m.reactions.isNotEmpty)
//                           Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 8),
//                             child: Wrap(
//                               children: m.reactions.map((reaction) {
//                                 return Container(
//                                   padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                                   decoration: BoxDecoration(
//                                       color: Colors.white,
//                                       borderRadius: BorderRadius.circular(12),
//                                       boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 1)]
//                                   ),
//                                   child: Text(reaction.toString(), style: const TextStyle(fontSize: 14)),
//                                 );
//                               }).toList(),
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//           SafeArea(
//             child: Container(
//               padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
//               decoration: BoxDecoration(
//                 border: Border(top: BorderSide(color: Colors.grey.shade300)),
//               ),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: TextField(
//                       controller: _controller,
//                       decoration: InputDecoration(
//                         hintText: "Type a message",
//                         border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   CircleAvatar(
//                     child: IconButton(
//                       icon: const Icon(Icons.send),
//                       onPressed: () async {
//                         final text = _controller.text.trim();
//                         if (text.isEmpty) return;
//
//                         if (cookie == null || cookie.isEmpty) {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(content: Text("Session expired")),
//                           );
//                           return;
//                         }
//
//                         final success = await context.read<SearchProvider>().service.sendChatMessage(
//                           cookie: cookie,
//                           channelId: widget.channelId,
//                           text: text,
//                         );
//
//                         if (success) {
//                           _controller.clear();
//                           await context.read<ChatProvider>().loadChatMessages(
//                             cookie: cookie,
//                             channelId: widget.channelId,
//                           );
//                         } else {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(content: Text("Failed to send message")),
//                           );
//                         }
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
// }

enum ChatSource { channel, directmsg }

class ChatPage extends StatefulWidget {
  final int? memberId;
  final List<int> partnerId;
  final String title;
  final String? image;
  final String? email;
  final String? phone;
  final String? cookie;
  final int channelId;
  final ChatSource? source;

  const ChatPage({
    super.key,
    required this.partnerId,
    required this.title,
    this.image,
    this.email,
    this.phone,
    this.cookie,
    required this.channelId,
    this.memberId,
    this.source,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

// class _ChatPageState extends State<ChatPage> {
//   late final TextEditingController _controller;
//   bool _readStatusLoaded = false;
//   late final AgoraCallInvitationService agoraInviteService;
//   CallListenerService? _callListener;
//
//   static const String testingAppId = "339050bec1fe49b8bc5e17ca9d739fba";
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = TextEditingController();
//
//     agoraInviteService = AgoraCallInvitationService(
//       callKw: OdooDiscussService(baseUrl: 'http://192.168.250.26:8069').callKw,
//     );
//
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       final auth = context.read<AuthProvider>();
//       final cookie = auth.sessionCookie;
//       final chatProv = context.read<ChatProvider>();
//       final String currentUid = (auth.partnerId ?? 0).toString();
//       if (cookie != null && cookie.isNotEmpty) {
//
//         await chatProv.loadChatMessages(
//           cookie: cookie,
//           channelId: widget.channelId,
//         );
//
//         for (var m in chatProv.messages) {
//           print("loaded files");
//           if (m.attachmentIds != null && m.attachmentIds!.isNotEmpty) {
//             print("loaded files1");
//             chatProv.loadFilesForMessage(
//               cookie: cookie,
//               messageId: m.id,
//               attachmentIds: m.attachmentIds!,
//             );
//           }
//         }
//         if (chatProv.messages.isNotEmpty) {
//           final lastId = chatProv.messages.last.id;
//           await chatProv.service.markChannelAsRead(
//             cookie: cookie,
//             channelId: widget.channelId,
//             lastMessageId: lastId,
//           );
//         }
//       }
//     });
//   }
//
//   final String _baseUrl = 'http://192.168.250.26:8069';
//
//   Future<void> _handleFileAction({
//     required BuildContext context,
//     required Map<String, dynamic> file,
//     required String cookie,
//   }) async {
//     final int attachmentId = file['id'];
//     final String fileName = file['name'] ?? 'file';
//     final String mimeType = file['mimetype'] ?? '';
//
//     print("=== [FILE ACTION START] ===");
//     print("Attachment ID: $attachmentId");
//     print("File Name: $fileName");
//     print("MimeType: $mimeType");
//     print("Cookie Available: ${cookie.isNotEmpty ? 'YES (Length: ${cookie.length})' : 'NO'}");
//
//     // 1. IMAGE PREVIEW POPUP
//     if (mimeType.startsWith('image/')) {
//       final String imageUrl = '$_baseUrl/web/image/ir.attachment/$attachmentId/datas';
//       print("[IMAGE DETECTED] Showing preview popup window. URL: $imageUrl");
//
//       showDialog(
//         context: context,
//         builder: (_) => Dialog(
//           backgroundColor: Colors.black,
//           insetPadding: const EdgeInsets.all(12),
//           child: Stack(
//             alignment: Alignment.topRight,
//             children: [
//               InteractiveViewer(
//                 child: Image.network(
//                   imageUrl,
//                   headers: {'Cookie': cookie},
//                   fit: BoxFit.contain,
//                   errorBuilder: (context, error, stackTrace) {
//                     print("[ERROR] Image.network failed to render preview image: $error");
//                     return const Center(
//                       child: Text("Preview failed to render.", style: TextStyle(color: Colors.white)),
//                     );
//                   },
//                 ),
//               ),
//               IconButton(
//                 icon: const Icon(Icons.close, color: Colors.white, size: 30),
//                 onPressed: () => Navigator.pop(context),
//               ),
//             ],
//           ),
//         ),
//       );
//       // NOTE: Removed 'return;' so images continue to download to the device folder after opening preview!
//     }
//
//     // 2. DOWNLOAD PIPELINE
//     final String downloadUrl = '$_baseUrl/web/content/$attachmentId?download=true';
//     print("[DOWNLOAD PIPELINE] Target URL: $downloadUrl");
//
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Downloading $fileName...'),
//         duration: const Duration(seconds: 2),
//       ),
//     );
//
//     try {
//       final dio = Dio();
//       final safeFileName = fileName.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
//       final tempDir = await getTemporaryDirectory();
//       final tempPath = '${tempDir.path}/$safeFileName';
//
//       print("[STEP 1: CACHE] Downloading raw stream to temp path: $tempPath");
//
//       await dio.download(
//         downloadUrl,
//         tempPath,
//         options: Options(
//           headers: {'Cookie': cookie},
//           responseType: ResponseType.bytes,
//         ),
//       );
//
//       final tempFile = File(tempPath);
//       if (await tempFile.exists()) {
//         print("[STEP 1 SUCCESS] Temp file written. Size: ${await tempFile.length()} bytes");
//       } else {
//         throw Exception("Temp file creation verified as false on disk storage layer.");
//       }
//
//       String? openPath = tempPath;
//       String savedLocation = tempPath;
//
//       if (Platform.isAndroid) {
//         print("[STEP 2: ANDROID MEDIASTORE] Initializing MediaStore...");
//         await MediaStore.ensureInitialized();
//         MediaStore.appFolder = 'Discuss';
//
//         print("[MEDIASTORE] Saving file from $tempPath to Download/Discuss...");
//         final mediaStore = MediaStore();
//         final saveInfo = await mediaStore.saveFile(
//           tempFilePath: tempPath,
//           dirType: DirType.download,
//           dirName: DirName.download,
//         );
//
//         if (saveInfo == null) {
//           print("[ERROR] MediaStore saveFile returned NULL.");
//           throw Exception('MediaStore could not save the file.');
//         }
//
//         print("[MEDIASTORE SUCCESS] Save payload contents:");
//         print(" -> Saved Name: ${saveInfo.name}");
//         print(" -> Storage URI: ${saveInfo.uri}");
//
//         savedLocation = 'Downloads/Discuss/${saveInfo.name}';
//
//         print("[MEDIASTORE] Resolving file path from Uri...");
//         openPath = await mediaStore.getFilePathFromUri(
//           uriString: saveInfo.uri.toString(),
//         );
//         print(" -> Resolved Path for opening: $openPath");
//
//       } else if (Platform.isIOS) {
//         print("[STEP 2: IOS SANDBOX] Exporting file copy to App Documents...");
//         final docsDir = await getApplicationDocumentsDirectory();
//         final savePath = '${docsDir.path}/$safeFileName';
//
//         await File(tempPath).copy(savePath);
//         savedLocation = savePath;
//         openPath = savePath;
//         print("[IOS SUCCESS] Saved location: $savedLocation");
//       }
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Downloaded to $savedLocation'),
//           backgroundColor: Colors.green,
//           duration: const Duration(seconds: 3),
//         ),
//       );
//
//       if (openPath != null) {
//         print("[STEP 3: OPEN] Attempting to open file with path: $openPath");
//         final openResult = await OpenFilex.open(openPath);
//         print(" -> OpenFilex Result Type: ${openResult.type}");
//         print(" -> OpenFilex Message: ${openResult.message}");
//       } else {
//         print("[WARNING] openPath evaluated as null. Skipping auto-open framework execution.");
//       }
//
//     } catch (e, stack) {
//       print("[CRITICAL EXCEPTION] Download manager pipeline crashed!");
//       print("Error details: $e");
//       print("Stack Trace:\n$stack");
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Unable to download this attachment: $e')),
//       );
//     } finally {
//       print("=== [FILE ACTION END] ===");
//     }
//   }
//
//   Future<void> _startAgoraCall({
//     required String callType,
//     required bool isAudioOnly,
//   }) async {
//     if (widget.partnerId.isEmpty) return;
//
//
//     final authProv = context.read<AuthProvider>();
//     final myPartnerId = authProv.partnerId;
//     final sessionCookie = authProv.sessionCookie;
//
//     if (myPartnerId == null || sessionCookie == null || sessionCookie.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Session expired")),
//       );
//       return;
//     }
//
//     final token = await generateAgoraToken(myPartnerId);
//
//     final remotePartnerId = widget.partnerId.firstWhere(
//           (partnerId) => partnerId != myPartnerId,
//       orElse: () => widget.partnerId.first,
//     );
//
//     await agoraInviteService.sendCallInvitation(
//       cookie: sessionCookie,
//       channelId: widget.channelId,
//       fromPartnerId: myPartnerId,
//       toPartnerId: remotePartnerId,
//       agoraChannelName: "test_discuss",
//       callType: callType,
//     );
//
//     if (!mounted) return;
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => AgoraCallPage(
//           channelName: "test_discuss",
//           callerName: widget.title,
//           appId: testingAppId,
//         //  token: "007eJxTYJCIDjSermp4IWCS+vQPTw+sssxaZPXq4wyH46f2Hy5gSW9TYDA2tjQwNUhKTTZMSzWxTLJISjZNNTRPTrRMMTe2TEtKrPHXzWoIZGQI2/qWiZEBAkF8HoaS1OKS+JTM4uTS4mIGBgCSMCP8",
//           token: token,
//           uid: myPartnerId,
//           isAudioOnly: isAudioOnly,
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _callListener?.stopListening();
//     _controller.dispose();
//     super.dispose();
//   }
//   Future<void> _pickAndUploadFile(BuildContext context) async {
//     try {
//       // FIX: Calling direct static method 'FilePicker.pickFiles'
//       // explicitly providing defaults to bypass the native Android crash
//       FilePickerResult? result = await FilePicker.pickFiles(
//         type: FileType.any,
//         allowMultiple: false, // Prevents native code null object references
//       );
//
//       if (result != null && result.files.single.path != null) {
//         final String filePath = result.files.single.path!;
//         final File file = File(filePath);
//         final String fileName = result.files.single.name;
//
//         final List<int> fileBytes = await file.readAsBytes();
//         final String base64Data = base64Encode(fileBytes);
//         final String mimeType = lookupMimeType(filePath) ?? 'application/octet-stream';
//
//         final auth = context.read<AuthProvider>();
//         final chatProvider = context.read<ChatProvider>();
//
//         if (!mounted) return;
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Uploading $fileName...'), duration: const Duration(seconds: 1)),
//         );
//
//         bool isSuccess = await chatProvider.uploadAndSendFile(
//           cookie: auth.sessionCookie!,
//           channelId: widget.channelId,
//           fileName: fileName,
//           base64Data: base64Data,
//           mimeType: mimeType,
//           bodyText: "📎 Shared an attachment: $fileName",
//         );
//
//         if (isSuccess && mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('File sent successfully!'), backgroundColor: Colors.green),
//           );
//         } else if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Failed to send file: ${chatProvider.error}'), backgroundColor: Colors.red),
//           );
//         }
//       } else {
//         debugPrint("=====> [FILE_PICKER] User closed picker without selecting a file.");
//       }
//     } catch (e) {
//       debugPrint("=====> [FILE_PICKER] Error selecting file: $e");
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error picking file: $e'), backgroundColor: Colors.red),
//         );
//       }
//     }
//   }
//   Widget _getIconForMimeType(String? mimeType) {
//     if (mimeType == null) return const Icon(Icons.insert_drive_file, color: Colors.grey);
//     if (mimeType.startsWith('image/')) return const Icon(Icons.image, color: Colors.blue);
//     if (mimeType == 'application/pdf') return const Icon(Icons.picture_as_pdf, color: Colors.red);
//     if (mimeType.contains('word') || mimeType.contains('officedocument')) return const Icon(Icons.description, color: Colors.blueAccent);
//     return const Icon(Icons.insert_drive_file, color: Colors.blueGrey);
//   }
//   @override
//   Widget build(BuildContext context) {
//     final prov = context.watch<ChatProvider>();
//     final auth = context.watch<AuthProvider>();
//     final messages = prov.messages;
//     final cookie = auth.sessionCookie;
//     final readProvider = context.watch<MessageReadStatusProvider>();
//
//     if (!_readStatusLoaded &&
//         cookie != null &&
//         cookie.isNotEmpty &&
//         messages.isNotEmpty) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (!mounted) return;
//         final myPartnerId = auth.partnerId;
//         final myMessageIds = messages
//             .where((m) => m.authorId == myPartnerId)
//             .map((m) => m.id)
//             .toList();
//
//         context.read<MessageReadStatusProvider>().loadReadStatus(
//           cookie: cookie,
//           channelId: widget.channelId,
//           messageIds: myMessageIds,
//           myPartnerId: myPartnerId!,
//           myPartnerIds: [],
//         );
//       });
//       _readStatusLoaded = true;
//     }
//
//     return Scaffold(
//       appBar: AppBar(
//         elevation: 0,
//         titleSpacing: 0,
//         title: Row(
//           children: [
//             CircleAvatar(
//               radius: 18,
//               backgroundColor: Colors.grey.shade300,
//               child: ClipOval(
//                 child: (widget.image != null && widget.image!.isNotEmpty)
//                     ? Image.network(
//                   widget.image!,
//                   width: 36,
//                   height: 36,
//                   fit: BoxFit.cover,
//                   headers: {if (cookie != null) 'Cookie': cookie},
//                   errorBuilder: (_, __, ___) =>
//                   const Icon(Icons.person, color: Colors.black54),
//                 )
//                     : const Icon(Icons.person, color: Colors.black54),
//               ),
//             ),
//             const SizedBox(width: 10),
//             Expanded(
//               child: Text(
//                 widget.title,
//                 overflow: TextOverflow.ellipsis,
//                 maxLines: 1,
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           // IconButton(
//           //   icon: const Icon(Icons.add),
//           //   onPressed: () {
//           //     Navigator.of(context).push(
//           //       MaterialPageRoute(
//           //         builder: (_) => SearchPage(
//           //           source: SearchSource.chat,
//           //           channelId: widget.channelId,
//           //         ),
//           //       ),
//           //     );
//           //   },
//           // ),
//           IconButton(
//             icon: const Icon(Icons.edit),
//             onPressed: () async {
//               final chatProvider = context.read<ChatProvider>();
//               final newNameController = TextEditingController(text: widget.title);
//
//               final result = await showDialog<String>(
//                 context: context,
//                 builder: (_) => AlertDialog(
//                   title: const Text("Edit Group Name"),
//                   content: TextField(
//                     controller: newNameController,
//                     decoration: const InputDecoration(
//                       hintText: "Enter new group name",
//                     ),
//                   ),
//                   actions: [
//                     TextButton(
//                       onPressed: () => Navigator.pop(context),
//                       child: const Text("Cancel"),
//                     ),
//                     ElevatedButton(
//                       onPressed: () {
//                         Navigator.pop(context, newNameController.text.trim());
//                       },
//                       child: const Text("Save"),
//                     ),
//                   ],
//                 ),
//               );
//
//               if (result != null && result.isNotEmpty) {
//                 final success = await chatProvider.renameGroup(
//                   cookie: cookie!,
//                   channelId: widget.channelId,
//                   newName: result,
//                 );
//
//                 if (success) {
//                   print("Group name:$result");
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text("Group name updated")),
//                   );
//                   setState(() {}); // update AppBar title
//                 } else {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text("Failed: ${chatProvider.error}")),
//                   );
//                 }
//               }
//             },
//           ),
//           IconButton(
//             icon: const Icon(Icons.phone),
//             onPressed: () async => _startAgoraCall(
//               callType: 'audio',
//               isAudioOnly: true,
//             ),
//           ),
//           IconButton(
//             icon: const Icon(Icons.photo_camera_rounded),
//             onPressed: () async => _startAgoraCall(
//               callType: 'video',
//               isAudioOnly: false,
//             ),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child:
//             // ListView.builder(
//             //   itemCount: messages.length,
//             //   itemBuilder: (_, i) {
//             //     final m = messages[i];
//             //
//             //     if (m.text.contains("AGORA_CALL::") ||
//             //         m.text.contains('"agora_call":')) {
//             //       return const SizedBox.shrink();
//             //     }
//             //
//             //     final isMe = m.authorId == auth.partnerId;
//             //     final isRead = readProvider.isMessageRead(m.id);
//             //     final files = prov.messageAttachments[m.id] ?? [];
//             //     return Align(
//             //       alignment:
//             //       isMe ? Alignment.centerRight : Alignment.centerLeft,
//             //       child: GestureDetector(
//             //         onTap: () {
//             //           showModalBottomSheet(
//             //             context: context,
//             //             builder: (_) {
//             //               final emojis = ['👍', '❤️', '😂', '😮', '😢', '🙏'];
//             //               return Padding(
//             //                 padding: const EdgeInsets.all(16),
//             //                 child: Row(
//             //                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             //                   children: emojis.map((emoji) {
//             //                     return InkWell(
//             //                       onTap: () async {
//             //                         Navigator.pop(context);
//             //                         final reactionProvider =
//             //                         context.read<ReactionProvider>();
//             //                         await reactionProvider.reactToMessage(
//             //                           cookie: cookie!,
//             //                           messageId: m.id,
//             //                           emoji: emoji,
//             //                         );
//             //                       },
//             //                       child: Text(emoji,
//             //                           style:
//             //                           const TextStyle(fontSize: 32)),
//             //                     );
//             //                   }).toList(),
//             //                 ),
//             //               );
//             //             },
//             //           );
//             //         },
//             //         child: Column(
//             //           crossAxisAlignment: isMe
//             //               ? CrossAxisAlignment.end
//             //               : CrossAxisAlignment.start,
//             //           children: [
//             //             Container(
//             //               margin: const EdgeInsets.all(6),
//             //               padding: const EdgeInsets.all(10),
//             //               decoration: BoxDecoration(
//             //                 color: isMe ? Colors.blue : Colors.grey.shade300,
//             //                 borderRadius: BorderRadius.circular(10),
//             //               ),
//             //               child: Text(
//             //                 m.text,
//             //                 style: TextStyle(
//             //                     color: isMe ? Colors.white : Colors.black),
//             //               ),
//             //             ),
//             //             if (files.isNotEmpty)
//             //               Container(
//             //                 constraints: const BoxConstraints(maxWidth: 260),
//             //                 margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
//             //                 decoration: BoxDecoration(
//             //                   color: isMe ? Colors.blue.shade700 : Colors.grey.shade200,
//             //                   borderRadius: BorderRadius.circular(12),
//             //                 ),
//             //                 child: Column(
//             //                   mainAxisSize: MainAxisSize.min,
//             //                   children: files.map<Widget>((file) {
//             //                     final double kbSize = (file['file_size'] ?? 0) / 1024;
//             //                     return ListTile(
//             //                       dense: true,
//             //                       contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//             //                       leading: _getIconForMimeType(file['mimetype']),
//             //                       title: Text(
//             //                         file['name'] ?? 'File attachment',
//             //                         maxLines: 1,
//             //                         overflow: TextOverflow.ellipsis,
//             //                         style: TextStyle(
//             //                           fontSize: 13,
//             //                           color: isMe ? Colors.white : Colors.black87,
//             //                           fontWeight: FontWeight.w500,
//             //                         ),
//             //                       ),
//             //                       subtitle: Text(
//             //                         '${kbSize.toStringAsFixed(1)} KB',
//             //                         style: TextStyle(
//             //                           fontSize: 11,
//             //                           color: isMe ? Colors.white70 : Colors.black54,
//             //                         ),
//             //                       ),
//             //                       trailing: Icon(
//             //                         Icons.download_rounded,
//             //                         size: 20,
//             //                         color: isMe ? Colors.white : Colors.blue,
//             //                       ),
//             //                       onTap: () => _handleFileAction(
//             //                         context: context,
//             //                         file: file,
//             //                         cookie: cookie ?? '',
//             //                       ),
//             //                     );
//             //                   }).toList(),
//             //                 ),
//             //               ),
//             //             if (isMe)
//             //               Padding(
//             //                 padding:
//             //                 const EdgeInsets.only(right: 14, bottom: 8),
//             //                 child: Row(
//             //                   mainAxisSize: MainAxisSize.min,
//             //                   children: [
//             //                     Text(
//             //                       isRead ? "Read" : "Sent",
//             //                       style: TextStyle(
//             //                         fontSize: 10,
//             //                         color: Colors.grey.shade600,
//             //                         fontWeight: isRead
//             //                             ? FontWeight.bold
//             //                             : FontWeight.normal,
//             //                       ),
//             //                     ),
//             //                     const SizedBox(width: 4),
//             //                     Icon(
//             //                       isRead ? Icons.done_all : Icons.done,
//             //                       size: 12,
//             //                       color: isRead ? Colors.blue : Colors.grey,
//             //                     ),
//             //                   ],
//             //                 ),
//             //               ),
//             //             if (m.reactions.isNotEmpty)
//             //               Padding(
//             //                 padding:
//             //                 const EdgeInsets.symmetric(horizontal: 8),
//             //                 child: Wrap(
//             //                   children: m.reactions.map((reaction) {
//             //                     return Container(
//             //                       padding: const EdgeInsets.symmetric(
//             //                           horizontal: 6, vertical: 2),
//             //                       decoration: BoxDecoration(
//             //                           color: Colors.white,
//             //                           borderRadius: BorderRadius.circular(12),
//             //                           boxShadow: const [
//             //                             BoxShadow(
//             //                                 color: Colors.black12,
//             //                                 blurRadius: 1)
//             //                           ]),
//             //                       child: Text(reaction.toString(),
//             //                           style: const TextStyle(fontSize: 14)),
//             //                     );
//             //                   }).toList(),
//             //                 ),
//             //               ),
//             //           ],
//             //         ),
//             //       ),
//             //     );
//             //   },
//             // ),
//             ListView.builder(
//               itemCount: messages.length,
//               itemBuilder: (_, i) {
//                 final m = messages[i];
//
//                 if (m.text.contains("AGORA_CALL::") ||
//                     m.text.contains('"agora_call":')) {
//                   return const SizedBox.shrink();
//                 }
//
//                 final isMe = m.authorId == auth.partnerId;
//                 final isRead = readProvider.isMessageRead(m.id);
//                 final files = prov.messageAttachments[m.id] ?? [];
//
//                 return Align(
//                   alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
//                   child: GestureDetector(
//                     onTap: () {
//                       showModalBottomSheet(
//                         context: context,
//                         shape: const RoundedRectangleBorder(
//                           borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//                         ),
//                         builder: (bottomSheetContext) {
//                           final emojis = ['👍', '❤️', '😂', '😮', '😢', '🙏'];
//                           return SafeArea(
//                             child: Padding(
//                               padding: const EdgeInsets.symmetric(vertical: 12.0),
//                               child: Column(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   // Emoji Reaction Row Matrix
//                                   Padding(
//                                     padding: const EdgeInsets.all(16),
//                                     child: Row(
//                                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                                       children: emojis.map((emoji) {
//                                         return InkWell(
//                                           onTap: () async {
//                                             Navigator.pop(bottomSheetContext);
//                                             final reactionProvider = context.read<ReactionProvider>();
//                                             await reactionProvider.reactToMessage(
//                                               cookie: cookie!,
//                                               messageId: m.id,
//                                               emoji: emoji,
//                                             );
//                                           },
//                                           child: Text(emoji, style: const TextStyle(fontSize: 32)),
//                                         );
//                                       }).toList(),
//                                     ),
//                                   ),
//                                   const Divider(height: 1),
//
//                                   // --- ADDED FEATURE: EDIT OPTION ROW FOR THE USER'S OWN MESSAGES ---
//                                   if (isMe)
//                                     ListTile(
//                                       leading: const Icon(Icons.edit, color: Colors.blueAccent),
//                                       title: const Text("Edit Message"),
//                                       onTap: () async {
//                                         // Dismiss the bottom sheet action frame first
//                                         Navigator.pop(bottomSheetContext);
//
//                                         // Initialize controller tracking current text context value
//                                         final editController = TextEditingController(text: m.text);
//
//                                         // Trigger an inline editing text modal input form dialog
//                                         final newText = await showDialog<String>(
//                                           context: context,
//                                           builder: (dialogContext) => AlertDialog(
//                                             title: const Text("Edit Message"),
//                                             content: TextField(
//                                               controller: editController,
//                                               maxLines: null, // Allow expanding multi-line inputs
//                                               decoration: const InputDecoration(
//                                                 hintText: "Modify your message...",
//                                               ),
//                                             ),
//                                             actions: [
//                                               TextButton(
//                                                 onPressed: () => Navigator.pop(dialogContext),
//                                                 child: const Text("Cancel"),
//                                               ),
//                                               ElevatedButton(
//                                                 onPressed: () {
//                                                   Navigator.pop(dialogContext, editController.text.trim());
//                                                 },
//                                                 child: const Text("Save"),
//                                               ),
//                                             ],
//                                           ),
//                                         );
//
//                                         // If text modifications are confirmed valid, fire the mutation block
//                                         if (newText != null && newText.isNotEmpty && newText != m.text) {
//                                           final chatProvider = context.read<ChatProvider>();
//
//                                           final success = await chatProvider.editMessageInChat(
//                                             cookie: cookie!,
//                                             messageId: m.id,
//                                             channelId: widget.channelId,
//                                             updatedText: newText,
//                                           );
//
//                                           if (success) {
//                                             ScaffoldMessenger.of(context).showSnackBar(
//                                               const SnackBar(content: Text("Message updated successfully")),
//                                             );
//                                           } else {
//                                             ScaffoldMessenger.of(context).showSnackBar(
//                                               SnackBar(content: Text("Failed to edit: ${chatProvider.error ?? 'Unknown Error'}")),
//                                             );
//                                           }
//                                         }
//                                       },
//                                     ),
//                                   const Divider(height: 1), // Clean separator line between actions
//
//                                   // 2. DELETE MESSAGE BUTTON
//                                   ListTile(
//                                     leading: const Icon(Icons.delete_forever, color: Colors.redAccent),
//                                     title: const Text(
//                                       "Delete Message",
//                                       style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w500),
//                                     ),
//                                     onTap: () async {
//                                       Navigator.pop(bottomSheetContext); // Close bottom sheet immediately
//
//                                       // Double-check confirmation dialog to safeguard data loss
//                                       final confirmDelete = await showDialog<bool>(
//                                         context: context,
//                                         builder: (dialogContext) => AlertDialog(
//                                           title: const Text("Delete Message?"),
//                                           content: const Text("Are you sure you want to permanently delete this message? This action cannot be undone."),
//                                           actions: [
//                                             TextButton(
//                                               onPressed: () => Navigator.pop(dialogContext, false), // User cancelled
//                                               child: const Text("Cancel"),
//                                             ),
//                                             ElevatedButton(
//                                               style: ElevatedButton.styleFrom(
//                                                 backgroundColor: Colors.red,
//                                                 foregroundColor: Colors.white,
//                                               ),
//                                               onPressed: () => Navigator.pop(dialogContext, true), // User confirmed
//                                               child: const Text("Delete"),
//                                             ),
//                                           ],
//                                         ),
//                                       );
//
//                                       // If user confirmed the delete prompt, execute provider pipeline
//                                       if (confirmDelete == true) {
//                                         final chatProvider = context.read<ChatProvider>();
//                                         final success = await chatProvider.deleteMessageFromChat(
//                                           cookie: cookie!,
//                                           messageId: m.id,
//                                           channelId: widget.channelId,
//                                         );
//
//                                         if (success) {
//                                           ScaffoldMessenger.of(context).showSnackBar(
//                                             const SnackBar(content: Text("Message deleted")),
//                                           );
//                                         } else {
//                                           ScaffoldMessenger.of(context).showSnackBar(
//                                             SnackBar(content: Text("Delete failed: ${chatProvider.error ?? 'Unknown Error'}")),
//                                           );
//                                         }
//                                       }
//                                     },
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           );
//                         },
//                       );
//                     },
//                     child: Column(
//                       crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//                       children: [
//                         // Message Text Bubble Layout Box
//                         Container(
//                           margin: const EdgeInsets.all(6),
//                           padding: const EdgeInsets.all(10),
//                           decoration: BoxDecoration(
//                             color: isMe ? Colors.blue : Colors.grey.shade300,
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           child: Text(
//                             m.text,
//                             style: TextStyle(color: isMe ? Colors.white : Colors.black),
//                           ),
//                         ),
//
//                         // Shared Document Attachments List Loop Block
//                         if (files.isNotEmpty)
//                           Container(
//                             constraints: const BoxConstraints(maxWidth: 260),
//                             margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
//                             decoration: BoxDecoration(
//                               color: isMe ? Colors.blue.shade700 : Colors.grey.shade200,
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: Column(
//                               mainAxisSize: MainAxisSize.min,
//                               children: files.map<Widget>((file) {
//                                 final double kbSize = (file['file_size'] ?? 0) / 1024;
//                                 return ListTile(
//                                   dense: true,
//                                   contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                                   leading: _getIconForMimeType(file['mimetype']),
//                                   title: Text(
//                                     file['name'] ?? 'File attachment',
//                                     maxLines: 1,
//                                     overflow: TextOverflow.ellipsis,
//                                     style: TextStyle(
//                                       fontSize: 13,
//                                       color: isMe ? Colors.white : Colors.black87,
//                                       fontWeight: FontWeight.w500,
//                                     ),
//                                   ),
//                                   subtitle: Text(
//                                     '${kbSize.toStringAsFixed(1)} KB',
//                                     style: TextStyle(
//                                       fontSize: 11,
//                                       color: isMe ? Colors.white70 : Colors.black54,
//                                     ),
//                                   ),
//                                   trailing: Icon(
//                                     Icons.download_rounded,
//                                     size: 20,
//                                     color: isMe ? Colors.white : Colors.blue,
//                                   ),
//                                   onTap: () => _handleFileAction(
//                                     context: context,
//                                     file: file,
//                                     cookie: cookie ?? '',
//                                   ),
//                                 );
//                               }).toList(),
//                             ),
//                           ),
//
//                         // Read/Sent Delivery Indicators Footer Row
//                         if (isMe)
//                           Padding(
//                             padding: const EdgeInsets.only(right: 14, bottom: 8),
//                             child: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Text(
//                                   isRead ? "Read" : "Sent",
//                                   style: TextStyle(
//                                     fontSize: 10,
//                                     color: Colors.grey.shade600,
//                                     fontWeight: isRead ? FontWeight.bold : FontWeight.normal,
//                                   ),
//                                 ),
//                                 const SizedBox(width: 4),
//                                 Icon(
//                                   isRead ? Icons.done_all : Icons.done,
//                                   size: 12,
//                                   color: isRead ? Colors.blue : Colors.grey,
//                                 ),
//                               ],
//                             ),
//                           ),
//
//                         // Emoji Reactions Badge Matrix Wrap Container
//                         if (m.reactions.isNotEmpty)
//                           Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 8),
//                             child: Wrap(
//                               children: m.reactions.map((reaction) {
//                                 return Container(
//                                   padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                                   decoration: BoxDecoration(
//                                       color: Colors.white,
//                                       borderRadius: BorderRadius.circular(12),
//                                       boxShadow: const [
//                                         BoxShadow(color: Colors.black12, blurRadius: 1)
//                                       ]),
//                                   child: Text(reaction.toString(), style: const TextStyle(fontSize: 14)),
//                                 );
//                               }).toList(),
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             )
//           ),
//           SafeArea(
//             child: Container(
//               padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
//               decoration: BoxDecoration(
//                 border: Border(top: BorderSide(color: Colors.grey.shade300)),
//               ),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: TextField(
//                       controller: _controller,
//                       decoration: InputDecoration(
//                         hintText: "Type a message",
//                         border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(24)),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   IconButton(
//                     icon: const Icon(Icons.attach_file, color: Colors.blueAccent),
//                     onPressed: () => _pickAndUploadFile(context),
//                   ),
//                   CircleAvatar(
//                     child: IconButton(
//                       icon: const Icon(Icons.send),
//                       onPressed: () async {
//                         final text = _controller.text.trim();
//                         if (text.isEmpty) return;
//
//                         if (cookie == null || cookie.isEmpty) {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(content: Text("Session expired")),
//                           );
//                           return;
//                         }
//
//                         final success = await context
//                             .read<SearchProvider>()
//                             .service
//                             .sendChatMessage(
//                           cookie: cookie,
//                           channelId: widget.channelId,
//                           text: text,
//                         );
//
//                         if (success) {
//                           _controller.clear();
//                           await context.read<ChatProvider>().loadChatMessages(
//                             cookie: cookie,
//                             channelId: widget.channelId,
//                           );
//                         } else {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(
//                                 content: Text("Failed to send message")),
//                           );
//                         }
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//
//
// }

class _ChatPageState extends State<ChatPage> {
  late final TextEditingController _controller;
  bool _readStatusLoaded = false;
  late final AgoraCallInvitationService agoraInviteService;
  CallListenerService? _callListener;
  List<GroupParticipant> _filteredMentions = [];
  bool _showMentionOverlay = false;
  int _mentionSearchStartIndex = -1;
  final GlobalKey _groupsIconKey = GlobalKey();


  late final iconContext = _groupsIconKey.currentContext;
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(_onTextChanged);
    agoraInviteService = AgoraCallInvitationService(
      callKw: OdooDiscussService(baseUrl: 'https://demo.kendroo.com').callKw,
      //  callKw: OdooDiscussService(baseUrl: 'http://localhost:8017').callKw,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = context.read<AuthProvider>();
      final cookie = auth.sessionCookie;
      final chatProv = context.read<ChatProvider>();
      if (cookie != null && cookie.isNotEmpty) {
        await chatProv.loadChatMessages(
          cookie: cookie,
          channelId: widget.channelId,
        );
        //   await chatProv.loadChannelParticipants(cookie: cookie, channelId: widget.channelId, myPartnerId:auth.partnerId!);
        await context.read<ChatProvider>().loadAllChannelMembers(
          cookie: widget.cookie!,
          channelId: widget.channelId,
        );
        for (var m in chatProv.messages) {
          print("loaded files");
          if (m.attachmentIds != null && m.attachmentIds!.isNotEmpty) {
            print("loaded files1");
            chatProv.loadFilesForMessage(
              cookie: cookie,
              messageId: m.id,
              attachmentIds: m.attachmentIds!,
            );
          }
        }
        if (chatProv.messages.isNotEmpty) {
          final lastId = chatProv.messages.last.id;
          await chatProv.service.markChannelAsRead(
            cookie: cookie,
            channelId: widget.channelId,
            lastMessageId: lastId,
          );
        }
      }
    });
  }


  Future<void> _showGroupMembersPopup() async {
    final auth = context.read<AuthProvider>();
    final cookie = auth.sessionCookie;

    if (cookie == null || cookie.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Session expired")),
      );
      return;
    }

    final chatProvider = context.read<ChatProvider>();

    if (chatProvider.participants.isEmpty) {
      await chatProvider.loadAllChannelMembers(
        cookie: cookie,
        channelId: widget.channelId,
      );
    }

    if (!mounted) return;

    final iconContext = _groupsIconKey.currentContext;
    if (iconContext == null) return;

    final RenderBox iconBox = iconContext.findRenderObject() as RenderBox;
    final RenderBox overlayBox =
    Overlay.of(context).context.findRenderObject() as RenderBox;

    final Offset iconPosition =
    iconBox.localToGlobal(Offset.zero, ancestor: overlayBox);

    final Size iconSize = iconBox.size;
    final Size screenSize = overlayBox.size;

    const double popupWidth = 285;

    final double left = (iconPosition.dx + iconSize.width - popupWidth)
        .clamp(12.0, screenSize.width - popupWidth - 12.0);

    final double top = iconPosition.dy + iconSize.height + 6;

    final members = List<GroupParticipant>.from(
      context.read<ChatProvider>().participants,
    );

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Group members",
      barrierColor: Colors.transparent,
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return Stack(
          children: [
            Positioned(
              left: left,
              top: top,
              width: popupWidth,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 380),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.18),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 10, 6, 6),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.groups,
                              color: Color(0xff714B67),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Members (${members.length})",
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: () => Navigator.pop(dialogContext),
                            ),
                          ],
                        ),
                      ),

                      const Divider(height: 1),

                      if (members.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(18),
                          child: Text(
                            "No members found",
                            style: TextStyle(color: Colors.black54),
                          ),
                        )
                      else
                        Flexible(
                          child: ListView.separated(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemCount: members.length,
                            separatorBuilder: (_, __) =>
                            const Divider(height: 1),
                            itemBuilder: (_, index) {
                              final member = members[index];

                              String name = member.displayName
                                  .replaceAll('"', '')
                                  .replaceAll("'", "")
                                  .replaceAll('“', '')
                                  .replaceAll('”', '')
                                  .replaceAll('‘', '')
                                  .replaceAll('’', '')
                                  .replaceAll(
                                RegExp(
                                  r'\s+in\s+false',
                                  caseSensitive: false,
                                ),
                                '',
                              )
                                  .trim();

                              if (name.isEmpty) {
                                name = "Unknown User";
                              }

                              return ListTile(
                                dense: true,
                                // leading: CircleAvatar(
                                //   radius: 18,
                                //   backgroundColor:
                                //   const Color(0xff714B67).withOpacity(0.12),
                                //   child: ClipOval(
                                //     child: Image.network(
                                //    //   _memberImageUrl(member.partnerId),
                                //       width: 36,
                                //       height: 36,
                                //       fit: BoxFit.cover,
                                //       headers: {'Cookie': cookie},
                                //       errorBuilder: (_, __, ___) {
                                //         return Text(
                                //           name[0].toUpperCase(),
                                //           style: const TextStyle(
                                //             color: Color(0xff714B67),
                                //             fontWeight: FontWeight.bold,
                                //           ),
                                //         );
                                //       },
                                //     ),
                                //   ),
                                // ),
                                title: Text(
                                  name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                                subtitle: Text(
                                  "Partner ID: ${member.partnerId}",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  void _onTextChanged() {
    final text = _controller.text;
    final selection = _controller.selection;
    if (selection.baseOffset < 0) return;

    final currentTextUpToCursor = text.substring(0, selection.baseOffset);
    final lastAtIndex = currentTextUpToCursor.lastIndexOf('@');

    if (lastAtIndex != -1) {
      final substringAfterAt = currentTextUpToCursor.substring(lastAtIndex + 1);

      if (!substringAfterAt.contains(' ')) {
        _mentionSearchStartIndex = lastAtIndex;
        _filterParticipants(substringAfterAt);
        return;
      }
    }

    if (_showMentionOverlay) {
      setState(() => _showMentionOverlay = false);
    }
  }

  Future<void> _refreshChat() async {
    final auth = context.read<AuthProvider>();
    final cookie = auth.sessionCookie;
    if (cookie == null || cookie.isEmpty) return;

    final chatProv = context.read<ChatProvider>();

    await chatProv.loadChatMessages(
      cookie: cookie,
      channelId: widget.channelId,
    );
    await chatProv.loadAllChannelMembers(
      cookie: cookie,
      channelId: widget.channelId,
    );

    for (final message in chatProv.messages) {
      final attachmentIds = message.attachmentIds;
      if (attachmentIds != null && attachmentIds.isNotEmpty) {
        await chatProv.loadFilesForMessage(
          cookie: cookie,
          messageId: message.id,
          attachmentIds: attachmentIds,
        );
      }
    }

    if (chatProv.messages.isNotEmpty) {
      final lastId = chatProv.messages.last.id;
      await chatProv.service.markChannelAsRead(
        cookie: cookie,
        channelId: widget.channelId,
        lastMessageId: lastId,
      );
    }

    if (mounted) {
      setState(() => _readStatusLoaded = false);
    }
  }

  // void _filterParticipants(String query) {
  //   final lowerQuery = query.toLowerCase();
  //   final allParticipants = context.read<ChatProvider>().participants;
  //
  //   final results = allParticipants.where((p) {
  //     return p.displayName.toLowerCase().contains(lowerQuery);
  //   }).toList();
  //
  //   setState(() {
  //     _filteredMentions = results;
  //     _showMentionOverlay = results.isNotEmpty;
  //   });
  // }

  // void _selectParticipant(GroupParticipant participant) {
  //   final text = _controller.text;
  //   final selection = _controller.selection;
  //
  //   final beforeMention = text.substring(0, _mentionSearchStartIndex);
  //   final afterSelection = text.substring(selection.baseOffset);
  //
  //
  //   final mentionText = "@${participant.displayName} ";
  //
  //   _controller.text = "$beforeMention$mentionText$afterSelection";
  //
  //   // Reposition cursor safely past the selected mention text block
  //   _controller.selection = TextSelection.fromPosition(
  //     TextPosition(offset: beforeMention.length + mentionText.length),
  //   );
  //
  //   setState(() {
  //     _showMentionOverlay = false;
  //   });
  // }

  // Widget _buildMentionOverlay() {
  //   return Container(
  //     height: 180,
  //     margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(12),
  //       border: Border.all(color: Colors.grey.shade200),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.08),
  //           blurRadius: 8,
  //           offset: const Offset(0, -2),
  //         ),
  //       ],
  //     ),
  //     child: ListView.builder(
  //       shrinkWrap: true,
  //       padding: EdgeInsets.zero,
  //       itemCount: _filteredMentions.length,
  //       itemBuilder: (context, index) {
  //         final p = _filteredMentions[index];
  //
  //         // ─── FAIL-SAFE UI SANITIZATION ───
  //         String cleanUIString = p.displayName
  //             .replaceAll('"', '')
  //             .replaceAll("'", "")
  //             .replaceAll('“', '')
  //             .replaceAll('”', '')
  //             .replaceAll('‘', '')
  //             .replaceAll('’', '')
  //             .trim();
  //
  //         cleanUIString = cleanUIString.replaceAll(RegExp(r'\s+in\s+false', caseSensitive: false), '').trim();
  //         if (cleanUIString.isEmpty) cleanUIString = "Unknown User";
  //         // ─────────────────────────────────
  //
  //         return ListTile(
  //           dense: true,
  //           leading: CircleAvatar(
  //             radius: 14,
  //             backgroundColor: const Color(0xff714B67).withOpacity(0.1),
  //             child: Text(
  //               cleanUIString.isNotEmpty ? cleanUIString[0].toUpperCase() : 'U',
  //               style: const TextStyle(color: Color(0xff714B67), fontSize: 12, fontWeight: FontWeight.bold),
  //             ),
  //           ),
  //           title: Text(
  //             cleanUIString, // 🎉 Displays perfectly clean now, no matter what!
  //             style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500),
  //           ),
  //           onTap: () {
  //             // Pass a temporary modified model to select participant safely
  //             final cleanParticipant = GroupParticipant(
  //               partnerId: p.partnerId,
  //               displayName: cleanUIString,
  //             );
  //             _selectParticipant(cleanParticipant);
  //           },
  //         );
  //       },
  //     ),
  //   );
  // }



  void _filterParticipants(String query) {
    final lowerQuery = query.toLowerCase();
    final allParticipants = context.read<ChatProvider>().participants;

    final results = allParticipants.where((p) {
      return p.displayName.toLowerCase().contains(lowerQuery);
    }).toList();

    if ('everyone'.contains(lowerQuery)) {
      results.insert(
        0,
        GroupParticipant(partnerId: -1, displayName: 'Everyone'),
      );
    }

    setState(() {
      _filteredMentions = results;
      _showMentionOverlay = results.isNotEmpty;
    });
  }

  void _selectParticipant(GroupParticipant participant) {
    final text = _controller.text;
    final selection = _controller.selection;

    final beforeMention = text.substring(0, _mentionSearchStartIndex);
    final afterSelection = text.substring(selection.baseOffset);

    final mentionText = participant.partnerId == -1
        ? "@Everyone "
        : "@${participant.displayName} ";

    _controller.text = "$beforeMention$mentionText$afterSelection";

    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: beforeMention.length + mentionText.length),
    );

    setState(() {
      _showMentionOverlay = false;
    });
  }

  Widget _buildMentionOverlay() {
    return Container(
      height: 180,
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: _filteredMentions.length,
        itemBuilder: (context, index) {
          final p = _filteredMentions[index];
          final isEveryone = p.partnerId == -1;

          // ─── FAIL-SAFE UI SANITIZATION ───
          String cleanUIString = p.displayName
              .replaceAll('"', '')
              .replaceAll("'", "")
              .replaceAll('“', '')
              .replaceAll('”', '')
              .replaceAll('‘', '')
              .replaceAll('’', '')
              .trim();

          cleanUIString = cleanUIString
              .replaceAll(RegExp(r'\s+in\s+false', caseSensitive: false), '')
              .trim();
          if (cleanUIString.isEmpty) cleanUIString = "Unknown User";
          // ─────────────────────────────────

          return ListTile(
            dense: true,
            leading: CircleAvatar(
              radius: 14,
              backgroundColor: isEveryone
                  ? Colors.orange.withOpacity(0.15)
                  : const Color(0xff714B67).withOpacity(0.1),
              child: isEveryone
                  ? const Icon(
                      Icons.groups_rounded,
                      color: Colors.orange,
                      size: 16,
                    )
                  : Text(
                      cleanUIString.isNotEmpty
                          ? cleanUIString[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        color: Color(0xff714B67),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            title: Text(
              cleanUIString,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: isEveryone ? FontWeight.bold : FontWeight.w500,
                color: isEveryone ? Colors.orange.shade900 : Colors.black87,
              ),
            ),
            onTap: () {
              // Pass a temporary modified model to select participant safely
              final cleanParticipant = GroupParticipant(
                partnerId: p.partnerId,
                displayName: cleanUIString,
              );
              _selectParticipant(cleanParticipant);
            },
          );
        },
      ),
    );
  }

  final String _baseUrl = 'https://demo.kendroo.com';
  //final String _baseUrl = 'http://localhost:8017';
  Future<void> _handleFileAction({
    required BuildContext context,
    required Map<String, dynamic> file,
    required String cookie,
  }) async {
    final int attachmentId = file['id'];
    final String fileName = file['name'] ?? 'file';
    final String mimeType = file['mimetype'] ?? '';

    print("=== [FILE ACTION START] ===");
    print("Attachment ID: $attachmentId");
    print("File Name: $fileName");
    print("MimeType: $mimeType");
    print(
      "Cookie Available: ${cookie.isNotEmpty ? 'YES (Length: ${cookie.length})' : 'NO'}",
    );

    if (mimeType.startsWith('image/')) {
      final String imageUrl =
          '$_baseUrl/web/image/ir.attachment/$attachmentId/datas';
      print("[IMAGE DETECTED] Showing preview popup window. URL: $imageUrl");

      showDialog(
        context: context,
        builder: (_) => Dialog(
          backgroundColor: Colors.black,
          insetPadding: const EdgeInsets.all(12),
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              InteractiveViewer(
                child: Image.network(
                  imageUrl,
                  headers: {'Cookie': cookie},
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    print(
                      "[ERROR] Image.network failed to render preview image: $error",
                    );
                    return const Center(
                      child: Text(
                        "Preview failed to render.",
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      );
    }

    final String downloadUrl =
        '$_baseUrl/web/content/$attachmentId?download=true';
    print("[DOWNLOAD PIPELINE] Target URL: $downloadUrl");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading $fileName...'),
        duration: const Duration(seconds: 2),
      ),
    );

    try {
      final dio = Dio();
      final safeFileName = fileName.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/$safeFileName';

      print("[STEP 1: CACHE] Downloading raw stream to temp path: $tempPath");

      await dio.download(
        downloadUrl,
        tempPath,
        options: Options(
          headers: {'Cookie': cookie},
          responseType: ResponseType.bytes,
        ),
      );

      final tempFile = File(tempPath);
      if (await tempFile.exists()) {
        print(
          "[STEP 1 SUCCESS] Temp file written. Size: ${await tempFile.length()} bytes",
        );
      } else {
        throw Exception(
          "Temp file creation verified as false on disk storage layer.",
        );
      }

      String? openPath = tempPath;
      String savedLocation = tempPath;

      if (Platform.isAndroid) {
        print("[STEP 2: ANDROID MEDIASTORE] Initializing MediaStore...");
        await MediaStore.ensureInitialized();
        MediaStore.appFolder = 'Discuss';

        print("[MEDIASTORE] Saving file from $tempPath to Download/Discuss...");
        final mediaStore = MediaStore();
        final saveInfo = await mediaStore.saveFile(
          tempFilePath: tempPath,
          dirType: DirType.download,
          dirName: DirName.download,
        );

        if (saveInfo == null) {
          print("[ERROR] MediaStore saveFile returned NULL.");
          throw Exception('MediaStore could not save the file.');
        }

        print("[MEDIASTORE SUCCESS] Save payload contents:");
        print(" -> Saved Name: ${saveInfo.name}");
        print(" -> Storage URI: ${saveInfo.uri}");

        savedLocation = 'Downloads/Discuss/${saveInfo.name}';

        print("[MEDIASTORE] Resolving file path from Uri...");
        openPath = await mediaStore.getFilePathFromUri(
          uriString: saveInfo.uri.toString(),
        );
        print(" -> Resolved Path for opening: $openPath");
      } else if (Platform.isIOS) {
        print("[STEP 2: IOS SANDBOX] Exporting file copy to App Documents...");
        final docsDir = await getApplicationDocumentsDirectory();
        final savePath = '${docsDir.path}/$safeFileName';

        await File(tempPath).copy(savePath);
        savedLocation = savePath;
        openPath = savePath;
        print("[IOS SUCCESS] Saved location: $savedLocation");
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Downloaded to $savedLocation'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );

      if (openPath != null) {
        print("[STEP 3: OPEN] Attempting to open file with path: $openPath");
        final openResult = await OpenFilex.open(openPath);
        print(" -> OpenFilex Result Type: ${openResult.type}");
        print(" -> OpenFilex Message: ${openResult.message}");
      } else {
        print(
          "[WARNING] openPath evaluated as null. Skipping auto-open framework execution.",
        );
      }
    } catch (e, stack) {
      print("[CRITICAL EXCEPTION] Download manager pipeline crashed!");
      print("Error details: $e");
      print("Stack Trace:\n$stack");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to download this attachment: $e')),
      );
    } finally {
      print("=== [FILE ACTION END] ===");
    }
  }

  // Future<void> _startAgoraCall({
  //   required String callType,
  //   required bool isAudioOnly,
  // }) async {
  //   if (widget.partnerId.isEmpty) return;
  //
  //   final authProv = context.read<AuthProvider>();
  //   final myPartnerId = authProv.partnerId;
  //   final sessionCookie = authProv.sessionCookie;
  //
  //   if (myPartnerId == null || sessionCookie == null || sessionCookie.isEmpty) {
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(const SnackBar(content: Text("Session expired")));
  //     return;
  //   }
  //
  //   final remotePartnerId = widget.partnerId.firstWhere(
  //     (partnerId) => partnerId != myPartnerId,
  //     orElse: () => widget.partnerId.first,
  //   );
  //
  //   final callData = await agoraInviteService.startCallAndGetToken(
  //     cookie: sessionCookie,
  //     channelId: widget.channelId,
  //     receiverPartnerId: remotePartnerId,
  //     callType: callType,
  //   );
  //   final callId = callData['call_id'];
  //
  //   if (!mounted) return;
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (_) => AgoraCallPage(
  //         channelName: callData['channel'],
  //         callerName: widget.title,
  //         appId: callData['app_id'],
  //         token: callData['token'],
  //         uid: callData['uid'],
  //         isAudioOnly: callData['call_type'] == 'audio',
  //         onCallEnded: callId == null
  //             ? null
  //             : () => agoraInviteService.endCall(
  //                 cookie: sessionCookie,
  //                 callId: callId,
  //               ),
  //       ),
  //     ),
  //   );
  // }

  Future<void> _startAgoraCall({
    required String callType,
    required bool isAudioOnly,
  }) async {
    if (widget.partnerId.isEmpty) return;

    final authProv = context.read<AuthProvider>();
    final myPartnerId = authProv.partnerId;
    final sessionCookie = authProv.sessionCookie;

    if (myPartnerId == null || sessionCookie == null || sessionCookie.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Session expired")));
      return;
    }

    // final receiverPartnerIds = context
    //     .read<ChatProvider>()
    //     .participants
    //     .map((p) => p.partnerId)
    //     .where((partnerId) => partnerId != myPartnerId)
    //     .toSet()
    //     .toList();

    final receiverPartnerIds = context
        .read<ChatProvider>()
        .participants
        .map((p) => p.partnerId)
        .where((partnerId) => partnerId != myPartnerId)
        .toSet()
        .toList();

    if (receiverPartnerIds.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("No receiver found")));
      return;
    }

    Map<String, dynamic>? firstCallData;

    for (final receiverPartnerId in receiverPartnerIds) {
      final callData = await agoraInviteService.startCallAndGetToken(
        cookie: sessionCookie,
        channelId: widget.channelId,
        receiverPartnerId: receiverPartnerId,
        callType: callType,
      );

      firstCallData ??= callData;
    }

    final callDataForPage = firstCallData;
    if (!mounted || callDataForPage == null) return;

    if (callDataForPage['channel'] == null ||
        callDataForPage['app_id'] == null ||
        callDataForPage['uid'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Call information is incomplete")),
      );
      return;
    }

    final callId = callDataForPage['call_id'];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AgoraCallPage(
          channelName: callDataForPage['channel'],
          callerName: widget.title,
          appId: callDataForPage['app_id'],
          token: callDataForPage['token'],
          uid: callDataForPage['uid'],
          isAudioOnly: false,
          onCallEnded: callId == null
              ? null
              : () => agoraInviteService.endCall(
                  cookie: sessionCookie,
                  callId: callId,
                ),
          onCallJoinFailed: callId == null
              ? null
              : () => agoraInviteService.endCall(
                  cookie: sessionCookie,
                  callId: callId,
                ),
          getCallState: callId == null
              ? null
              : () => agoraInviteService.getCallState(
                  cookie: sessionCookie,
                  callId: callId,
                ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _callListener?.stopListening();

    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadFile(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final String filePath = result.files.single.path!;
        final File file = File(filePath);
        final String fileName = result.files.single.name;

        final List<int> fileBytes = await file.readAsBytes();
        final String base64Data = base64Encode(fileBytes);
        final String mimeType =
            lookupMimeType(filePath) ?? 'application/octet-stream';

        final auth = context.read<AuthProvider>();
        final chatProvider = context.read<ChatProvider>();

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Uploading $fileName...'),
            duration: const Duration(seconds: 1),
          ),
        );

        bool isSuccess = await chatProvider.uploadAndSendFile(
          cookie: auth.sessionCookie!,
          channelId: widget.channelId,
          fileName: fileName,
          base64Data: base64Data,
          mimeType: mimeType,
          bodyText: "📎 Shared an attachment: $fileName",
        );

        if (isSuccess && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('File sent successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to send file: ${chatProvider.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        debugPrint(
          "=====> [FILE_PICKER] User closed picker without selecting a file.",
        );
      }
    } catch (e) {
      debugPrint("=====> [FILE_PICKER] Error selecting file: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _getIconForMimeType(String? mimeType) {
    if (mimeType == null)
      return const Icon(Icons.insert_drive_file, color: Colors.grey);
    if (mimeType.startsWith('image/'))
      return const Icon(Icons.image, color: Colors.blue);
    if (mimeType == 'application/pdf')
      return const Icon(Icons.picture_as_pdf, color: Colors.red);
    if (mimeType.contains('word') || mimeType.contains('officedocument'))
      return const Icon(Icons.description, color: Colors.blueAccent);
    return const Icon(Icons.insert_drive_file, color: Colors.blueGrey);
  }

  Future<void> _loadAllAttachmentMetadata() async {
    final auth = context.read<AuthProvider>();
    final cookie = auth.sessionCookie;
    if (cookie == null || cookie.isEmpty) return;

    final chatProvider = context.read<ChatProvider>();
    for (final message in chatProvider.messages) {
      if (message.attachmentIds.isNotEmpty) {
        await chatProvider.loadFilesForMessage(
          cookie: cookie,
          messageId: message.id,
          attachmentIds: message.attachmentIds,
        );
      }
    }
  }

  List<Map<String, dynamic>> _allChatAttachments(ChatProvider provider) {
    final filesById = <int, Map<String, dynamic>>{};

    for (final files in provider.messageAttachments.values) {
      for (final file in files) {
        if (file is Map) {
          final item = Map<String, dynamic>.from(file);
          final id = item['id'];
          if (id is int) {
            filesById[id] = item;
          }
        }
      }
    }

    return filesById.values.toList();
  }

  void _showAttachmentsDialog(BuildContext context) {
    final cookie = context.read<AuthProvider>().sessionCookie ?? '';
    final files = _allChatAttachments(context.read<ChatProvider>());
    final mediaFiles = files.where((file) {
      final mimeType = (file['mimetype'] ?? '').toString();
      return mimeType.startsWith('image/') || mimeType.startsWith('video/');
    }).toList();
    final docFiles = files.where((file) {
      final mimeType = (file['mimetype'] ?? '').toString();
      return !mimeType.startsWith('image/') && !mimeType.startsWith('video/');
    }).toList();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 28,
          ),
          child: SizedBox(
            width: double.maxFinite,
            height: 520,
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 8, 0),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Attachments',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(dialogContext),
                        ),
                      ],
                    ),
                  ),
                  const TabBar(
                    labelColor: Color(0xff714B67),
                    indicatorColor: Color(0xff714B67),
                    tabs: [
                      Tab(text: 'Media'),
                      Tab(text: 'Docs'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _attachmentMediaGrid(mediaFiles, cookie),
                        _attachmentDocsList(docFiles, cookie),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _attachmentMediaGrid(List<Map<String, dynamic>> files, String cookie) {
    if (files.isEmpty) {
      return const Center(child: Text('No media attachments'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: files.length,
      itemBuilder: (_, index) {
        final file = files[index];
        final id = file['id'];
        final mimeType = (file['mimetype'] ?? '').toString();
        final isImage = mimeType.startsWith('image/');
        final imageUrl = '$_baseUrl/web/image/ir.attachment/$id/datas';

        return InkWell(
          onTap: () =>
              _handleFileAction(context: context, file: file, cookie: cookie),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              color: Colors.grey.shade200,
              child: isImage
                  ? Image.network(
                      imageUrl,
                      headers: {'Cookie': cookie},
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.broken_image_outlined),
                    )
                  : const Center(
                      child: Icon(
                        Icons.play_circle_fill,
                        color: Color(0xff714B67),
                        size: 38,
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _attachmentDocsList(List<Map<String, dynamic>> files, String cookie) {
    if (files.isEmpty) {
      return const Center(child: Text('No document attachments'));
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: files.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, index) {
        final file = files[index];
        final rawSize = file['file_size'];
        final kbSize = (rawSize is num ? rawSize : 0) / 1024;

        return ListTile(
          leading: _getIconForMimeType(file['mimetype']?.toString()),
          title: Text(
            file['name']?.toString() ?? 'File attachment',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text('${kbSize.toStringAsFixed(1)} KB'),
          trailing: const Icon(Icons.download_rounded),
          onTap: () =>
              _handleFileAction(context: context, file: file, cookie: cookie),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ChatProvider>();
    final auth = context.watch<AuthProvider>();
    final messages = prov.messages;
    final cookie = auth.sessionCookie;
    final readProvider = context.watch<MessageReadStatusProvider>();

    if (!_readStatusLoaded &&
        cookie != null &&
        cookie.isNotEmpty &&
        messages.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        final myPartnerId = auth.partnerId;
        final myMessageIds = messages
            .where((m) => m.authorId == myPartnerId)
            .map((m) => m.id)
            .toList();

        context.read<MessageReadStatusProvider>().loadReadStatus(
          cookie: cookie,
          channelId: widget.channelId,
          messageIds: myMessageIds,
          myPartnerId: myPartnerId!,
          myPartnerIds: [],
        );
      });

      _readStatusLoaded = true;
    }

    return Scaffold(
      backgroundColor: const Color(0xffF8F6F8),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xff714B67),
        foregroundColor: Colors.white,
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xffF3EEF5),
              child: ClipOval(
                child: (widget.image != null && widget.image!.isNotEmpty)
                    ? Image.network(
                        widget.image!,
                        width: 36,
                        height: 36,
                        fit: BoxFit.cover,
                        headers: {if (cookie != null) 'Cookie': cookie},
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.person, color: Color(0xff714B67)),
                      )
                    : const Icon(Icons.person, color: Color(0xff714B67)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.title,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            key: _groupsIconKey,
            icon: const Icon(Icons.groups),
            onPressed: _showGroupMembersPopup,
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              final chatProvider = context.read<ChatProvider>();
              final newNameController = TextEditingController(
                text: widget.title,
              );

              final result = await showDialog<String>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Edit Name"),
                  content: TextField(
                    controller: newNameController,
                    decoration: const InputDecoration(
                      hintText: "Enter new group name",
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff714B67),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pop(context, newNameController.text.trim());
                      },
                      child: const Text("Save"),
                    ),
                  ],
                ),
              );

              if (result != null && result.isNotEmpty) {
                final success = await chatProvider.renameGroup(
                  cookie: cookie!,
                  channelId: widget.channelId,
                  newName: result,
                );

                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Group name updated")),
                  );
                  setState(() {});
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Failed: ${chatProvider.error}")),
                  );
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.attach_file),
            onPressed: () async {
              final currentCookie = context.read<AuthProvider>().sessionCookie;
              if (currentCookie == null || currentCookie.isEmpty) {
                return;
              }

              await _loadAllAttachmentMetadata();
              if (!mounted) return;
              _showAttachmentsDialog(context);
            },
          ),
          if (widget.source == ChatSource.channel)
            IconButton(
              icon: const Icon(Icons.group_add),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => SearchPage(
                      source: SearchSource.chatChannel,
                      channelId: widget.channelId,
                    ),
                  ),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () async =>
                _startAgoraCall(callType: 'video', isAudioOnly: false),
          ),
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshChat,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 12,
                ),
                itemCount: messages.length,
                itemBuilder: (_, i) {
                  final m = messages[i];

                  if (m.text.contains("AGORA_CALL::") ||
                      m.text.contains('"agora_call":')) {
                    return const SizedBox.shrink();
                  }

                  final isMe = m.authorId == auth.partnerId;
                  final isRead = readProvider.isMessageRead(m.id);
                  final files = prov.messageAttachments[m.id] ?? [];

                  return Align(
                    alignment: isMe
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () {
                        _showMessageActionSheet(
                          context: context,
                          message: m,
                          isMe: isMe,
                          cookie: cookie,
                        );
                      },
                      child: Column(
                        crossAxisAlignment: isMe
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Container(
                            constraints: const BoxConstraints(maxWidth: 280),
                            margin: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 4,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isMe
                                  ? const Color(0xff714B67)
                                  : Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(16),
                                topRight: const Radius.circular(16),
                                bottomLeft: Radius.circular(isMe ? 16 : 4),
                                bottomRight: Radius.circular(isMe ? 4 : 16),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              m.text,
                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.black87,
                                fontSize: 14.5,
                              ),
                            ),
                          ),

                          if (files.isNotEmpty)
                            Container(
                              constraints: const BoxConstraints(maxWidth: 280),
                              margin: const EdgeInsets.symmetric(
                                horizontal: 3,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: isMe
                                    ? const Color(0xff5E3E56)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                // children: files.map<Widget>((file) {
                                //   final double kbSize =
                                //       (file['file_size'] ?? 0) / 1024;
                                //
                                //   return ListTile(
                                //     dense: true,
                                //     contentPadding: const EdgeInsets.symmetric(
                                //       horizontal: 12,
                                //       vertical: 4,
                                //     ),
                                //     leading: _getIconForMimeType(
                                //       file['mimetype'],
                                //     ),
                                //     title: Text(
                                //       file['name'] ?? 'File attachment',
                                //       maxLines: 1,
                                //       overflow: TextOverflow.ellipsis,
                                //       style: TextStyle(
                                //         fontSize: 13,
                                //         color: isMe
                                //             ? Colors.white
                                //             : Colors.black87,
                                //         fontWeight: FontWeight.w500,
                                //       ),
                                //     ),
                                //     subtitle: Text(
                                //       '${kbSize.toStringAsFixed(1)} KB',
                                //       style: TextStyle(
                                //         fontSize: 11,
                                //         color: isMe
                                //             ? Colors.white70
                                //             : Colors.black54,
                                //       ),
                                //     ),
                                //     trailing: Icon(
                                //       Icons.download_rounded,
                                //       size: 20,
                                //       color: isMe
                                //           ? Colors.white
                                //           : const Color(0xff714B67),
                                //     ),
                                //     onTap: () => _handleFileAction(
                                //       context: context,
                                //       file: file,
                                //       cookie: cookie ?? '',
                                //     ),
                                //   );
                                // }).toList(),

                                children: files.map<Widget>((file) {
                                  final String mimeType = (file['mimetype'] ?? '').toString();
                                  final int? attachmentId = file['id'] is int ? file['id'] as int : null;
                                  final double kbSize = ((file['file_size'] ?? 0) as num) / 1024;
                                  final bool isImage = mimeType.startsWith('image/');

                                  if (isImage && attachmentId != null) {
                                    final imageUrl = '$_baseUrl/web/image/ir.attachment/$attachmentId/datas';

                                    return InkWell(
                                      onTap: () => _handleFileAction(
                                        context: context,
                                        file: Map<String, dynamic>.from(file),
                                        cookie: cookie ?? '',
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          imageUrl,
                                          headers: {if (cookie != null) 'Cookie': cookie},
                                          width: 240,
                                          height: 260,
                                          fit: BoxFit.contain,
                                          loadingBuilder: (context, child, loadingProgress) {
                                            if (loadingProgress == null) return child;

                                            return Container(
                                              width: 260,
                                              height: 180,
                                              alignment: Alignment.center,
                                              color: Colors.grey.shade200,
                                              child: const CircularProgressIndicator(),
                                            );
                                          },
                                          errorBuilder: (_, __, ___) {
                                            return ListTile(
                                              dense: true,
                                              leading: const Icon(Icons.broken_image_outlined),
                                              title: Text(file['name'] ?? 'Image attachment'),
                                              subtitle: Text('${kbSize.toStringAsFixed(1)} KB'),
                                            );
                                          },
                                        ),
                                      ),
                                    );
                                  }

                                  return ListTile(
                                    dense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    leading: _getIconForMimeType(file['mimetype']),
                                    title: Text(
                                      file['name'] ?? 'File attachment',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isMe ? Colors.white : Colors.black87,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    subtitle: Text(
                                      '${kbSize.toStringAsFixed(1)} KB',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isMe ? Colors.white70 : Colors.black54,
                                      ),
                                    ),
                                    trailing: Icon(
                                      Icons.download_rounded,
                                      size: 20,
                                      color: isMe ? Colors.white : const Color(0xff714B67),
                                    ),
                                    onTap: () => _handleFileAction(
                                      context: context,
                                      file: Map<String, dynamic>.from(file),
                                      cookie: cookie ?? '',
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),

                          if (isMe)
                            Padding(
                              padding: const EdgeInsets.only(
                                right: 12,
                                bottom: 6,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    isRead ? "Read" : "Sent",
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    isRead ? Icons.done_all : Icons.done,
                                    size: 13,
                                    color: isRead
                                        ? const Color(0xff714B67)
                                        : Colors.grey,
                                  ),
                                ],
                              ),
                            ),

                          if (m.reactions.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Wrap(
                                spacing: 4,
                                children: m.reactions.map<Widget>((reaction) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 7,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 1,
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      reaction.toString(),
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          if (_showMentionOverlay) _buildMentionOverlay(),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.attach_file,
                      color: Color(0xff714B67),
                    ),
                    onPressed: () => _pickAndUploadFile(context),
                  ),

                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: "Type a message",
                        filled: true,
                        fillColor: const Color(0xffF3EEF5),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  CircleAvatar(
                    backgroundColor: const Color(0xff714B67),
                    child: IconButton(
                      icon: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () async {
                        final text = _controller.text.trim();
                        if (text.isEmpty) return;
                        String finalMessageBody = text;

                        if (cookie == null || cookie.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Session expired")),
                          );
                          return;
                        }
                        if (text.contains('@Everyone')) {
                          final chatProvider = context.read<ChatProvider>();

                          final allPartnerIds = chatProvider.participants
                              .map((p) => p.partnerId)
                              .toList();

                          print("Pinging all channel users: $allPartnerIds");
                        }
                        final success = await context
                            .read<SearchProvider>()
                            .service
                            .sendChatMessage(
                              cookie: cookie,
                              channelId: widget.channelId,
                              text: text,
                            );

                        if (success) {
                          _controller.clear();
                          await Future.delayed(const Duration(milliseconds: 300));
                          await _refreshChat();
                          // await context.read<ChatProvider>().loadChatMessages(
                          //   cookie: cookie,
                          //   channelId: widget.channelId,
                          // );
                        } else if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Failed to send message"),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // void _showMessageActionSheet({
  //   required BuildContext context,
  //   required dynamic message,
  //   required bool isMe,
  //   required String? cookie,
  // }) {
  //   showModalBottomSheet(
  //     context: context,
  //     backgroundColor:  Colors.white,
  //     barrierColor: Colors.black.withOpacity(0.15),
  //   shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(50), bottom: Radius.circular(50),),
  //     ),
  //     builder: (bottomSheetContext) {
  //       final emojis = ['👍', '❤️', '😂', '😮', '😢', '🙏'];
  //
  //       return SafeArea(
  //         child: Padding(
  //           padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               Container(
  //                 width: 32,
  //                // height: 1,
  //                 decoration: BoxDecoration(
  //                   color: Colors.grey.shade300,
  //                   borderRadius: BorderRadius.circular(20),
  //                 ),
  //               ),
  //
  //               const SizedBox(height: 14),
  //
  //               Padding(
  //                 padding: const EdgeInsets.symmetric(horizontal: 16),
  //                 child: Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                   children: emojis.map((emoji) {
  //                     return InkWell(
  //                       borderRadius: BorderRadius.circular(24),
  //                       onTap: () async {
  //                         Navigator.pop(bottomSheetContext);
  //
  //                         final reactionProvider =
  //                         context.read<ReactionProvider>();
  //
  //                         await reactionProvider.reactToMessage(
  //                           cookie: cookie!,
  //                           messageId: message.id,
  //                           emoji: emoji,
  //                         );
  //                       },
  //                       child: Padding(
  //                         padding: const EdgeInsets.all(8),
  //                         child: Text(
  //                           emoji,
  //                           style: const TextStyle(fontSize: 20),
  //                         ),
  //                       ),
  //                     );
  //                   }).toList(),
  //                 ),
  //               ),
  //
  //               const SizedBox(height: 8),
  //               Divider(height: 1, color: Colors.grey.shade200),
  //
  //               if (isMe)
  //                 ListTile(
  //                   leading: const Icon(
  //                     Icons.edit_outlined,
  //                     color: Color(0xff714B67),
  //                   ),
  //                   title: const Text(
  //                     "Edit Message",
  //                     style: TextStyle(fontWeight: FontWeight.w500,fontSize: 12),
  //
  //                   ),
  //                   onTap: () async {
  //                     Navigator.pop(bottomSheetContext);
  //
  //                     final editController =
  //                     TextEditingController(text: message.text);
  //
  //                     final newText = await showDialog<String>(
  //                       context: context,
  //                       builder: (dialogContext) => AlertDialog(
  //                         title: const Text("Edit Message"),
  //                         content: TextField(
  //                           controller: editController,
  //                           maxLines: null,
  //                           decoration: const InputDecoration(
  //                             hintText: "Modify your message...",
  //                           ),
  //                         ),
  //                         actions: [
  //                           TextButton(
  //                             onPressed: () => Navigator.pop(dialogContext),
  //                             child: const Text("Cancel"),
  //                           ),
  //                           ElevatedButton(
  //                             style: ElevatedButton.styleFrom(
  //                               backgroundColor: const Color(0xff714B67),
  //                               foregroundColor: Colors.white,
  //                             ),
  //                             onPressed: () {
  //                               Navigator.pop(
  //                                 dialogContext,
  //                                 editController.text.trim(),
  //                               );
  //                             },
  //                             child: const Text("Save"),
  //                           ),
  //                         ],
  //                       ),
  //                     );
  //
  //                     if (newText != null &&
  //                         newText.isNotEmpty &&
  //                         newText != message.text) {
  //                       final chatProvider = context.read<ChatProvider>();
  //
  //                       final success =
  //                       await chatProvider.editMessageInChat(
  //                         cookie: cookie!,
  //                         messageId: message.id,
  //                         channelId: widget.channelId,
  //                         updatedText: newText,
  //                       );
  //
  //                       if (success && mounted) {
  //                         ScaffoldMessenger.of(context).showSnackBar(
  //                           const SnackBar(
  //                             content: Text("Message updated successfully"),
  //                           ),
  //                         );
  //                       } else if (mounted) {
  //                         ScaffoldMessenger.of(context).showSnackBar(
  //                           SnackBar(
  //                             content: Text(
  //                               "Failed to edit: ${chatProvider.error ?? 'Unknown Error'}",
  //                             ),
  //                           ),
  //                         );
  //                       }
  //                     }
  //                   },
  //                 ),
  //
  //               ListTile(
  //                 leading: const Icon(
  //                   Icons.delete_outline,
  //                   color: Colors.redAccent,
  //                 ),
  //                 title: const Text(
  //                   "Delete Message",
  //                   style: TextStyle(
  //                     color: Colors.redAccent,
  //                     fontWeight: FontWeight.w500,fontSize: 12
  //                   ),
  //                 ),
  //                 onTap: () async {
  //                   Navigator.pop(bottomSheetContext);
  //
  //                   final confirmDelete = await showDialog<bool>(
  //                     context: context,
  //                     builder: (dialogContext) => AlertDialog(
  //                       title: const Text("Delete Message?"),
  //                       content: const Text(
  //                         "Are you sure you want to permanently delete this message?",
  //                       ),
  //                       actions: [
  //                         TextButton(
  //                           onPressed: () =>
  //                               Navigator.pop(dialogContext, false),
  //                           child: const Text("Cancel"),
  //                         ),
  //                         ElevatedButton(
  //                           style: ElevatedButton.styleFrom(
  //                             backgroundColor: Colors.red,
  //                             foregroundColor: Colors.white,
  //                           ),
  //                           onPressed: () =>
  //                               Navigator.pop(dialogContext, true),
  //                           child: const Text("Delete"),
  //                         ),
  //                       ],
  //                     ),
  //                   );
  //
  //                   if (confirmDelete == true) {
  //                     final chatProvider = context.read<ChatProvider>();
  //
  //                     final success =
  //                     await chatProvider.deleteMessageFromChat(
  //                       cookie: cookie!,
  //                       messageId: message.id,
  //                       channelId: widget.channelId,
  //                     );
  //
  //                     if (success && mounted) {
  //                       ScaffoldMessenger.of(context).showSnackBar(
  //                         const SnackBar(content: Text("Message deleted")),
  //                       );
  //                     } else if (mounted) {
  //                       ScaffoldMessenger.of(context).showSnackBar(
  //                         SnackBar(
  //                           content: Text(
  //                             "Delete failed: ${chatProvider.error ?? 'Unknown Error'}",
  //                           ),
  //                         ),
  //                       );
  //                     }
  //                   }
  //                 },
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  // void _showMessageActionSheet({
  //   required BuildContext context,
  //   required dynamic message,
  //   required bool isMe,
  //   required String? cookie,
  // }) {
  //   showModalBottomSheet(
  //     context: context,
  //     backgroundColor: Colors.transparent,
  //     barrierColor: Colors.black.withOpacity(0.15),
  //     builder: (bottomSheetContext) {
  //       final emojis = ['👍', '❤️', '😂', '😮', '😢', '🙏'];
  //
  //       return SafeArea(
  //         child: Align(
  //           alignment: Alignment.bottomCenter,
  //           child: Container(
  //             width: 300,
  //             margin: const EdgeInsets.only(bottom: 18),
  //             decoration: BoxDecoration(
  //               color: Colors.white,
  //               borderRadius: BorderRadius.circular(22),
  //               border: Border.all(color: Colors.grey.shade300),
  //             ),
  //             child: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 SizedBox(
  //                   height: 54,
  //                   child: Row(
  //                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                     children: emojis.map((emoji) {
  //                       return InkWell(
  //                         borderRadius: BorderRadius.circular(24),
  //                         onTap: () async {
  //                           Navigator.pop(bottomSheetContext);
  //
  //                           await context.read<ReactionProvider>().reactToMessage(
  //                             cookie: cookie!,
  //                             messageId: message.id,
  //                             emoji: emoji,
  //                           );
  //                         },
  //                         child: Padding(
  //                           padding: const EdgeInsets.all(7),
  //                           child: Text(
  //                             emoji,
  //                             style: const TextStyle(fontSize: 28),
  //                           ),
  //                         ),
  //                       );
  //                     }).toList(),
  //                   ),
  //                 ),
  //
  //                 _simpleDivider(),
  //
  //                 if (isMe)
  //                   _simpleMenuRow(
  //                     title: "Edit",
  //                     onTap: () async {
  //                       Navigator.pop(bottomSheetContext);
  //                       await _editSelectedMessage(message, cookie);
  //                     },
  //                   ),
  //
  //                 if (isMe) _simpleDivider(),
  //
  //                 _simpleMenuRow(
  //                   title: "Delete",
  //                   textColor: Colors.redAccent,
  //                   onTap: () async {
  //                     Navigator.pop(bottomSheetContext);
  //                     await _deleteSelectedMessage(message, cookie);
  //                   },
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }
  //
  // Future<void> _editSelectedMessage(dynamic message, String? cookie) async {
  //   final editController = TextEditingController(text: message.text);
  //
  //   final newText = await showDialog<String>(
  //     context: context,
  //     builder: (dialogContext) => AlertDialog(
  //       title: const Text("Edit Message"),
  //       content: TextField(
  //         controller: editController,
  //         maxLines: null,
  //         decoration: const InputDecoration(
  //           hintText: "Modify your message...",
  //         ),
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(dialogContext),
  //           child: const Text("Cancel"),
  //         ),
  //         ElevatedButton(
  //           style: ElevatedButton.styleFrom(
  //             backgroundColor: const Color(0xff714B67),
  //             foregroundColor: Colors.white,
  //           ),
  //           onPressed: () {
  //             Navigator.pop(dialogContext, editController.text.trim());
  //           },
  //           child: const Text("Save"),
  //         ),
  //       ],
  //     ),
  //   );
  //
  //   if (newText != null && newText.isNotEmpty && newText != message.text) {
  //     final chatProvider = context.read<ChatProvider>();
  //
  //     await chatProvider.editMessageInChat(
  //       cookie: cookie!,
  //       messageId: message.id,
  //       channelId: widget.channelId,
  //       updatedText: newText,
  //     );
  //   }
  // }
  //
  // Future<void> _deleteSelectedMessage(dynamic message, String? cookie) async {
  //   final confirmDelete = await showDialog<bool>(
  //     context: context,
  //     builder: (dialogContext) => AlertDialog(
  //       title: const Text("Delete Message?"),
  //       content: const Text("Are you sure you want to delete this message?"),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(dialogContext, false),
  //           child: const Text("Cancel"),
  //         ),
  //         ElevatedButton(
  //           style: ElevatedButton.styleFrom(
  //             backgroundColor: Colors.redAccent,
  //             foregroundColor: Colors.white,
  //           ),
  //           onPressed: () => Navigator.pop(dialogContext, true),
  //           child: const Text("Delete"),
  //         ),
  //       ],
  //     ),
  //   );
  //
  //   if (confirmDelete == true) {
  //     final chatProvider = context.read<ChatProvider>();
  //
  //     await chatProvider.deleteMessageFromChat(
  //       cookie: cookie!,
  //       messageId: message.id,
  //       channelId: widget.channelId,
  //     );
  //   }
  // }
  // Widget _simpleMenuRow({
  //   required String title,
  //   required VoidCallback onTap,
  //   Color textColor = Colors.black87,
  // }) {
  //   return InkWell(
  //     onTap: onTap,
  //     child: SizedBox(
  //       height: 48,
  //       child: Center(
  //         child: Text(
  //           title,
  //           style: TextStyle(
  //             fontSize: 16,
  //             color: textColor,
  //             fontWeight: FontWeight.w500,
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
  //
  // Widget _simpleDivider() {
  //   return Divider(
  //     height: 1,
  //     thickness: 1,
  //     color: Colors.grey.shade300,
  //   );
  // }

  void _showMessageActionSheet({
    required BuildContext context,
    required dynamic message,
    required bool isMe,
    required String? cookie,
  }) {
    showModalBottomSheet(
      context: context,

      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.15),
      isScrollControlled: true,
      builder: (bottomSheetContext) {
        final emojis = ['👍', '❤️', '😂', '😮', '😢', '🙏'];

        return SafeArea(
          child: Padding(
            // 2. Adds consistent floating margins on the left, right, and bottom sides
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Container(
              // 3. Wraps the sheet contents inside a completely unified, rounded card deck
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                  28,
                ), // Equal curves on all corners
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Elegant grab handle bar element
                    Container(
                      width: 38,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),

                    const SizedBox(height: 10),


                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: emojis.map((emoji) {
                          return InkWell(
                            borderRadius: BorderRadius.circular(24),
                            onTap: () async {
                              Navigator.pop(bottomSheetContext);
                              final reactionProvider = context
                                  .read<ReactionProvider>();
                              await reactionProvider.reactToMessage(
                                cookie: cookie!,
                                messageId: message.id,
                                emoji: emoji,
                              );
                              await context.read<ChatProvider>().loadChatMessages(
                                cookie: cookie!,
                                channelId: widget.channelId,
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                emoji,
                                style: const TextStyle(fontSize: 22),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 8),
                    Divider(height: 1, color: Colors.grey.shade100),
                    const SizedBox(height: 4),

                    // Action Menu Option Blocks
                    if (isMe)
                      ListTile(
                        leading: const Icon(
                          Icons.edit_outlined,
                          color: Color(0xff714B67),
                          size: 22,
                        ),
                        title: const Text(
                          "Edit Message",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        onTap: () async {
                          Navigator.pop(bottomSheetContext);
                          final editController = TextEditingController(
                            text: message.text,
                          );

                          final newText = await showDialog<String>(
                            context: context,
                            builder: (dialogContext) => AlertDialog(
                              title: const Text("Edit Message"),
                              content: TextField(
                                controller: editController,
                                maxLines: null,
                                decoration: const InputDecoration(
                                  hintText: "Modify your message...",
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(dialogContext),
                                  child: const Text("Cancel"),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xff714B67),
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () {
                                    Navigator.pop(
                                      dialogContext,
                                      editController.text.trim(),
                                    );
                                  },
                                  child: const Text("Save"),
                                ),
                              ],
                            ),
                          );

                          if (newText != null &&
                              newText.isNotEmpty &&
                              newText != message.text) {
                            final chatProvider = context.read<ChatProvider>();
                            final success = await chatProvider
                                .editMessageInChat(
                                  cookie: cookie!,
                                  messageId: message.id,
                                  channelId: widget.channelId,
                                  updatedText: newText,
                                );

                            if (success && mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Message updated successfully"),
                                ),
                              );
                            } else if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Failed to edit: ${chatProvider.error ?? 'Unknown Error'}",
                                  ),
                                ),
                              );
                            }
                          }
                        },
                      ),

                    ListTile(
                      leading: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                        size: 22,
                      ),
                      title: const Text(
                        "Delete Message",
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      onTap: () async {
                        Navigator.pop(bottomSheetContext);

                        final confirmDelete = await showDialog<bool>(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            title: const Text("Delete Message?"),
                            content: const Text(
                              "Are you sure you want to permanently delete this message?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(dialogContext, false),
                                child: const Text("Cancel"),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () =>
                                    Navigator.pop(dialogContext, true),
                                child: const Text("Delete"),
                              ),
                            ],
                          ),
                        );

                        if (confirmDelete == true) {
                          final chatProvider = context.read<ChatProvider>();
                          final success = await chatProvider
                              .deleteMessageFromChat(
                                cookie: cookie!,
                                messageId: message.id,
                                channelId: widget.channelId,
                              );

                          if (success && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Message deleted")),
                            );
                          } else if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Delete failed: ${chatProvider.error ?? 'Unknown Error'}",
                                ),
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
