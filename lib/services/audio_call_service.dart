// class AudioCallService {
//   RTCPeerConnection? _peerConnection;
//   MediaStream? _localStream;
//
//   Function(RTCIceCandidate candidate)? onIceCandidate;
//   Function(MediaStream stream)? onRemoteStream;
//
//   Future<void> initializeWebRTC() async {
//     final configuration = {
//       "iceServers": [
//         {"urls": "stun:stun.l.google.com:19302"},
//       ],
//     };
//
//     _peerConnection = await createPeerConnection(configuration);
//
//     _peerConnection!.onIceCandidate = (candidate) {
//       if (candidate.candidate != null) {
//         onIceCandidate?.call(candidate);
//       }
//     };
//
//     _peerConnection!.onTrack = (RTCTrackEvent event) {
//       if (event.streams.isNotEmpty) {
//         onRemoteStream?.call(event.streams.first);
//       }
//     };
//
//     _peerConnection!.onConnectionState = (state) {
//       print("WEBRTC CONNECTION STATE: $state");
//     };
//
//     _peerConnection!.onIceConnectionState = (state) {
//       print("ICE STATE: $state");
//     };
//
//     _localStream = await navigator.mediaDevices.getUserMedia({
//       'audio': true,
//       'video': false,
//     });
//
//     for (final track in _localStream!.getTracks()) {
//       await _peerConnection!.addTrack(track, _localStream!);
//     }
//
//     print("WebRTC initialized");
//   }
//
//   Future<RTCSessionDescription> createOffer() async {
//     final offer = await _peerConnection!.createOffer();
//     await _peerConnection!.setLocalDescription(offer);
//     return offer;
//   }
//
//   Future<RTCSessionDescription> createAnswer() async {
//     final answer = await _peerConnection!.createAnswer();
//     await _peerConnection!.setLocalDescription(answer);
//     return answer;
//   }
//
//   Future<void> setRemoteOffer(String sdp) async {
//     await _peerConnection!.setRemoteDescription(
//       RTCSessionDescription(sdp, 'offer'),
//     );
//   }
//
//   Future<void> setRemoteAnswer(String sdp) async {
//     await _peerConnection!.setRemoteDescription(
//       RTCSessionDescription(sdp, 'answer'),
//     );
//   }
//
//   Future<void> addRemoteIceCandidate({
//     required String candidate,
//     required String sdpMid,
//     required int sdpMLineIndex,
//   }) async {
//     await _peerConnection!.addCandidate(
//       RTCIceCandidate(candidate, sdpMid, sdpMLineIndex),
//     );
//   }
//
//   void toggleMute(bool isMuted) {
//     final tracks = _localStream?.getAudioTracks() ?? [];
//     if (tracks.isNotEmpty) {
//       tracks.first.enabled = !isMuted;
//     }
//   }
//
//   Future<void> endCall() async {
//     for (final track in _localStream?.getTracks() ?? []) {
//       track.stop();
//     }
//
//     await _localStream?.dispose();
//     await _peerConnection?.close();
//     await _peerConnection?.dispose();
//
//     _localStream = null;
//     _peerConnection = null;
//   }
// }

