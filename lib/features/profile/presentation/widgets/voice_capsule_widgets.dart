import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

class VoiceRecorderButton extends StatefulWidget {
  final Function(String path) onRecordComplete;
  const VoiceRecorderButton({super.key, required this.onRecordComplete});

  @override
  State<VoiceRecorderButton> createState() => _VoiceRecorderButtonState();
}

class _VoiceRecorderButtonState extends State<VoiceRecorderButton> with SingleTickerProviderStateMixin {
  final AudioRecorder _record = AudioRecorder();
  bool _isRecording = false;
  late AnimationController _pulseController;
  Timer? _timer;
  int _recordDuration = 0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _record.dispose();
    _pulseController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _startRecording() async {
    if (await _record.hasPermission()) {
      HapticFeedback.heavyImpact();
      final tempDir = await getTemporaryDirectory();
      final path = '${tempDir.path}/temp_record_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _record.start(const RecordConfig(encoder: AudioEncoder.aacLc), path: path);
      setState(() {
        _isRecording = true;
        _recordDuration = 0;
      });
      _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => setState(() => _recordDuration++));
    }
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return;
    HapticFeedback.lightImpact();
    _timer?.cancel();
    final path = await _record.stop();
    setState(() => _isRecording = false);
    if (path != null && _recordDuration > 1) {
      widget.onRecordComplete(path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (_) => _startRecording(),
      onLongPressEnd: (_) => _stopRecording(),
      onLongPressUp: _stopRecording,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: _isRecording ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(32),
          boxShadow: _isRecording ? [BoxShadow(color: Colors.red.withOpacity(0.5), blurRadius: 20, spreadRadius: 5)] : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_isRecording ? Icons.mic : Icons.mic_none, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              _isRecording ? 'Recording 00:${_recordDuration.toString().padLeft(2, '0')}' : 'Hold to record',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class VoicePlayerWidget extends StatefulWidget {
  final String audioUrl;
  const VoicePlayerWidget({super.key, required this.audioUrl});

  @override
  State<VoicePlayerWidget> createState() => _VoicePlayerWidgetState();
}

class _VoicePlayerWidgetState extends State<VoicePlayerWidget> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _player.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => _isPlaying = state == PlayerState.playing);
    });
    _player.onDurationChanged.listen((newDuration) {
      if (mounted) setState(() => _duration = newDuration);
    });
    _player.onPositionChanged.listen((newPosition) {
      if (mounted) setState(() => _position = newPosition);
    });
    _player.setSourceUrl(widget.audioUrl);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(_isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill),
            color: Theme.of(context).colorScheme.primary,
            iconSize: 36,
            onPressed: () {
              _isPlaying ? _player.pause() : _player.play(UrlSource(widget.audioUrl));
            },
          ),
          Expanded(
            child: Slider(
              value: _position.inSeconds.toDouble(),
              min: 0.0,
              max: _duration.inSeconds.toDouble() > 0 ? _duration.inSeconds.toDouble() : 1.0,
              onChanged: (val) {
                _player.seek(Duration(seconds: val.toInt()));
              },
            ),
          ),
        ],
      ),
    );
  }
}
