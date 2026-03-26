import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

const _combos = [
  '1-2 (Jab, Cross)',
  '1-2-3 (Jab, Cross, Hook)',
  '1-2-3-2 (Jab, Cross, Hook, Cross)',
  '1-1-2 (Double Jab, Cross)',
  '2-3-2 (Cross, Hook, Cross)',
  '1-2-Body (Jab, Cross, Body Shot)',
  '3-2-3 (Hook, Cross, Hook)',
  '1-2-3-4 (Jab, Cross, Hook, Uppercut)',
  '2-3-4 (Cross, Hook, Uppercut)',
  '1-2-5-2 (Jab, Cross, Uppercut, Cross)',
  '6-3-2 (Lead Uppercut, Hook, Cross)',
  '1-2-3 Body-3 Head (Jab, Cross, Body Hook, Head Hook)',
];

class ShadowBoxingSheet extends StatefulWidget {
  const ShadowBoxingSheet({super.key});

  @override
  State<ShadowBoxingSheet> createState() => _ShadowBoxingSheetState();
}

class _ShadowBoxingSheetState extends State<ShadowBoxingSheet> {
  int totalRounds = 6;
  int roundDuration = 180;
  int restDuration = 60;
  int currentRound = 1;
  late int timeLeft;
  String phase = 'fight';
  bool running = false;
  Timer? _timer;
  String currentCombo = _combos[0];

  @override
  void initState() {
    super.initState();
    timeLeft = roundDuration;
    _updateCombo();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateCombo() {
    setState(() {
      currentCombo = _combos[Random().nextInt(_combos.length)];
    });
  }

  void _toggle() {
    running ? _pause() : _start();
  }

  void _start() {
    setState(() => running = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (timeLeft > 0) {
          timeLeft--;
          if (phase == 'fight' && timeLeft > 0 && timeLeft % 30 == 0) {
            _updateCombo();
          }
        } else {
          _onTimerEnd();
        }
      });
    });
  }

  void _pause() {
    _timer?.cancel();
    setState(() => running = false);
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      running = false;
      currentRound = 1;
      timeLeft = roundDuration;
      phase = 'fight';
    });
    _updateCombo();
  }

  void _skip() {
    _timer?.cancel();
    setState(() {
      if (phase == 'fight') {
        if (currentRound >= totalRounds) {
          _endWorkout();
          return;
        }
        phase = 'rest';
        timeLeft = restDuration;
      } else {
        currentRound++;
        phase = 'fight';
        timeLeft = roundDuration;
        _updateCombo();
      }
      running = false;
    });
    _start();
  }

  void _onTimerEnd() {
    _timer?.cancel();
    if (phase == 'fight') {
      if (currentRound >= totalRounds) {
        _endWorkout();
      } else {
        setState(() {
          phase = 'rest';
          timeLeft = restDuration;
        });
        _start();
      }
    } else {
      setState(() {
        currentRound++;
        phase = 'fight';
        timeLeft = roundDuration;
      });
      _updateCombo();
      _start();
    }
  }

  void _endWorkout() {
    _timer?.cancel();
    setState(() {
      running = false;
      phase = 'done';
    });
  }

  String get _timeDisplay {
    final m = timeLeft ~/ 60;
    final s = timeLeft % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  double get _progress {
    final total = phase == 'fight' ? roundDuration : restDuration;
    if (total == 0) return 0;
    return timeLeft / total;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bg2,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 24, right: 24,
        top: 24,
        bottom: 40 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: AppColors.text3,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          // Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('SHADOW BOXING', style: AppTheme.headingStyle(28)),
                  Text(
                    phase == 'done'
                        ? 'WORKOUT COMPLETE!'
                        : 'ROUND $currentRound of $totalRounds — ${phase.toUpperCase()}',
                    style: AppTheme.bodyStyle(13, color: AppColors.text2),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 34, height: 34,
                  decoration: BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
                  child: const Icon(Icons.close, color: AppColors.text2, size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Config row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Rounds:', style: AppTheme.bodyStyle(12, color: AppColors.text2)),
              const SizedBox(width: 8),
              _SelectChip(
                options: const ['3', '6', '8', '12'],
                selected: totalRounds.toString(),
                onSelect: (v) {
                  if (!running) setState(() {
                    totalRounds = int.parse(v);
                    currentRound = 1;
                  });
                },
              ),
              const SizedBox(width: 16),
              Text('Duration:', style: AppTheme.bodyStyle(12, color: AppColors.text2)),
              const SizedBox(width: 8),
              _SelectChip(
                options: const ['2 min', '3 min', '4 min', '5 min'],
                selected: _durationLabel(),
                onSelect: (v) {
                  if (!running) setState(() {
                    roundDuration = _durationFromLabel(v);
                    timeLeft = roundDuration;
                    phase = 'fight';
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Timer ring
          SizedBox(
            width: 200, height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 200, height: 200,
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
                      style: AppTheme.bodyStyle(13, weight: FontWeight.w700,
                          color: phase == 'rest' ? AppColors.blue : AppColors.red),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Combo
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
                Text('CURRENT COMBO',
                    style: AppTheme.bodyStyle(10, weight: FontWeight.w700, color: AppColors.text3)),
                const SizedBox(height: 6),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    currentCombo,
                    key: ValueKey(currentCombo),
                    style: AppTheme.bodyStyle(15, weight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          // Controls
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
          // Round dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(totalRounds, (i) {
              final rNum = i + 1;
              Color col;
              if (rNum < currentRound) col = AppColors.red.withOpacity(0.4);
              else if (rNum == currentRound) col = AppColors.red;
              else col = AppColors.bg3;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8, height: 8,
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

  String _durationLabel() {
    switch (roundDuration) {
      case 120: return '2 min';
      case 180: return '3 min';
      case 240: return '4 min';
      case 300: return '5 min';
      default: return '3 min';
    }
  }

  int _durationFromLabel(String label) {
    switch (label) {
      case '2 min': return 120;
      case '3 min': return 180;
      case '4 min': return 240;
      case '5 min': return 300;
      default: return 180;
    }
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

    // BG ring
    canvas.drawCircle(center, radius,
      Paint()
        ..color = AppColors.bg3
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    // Progress arc
    const startAngle = -pi / 2;
    final sweepAngle = 2 * pi * progress;
    final arcColor = isDone ? AppColors.green : (isRest ? AppColors.blue : AppColors.red);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle, sweepAngle, false,
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

class _SelectChip extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelect;
  const _SelectChip({required this.options, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final val = await showDialog<String>(
          context: context,
          builder: (_) => SimpleDialog(
            backgroundColor: AppColors.bg2,
            children: options.map((o) => SimpleDialogOption(
              onPressed: () => Navigator.pop(context, o),
              child: Text(o, style: AppTheme.bodyStyle(14, color: AppColors.text)),
            )).toList(),
          ),
        );
        if (val != null) onSelect(val);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.bg3,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(selected, style: AppTheme.bodyStyle(13, color: AppColors.text)),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, color: AppColors.text2, size: 18),
          ],
        ),
      ),
    );
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
          child: Text(label,
              style: AppTheme.bodyStyle(14, weight: FontWeight.w700,
                  color: ghost ? AppColors.text2 : Colors.white)),
        ),
      ),
    );
  }
}
