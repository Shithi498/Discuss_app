import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../provider/auth_provider.dart';
import '../provider/call_provider.dart';

// class AudioCallPage extends StatefulWidget {
//   final String cookie;
//   final int channelId;
//   final int partnerId;
//   final int memberId;
//
//   AudioCallPage({
//     required this.cookie,
//     required this.channelId,
//     required this.partnerId, required this.memberId,
//   });
//
//   @override
//   _AudioCallPageState createState() => _AudioCallPageState();
// }
//
// class _AudioCallPageState extends State<AudioCallPage> {
//   bool isCallActive = false;
//   bool isLoading = false;
//   String? error;
//
//   @override
//   void initState() {
//     super.initState();
//     _requestPermissions();
//   }
//   Future<void> _requestPermissions() async {
//
//     PermissionStatus cameraStatus = await Permission.camera.request();
//     PermissionStatus microphoneStatus = await Permission.microphone.request();
//
//     if (cameraStatus.isGranted && microphoneStatus.isGranted) {
//       print("Camera and Microphone permissions granted");
//
//     } else {
//       print("Camera and/or Microphone permissions denied");
//
//     }
//   }
//   Future<void> _startCall() async {
//     setState(() {
//       isLoading = true;
//     });
//
//     final callProvider = context.read<CallProvider>();
//
//     try {
//       await callProvider.startAudioCall(
//         cookie: widget.cookie,
//         channelId: widget.channelId,
//         partnerId: widget.partnerId,
//         memberId: widget.memberId,
//       );
//
//       setState(() {
//         isCallActive = true;
//         isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         error = "Failed to start call: $e";
//         isLoading = false;
//       });
//     }
//   }
//
//   Future<void> _endCall() async {
//     setState(() {
//       isLoading = true;
//     });
//
//     final callProvider = context.read<CallProvider>();
//
//     try {
//       await callProvider.endAudioCall(
//         cookie: widget.cookie,
//         channelId: widget.channelId,
//       );
//
//       setState(() {
//         isCallActive = false;
//         isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         error = "Failed to end call: $e";
//         isLoading = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Audio Call")),
//       body: Column(
//         children: [
//           if (isLoading)
//             CircularProgressIndicator()
//           else if (error != null) ...[
//             Text(error!),
//           ],
//           Spacer(),
//           IconButton(
//             icon: Icon(
//               isCallActive ? Icons.call_end : Icons.phone,
//               color: isCallActive ? Colors.red : null,
//             ),
//             onPressed: isCallActive ? _endCall : _startCall,
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:async';
import '../services/audio_call_service.dart';
import '../services/odoo_discuss_service.dart';
import '../services/rtc_signaling_service.dart';

