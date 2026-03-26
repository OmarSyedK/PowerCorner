import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/storage.dart';

class CampScreen extends StatefulWidget {
  const CampScreen({super.key});

  @override
  State<CampScreen> createState() => _CampScreenState();
}

class _CampScreenState extends State<CampScreen> {
  List<double> _weightLogs = [73.8, 73.2, 72.8, 72.4];
  final double _target = 71.0;
  final TextEditingController _weightCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadWeights();
  }

  @override
  void dispose() {
    _weightCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadWeights() async {
    final logs = await Storage.getWeightLogs();
    if (mounted) setState(() => _weightLogs = logs);
  }

  Future<void> _saveWeight() async {
    final val = double.tryParse(_weightCtrl.text);
    if (val == null || val < 40 || val > 200) {
      _showToast('⚠️ Enter a valid weight (40–200 kg)');
      return;
    }
    final updated = [..._weightLogs, val];
    final trimmed = updated.length > 8 ? updated.sublist(updated.length - 8) : updated;
    await Storage.saveWeightLogs(trimmed);
    _weightCtrl.clear();
    if (!mounted) return;
    Navigator.pop(context);
    setState(() => _weightLogs = trimmed);
    _showToast('✓ Weight logged: ${val}kg');
  }

  void _showWeightModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.bg2,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 28,
            bottom: 48 + MediaQuery.of(context).padding.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 34, height: 34,
                    decoration: BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
                    child: const Icon(Icons.close, color: AppColors.text2, size: 16),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text('LOG WEIGHT', style: AppTheme.headingStyle(26)),
              const SizedBox(height: 6),
              Text('Enter your weight for today.', style: AppTheme.bodyStyle(13, color: AppColors.text2)),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _weightCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      autofocus: true,
                      style: bebasNeueStyle(18),
                      decoration: InputDecoration(
                        hintText: '72.4',
                        hintStyle: AppTheme.bodyStyle(18, color: AppColors.text3),
                        filled: true,
                        fillColor: AppColors.bg3,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.red),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('kg', style: AppTheme.bodyStyle(16, weight: FontWeight.w600, color: AppColors.text2)),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveWeight,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  child: Text('SAVE WEIGHT', style: AppTheme.headingStyle(16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // helper workaround to get Bebas style without import conflict
  TextStyle bebasNeueStyle(double size) =>
      AppTheme.headingStyle(size, color: AppColors.text);

  void _showToast(String msg) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (_) => Positioned(
        bottom: 90, left: 24, right: 24,
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xF01E1E28),
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(msg, style: AppTheme.bodyStyle(14, weight: FontWeight.w500)),
            ),
          ),
        ),
      ),
    );
    overlay.insert(entry);
    Future.delayed(const Duration(milliseconds: 2500), entry.remove);
  }

  double get _current => _weightLogs.isEmpty ? 72.4 : _weightLogs.last;
  double get _diff => _current - _target;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          height: 60 + MediaQuery.of(context).padding.top,
          padding: EdgeInsets.only(left: 18, right: 18, top: MediaQuery.of(context).padding.top),
          decoration: BoxDecoration(
            color: AppColors.bg.withOpacity(0.9),
            border: const Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('FIGHT CAMP', style: AppTheme.headingStyle(26, color: AppColors.text)),
              GestureDetector(
                onTap: () => _showToast('📡 Camp sync active'),
                child: Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
                  child: const Icon(Icons.wifi, color: AppColors.text2, size: 18),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // Camp header card
                _CampHeaderCard(),
                _CampProgressCard(),
                // Weight cut
                _SectionLabel('Weight Cut Tracker'),
                _WeightCutCard(
                  current: _current,
                  target: _target,
                  diff: _diff,
                  logs: _weightLogs,
                  onLog: _showWeightModal,
                ),
                // Schedule
                _SectionLabel("Today's Schedule"),
                _ScheduleList(),
                // Nutrition
                _SectionLabel("Today's Nutrition"),
                _NutritionCard(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(text.toUpperCase(),
            style: AppTheme.bodyStyle(15, weight: FontWeight.w700, color: AppColors.text)),
      ),
    );
  }
}

