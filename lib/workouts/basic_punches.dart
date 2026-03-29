import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:video_player/video_player.dart';
import '../theme/app_theme.dart';
import 'workout_foreground_service.dart';

class BasicPunchesWorkoutSheet extends StatefulWidget {
  const BasicPunchesWorkoutSheet({super.key});

  @override
  State<BasicPunchesWorkoutSheet> createState() =>
      _BasicPunchesWorkoutSheetState();
}

class _BasicPunchesWorkoutSheetState
    extends State<BasicPunchesWorkoutSheet> with WidgetsBindingObserver {
  static const int _totalRounds = 3;
  static const int _roundDuration = 120;
  static const int _restDuration = 20;

  int _tutorialIndex = 0;
  bool _showTutorial = true;

  int currentRound = 1;
  int timeLeft = _roundDuration;
  String phase = 'fight';
  bool running = false;
  DateTime? _phaseEndAt;

  Timer? _timer;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final Random _random = Random();

  String _currentPunch = 'Get Ready';

  /// Weighted punches (Jab appears more often)
  final List<int> _weightedPunches = [
    1, 1, 1, 1, // Jab (high probability)
    2, 2,       // Cross
    3,          // Left Hook
    4,           // Right Hook
    5,          // Left Uppercut
    6           // Right Uppercut
  ];

  final List<_TutorialStep> _steps = const [
    _TutorialStep(
      title: 'Jab \nThe Most Important Punch',
      body: '''
1. While keeping the rest of your body still, extend your lead hand straight. (Lead hand is the hand that is forward)
2. Start the movement from your shoulder. 
3. Snap it back quickly.
4. Keep your other hand up.

The jab is the most basic and important punch at the same time. A great jab sets up everything else.
A jab is used to attack, defend, score points, measure distance to your opponents and set up other punches.
It is highly suggested that every combination should start with a jab.
      ''',
      videoPath: 'assets/video/jab.mp4',
    ),
    _TutorialStep(
      title: 'Cross',
      body: '''
The second straight punch. The Cross is a very powerful punch as it comes from your dominant hand. 

1. Rotate your hips and shoulder forward.
2. Pivot your back foot.
3. Keep your non-throwing hand up.
4. Start the motion from your shoulder and throw your lead hand forward.
      ''',
      videoPath: 'assets/video/cross.mp4',
    ),
    _TutorialStep(
      title: 'Hook',
      body: '''
A strong Hook can be devastating. It can be thrown comfortably using both of your hands.

1. Pivot your feet towards the punch.
2. Bend your arm at 90°.
3. Rotate hips and shoulders.
4. Keep non-throwing hand up.
      ''',
      videoPath: 'assets/video/hook.mp4',
    ),
    _TutorialStep(
      title: 'Uppercut',
      body: '''
The Uppercut is a sneaky punch as it is thrown from an unusual angle. 
It is really good for surprising an opponent however it is ideally to be thrown in close range. It is a devastating punch to throw in the middle or at the end of a combination. 

1. Drop slightly and drive upward.
2. Pivot your legs and hips.
3. Keep your non-thwoing hand up.
      ''',
      imagePath: 'assets/uppercut.jpg',
    ),
    _TutorialStep(
      title: 'Punch Numbers',
      body: '''
1 = Jab  
2 = Cross  
3 = Lead Hook  
4 = Rear Hook
5 = Lead Uppercut
6 = Rear Uppercut 

Listen for the number and throw the punch.
Remember: Odd numbers are for punches with lead hand, even numbers are for punches with rear hand.
Exhale sharply from your nose during each punch
      ''',
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WorkoutForegroundService.ensureInitialized();
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    WorkoutForegroundService.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && running) {
      _syncWithClock();
    }
  }

  void _updateForegroundNotification() {
    if (!running) return;
    WorkoutForegroundService.startOrUpdate(
      title: 'Basic Punches',
      text: 'Round $currentRound/$_totalRounds • ${phase.toUpperCase()} • $_timeDisplay',
    );
  }

  Future<void> _playAudio(String path) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(path));
    } catch (_) {}
  }

  int _getRandomPunch() {
    return _weightedPunches[_random.nextInt(_weightedPunches.length)];
  }

  void _maybeCallPunch(int elapsed) {
    if (phase != 'fight') return;

    if (elapsed > 0 && elapsed % 3 == 0) {
      final punch = _getRandomPunch();
      _playAudio('audio/$punch.mp3');

      setState(() {
        _currentPunch = _labelForPunch(punch);
      });
    }
  }

  String _labelForPunch(int p) {
    switch (p) {
      case 1:
        return 'JAB (1)';
      case 2:
        return 'CROSS (2)';
      case 3:
        return 'LEAD HOOK (3)';
      case 4:
        return 'REAR HOOK (4)';
      case 5:
        return 'LEFT UPPERCUT (5)';
      case 6:
        return 'RIGHT UPPERCUT (6)';
      default:
        return '';
    }
  }

  void _start() {
    _timer?.cancel();
    _phaseEndAt = DateTime.now().add(Duration(seconds: timeLeft));
    setState(() => running = true);
    _updateForegroundNotification();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      _syncWithClock();
    });
  }

  void _syncWithClock() {
    if (_phaseEndAt == null || !running) return;
    final remaining = _phaseEndAt!.difference(DateTime.now()).inSeconds;
    final clamped = remaining < 0 ? 0 : remaining;
    final elapsed = (phase == 'fight' ? _roundDuration : _restDuration) - clamped;
    _maybeCallPunch(elapsed);

    if (clamped <= 0) {
      setState(() => timeLeft = 0);
      _onTimerEnd();
      return;
    }

    if (timeLeft != clamped) {
      setState(() => timeLeft = clamped);
      _updateForegroundNotification();
    }
  }

  void _pause() {
    _timer?.cancel();
    _phaseEndAt = null;
    setState(() => running = false);
    WorkoutForegroundService.stop();
  }

  void _toggle() {
    if (phase == 'done') return;
    running ? _pause() : _start();
  }

  void _reset() {
    _timer?.cancel();
    _audioPlayer.stop();
    _phaseEndAt = null;

    setState(() {
      _showTutorial = true;
      _tutorialIndex = 0;
      running = false;
      currentRound = 1;
      phase = 'fight';
      timeLeft = _roundDuration;
      _currentPunch = 'Get Ready';
    });
    WorkoutForegroundService.stop();
  }

  void _skip() {
    if (phase == 'done') return;
    _timer?.cancel();
    _phaseEndAt = null;

    if (phase == 'fight') {
      _playAudio('audio/bell.mp3');
      if (currentRound >= _totalRounds) {
        setState(() {
          running = false;
          phase = 'done';
          timeLeft = 0;
        });
      } else {
        setState(() {
          running = false;
          phase = 'rest';
          timeLeft = _restDuration;
        });
        _start();
      }
    } else {
      currentRound++;
      _playAudio('audio/bell.mp3');
      setState(() {
        running = false;
        phase = 'fight';
        timeLeft = _roundDuration;
        _currentPunch = 'Get Ready';
      });
      _start();
    }
  }

  void _onTimerEnd() {
    _timer?.cancel();
    _phaseEndAt = null;

    if (phase == 'fight') {
      _playAudio('audio/bell.mp3');

      if (currentRound >= _totalRounds) {
        setState(() {
          phase = 'done';
          running = false;
        });
        WorkoutForegroundService.stop();
      } else {
        setState(() {
          phase = 'rest';
          timeLeft = _restDuration;
        });
        _start();
      }
    } else {
      currentRound++;
      _playAudio('audio/bell.mp3');

      setState(() {
        phase = 'fight';
        timeLeft = _roundDuration;
      });

      _start();
    }
  }

  void _startFromTutorial() {
    setState(() {
      _showTutorial = false;
      currentRound = 1;
      phase = 'fight';
      timeLeft = _roundDuration;
    });

    _playAudio('audio/bell.mp3');
    _start();
  }

  String get _timeDisplay {
    final m = timeLeft ~/ 60;
    final s = timeLeft % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  double get _progress {
    final total = phase == 'fight' ? _roundDuration : _restDuration;
    return total == 0 ? 0 : timeLeft / total;
  }

  Widget _buildTutorialView() {
    final step = _steps[_tutorialIndex];
    final isLast = _tutorialIndex == _steps.length - 1;

    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(step.title,
                          style: AppTheme.headingStyle(28, color: Colors.black)),
                      const SizedBox(height: 16),
                      if (step.videoPath != null)
                        _LoopingVideoPlayer(
                          key: ValueKey(step.videoPath),
                          videoPath: step.videoPath!,
                        )
                      else if (step.imagePath != null)
                        Image.asset(step.imagePath!),
                      const SizedBox(height: 16),
                      Text(step.body,
                          style: AppTheme.bodyStyle(16, color: Colors.black)),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  TextButton(
                      onPressed: _startFromTutorial,
                      child: const Text('Skip')),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      if (isLast) {
                        _startFromTutorial();
                      } else {
                        setState(() => _tutorialIndex++);
                      }
                    },
                    child: Text(isLast ? 'Begin' : 'Next'),
                  )
                ],
              )
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
                  Text('BASIC PUNCHES', style: AppTheme.headingStyle(28)),
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
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                  ),
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
              const _LockedChip(label: '3'),
              const SizedBox(width: 16),
              Text('Duration:', style: AppTheme.bodyStyle(12, color: AppColors.text2)),
              const SizedBox(width: 8),
              const _LockedChip(label: '2 min'),
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
                  'CURRENT PUNCH',
                  style: AppTheme.bodyStyle(10, weight: FontWeight.w700, color: AppColors.text3),
                ),
                const SizedBox(height: 6),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    phase == 'rest'
                        ? 'REST'
                        : phase == 'done'
                            ? 'DONE'
                            : _currentPunch,
                    key: ValueKey('${phase}_${timeLeft}_$_currentPunch'),
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
              Expanded(
                child: _CtrlBtn(label: '↺ Reset', onTap: _reset, ghost: true),
              ),
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
              Expanded(
                child: _CtrlBtn(label: 'Skip ▷', onTap: _skip, ghost: true),
              ),
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
    return _showTutorial ? _buildTutorialView() : _buildWorkoutView();
  }
}

class _TutorialStep {
  final String title;
  final String body;
  final String? imagePath;
  final String? videoPath;

  const _TutorialStep({
    required this.title,
    required this.body,
    this.imagePath,
    this.videoPath,
  });
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
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.isRest != isRest || old.isDone != isDone;
}

class _LoopingVideoPlayer extends StatefulWidget {
  final String videoPath;
  const _LoopingVideoPlayer({
  Key? key,
  required this.videoPath,
    }) : super(key: key);


  @override
  State<_LoopingVideoPlayer> createState() => _LoopingVideoPlayerState();
}

class _LoopingVideoPlayerState extends State<_LoopingVideoPlayer> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.videoPath)
      ..initialize().then((_) {
        setState(() {});
        _controller.setLooping(true);
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          )
        : const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
  }
}
