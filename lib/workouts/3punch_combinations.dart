import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../theme/app_theme.dart';
import 'workout_foreground_service.dart';

class ThreePunchCombinationsWorkoutSheet extends StatefulWidget {
  const ThreePunchCombinationsWorkoutSheet({super.key});

  @override
  State<ThreePunchCombinationsWorkoutSheet> createState() =>
      _ThreePunchCombinationsWorkoutSheetState();
}

class _ThreePunchCombinationsWorkoutSheetState
    extends State<ThreePunchCombinationsWorkoutSheet>
    with WidgetsBindingObserver {
  static const int _totalRounds = 3;
  static const int _roundDuration = 120;
  static const int _restDuration = 60;

  int currentRound = 1;
  int timeLeft = _roundDuration;
  String phase = 'fight';
  bool running = false;
  DateTime? _phaseEndAt;

  Timer? _timer;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final Random _random = Random();

  String _currentPunch = 'Get Ready';

  /// Bumped to cancel in-flight combo audio (reset / pause / dispose).
  int _playbackSession = 0;

  /// Weight per punch number when building a 3-punch combo (jab-heavy).
  final List<int> _weightedPunches = [
    1, 1, 1, 1,
    2, 2,
    3,
    4,
    5,
    6,
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
    _playbackSession++;
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
      title: '3 Punch Combinations',
      text: 'Round $currentRound/$_totalRounds • ${phase.toUpperCase()} • $_timeDisplay',
    );
  }

  Future<void> _playAudio(String path) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(path));
    } catch (_) {}
  }

  int _randomPunchNumber() {
    return _weightedPunches[_random.nextInt(_weightedPunches.length)];
  }

  List<int> _getRandomCombo() {
    return [_randomPunchNumber(), _randomPunchNumber(), _randomPunchNumber()];
  }

  String _labelForCombo(List<int> c) => '${c[0]} · ${c[1]} · ${c[2]}';

  /// Plays `audio/1.mp3` … `audio/6.mp3` back-to-back so one cue sounds like a combo.
  Future<void> _playComboAudio(List<int> combo) async {
    final session = ++_playbackSession;

    for (var i = 0; i < combo.length; i++) {
      if (!mounted || session != _playbackSession) return;

      final p = combo[i];
      final completer = Completer<void>();
      var completeArmed = false;
      late StreamSubscription<void> sub;
      sub = _audioPlayer.onPlayerComplete.listen((_) {
        if (!completeArmed) return;
        completeArmed = false;
        sub.cancel();
        if (!completer.isCompleted) completer.complete();
      });

      try {
        await _audioPlayer.stop();
        completeArmed = true;
        await _audioPlayer.play(AssetSource('audio/$p.mp3'));
        await completer.future.timeout(const Duration(seconds: 5));
      } catch (_) {
        // Asset missing, platform error, or timeout — continue or abort via session
      } finally {
        completeArmed = false;
        await sub.cancel();
      }
    }
  }

  void _maybeCallPunch(int elapsed) {
    if (phase != 'fight') return;

    if (elapsed > 0 && elapsed % 5 == 0) {
      final combo = _getRandomCombo();
      setState(() {
        _currentPunch = _labelForCombo(combo);
      });
      _playComboAudio(combo);
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
    _playbackSession++;
    _audioPlayer.stop();
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
    _playbackSession++;
    _audioPlayer.stop();
    _phaseEndAt = null;

    setState(() {
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

  String get _timeDisplay {
    final m = timeLeft ~/ 60;
    final s = timeLeft % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  double get _progress {
    final total = phase == 'fight' ? _roundDuration : _restDuration;
    return total == 0 ? 0 : timeLeft / total;
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
                  Text('3 PUNCH COMBINATIONS', style: AppTheme.headingStyle(28)),
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
    return _buildWorkoutView();
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
