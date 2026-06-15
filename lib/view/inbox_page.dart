

import 'package:discuss/view/search_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/thread_model.dart';

import '../provider/auth_provider.dart';
import '../provider/chat_provider.dart';
import '../provider/inbox_provider.dart';
import '../provider/marked_read_provider.dart';
import '../services/agora_call_invitation_service.dart';
import '../services/agora_create_token.dart';
import '../services/call_ringtone_controller.dart';
import '../services/odoo_discuss_service.dart';
import 'agora_call_page.dart';

// import 'chat_page.dart';
import 'chat_page.dart';
import 'incoming_call_listener.dart';

class DirectMessagesScreen extends StatefulWidget {
  @override
  _DirectMessagesScreenState createState() => _DirectMessagesScreenState();
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

class _DirectMessagesScreenState extends State<DirectMessagesScreen> {
  late IncomingCallListener _incomingCallListener;
  static const String testingAppId = "339050bec1fe49b8bc5e17ca9d739fba";
  late final authProvider = context.read<AuthProvider>();

  @override
  void initState() {
    super.initState();
    debugPrint("=====> [INIT] InboxPage initState started.");
    _incomingCallListener = IncomingCallListener();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      debugPrint("=====> [POST_FRAME] Running Inbox post-frame setup...");
      final authProvider = context.read<AuthProvider>();
      final cookie = authProvider.sessionCookie;
      final partnerId = authProvider.partnerId;
      await _loadMessages();

      if (cookie == null || cookie.isEmpty || partnerId == null) {
        debugPrint("=====> [POST_FRAME] WARNING: Credentials missing.");
        return;
      }

      _incomingCallListener.startListening(
        context: context,
        cookie: cookie,
        myPartnerId: partnerId,
        onCallReceived: (Map<String, dynamic> inviteData) {
          _showIncomingCallUi(inviteData);
        },
        callKw: ({
          required String cookie,
          required String model,
          required String method,
          required List args,
          required Map<String, dynamic> kwargs,
        }) {
          return OdooDiscussService(baseUrl: "http://192.168.250.26:8069").callKw(
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
    _incomingCallListener.stopListening();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    final cookie = context.read<AuthProvider>().sessionCookie;
    final partnerId = authProvider.partnerId;
    if (cookie == null || cookie.isEmpty || partnerId == null) return;
    await context.read<InboxProvider>().loadDirectMessages(cookie, partnerId);
  }

  // --- PREMIUM UPGRADED INCOMING CALL DIALOG UI ---
  Future<void> _showIncomingCallUi(Map<String, dynamic> invite) async {
    if (!mounted) return;

    final String targetChannel = 'test_discuss';
    final String rawCallType = invite['call_type'] ?? 'video';
    final bool isAudioOnly = rawCallType == 'audio';

    final ringtoneController = CallRingtoneController();
    await ringtoneController.startRinging();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: const Color(0xff0F172A), // Dark slate aesthetic
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isAudioOnly ? Colors.green.withOpacity(0.15) : Colors.blue.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isAudioOnly ? Icons.phone_forwarded : Icons.video_chat_rounded,
                    color: isAudioOnly ? Colors.greenAccent : Colors.blueAccent,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  isAudioOnly ? "Incoming Audio Call" : "Incoming Video Call",
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: .3),
                ),
                const SizedBox(height: 8),
                Text(
                  "User ${invite['from_partner_id']} is calling...",
                  style: TextStyle(color: Colors.blueGrey.shade300, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.redAccent.withOpacity(0.4)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        icon: const Icon(Icons.call_end, color: Colors.redAccent, size: 18),
                        label: const Text("Decline", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
                        onPressed: () async {
                          await ringtoneController.stopRinging();
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
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        icon: const Icon(Icons.call, size: 18),
                        label: const Text("Answer", style: TextStyle(fontWeight: FontWeight.w600)),
                        onPressed: () async {
                          await ringtoneController.stopRinging();
                          final authProv = context.read<AuthProvider>();
                          final currentUid = authProv.partnerId;
                          final String currentUserName = authProv.userName ?? "User_${authProv.partnerId}";

                          if (currentUid == null) return;

                          Navigator.pop(dialogContext);
                          final String token = await generateAgoraToken(currentUid);

                          if (context.mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AgoraCallPage(
                                  channelName: targetChannel,
                                  callerName: currentUserName,
                                  appId: testingAppId,
                                  token: token,
                                  uid: currentUid,
                                  isAudioOnly: isAudioOnly,
                                ),
                              ),
                            );
                          }
                          _incomingCallListener.resetCallState();
                        },
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    ).then((_) async {
      await ringtoneController.stopRinging();
    });
  }

  // --- RENDERS INITIALS/COLOR MATCHING PATTERN AVATARS ---
  Widget _buildAvatar(String title, List<dynamic> participants) {
    final String cleanTitle = title.replaceAll(RegExp(r'[^\w\s]'), '').trim();
    final String initial = cleanTitle.isNotEmpty ? cleanTitle[0].toUpperCase() : "?";

    // Choose specific background colors dynamically based on title hashing signature rules
    final List<Color> avatarColors = [
      Colors.indigo.shade600,
      Colors.teal.shade600,
      Colors.blueGrey.shade600,
      Colors.blue.shade700,
      Colors.deepPurple.shade600
    ];
    final Color selectedColor = avatarColors[title.length % avatarColors.length];

    if (participants.length > 1) {
      // Group Chat Icon Framework Layout Style Variant
      return Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(color: Colors.blueGrey.shade300, shape: BoxShape.circle),
        child: const Icon(Icons.groups_rounded, color: Colors.blueAccent, size: 26),
      );
    }

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(color: selectedColor, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: .5),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
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
        child: const Icon(Icons.edit_square),
      ),
      body: Consumer<InboxProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
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

                return FutureBuilder<List<dynamic>>(
                  future: Future.wait([
                    context
                        .read<MessageReadStatusProvider>()
                        .service
                        .getOtherParticipantPartnerIds(
                      cookie: context.read<AuthProvider>().sessionCookie!,
                      channelId: message.channelId,
                      myPartnerId: authProvider.partnerId,
                    ),
                    context.read<ChatProvider>().loadrename(
                      cookie: context.read<AuthProvider>().sessionCookie!,
                      channelId: message.channelId,
                    ),
                  ]),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _chatLoadingTile();
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    final List<dynamic> otherParticipants =
                    snapshot.data![0] as List<dynamic>;

                    final String? renamedGroupName =
                    snapshot.data![1] as String?;

                    final participantNames = otherParticipants.map((p) {
                      var displayName = p['display_name'] ?? 'Unknown';

                      if (authProvider.userName != null &&
                          displayName.contains(authProvider.userName)) {
                        displayName = displayName
                            .replaceAll(authProvider.userName!, '')
                            .trim();
                      }

                      displayName =
                          displayName.replaceAll(RegExp(r'^,|,$'), '').trim();

                      return displayName
                          .toString()
                          .replaceAll('“', '')
                          .replaceAll('”', '')
                          .replaceAll(message.authorName, '')
                          .split(' in')[0]
                          .trim();
                    }).toList();

                    final String displayNameTitle =
                    renamedGroupName != null && renamedGroupName.isNotEmpty
                        ? renamedGroupName
                        : participantNames.join(', ').isEmpty
                        ? message.authorName
                        : participantNames.join(', ');

                    final cleanPreviewText = _cleanDiscussPreview(message.body);
                    final isGroup = otherParticipants.length > 1;

                    return _discussChatTile(
                      title: displayNameTitle,
                      subtitle: cleanPreviewText,
                      time: _formatDiscussTime(message.date),
                      isGroup: isGroup,
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
                            ),
                          ),
                        ).then((_) => _loadMessages());
                      },
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
    required VoidCallback onTap,
  }) {
    final firstLetter = title.trim().isNotEmpty ? title.trim()[0].toUpperCase() : '?';

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
              child: Center(
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
                          style: const TextStyle(
                            fontSize: 15.8,
                            fontWeight: FontWeight.w600,
                            color: Color(0xff1F2937),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
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
                      color: Colors.grey.shade600,
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
                Container(
                  width: 150,
                  height: 12,
                  color: Colors.grey.shade200,
                ),
                const SizedBox(height: 8),
                Container(
                  width: 230,
                  height: 10,
                  color: Colors.grey.shade100,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyDiscussState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.forum_outlined,
            size: 72,
            color: Color(0xff714B67),
          ),
          const SizedBox(height: 14),
          const Text(
            'No conversations yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Start a new direct message or group chat.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
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

    final isYesterday = date.year == yesterday.year &&
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

  Widget _buildChatCard({
    required String title,
    required String subtitle,
    required String time,
    required bool isGroup,
    required bool isOnline,
    required int unreadCount,
    required VoidCallback onTap,
  }) {
    final String avatarText =
    title.trim().isNotEmpty ? title.trim()[0].toUpperCase() : '?';

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
            style: TextStyle(
              fontSize: 14,
              color: Color(0xff64748B),
            ),
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
    final isYesterday = date.year == yesterday.year &&
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


