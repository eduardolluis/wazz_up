import 'dart:async';

import 'package:flutter/material.dart';

class StatusViewerPage extends StatefulWidget {
  final String name;
  final String time;
  final int statusNum;

  const StatusViewerPage({
    super.key,
    required this.name,
    required this.time,
    required this.statusNum,
  });

  @override
  State<StatusViewerPage> createState() => _StatusViewerPageState();
}

class _StatusViewerPageState extends State<StatusViewerPage>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _progressController;
  Timer? _autoAdvanceTimer;

  static const _duration = Duration(seconds: 5);

  final List<_StatusSlide> _slides = [
    _StatusSlide(
      background: const Color(0xFF1A1A2E),
      text: '¡Buenos días! 🌅',
      emoji: '☀️',
    ),
    _StatusSlide(
      background: const Color(0xFF16213E),
      text: 'Working on something great 🚀',
      emoji: '💻',
    ),
    _StatusSlide(
      background: const Color(0xFF0F3460),
      text: 'WhatZapp clone looking good!',
      emoji: '🎉',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: _duration,
    );
    _start();
  }

  void _start() {
    _progressController.reset();
    _progressController.forward();
    _autoAdvanceTimer?.cancel();
    _autoAdvanceTimer = Timer(_duration, _nextSlide);
  }

  void _nextSlide() {
    if (_currentIndex < _clampedCount - 1) {
      setState(() => _currentIndex++);
      _start();
    } else {
      Navigator.pop(context);
    }
  }

  void _prevSlide() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
      _start();
    }
  }

  int get _clampedCount => widget.statusNum.clamp(1, _slides.length);

  @override
  void dispose() {
    _progressController.dispose();
    _autoAdvanceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_currentIndex % _slides.length];

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapUp: (details) {
          final half = MediaQuery.of(context).size.width / 2;
          if (details.globalPosition.dx < half) {
            _prevSlide();
          } else {
            _nextSlide();
          }
        },
        child: Stack(
          children: [
            // Background
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              color: slide.background,
              width: double.infinity,
              height: double.infinity,
            ),

            // Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(slide.emoji, style: const TextStyle(fontSize: 80)),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      slide.text,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: List.generate(_clampedCount, (i) {
                        return Expanded(
                            child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: i < _currentIndex
                                ? Container(
                                    height: 3,
                                    color: Colors.white,
                                  )
                                : i == _currentIndex
                                    ? AnimatedBuilder(
                                        animation: _progressController,
                                        builder: (_, __) =>
                                            LinearProgressIndicator(
                                          value: _progressController.value,
                                          minHeight: 3,
                                          backgroundColor: Colors.white38,
                                          valueColor:
                                              const AlwaysStoppedAnimation(
                                                  Colors.white),
                                        ),
                                      )
                                    : Container(
                                        height: 3,
                                        color: Colors.white38,
                                      ),
                          ),
                        ));
                      }),
                    ),
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.blueGrey,
                          child: Text(
                            widget.name[0].toUpperCase(),
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              'Today at ${widget.time}',
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Bottom reply bar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white54),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Text(
                            'Responder...',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 15),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      CircleAvatar(
                        backgroundColor: Colors.white24,
                        child: const Icon(Icons.emoji_emotions_outlined,
                            color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: Colors.white24,
                        child: const Icon(Icons.forward, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusSlide {
  final Color background;
  final String text;
  final String emoji;
  const _StatusSlide(
      {required this.background, required this.text, required this.emoji});
}
