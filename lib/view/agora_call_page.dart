
import 'package:flutter/material.dart';

//
// class AgoraCallPage extends StatefulWidget {
//   final String channelName;
//   final String callerName;
//   final String appId;
//   final String? token;
//   final int uid;
//   final bool isAudioOnly;
//
//   const AgoraCallPage({
//     super.key,
//     required this.channelName,
//     required this.callerName,
//     required this.appId,
//     this.token,
//     required this.uid,
//     required this.isAudioOnly,
//   });
//
//   @override
//   State<AgoraCallPage> createState() => _AgoraCallPageState();
// }
//
// class _AgoraCallPageState extends State<AgoraCallPage> {
//   late final AgoraClient _client;
//   bool _isInitialized = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _initAgoraUIKit();
//   }
//
//   void _initAgoraUIKit() async {
//     List<Permission> permissions = [Permission.microphone];
//     if (!widget.isAudioOnly) {
//       permissions.add(Permission.camera);
//     }
//
//     _client = AgoraClient(
//       agoraConnectionData: AgoraConnectionData(
//         appId: widget.appId,
//         channelName: widget.channelName,
//         uid: widget.uid,
//         tempToken: widget.token,
//         username: widget.callerName.isNotEmpty ? widget.callerName : "User",
//         rtmUid: DateTime.now().millisecondsSinceEpoch.toString(),
//         rtmEnabled: false,
//       ),
//       enabledPermission: permissions,
//     );
//
//     await _client.initialize();
//
//     if (widget.isAudioOnly) {
//       // Clean shutdown for camera operations during voice calls
//       await _client.engine.muteLocalVideoStream(true);
//       await _client.engine.enableAudio();
//       await _client.engine.disableVideo();
//       await _client.engine.enableLocalVideo(false);
//
//
//
//     } else {
//       // Ensure the video state pipeline is fully active
//       await _client.engine.enableVideo();
//       await _client.engine.muteLocalVideoStream(false);
//     }
//
//     setState(() {
//       _isInitialized = true;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xff101828), // Sleek midnight background theme
//       appBar: AppBar(
//         backgroundColor: const Color(0xff101828),
//         foregroundColor: Colors.white,
//         elevation: 0,
//         title: Text(widget.isAudioOnly ? "Voice Call with ${widget.callerName}" : "Video Call with ${widget.callerName}"),
//         centerTitle: true,
//         leading: IconButton(
//           icon: const Icon(Icons.keyboard_arrow_down, size: 28),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: SafeArea(
//         child: !_isInitialized
//             ? const Center(child: CircularProgressIndicator(color: Colors.blue))
//             : Stack(
//           children: [
//             // FIXED: Restored this layer so the cameras have a canvas viewport target to display onto!
//             AgoraVideoViewer(
//               client: _client,
//               layoutType: Layout.grid,
//               showAVState: true,
//               // Designates a clean placeholder card layout design specifically for Audio users
//               disabledVideoWidget: Container(
//                 color: const Color(0xff1D2939),
//                 child: Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       CircleAvatar(
//                         radius: 50,
//                         backgroundColor: Colors.blueAccent.withAlpha(51),
//                         child: const Icon(Icons.person, size: 60, color: Colors.blueAccent),
//                       ),
//                       const SizedBox(height: 16),
//                       Text(
//                         widget.callerName,
//                         style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
//                       ),
//                       const SizedBox(height: 8),
//                       const Text("Voice Active Call", style: TextStyle(color: Colors.white54, fontSize: 14)),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//
//             // Pre-styled call action controls overlays
//             AgoraVideoButtons(
//               client: _client,
//               enabledButtons: widget.isAudioOnly
//                   ? const [
//                 BuiltInButtons.toggleMic,
//                 BuiltInButtons.callEnd,
//
//               ]
//                   : const [
//                 BuiltInButtons.toggleMic,
//                 BuiltInButtons.switchCamera,
//                 BuiltInButtons.toggleCamera,
//                 BuiltInButtons.callEnd,
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class AgoraCallPage extends StatefulWidget {
  final String channelName;
  final String callerName;
  final String appId;
  final String? token;
  final int uid;
  final bool isAudioOnly;
  final Future<void> Function()? onCallEnded;

  const AgoraCallPage({
    super.key,
    required this.channelName,
    required this.callerName,
    required this.appId,
    this.token,
    required this.uid,
    required this.isAudioOnly,
    this.onCallEnded,
  });

  @override
  State<AgoraCallPage> createState() => _AgoraCallPageState();
}

class _AgoraCallPageState extends State<AgoraCallPage> {
  late final RtcEngine _engine;

  int? _remoteUid;
  bool _joined = false;
  bool _muted = false;
  bool _cameraOff = true;
  bool _endNotified = false;

  @override
  void initState() {
    super.initState();
    _initAgora();
  }

