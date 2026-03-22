import 'package:flutter/material.dart';

class AudioMessageBubble extends StatefulWidget {
  const AudioMessageBubble({
    super.key,
    required this.message,
    required this.time,
    required this.isMine,
  });

  final String message;
  final String time;
  final bool isMine;

  @override
  State<AudioMessageBubble> createState() => _AudioMessageBubbleState();
}

class _AudioMessageBubbleState extends State<AudioMessageBubble>
    with SingleTickerProviderStateMixin {
  bool _isPlaying = false;
  double _progress = 0.0;
  late AnimationController _waveController;

  String get _durationLabel {
    final parts = widget.message.split('•');
    if (parts.length >= 2) return parts.last.trim();
    return '0:00';
  }

  int get _totalSeconds {
    final label = _durationLabel;
    final segments = label.split(':');
    if (segments.length == 2) {
      final m = int.tryParse(segments[0]) ?? 0;
      final s = int.tryParse(segments[1]) ?? 0;
      return m * 60 + s;
    }
    return 0;
  }

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  void _togglePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _simulateProgress();
      }
    });
  }

  void _simulateProgress() {
    if (!_isPlaying) return;
    final total = _totalSeconds == 0 ? 10 : _totalSeconds;
    const interval = Duration(milliseconds: 300);
    final step = 1.0 / (total * (1000 / interval.inMilliseconds));

    Future.delayed(interval, () {
      if (!mounted || !_isPlaying) return;
      setState(() {
        _progress += step;
        if (_progress >= 1.0) {
          _progress = 0.0;
          _isPlaying = false;
          return;
        }
      });
      _simulateProgress();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bubbleColor = widget.isMine ? const Color(0xFFDCF8C6) : Colors.white;
    final iconColor =
        widget.isMine ? const Color(0xFF075E54) : const Color(0xFF128C7E);
    final trackColor =
        widget.isMine ? const Color(0xFF25D366) : const Color(0xFF128C7E);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: _togglePlay,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              SizedBox(
                width: 120,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWaveform(trackColor),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _progress,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(trackColor),
                        minHeight: 3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Duración
              Text(
                _durationLabel,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.time,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
                if (widget.isMine) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.done_all, size: 16, color: Colors.blue),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaveform(Color color) {
    final heights = [
      6.0,
      12.0,
      8.0,
      16.0,
      10.0,
      14.0,
      7.0,
      18.0,
      9.0,
      13.0,
      6.0,
      15.0,
      11.0,
      8.0,
      16.0
    ];

    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(heights.length, (i) {
            final isActive = (i / heights.length) <= _progress;
            final animOffset = _isPlaying
                ? (_waveController.value * 4 * ((i % 3) + 1)).clamp(0.0, 4.0)
                : 0.0;

            return Container(
              width: 3,
              height: heights[i] + (isActive ? animOffset : 0),
              decoration: BoxDecoration(
                color: isActive ? color : Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        );
      },
    );
  }
}