class _CampHeaderCard extends StatelessWidget {
  const _CampHeaderCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 14, 18, 4),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.red.withOpacity(0.15), AppColors.red.withOpacity(0.04)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        border: Border.all(color: AppColors.red.withOpacity(0.25)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('FIGHT NIGHT PREP', style: AppTheme.headingStyle(22)),
              const SizedBox(height: 4),
              Text('42-Day Camp • Fight Date: Apr 5, 2026',
                  style: AppTheme.bodyStyle(12, color: AppColors.text2)),
              const SizedBox(height: 4),
              Text('vs. Marcus "The Bull" Rivera',
                  style: AppTheme.bodyStyle(13, weight: FontWeight.w600, color: AppColors.red)),
            ],
          ),
          Column(
            children: [
              Text('18', style: AppTheme.headingStyle(48, color: AppColors.red)),
              Text('DAY', style: AppTheme.bodyStyle(11, weight: FontWeight.w700, color: AppColors.text2)),
            ],
          ),
        ],
      ),
    );
  }
}

class _CampProgressCard extends StatelessWidget {
  const _CampProgressCard();

  @override
  Widget build(BuildContext context) {
    final phases = [
      (true, 'Foundation'),
      (true, 'Build'),
      (false, 'Peak'),
      (false, 'Taper'),
    ];
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 4, 18, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Camp Progress', style: AppTheme.bodyStyle(13, color: AppColors.text2)),
              Text('Day 18/42', style: AppTheme.bodyStyle(13, weight: FontWeight.w700, color: AppColors.red)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: 18 / 42,
              backgroundColor: AppColors.bg3,
              valueColor: const AlwaysStoppedAnimation(AppColors.red),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: phases.map((p) => Expanded(
              child: Column(
                children: [
                  Container(
                    width: 10, height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: p.$1 ? AppColors.red : AppColors.bg3,
                      border: Border.all(color: p.$1 ? AppColors.red : AppColors.border),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(p.$2,
                      style: AppTheme.bodyStyle(11,
                          color: p.$1 ? AppColors.text2 : AppColors.text3),
                      textAlign: TextAlign.center),
                ],
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }
}

class _WeightCutCard extends StatelessWidget {
  final double current, target, diff;
  final List<double> logs;
  final VoidCallback onLog;
  const _WeightCutCard({
    required this.current, required this.target, required this.diff,
    required this.logs, required this.onLog,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _WeightStat(label: 'Current', value: '${current.toStringAsFixed(1)}kg', color: AppColors.text),
              Text('→', style: AppTheme.bodyStyle(18, color: AppColors.text3)),
              _WeightStat(label: 'Target', value: '${target.toStringAsFixed(1)}kg', color: AppColors.red),
              Text('→', style: AppTheme.bodyStyle(18, color: AppColors.text3)),
              _WeightStat(label: 'Fight Day', value: 'Apr 5', color: AppColors.text),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.red.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  diff > 0 ? '-${diff.toStringAsFixed(1)} kg to cut'
                      : diff < 0 ? '+${(-diff).toStringAsFixed(1)} kg over target'
                      : '✓ On target!',
                  style: AppTheme.bodyStyle(12, weight: FontWeight.w700, color: AppColors.red),
                ),
              ),
              const SizedBox(width: 10),
              Text('35 days left', style: AppTheme.bodyStyle(12, color: AppColors.text3)),
            ],
          ),
          const SizedBox(height: 12),
          // Mini chart
          if (logs.length >= 2)
            SizedBox(
              height: 60,
              child: CustomPaint(
                size: const Size(double.infinity, 60),
                painter: _WeightChartPainter(logs: logs.length > 6 ? logs.sublist(logs.length - 6) : logs),
              ),
            ),
          const SizedBox(height: 4),
          Text(
            logs.take(4).map((w) => w.toStringAsFixed(1)).join(' → '),
            style: AppTheme.bodyStyle(11, color: AppColors.text3),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: onLog,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.red.withOpacity(0.12),
                border: Border.all(color: AppColors.red.withOpacity(0.25)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text('+ Log Today\'s Weight',
                    style: AppTheme.bodyStyle(14, weight: FontWeight.w700, color: AppColors.red)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeightStat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _WeightStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: AppTheme.bodyStyle(11, color: AppColors.text3)),
        const SizedBox(height: 4),
        Text(value, style: AppTheme.headingStyle(22, color: color)),
      ],
    );
  }
}

class _WeightChartPainter extends CustomPainter {
  final List<double> logs;
  const _WeightChartPainter({required this.logs});

  @override
  void paint(Canvas canvas, Size size) {
    if (logs.length < 2) return;
    final max = logs.reduce((a, b) => a > b ? a : b);
    final min = logs.reduce((a, b) => a < b ? a : b);
    final range = (max - min).abs() < 0.01 ? 1.0 : max - min;
    final pad = 10.0;

    final points = <Offset>[];
    for (int i = 0; i < logs.length; i++) {
      final x = (i / (logs.length - 1)) * (size.width - pad * 2) + pad;
      final y = size.height - pad - ((logs[i] - min) / range) * (size.height - pad * 2);
      points.add(Offset(x, y));
    }

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) path.lineTo(p.dx, p.dy);

    canvas.drawPath(path, Paint()
      ..color = AppColors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round);

    canvas.drawCircle(points.last, 5, Paint()..color = AppColors.red);
  }

  @override
  bool shouldRepaint(_WeightChartPainter old) => old.logs != logs;
}

class _ScheduleList extends StatelessWidget {
  const _ScheduleList();

