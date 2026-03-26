import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../theme/app_theme.dart';
class StanceMovementWorkoutSheet extends StatefulWidget {
  const StanceMovementWorkoutSheet({super.key});
  @override
  State<StanceMovementWorkoutSheet> createState() => _StanceMovementWorkoutSheetState();
}
class _StanceMovementWorkoutSheetState extends State<StanceMovementWorkoutSheet> {
  static const int _totalRounds = 3;
  static const int _roundDuration = 60;
  static const int _restDuration = 15;
  int _tutorialIndex = 0;
  bool _showTutorial = true;
  int currentRound = 1;
  int timeLeft = _roundDuration;
  String phase = 'fight';
  bool running = false;
  Timer? _timer;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final List<_TutorialStep> _steps = const [
    _TutorialStep(
      title: 'Stance',
      body:'''
1. Stand with one foot slightly ahead of the other, shoulder-width apart. 
2. Keep your knees soft.
3. Tuck your chin.
4. Keep your hands up by your face.
5. Stay balanced on the balls of your feet.
          ''',
      imagePath: 'assets/stance.jpg',
    ),
    _TutorialStep(
      title: 'Linear Movement',
      body: '''
1. Going forward: move lead foot first, then back foot.  
2. Going backward: move back foot first, then lead foot.
3. To move back quicker, shift more of your body weight onto your back foot.
          ''',
    ),
    _TutorialStep(
      title: 'Lateral Movement',
      body: '''
1. If you want to move right, move your right foot first. 
2. If you want to move left, move your left foot first. 
3. Keep your stance shape and avoid crossing your feet.
          ''',
    ),
  ];
  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playAssetOncePerCall(String assetRelativePath) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(assetRelativePath));
    } catch (_) {
      // If an audio file is missing or fails to load, we simply skip it.
    }
  }

  void _maybePlayInstructionAudio(int elapsed) {
    if (phase != 'fight') return;
    switch (elapsed) {
      case 2:
        _playAssetOncePerCall('audio/bend_knees.mp3');
        break;
      case 4:
        _playAssetOncePerCall('audio/tuck_chin.mp3');
        break;
      case 6:
        _playAssetOncePerCall('audio/hands_up.mp3');
        break;
      case 8:
        _playAssetOncePerCall('audio/stay_balanced.mp3');
        break;
      case 10:
        _playAssetOncePerCall('audio/forward.mp3');
        break;
      case 15:
        _playAssetOncePerCall('audio/backwards.mp3');
        break;
      case 20:
        _playAssetOncePerCall('audio/forward.mp3');
        break;
      case 25:
        _playAssetOncePerCall('audio/backwards.mp3');
        break;
      case 30:
        _playAssetOncePerCall('audio/forward.mp3');
        break;
      case 35:
        _playAssetOncePerCall('audio/right.mp3');
        break;
      case 40:
        _playAssetOncePerCall('audio/left.mp3');
        break;
      case 45:
        _playAssetOncePerCall('audio/right.mp3');
        break;
      case 50:
        _playAssetOncePerCall('audio/left.mp3');
        break;
      case 55:
        _playAssetOncePerCall('audio/right.mp3');
        break;
      default:
        break;
    }
  }

  void _enterFight({required bool playBellStart}) {
    if (playBellStart) {
      _playAssetOncePerCall('audio/bell.mp3');
    }
    setState(() {
      phase = 'fight';
      timeLeft = _roundDuration;
      running = false;
    });
  }

  void _enterRest() {
    setState(() {
      phase = 'rest';
      timeLeft = _restDuration;
      running = false;
    });
  }
  void _startFromTutorial() {
    _enterFight(playBellStart: true);
    setState(() {
      _showTutorial = false;
      currentRound = 1;
    });
    _start();
  }
  void _start() {
    _timer?.cancel();
    setState(() => running = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (timeLeft <= 0) {
        _onTimerEnd();
        return;
      }

      final elapsed = _roundDuration - timeLeft;
      _maybePlayInstructionAudio(elapsed);

      final next = timeLeft - 1;
      setState(() => timeLeft = next);
      if (next <= 0) _onTimerEnd();
    });
  }
  void _pause() {
    _timer?.cancel();
    setState(() => running = false);
  }
  void _toggle() {
    if (phase == 'done') return;
    running ? _pause() : _start();
  }
  void _reset() {
    _timer?.cancel();
    setState(() {
      _showTutorial = true;
      _tutorialIndex = 0;
      running = false;
      currentRound = 1;
      phase = 'fight';
      timeLeft = _roundDuration;
    });
    _audioPlayer.stop();
  }
  void _skipRoundPart() {
    _timer?.cancel();
    if (phase == 'fight') {
      _playAssetOncePerCall('audio/bell.mp3');
      final finishing = currentRound >= _totalRounds;
      setState(() {
        running = false;
        phase = finishing ? 'done' : 'rest';
        timeLeft = finishing ? 0 : _restDuration;
      });
      if (!finishing) _start();
      return;
    }

    if (phase == 'rest') {
      _playAssetOncePerCall('audio/bell.mp3');
      setState(() {
        running = false;
        currentRound++;
        phase = 'fight';
        timeLeft = _roundDuration;
      });
      _start();
    }
  }
  void _onTimerEnd() {
    _timer?.cancel();
    if (phase == 'fight') {
      _playAssetOncePerCall('audio/bell.mp3');
      if (currentRound >= _totalRounds) {
        setState(() {
          running = false;
          phase = 'done';
        });
      } else {
        _enterRest();
        _start();
      }
    } else if (phase == 'rest') {
      currentRound++;
      _enterFight(playBellStart: true);
      _start();
    }
  }
  String get _timeDisplay {
    final m = timeLeft ~/ 60;
    final s = timeLeft % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
  double get _progress {
    final total = phase == 'fight' ? _roundDuration : _restDuration;
    if (phase == 'done' || total == 0) return 0;
    return timeLeft / total;
  }
  String _cueForCurrentSecond() {
    if (phase == 'rest') return 'Rest, breathe, and reset your stance';
    if (phase == 'done') return 'Workout complete!';
    final elapsed = _roundDuration - timeLeft;
    if (elapsed < 10) {
      if (elapsed < 2) return 'Hold your boxing stance';
      if (elapsed < 4) return 'Bend your knees';
      if (elapsed < 6) return 'Tuck your chin';
      if (elapsed < 8) return 'Hands up, elbows in';
      return 'Stay balanced on the balls of your feet';
    }
    if (elapsed < 35) {
      final block = ((elapsed - 10) ~/ 5) % 2;
      return block == 0 ? 'Linear Movement: Move forward' : 'Linear Movement: Move backward';
    }
    final block = ((elapsed - 35) ~/ 5) % 2;
    return block == 0 ? 'Lateral Movement: Move right' : 'Lateral Movement: Move left';
  }
  Widget _buildTutorialView() {
    final step = _steps[_tutorialIndex];
    final isLast = _tutorialIndex == _steps.length - 1;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(step.title, style: AppTheme.headingStyle(30, color: Colors.black)),
                      const SizedBox(height: 14),
                      if (step.imagePath != null) ...[
                        Container(
                          width: double.infinity,
                          height: 260,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F4F4),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0x22000000)),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.asset(
                              step.imagePath!,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Center(
                                child: Text(
                                  'Could not load assets/stance.jpg',
                                  style: TextStyle(color: Colors.black54),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],
                      Text(step.body, style: AppTheme.bodyStyle(16, color: Colors.black87)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  TextButton(
                    onPressed: _startFromTutorial,
                    child: Text(
                      'Skip',
                      style: AppTheme.bodyStyle(15, weight: FontWeight.w700, color: Colors.black),
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      if (isLast) {
                        _startFromTutorial();
                      } else {
                        setState(() => _tutorialIndex++);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(isLast ? 'Begin' : 'Next'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildWorkoutView() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bg2,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: 40 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.text3,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('STANCE + MOVEMENTS', style: AppTheme.headingStyle(28)),
                  Text(
                    phase == 'done'
                        ? 'WORKOUT COMPLETE!'
                        : 'ROUND $currentRound of $_totalRounds - ${phase.toUpperCase()}',
                    style: AppTheme.bodyStyle(13, color: AppColors.text2),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
                  child: const Icon(Icons.close, color: AppColors.text2, size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Rounds:', style: AppTheme.bodyStyle(12, color: AppColors.text2)),
              const SizedBox(width: 8),
              _LockedChip(label: '3'),
              const SizedBox(width: 16),
              Text('Duration:', style: AppTheme.bodyStyle(12, color: AppColors.text2)),
              const SizedBox(width: 8),
              _LockedChip(label: '1 min'),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: CustomPaint(
                    painter: _RingPainter(
                      progress: _progress,
                      isRest: phase == 'rest',
                      isDone: phase == 'done',
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      phase == 'done' ? '0:00' : _timeDisplay,
                      style: AppTheme.headingStyle(52, color: Colors.white),
                    ),
                    Text(
                      phase == 'done' ? 'DONE!' : phase.toUpperCase(),
                      style: AppTheme.bodyStyle(
                        13,
                        weight: FontWeight.w700,
                        color: phase == 'rest' ? AppColors.blue : AppColors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Text(
                  'CURRENT INSTRUCTION',
                  style: AppTheme.bodyStyle(10, weight: FontWeight.w700, color: AppColors.text3),
                ),
                const SizedBox(height: 6),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Text(
                    _cueForCurrentSecond(),
                    key: ValueKey('${phase}_$timeLeft'),
                    style: AppTheme.bodyStyle(15, weight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(child: _CtrlBtn(label: '↺ Reset', onTap: _reset, ghost: true)),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: _CtrlBtn(
                  label: running ? '⏸ Pause' : (phase == 'done' ? '▶ Again' : '▶ Start'),
                  onTap: phase == 'done' ? _reset : _toggle,
                  ghost: false,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: _CtrlBtn(label: 'Skip ▷', onTap: _skipRoundPart, ghost: true)),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_totalRounds, (i) {
              final rNum = i + 1;
              Color col;
              if (rNum < currentRound) {
                col = AppColors.red.withOpacity(0.4);
              } else if (rNum == currentRound) {
                col = AppColors.red;
              } else {
                col = AppColors.bg3;
              }
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: col,
                  shape: BoxShape.circle,
                  border: Border.all(color: rNum == currentRound ? AppColors.red : AppColors.border),
                  boxShadow: rNum == currentRound
                      ? [BoxShadow(color: AppColors.red.withOpacity(0.4), blurRadius: 6)]
                      : null,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: _showTutorial ? _buildTutorialView() : _buildWorkoutView(),
    );
  }
}
class _TutorialStep {
  final String title;
  final String body;
  final String? imagePath;
  const _TutorialStep({required this.title, required this.body, this.imagePath});
}
class _LockedChip extends StatelessWidget {
  final String label;
  const _LockedChip({required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.bg3,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: AppTheme.bodyStyle(13, color: AppColors.text)),
    );
  }
}
class _RingPainter extends CustomPainter {
  final double progress;
  final bool isRest;
  final bool isDone;
  const _RingPainter({required this.progress, required this.isRest, required this.isDone});
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    const strokeWidth = 10.0;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AppColors.bg3
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );
    const startAngle = -pi / 2;
    final sweepAngle = 2 * pi * progress;
    final arcColor = isDone ? AppColors.green : (isRest ? AppColors.blue : AppColors.red);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      Paint()
        ..color = arcColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }
  @override
  bool shouldRepaint(_RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isRest != isRest ||
        oldDelegate.isDone != isDone;
  }
}
class _CtrlBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool ghost;
  const _CtrlBtn({required this.label, required this.onTap, required this.ghost});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: ghost ? AppColors.surface : AppColors.red,
          border: ghost ? Border.all(color: AppColors.border) : null,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTheme.bodyStyle(
              14,
              weight: FontWeight.w700,
              color: ghost ? AppColors.text2 : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}