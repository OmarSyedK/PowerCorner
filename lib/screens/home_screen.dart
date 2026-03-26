import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'main_shell.dart';
import 'shadow_boxing_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> _aiTips = [
    "Keep your guard up on your jab. Focus on snapping back to protect your chin today.",
    "Work on your footwork today. Pivot off the jab and create angles.",
    "Stay sharp — breathe out with every punch. Don't hold your breath.",
    "Jab sets everything up. Don't neglect it — throw it with purpose.",
    "Defense wins fights. Practice slipping and rolling after combos.",
    "Head movement is your best friend. Make yourself a hard target.",
    "Cut weight steadily — 0.5–0.8 kg/week is the safe zone.",
    "Recovery is training too. Ice, sleep, and nutrition matter as much as sparring.",
    "Visualise your game plan before every session — mentally rehearse each combo.",
    "Track your punches. Volume in training = confidence on fight night.",
  ];

  late int _tipIdx;

  @override
  void initState() {
    super.initState();
    _tipIdx = DateTime.now().millisecond % _aiTips.length;
    // Rotate tip every 30s
    Future.delayed(const Duration(seconds: 30), _rotateTip);
  }

  void _rotateTip() {
    if (!mounted) return;
    setState(() => _tipIdx = (_tipIdx + 1) % _aiTips.length);
    Future.delayed(const Duration(seconds: 30), _rotateTip);
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h >= 5 && h < 12) return 'Good morning';
    if (h >= 12 && h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  void _openShadowBoxing() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ShadowBoxingSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _AppHeader(
          onNotif: () => _showToast(context, '🔔 No new notifications'),
        ),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeroBanner(greeting: _greeting()),
                const SizedBox(height: 6),
                _SectionHeader(title: 'Quick Start'),
                _QuickStartGrid(onShadowBoxing: _openShadowBoxing),
                _SectionHeader(title: "Today's Plan"),
                _TodayPlan(onShadowBoxing: _openShadowBoxing),
                _AiTipCard(tip: _aiTips[_tipIdx]),
                _SectionHeader(title: 'Weekly Progress'),
                const _WeeklyBars(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── AppHeader ──────────────────────────────────────
class _AppHeader extends StatelessWidget {
  final VoidCallback onNotif;
  const _AppHeader({required this.onNotif});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60 + MediaQuery.of(context).padding.top,
      padding: EdgeInsets.only(
        left: 18, right: 18, top: MediaQuery.of(context).padding.top,
      ),
      decoration: BoxDecoration(
        color: AppColors.bg.withOpacity(0.9),
        border: const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RichText(
            text: TextSpan(children: [
              TextSpan(
                text: 'POWER',
                style: AppTheme.headingStyle(22, color: AppColors.text),
              ),
              TextSpan(
                text: 'CORNER',
                style: AppTheme.headingStyle(22, color: AppColors.red),
              ),
            ]),
          ),
          GestureDetector(
            onTap: onNotif,
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: Stack(
                children: [
                  const Center(child: Icon(Icons.notifications_outlined, color: AppColors.text2, size: 20)),
                  Positioned(
                    right: 7, top: 7,
                    child: Container(
                      width: 7, height: 7,
                      decoration: BoxDecoration(
                        color: AppColors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.bg, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Hero Banner ─────────────────────────────────────
class _HeroBanner extends StatelessWidget {
  final String greeting;
  const _HeroBanner({required this.greeting});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background photo
          Image.asset(
            'assets/hero_banner.png',
            fit: BoxFit.cover,
            alignment: Alignment.center,
            errorBuilder: (_, __, ___) => Container(color: const Color(0xFF1A0A0E)),
          ),
          // Scrim: dark gradient so text is always readable
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
                colors: [Color(0x22000000), Color(0xDD060608)],
                stops: [0.0, 0.65],
              ),
            ),
          ),
          // Second scrim: bottom fade to background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0xF2060608)],
                stops: [0.4, 1.0],
              ),
            ),
          ),
          // Text overlay
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.max,
              children: [
                RichText(
                  text: TextSpan(
                    text: '$greeting, ',
                    style: AppTheme.bodyStyle(13, color: Colors.white70),
                    children: [
                      TextSpan(
                        text: 'Champion 🥊',
                        style: AppTheme.bodyStyle(13, weight: FontWeight.w700, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                RichText(
                  text: TextSpan(children: [
                    TextSpan(text: 'READY TO\n', style: AppTheme.headingStyle(36, color: Colors.white)),
                    TextSpan(text: 'TRAIN?', style: AppTheme.headingStyle(36, color: AppColors.red)),
                  ]),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _HeroStat(val: '14', lbl: 'Day Streak')),
                    Container(width: 1, height: 26, color: Colors.white24),
                    Expanded(child: _HeroStat(val: '6', lbl: 'Sessions This Week')),
                    Container(width: 1, height: 26, color: Colors.white24),
                    Expanded(child: _HeroStat(val: '87%', lbl: 'Camp Progress')),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String val;
  final String lbl;
  const _HeroStat({required this.val, required this.lbl});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(val, style: AppTheme.headingStyle(22, color: Colors.white)),
        const SizedBox(height: 2),
        Text(lbl, style: AppTheme.bodyStyle(10, color: Colors.white54), textAlign: TextAlign.center),
      ],
    );
  }
}

// ─── Quick Start Grid ─────────────────────────────────
class _QuickStartGrid extends StatelessWidget {
  final VoidCallback onShadowBoxing;
  const _QuickStartGrid({required this.onShadowBoxing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.5,
        children: [
          _QSCard(
            emoji: '🥊', label: 'Shadow Boxing', sub: 'Start Now',
            gradient: [AppColors.red.withOpacity(0.25), AppColors.red.withOpacity(0.08)],
            borderColor: AppColors.red.withOpacity(0.3),
            onTap: () {
              MainShell.of(context)?.switchTab(1);
              Future.delayed(const Duration(milliseconds: 200), onShadowBoxing);
            },
          ),
          _QSCard(
            emoji: '💪', label: 'Workout', sub: 'Upper Body',
            gradient: [AppColors.surface, AppColors.surface],
            borderColor: AppColors.border,
            onTap: () => MainShell.of(context)?.switchTab(1),
          ),
          _QSCard(
            emoji: '🏕️', label: 'Fight Camp', sub: 'Day 18/42',
            gradient: [AppColors.blue.withOpacity(0.2), AppColors.blue.withOpacity(0.06)],
            borderColor: AppColors.blue.withOpacity(0.25),
            onTap: () => MainShell.of(context)?.switchTab(2),
          ),
          _QSCard(
            emoji: '⚖️', label: 'Weight Cut', sub: '-1.4kg to go',
            gradient: [AppColors.purple.withOpacity(0.2), AppColors.purple.withOpacity(0.06)],
            borderColor: AppColors.purple.withOpacity(0.25),
            onTap: () => MainShell.of(context)?.switchTab(2),
          ),
        ],
      ),
    );
  }
}

class _QSCard extends StatelessWidget {
  final String emoji, label, sub;
  final List<Color> gradient;
  final Color borderColor;
  final VoidCallback onTap;
  const _QSCard({
    required this.emoji, required this.label, required this.sub,
    required this.gradient, required this.borderColor, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 4),
            Text(label, style: AppTheme.bodyStyle(13, weight: FontWeight.w700, color: AppColors.text)),
            Text(sub, style: AppTheme.bodyStyle(11, color: AppColors.text2)),
          ],
        ),
      ),
    );
  }
}

// ─── Today's Plan ─────────────────────────────────────
class _TodayPlan extends StatelessWidget {
  final VoidCallback onShadowBoxing;
  const _TodayPlan({required this.onShadowBoxing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        children: [
          _PlanCard(
            emoji: '✓', title: 'Morning Run', meta: '5km • Cardio • Done',
            badgeColor: AppColors.green.withOpacity(0.15),
            badgeText: 'Done', badgeTextColor: AppColors.green,
            done: true,
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onShadowBoxing,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.red.withOpacity(0.07),
                border: Border.all(color: AppColors.red.withOpacity(0.35)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const _PulsingEmoji(),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Shadow Boxing', style: AppTheme.bodyStyle(14, weight: FontWeight.w600)),
                        Text('6 Rounds • 3 min each', style: AppTheme.bodyStyle(12, color: AppColors.text2)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('Start', style: AppTheme.bodyStyle(11, weight: FontWeight.w700, color: AppColors.red)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          _PlanCard(
            emoji: '🏋️', title: 'Strength Circuit', meta: '45 min • Core & Legs',
            badgeColor: AppColors.surface,
            badgeText: 'Later', badgeTextColor: AppColors.text3,
            done: false,
          ),
        ],
      ),
    );
  }
}

class _PulsingEmoji extends StatefulWidget {
  const _PulsingEmoji();

  @override
  State<_PulsingEmoji> createState() => _PulsingEmojiState();
}

class _PulsingEmojiState extends State<_PulsingEmoji> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
    _anim = Tween<double>(begin: 1.0, end: 1.2).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _anim,
      child: const Text('🥊', style: TextStyle(fontSize: 22)),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String emoji, title, meta;
  final Color badgeColor, badgeTextColor;
  final String badgeText;
  final bool done;
  const _PlanCard({
    required this.emoji, required this.title, required this.meta,
    required this.badgeColor, required this.badgeText, required this.badgeTextColor,
    required this.done,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: done ? 0.5 : 1.0,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            SizedBox(width: 36, child: Text(emoji, style: const TextStyle(fontSize: 20), textAlign: TextAlign.center)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: AppTheme.bodyStyle(14, weight: FontWeight.w600)),
                Text(meta, style: AppTheme.bodyStyle(12, color: AppColors.text2)),
              ]),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(20)),
              child: Text(badgeText, style: AppTheme.bodyStyle(11, weight: FontWeight.w700, color: badgeTextColor)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── AI Tip ─────────────────────────────────────────
class _AiTipCard extends StatelessWidget {
  final String tip;
  const _AiTipCard({required this.tip});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 12, 18, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.blue.withOpacity(0.1), AppColors.blue.withOpacity(0.04)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        border: Border.all(color: AppColors.blue.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🤖', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI COACH TIP', style: AppTheme.bodyStyle(10, weight: FontWeight.w700, color: AppColors.blue)),
                const SizedBox(height: 4),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(tip, key: ValueKey(tip), style: AppTheme.bodyStyle(13), maxLines: 4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Weekly Bars ─────────────────────────────────────
class _WeeklyBars extends StatelessWidget {
  const _WeeklyBars();

  @override
  Widget build(BuildContext context) {
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final fills = [1.0, 1.0, 1.0, 0.75, 0.5, 0.0, 0.0];
    final today = 5; // Saturday index

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (i) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _DayBar(
                label: days[i],
                fill: fills[i],
                isToday: i == today,
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _DayBar extends StatefulWidget {
  final String label;
  final double fill;
  final bool isToday;
  const _DayBar({required this.label, required this.fill, required this.isToday});

  @override
  State<_DayBar> createState() => _DayBarState();
}

class _DayBarState extends State<_DayBar> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _anim = CurvedAnimation(parent: _ctrl, curve: const Cubic(0.22, 1, 0.36, 1));
    Future.delayed(
      Duration(milliseconds: 100 + (300 * widget.fill).toInt()),
      () { if (mounted) _ctrl.forward(); },
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 52,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: widget.isToday ? Border.all(color: AppColors.red.withOpacity(0.5)) : null,
            borderRadius: BorderRadius.circular(6),
          ),
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.antiAlias,
          child: AnimatedBuilder(
            animation: _anim,
            builder: (_, __) => FractionallySizedBox(
              heightFactor: _anim.value * widget.fill,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.red.withOpacity(0.4 + 0.6 * widget.fill),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          widget.label,
          style: AppTheme.bodyStyle(
            11,
            color: widget.isToday ? AppColors.red : AppColors.text3,
            weight: widget.isToday ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

// ─── Section Header ─────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  const _SectionHeader({required this.title, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title.toUpperCase(),
              style: AppTheme.bodyStyle(15, weight: FontWeight.w700, color: AppColors.text)),
          if (actionLabel != null)
            GestureDetector(
              onTap: onAction,
              child: Text(actionLabel!, style: AppTheme.bodyStyle(13, weight: FontWeight.w600, color: AppColors.red)),
            ),
        ],
      ),
    );
  }
}

void _showToast(BuildContext context, String msg) {
  final overlay = Overlay.of(context);
  final entry = OverlayEntry(
    builder: (_) => Positioned(
      bottom: 90,
      left: 24,
      right: 24,
      child: _ToastWidget(message: msg),
    ),
  );
  overlay.insert(entry);
  Future.delayed(const Duration(milliseconds: 2200), entry.remove);
}

class _ToastWidget extends StatelessWidget {
  final String message;
  const _ToastWidget({required this.message});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xF01E1E28),
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(message, style: AppTheme.bodyStyle(14, weight: FontWeight.w500)),
        ),
      ),
    );
  }
}
