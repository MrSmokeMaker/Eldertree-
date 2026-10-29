import 'package:audioplayers/audioplayers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'audio_service.g.dart';

@riverpod
AudioService audioService(AudioServiceRef ref) {
  final service = AudioService();
  ref.onDispose(service.dispose);
  return service;
}

class AudioService {
  final AudioPlayer _scrollPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();
  bool _isSoundEnabled = true;

  AudioService() {
    _scrollPlayer.setReleaseMode(ReleaseMode.loop);
  }

  void dispose() {
    _scrollPlayer.dispose();
    _sfxPlayer.dispose();
  }

  void toggleSound(bool enable) {
    _isSoundEnabled = enable;
    if (!enable) {
      _scrollPlayer.stop();
    }
  }

  Future<void> playScrollLeaves() async {
    if (!_isSoundEnabled) return;
    if (_scrollPlayer.state != PlayerState.playing) {
      try {
        await _scrollPlayer.play(AssetSource('sounds/leaves_scroll.mp3'), volume: 0.2);
      } catch (_) {}
    }
  }

  Future<void> stopScrollLeaves() async {
    await _scrollPlayer.pause();
  }

  Future<void> playAddMemberChime() async {
    if (!_isSoundEnabled) return;
    try {
      await _sfxPlayer.play(AssetSource('sounds/chime_add_member.mp3'), volume: 0.6);
    } catch (_) {}
  }
}