// import 'package:flutter_webrtc/flutter_webrtc.dart';
//
// class AudioCallService {
//   RTCPeerConnection? _peerConnection;
//   MediaStream? _localStream;
//   MediaStream? _remoteStream;
//   final List<RTCIceCandidate> _pendingIceCandidates = [];
//   final Set<String> _localMids = {};
//   final Set<String> _remoteMids = {};
//   bool _remoteDescriptionSet = false;
//   int _localIceCandidateCount = 0;
//
//   Function(RTCIceCandidate candidate)? onIceCandidate;
//   Function(MediaStream stream)? onRemoteStream;
//
//   Future<void> initializeWebRTC() async {
//     await _configureAudioSession();
//
//     // final configuration = {
//     //   "iceServers": [
//     //
//     //     {"urls": "stun:stun.l.google.com:19302"},
//     //     {
//     //       "urls": "turn:demo.kendroo.com:3478?transport=udp",
//     //       "username": "YOUR_TURN_USERNAME",
//     //       "credential": "YOUR_TURN_PASSWORD",
//     //     },
//     //   ],
//     //   "iceCandidatePoolSize": 10,
//     //   "continualGatheringPolicy": "gather_continually",
//     //   "sdpSemantics": "unified-plan",
//     // };
//     final configuration = {
//       "iceServers": [
//         {"urls": "stun:stun.l.google.com:19302"},
//         {
//           "urls": [
//             "turn:192.168.50.53:3478?transport=udp",
//             "turn:192.168.50.53:3478?transport=tcp",
//           ],
//           "username": "test",
//           "credential": "test",
//         },
//       ],
//       "iceTransportPolicy": "relay",
//       "sdpSemantics": "unified-plan",
//     };
//
//     print("WEBRTC ICE CONFIG: $configuration");
//     _peerConnection = await createPeerConnection(configuration);
//
//     // _peerConnection!.onIceCandidate = (candidate) {
//     //   if (candidate.candidate != null) {
//     //     print(
//     //       "LOCAL ICE CANDIDATE: mid=${candidate.sdpMid}, "
//     //       "mLine=${candidate.sdpMLineIndex}",
//     //     );
//     //     onIceCandidate?.call(candidate);
//     //   }
//     // };
//
//     // _peerConnection!.onIceCandidate = (candidate) {
//     //   final value = candidate.candidate;
//     //
//     //   if (value == null) {
//     //     print("ICE CANDIDATE GATHERING END");
//     //     return;
//     //   }
//     //
//     //   _localIceCandidateCount++;
//     //   print("FULL LOCAL ICE CANDIDATE: $value");
//     //
//     //   if (value.contains("typ relay")) {
//     //     print("✅ TURN RELAY CANDIDATE FOUND");
//     //   } else {
//     //     print("NON-RELAY ICE CANDIDATE FOUND");
//     //   }
//     //
//     //   onIceCandidate?.call(candidate);
//     // };
//
//     _peerConnection!.onIceCandidate = (candidate) {
//       final value = candidate.candidate;
//
//       if (value == null) {
//         print("ICE CANDIDATE GATHERING END");
//         return;
//       }
//
//       print("FULL LOCAL ICE CANDIDATE: $value");
//       if (!value.contains("typ relay")) {
//         print("SKIPPING NON-RELAY ICE");
//         return;
//       }
//
//       print("SENDING ICE");
//       onIceCandidate?.call(candidate);
//     };
//
//     _peerConnection!.onTrack = (RTCTrackEvent event) {
//       print(
//         "REMOTE TRACK EVENT: track=${event.track.id}, "
//         "kind=${event.track.kind}, enabled=${event.track.enabled}, "
//         "muted=${event.track.muted}, streams=${event.streams.length}",
//       );
//       if (event.streams.isNotEmpty) {
//         _remoteStream = event.streams.first;
//         for (final track in _remoteStream!.getAudioTracks()) {
//           track.enabled = true;
//           Helper.setVolume(1.0, track).catchError((e) {
//             print("REMOTE AUDIO VOLUME ERROR: $e");
//           });
//         }
//         onRemoteStream?.call(_remoteStream!);
//       }
//     };
//
//     _peerConnection!.onConnectionState = (state) {
//       print("WEBRTC CONNECTION STATE: $state");
//     };
//
//     _peerConnection!.onIceConnectionState = (state) {
//       print("ICE STATE: $state");
//     };
//
//     _peerConnection!.onIceGatheringState = (state) {
//       print(
//         "ICE GATHERING STATE: $state, "
//         "localCandidates=$_localIceCandidateCount",
//       );
//     };
//
//     _peerConnection!.onSignalingState = (state) {
//       print("WEBRTC SIGNALING STATE: $state");
//     };
//
//     _localStream = await navigator.mediaDevices.getUserMedia({
//       'audio': true,
//       //  'audio': {
//       //    'echoCancellation': true,
//       //    'noiseSuppression': true,
//       //    'autoGainControl': true,
//       //  },
//       'video': false,
//     });
//
//     print("LOCAL STREAM: ${_localStream!.id}");
//     print("LOCAL AUDIO TRACKS: ${_localStream!.getAudioTracks().length}");
//     for (final track in _localStream!.getAudioTracks()) {
//       track.enabled = true;
//       print(
//         "LOCAL AUDIO TRACK: id=${track.id}, enabled=${track.enabled}, "
//         "muted=${track.muted}",
//       );
//     }
//
//     await Helper.setSpeakerphoneOn(true);
//
//     for (final track in _localStream!.getTracks()) {
//       await _peerConnection!.addTrack(track, _localStream!);
//       print("ADDED LOCAL TRACK: id=${track.id}, kind=${track.kind}");
//     }
//
//     print("WebRTC initialized");
//   }
//
//   Future<void> _configureAudioSession() async {
//     try {
//       if (WebRTC.platformIsAndroid) {
//         await Helper.setAndroidAudioConfiguration(
//           AndroidAudioConfiguration.communication,
//         );
//       } else if (WebRTC.platformIsIOS) {
//         await Helper.ensureAudioSession();
//       }
//       await Helper.setSpeakerphoneOn(true);
//       print("WEBRTC AUDIO SESSION CONFIGURED");
//     } catch (e) {
//       print("WEBRTC AUDIO SESSION CONFIG ERROR: $e");
//     }
//   }
//
//   Future<RTCSessionDescription> createOffer() async {
//     final offer = await _peerConnection!.createOffer({
//       'offerToReceiveAudio': true,
//       'offerToReceiveVideo': false,
//     });
//     await _peerConnection!.setLocalDescription(offer);
//     final gatheringState = await _peerConnection!.getIceGatheringState();
//     _localMids
//       ..clear()
//       ..addAll(_extractMids(offer.sdp));
//     print(
//       "LOCAL OFFER SET: audio=${offer.sdp?.contains('m=audio') == true}, "
//       "iceGatheringState=$gatheringState",
//     );
//     return offer;
//   }
//
//   Future<RTCSessionDescription> createAnswer() async {
//     final answer = await _peerConnection!.createAnswer({
//       'offerToReceiveAudio': true,
//       'offerToReceiveVideo': false,
//     });
//     await _peerConnection!.setLocalDescription(answer);
//     final gatheringState = await _peerConnection!.getIceGatheringState();
//     _localMids
//       ..clear()
//       ..addAll(_extractMids(answer.sdp));
//     print(
//       "LOCAL ANSWER SET: audio=${answer.sdp?.contains('m=audio') == true}, "
//       "iceGatheringState=$gatheringState",
//     );
//     return answer;
//   }
//
//   Future<bool> setRemoteOffer(String sdp) async {
//     final state = await _peerConnection?.getSignalingState();
//     if (state != RTCSignalingState.RTCSignalingStateStable) {
//       print("Skipping remote offer in signaling state: $state");
//       return false;
//     }
//
//     await _peerConnection!.setRemoteDescription(
//       RTCSessionDescription(sdp, 'offer'),
//     );
//     _remoteMids
//       ..clear()
//       ..addAll(_extractMids(sdp));
//     _remoteDescriptionSet = true;
//     print("REMOTE OFFER SET: audio=${sdp.contains('m=audio')}");
//     await _flushPendingIce();
//     return true;
//   }
//
//   Future<void> _flushPendingIce() async {
//     if (_pendingIceCandidates.isNotEmpty) {
//       print("FLUSHING PENDING ICE: ${_pendingIceCandidates.length}");
//     }
//     for (final ice in _pendingIceCandidates) {
//       await _peerConnection!.addCandidate(ice);
//     }
//     _pendingIceCandidates.clear();
//   }
//
//   Future<bool> setRemoteAnswer(String sdp) async {
//     final state = await _peerConnection?.getSignalingState();
//     if (state != RTCSignalingState.RTCSignalingStateHaveLocalOffer) {
//       print("Skipping remote answer in signaling state: $state");
//       return false;
//     }
//
//     await _peerConnection!.setRemoteDescription(
//       RTCSessionDescription(sdp, 'answer'),
//     );
//     _remoteMids
//       ..clear()
//       ..addAll(_extractMids(sdp));
//     _remoteDescriptionSet = true;
//     print("REMOTE ANSWER SET: audio=${sdp.contains('m=audio')}");
//     await _flushPendingIce();
//     return true;
//   }
//
//   Future<void> addRemoteIceCandidate({
//     required String candidate,
//     required String sdpMid,
//     required int sdpMLineIndex,
//   }) async {
//     // if (!_isKnownMid(sdpMid)) {
//     //   print(
//     //     "IGNORING REMOTE ICE FOR UNKNOWN MID: mid=$sdpMid, "
//     //     "localMids=$_localMids, remoteMids=$_remoteMids",
//     //   );
//     //   return;
//     // }
//
//     final ice = RTCIceCandidate(candidate, sdpMid, sdpMLineIndex);
//
//     if (!_remoteDescriptionSet) {
//       print("QUEUING REMOTE ICE UNTIL SDP IS SET: mid=$sdpMid");
//       _pendingIceCandidates.add(ice);
//       return;
//     }
//
//     try {
//       await _peerConnection!.addCandidate(ice);
//       print("ADDED REMOTE ICE: $candidate");
//     } catch (e) {
//       print("ADD REMOTE ICE ERROR: $e");
//     }
//   }
//
//   bool _isKnownMid(String sdpMid) {
//     if (_localMids.isNotEmpty && !_localMids.contains(sdpMid)) {
//       return false;
//     }
//
//     if (_remoteMids.isNotEmpty && !_remoteMids.contains(sdpMid)) {
//       return false;
//     }
//
//     return true;
//   }
//
//   Set<String> _extractMids(String? sdp) {
//     if (sdp == null || sdp.isEmpty) {
//       return {};
//     }
//
//     return RegExp(r'^a=mid:(.+)$', multiLine: true)
//         .allMatches(sdp)
//         .map((match) => match.group(1)?.trim())
//         .whereType<String>()
//         .where((mid) => mid.isNotEmpty)
//         .toSet();
//   }
//
//   Future<List<StatsReport>> getStats() async {
//     final peerConnection = _peerConnection;
//     if (peerConnection == null) {
//       return [];
//     }
//
//     return peerConnection.getStats();
//   }
//
//   void toggleMute(bool isMuted) {
//     final tracks = _localStream?.getAudioTracks() ?? [];
//     if (tracks.isNotEmpty) {
//       tracks.first.enabled = !isMuted;
//       print(
//         "LOCAL MUTE CHANGED: muted=$isMuted, "
//         "track=${tracks.first.id}, enabled=${tracks.first.enabled}",
//       );
//     }
//   }
//
//   Future<void> endCall() async {
//     for (final track in _localStream?.getTracks() ?? []) {
//       track.stop();
//     }
//
//     await _localStream?.dispose();
//     await _remoteStream?.dispose();
//     await _peerConnection?.close();
//     await _peerConnection?.dispose();
//
//     try {
//       await Helper.clearAndroidCommunicationDevice();
//     } catch (e) {
//       print("WEBRTC AUDIO SESSION CLEAR ERROR: $e");
//     }
//
//     _pendingIceCandidates.clear();
//     _localMids.clear();
//     _remoteMids.clear();
//     _remoteDescriptionSet = false;
//     _localIceCandidateCount = 0;
//     _localStream = null;
//     _remoteStream = null;
//     _peerConnection = null;
//   }
// }
