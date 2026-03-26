import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'shadow_boxing_screen.dart';
import '../workouts/stance_movement_workout_sheet.dart';

class TrainScreen extends StatefulWidget {
  const TrainScreen({super.key});

  @override
  State<TrainScreen> createState() => _TrainScreenState();
}

class _TrainScreenState extends State<TrainScreen> {
  String _activeFilter = 'all';

  final _workouts = [
    _WorkoutData('🥊', 'Southpaw Shredder', 'Shadow Boxing • 4 Rounds', 'Beginner', '20 min', 'shadow', true),
    _WorkoutData('💪', "Puncher's Power", 'Strength • Upper Body', 'Advanced', '45 min', 'strength', false),
    _WorkoutData('🏃', 'Road Work Sprint', 'Cardio • Outdoor', 'Intermediate', '35 min', 'cardio', false),
    _WorkoutData('⚡', 'Rapid Fire Combos', 'Combo Drills • 3 Rounds', 'Intermediate', '15 min', 'combo', true),
    _WorkoutData('🏋️', 'Core Destroyer', 'Strength • Core & Legs', 'Advanced', '50 min', 'strength', false),
    _WorkoutData('🎯', 'Precision Drills', 'Shadow Boxing • Focus Mitts', 'Advanced', '40 min', 'shadow', true),
    _WorkoutData('🧍', 'Stance + Movements', 'Footwork Fundamentals', 'Beginner', '12 min', 'beginner', true),
    _WorkoutData('👊', 'Basic Punches', 'Jab • Cross • Hooks', 'Beginner', '15 min', 'beginner', true),
    _WorkoutData('🥋', '2 Punch Combinations', 'Pad Drills • 2-Count', 'Beginner', '14 min', 'beginner', true),
    _WorkoutData('🔥', '3 Punch Combinations', 'Bag Work • 3-Count', 'Beginner', '18 min', 'beginner', true),
  ];

  void _openShadowBoxing() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ShadowBoxingSheet(),
    );
  }

  void _openStanceAndMovements() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.96,
        child: const StanceMovementWorkoutSheet(),
      ),
    );
  }

  void _showToast(String msg) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (_) => Positioned(
        bottom: 90,
        left: 24,
        right: 24,
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
    Future.delayed(const Duration(milliseconds: 2200), entry.remove);
  }

  @override
  Widget build(BuildContext context) {
    final visible = _workouts.where(
      (w) => _activeFilter == 'all' || w.cat == _activeFilter,
    ).toList();

    return Column(
      children: [
        // Header
        Container(
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
              Text('TRAIN', style: AppTheme.headingStyle(26, color: AppColors.text)),
              GestureDetector(
                onTap: _openShadowBoxing,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('▶  Start Session',
                      style: AppTheme.bodyStyle(13, weight: FontWeight.w600, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category chips
                _ChipRow(
                  chips: const ['All', 'Beginner', 'Shadow Boxing', 'Strength', 'Cardio', 'Combos'],
                  keys: const ['all', 'beginner', 'shadow', 'strength', 'cardio', 'combo'],
                  active: _activeFilter,
                  onTap: (k) => setState(() => _activeFilter = k),
                ),
                // Featured
                if (_activeFilter == 'all' || _activeFilter == 'shadow')
                  _FeaturedWorkout(onStart: _openShadowBoxing),
                // Section header
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
                  child: Text('WORKOUTS', style: AppTheme.bodyStyle(15, weight: FontWeight.w700)),
                ),
                // Workout list
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Column(
                    children: visible.map((w) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _WorkoutCard(
                        data: w,
                        onTap: w.title == 'Stance + Movements'
                            ? _openStanceAndMovements
                            : (w.usesSb
                                ? _openShadowBoxing
                                : () => _showToast('Starting ${w.title}...')),
                      ),
                    )).toList(),
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _WorkoutData {
  final String emoji, title, meta, level, duration, cat;
  final bool usesSb;
  const _WorkoutData(this.emoji, this.title, this.meta, this.level, this.duration, this.cat, this.usesSb);
}

class _ChipRow extends StatelessWidget {
  final List<String> chips, keys;
  final String active;
  final ValueChanged<String> onTap;
  const _ChipRow({required this.chips, required this.keys, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
      child: Row(
        children: List.generate(chips.length, (i) {
          final isActive = keys[i] == active;
          return GestureDetector(
            onTap: () => onTap(keys[i]),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              decoration: BoxDecoration(
                color: isActive ? AppColors.red : AppColors.surface,
                border: Border.all(color: isActive ? AppColors.red : AppColors.border),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                chips[i],
                style: AppTheme.bodyStyle(13, weight: FontWeight.w500,
                    color: isActive ? Colors.white : AppColors.text2),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _FeaturedWorkout extends StatelessWidget {
  final VoidCallback onStart;
  const _FeaturedWorkout({required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A0A0E), Color(0xFF200D0F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: AppColors.red.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30, top: -30,
            child: Container(
              width: 120, height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.red.withOpacity(0.12),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('🔥 Featured', style: AppTheme.bodyStyle(11, weight: FontWeight.w700, color: AppColors.red)),
              const SizedBox(height: 6),
              Text('CHAMPIONSHIP PREP', style: AppTheme.headingStyle(28, color: Colors.white)),
              const SizedBox(height: 4),
              Text('Shadow Boxing • 6 Rounds • Intermediate',
                  style: AppTheme.bodyStyle(13, color: AppColors.text2)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text('🕐 30 min  ', style: AppTheme.bodyStyle(13, color: AppColors.text2)),
                  Text('🔥 420 cal  ', style: AppTheme.bodyStyle(13, color: AppColors.text2)),
                  Text('⭐ 4.9', style: AppTheme.bodyStyle(13, color: AppColors.text2)),
                ],
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: onStart,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.red,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Text('Start Workout',
                      style: AppTheme.bodyStyle(14, weight: FontWeight.w700, color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WorkoutCard extends StatelessWidget {
  final _WorkoutData data;
  final VoidCallback onTap;
  const _WorkoutCard({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: AppColors.bg3, borderRadius: BorderRadius.circular(12)),
            child: Center(child: Text(data.emoji, style: const TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.title, style: AppTheme.bodyStyle(14, weight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(data.meta, style: AppTheme.bodyStyle(12, color: AppColors.text2)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _Tag(data.level),
                    const SizedBox(width: 6),
                    _Tag(data.duration),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: AppColors.red, shape: BoxShape.circle),
              child: const Center(child: Text('▶', style: TextStyle(color: Colors.white, fontSize: 14))),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  const _Tag(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: AppColors.bg3, borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: AppTheme.bodyStyle(11, color: AppColors.text3)),
    );
  }
}
