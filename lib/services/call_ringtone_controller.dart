

import 'package:audioplayers/audioplayers.dart';

class CallRingtoneController {

  static final CallRingtoneController _instance = CallRingtoneController._internal();
  factory CallRingtoneController() => _instance;
  CallRingtoneController._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isRinging = false;


  Future<void> startRinging() async {
    if (_isRinging) return;

    try {
      _isRinging = true;


      await _audioPlayer.setReleaseMode(ReleaseMode.loop);

      await _audioPlayer.setAudioContext(
        AudioContext(
          android: const AudioContextAndroid(
            isSpeakerphoneOn: true,
            stayAwake: true,
            contentType: AndroidContentType.music,
            usageType: AndroidUsageType.notificationRingtone,
            audioFocus: AndroidAudioFocus.gainTransient,
          ),
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
            options: {
              AVAudioSessionOptions.duckOthers,
            },
          ),
        ),
      );


      await _audioPlayer.play(  AssetSource('assets/audio/rigntone.wav'),);
      print("[RINGTONE] Ringtone playback started loop successfully.");
    } catch (e) {
      print("[RINGTONE ERROR] Failed to play ringtone: $e");
      _isRinging = false;
    }
  }


  Future<void> stopRinging() async {
    if (!_isRinging) return;
    try {
      await _audioPlayer.stop();
      _isRinging = false;
      print("[RINGTONE] Ringtone stopped.");
    } catch (e) {
      print("[RINGTONE ERROR] Failed to stop playback: $e");
    }
  }
}