  @override
  Widget build(BuildContext context) {
    final items = [
      (true, false, '6:00 AM', 'Morning Run – 8km', 'Zone 2 Cardio • Completed'),
      (false, true, '10:00 AM', 'Technical Sparring', '6 Rounds • Head Coach'),
      (false, false, '2:00 PM', 'Strength & Conditioning', '45 min • Core Focus'),
      (false, false, '8:00 PM', 'Recovery & Nutrition', 'Ice Bath + Meal Prep'),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        children: items.map((item) {
          final done = item.$1;
          final current = item.$2;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: current ? AppColors.red.withOpacity(0.05) : AppColors.surface,
              border: Border.all(
                color: current ? AppColors.red.withOpacity(0.3) : AppColors.border,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Opacity(
              opacity: done ? 0.5 : 1.0,
              child: Row(
                children: [
                  SizedBox(
                    width: 60,
                    child: Text(item.$3, style: AppTheme.bodyStyle(12, weight: FontWeight.w600, color: AppColors.text3)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(item.$4, style: AppTheme.bodyStyle(14, weight: FontWeight.w600)),
                      Text(item.$5, style: AppTheme.bodyStyle(12, color: AppColors.text2)),
                    ]),
                  ),
                  _StatusDot(done: done, current: current),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _StatusDot extends StatefulWidget {
  final bool done, current;
  const _StatusDot({required this.done, required this.current});

  @override
  State<_StatusDot> createState() => _StatusDotState();
}

class _StatusDotState extends State<_StatusDot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _anim = Tween<double>(begin: 0, end: 6).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    if (widget.current) _ctrl.repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.done) {
      return Container(width: 10, height: 10, decoration: const BoxDecoration(color: AppColors.green, shape: BoxShape.circle));
    }
    if (widget.current) {
      return AnimatedBuilder(
        animation: _anim,
        builder: (_, __) => Container(
          width: 10, height: 10,
          decoration: BoxDecoration(
            color: AppColors.red,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: AppColors.red.withOpacity(0.5), blurRadius: _anim.value, spreadRadius: _anim.value / 2)],
          ),
        ),
      );
    }
    return Container(
      width: 10, height: 10,
      decoration: BoxDecoration(color: AppColors.bg3, shape: BoxShape.circle, border: Border.all(color: AppColors.border)),
    );
  }
}

class _NutritionCard extends StatelessWidget {
  const _NutritionCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Macro rings
          Row(
            children: [
              _MacroRing(label: 'Protein', value: '148g', progress: 0.70, color: AppColors.red),
              const SizedBox(width: 12),
              _MacroRing(label: 'Carbs', value: '210g', progress: 0.50, color: AppColors.blue),
              const SizedBox(width: 12),
              _MacroRing(label: 'Fats', value: '62g', progress: 0.25, color: AppColors.gold),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Calories', style: AppTheme.bodyStyle(11, color: AppColors.text3)),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(children: [
                    TextSpan(text: '1980 ', style: AppTheme.headingStyle(26)),
                    TextSpan(text: '/ 2400', style: AppTheme.headingStyle(16, color: AppColors.text3)),
                  ]),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: 1980 / 2400,
                    backgroundColor: AppColors.bg3,
                    valueColor: const AlwaysStoppedAnimation(AppColors.gold),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MacroRing extends StatelessWidget {
  final String label, value;
  final double progress;
  final Color color;
  const _MacroRing({required this.label, required this.value, required this.progress, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 56, height: 56,
          child: CustomPaint(
            painter: _DonutPainter(progress: progress, color: color),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: AppTheme.bodyStyle(10, color: AppColors.text2)),
        Text(value, style: AppTheme.bodyStyle(11, weight: FontWeight.w700)),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  final double progress;
  final Color color;
  const _DonutPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    const strokeWidth = 7.0;
    const startAngle = -3.14159 / 2;

    canvas.drawCircle(center, radius, Paint()
      ..color = AppColors.bg3
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle, 2 * 3.14159 * progress, false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_DonutPainter old) => old.progress != progress;
}