  Future<void> _initAgora() async {
    await Permission.microphone.request();

    if (!widget.isAudioOnly) {
      await Permission.camera.request();
    }

    _engine = createAgoraRtcEngine();

    await _engine.initialize(
      RtcEngineContext(
        appId: widget.appId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ),
    );

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (connection, elapsed) {
          if (mounted) {
            setState(() => _joined = true);
          }
        },
        onUserJoined: (connection, remoteUid, elapsed) {
          if (mounted) {
            setState(() => _remoteUid = remoteUid);
          }
        },
        onUserOffline: (connection, remoteUid, reason) {
          if (mounted) {
            setState(() => _remoteUid = null);
          }
        },
      ),
    );

    await _engine.enableAudio();

    if (widget.isAudioOnly) {
      await _engine.disableVideo();
    } else {
      await _engine.enableVideo();
      await _engine.startPreview();
    }

    await _engine.joinChannel(
      token: widget.token ?? '',
      channelId: widget.channelName,
      uid: widget.uid,
      options: ChannelMediaOptions(
        autoSubscribeAudio: true,
        autoSubscribeVideo: !widget.isAudioOnly,
        publishMicrophoneTrack: true,
        publishCameraTrack: !widget.isAudioOnly,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
      ),
    );
  }

  Future<void> _endCall() async {
    await _notifyCallEnded();
    await _engine.leaveChannel();
    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _notifyCallEnded() async {
    if (_endNotified) return;
    _endNotified = true;
    await widget.onCallEnded?.call();
  }

  Future<void> _toggleMic() async {
    setState(() => _muted = !_muted);
    await _engine.muteLocalAudioStream(_muted);
  }

  Future<void> _toggleCamera() async {
    setState(() => _cameraOff = !_cameraOff);
    await _engine.muteLocalVideoStream(_cameraOff);

    if (_cameraOff) {
      await _engine.stopPreview();
    } else {
      await _engine.startPreview();
    }
  }

  Future<void> _switchCamera() async {
    await _engine.switchCamera();
  }

  @override
  void dispose() {
    _notifyCallEnded();
    _engine.leaveChannel();
    _engine.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: !_joined
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                widget.isAudioOnly ? _audioView() : _videoView(),
                _topBar(),
                _bottomButtons(),
              ],
            ),
    );
  }

  Widget _videoView() {
    return Stack(
      children: [
        Positioned.fill(
          child: _remoteUid != null
              ? AgoraVideoView(
                  controller: VideoViewController.remote(
                    rtcEngine: _engine,
                    canvas: VideoCanvas(
                      uid: _remoteUid,
                      renderMode: RenderModeType.renderModeHidden,
                    ),
                    connection: RtcConnection(channelId: widget.channelName),
                  ),
                )
              : _waitingView(),
        ),

        Positioned(
          top: 95,
          right: 16,
          child: Container(
            width: 135,
            height: 190,
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white24),
            ),
            clipBehavior: Clip.antiAlias,
            child: _cameraOff
                ? const Center(
                    child: Icon(
                      Icons.videocam_off,
                      color: Colors.white,
                      size: 38,
                    ),
                  )
                : AgoraVideoView(
                    controller: VideoViewController(
                      rtcEngine: _engine,
                      canvas: const VideoCanvas(
                        uid: 0,
                        renderMode: RenderModeType.renderModeHidden,
                        mirrorMode: VideoMirrorModeType.videoMirrorModeEnabled,
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _audioView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 62,
            backgroundColor: Color(0xff1D2939),
            child: Icon(Icons.person, size: 80, color: Colors.white70),
          ),
          const SizedBox(height: 20),
          Text(
            widget.callerName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Voice Call",
            style: TextStyle(color: Colors.white54, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _waitingView() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Text(
          "Waiting for ${widget.callerName}...",
          style: const TextStyle(color: Colors.white70, fontSize: 18),
        ),
      ),
    );
  }

  Widget _topBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.isAudioOnly
                    ? "Voice Call with ${widget.callerName}"
                    : widget.callerName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomButtons() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 34,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _circleButton(
            icon: _muted ? Icons.mic_off : Icons.mic,
            color: Colors.black54,
            onTap: _toggleMic,
          ),
          if (!widget.isAudioOnly)
            _circleButton(
              icon: Icons.cameraswitch,
              color: Colors.black54,
              onTap: _switchCamera,
            ),
          if (!widget.isAudioOnly)
            _circleButton(
              icon: _cameraOff ? Icons.videocam_off : Icons.videocam,
              color: Colors.white,
              iconColor: Colors.black,
              onTap: _toggleCamera,
            ),
          _circleButton(
            icon: Icons.call_end,
            color: Colors.red,
            size: 68,
            iconColor: Colors.white,
            onTap: _endCall,
          ),
        ],
      ),
    );
  }

  Widget _circleButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    Color iconColor = Colors.white,
    double size = 58,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(size),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, color: iconColor, size: 30),
      ),
    );
  }
}
