import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

// class AgoraAudioCallService {
//   RtcEngine? _engine;
//
//   Future<void> initialize({
//     required String appId,
//     required void Function(int remoteUid) onRemoteUserJoined,
//     required void Function(int remoteUid) onRemoteUserLeft,
//   }) async {
//     final mic = await Permission.microphone.request();
//     if (!mic.isGranted) {
//       throw Exception("Microphone permission denied");
//     }
//
//     _engine = createAgoraRtcEngine();
//
//     await _engine!.initialize(
//       RtcEngineContext(appId: appId),
//     );
//
//     await _engine!.enableAudio();
//
//     await _engine!.setClientRole(
//       role: ClientRoleType.clientRoleBroadcaster,
//     );
//
//     //await _engine!.setEnableSpeakerphone(true);
//
//     _engine!.registerEventHandler(
//       RtcEngineEventHandler(
//         onJoinChannelSuccess: (connection, elapsed) {
//           print("Agora joined channel: ${connection.channelId}");
//         },
//         onUserJoined: (connection, remoteUid, elapsed) {
//           print("Agora remote user joined: $remoteUid");
//           onRemoteUserJoined(remoteUid);
//         },
//         onUserOffline: (connection, remoteUid, reason) {
//           print("Agora remote user left: $remoteUid");
//           onRemoteUserLeft(remoteUid);
//         },
//         onError: (err, msg) {
//           print("Agora error: $err $msg");
//         },
//       ),
//     );
//   }
//
//   Future<void> joinChannel({
//     required String token,
//     required String channelName,
//     required int uid,
//   }) async {
//     await _engine!.joinChannel(
//       token: token,
//       channelId: channelName,
//       uid: uid,
//       options: const ChannelMediaOptions(
//         clientRoleType: ClientRoleType.clientRoleBroadcaster,
//         publishMicrophoneTrack: true,
//         autoSubscribeAudio: true,
//       ),
//     );
//     try {
//       await _engine!.setEnableSpeakerphone(true);
//     } catch (e) {
//       print("Speaker enable ignored: $e");
//     }
//   }
//
//   Future<void> mute(bool muted) async {
//     await _engine?.muteLocalAudioStream(muted);
//   }
//
//   Future<void> speaker(bool enabled) async {
//     await _engine?.setEnableSpeakerphone(enabled);
//   }
//
//   Future<void> leave() async {
//     await _engine?.leaveChannel();
//   }
//
//   Future<void> dispose() async {
//     await _engine?.release();
//     _engine = null;
//   }
// }

class AgoraAudioCallService {
  RtcEngine? _engine;

  Future<void> initialize({
    required String appId,
    required void Function(int remoteUid) onRemoteUserJoined,
    required void Function(int remoteUid) onRemoteUserLeft,
  }) async {
    final mic = await Permission.microphone.request();
    if (!mic.isGranted) {
      throw Exception("Microphone permission denied");
    }

    _engine = createAgoraRtcEngine();

    await _engine!.initialize(
      RtcEngineContext(appId: appId.trim()),
    );

    await _engine!.enableAudio();

    await _engine!.setClientRole(
      role: ClientRoleType.clientRoleBroadcaster,
    );

    _engine!.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (connection, elapsed) {
          print("Agora joined channel: ${connection.channelId}");
        },
        onUserJoined: (connection, remoteUid, elapsed) {
          print("Agora remote user joined: $remoteUid");
          onRemoteUserJoined(remoteUid);
        },
        onUserOffline: (connection, remoteUid, reason) {
          print("Agora remote user left: $remoteUid");
          onRemoteUserLeft(remoteUid);
        },
        onError: (err, msg) {
          print("Agora error: $err $msg");
        },
      ),
    );
  }

  Future<void> joinChannel({
    required String token,
    required String channelName,
    required int uid,
  }) async {
    await _engine!.joinChannel(
      token: token,
      channelId: channelName,
      uid: uid,
      options: const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        publishMicrophoneTrack: true,
        autoSubscribeAudio: true,
      ),
    );

    try {
      await _engine!.setEnableSpeakerphone(true);
    } catch (e) {
      print("Speaker enable ignored: $e");
    }
  }

  Future<void> mute(bool muted) async {
    await _engine?.muteLocalAudioStream(muted);
  }

  Future<void> speaker(bool enabled) async {
    await _engine?.setEnableSpeakerphone(enabled);
  }

  Future<void> leave() async {
    await _engine?.leaveChannel();
  }

  Future<void> dispose() async {
    await _engine?.release();
    _engine = null;
  }
}