import 'dart:async';
import 'dart:io';

import 'package:discuss/view/search_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/thread_model.dart';
import '../provider/auth_provider.dart';
import '../provider/chat_provider.dart';
import '../provider/inbox_provider.dart';
import '../provider/marked_read_provider.dart';
import '../provider/notification_provider.dart';
import '../provider/task_provider.dart';
import '../services/agora_call_invitation_service.dart';
import '../services/call_ringtone_controller.dart';
import '../services/odoo_discuss_service.dart';
import 'agora_call_page.dart';

import 'chat_page.dart';
import 'incoming_call_listener.dart';

class DirectMessagesScreen extends StatefulWidget {
  const DirectMessagesScreen({super.key});

  @override
  DirectMessagesScreenState createState() => DirectMessagesScreenState();
}

//
// class _DirectMessagesScreenState extends State<DirectMessagesScreen> {
//   late IncomingCallListener _incomingCallListener;
//   static const String testingAppId = "339050bec1fe49b8bc5e17ca9d739fba";
//   late final authProvider = context.read<AuthProvider>();
//   @override
//   // void initState() {
//   //   super.initState();
//   //
//   //   _incomingCallListener = IncomingCallListener();
//   //
//   //   WidgetsBinding.instance.addPostFrameCallback((_) async {
//   //     await _loadMessages();
//   //
//   //     final authProvider = context.read<AuthProvider>();
//   //
//   //     final cookie = authProvider.sessionCookie;
//   //     final partnerId = authProvider.partnerId;
//   //
//   //     if (cookie == null || cookie.isEmpty || partnerId == null) {
//   //       return;
//   //     }
//   //
//   //     _incomingCallListener.startListening(
//   //       context: context,
//   //       cookie: cookie,
//   //       myPartnerId: partnerId,
//   //
//   //       // Replace OdooRpcService().callKw with your actual callKw function/service
//   //       callKw: ({
//   //         required String cookie,
//   //         required String model,
//   //         required String method,
//   //         required List args,
//   //         required Map<String, dynamic> kwargs,
//   //       }) {
//   //        // return OdooDiscussService(baseUrl: 'https://demo.kendroo.com').callKw(
//   //         return OdooDiscussService(baseUrl: "http://192.168.250.26:8069").callKw(
//   //           cookie: cookie,
//   //           model: model,
//   //           method: method,
//   //           args: args,
//   //           kwargs: kwargs,
//   //         );
//   //       },
//   //     );
//   //   });
//   //
//   //
//   // }
//
//
//
//   @override
//   void initState() {
//     super.initState();
//
//     debugPrint("=====> [INIT] InboxPage initState started.");
//
//     _incomingCallListener = IncomingCallListener();
//
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       debugPrint("=====> [POST_FRAME] Running Inbox post-frame setup...");
//       final authProvider = context.read<AuthProvider>();
//       final cookie = authProvider.sessionCookie;
//       final partnerId = authProvider.partnerId;
//       await _loadMessages();
//
//       debugPrint("=====> [POST_FRAME] Auth Partner ID: $partnerId");
//
//       if (cookie == null || cookie.isEmpty || partnerId == null) {
//         debugPrint("=====> [POST_FRAME] WARNING: Credentials missing.");
//         return;
//       }
//       _incomingCallListener.startListening(
//         context: context,
//         cookie: cookie,
//         myPartnerId: partnerId,
//         onCallReceived: (Map<String, dynamic> inviteData) {
//           debugPrint("=====> [INBOX] Listener intercepted call payload! Piping to UI.");
//           _showIncomingCallUi(inviteData);
//         },
//         callKw: ({
//           required String cookie,
//           required String model,
//           required String method,
//           required List args,
//           required Map<String, dynamic> kwargs,
//         }) {
//           debugPrint("=====> [RPC_CALL] Executing model query: $model | Method: $method");
//           return OdooDiscussService(baseUrl: "http://192.168.250.26:8069").callKw(
//             cookie: cookie,
//             model: model,
//             method: method,
//             args: args,
//             kwargs: kwargs,
//           );
//         },
//       );
//     });
//   }
//   @override
//   void dispose() {
//     _incomingCallListener.stopListening();
//     super.dispose();
//   }
//
//   Future<void> _loadMessages() async {
//     final cookie = context.read<AuthProvider>().sessionCookie;
//     final authProvider = context.read<AuthProvider>();
//
//     final partnerId = authProvider.partnerId;
//     if (cookie == null || cookie.isEmpty) return;
//
//     await context.read<InboxProvider>().loadDirectMessages(cookie,partnerId! );
//
//   }
//
//   Future<void> _showIncomingCallUi(Map<String, dynamic> invite) async {
//     debugPrint("=====> [CALL_UI] _showIncomingCallUi triggered with data: $invite");
//
//     if (!mounted) {
//       debugPrint("=====> [CALL_UI] CRITICAL: Page is not mounted! Cannot show dialog.");
//       return;
//     }
//
//     final String targetChannel = 'test_discuss';
//     debugPrint("=====> [CALL_UI] targetChannel resolved to: $targetChannel");
//     final String rawCallType = invite['call_type'] ?? 'video';
//     final bool isAudioOnly = rawCallType == 'audio';
//
//     // 1. GET THE SINGLETON CONTROLLER AND START PLAYING THE RINGTONE
//     final ringtoneController = CallRingtoneController();
//     debugPrint("=====> [CALL_UI] Triggering background phone ringtone loop...");
//     await ringtoneController.startRinging();
//
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext dialogContext) {
//         debugPrint("=====> [CALL_UI] AlertDialog builder context running...");
//         return AlertDialog(
//           backgroundColor: const Color(0xff101828),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//           title: Text(
//             isAudioOnly ? "Incoming Audio Call" : "Incoming Video Call",
//             style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
//
//             // --- DECLINE/REJECT CALL ---
//             TextButton(
//               onPressed: () async {
//                 debugPrint("=====> [CALL_UI] User clicked Decline");
//
//                 // 2. Stop the audio playback immediately before closing UI elements
//                 await ringtoneController.stopRinging();
//
//                 Navigator.pop(dialogContext);
//                 _incomingCallListener.resetCallState();
//               },
//               child: const Text("Decline", style: TextStyle(color: Colors.redAccent, fontSize: 16)),
//             ),
//
//             // --- ANSWER CALL ---
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.green,
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//                 padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
//               ),
//               onPressed: () async {
//                 debugPrint("=====> [CALL_UI] User clicked Answer");
//
//                 // 3. Stop the ringtone the millisecond they hit accept so they can hear the speaker stream
//                 await ringtoneController.stopRinging();
//
//                 // Read Provider cleanly before mutating UI layers or introducing async gaps
//                 final authProv = context.read<AuthProvider>();
//                 final currentUid = authProv.partnerId;
//                 final String currentUserName = authProv.userName ?? "User_${authProv.partnerId}";
//
//                 if (currentUid == null) {
//                   debugPrint("=====> [CALL_UI] Cannot answer call: current user UID is missing.");
//                   return;
//                 }
//
//                 // Dismiss the dialog immediately
//                 Navigator.pop(dialogContext);
//
//                 // Generate token using variables safely held in the scope
//                 debugPrint("=====> [CALL_UI] Requesting token for UID: $currentUid");
//                 final String token = await generateAgoraToken(currentUid);
//
//                 debugPrint("=====> [CALL_UI] Token successfully generated: $token");
//                 debugPrint("=====> [CALL_UI] Navigating to AgoraCallPage as: $currentUserName");
//
//                 // Ensure widget tree state is still valid before pushing view
//                 if (context.mounted) {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => AgoraCallPage(
//                         channelName: targetChannel,
//                         callerName: currentUserName,
//                         appId: testingAppId,
//                         token: token,
//                         uid: currentUid,
//                         isAudioOnly: isAudioOnly,
//                       ),
//                     ),
//                   );
//                 }
//
//                 _incomingCallListener.resetCallState();
//               },
//               child: const Text("Answer", style: TextStyle(color: Colors.white, fontSize: 16)),
//             )
//           ],
//         );
//       },
//     ).then((_) async {
//       // 4. SAFETY FALLBACK: If the dialog closes due to an unhandled state modification,
//       // ensure the ringtone stops instead of blasting forever in the background.
//       await ringtoneController.stopRinging();
//     });
//   }
//
//   // Future<void> _showIncomingCallUi(Map<String, dynamic> invite) async {
//   //   debugPrint("=====> [CALL_UI] _showIncomingCallUi triggered with data: $invite");
//   //
//   //   if (!mounted) {
//   //     debugPrint("=====> [CALL_UI] CRITICAL: Page is not mounted! Cannot show dialog.");
//   //     return;
//   //   }
//   //
//   //   final String targetChannel = 'test_discuss';
//   //   debugPrint("=====> [CALL_UI] targetChannel resolved to: $targetChannel");
//   //   final String rawCallType = invite['call_type'] ?? 'video';
//   //   final bool isAudioOnly = rawCallType == 'audio';
//   //
//   //   showDialog(
//   //     context: context,
//   //     barrierDismissible: false,
//   //     builder: (BuildContext dialogContext) {
//   //       debugPrint("=====> [CALL_UI] AlertDialog builder context running...");
//   //       return AlertDialog(
//   //         backgroundColor: const Color(0xff101828),
//   //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//   //         title: Text(
//   //           isAudioOnly ? "Incoming Audio Call" : "Incoming Video Call",
//   //           style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
//   //               _incomingCallListener.resetCallState();
//   //             },
//   //             child: const Text("Decline", style: TextStyle(color: Colors.redAccent, fontSize: 16)),
//   //           ),
//   //           ElevatedButton(
//   //             style: ElevatedButton.styleFrom(
//   //               backgroundColor: Colors.green,
//   //               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//   //               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
//   //             ),
//   //             onPressed: () async {
//   //               debugPrint("=====> [CALL_UI] User clicked Answer");
//   //
//   //               // 1. Read Provider cleanly before mutating UI layers or introducing async gaps
//   //               final authProv = context.read<AuthProvider>();
//   //               final currentUid = authProv.partnerId;
//   //               final String currentUserName = authProv.userName ?? "User_${authProv.partnerId}";
//   //
//   //               if (currentUid == null) {
//   //                 debugPrint("=====> [CALL_UI] Cannot answer call: current user UID is missing.");
//   //                 return;
//   //               }
//   //
//   //               // 2. Dismiss the dialog immediately
//   //               Navigator.pop(dialogContext);
//   //
//   //               // 3. Generate token using variables safely held in the scope
//   //               debugPrint("=====> [CALL_UI] Requesting token for UID: $currentUid");
//   //               final String token = await generateAgoraToken(currentUid);
//   //
//   //               // This will confidently print now!
//   //               debugPrint("=====> [CALL_UI] Token successfully generated: $token");
//   //               debugPrint("=====> [CALL_UI] Navigating to AgoraCallPage as: $currentUserName");
//   //
//   //               // 4. Ensure widget tree state is still valid before pushing view
//   //               if (context.mounted) {
//   //                 Navigator.push(
//   //                   context,
//   //                   MaterialPageRoute(
//   //                     builder: (_) => AgoraCallPage(
//   //                       channelName: targetChannel,
//   //                       callerName: currentUserName,
//   //                       appId: testingAppId,
//   //                       token: token,
//   //                       uid: currentUid,
//   //                   //    token: "007eJxTYJCIDjSermp4IWCS+vQPTw+sssxaZPXq4wyH46f2Hy5gSW9TYDA2tjQwNUhKTTZMSzWxTLJISjZNNTRPTrRMMTe2TEtKrPHXzWoIZGQI2/qWiZEBAkF8HoaS1OKS+JTM4uTS4mIGBgCSMCP8",
//   //                       isAudioOnly: isAudioOnly,
//   //                     ),
//   //                   ),
//   //                 );
//   //               }
//   //
//   //               _incomingCallListener.resetCallState();
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
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('Direct Messages'),
// //         actions: [
// //           IconButton(
// //             icon: const Icon(Icons.search),
// //             onPressed: () {
// //               Navigator.of(context).push(
// //                 MaterialPageRoute(
// //                   builder: (_) => SearchPage(
// //                     source: SearchSource.chat,
// //                   ),
// //                 ),
// //               );
// //             },
// //           ),
// //         ],
// //       ),
// //       body: Consumer<InboxProvider>(
// //         builder: (context, provider, child) {
// //           if (provider.isLoading) {
// //             return const Center(child: CircularProgressIndicator());
// //           }
// //
// //           if (provider.errorMessage.isNotEmpty) {
// //             return Center(child: Text(provider.errorMessage));
// //           }
// //
// //           if (provider.messages.isEmpty) {
// //             return const Center(child: Text('No messages found.'));
// //           }
// //
// //           final sortedMessages = [...provider.messages];
// //
// //           sortedMessages.sort((a, b) {
// //             final dateA = DateTime.tryParse(a.date) ?? DateTime(1900);
// //             final dateB = DateTime.tryParse(b.date) ?? DateTime(1900);
// //             return dateA.compareTo(dateB);
// //           });
// //
// //           final Map<dynamic, DirectMessage> lastMessagesByPartner = {};
// //
// //           for (final msg in sortedMessages) {
// //             if (msg.partnerIds != 0 && msg.partnerIds != msg.authorId) {
// //               lastMessagesByPartner[msg.partnerIds] = msg;
// //             }
// //           }
// //
// //           final lastMessages = lastMessagesByPartner.values.toList();
// //
// //           lastMessages.sort((a, b) {
// //             final dateA = DateTime.tryParse(a.date) ?? DateTime(1900);
// //             final dateB = DateTime.tryParse(b.date) ?? DateTime(1900);
// //             return dateB.compareTo(dateA);
// //           });
// //
// //           if (lastMessages.isEmpty) {
// //             return const Center(child: Text('No messages found.'));
// //           }
// //
// //           return RefreshIndicator(
// //             onRefresh: _loadMessages,
// //             child: ListView.builder(
// //               itemCount: lastMessages.length,
// //               itemBuilder: (context, index) {
// //                 final message = lastMessages[index];
// //
// //                 return FutureBuilder<List<dynamic>>(
// //                   future: context
// //                       .read<MessageReadStatusProvider>()
// //                       .service
// //                       .getOtherParticipantPartnerIds(
// //                     cookie: context.read<AuthProvider>().sessionCookie!,
// //                     channelId: message.channelId,
// //                     myPartnerId: context.read<AuthProvider>().partnerId,
// //                   ),
// //                   builder: (context, snapshot) {
// //                     if (snapshot.connectionState == ConnectionState.waiting) {
// //                       return const ListTile(title: Text("Loading..."));
// //                     }
// //
// //                     if (!snapshot.hasData || snapshot.data!.isEmpty) {
// //                       return const SizedBox.shrink();
// //                     }
// //
// //                     final otherParticipants = snapshot.data!;
// //
// //                     final participantNames = otherParticipants.map((p) {
// //                       var displayName = p['display_name'] ?? 'Unknown';
// //
// //                       if (displayName.contains(message.authorName)) {
// //                         displayName =
// //                             displayName.replaceAll(message.authorName, '').trim();
// //                       }
// //
// //                       displayName =
// //                           displayName.replaceAll(RegExp(r'^,|,$'), '').trim();
// //
// //                       return displayName
// //                           .toString()
// //                           .replaceAll('“', '')
// //                           .replaceAll('”', '')
// //                           .replaceAll(message.authorName, '')
// //                           .split(' in')[0]
// //                           .trim();
// //                     }).toList();
// //
// //                     final String name = participantNames.join(', ');
// // print("message.body,${message.body}");
// //                     return ListTile(
// //                       title: Text(name),
// //                       subtitle: Text(message.body),
// //                       trailing: Text(message.date),
// //                       onTap: () {
// //                         Navigator.push(
// //                           context,
// //                           MaterialPageRoute(
// //                             // builder: (context) => ChatPage(
// //                             //   partnerId: message.partnerIds,
// //                             //   title: name,
// //                             //   cookie: context.read<AuthProvider>().sessionCookie,
// //                             //   channelId: message.channelId,
// //                             // ),
// //                             builder: (context) => ChatPage(
// //                               partnerId: otherParticipants
// //                                   .map<int>((participant) => participant['partner_id'] as int)
// //                                   .toList(),
// //                               title: name,
// //                               cookie: context.read<AuthProvider>().sessionCookie,
// //                               channelId: message.channelId,
// //                             ),
// //
// //                           ),
// //                         );
// //                       },
// //                     );
// //                   },
// //                 );
// //               },
// //             ),
// //           );
// //         },
// //       ),
// //     );
// //   }
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Direct Messages'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.group_add),
//             onPressed: () {
//               Navigator.of(context).push(
//                 MaterialPageRoute(
//                   builder: (_) => SearchPage(source: SearchSource.chat),
//                 ),
//               );
//             },
//           ),
//
//         ],
//       ),
//       body: Consumer<InboxProvider>(
//         builder: (context, provider, child) {
//           if (provider.isLoading) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (provider.errorMessage.isNotEmpty) {
//             return Center(child: Text(provider.errorMessage));
//           }
//           if (provider.messages.isEmpty) {
//             return const Center(child: Text('No messages found.'));
//           }
//
//
//           final sortedMessages = [...provider.messages];
//           sortedMessages.sort((a, b) {
//             final dateA = DateTime.tryParse(a.date) ?? DateTime(1900);
//             final dateB = DateTime.tryParse(b.date) ?? DateTime(1900);
//             return dateA.compareTo(dateB);
//           });
//
//
//           final Map<int, DirectMessage> uniqueLatestMessageByChannel = {};
//
//           for (final msg in sortedMessages) {
//
//             if (msg.body.contains("AGORA_CALL::") || msg.body.contains('"agora_call":')) {
//               continue;
//             }
//
//             uniqueLatestMessageByChannel[msg.channelId] = msg;
//           }
//
//
//           final lastMessages = uniqueLatestMessageByChannel.values.toList();
//
//           lastMessages.sort((a, b) {
//             final dateA = DateTime.tryParse(a.date) ?? DateTime(1900);
//             final dateB = DateTime.tryParse(b.date) ?? DateTime(1900);
//             return dateB.compareTo(dateA);
//           });
//
//           if (lastMessages.isEmpty) {
//             return const Center(child: Text('No messages found.'));
//           }
//
//           return RefreshIndicator(
//             onRefresh: _loadMessages,
//             child: ListView.builder(
//               itemCount: lastMessages.length,
//               itemBuilder: (context, index) {
//                 final message = lastMessages[index];
//
//                 return FutureBuilder<List<dynamic>>(
//                   // future: context
//                   //     .read<MessageReadStatusProvider>()
//                   //     .service
//                   //     .getOtherParticipantPartnerIds(
//                   //   cookie: context.read<AuthProvider>().sessionCookie!,
//                   //   channelId: message.channelId,
//                   //   myPartnerId: context.read<AuthProvider>().partnerId,
//                   // ),
//                   future: Future.wait([
//                     context.read<MessageReadStatusProvider>().service.getOtherParticipantPartnerIds(
//                       cookie:context.read<AuthProvider>().sessionCookie!,
//                       channelId: message.channelId,
//                       myPartnerId: authProvider.partnerId,
//                     ),
//                     context.read<ChatProvider>().loadrename(
//                       cookie: context.read<AuthProvider>().sessionCookie!,
//                       channelId: message.channelId,
//                     ),
//                   ]),
//                   builder: (context, snapshot) {
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return const ListTile(title: Text("Loading..."));
//                     }
//                     if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                       return const SizedBox.shrink();
//                     }
//
//                    // final otherParticipants = snapshot.data!;
//                     final List<dynamic> otherParticipants = snapshot.data![0] as List<dynamic>;
//                     final String? renamedGroupName = snapshot.data![1] as String?;
//                     print('Other participant data: ${snapshot.data}');
//                     final participantNames = otherParticipants.map((p) {
//
//                      var displayName = p['display_name'] ?? 'Unknown';
//                  //     if (displayName.contains(message.authorName)) {
//                         if (displayName.contains(authProvider.userName)) {
//                         displayName = displayName.replaceAll(authProvider.userName, '').trim();
//                       }
//                       displayName = displayName.replaceAll(RegExp(r'^,|,$'), '').trim();
//                       return displayName
//                           .toString()
//                           .replaceAll('“', '')
//                           .replaceAll('”', '')
//                           .replaceAll(message.authorName, '')
//                           .split(' in')[0]
//                           .trim();
//                     }).toList();
//
//
//                     final String name = participantNames.join(', ').isEmpty
//                         ? message.authorName
//                         : participantNames.join(', ');
//
//                     final String displayNameTitle = (renamedGroupName != null && renamedGroupName.isNotEmpty)
//                         ? renamedGroupName
//                         : (participantNames.join(', ').isEmpty ? message.authorName : participantNames.join(', '));
//
//                     final String cleanPreviewText = message.body
//                         .replaceAll(RegExp(r'<[^>]*>'), '')
//                         .replaceAll('&quot;', '"')
//                         .replaceAll('&#34;', '"')
//                         .replaceAll('&amp;', '&')
//                         .trim();
//
//                     return ListTile(
//                       leading:CircleAvatar(
//                         backgroundColor: Colors.blueAccent.withAlpha(30),
//                         child: const Icon(
//                           Icons.person,
//                           color: Colors.blue,
//                           size: 24,
//                         ),
//                       ),
//                       title: Text(displayNameTitle, style: const TextStyle(fontWeight: FontWeight.w600)),
//                       subtitle: Text(cleanPreviewText, maxLines: 1, overflow: TextOverflow.ellipsis),
//                       trailing: Text(
//                         message.date.length > 16 ? message.date.substring(11, 16) : message.date,
//                         style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
//                       ),
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => ChatPage(
//                               partnerId: otherParticipants
//                                   .map<int>((participant) => participant['partner_id'] as int)
//                                   .toList(),
//                               title: displayNameTitle,
//                               cookie: context.read<AuthProvider>().sessionCookie,
//                               channelId: message.channelId,
//                             ),
//                           ),
//                         ).then((_) => _loadMessages()); // Refresh lists when leaving chat page
//                       },
//                     );
//                   },
//                 );
//               },
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

class DirectMessagesScreenState extends State<DirectMessagesScreen> {
  late IncomingCallListener _incomingCallListener;
  late final authProvider = context.read<AuthProvider>();
  final Map<int, Future<List<dynamic>>> _inboxRowFutures = {};
  Timer? _inboxRefreshTimer;
  bool _isSilentRefreshRunning = false;
  bool hasUncheckedTaskNotification = false;
  int lastTaskCount = 0;
  @override
  void initState() {
    super.initState();
    debugPrint("=====> [INIT] InboxPage initState started.");
    _incomingCallListener = IncomingCallListener();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // _inboxRefreshTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      //   if (mounted) {
      //     _refreshInboxSilently();
      //   }
      // });
      debugPrint("=====> [POST_FRAME] Running Inbox post-frame setup...");
      final authProvider = context.read<AuthProvider>();
      final cookie = authProvider.sessionCookie;
      final partnerId = authProvider.partnerId;
      if (cookie == null || cookie.isEmpty || partnerId == null) {
        debugPrint("=====> [POST_FRAME] WARNING: Credentials missing.");
        return;
      }

      // await _loadMessages();
      //   checkNewAssignedTasks();
      _startInboxLoading();
      await context.read<InboxProvider>().loadUnreadCounters(
        cookie,
        partnerId,
        silent: true,
      );
      // await context.read<InboxProvider>().loadChannels(cookie!);
      _inboxRefreshTimer?.cancel();

      // if (cookie == null || cookie.isEmpty || partnerId == null) {
      //   debugPrint("=====> [POST_FRAME] WARNING: Credentials missing.");
      //   return;
      // }

      _incomingCallListener.startListening(
        context: context,
        cookie: cookie,
        myPartnerId: partnerId,
        onCallReceived: (Map<String, dynamic> inviteData) {
          _showIncomingCallUi(inviteData);
        },
        callKw:
            ({
          required String cookie,
          required String model,
          required String method,
          required List args,
          required Map<String, dynamic> kwargs,
        }) {
          return OdooDiscussService(
            baseUrl: "https://demo.kendroo.com",
            // baseUrl: "http://localhost:8017",
          ).callKw(
            cookie: cookie,
            model: model,
            method: method,
            args: args,
            kwargs: kwargs,
          );
        },
      );
    });
  }

  @override
  void dispose() {
    _inboxRefreshTimer?.cancel();
    _incomingCallListener.stopListening();
    super.dispose();
  }

  // Future<void> checkNewAssignedTasks() async {
  //   final taskProvider = context.read<TaskProvider>();
  //   final authProvider = context.read<AuthProvider>();
  //
  //   await taskProvider.fetchAssignedTasks(
  //     cookie: authProvider.sessionCookie!,
  //     userId: authProvider.uid!,
  //   );
  //
  //   if (taskProvider.assignedTasks.length > lastTaskCount) {
  //     setState(() {
  //       hasUncheckedTaskNotification = true;
  //     });
  //   }
  //
  //   lastTaskCount = taskProvider.assignedTasks.length;
  // }
  Future<void> _startInboxLoading() async {
    final auth = context.read<AuthProvider>();
    final cookie = auth.sessionCookie;
    final partnerId = auth.partnerId;

    if (cookie == null || cookie.isEmpty || partnerId == null) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _startInboxLoading();
        }
      });
      return;
    }

    await _loadMessages();
    //  await context.read<InboxProvider>().loadChannels(cookie);

    _inboxRefreshTimer?.cancel();
    _inboxRefreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) {
        _refreshInboxSilently();
      }
    });

    _incomingCallListener.startListening(
      context: context,
      cookie: cookie,
      myPartnerId: partnerId,
      onCallReceived: (Map<String, dynamic> inviteData) {
        _showIncomingCallUi(inviteData);
      },
      callKw:
          ({
        required String cookie,
        required String model,
        required String method,
        required List args,
        required Map<String, dynamic> kwargs,
      }) {
        return OdooDiscussService(
          baseUrl: "https://demo.kendroo.com",
        ).callKw(
          cookie: cookie,
          model: model,
          method: method,
          args: args,
          kwargs: kwargs,
        );
      },
    );
  }

  Future<void> checkNewAssignedTasks() async {
    final taskProvider = context.read<TaskProvider>();
    final authProvider = context.read<AuthProvider>();

    await taskProvider.fetchAssignedTasks(
      cookie: authProvider.sessionCookie!,
      userId: authProvider.uid!,
    );

    taskProvider.updateNotificationStatus();
  }

  // Future<void> _loadMessages({bool silent = false, DirectMessage? message}) async {
  //   if (!silent) {
  //     _inboxRowFutures.clear();
  //   }
  //   final cookie = context.read<AuthProvider>().sessionCookie;
  //   final partnerId = authProvider.partnerId;
  //   if (cookie == null || cookie.isEmpty || partnerId == null) return;
  //   await context.read<InboxProvider>().loadDirectMessages(
  //     cookie,
  //     partnerId,
  //     silent: silent,
  //   );
  //
  //   await context.read<InboxProvider>().loadUnreadCounters(cookie, partnerId);
  //
  //   context.read<ChatProvider>().loadrename(
  //     cookie: cookie,
  //     channelId: message!.channelId!,
  //   );
  //   if (!silent) {
  //     checkNewAssignedTasks();
  //   }
  // }

  Future<void> _loadMessages({bool silent = false, DirectMessage? message}) async {
    if (!silent) {
      _inboxRowFutures.clear();
    }

    final cookie = context.read<AuthProvider>().sessionCookie;
    final partnerId = authProvider.partnerId;

    if (cookie == null || cookie.isEmpty || partnerId == null) return;

    await context.read<InboxProvider>().loadDirectMessages(
      cookie,
      partnerId,
      silent: silent,
    );

    await context.read<InboxProvider>().loadUnreadCounters(
      cookie,
      partnerId,
      silent: silent,
    );

    if (message != null) {
      context.read<ChatProvider>().loadrename(
        cookie: cookie,
        channelId: message.channelId,
      );
    }

    if (!silent) {
      checkNewAssignedTasks();
    }
  }

  Future<void> _refreshInboxSilently({int? changedChannelId}) async {
    if (_isSilentRefreshRunning) return;

    if (changedChannelId != null) {
      _inboxRowFutures.remove(changedChannelId);
    }

    _isSilentRefreshRunning = true;
    try {
      await _loadMessages(silent: true);
    } finally {
      _isSilentRefreshRunning = false;
    }
  }

  Future<void> refreshNow() async {
    final cookie = authProvider.sessionCookie;
    final partnerId = authProvider.partnerId;

    if (cookie == null || cookie.isEmpty || partnerId == null) return;

    await Future.wait([
      _refreshInboxSilently(),
      context.read<InboxProvider>().loadUnreadCounters(
        cookie,
        partnerId,
        silent: true,
      ),
    ]);
  }

  Future<List<dynamic>> _getInboxRowFuture(DirectMessage message) {
    return _inboxRowFutures.putIfAbsent(message.channelId, () {
      final cookie = context.read<AuthProvider>().sessionCookie!;

      return Future.wait([
        context
            .read<MessageReadStatusProvider>()
            .service
            .getOtherParticipantPartnerIds(
          cookie: cookie,
          channelId: message.channelId,
          myPartnerId: authProvider.partnerId,
        ),
        context.read<ChatProvider>().loadrename(
          cookie: cookie,
          channelId: message.channelId,
        ),
        _loadMySeenMessageId(
          cookie: cookie,
          channelId: message.channelId,
          partnerId: authProvider.partnerId,
        ),
      ]);
    });
  }

  int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  Future<void> _showIncomingCallUi(Map<String, dynamic> invite) async {
    if (!mounted) return;

    final callId = _asInt(invite['call_id'] ?? invite['id']);
    final callService = AgoraCallInvitationService(
      callKw: OdooDiscussService(baseUrl: "https://demo.kendroo.com").callKw,
      // callKw: OdooDiscussService(baseUrl: "http://localhost:8017").callKw,
    );

    final ringtoneController = CallRingtoneController();
    await ringtoneController.startRinging();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: const Color(0xff0F172A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.video_chat_rounded,
                    color: Colors.blueAccent,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Incoming Video Call",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "User ${invite['from_partner_id']} is calling...",
                  style: TextStyle(
                    color: Colors.blueGrey.shade300,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: Colors.redAccent.withOpacity(0.4),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(
                          Icons.call_end,
                          color: Colors.redAccent,
                          size: 18,
                        ),
                        label: const Text(
                          "Decline",
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed: () async {
                          await ringtoneController.stopRinging();
                          final cookie = context
                              .read<AuthProvider>()
                              .sessionCookie;
                          if (cookie != null &&
                              cookie.isNotEmpty &&
                              callId != null) {
                            try {
                              await callService.declineCall(
                                cookie: cookie,
                                callId: callId,
                              );
                            } catch (e) {
                              debugPrint("Agora decline call failed: $e");
                            }
                          }
                          Navigator.pop(dialogContext);
                          _incomingCallListener.resetCallState();
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.call, size: 18),
                        label: const Text(
                          "Answer",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        onPressed: () async {
                          await ringtoneController.stopRinging();
                          final authProv = context.read<AuthProvider>();
                          final cookie = authProv.sessionCookie;

                          if (cookie == null ||
                              cookie.isEmpty ||
                              callId == null) {
                            return;
                          }

                          Navigator.pop(dialogContext);

                          bool accepted = false;
                          try {
                            accepted = await callService.acceptCall(
                              cookie: cookie,
                              callId: callId,
                            );
                          } catch (e) {
                            debugPrint("Agora accept call failed: $e");
                          }

                          if (!accepted) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Unable to accept this call"),
                                ),
                              );
                            }
                            _incomingCallListener.resetCallState();
                            return;
                          }

                          Map<String, dynamic> tokenData;
                          try {
                            tokenData = await callService.getAgoraToken(
                              cookie: cookie,
                              callId: callId,
                            );
                          } catch (e) {
                            debugPrint("Agora token fetch failed: $e");
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Unable to join this call"),
                                ),
                              );
                            }
                            _incomingCallListener.resetCallState();
                            return;
                          }

                          if (tokenData['channel'] == null ||
                              tokenData['app_id'] == null ||
                              tokenData['uid'] == null) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Call information is incomplete",
                                  ),
                                ),
                              );
                            }
                            _incomingCallListener.resetCallState();
                            return;
                          }

                          if (context.mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AgoraCallPage(
                                  channelName: tokenData['channel'],
                                  callerName:
                                  invite['from_partner_name']?.toString() ??
                                      "User ${invite['from_partner_id']}",
                                  appId: tokenData['app_id'],
                                  token: tokenData['token'],
                                  uid: tokenData['uid'],
                                  isAudioOnly: false,
                                  onCallEnded: () => callService.endCall(
                                    cookie: cookie,
                                    callId: callId,
                                  ),
                                  onCallJoinFailed: () => callService.endCall(
                                    cookie: cookie,
                                    callId: callId,
                                  ),
                                  getCallState: () => callService.getCallState(
                                    cookie: cookie,
                                    callId: callId,
                                  ),
                                ),
                              ),
                            );
                          }
                          _incomingCallListener.resetCallState();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ).then((_) async {
      await ringtoneController.stopRinging();
    });
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final discussNotificationProvider = context.watch<NotificationProvider>();
    final GlobalKey taskIconKey = GlobalKey();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xff714B67),
        foregroundColor: Colors.white,
        title: const Text(
          'Discuss',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.group_add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SearchPage(source: SearchSource.chat),
                ),
              );
            },
          ),
          // IconButton(
          //   icon: const Icon(Icons.message),
          //   onPressed: () async {
          //     // 1. Fetch the data before or during dialog presentation
          //     // Ensure listen: false is used when calling methods inside callbacks
          //     final notificationProvider = Provider.of<NotificationProvider>(
          //       context,
          //       listen: false,
          //     );
          //
          //     // Replace 'your_stored_cookie_here' with your app's actual session cookie variable
          //     notificationProvider.loadNotificationList(
          //       cookie: authProvider.sessionCookie!,
          //       partnerId: authProvider.partnerId!,
          //     );
          //
          //     // 2. Open the Dialog
          //     showDialog(
          //       context: context,
          //       builder: (BuildContext dialogContext) {
          //         // Consumer keeps the dialog content reactive to the provider's state changes
          //         return Consumer<NotificationProvider>(
          //           builder: (context, provider, child) {
          //             return AlertDialog(
          //               title: const Text('Notifications'),
          //               content: SizedBox(
          //                 width: double.maxFinite,
          //                 height: 300, // Constrain height for scrollable list
          //                 child: _buildDialogContent(provider),
          //               ),
          //               actions: [
          //                 TextButton(
          //                   onPressed: () => Navigator.pop(dialogContext),
          //                   child: const Text('Close'),
          //                 ),
          //               ],
          //             );
          //           },
          //         );
          //       },
          //     );
          //   },
          // ),
          Consumer<InboxProvider>(
            builder: (context, inboxProvider, child) {
              final int unreadCount = inboxProvider.totalUnreadCounter;

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: const Icon(Icons.message),
                    onPressed: () async {
                      final notificationProvider =
                      Provider.of<NotificationProvider>(
                        context,
                        listen: false,
                      );
                      notificationProvider.loadNotificationList(
                        cookie: authProvider.sessionCookie!,
                        partnerId: authProvider.partnerId!,
                      );

                      showDialog(
                        context: context,
                        builder: (BuildContext dialogContext) {
                          return Consumer<NotificationProvider>(
                            builder: (context, provider, child) {
                              return AlertDialog(
                                title: const Text('Notifications'),
                                content: SizedBox(
                                  width: double.maxFinite,
                                  height: 300,
                                  child: _buildDialogContent(provider),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(dialogContext),
                                    child: const Text('Close'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );
                    },
                  ),

                  if (unreadCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          unreadCount > 99 ? '99+' : unreadCount.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          // IconButton(
          //   icon: Icon(
          //     Icons.notifications_active,
          //     color: taskProvider.hasUncheckedTaskNotification
          //         ? Colors.red
          //         : null,
          //   ),
          //   onPressed: () async {
          //     final authProvider = context.read<AuthProvider>();
          //
          //     await taskProvider.fetchAssignedTasks(
          //       cookie: authProvider.sessionCookie!,
          //       userId: authProvider.uid!,
          //     );
          //
          //     taskProvider.markNotificationsAsRead();
          //
          //     // showDialog(
          //     //   context: context,
          //     //   builder: (_) {
          //     //     return Consumer<TaskProvider>(
          //     //       builder: (context, provider, child) {
          //     //         return Dialog(
          //     //           backgroundColor: Colors.white,
          //     //           shape: RoundedRectangleBorder(
          //     //             borderRadius: BorderRadius.circular(24),
          //     //           ),
          //     //           child: Padding(
          //     //             padding: const EdgeInsets.all(20.0),
          //     //             child: Column(
          //     //               mainAxisSize: MainAxisSize.min,
          //     //               crossAxisAlignment: CrossAxisAlignment.start,
          //     //               children: [
          //     //                 Row(
          //     //                   children: [
          //     //                     Container(
          //     //                       padding: const EdgeInsets.all(10),
          //     //                       decoration: BoxDecoration(
          //     //                         color: const Color(0xff714B67).withOpacity(0.12),
          //     //                         borderRadius: BorderRadius.circular(12),
          //     //                       ),
          //     //                       child: const Icon(
          //     //                         Icons.assignment_turned_in_rounded,
          //     //                         color: Color(0xff714B67),
          //     //                         size: 24,
          //     //                       ),
          //     //                     ),
          //     //                     const SizedBox(width: 14),
          //     //                     const Expanded(
          //     //                       child: Column(
          //     //                         crossAxisAlignment: CrossAxisAlignment.start,
          //     //                         children: [
          //     //                           Text(
          //     //                             "Assigned Tasks",
          //     //                             style: TextStyle(
          //     //                               fontSize: 18,
          //     //                               fontWeight: FontWeight.w700,
          //     //                               color: Color(0xff1F2937),
          //     //                             ),
          //     //                           ),
          //     //                           SizedBox(height: 2),
          //     //                           Text(
          //     //                             "Your active obligations",
          //     //                             style: TextStyle(
          //     //                               fontSize: 12,
          //     //                               color: Colors.grey,
          //     //                             ),
          //     //                           ),
          //     //                         ],
          //     //                       ),
          //     //                     ),
          //     //                   ],
          //     //                 ),
          //     //                 const Padding(
          //     //                   padding: EdgeInsets.symmetric(vertical: 16.0),
          //     //                   child: Divider(height: 1, thickness: 0.8),
          //     //                 ),
          //     //
          //     //                 ConstrainedBox(
          //     //                   constraints: BoxConstraints(
          //     //                     maxHeight: MediaQuery.of(context).size.height * 0.25,
          //     //                   ),
          //     //                   child: SizedBox(
          //     //                     width: double.maxFinite,
          //     //                     child: provider.loading
          //     //                         ? const Center(
          //     //                       child: Padding(
          //     //                         padding: EdgeInsets.symmetric(vertical: 24.0),
          //     //                         child: CircularProgressIndicator(
          //     //                           valueColor: AlwaysStoppedAnimation<Color>(Color(0xff714B67)),
          //     //                         ),
          //     //                       ),
          //     //                     )
          //     //                         : provider.assignedTasks.isEmpty
          //     //                         ? Center(
          //     //                       child: Padding(
          //     //                         padding: const EdgeInsets.symmetric(vertical: 32.0),
          //     //                         child: Column(
          //     //                           mainAxisSize: MainAxisSize.min,
          //     //                           children: [
          //     //                             Icon(Icons.task_alt_rounded, size: 48, color: Colors.grey.shade300),
          //     //                             const SizedBox(height: 12),
          //     //                             Text(
          //     //                               "No assigned tasks found.",
          //     //                               style: TextStyle(
          //     //                                 color: Colors.grey.shade600,
          //     //                                 fontSize: 14,
          //     //                                 fontWeight: FontWeight.w500,
          //     //                               ),
          //     //                             ),
          //     //                           ],
          //     //                         ),
          //     //                       ),
          //     //                     )
          //     //                         : ListView.separated(
          //     //                       shrinkWrap: true,
          //     //                       physics: const BouncingScrollPhysics(),
          //     //                       itemCount: provider.assignedTasks.length,
          //     //                       separatorBuilder: (_, __) => Divider(
          //     //                         height: 1,
          //     //                         thickness: 0.6,
          //     //                         color: Colors.grey.shade100,
          //     //                       ),
          //     //                       itemBuilder: (context, index) {
          //     //                         final task = provider.assignedTasks[index];
          //     //                         return Material(
          //     //                           color: Colors.transparent,
          //     //                           child: ListTile(
          //     //                             contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          //     //                             leading: Container(
          //     //                               padding: const EdgeInsets.all(8),
          //     //                               decoration: BoxDecoration(
          //     //                                 color: const Color(0xffF3EEF5),
          //     //                                 borderRadius: BorderRadius.circular(10),
          //     //                               ),
          //     //                               child: const Icon(
          //     //                                 Icons.task_alt,
          //     //                                 color: Color(0xff714B67),
          //     //                                 size: 20,
          //     //                               ),
          //     //                             ),
          //     //                             title: Text(
          //     //                               task['name'] ?? 'No Task Name',
          //     //                               maxLines: 1,
          //     //                               overflow: TextOverflow.ellipsis,
          //     //                               style: const TextStyle(
          //     //                                 fontSize: 14.5,
          //     //                                 fontWeight: FontWeight.w600,
          //     //                                 color: Color(0xff1F2937),
          //     //                               ),
          //     //                             ),
          //     //                             subtitle: Padding(
          //     //                               padding: const EdgeInsets.only(top:4),
          //     //                               child: Text(
          //     //                                 task['project_id'] is List
          //     //                                     ? task['project_id'][1].toString()
          //     //                                     : 'No Project',
          //     //                                 maxLines: 1,
          //     //                                 overflow: TextOverflow.ellipsis,
          //     //                                 style: TextStyle(
          //     //                                   fontSize: 12,
          //     //                                   color: Colors.grey.shade500,
          //     //                                 ),
          //     //                               ),
          //     //                             ),
          //     //                             onTap: () {
          //     //                               Navigator.pop(context);
          //     //                               print("Clicked task ID: ${task['id']}");
          //     //                             },
          //     //                           ),
          //     //                         );
          //     //                       },
          //     //                     ),
          //     //                   ),
          //     //                 ),
          //     //
          //     //                 const SizedBox(height: 16),
          //     //
          //     //                 Row(
          //     //                   mainAxisAlignment: MainAxisAlignment.end,
          //     //                   children: [
          //     //                     TextButton(
          //     //                       style: TextButton.styleFrom(
          //     //                         foregroundColor: const Color(0xff714B67),
          //     //                         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          //     //                         shape: RoundedRectangleBorder(
          //     //                           borderRadius: BorderRadius.circular(12),
          //     //                         ),
          //     //                       ),
          //     //                       onPressed: () => Navigator.pop(context),
          //     //                       child: const Text(
          //     //                         "Close",
          //     //                         style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          //     //                       ),
          //     //                     ),
          //     //                   ],
          //     //                 ),
          //     //               ],
          //     //             ),
          //     //           ),
          //     //         );
          //     //       },
          //     //     );
          //     //   },
          //     // );
          //
          //     showGeneralDialog(
          //       context: context,
          //       barrierDismissible: true,
          //       barrierLabel: "Dismiss Tasks Menu",
          //       barrierColor: Colors.black.withOpacity(0.15),
          //       transitionDuration: const Duration(milliseconds: 220),
          //       pageBuilder: (context, animation, secondaryAnimation) {
          //         return Consumer<TaskProvider>(
          //           builder: (context, provider, child) {
          //             final double topPadding =
          //                 MediaQuery.of(context).padding.top +
          //                 kToolbarHeight -
          //                 8;
          //             return Align(
          //               alignment: Alignment.topRight,
          //               child: Padding(
          //                 padding: EdgeInsets.only(top: topPadding, right: 12),
          //                 child: Material(
          //                   type: MaterialType.transparency,
          //                   child: Container(
          //                     width: MediaQuery.of(context).size.width * 0.85,
          //                     decoration: BoxDecoration(
          //                       color: Colors.white,
          //                       borderRadius: BorderRadius.circular(20),
          //                       boxShadow: [
          //                         BoxShadow(
          //                           color: Colors.black.withOpacity(0.08),
          //                           blurRadius: 16,
          //                           offset: const Offset(0, 8),
          //                         ),
          //                       ],
          //                     ),
          //                     child: Padding(
          //                       padding: const EdgeInsets.all(16.0),
          //                       child: Column(
          //                         mainAxisSize: MainAxisSize.min,
          //                         crossAxisAlignment: CrossAxisAlignment.start,
          //                         children: [
          //                           Row(
          //                             children: [
          //                               Container(
          //                                 padding: const EdgeInsets.all(8),
          //                                 decoration: BoxDecoration(
          //                                   color: const Color(
          //                                     0xff714B67,
          //                                   ).withOpacity(0.12),
          //                                   borderRadius: BorderRadius.circular(
          //                                     10,
          //                                   ),
          //                                 ),
          //                                 child: const Icon(
          //                                   Icons.assignment_turned_in_rounded,
          //                                   color: Color(0xff714B67),
          //                                   size: 20,
          //                                 ),
          //                               ),
          //                               const SizedBox(width: 12),
          //                               const Expanded(
          //                                 child: Column(
          //                                   crossAxisAlignment:
          //                                       CrossAxisAlignment.start,
          //                                   children: [
          //                                     Text(
          //                                       "Assigned Tasks",
          //                                       style: TextStyle(
          //                                         fontSize: 16,
          //                                         fontWeight: FontWeight.w700,
          //                                         color: Color(0xff1F2937),
          //                                       ),
          //                                     ),
          //                                     SizedBox(height: 1),
          //                                     Text(
          //                                       "Your active obligations",
          //                                       style: TextStyle(
          //                                         fontSize: 11,
          //                                         color: Colors.grey,
          //                                       ),
          //                                     ),
          //                                   ],
          //                                 ),
          //                               ),
          //                             ],
          //                           ),
          //                           const Padding(
          //                             padding: EdgeInsets.symmetric(
          //                               vertical: 12.0,
          //                             ),
          //                             child: Divider(height: 1, thickness: 0.8),
          //                           ),
          //
          //                           ConstrainedBox(
          //                             constraints: BoxConstraints(
          //                               maxHeight:
          //                                   MediaQuery.of(context).size.height *
          //                                   0.35,
          //                             ),
          //                             child: SizedBox(
          //                               width: double.maxFinite,
          //                               child: provider.loading
          //                                   ? const Center(
          //                                       child: Padding(
          //                                         padding: EdgeInsets.symmetric(
          //                                           vertical: 24.0,
          //                                         ),
          //                                         child: CircularProgressIndicator(
          //                                           strokeWidth: 3,
          //                                           valueColor:
          //                                               AlwaysStoppedAnimation<
          //                                                 Color
          //                                               >(Color(0xff714B67)),
          //                                         ),
          //                                       ),
          //                                     )
          //                                   : provider.assignedTasks.isEmpty
          //                                   ? Center(
          //                                       child: Padding(
          //                                         padding:
          //                                             const EdgeInsets.symmetric(
          //                                               vertical: 24.0,
          //                                             ),
          //                                         child: Column(
          //                                           mainAxisSize:
          //                                               MainAxisSize.min,
          //                                           children: [
          //                                             Icon(
          //                                               Icons.task_alt_rounded,
          //                                               size: 40,
          //                                               color: Colors
          //                                                   .grey
          //                                                   .shade300,
          //                                             ),
          //                                             const SizedBox(height: 8),
          //                                             Text(
          //                                               "No assigned tasks found.",
          //                                               style: TextStyle(
          //                                                 color: Colors
          //                                                     .grey
          //                                                     .shade600,
          //                                                 fontSize: 13,
          //                                                 fontWeight:
          //                                                     FontWeight.w500,
          //                                               ),
          //                                             ),
          //                                           ],
          //                                         ),
          //                                       ),
          //                                     )
          //                                   : ListView.separated(
          //                                       shrinkWrap: true,
          //                                       padding: EdgeInsets.zero,
          //                                       physics:
          //                                           const BouncingScrollPhysics(),
          //                                       itemCount: provider
          //                                           .assignedTasks
          //                                           .length,
          //                                       separatorBuilder: (_, __) =>
          //                                           Divider(
          //                                             height: 1,
          //                                             thickness: 0.6,
          //                                             color:
          //                                                 Colors.grey.shade100,
          //                                           ),
          //                                       itemBuilder: (context, index) {
          //                                         final task = provider
          //                                             .assignedTasks[index];
          //                                         return ListTile(
          //                                           contentPadding:
          //                                               const EdgeInsets.symmetric(
          //                                                 horizontal: 4,
          //                                                 vertical: 0,
          //                                               ),
          //                                           leading: Container(
          //                                             padding:
          //                                                 const EdgeInsets.all(
          //                                                   6,
          //                                                 ),
          //                                             decoration: BoxDecoration(
          //                                               color: const Color(
          //                                                 0xffF3EEF5,
          //                                               ),
          //                                               borderRadius:
          //                                                   BorderRadius.circular(
          //                                                     8,
          //                                                   ),
          //                                             ),
          //                                             child: const Icon(
          //                                               Icons.task_alt,
          //                                               color: Color(
          //                                                 0xff714B67,
          //                                               ),
          //                                               size: 18,
          //                                             ),
          //                                           ),
          //                                           title: Text(
          //                                             task['name'] ??
          //                                                 'No Task Name',
          //                                             maxLines: 1,
          //                                             overflow:
          //                                                 TextOverflow.ellipsis,
          //                                             style: const TextStyle(
          //                                               fontSize: 13.5,
          //                                               fontWeight:
          //                                                   FontWeight.w600,
          //                                               color: Color(
          //                                                 0xff1F2937,
          //                                               ),
          //                                             ),
          //                                           ),
          //                                           subtitle: Padding(
          //                                             padding:
          //                                                 const EdgeInsets.only(
          //                                                   top: 2,
          //                                                 ),
          //                                             child: Text(
          //                                               task['project_id']
          //                                                       is List
          //                                                   ? task['project_id'][1]
          //                                                         .toString()
          //                                                   : 'No Project',
          //                                               maxLines: 1,
          //                                               overflow: TextOverflow
          //                                                   .ellipsis,
          //                                               style: TextStyle(
          //                                                 fontSize: 11.5,
          //                                                 color: Colors
          //                                                     .grey
          //                                                     .shade500,
          //                                               ),
          //                                             ),
          //                                           ),
          //                                           onTap: () {
          //                                             Navigator.pop(context);
          //                                             print(
          //                                               "Clicked task ID: ${task['id']}",
          //                                             );
          //                                           },
          //                                         );
          //                                       },
          //                                     ),
          //                             ),
          //                           ),
          //                           const SizedBox(height: 12),
          //
          //                           Row(
          //                             mainAxisAlignment: MainAxisAlignment.end,
          //                             children: [
          //                               TextButton(
          //                                 style: TextButton.styleFrom(
          //                                   foregroundColor: const Color(
          //                                     0xff714B67,
          //                                   ),
          //
          //                                   padding: const EdgeInsets.symmetric(
          //                                     horizontal: 16,
          //                                     vertical: 8,
          //                                   ),
          //                                   shape: RoundedRectangleBorder(
          //                                     borderRadius:
          //                                         BorderRadius.circular(8),
          //                                   ),
          //                                 ),
          //                                 onPressed: () =>
          //                                     Navigator.pop(context),
          //                                 child: const Text(
          //                                   "Close",
          //                                   style: TextStyle(
          //                                     fontWeight: FontWeight.w600,
          //                                     fontSize: 13,
          //                                   ),
          //                                 ),
          //                               ),
          //                             ],
          //                           ),
          //                         ],
          //                       ),
          //                     ),
          //                   ),
          //                 ),
          //               ),
          //             );
          //           },
          //         );
          //       },
          //
          //       transitionBuilder:
          //           (context, animation, secondaryAnimation, child) {
          //             return ScaleTransition(
          //               alignment: const Alignment(0.85, -0.9),
          //               scale: CurvedAnimation(
          //                 parent: animation,
          //                 curve: Curves.easeOutCubic,
          //               ),
          //               child: FadeTransition(opacity: animation, child: child),
          //             );
          //           },
          //     );
          //   },
          // ),
          // IconButton(
          //   icon: Icon(
          //     Icons.notifications_active,
          //     color: discussNotificationProvider.notifications.isNotEmpty
          //         ? Colors.red
          //         : null,
          //   ),
          //   onPressed: () async {
          //     final provider = context.read<NotificationProvider>();
          //
          //     // Fetch notifications if not already fetched
          //     await provider.fetchNotifications(
          //       cookie: authProvider.sessionCookie!,
          //       myPartnerId: authProvider.partnerId!,
          //     );
          //
          //     if (!mounted) return;
          //     showModalBottomSheet(
          //       context: context,
          //       backgroundColor: const Color(0xff101828),
          //       shape: const RoundedRectangleBorder(
          //         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          //       ),
          //       builder: (context) {
          //         // We use Consumer here so this specific UI fragment rebuilds when data changes
          //         return Consumer<DiscussNotificationProvider>(
          //           builder: (context, provider, child) {
          //             // 1. Show a loading indicator while the network request is running
          //             if (provider.isLoading) {
          //               return const SizedBox(
          //                 height: 200,
          //                 child: Center(
          //                   child: CircularProgressIndicator(color: Colors.white),
          //                 ),
          //               );
          //             }
          //
          //             // 2. Show an error message if the API call failed
          //             if (provider.errorMessage.isNotEmpty) {
          //               return SizedBox(
          //                 height: 200,
          //                 child: Center(
          //                   child: Padding(
          //                     padding: const EdgeInsets.all(16.0),
          //                     child: Text(
          //                       provider.errorMessage,
          //                       style: const TextStyle(color: Colors.redAccent),
          //                       textAlign: TextAlign.center,
          //                     ),
          //                   ),
          //                 ),
          //               );
          //             }
          //
          //             final notifications = provider.notifications;
          //
          //             // 3. Show "No notifications" only if we successfully loaded an empty list
          //             if (notifications.isEmpty) {
          //               return const SizedBox(
          //                 height: 200,
          //                 child: Center(
          //                   child: Text(
          //                     "No notifications",
          //                     style: TextStyle(color: Colors.white70),
          //                   ),
          //                 ),
          //               );
          //             }
          //
          //             return SizedBox(
          //               height: 400,
          //               child: ListView.separated(
          //                 padding: const EdgeInsets.all(16),
          //                 itemCount: notifications.length,
          //                 separatorBuilder: (_, __) => const Divider(color: Colors.white24),
          //                 itemBuilder: (_, index) {
          //                   final n = notifications[index];
          //                   final title = n['title'] ?? 'Notification';
          //                   final subtitle = n['subtitle'] ?? '';
          //                   final type = n['type'] ?? 'Notification';
          //                   final time = n['time'] ?? '';
          //
          //                   return ListTile(
          //                     leading: const Icon(Icons.notifications, color: Colors.white70),
          //                     title: Text("$title", style: const TextStyle(color: Colors.white)),
          //                     subtitle: Text(
          //                       [
          //                         type,
          //                         if (subtitle.toString().isNotEmpty) subtitle,
          //                         if (time.toString().isNotEmpty) time,
          //                       ].join('\n'),
          //                       style: const TextStyle(color: Colors.white54, fontSize: 12),
          //                     ),
          //                     onTap: () {
          //                       Navigator.pop(context);
          //                       print("Tapped notification: $n");
          //                     },
          //                   );
          //                 },
          //               ),
          //             );
          //           },
          //         );
          //       },
          //     );
          //   },
          // ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff714B67),
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => SearchPage(source: SearchSource.profile),
            ),
          );
        },
        child: const Icon(Icons.add_comment),
      ),
      body: Consumer<InboxProvider>(
        builder: (context, provider, child) {

          if (provider.isLoading && provider.messages.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage.isNotEmpty) {
            return Center(child: Text(provider.errorMessage));
          }

          if (provider.messages.isEmpty) {
            return _emptyDiscussState();
          }

          final sortedMessages = [...provider.messages];

          sortedMessages.sort((a, b) {
            final dateA = DateTime.tryParse(a.date) ?? DateTime(1900);
            final dateB = DateTime.tryParse(b.date) ?? DateTime(1900);
            return dateA.compareTo(dateB);
          });

          final Map<int, DirectMessage> uniqueLatestMessageByChannel = {};

          for (final msg in sortedMessages) {
            if (msg.body.contains("AGORA_CALL::") ||
                msg.body.contains('"agora_call":')) {
              continue;
            }

            uniqueLatestMessageByChannel[msg.channelId] = msg;
          }

          final lastMessages = uniqueLatestMessageByChannel.values.toList();

          lastMessages.sort((a, b) {
            final dateA = DateTime.tryParse(a.date) ?? DateTime(1900);
            final dateB = DateTime.tryParse(b.date) ?? DateTime(1900);
            return dateB.compareTo(dateA);
          });

          if (lastMessages.isEmpty) {
            return _emptyDiscussState();
          }

          return RefreshIndicator(
            onRefresh: _loadMessages,
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: lastMessages.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                thickness: 0.7,
                indent: 76,
                color: Colors.grey.shade200,
              ),
              itemBuilder: (context, index) {
                final message = lastMessages[index];

                final otherParticipants = message.otherParticipants;

                final participantNames = otherParticipants
                    .map(
                      (p) => (p['display_name'] ?? 'Unknown')
                          .toString()
                          .trim(),
                    )
                    .where((name) => name.isNotEmpty)
                    .toList();

                final isGroup = otherParticipants.length > 1;
                final participantTitle = participantNames.join(', ');

                final String displayNameTitle =
                  //  isGroup &&
                            message.renamedGroupName != null &&
                            message.renamedGroupName!.isNotEmpty
                        ? message.renamedGroupName!
                        : participantTitle.isNotEmpty
                            ? participantTitle
                            : message.recordName.isNotEmpty
                                ? message.recordName
                                : message.authorName;

                final cleanPreviewText = _cleanDiscussPreview(message.body);
                final String? imageUrl = isGroup
                    ? _groupImageUrl(message.channelId)
                    : otherParticipants.isEmpty
                        ? null
                        : _partnerImageUrl(
                            _asInt(otherParticipants.first['partner_id']),
                          );
                final bool isUnread =
                    message.authorId != authProvider.partnerId &&
                        message.id > message.mySeenMessageId;

                return _discussChatTile(
                  title: displayNameTitle,
                  subtitle: cleanPreviewText,
                  time: _formatDiscussTime(message.date),
                  isGroup: isGroup,
                  isUnread: isUnread,
                  imageUrl: imageUrl,
                  sessionCookie: context.read<AuthProvider>().sessionCookie,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatPage(
                          partnerId: otherParticipants
                              .map<int>(
                                (participant) =>
                                    participant['partner_id'] as int,
                              )
                              .toList(),
                          title: displayNameTitle,
                          cookie: context.read<AuthProvider>().sessionCookie,
                          channelId: message.channelId,
                          source: ChatSource.directmsg,
                          image: imageUrl,
                        ),
                      ),
                    ).then(
                      (_) => _refreshInboxSilently(
                        changedChannelId: message.channelId,
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _discussChatTile({
    required String title,
    required String subtitle,
    required String time,
    required bool isGroup,
    required bool isUnread,
    required String? imageUrl,
    required String? sessionCookie,
    required VoidCallback onTap,
  }) {
    final firstLetter = title.trim().isNotEmpty
        ? title.trim()[0].toUpperCase()
        : '?';

    Widget fallbackAvatar() {
      return Center(
        child: isGroup
            ? const Icon(
          Icons.groups_2_outlined,
          color: Color(0xff714B67),
          size: 25,
        )
            : Text(
          firstLetter,
          style: const TextStyle(
            color: Color(0xff714B67),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isGroup
                    ? const Color(0xffE8DFF0)
                    : const Color(0xffF3EEF5),
                borderRadius: BorderRadius.circular(14),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: imageUrl == null || imageUrl.isEmpty
                    ? fallbackAvatar()
                    : Image.network(
                  imageUrl,
                  headers: sessionCookie == null || sessionCookie.isEmpty
                      ? null
                      : {'Cookie': sessionCookie},
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => fallbackAvatar(),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15.8,
                            fontWeight: isUnread
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: const Color(0xff1F2937),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 12,
                          color: isUnread
                              ? const Color(0xff714B67)
                              : Colors.grey.shade500,
                          fontWeight: isUnread
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle.isEmpty ? 'No message preview' : subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: isUnread ? Colors.black87 : Colors.grey.shade600,
                      fontWeight: isUnread ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chatLoadingTile() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 150, height: 12, color: Colors.grey.shade200),
                const SizedBox(height: 8),
                Container(width: 230, height: 10, color: Colors.grey.shade100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String? _partnerImageUrl(int? partnerId) {
    if (partnerId == null) return null;

    final baseUrl = context.read<InboxProvider>().service.baseUrl;
    return '$baseUrl/web/image?model=res.partner&id=$partnerId&field=image_128';
  }

  String? _groupImageUrl(int? channelId) {
    if (channelId == null) return null;

    final baseUrl = context.read<InboxProvider>().service.baseUrl;
    return '$baseUrl/web/image?model=discuss.channel&id=$channelId&field=image_128';
  }

  Future<int> _loadMySeenMessageId({
    required String cookie,
    required int channelId,
    required int? partnerId,
  }) async {
    if (partnerId == null) return 0;

    try {
      final result = await context.read<InboxProvider>().service.callKw(
        cookie: cookie,
        model: 'discuss.channel.member',
        method: 'search_read',
        args: [
          [
            ['channel_id', '=', channelId],
            ['partner_id', '=', partnerId],
          ],
        ],
        kwargs: {
          'fields': ['seen_message_id'],
          'limit': 1,
        },
      );

      if (result is List && result.isNotEmpty) {
        final seenMessage = result.first['seen_message_id'];
        if (seenMessage is List && seenMessage.isNotEmpty) {
          return _asInt(seenMessage.first) ?? 0;
        }
        return _asInt(seenMessage) ?? 0;
      }
    } catch (e) {
      debugPrint('LOAD MY SEEN MESSAGE ERROR: $e');
    }

    return 0;
  }

  Widget _emptyDiscussState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.forum_outlined, size: 72, color: Color(0xff714B67)),
          const SizedBox(height: 14),
          const Text(
            'No conversations yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            'Start a new direct message or group chat.',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  String _cleanDiscussPreview(String body) {
    final clean = body
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&quot;', '"')
        .replaceAll('&#34;', '"')
        .replaceAll('&amp;', '&')
        .replaceAll('&nbsp;', ' ')
        .trim();

    if (clean.contains('AGORA_CALL::')) {
      if (clean.contains('"call_type":"audio"')) return 'Audio call';
      if (clean.contains('"call_type":"video"')) return 'Video call';
      return 'Call';
    }

    return clean;
  }

  String _formatDiscussTime(String rawDate) {
    final date = DateTime.tryParse(rawDate);

    if (date == null) {
      return rawDate.length > 16 ? rawDate.substring(11, 16) : rawDate;
    }

    final now = DateTime.now();

    final isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;

    final yesterday = now.subtract(const Duration(days: 1));

    final isYesterday =
        date.year == yesterday.year &&
            date.month == yesterday.month &&
            date.day == yesterday.day;

    if (isToday) {
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }

    if (isYesterday) return 'Yesterday';

    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildSearchHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: const Color(0xffF1F5F9),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          children: [
            SizedBox(width: 14),
            Icon(Icons.search_rounded, color: Colors.grey),
            SizedBox(width: 10),
            Text(
              'Search messages...',
              style: TextStyle(color: Colors.grey, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  void showTaskPopup(
      BuildContext context,
      GlobalKey iconKey,
      TaskProvider provider,
      ) {
    final renderBox = iconKey.currentContext!.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);

    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    final entry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            // 🔥 tap outside to close
            GestureDetector(child: Container(color: Colors.black26)),

            Positioned(
              top: offset.dy + renderBox.size.height + 8,
              left: offset.dx - 120, // adjust alignment
              child: Material(
                elevation: 10,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 300,
                  height: 320, // 🔥 fixed height = scroll enabled
                  padding: const EdgeInsets.all(8),
                  child: provider.loading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                    shrinkWrap: true,
                    itemCount: provider.assignedTasks.length,
                    itemBuilder: (context, index) {
                      final task = provider.assignedTasks[index];

                      return ListTile(
                        dense: true,
                        leading: const Icon(Icons.task_alt, size: 18),
                        title: Text(
                          task['name'] ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          task['project_id'] is List
                              ? task['project_id'][1].toString()
                              : 'No Project',
                          maxLines: 1,
                        ),
                        onTap: () {
                          print("Task ID: ${task['id']}");
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(entry);
  }

  Widget _buildChatCard({
    required String title,
    required String subtitle,
    required String time,
    required bool isGroup,
    required bool isOnline,
    required int unreadCount,
    required VoidCallback onTap,
  }) {
    final String avatarText = title.trim().isNotEmpty
        ? title.trim()[0].toUpperCase()
        : '?';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.035),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: isGroup
                        ? const Color(0xffDCFCE7)
                        : const Color(0xffDBEAFE),
                    child: isGroup
                        ? const Icon(
                      Icons.groups_rounded,
                      color: Color(0xff16A34A),
                      size: 28,
                    )
                        : Text(
                      avatarText,
                      style: const TextStyle(
                        color: Color(0xff2563EB),
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  if (!isGroup)
                    Positioned(
                      right: 1,
                      bottom: 1,
                      child: Container(
                        width: 13,
                        height: 13,
                        decoration: BoxDecoration(
                          color: isOnline ? Colors.green : Colors.grey,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xff111827),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          time,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xff94A3B8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            subtitle.isEmpty ? 'No message preview' : subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xff64748B),
                            ),
                          ),
                        ),
                        if (unreadCount > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xff2563EB),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              unreadCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatSkeleton() {
    return Container(
      height: 84,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: Color(0xffE5E7EB),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 160,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xffE5E7EB),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: 220,
                  height: 10,
                  decoration: BoxDecoration(
                    color: const Color(0xffF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildDialogContent(NotificationProvider provider) {
  //   if (provider.isLoading) {
  //     return const Center(child: CircularProgressIndicator());
  //   }
  //
  //   if (provider.errorMessage.isNotEmpty) {
  //     return Center(
  //       child: Text(
  //         provider.errorMessage,
  //
  //         style: const TextStyle(color: Colors.red),
  //       ),
  //     );
  //   }
  //
  //   if (provider.notifications.isEmpty) {
  //     return const Center(child: Text('No new notifications'));
  //   }
  //
  //   return ListView.builder(
  //     itemCount: provider.notifications.length,
  //
  //     itemBuilder: (context, index) {
  //       final notification = provider.notifications[index];
  //
  //       String recordName = notification['author_id'];
  //
  //       if (notification['author_id'] is List &&
  //           (notification['author_id'] as List).length > 1) {
  //         recordName = notification['author_id'][1] ?? "";
  //       } else {
  //         recordName =
  //             "System Notification"; // Fallback if no author is present
  //       }
  //
  //       final String body = notification['last_message'] ?? '';
  //
  //       //  final String recordName = notification['name'] ?? "";
  //
  //       return ListTile(
  //         leading: const Icon(Icons.mail_outline),
  //
  //         title: Text(recordName),
  //
  //         // Simple regex preview to strip HTML tags from the Odoo message body if necessary
  //         subtitle: Text(
  //           body.replaceAll(RegExp(r'<[^>]*>|&ndash;'), ''),
  //
  //           maxLines: 2,
  //
  //           overflow: TextOverflow.ellipsis,
  //         ),
  //       );
  //     },
  //   );
  // }
  Widget _buildDialogContent(NotificationProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage.isNotEmpty) {
      return Center(
        child: Text(
          provider.errorMessage,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (provider.notifications.isEmpty) {
      return const Center(child: Text('No new notifications'));
    }

    return ListView.builder(
      itemCount: provider.notifications.length,
      itemBuilder: (context, index) {
        final notification = provider.notifications[index];

        String recordName = "System Notification";

        final rawAuthor = notification['author_id'];

        if (rawAuthor is List && rawAuthor.length > 1) {
          recordName = rawAuthor[1]?.toString() ?? "System Notification";
        } else if (rawAuthor is String && rawAuthor.isNotEmpty) {
          recordName = rawAuthor;
        }

        String body = "";

        final rawBody = notification['last_message'];

        if (rawBody is String) {
          body = rawBody;
        } else if (rawBody is List && rawBody.isNotEmpty) {
          body = rawBody.last.toString();
        } else if (rawBody != null) {
          body = rawBody.toString();
        }

        final cleanBody = body
            .replaceAll(RegExp(r'<[^>]*>'), '')
            .replaceAll('&nbsp;', ' ')
            .replaceAll('&ndash;', '-')
            .replaceAll('&amp;', '&')
            .trim();

        return ListTile(
          leading: const Icon(Icons.mail_outline),
          title: Text(recordName),
          subtitle: Text(
            cleanBody.isEmpty ? "No message preview" : cleanBody,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 86,
            height: 86,
            decoration: const BoxDecoration(
              color: Color(0xffDBEAFE),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chat_bubble_outline_rounded,
              size: 42,
              color: Color(0xff2563EB),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'No messages found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xff111827),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Start a new conversation using the chat button.',
            style: TextStyle(fontSize: 14, color: Color(0xff64748B)),
          ),
        ],
      ),
    );
  }

  String _cleanMessagePreview(String body) {
    String clean = body
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&quot;', '"')
        .replaceAll('&#34;', '"')
        .replaceAll('&amp;', '&')
        .replaceAll('&nbsp;', ' ')
        .trim();

    if (clean.contains('AGORA_CALL::')) {
      if (clean.contains('"call_type":"audio"')) {
        return '📞 Audio call';
      }
      if (clean.contains('"call_type":"video"')) {
        return '🎥 Video call';
      }
      return '📞 Call';
    }

    if (clean.isEmpty) {
      return 'No message preview';
    }

    return clean;
  }

  String _formatChatTime(String rawDate) {
    final date = DateTime.tryParse(rawDate);
    if (date == null) {
      return rawDate.length > 16 ? rawDate.substring(11, 16) : rawDate;
    }

    final now = DateTime.now();
    final isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;

    final yesterday = now.subtract(const Duration(days: 1));
    final isYesterday =
        date.year == yesterday.year &&
            date.month == yesterday.month &&
            date.day == yesterday.day;

    if (isToday) {
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }

    if (isYesterday) {
      return 'Yesterday';
    }

    return '${date.day}/${date.month}/${date.year}';
  }
}


