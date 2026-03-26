import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/storage.dart';
import 'main_shell.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _step = 1;
  String? _selectedGoal;

  void _nextStep(int step) => setState(() => _step = step);

  void _selectGoal(String goal) {
    setState(() => _selectedGoal = goal);
  }

  Future<void> _finish() async {
    await Storage.setOnboarded(_selectedGoal ?? 'fitness');
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
              ).animate(anim),
              child: child,
            ),
          ),
          child: _buildStep(key: ValueKey(_step)),
        ),
      ),
    );
  }

  Widget _buildStep({required Key key}) {
    switch (_step) {
      case 1:
        return _StepWelcome(key: key, onNext: () => _nextStep(2), onSkip: _finish);
      case 2:
        return _StepGoal(
          key: key,
          selectedGoal: _selectedGoal,
          onSelect: _selectGoal,
          onNext: () => _nextStep(3),
        );
      case 3:
        return _StepReady(key: key, onEnter: _finish);
      default:
        return _StepWelcome(key: key, onNext: () => _nextStep(2), onSkip: _finish);
    }
  }
}

class _StepWelcome extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onSkip;
  const _StepWelcome({required this.onNext, required this.onSkip, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🥊', style: TextStyle(fontSize: 80)),
          const SizedBox(height: 24),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'POWER',
                  style: AppTheme.headingStyle(42, color: AppColors.text),
                ),
                TextSpan(
                  text: 'CORNER',
                  style: AppTheme.headingStyle(42, color: AppColors.red),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your all-in-one boxing companion —\nfrom home workouts to fight day.',
            style: AppTheme.bodyStyle(15, color: AppColors.text2),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          _ObButton(label: 'GET STARTED', onTap: onNext),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onSkip,
            child: Text(
              'Skip intro',
              style: AppTheme.bodyStyle(13, color: AppColors.text3),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepGoal extends StatelessWidget {
  final String? selectedGoal;
  final ValueChanged<String> onSelect;
  final VoidCallback onNext;
  const _StepGoal({
    required this.selectedGoal,
    required this.onSelect,
    required this.onNext,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final goals = [
      ('fitness', '🏋️', 'Fitness Boxing', 'Get fit, burn calories, stay sharp'),
      ('amateur', '🥊', 'Amateur Competitor', 'Train for fights, track camp progress'),
      ('pro', '🏆', 'Pro Fighter', 'Elite prep — weight cuts, fight camps, sparring'),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(children: [
              TextSpan(
                text: "WHAT'S YOUR ",
                style: AppTheme.headingStyle(32, color: AppColors.text),
              ),
              TextSpan(
                text: 'GOAL?',
                style: AppTheme.headingStyle(32, color: AppColors.red),
              ),
            ]),
          ),
          const SizedBox(height: 8),
          Text(
            "Pick your primary focus — we'll personalise your experience.",
            style: AppTheme.bodyStyle(14, color: AppColors.text2),
          ),
          const SizedBox(height: 24),
          ...goals.map((g) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _GoalCard(
                  icon: g.$1,
                  emoji: g.$2,
                  title: g.$3,
                  desc: g.$4,
                  selected: selectedGoal == g.$1,
                  onTap: () => onSelect(g.$1),
                ),
              )),
          const SizedBox(height: 24),
          Opacity(
            opacity: selectedGoal != null ? 1.0 : 0.4,
            child: AbsorbPointer(
              absorbing: selectedGoal == null,
              child: _ObButton(label: 'CONTINUE', onTap: onNext),
            ),
          ),
          const SizedBox(height: 16),
          _StepDots(currentStep: 2, totalSteps: 3),
        ],
      ),
    );
  }
}

class _StepReady extends StatelessWidget {
  final VoidCallback onEnter;
  const _StepReady({required this.onEnter, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 80)),
          const SizedBox(height: 24),
          RichText(
            text: TextSpan(children: [
              TextSpan(
                text: "YOU'RE ",
                style: AppTheme.headingStyle(36, color: AppColors.text),
              ),
              TextSpan(
                text: 'READY.',
                style: AppTheme.headingStyle(36, color: AppColors.red),
              ),
            ]),
          ),
          const SizedBox(height: 12),
          Text(
            'Your corner is set up.\nTrain hard. Fight smart. Win.',
            style: AppTheme.bodyStyle(15, color: AppColors.text2),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          _ObButton(label: 'ENTER THE GYM', onTap: onEnter),
          const SizedBox(height: 16),
          _StepDots(currentStep: 3, totalSteps: 3),
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final String icon;
  final String emoji;
  final String title;
  final String desc;
  final bool selected;
  final VoidCallback onTap;
  const _GoalCard({
    required this.icon,
    required this.emoji,
    required this.title,
    required this.desc,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.red.withOpacity(0.1)
              : AppColors.surface,
          border: Border.all(
            color: selected ? AppColors.red : AppColors.border,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTheme.bodyStyle(15,
                          weight: FontWeight.w700, color: AppColors.text)),
                  const SizedBox(height: 2),
                  Text(desc,
                      style: AppTheme.bodyStyle(12, color: AppColors.text2)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ObButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _ObButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: Text(label, style: AppTheme.headingStyle(18, color: Colors.white)),
      ),
    );
  }
}

class _StepDots extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  const _StepDots({required this.currentStep, required this.totalSteps});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (i) {
        final active = i + 1 == currentStep;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? AppColors.red : AppColors.bg3,
            border: Border.all(color: active ? AppColors.red : AppColors.border),
          ),
        );
      }),
    );
  }
}