// class AudioCallPage extends StatefulWidget {
//   final String cookie;
//   final int channelId;
//   final int partnerId;
//   final int memberId;
//   final String callerName;
//   final bool? isIncomingCall;
//
//   const AudioCallPage({
//     super.key,
//     required this.cookie,
//     required this.channelId,
//     required this.partnerId,
//     required this.memberId,
//     this.callerName = "Unknown User",
//     this.isIncomingCall= false,
//   });
//
//   @override
//   State<AudioCallPage> createState() => _AudioCallPageState();
// }
//
// class _AudioCallPageState extends State<AudioCallPage> {
//   bool isCallActive = false;
//   bool isLoading = false;
//   bool isMuted = false;
//   bool isSpeakerOn = true;
//   String? error;
//   final AudioCallService audioCallService = AudioCallService();
//
//   late final RtcSignalingService signalingService;
//
//   int? lastSignalMessageId;
//   Timer? _timer;
//   int callSeconds = 0;
//   Timer? rtcSignalTimer;
//
//   void startSignalPolling({
//     required String cookie,
//     required int channelId,
//     required int myPartnerId,
//   }) {
//     rtcSignalTimer?.cancel();
//
//     rtcSignalTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
//       final signals = await signalingService.fetchSignals(
//         cookie: cookie,
//         channelId: channelId,
//         myPartnerId: myPartnerId,
//         lastMessageId: lastSignalMessageId,
//       );
//
//       for (final signal in signals) {
//         lastSignalMessageId = signal['message_id'];
//
//         if (signal['type'] == 'answer') {
//           await audioCallService.setRemoteAnswer(
//             signal['data']['sdp'],
//           );
//         }
//
//         if (signal['type'] == 'ice') {
//           await audioCallService.addRemoteIceCandidate(
//             candidate: signal['data']['candidate'],
//             sdpMid: signal['data']['sdpMid'],
//             sdpMLineIndex: signal['data']['sdpMLineIndex'],
//           );
//         }
//       }
//     });
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     signalingService = RtcSignalingService(
//       callKw: OdooDiscussService(baseUrl: 'https://demo.kendroo.com').callKw,
//     );
//     _requestPermissions();
//   }
//
//   @override
//   void dispose() {
//     _timer?.cancel();
//     super.dispose();
//   }
//
//   Future<void> _requestPermissions() async {
//     final microphoneStatus = await Permission.microphone.request();
//
//     if (!microphoneStatus.isGranted) {
//       setState(() {
//         error = "Microphone permission denied";
//       });
//     }
//   }
//
//   void _startTimer() {
//     _timer?.cancel();
//     callSeconds = 0;
//
//     _timer = Timer.periodic(const Duration(seconds: 1), (_) {
//       if (!mounted) return;
//       setState(() {
//         callSeconds++;
//       });
//     });
//   }
//
//   String _formatDuration(int seconds) {
//     final minutes = seconds ~/ 60;
//     final sec = seconds % 60;
//     return "${minutes.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}";
//   }
//
//   // Start the call
//   Future<void> _startCall() async {
//     setState(() {
//       isLoading = true;
//     });
//
//     final callProvider = context.read<CallProvider>();
//     final authProvider = context.read<AuthProvider>();
//
//     try {
//       await callProvider.startAudioCall(
//         cookie: widget.cookie,
//         channelId: widget.channelId,
//         partnerId: widget.partnerId,
//         memberId: widget.memberId,
//       );
//
//       await audioCallService.initializeWebRTC();
//
//       // Set up ICE candidate handling
//       audioCallService.onIceCandidate = (candidate) async {
//         await signalingService.sendSignal(
//           cookie: widget.cookie,
//           channelId: widget.channelId,
//           fromPartnerId: authProvider.partnerId!,
//           type: 'ice',
//           data: {
//             'candidate': candidate.candidate,
//             'sdpMid': candidate.sdpMid,
//             'sdpMLineIndex': candidate.sdpMLineIndex,
//           },
//         );
//       };
//
//       // Create and send the offer
//       final offer = await audioCallService.createOffer();
//
//       await signalingService.sendSignal(
//         cookie: widget.cookie,
//         channelId: widget.channelId,
//         fromPartnerId: authProvider.partnerId!,
//         type: 'offer',
//         data: {
//           'sdp': offer.sdp,
//         },
//       );
//
//       // Start polling for RTC signals
//       startSignalPolling(
//         cookie: widget.cookie,
//         channelId: widget.channelId,
//         myPartnerId: authProvider.partnerId!,
//       );
//
//       setState(() {
//         isCallActive = true;
//         isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         error = "Failed to start call: $e";
//         print("Failed to start call: $e");
//         isLoading = false;
//       });
//     }
//   }
//
//
//   // Future<void> _receiveCall() async {
//   //   setState(() {
//   //     isLoading = true;
//   //     error = null;
//   //   });
//   //
//   //   final callProvider = context.read<CallProvider>();
//   //   final authProv = context.read<AuthProvider>();
//   //
//   //   try {
//   //     await callProvider.receiveAudioCall(
//   //       cookie: widget.cookie,
//   //       channelId: widget.channelId,
//   //       partnerId: authProv.uid!,
//   //       memberId: authProv.partnerId!,
//   //     );
//   //     await audioCallService.initializeWebRTC();
//   //
//   //     audioCallService.onIceCandidate = (candidate) async {
//   //       await signalingService.sendSignal(
//   //         cookie: widget.cookie,
//   //         channelId: widget.channelId,
//   //         fromPartnerId: authProv.partnerId!,
//   //         type: 'ice',
//   //         data: {
//   //           'candidate': candidate.candidate,
//   //           'sdpMid': candidate.sdpMid,
//   //           'sdpMLineIndex': candidate.sdpMLineIndex,
//   //         },
//   //       );
//   //     };
//   //
//   //     final signals = await signalingService.fetchSignals(
//   //       cookie: widget.cookie,
//   //       channelId: widget.channelId,
//   //       myPartnerId: authProv.partnerId!,
//   //     );
//   //
//   //     final offerSignal = signals.firstWhere(
//   //           (s) => s['type'] == 'offer',
//   //     );
//   //
//   //     await audioCallService.setRemoteOffer(
//   //       offerSignal['data']['sdp'],
//   //     );
//   //
//   //     final answer = await audioCallService.createAnswer();
//   //
//   //     await signalingService.sendSignal(
//   //       cookie: widget.cookie,
//   //       channelId: widget.channelId,
//   //       fromPartnerId: authProv.partnerId!,
//   //       type: 'answer',
//   //       data: {
//   //         'sdp': answer.sdp,
//   //       },
//   //     );
//   //
//   //     if (!mounted) return;
//   //
//   //     setState(() {
//   //       isCallActive = true;
//   //       isLoading = false;
//   //     });
//   //
//   //     _startTimer();
//   //   } catch (e) {
//   //     if (!mounted) return;
//   //
//   //     setState(() {
//   //       error = "Failed to receive call: $e";
//   //       isLoading = false;
//   //     });
//   //   }
//   // }
//   Future<void> _receiveCall() async {
//     setState(() {
//       isLoading = true;
//       error = null;
//     });
//
//     final callProvider = context.read<CallProvider>();
//     final authProv = context.read<AuthProvider>();
//
//     try {
//       // 1. Double check your backend structure here. Usually:
//       // partnerId should be the remote peer's ID (Jareen - 11)
//       // memberId or similar should be you (9)
//       await callProvider.receiveAudioCall(
//         cookie: widget.cookie,
//         channelId: widget.channelId,
//         partnerId: authProv.uid!,       // Your ID (9)
//         memberId: authProv.partnerId!
//         , // Jareen's ID (11)
//       );
//
//       await audioCallService.initializeWebRTC();
//
//       audioCallService.onIceCandidate = (candidate) async {
//         await signalingService.sendSignal(
//           cookie: widget.cookie,
//           channelId: widget.channelId,
//           fromPartnerId: authProv.uid!, // SHOULD BE YOUR ID (9) - you are sending it
//           type: 'ice',
//           data: {
//             'candidate': candidate.candidate,
//             'sdpMid': candidate.sdpMid,
//             'sdpMLineIndex': candidate.sdpMLineIndex,
//           },
//         );
//       };
//
//       Map<String, dynamic>? offerSignal;
//
//       for (int i = 0; i < 10; i++) {
//         // FIX HERE: Pass YOUR ID to myPartnerId so you filter out YOUR OWN signals,
//         // allowing Jareen's (11) signals to bypass the 'continue' block.
//         final signals = await signalingService.fetchSignals(
//           cookie: widget.cookie,
//           channelId: widget.channelId,
//           myPartnerId: authProv.partnerId!
//         );
//
//         print("FETCHED SIGNALS: $signals");
//
//         final offers = signals.where((s) => s['type'] == 'offer').toList();
//
//         if (offers.isNotEmpty) {
//           offerSignal = Map<String, dynamic>.from(offers.last);
//           break;
//         }
//
//         await Future.delayed(const Duration(seconds: 1));
//       }
//
//       if (offerSignal == null) {
//         throw Exception("No offer signal found for this call");
//       }
//
//       await audioCallService.setRemoteOffer(
//         offerSignal['data']['sdp'],
//       );
//
//       final answer = await audioCallService.createAnswer();
//
//       await signalingService.sendSignal(
//         cookie: widget.cookie,
//         channelId: widget.channelId,
//         fromPartnerId: authProv.uid!, // SHOULD BE YOUR ID (9) - you are answering
//         type: 'answer',
//         data: {
//           'sdp': answer.sdp,
//           'type': answer.type,
//         },
//       );
//
//       if (!mounted) return;
//
//       setState(() {
//         isCallActive = true;
//         isLoading = false;
//       });
//
//       _startTimer();
//     } catch (e) {
//       if (!mounted) return;
//
//       setState(() {
//         error = "Failed to receive call: $e";
//         isLoading = false;
//       });
//     }
//   }
//
//   Future<void> _endCall() async {
//     setState(() {
//       isLoading = true;
//       error = null;
//     });
//
//     final callProvider = context.read<CallProvider>();
//
//     try {
//       await callProvider.endAudioCall(
//         cookie: widget.cookie,
//         channelId: widget.channelId,
//       );
//
//       _timer?.cancel();
//
//       if (!mounted) return;
//
//       setState(() {
//         isCallActive = false;
//         isLoading = false;
//         callSeconds = 0;
//       });
//
//       Navigator.pop(context);
//     } catch (e) {
//       if (!mounted) return;
//
//       setState(() {
//         error = "Failed to end call: $e";
//         isLoading = false;
//       });
//     }
//   }
//
//   // Toggle mute status
//   void _toggleMute() {
//     setState(() {
//       isMuted = !isMuted;
//     });
//   }
//
//   // Toggle speaker status
//   void _toggleSpeaker() {
//     setState(() {
//       isSpeakerOn = !isSpeakerOn;
//     });
//   }
//
//   // Build UI for the Audio Call page
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xff101828),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
//           child: Column(
//             children: [
//               Row(
//                 children: [
//                   IconButton(
//                     onPressed: () => Navigator.pop(context),
//                     icon: const Icon(
//                       Icons.keyboard_arrow_down,
//                       color: Colors.white,
//                       size: 34,
//                     ),
//                   ),
//                   const Spacer(),
//                   const Text(
//                     "Audio Call",
//                     style: TextStyle(
//                       color: Colors.white70,
//                       fontSize: 16,
//                     ),
//                   ),
//                   const Spacer(),
//                   const SizedBox(width: 48),
//                 ],
//               ),
//
//               const Spacer(),
//
//               Container(
//                 height: 135,
//                 width: 135,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   gradient: const LinearGradient(
//                     colors: [
//                       Color(0xff667085),
//                       Color(0xff344054),
//                     ],
//                   ),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.blue.withOpacity(0.25),
//                       blurRadius: 35,
//                       spreadRadius: 8,
//                     ),
//                   ],
//                 ),
//                 child: const Icon(
//                   Icons.person,
//                   color: Colors.white,
//                   size: 78,
//                 ),
//               ),
//
//               const SizedBox(height: 28),
//
//               Text(
//                 widget.callerName,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 27,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//
//               const SizedBox(height: 10),
//
//               Text(
//                 isLoading
//                     ? "Connecting..."
//                     : isCallActive
//                     ? _formatDuration(callSeconds)
//                     : widget.isIncomingCall!
//                     ? "Incoming audio call..."
//                     : "Ready to call",
//                 style: const TextStyle(
//                   color: Colors.white60,
//                   fontSize: 16,
//                 ),
//               ),
//
//               if (error != null) ...[
//                 const SizedBox(height: 18),
//                 Text(
//                   error!,
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(
//                     color: Colors.redAccent,
//                     fontSize: 14,
//                   ),
//                 ),
//               ],
//
//               const Spacer(),
//
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   _CallControlButton(
//                     icon: isMuted ? Icons.mic_off : Icons.mic,
//                     label: isMuted ? "Muted" : "Mute",
//                     onTap: _toggleMute,
//                   ),
//                   _CallControlButton(
//                     icon: isSpeakerOn ? Icons.volume_up : Icons.volume_off,
//                     label: "Speaker",
//                     onTap: _toggleSpeaker,
//                   ),
//                 ],
//               ),
//
//               const SizedBox(height: 42),
//
//               if (widget.isIncomingCall == true && !isCallActive) ...[
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     GestureDetector(
//                       onTap: isLoading ? null : () => Navigator.pop(context),
//                       child: Container(
//                         height: 76,
//                         width: 76,
//                         decoration: const BoxDecoration(
//                           shape: BoxShape.circle,
//                           color: Color(0xfff04438),
//                         ),
//                         child: const Icon(
//                           Icons.call_end,
//                           color: Colors.white,
//                           size: 36,
//                         ),
//                       ),
//                     ),
//
//                     GestureDetector(
//                       onTap: isLoading ? null : _receiveCall,
//                       child: Container(
//                         height: 76,
//                         width: 76,
//                         decoration: const BoxDecoration(
//                           shape: BoxShape.circle,
//                           color: Color(0xff12b76a),
//                         ),
//                         child: isLoading
//                             ? const Padding(
//                           padding: EdgeInsets.all(22),
//                           child: CircularProgressIndicator(
//                             strokeWidth: 3,
//                             color: Colors.white,
//                           ),
//                         )
//                             : const Icon(
//                           Icons.call,
//                           color: Colors.white,
//                           size: 36,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ] else ...[
//                 GestureDetector(
//                   onTap: isLoading
//                       ? null
//                       : isCallActive
//                       ? _endCall
//                       : _startCall,
//                   child: Container(
//                     height: 76,
//                     width: 76,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: isCallActive
//                           ? const Color(0xfff04438)
//                           : const Color(0xff12b76a),
//                     ),
//                     child: isLoading
//                         ? const Padding(
//                       padding: EdgeInsets.all(22),
//                       child: CircularProgressIndicator(
//                         strokeWidth: 3,
//                         color: Colors.white,
//                       ),
//                     )
//                         : Icon(
//                       isCallActive ? Icons.call_end : Icons.call,
//                       color: Colors.white,
//                       size: 36,
//                     ),
//                   ),
//                 ),
//               ],
//               const SizedBox(height: 32),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
// class _CallControlButton extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final VoidCallback onTap;
//
//   const _CallControlButton({
//     required this.icon,
//     required this.label,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         GestureDetector(
//           onTap: onTap,
//           child: Container(
//             height: 62,
//             width: 62,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: Colors.white.withOpacity(0.12),
//             ),
//             child: Icon(
//               icon,
//               color: Colors.white,
//               size: 28,
//             ),
//           ),
//         ),
//         const SizedBox(height: 9),
//         Text(
//           label,
//           style: const TextStyle(
//             color: Colors.white70,
//             fontSize: 13,
//           ),
//         ),
//       ],
//     );
//   }
//
//
// }

// class AudioCallPage extends StatefulWidget {
//   final String cookie;
//   final int channelId;
//   final int partnerId;
//   final int memberId;
//   final String callerName;
//   final bool? isIncomingCall;
//
//   const AudioCallPage({
//     super.key,
//     required this.cookie,
//     required this.channelId,
//     required this.partnerId,
//     required this.memberId,
//     this.callerName = "Unknown User",
//     this.isIncomingCall = false,
//   });
//
//   @override
//   State<AudioCallPage> createState() => _AudioCallPageState();
// }
//
// class _AudioCallPageState extends State<AudioCallPage> {
//   bool isCallActive = false;
//   bool isLoading = false;
//   bool isMuted = false;
//   bool isSpeakerOn = true;
//   String? error;
//
//   final AudioCallService audioCallService = AudioCallService();
//   late final RtcSignalingService signalingService;
//
//   int? lastSignalMessageId;
//   String? _rtcSessionId;
//   final Set<int> _processedSignalMessageIds = {};
//   final List<RTCIceCandidate> _pendingLocalIceCandidates = [];
//   bool _isRtcSignalPollInProgress = false;
//   bool _canSendLocalIce = false;
//   Timer? _timer;
//   int callSeconds = 0;
//   Timer? rtcSignalTimer;
//   Timer? rtcStatsTimer;
//
//   void startSignalPolling({
//     required String cookie,
//     required int channelId,
//     required int myPartnerId,
//   }) {
//     rtcSignalTimer?.cancel();
//
//     rtcSignalTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
//       if (_isRtcSignalPollInProgress) return;
//       _isRtcSignalPollInProgress = true;
//
//       try {
//         final currentSessionId = _rtcSessionId;
//
//         if (currentSessionId == null || currentSessionId.isEmpty) {
//           print("RTC POLLING SKIPPED: session id missing");
//           return;
//         }
//
//         final signals = await signalingService.fetchSignals(
//           cookie: cookie,
//           channelId: channelId,
//           myPartnerId: myPartnerId,
//           lastMessageId: lastSignalMessageId,
//           currentSessionId: currentSessionId,
//         );
//
//         for (final signal in signals) {
//           print(
//             "RTC SIGNAL RECEIVED: type=${signal['type']}, "
//             "from=${signal['from_partner_id']}, expected=${widget.partnerId}, "
//             "message=${signal['message_id']}",
//           );
//
//           final messageId = signal['message_id'];
//           if (messageId is int &&
//               _processedSignalMessageIds.contains(messageId)) {
//             continue;
//           }
//
//           if (signal['from_partner_id'] != widget.partnerId) {
//             print(
//               "RTC SIGNAL IGNORED: from=${signal['from_partner_id']} "
//               "does not match expected=${widget.partnerId}",
//             );
//             continue;
//           }
//
//           if (!_isCurrentRtcSession(signal)) {
//             print(
//               "RTC SIGNAL IGNORED: session=${signal['session_id']} "
//               "current=$_rtcSessionId",
//             );
//             continue;
//           }
//
//           if (messageId is int) {
//             lastSignalMessageId = messageId;
//             _processedSignalMessageIds.add(messageId);
//           }
//
//           if (signal['type'] == 'answer') {
//             print("RTC ANSWER RECEIVED");
//             await audioCallService.setRemoteAnswer(signal['data']['sdp']);
//           }
//
//           if (signal['type'] == 'ice') {
//             print("RTC ICE RECEIVED");
//             await _applyIceSignal(signal);
//           }
//         }
//       } catch (e) {
//         print("RTC signal polling error: $e");
//       } finally {
//         _isRtcSignalPollInProgress = false;
//       }
//     });
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     signalingService = RtcSignalingService(
//      // callKw: OdooDiscussService(baseUrl: 'https://demo.kendroo.com').callKw,
//       callKw: OdooDiscussService(baseUrl: 'http://192.168.250.26:8069').callKw,
//     );
//     _requestPermissions();
//   }
//
//   @override
//   void dispose() {
//     _timer?.cancel();
//     rtcSignalTimer?.cancel();
//     rtcStatsTimer?.cancel();
//     audioCallService.endCall();
//     super.dispose();
//   }
//
//   Future<void> _requestPermissions() async {
//     final microphoneStatus = await Permission.microphone.request();
//     if (!microphoneStatus.isGranted && mounted) {
//       setState(() {
//         error = "Microphone permission denied";
//       });
//     }
//   }
//
//   void _startTimer() {
//     _timer?.cancel();
//     callSeconds = 0;
//
//     _timer = Timer.periodic(const Duration(seconds: 1), (_) {
//       if (!mounted) return;
//       setState(() {
//         callSeconds++;
//       });
//     });
//   }
//
//   void _startRtcStatsLogging() {
//     rtcStatsTimer?.cancel();
//
//     rtcStatsTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
//       try {
//         final stats = await audioCallService.getStats();
//
//         for (final report in stats) {
//           final values = report.values;
//           final type = report.type.toLowerCase();
//           final kind = "${values['kind'] ?? values['mediaType'] ?? ''}"
//               .toLowerCase();
//           final mimeType = "${values['mimeType'] ?? ''}".toLowerCase();
//
//           final isAudio = kind == 'audio' || mimeType.contains('audio');
//           final isRtp = type == 'inbound-rtp' || type == 'outbound-rtp';
//           final hasAudioCounters =
//               values.containsKey('audioLevel') ||
//               values.containsKey('totalAudioEnergy') ||
//               values.containsKey('concealedSamples');
//           final isCandidatePair =
//               type == 'candidate-pair' &&
//               (values['selected'] == true ||
//                   values['nominated'] == true ||
//                   values['state'] == 'succeeded');
//           final isTransport = type == 'transport';
//
//           if (isCandidatePair) {
//             print(
//               "RTC ICE PAIR STATS: state=${values['state']}, "
//               "selected=${values['selected']}, nominated=${values['nominated']}, "
//               "writable=${values['writable']}, "
//               "bytesSent=${values['bytesSent']}, "
//               "bytesReceived=${values['bytesReceived']}, "
//               "requestsSent=${values['requestsSent']}, "
//               "responsesReceived=${values['responsesReceived']}, "
//               "localCandidateId=${values['localCandidateId']}, "
//               "remoteCandidateId=${values['remoteCandidateId']}",
//             );
//             continue;
//           }
//
//           if (type == 'local-candidate' || type == 'remote-candidate') {
//             print(
//               "RTC CANDIDATE STATS: type=${report.type}, "
//               "id=${report.id}, candidateType=${values['candidateType']}, "
//               "protocol=${values['protocol']}, "
//               "address=${values['address'] ?? values['ip']}, "
//               "port=${values['port']}, "
//               "networkType=${values['networkType']}, "
//               "relayProtocol=${values['relayProtocol']}",
//             );
//             continue;
//           }
//
//           if (isTransport) {
//             print(
//               "RTC TRANSPORT STATS: dtlsState=${values['dtlsState']}, "
//               "iceState=${values['iceState']}, "
//               "selectedCandidatePairId=${values['selectedCandidatePairId']}",
//             );
//             continue;
//           }
//
//           if (!isRtp || (!isAudio && !hasAudioCounters)) continue;
//
//           print(
//             "RTC AUDIO STATS: type=${report.type}, "
//             "bytesSent=${values['bytesSent']}, "
//             "bytesReceived=${values['bytesReceived']}, "
//             "packetsSent=${values['packetsSent']}, "
//             "packetsReceived=${values['packetsReceived']}, "
//             "packetsLost=${values['packetsLost']}, "
//             "jitter=${values['jitter']}, "
//             "audioLevel=${values['audioLevel']}, "
//             "totalAudioEnergy=${values['totalAudioEnergy']}",
//           );
//         }
//       } catch (e) {
//         print("RTC stats logging error: $e");
//       }
//     });
//   }
//
//   String _formatDuration(int seconds) {
//     final minutes = seconds ~/ 60;
//     final sec = seconds % 60;
//     return "${minutes.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}";
//   }
//
//   String _createRtcSessionId(int partnerId) {
//     return "${widget.channelId}-$partnerId-${DateTime.now().microsecondsSinceEpoch}";
//   }
//
//   bool _isCurrentRtcSession(Map<String, dynamic> signal) {
//     final currentSessionId = _rtcSessionId;
//     if (currentSessionId == null) return true;
//     return signal['session_id']?.toString() == currentSessionId;
//   }
//
//   String? _extractIceUfrag(String? sdp) {
//     if (sdp == null || sdp.isEmpty) return null;
//     return RegExp(
//       r'^a=ice-ufrag:(.+)$',
//       multiLine: true,
//     ).firstMatch(sdp)?.group(1)?.trim();
//   }
//
//   bool _candidateMatchesUfrag(Map<String, dynamic> signal, String? ufrag) {
//     if (ufrag == null || ufrag.isEmpty) return true;
//
//     final data = signal['data'];
//     if (data is! Map) return false;
//
//     final candidate = data['candidate']?.toString() ?? '';
//     return RegExp(
//       '(?:^| )ufrag ${RegExp.escape(ufrag)}(?:\$| )',
//     ).hasMatch(candidate);
//   }
//
//   Future<void> _applyIceSignal(Map<String, dynamic> signal) async {
//     final data = signal['data'];
//     if (data is! Map) return;
//
//     final candidate = data['candidate'];
//     final sdpMid = data['sdpMid'];
//     final sdpMLineIndex = data['sdpMLineIndex'];
//
//     if (candidate is! String || sdpMid is! String || sdpMLineIndex is! int) {
//       print("RTC ICE IGNORED: invalid data=$data");
//       return;
//     }
//
//     await audioCallService.addRemoteIceCandidate(
//       candidate: candidate,
//       sdpMid: sdpMid,
//       sdpMLineIndex: sdpMLineIndex,
//     );
//   }
//
//   Future<void> _handleLocalIceCandidate({
//     required RTCIceCandidate candidate,
//     required int fromPartnerId,
//   }) async {
//     if (!_canSendLocalIce) {
//       _pendingLocalIceCandidates.add(candidate);
//       print("QUEUING LOCAL ICE UNTIL SDP SIGNAL IS SENT");
//       return;
//     }
//
//     await _sendLocalIceCandidate(
//       candidate: candidate,
//       fromPartnerId: fromPartnerId,
//     );
//   }
//
//   Future<void> _sendLocalIceCandidate({
//     required RTCIceCandidate candidate,
//     required int fromPartnerId,
//   }) async {
//     await signalingService.sendSignal(
//       cookie: widget.cookie,
//       channelId: widget.channelId,
//       fromPartnerId: fromPartnerId,
//       type: 'ice',
//       sessionId: _rtcSessionId,
//       data: {
//         'candidate': candidate.candidate,
//         'sdpMid': candidate.sdpMid,
//         'sdpMLineIndex': candidate.sdpMLineIndex,
//       },
//     );
//   }
//
//   Future<void> _flushLocalIceCandidates(int fromPartnerId) async {
//     _canSendLocalIce = true;
//
//     if (_pendingLocalIceCandidates.isNotEmpty) {
//       print("FLUSHING LOCAL ICE: ${_pendingLocalIceCandidates.length}");
//     }
//
//     final candidates = List<RTCIceCandidate>.from(_pendingLocalIceCandidates);
//     _pendingLocalIceCandidates.clear();
//
//     for (final candidate in candidates) {
//       await _sendLocalIceCandidate(
//         candidate: candidate,
//         fromPartnerId: fromPartnerId,
//       );
//     }
//   }
//   Future _startCall() async {setState(() {isLoading = true;});
//
//   final callProvider = context.read<CallProvider>();
//   final authProvider = context.read<AuthProvider>();
//
//   try {
//     _canSendLocalIce = false;
//     _pendingLocalIceCandidates.clear();
//     _rtcSessionId = _createRtcSessionId(authProvider.partnerId!);
//
//     await callProvider.startAudioCall(
//       cookie: widget.cookie,
//       channelId: widget.channelId,
//       partnerId: authProvider.partnerId!,
//       memberId: widget.memberId,
//     );
//
//     await audioCallService.initializeWebRTC();
//
//     audioCallService.onRemoteStream = (stream) async {
//       print("REMOTE STREAM RECEIVED: ${stream.id}");
//       for (final track in stream.getAudioTracks()) {
//         track.enabled = true;
//         print("REMOTE AUDIO TRACK: ${track.id}");
//       }
//
//       await Helper.setSpeakerphoneOn(true);
//     };
//
//     audioCallService.onIceCandidate = (candidate) async {
//       await _handleLocalIceCandidate(
//         candidate: candidate,
//         fromPartnerId: authProvider.partnerId!,
//       );
//     };
//
//     final offer = await audioCallService.createOffer();
//
//     await signalingService.sendSignal(
//       cookie: widget.cookie,
//       channelId: widget.channelId,
//       fromPartnerId: authProvider.partnerId!,
//       type: 'offer',
//       sessionId: _rtcSessionId,
//       data: {'sdp': offer.sdp},
//     );
//
//     await _flushLocalIceCandidates(authProvider.partnerId!);
//
//     startSignalPolling(
//       cookie: widget.cookie,
//       channelId: widget.channelId,
//       myPartnerId: authProvider.partnerId!,
//     );
//
//     setState(() {
//       isCallActive = true;
//       isLoading = false;
//     });
//     _startTimer();
//     _startRtcStatsLogging();
//   } catch (e) {
//     setState(() {
//       error = "Failed to start call: $e";
//       isLoading = false;
//     });
//   }
//
//   }
//   // Future<void> _startCall() async {
//   //   setState(() {
//   //     isLoading = true;
//   //   });
//   //
//   //   final callProvider = context.read<CallProvider>();
//   //   final authProvider = context.read<AuthProvider>();
//   //
//   //   try {
//   //     _canSendLocalIce = false;
//   //     _pendingLocalIceCandidates.clear();
//   //     _rtcSessionId = _createRtcSessionId(authProvider.partnerId!);
//   //
//   //     await callProvider.startAudioCall(
//   //       cookie: widget.cookie,
//   //       channelId: widget.channelId,
//   //       partnerId: authProvider.partnerId!,
//   //       memberId: widget.memberId,
//   //     );
//   //
//   //     await audioCallService.initializeWebRTC();
//   //
//   //     audioCallService.onRemoteStream = (stream) async {
//   //       print("REMOTE STREAM RECEIVED: ${stream.id}");
//   //       for (final track in stream.getAudioTracks()) {
//   //         track.enabled = true;
//   //         print("REMOTE AUDIO TRACK: ${track.id}");
//   //       }
//   //
//   //       await Helper.setSpeakerphoneOn(true);
//   //     };
//   //
//   //     audioCallService.onIceCandidate = (candidate) async {
//   //       await _handleLocalIceCandidate(
//   //         candidate: candidate,
//   //         fromPartnerId: authProvider.partnerId!,
//   //       );
//   //     };
//   //
//   //     final offer = await audioCallService.createOffer();
//   //
//   //     await signalingService.sendSignal(
//   //       cookie: widget.cookie,
//   //       channelId: widget.channelId,
//   //       fromPartnerId: authProvider.partnerId!,
//   //       type: 'offer',
//   //       sessionId: _rtcSessionId,
//   //       data: {'sdp': offer.sdp},
//   //     );
//   //
//   //     await _flushLocalIceCandidates(authProvider.partnerId!);
//   //
//   //     startSignalPolling(
//   //       cookie: widget.cookie,
//   //       channelId: widget.channelId,
//   //       myPartnerId: authProvider.partnerId!,
//   //     );
//   //
//   //     setState(() {
//   //       isCallActive = true;
//   //       isLoading = false;
//   //     });
//   //     _startTimer();
//   //     _startRtcStatsLogging();
//   //   } catch (e) {
//   //     setState(() {
//   //       error = "Failed to start call: $e";
//   //       isLoading = false;
//   //     });
//   //   }
//   // }
//
//   // Future<void> _receiveCall() async {
//   //   setState(() {
//   //     isLoading = true;
//   //     error = null;
//   //   });
//   //
//   //   final callProvider = context.read<CallProvider>();
//   //   final authProv = context.read<AuthProvider>();
//   //
//   //   try {
//   //     // 1. Notify Backend that we are picking up the line
//   //     await callProvider.receiveAudioCall(
//   //       cookie: widget.cookie,
//   //       channelId: widget.channelId,
//   //       partnerId: widget.partnerId,
//   //       memberId: widget.memberId,
//   //     );
//   //
//   //     await audioCallService.initializeWebRTC();
//   //
//   //     // 2. Register candidate generation hook using our Partner ID
//   //     audioCallService.onIceCandidate = (candidate) async {
//   //       await signalingService.sendSignal(
//   //         cookie: widget.cookie,
//   //         channelId: widget.channelId,
//   //         fromPartnerId: authProv.partnerId!,
//   //         type: 'ice',
//   //         data: {
//   //           'candidate': candidate.candidate,
//   //           'sdpMid': candidate.sdpMid,
//   //           'sdpMLineIndex': candidate.sdpMLineIndex,
//   //         },
//   //       );
//   //     };
//   //
//   //     Map<String, dynamic>? offerSignal;
//   //
//   //     // 3. Poll for the remote side's inbound offer signal descriptor
//   //     for (int i = 0; i < 10; i++) {
//   //       final signals = await signalingService.fetchSignals(
//   //         cookie: widget.cookie,
//   //         channelId: widget.channelId,
//   //         myPartnerId: authProv.partnerId!, // Correctly skips OUR signals, retains incoming ones
//   //       );
//   //
//   //       print("FETCHED SIGNALS ON RECEIVE: $signals");
//   //
//   //       final offers = signals.where((s) => s['type'] == 'offer').toList();
//   //       if (offers.isNotEmpty) {
//   //         offerSignal = Map<String, dynamic>.from(offers.last);
//   //         break;
//   //       }
//   //       await Future.delayed(const Duration(seconds: 1));
//   //     }
//   //
//   //     if (offerSignal == null) {
//   //       throw Exception("No remote session offer signal found on channel.");
//   //     }
//   //
//   //     // 4. Accept external offer and create a handshake answer response string
//   //     await audioCallService.setRemoteOffer(offerSignal['data']['sdp']);
//   //     final answer = await audioCallService.createAnswer();
//   //
//   //     // 5. Send back the answer string
//   //     await signalingService.sendSignal(
//   //       cookie: widget.cookie,
//   //       channelId: widget.channelId,
//   //       fromPartnerId: authProv.partnerId!,
//   //       type: 'answer',
//   //       data: {
//   //         'sdp': answer.sdp,
//   //         'type': answer.type,
//   //       },
//   //     );
//   //
//   //     // 6. Start listening for incoming remote ICE candidates to finalize connection setup
//   //     startSignalPolling(
//   //       cookie: widget.cookie,
//   //       channelId: widget.channelId,
//   //       myPartnerId: authProv.partnerId!,
//   //     );
//   //
//   //     if (!mounted) return;
//   //
//   //     setState(() {
//   //       isCallActive = true;
//   //       isLoading = false;
//   //     });
//   //
//   //     _startTimer();
//   //   } catch (e) {
//   //     if (!mounted) return;
//   //     setState(() {
//   //       error = "Failed to receive call: $e";
//   //       isLoading = false;
//   //     });
//   //   }
//   // }
//
//   // Future<void> _receiveCall() async {
//   //   setState(() {
//   //     isLoading = true;
//   //     error = null;
//   //   });
//   //
//   //   final callProvider = context.read<CallProvider>();
//   //   final authProv = context.read<AuthProvider>();
//   //
//   //   try {
//   //     _canSendLocalIce = false;
//   //     _pendingLocalIceCandidates.clear();
//   //     final myPartnerId = authProv.partnerId;
//   //
//   //     if (myPartnerId == null) {
//   //       throw Exception("Authentication state is missing a valid partner ID.");
//   //     }
//   //
//   //     await callProvider.receiveAudioCall(
//   //       cookie: widget.cookie,
//   //       channelId: widget.channelId,
//   //       partnerId: myPartnerId,
//   //     );
//   //
//   //     await audioCallService.initializeWebRTC();
//   //     audioCallService.onRemoteStream = (stream) async {
//   //       print("REMOTE STREAM RECEIVED: ${stream.id}");
//   //       for (final track in stream.getAudioTracks()) {
//   //         track.enabled = true;
//   //         print("REMOTE AUDIO TRACK: ${track.id}");
//   //       }
//   //
//   //       await Helper.setSpeakerphoneOn(true);
//   //     };
//   //
//   //     audioCallService.onIceCandidate = (candidate) async {
//   //       await _handleLocalIceCandidate(
//   //         candidate: candidate,
//   //         fromPartnerId: myPartnerId,
//   //       );
//   //     };
//   //
//   //     Map<String, dynamic>? offerSignal;
//   //     List<Map<String, dynamic>> receiveSignals = [];
//   //
//   //     for (int i = 0; i < 10; i++) {
//   //       final signals = await signalingService.fetchSignals(
//   //         cookie: widget.cookie,
//   //         channelId: widget.channelId,
//   //         myPartnerId: myPartnerId,
//   //       );
//   //
//   //       print("FETCHED SIGNALS ON RECEIVE: $signals");
//   //
//   //       // final offers = signals
//   //       //     .where((signal) => signal['type'] == 'offer')
//   //       //     .toList();
//   //       // final matchingOffers = offers
//   //       //     .where((signal) => signal['from_partner_id'] == widget.partnerId)
//   //       //     .toList();
//   //       // final candidateOffers = matchingOffers.isNotEmpty
//   //       //     ? matchingOffers
//   //       //     : offers;
//   //       // if (candidateOffers.isNotEmpty) {
//   //       //   offerSignal = Map<String, dynamic>.from(candidateOffers.last);
//   //       //   receiveSignals = signals;
//   //       //   break;
//   //       // }
//   //
//   //       final candidateOffers = signals
//   //           .where(
//   //             (signal) =>
//   //                 signal['type'] == 'offer' &&
//   //                 signal['from_partner_id'] == widget.partnerId,
//   //           )
//   //           .toList();
//   //
//   //       candidateOffers.sort((a, b) {
//   //         final aId = a['message_id'] as int? ?? 0;
//   //         final bId = b['message_id'] as int? ?? 0;
//   //         return bId.compareTo(aId); // newest first
//   //       });
//   //
//   //       if (candidateOffers.isNotEmpty) {
//   //         offerSignal = Map<String, dynamic>.from(candidateOffers.first);
//   //         receiveSignals = signals;
//   //         break;
//   //       }
//   //       await Future.delayed(const Duration(seconds: 1));
//   //     }
//   //
//   //     if (offerSignal == null) {
//   //       throw Exception("No remote session offer signal found on channel.");
//   //     }
//   //
//   //     _rtcSessionId = offerSignal['session_id']?.toString();
//   //
//   //     if (_rtcSessionId == null || _rtcSessionId!.isEmpty) {
//   //       _rtcSessionId = "legacy-${offerSignal['message_id']}";
//   //     }
//   //
//   //     receiveSignals = receiveSignals
//   //         .where((signal) =>
//   //             signal['session_id']?.toString() == _rtcSessionId &&
//   //             signal['from_partner_id'] == widget.partnerId)
//   //         .toList();
//   //     print("RTC SESSION ACCEPTED: $_rtcSessionId");
//   //
//   //     // 5. Handshake processing
//   //     final acceptedOffer = await audioCallService.setRemoteOffer(
//   //       offerSignal['data']['sdp'],
//   //     );
//   //     if (!acceptedOffer) {
//   //       throw Exception(
//   //         "Remote offer could not be applied in the current call state.",
//   //       );
//   //     }
//   //
//   //     final answer = await audioCallService.createAnswer();
//   //
//   //     // 6. Send your handshake reply back down the signaling pipe before ICE.
//   //     await signalingService.sendSignal(
//   //       cookie: widget.cookie,
//   //       channelId: widget.channelId,
//   //       fromPartnerId: myPartnerId, // Signed by you
//   //       type: 'answer',
//   //       sessionId: _rtcSessionId,
//   //       data: {'sdp': answer.sdp, 'type': answer.type},
//   //     );
//   //
//   //     await _flushLocalIceCandidates(myPartnerId);
//   //
//   //     final offerSdp = offerSignal['data']['sdp']?.toString();
//   //     final offerUfrag = _extractIceUfrag(offerSdp);
//   //     final currentOfferIceSignals = receiveSignals.where((signal) {
//   //       return signal['type'] == 'ice' &&
//   //           signal['from_partner_id'] == widget.partnerId &&
//   //           _isCurrentRtcSession(signal) &&
//   //           _candidateMatchesUfrag(signal, offerUfrag);
//   //     }).toList();
//   //
//   //     print(
//   //       "APPLYING RECEIVE-BATCH ICE: count=${currentOfferIceSignals.length}, "
//   //       "ufrag=$offerUfrag",
//   //     );
//   //
//   //     for (final signal in currentOfferIceSignals) {
//   //       final messageId = signal['message_id'];
//   //       if (messageId is int) {
//   //         _processedSignalMessageIds.add(messageId);
//   //       }
//   //       await _applyIceSignal(signal);
//   //     }
//   //
//   //     final offerMessageId = offerSignal['message_id'];
//   //     if (offerMessageId is int) {
//   //       _processedSignalMessageIds.add(offerMessageId);
//   //     }
//   //
//   //     final receivedMessageIds = receiveSignals
//   //         .map((signal) => signal['message_id'])
//   //         .whereType<int>();
//   //     if (receivedMessageIds.isNotEmpty) {
//   //       lastSignalMessageId = receivedMessageIds.reduce(
//   //         (currentMax, messageId) =>
//   //             messageId > currentMax ? messageId : currentMax,
//   //       );
//   //     } else if (offerMessageId is int) {
//   //       lastSignalMessageId = offerMessageId;
//   //     }
//   //
//   //     // 7. Start polling loop for remote ICE steps
//   //     startSignalPolling(
//   //       cookie: widget.cookie,
//   //       channelId: widget.channelId,
//   //       myPartnerId: myPartnerId,
//   //     );
//   //
//   //     if (!mounted) return;
//   //
//   //     setState(() {
//   //       isCallActive = true;
//   //       isLoading = false;
//   //     });
//   //
//   //     _startTimer();
//   //     _startRtcStatsLogging();
//   //   } catch (e) {
//   //     print("Error receiving RTC call: $e");
//   //     if (!mounted) return;
//   //     setState(() {
//   //       error =
//   //           "Failed to receive call: ${e.toString().replaceAll('Exception: ', '')}";
//   //       isLoading = false;
//   //     });
//   //   }
//   // }
//   Future _receiveCall() async {setState(() {isLoading = true;error = null;});
//
//   final callProvider = context.read<CallProvider>();
//   final authProv = context.read<AuthProvider>();
//
//   try {
//     _canSendLocalIce = false;
//     _pendingLocalIceCandidates.clear();
//     final myPartnerId = authProv.partnerId;
//
//     if (myPartnerId == null) {
//       throw Exception("Authentication state is missing a valid partner ID.");
//     }
//
//     await callProvider.receiveAudioCall(
//       cookie: widget.cookie,
//       channelId: widget.channelId,
//       partnerId: myPartnerId,
//     );
//
//     await audioCallService.initializeWebRTC();
//     audioCallService.onRemoteStream = (stream) async {
//       print("REMOTE STREAM RECEIVED: ${stream.id}");
//       for (final track in stream.getAudioTracks()) {
//         track.enabled = true;
//         print("REMOTE AUDIO TRACK: ${track.id}");
//       }
//
//       await Helper.setSpeakerphoneOn(true);
//     };
//
//     audioCallService.onIceCandidate = (candidate) async {
//       await _handleLocalIceCandidate(
//         candidate: candidate,
//         fromPartnerId: myPartnerId,
//       );
//     };
//
//     Map<String, dynamic>? offerSignal;
//     List<Map<String, dynamic>> receiveSignals = [];
//
//     for (int i = 0; i < 10; i++) {
//       final signals = await signalingService.fetchSignals(
//         cookie: widget.cookie,
//         channelId: widget.channelId,
//         myPartnerId: myPartnerId,
//       );
//
//       print("FETCHED SIGNALS ON RECEIVE: $signals");
//
//       // final offers = signals
//       //     .where((signal) => signal['type'] == 'offer')
//       //     .toList();
//       // final matchingOffers = offers
//       //     .where((signal) => signal['from_partner_id'] == widget.partnerId)
//       //     .toList();
//       // final candidateOffers = matchingOffers.isNotEmpty
//       //     ? matchingOffers
//       //     : offers;
//       // if (candidateOffers.isNotEmpty) {
//       //   offerSignal = Map<String, dynamic>.from(candidateOffers.last);
//       //   receiveSignals = signals;
//       //   break;
//       // }
//
//       final candidateOffers = signals
//           .where(
//             (signal) =>
//         signal['type'] == 'offer' &&
//             signal['from_partner_id'] == widget.partnerId,
//       )
//           .toList();
//
//       candidateOffers.sort((a, b) {
//         final aId = a['message_id'] as int? ?? 0;
//         final bId = b['message_id'] as int? ?? 0;
//         return bId.compareTo(aId); // newest first
//       });
//
//       if (candidateOffers.isNotEmpty) {
//         offerSignal = Map<String, dynamic>.from(candidateOffers.first);
//         receiveSignals = signals;
//         break;
//       }
//       await Future.delayed(const Duration(seconds: 1));
//     }
//
//     if (offerSignal == null) {
//       throw Exception("No remote session offer signal found on channel.");
//     }
//
//     _rtcSessionId = offerSignal['session_id']?.toString();
//
//     if (_rtcSessionId == null || _rtcSessionId!.isEmpty) {
//       _rtcSessionId = "legacy-${offerSignal['message_id']}";
//     }
//
//     receiveSignals = receiveSignals
//         .where((signal) =>
//     signal['session_id']?.toString() == _rtcSessionId &&
//         signal['from_partner_id'] == widget.partnerId)
//         .toList();
//     print("RTC SESSION ACCEPTED: $_rtcSessionId");
//
//     // 5. Handshake processing
//     final acceptedOffer = await audioCallService.setRemoteOffer(
//       offerSignal['data']['sdp'],
//     );
//     if (!acceptedOffer) {
//       throw Exception(
//         "Remote offer could not be applied in the current call state.",
//       );
//     }
//
//     final answer = await audioCallService.createAnswer();
//
//     // 6. Send your handshake reply back down the signaling pipe before ICE.
//     await signalingService.sendSignal(
//       cookie: widget.cookie,
//       channelId: widget.channelId,
//       fromPartnerId: myPartnerId, // Signed by you
//       type: 'answer',
//       sessionId: _rtcSessionId,
//       data: {'sdp': answer.sdp, 'type': answer.type},
//     );
//
//     await _flushLocalIceCandidates(myPartnerId);
//
//     final offerSdp = offerSignal['data']['sdp']?.toString();
//     final offerUfrag = _extractIceUfrag(offerSdp);
//     final currentOfferIceSignals = receiveSignals.where((signal) {
//       return signal['type'] == 'ice' &&
//           signal['from_partner_id'] == widget.partnerId &&
//           _isCurrentRtcSession(signal) &&
//           _candidateMatchesUfrag(signal, offerUfrag);
//     }).toList();
//
//     print(
//       "APPLYING RECEIVE-BATCH ICE: count=${currentOfferIceSignals.length}, "
//           "ufrag=$offerUfrag",
//     );
//
//     for (final signal in currentOfferIceSignals) {
//       final messageId = signal['message_id'];
//       if (messageId is int) {
//         _processedSignalMessageIds.add(messageId);
//       }
//       await _applyIceSignal(signal);
//     }
//
//     final offerMessageId = offerSignal['message_id'];
//     if (offerMessageId is int) {
//       _processedSignalMessageIds.add(offerMessageId);
//     }
//
//     final receivedMessageIds = receiveSignals
//         .map((signal) => signal['message_id'])
//         .whereType<int>();
//     if (receivedMessageIds.isNotEmpty) {
//       lastSignalMessageId = receivedMessageIds.reduce(
//             (currentMax, messageId) =>
//         messageId > currentMax ? messageId : currentMax,
//       );
//     } else if (offerMessageId is int) {
//       lastSignalMessageId = offerMessageId;
//     }
//
//     // 7. Start polling loop for remote ICE steps
//     startSignalPolling(
//       cookie: widget.cookie,
//       channelId: widget.channelId,
//       myPartnerId: myPartnerId,
//     );
//
//     if (!mounted) return;
//
//     setState(() {
//       isCallActive = true;
//       isLoading = false;
//     });
//
//     _startTimer();
//     _startRtcStatsLogging();
//   } catch (e) {
//     print("Error receiving RTC call: $e");
//     if (!mounted) return;
//     setState(() {
//       error =
//       "Failed to receive call: ${e.toString().replaceAll('Exception: ', '')}";
//       isLoading = false;
//     });
//   }
//
//   }
//   // Future<void> _receiveCall() async {
//   //   setState(() {
//   //     isLoading = true;
//   //     error = null;
//   //   });
//   //
//   //   final callProvider = context.read<CallProvider>();
//   //   final authProv = context.read<AuthProvider>();
//   //
//   //   try {
//   //     final myPartnerId = authProv.partnerId;
//   //     if (myPartnerId == null) {
//   //       throw Exception("Authentication state is missing partner ID.");
//   //     }
//   //
//   //     lastSignalMessageId = null;
//   //     _processedSignalMessageIds.clear();
//   //     _pendingLocalIceCandidates.clear();
//   //     _canSendLocalIce = false;
//   //
//   //     await callProvider.receiveAudioCall(
//   //       cookie: widget.cookie,
//   //       channelId: widget.channelId,
//   //       partnerId: myPartnerId,
//   //     );
//   //
//   //     await audioCallService.initializeWebRTC();
//   //
//   //     audioCallService.onRemoteStream = (stream) async {
//   //       print("REMOTE STREAM RECEIVED: ${stream.id}");
//   //       for (final track in stream.getAudioTracks()) {
//   //         track.enabled = true;
//   //         print("REMOTE AUDIO TRACK: ${track.id}");
//   //       }
//   //       await Helper.setSpeakerphoneOn(true);
//   //     };
//   //
//   //     audioCallService.onIceCandidate = (candidate) async {
//   //       await _handleLocalIceCandidate(
//   //         candidate: candidate,
//   //         fromPartnerId: myPartnerId,
//   //       );
//   //     };
//   //
//   //     Map<String, dynamic>? offerSignal;
//   //     List<Map<String, dynamic>> initialSignals = [];
//   //
//   //     // Receiver does not know session_id yet, so fetch latest RTC messages only
//   //     for (int i = 0; i < 10; i++) {
//   //       final signals = await signalingService.fetchSignals(
//   //         cookie: widget.cookie,
//   //         channelId: widget.channelId,
//   //         myPartnerId: myPartnerId,
//   //         currentSessionId: null,
//   //         limit: 30,
//   //       );
//   //
//   //       final offers = signals
//   //           .where((s) =>
//   //       s['type'] == 'offer' &&
//   //           s['from_partner_id'] == widget.partnerId)
//   //           .toList();
//   //
//   //       offers.sort((a, b) {
//   //         final aId = a['message_id'] as int? ?? 0;
//   //         final bId = b['message_id'] as int? ?? 0;
//   //         return bId.compareTo(aId); // newest first
//   //       });
//   //
//   //       if (offers.isNotEmpty) {
//   //         offerSignal = Map<String, dynamic>.from(offers.first);
//   //         initialSignals = signals;
//   //         break;
//   //       }
//   //
//   //       await Future.delayed(const Duration(seconds: 1));
//   //     }
//   //
//   //     if (offerSignal == null) {
//   //       throw Exception("No remote session offer signal found on channel.");
//   //     }
//   //
//   //     _rtcSessionId = offerSignal['session_id']?.toString();
//   //
//   //     if (_rtcSessionId == null || _rtcSessionId!.isEmpty) {
//   //       _rtcSessionId = "legacy-${offerSignal['message_id']}";
//   //     }
//   //
//   //     print("RTC SESSION ACCEPTED: $_rtcSessionId");
//   //
//   //     final acceptedOffer = await audioCallService.setRemoteOffer(
//   //       offerSignal['data']['sdp'],
//   //     );
//   //
//   //     if (!acceptedOffer) {
//   //       throw Exception("Remote offer could not be applied.");
//   //     }
//   //
//   //     final answer = await audioCallService.createAnswer();
//   //
//   //     await signalingService.sendSignal(
//   //       cookie: widget.cookie,
//   //       channelId: widget.channelId,
//   //       fromPartnerId: myPartnerId,
//   //       type: 'answer',
//   //       sessionId: _rtcSessionId,
//   //       data: {
//   //         'sdp': answer.sdp,
//   //         'type': answer.type,
//   //       },
//   //     );
//   //
//   //     await _flushLocalIceCandidates(myPartnerId);
//   //
//   //     final offerSdp = offerSignal['data']['sdp']?.toString();
//   //     final offerUfrag = _extractIceUfrag(offerSdp);
//   //
//   //     final currentIceSignals = initialSignals.where((signal) {
//   //       return signal['type'] == 'ice' &&
//   //           signal['from_partner_id'] == widget.partnerId &&
//   //           signal['session_id']?.toString() == _rtcSessionId &&
//   //           _candidateMatchesUfrag(signal, offerUfrag);
//   //     }).toList();
//   //
//   //     print(
//   //       "APPLYING RECEIVE-BATCH ICE: count=${currentIceSignals.length}, "
//   //           "ufrag=$offerUfrag",
//   //     );
//   //
//   //     for (final signal in currentIceSignals) {
//   //       final messageId = signal['message_id'];
//   //       if (messageId is int) {
//   //         _processedSignalMessageIds.add(messageId);
//   //       }
//   //       await _applyIceSignal(signal);
//   //     }
//   //
//   //     final offerMessageId = offerSignal['message_id'];
//   //     if (offerMessageId is int) {
//   //       _processedSignalMessageIds.add(offerMessageId);
//   //     }
//   //
//   //     final currentSessionMessageIds = initialSignals
//   //         .where((s) => s['session_id']?.toString() == _rtcSessionId)
//   //         .map((s) => s['message_id'])
//   //         .whereType<int>();
//   //
//   //     if (currentSessionMessageIds.isNotEmpty) {
//   //       lastSignalMessageId = currentSessionMessageIds.reduce(
//   //             (a, b) => a > b ? a : b,
//   //       );
//   //     } else if (offerMessageId is int) {
//   //       lastSignalMessageId = offerMessageId;
//   //     }
//   //
//   //     startSignalPolling(
//   //       cookie: widget.cookie,
//   //       channelId: widget.channelId,
//   //       myPartnerId: myPartnerId,
//   //     );
//   //
//   //     if (!mounted) return;
//   //
//   //     setState(() {
//   //       isCallActive = true;
//   //       isLoading = false;
//   //     });
//   //
//   //     _startTimer();
//   //     _startRtcStatsLogging();
//   //   } catch (e) {
//   //     print("Error receiving RTC call: $e");
//   //     if (!mounted) return;
//   //     setState(() {
//   //       error = "Failed to receive call: ${e.toString().replaceAll('Exception: ', '')}";
//   //       isLoading = false;
//   //     });
//   //   }
//   // }
//
//   Future<void> _endCall() async {
//     setState(() {
//       isLoading = true;
//       error = null;
//     });
//
//     final callProvider = context.read<CallProvider>();
//
//     try {
//       await callProvider.endAudioCall(
//         cookie: widget.cookie,
//         channelId: widget.channelId,
//       );
//
//       _timer?.cancel();
//       rtcSignalTimer?.cancel();
//       rtcStatsTimer?.cancel();
//       await audioCallService.endCall();
//
//       if (!mounted) return;
//
//       setState(() {
//         isCallActive = false;
//         isLoading = false;
//         callSeconds = 0;
//       });
//
//       Navigator.pop(context);
//     } catch (e) {
//       if (!mounted) return;
//       setState(() {
//         error = "Failed to end call: $e";
//         isLoading = false;
//       });
//     }
//   }
//
//   void _toggleMute() {
//     setState(() {
//       isMuted = !isMuted;
//       audioCallService.toggleMute(isMuted);
//     });
//   }
//
//   void _toggleSpeaker() async {
//     setState(() {
//       isSpeakerOn = !isSpeakerOn;
//     });
//
//     await Helper.setSpeakerphoneOn(isSpeakerOn);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xff101828),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
//           child: Column(
//             children: [
//               Row(
//                 children: [
//                   IconButton(
//                     onPressed: () => Navigator.pop(context),
//                     icon: const Icon(
//                       Icons.keyboard_arrow_down,
//                       color: Colors.white,
//                       size: 34,
//                     ),
//                   ),
//                   const Spacer(),
//                   const Text(
//                     "Audio Call",
//                     style: TextStyle(color: Colors.white70, fontSize: 16),
//                   ),
//                   const Spacer(),
//                   const SizedBox(width: 48),
//                 ],
//               ),
//               const Spacer(),
//               Container(
//                 height: 135,
//                 width: 135,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   gradient: const LinearGradient(
//                     colors: [Color(0xff667085), Color(0xff344054)],
//                   ),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.blue.withOpacity(0.25),
//                       blurRadius: 35,
//                       spreadRadius: 8,
//                     ),
//                   ],
//                 ),
//                 child: const Icon(Icons.person, color: Colors.white, size: 78),
//               ),
//               const SizedBox(height: 28),
//               Text(
//                 widget.callerName,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 27,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//               const SizedBox(height: 10),
//               Text(
//                 isLoading
//                     ? "Connecting..."
//                     : isCallActive
//                     ? _formatDuration(callSeconds)
//                     : widget.isIncomingCall!
//                     ? "Incoming audio call..."
//                     : "Ready to call",
//                 style: const TextStyle(color: Colors.white60, fontSize: 16),
//               ),
//               if (error != null) ...[
//                 const SizedBox(height: 18),
//                 Text(
//                   error!,
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(color: Colors.redAccent, fontSize: 14),
//                 ),
//               ],
//               const Spacer(),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   _CallControlButton(
//                     icon: isMuted ? Icons.mic_off : Icons.mic,
//                     label: isMuted ? "Muted" : "Mute",
//                     onTap: _toggleMute,
//                   ),
//                   _CallControlButton(
//                     icon: isSpeakerOn ? Icons.volume_up : Icons.volume_off,
//                     label: "Speaker",
//                     onTap: _toggleSpeaker,
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 42),
//               if (widget.isIncomingCall == true && !isCallActive) ...[
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     GestureDetector(
//                       onTap: isLoading ? null : () => Navigator.pop(context),
//                       child: Container(
//                         height: 76,
//                         width: 76,
//                         decoration: const BoxDecoration(
//                           shape: BoxShape.circle,
//                           color: Color(0xfff04438),
//                         ),
//                         child: const Icon(
//                           Icons.call_end,
//                           color: Colors.white,
//                           size: 36,
//                         ),
//                       ),
//                     ),
//                     GestureDetector(
//                       onTap: isLoading ? null : _receiveCall,
//                       child: Container(
//                         height: 76,
//                         width: 76,
//                         decoration: const BoxDecoration(
//                           shape: BoxShape.circle,
//                           color: Color(0xff12b76a),
//                         ),
//                         child: isLoading
//                             ? const Padding(
//                                 padding: EdgeInsets.all(22),
//                                 child: CircularProgressIndicator(
//                                   strokeWidth: 3,
//                                   color: Colors.white,
//                                 ),
//                               )
//                             : const Icon(
//                                 Icons.call,
//                                 color: Colors.white,
//                                 size: 36,
//                               ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ] else ...[
//                 GestureDetector(
//                   onTap: isLoading
//                       ? null
//                       : isCallActive
//                       ? _endCall
//                       : _startCall,
//                   child: Container(
//                     height: 76,
//                     width: 76,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: isCallActive
//                           ? const Color(0xfff04438)
//                           : const Color(0xff12b76a),
//                     ),
//                     child: isLoading
//                         ? const Padding(
//                             padding: EdgeInsets.all(22),
//                             child: CircularProgressIndicator(
//                               strokeWidth: 3,
//                               color: Colors.white,
//                             ),
//                           )
//                         : Icon(
//                             isCallActive ? Icons.call_end : Icons.call,
//                             color: Colors.white,
//                             size: 36,
//                           ),
//                   ),
//                 ),
//               ],
//               const SizedBox(height: 32),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class _CallControlButton extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final VoidCallback onTap;
//
//   const _CallControlButton({
//     required this.icon,
//     required this.label,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         GestureDetector(
//           onTap: onTap,
//           child: Container(
//             height: 62,
//             width: 62,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: Colors.white.withOpacity(0.12),
//             ),
//             child: Icon(icon, color: Colors.white, size: 28),
//           ),
//         ),
//         const SizedBox(height: 9),
//         Text(
//           label,
//           style: const TextStyle(color: Colors.white70, fontSize: 13),
//         ),
//       ],
//     );
//   }
// }
