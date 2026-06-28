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

import 'dart:async';

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
  final Future<void> Function()? onCallJoinFailed;
  final Future<String?> Function()? getCallState;

  const AgoraCallPage({
    super.key,
    required this.channelName,
    required this.callerName,
    required this.appId,
    this.token,
    required this.uid,
    required this.isAudioOnly,
    this.onCallEnded,
    this.onCallJoinFailed,
    this.getCallState,
  });

  @override
  State<AgoraCallPage> createState() => _AgoraCallPageState();
}

class _AgoraCallPageState extends State<AgoraCallPage> {
  RtcEngine? _engine;

  int? _remoteUid;
  bool _joined = false;
  bool _muted = false;
  bool _cameraOff = true;
  bool _remoteCameraOff = true;
  bool _endNotified = false;
  bool _joinFailureNotified = false;
  String? _joinError;
  String? _remoteCallError;
  Timer? _joinTimeoutTimer;
  Timer? _callStateTimer;
  static const double _localPreviewWidth = 135;
  static const double _localPreviewHeight = 190;

  Offset _localPreviewOffset = Offset.zero;
  bool _localPreviewPositionReady = false;
  @override
  void initState() {
    super.initState();
    _initAgora();
    _startCallStatePolling();
  }

  Future<void> _initAgora() async {
    final micStatus = await Permission.microphone.request();
    if (!micStatus.isGranted) {
      _showJoinError("Microphone permission is required.");
      return;
    }

    if (widget.appId.trim().isEmpty ||
        widget.channelName.trim().isEmpty ||
        widget.uid <= 0) {
      _showJoinError("Call information is incomplete.");
      return;
    }

    try {
      _joinTimeoutTimer?.cancel();
      _joinTimeoutTimer = Timer(const Duration(seconds: 15), () {
        if (!mounted || _joined) return;
        _showJoinError("Unable to join the call. Please try again.");
      });

      final engine = createAgoraRtcEngine();
      _engine = engine;

      await engine.initialize(
        RtcEngineContext(
          appId: widget.appId.trim(),
          channelProfile: ChannelProfileType.channelProfileCommunication,
        ),
      );

      engine.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (connection, elapsed) {
            _joinTimeoutTimer?.cancel();
            if (mounted) {
              setState(() {
                _joined = true;
                _joinError = null;
              });
            }
          },
          onError: (err, msg) {
            _joinTimeoutTimer?.cancel();
            if (mounted && !_joined) {
              _showJoinError(
                msg.isNotEmpty
                    ? msg
                    : "Unable to join the call. Please try again.",
              );
            }
          },
          onUserJoined: (connection, remoteUid, elapsed) {
            if (mounted) {
              setState(() {
                _remoteUid = remoteUid;
                _remoteCameraOff = true;
              });
            }
          },
          onUserOffline: (connection, remoteUid, reason) {
            if (mounted) {
              setState(() {
                _remoteUid = null;
                _remoteCameraOff = true;
              });
            }
          },
          onUserMuteVideo: (connection, remoteUid, muted) {
            if (mounted && remoteUid == _remoteUid) {
              setState(() => _remoteCameraOff = muted);
            }
          },
          onRemoteVideoStateChanged:
              (connection, remoteUid, state, reason, elapsed) {
                if (!mounted || remoteUid != _remoteUid) return;

                if (state == RemoteVideoState.remoteVideoStateDecoding ||
                    state == RemoteVideoState.remoteVideoStateStarting) {
                  setState(() => _remoteCameraOff = false);
                } else if (state == RemoteVideoState.remoteVideoStateStopped) {
                  setState(() => _remoteCameraOff = true);
                }
              },
        ),
      );

      await engine.enableAudio();

      if (widget.isAudioOnly) {
        await engine.disableVideo();
      } else {
        await engine.enableVideo();
        await engine.enableLocalVideo(false);
      }

      await engine.joinChannel(
        token: widget.token ?? '',
        channelId: widget.channelName.trim(),
        uid: widget.uid,
        options: const ChannelMediaOptions(
          autoSubscribeAudio: true,
          autoSubscribeVideo: true,
          publishMicrophoneTrack: true,
          publishCameraTrack: false,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
        ),
      );
    } catch (e) {
      _joinTimeoutTimer?.cancel();
      _showJoinError("Unable to join the call. Please try again.");
    }
  }

  void _showJoinError(String message) {
    if (mounted) {
      setState(() => _joinError = message);
    }
    unawaited(_notifyCallJoinFailed());
  }

  void _startCallStatePolling() {
    if (widget.getCallState == null) return;

    _callStateTimer?.cancel();
    _callStateTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      if (_endNotified || !mounted) return;

      try {
        final state = await widget.getCallState?.call();
        if (!mounted || _endNotified) return;

        if (state == 'ended' || state == 'missed') {
          _callStateTimer?.cancel();
          _joinTimeoutTimer?.cancel();
          _endNotified = true;
          setState(() {
            _remoteCallError = _remoteUid == null
                ? "The other person is unable to join the call."
                : "Call ended.";
          });
        }
      } catch (e) {
        debugPrint("Agora call state polling failed: $e");
      }
    });
  }

  Future<void> _endCall() async {
    await _notifyCallEnded();
    await _engine?.leaveChannel();
    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _notifyCallEnded() async {
    if (_endNotified) return;
    _endNotified = true;
    _callStateTimer?.cancel();
    await widget.onCallEnded?.call();
  }

  Future<void> _notifyCallJoinFailed() async {
    if (_joinFailureNotified) return;
    _joinFailureNotified = true;
    _endNotified = true;
    _callStateTimer?.cancel();
    await (widget.onCallJoinFailed ?? widget.onCallEnded)?.call();
  }

  Future<void> _toggleMic() async {
    setState(() => _muted = !_muted);
    await _engine?.muteLocalAudioStream(_muted);
  }

  Future<void> _toggleCamera() async {
    final turningCameraOn = _cameraOff;

    if (turningCameraOn) {
      final status = await Permission.camera.request();
      if (!status.isGranted) return;

      await _engine?.enableLocalVideo(true);
      await _engine?.startPreview();
      await _engine?.muteLocalVideoStream(false);
      await _engine?.updateChannelMediaOptions(
        const ChannelMediaOptions(
          autoSubscribeAudio: true,
          autoSubscribeVideo: true,
          publishMicrophoneTrack: true,
          publishCameraTrack: true,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
        ),
      );
    } else {
      await _engine?.updateChannelMediaOptions(
        const ChannelMediaOptions(
          autoSubscribeAudio: true,
          autoSubscribeVideo: true,
          publishMicrophoneTrack: true,
          publishCameraTrack: false,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
        ),
      );
      await _engine?.muteLocalVideoStream(true);
      await _engine?.stopPreview();
      await _engine?.enableLocalVideo(false);
    }

    setState(() => _cameraOff = !turningCameraOn);
  }

  Future<void> _switchCamera() async {
    if (_cameraOff) return;
    await _engine?.switchCamera();
  }
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_localPreviewPositionReady) return;

    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);

    _localPreviewOffset = Offset(
      size.width - _localPreviewWidth - 16,
      padding.top + 72,
    );

    _localPreviewPositionReady = true;
  }

  Offset _clampLocalPreviewOffset(Offset offset) {
    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);

    const minX = 8.0;
    final maxX = size.width - _localPreviewWidth - 8;

    final minY = padding.top + 56;
    final maxY = size.height - _localPreviewHeight - 110;

    return Offset(
      offset.dx.clamp(minX, maxX < minX ? minX : maxX).toDouble(),
      offset.dy.clamp(minY, maxY < minY ? minY : maxY).toDouble(),
    );
  }

  void _snapLocalPreviewToSide() {
    final size = MediaQuery.sizeOf(context);
    final centerX = _localPreviewOffset.dx + (_localPreviewWidth / 2);

    final targetX = centerX < size.width / 2
        ? 8.0
        : size.width - _localPreviewWidth - 8;

    setState(() {
      _localPreviewOffset = _clampLocalPreviewOffset(
        Offset(targetX, _localPreviewOffset.dy),
      );
    });
  }

  Widget _movableLocalPreview(RtcEngine engine) {
    return Positioned(
      left: _localPreviewOffset.dx,
      top: _localPreviewOffset.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _localPreviewOffset = _clampLocalPreviewOffset(
              _localPreviewOffset + details.delta,
            );
          });
        },
        onPanEnd: (_) => _snapLocalPreviewToSide(),
        child: Container(
          width: _localPreviewWidth,
          height: _localPreviewHeight,
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.28),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: _cameraOff
              ? _cameraOffTile("You")
              : AgoraVideoView(
            controller: VideoViewController(
              rtcEngine: engine,
              canvas: const VideoCanvas(
                uid: 0,
                renderMode: RenderModeType.renderModeHidden,
                mirrorMode: VideoMirrorModeType.videoMirrorModeEnabled,
              ),
            ),
          ),
        ),
      ),
    );
  }
  @override
  void dispose() {
    _joinTimeoutTimer?.cancel();
    _callStateTimer?.cancel();
    _notifyCallEnded();
    _engine?.leaveChannel();
    _engine?.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _remoteCallError != null
          ? _remoteCallErrorView()
          : _joinError != null
          ? _joinErrorView()
          : !_joined
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

  // Widget _videoView() {
  //   final engine = _engine;
  //   if (engine == null) return const SizedBox.shrink();
  //
  //   return Stack(
  //     children: [
  //       Positioned.fill(
  //         child: _remoteUid != null && !_remoteCameraOff
  //             ? AgoraVideoView(
  //                 controller: VideoViewController.remote(
  //                   rtcEngine: engine,
  //                   canvas: VideoCanvas(
  //                     uid: _remoteUid,
  //                     renderMode: RenderModeType.renderModeHidden,
  //                   ),
  //                   connection: RtcConnection(channelId: widget.channelName),
  //                 ),
  //               )
  //             : _nameOnlyView(
  //                 _remoteUid == null
  //                     ? "Waiting for ${widget.callerName}..."
  //                     : widget.callerName,
  //               ),
  //       ),
  //
  //       Positioned(
  //         top: 95,
  //         right: 16,
  //         child: Container(
  //           width: 135,
  //           height: 190,
  //           decoration: BoxDecoration(
  //             color: Colors.black87,
  //             borderRadius: BorderRadius.circular(22),
  //             border: Border.all(color: Colors.white24),
  //           ),
  //           clipBehavior: Clip.antiAlias,
  //           child: _cameraOff
  //               ? _cameraOffTile("You")
  //               : AgoraVideoView(
  //                   controller: VideoViewController(
  //                     rtcEngine: engine,
  //                     canvas: const VideoCanvas(
  //                       uid: 0,
  //                       renderMode: RenderModeType.renderModeHidden,
  //                       mirrorMode: VideoMirrorModeType.videoMirrorModeEnabled,
  //                     ),
  //                   ),
  //                 ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _videoView() {
    final engine = _engine;
    if (engine == null) return const SizedBox.shrink();

    return Stack(
      children: [
        Positioned.fill(
          child: _remoteUid != null && !_remoteCameraOff
              ? AgoraVideoView(
            controller: VideoViewController.remote(
              rtcEngine: engine,
              canvas: VideoCanvas(
                uid: _remoteUid,
                renderMode: RenderModeType.renderModeHidden,
              ),
              connection: RtcConnection(channelId: widget.channelName),
            ),
          )
              : _nameOnlyView(
            _remoteUid == null
                ? "Waiting for ${widget.callerName}..."
                : widget.callerName,
          ),
        ),

        _movableLocalPreview(engine),
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

  Widget _joinErrorView() {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.call_end, color: Colors.redAccent, size: 56),
              const SizedBox(height: 16),
              Text(
                _joinError!,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _endCall, child: const Text("Close")),
            ],
          ),
        ),
      ),
    );
  }

  Widget _remoteCallErrorView() {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.call_end, color: Colors.redAccent, size: 56),
              const SizedBox(height: 16),
              Text(
                _remoteCallError!,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _nameOnlyView(String label) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 58,
              backgroundColor: Color(0xff1D2939),
              child: Icon(Icons.person, size: 70, color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _cameraOffTile(String label) {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.videocam_off, color: Colors.white, size: 34),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ],
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
