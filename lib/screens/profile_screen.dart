import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/storage.dart';
import 'main_shell.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, bool> _settings = {
    'notifications': true,
    'audio': true,
    'offline': false,
  };

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final s = await Storage.getSettings();
    if (mounted) setState(() => _settings = s);
  }

  Future<void> _toggleSetting(String key) async {
    setState(() => _settings[key] = !(_settings[key] ?? false));
    await Storage.saveSettings(_settings);
    _toast(_settings[key]! ? '✓ Setting enabled' : 'Setting disabled');
  }

  void _toast(String msg) {
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
    Future.delayed(const Duration(milliseconds: 2200), entry.remove);
  }

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
              Text('PROFILE', style: AppTheme.headingStyle(26)),
              GestureDetector(
                onTap: () => _toast('⚙️ Settings'),
                child: Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
                  child: const Icon(Icons.settings_outlined, color: AppColors.text2, size: 18),
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
                // Profile hero
                _ProfileHero(),
                // Stats grid
                _StatsGrid(),
                // Achievements
                _SectionLabel('Achievements'),
                _Achievements(),
                // Gear bag
                _SectionLabel2(text: 'My Gear Bag', actionLabel: '+ Add', onAction: () => _toast('➕ Add gear feature coming soon')),
                _GearBag(),
                // Settings
                _SectionLabel('Settings'),
                _SettingsPanel(
                  settings: _settings,
                  onToggle: _toggleSetting,
                  onShare: () => _toast('📊 Stats sharing coming soon'),
                  onRedo: () => MainShell.of(context)?.resetOnboarding(),
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

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(text.toUpperCase(), style: AppTheme.bodyStyle(15, weight: FontWeight.w700)),
      ),
    );
  }
}

class _SectionLabel2 extends StatelessWidget {
  final String text, actionLabel;
  final VoidCallback onAction;
  const _SectionLabel2({required this.text, required this.actionLabel, required this.onAction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(text.toUpperCase(), style: AppTheme.bodyStyle(15, weight: FontWeight.w700)),
          GestureDetector(
            onTap: onAction,
            child: Text(actionLabel, style: AppTheme.bodyStyle(13, weight: FontWeight.w600, color: AppColors.red)),
          ),
        ],
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 14, 18, 0),
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppColors.red, Color(0xFFC1121F)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(color: AppColors.red.withOpacity(0.3), blurRadius: 12, spreadRadius: 2),
              ],
            ),
            child: const Center(child: Text('🥊', style: TextStyle(fontSize: 36))),
          ),
          const SizedBox(height: 12),
          Text('Alex "Thunder" Johnson', style: AppTheme.headingStyle(22)),
          const SizedBox(height: 4),
          Text('Amateur Boxer • Welterweight (71kg)',
              style: AppTheme.bodyStyle(13, color: AppColors.text2)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _RecordStat(num: '12', label: 'WINS', color: AppColors.text),
              const SizedBox(width: 16),
              _RecordStat(num: '3', label: 'LOSSES', color: AppColors.red),
              const SizedBox(width: 16),
              _RecordStat(num: '1', label: 'DRAWS', color: AppColors.text),
              const SizedBox(width: 16),
              _RecordStat(num: '8', label: 'KOs', color: AppColors.gold),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecordStat extends StatelessWidget {
  final String num, label;
  final Color color;
  const _RecordStat({required this.num, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(num, style: AppTheme.headingStyle(24, color: color)),
        Text(label, style: AppTheme.bodyStyle(10, weight: FontWeight.w700, color: AppColors.text3)),
      ],
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid();

  @override
  Widget build(BuildContext context) {
    final tiles = [
      ('🔥', '14', 'Day Streak'),
      ('⏱️', '48h', 'Total Training'),
      ('👊', '6.2k', 'Punches Logged'),
      ('🏆', 'Gold', 'Fighter Rank'),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.3,
        children: tiles.map((t) => Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(t.$1, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 4),
              Text(t.$2, style: AppTheme.headingStyle(22)),
              Text(t.$3, style: AppTheme.bodyStyle(10, color: AppColors.text3), textAlign: TextAlign.center),
            ],
          ),
        )).toList(),
      ),
    );
  }
}

class _Achievements extends StatelessWidget {
  const _Achievements();

  @override
  Widget build(BuildContext context) {
    final achs = [
      (true, '🔥', 'On Fire'),
      (true, '💯', '100 Sessions'),
      (true, '⚡', 'Speed Demon'),
      (false, '🏅', 'Iron Will'),
      (false, '👑', 'Champion'),
    ];
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        children: achs.map((a) => Opacity(
          opacity: a.$1 ? 1.0 : 0.35,
          child: Container(
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(
                color: a.$1 ? AppColors.gold.withOpacity(0.3) : AppColors.border,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(a.$2, style: const TextStyle(fontSize: 26)),
                const SizedBox(height: 6),
                Text(a.$3, style: AppTheme.bodyStyle(11, weight: FontWeight.w600, color: AppColors.text2), textAlign: TextAlign.center),
              ],
            ),
          ),
        )).toList(),
      ),
    );
  }
}

class _GearBag extends StatelessWidget {
  const _GearBag();

  @override
  Widget build(BuildContext context) {
    final gear = [
      ('🥊', 'Cleto Reyes Training Gloves', '16oz • 42 sessions', true),
      ('👟', 'Adidas AdiSpeed Boots', 'Size 10.5 • 28 sessions', true),
      ('🦺', 'Body Protector', '15 sessions', false),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        children: gear.map((g) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Text(g.$1, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(g.$2, style: AppTheme.bodyStyle(14, weight: FontWeight.w600)),
                    Text(g.$3, style: AppTheme.bodyStyle(12, color: AppColors.text2)),
                  ],
                )),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: g.$4 ? AppColors.green.withOpacity(0.15) : AppColors.gold.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    g.$4 ? 'Good' : 'Replace Soon',
                    style: AppTheme.bodyStyle(11, weight: FontWeight.w700,
                        color: g.$4 ? AppColors.green : AppColors.gold),
                  ),
                ),
              ],
            ),
          ),
        )).toList(),
      ),
    );
  }
}

class _SettingsPanel extends StatelessWidget {
  final Map<String, bool> settings;
  final Future<void> Function(String) onToggle;
  final VoidCallback onShare;
  final VoidCallback? onRedo;
  const _SettingsPanel({
    required this.settings, required this.onToggle,
    required this.onShare, required this.onRedo,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            _ToggleRow(
              label: '🔔 Notifications',
              value: settings['notifications'] ?? true,
              onTap: () => onToggle('notifications'),
            ),
            _Divider(),
            _ToggleRow(
              label: '🎵 Audio Cues',
              value: settings['audio'] ?? true,
              onTap: () => onToggle('audio'),
            ),
            _Divider(),
            _ToggleRow(
              label: '📴 Offline Mode',
              value: settings['offline'] ?? false,
              onTap: () => onToggle('offline'),
            ),
            _Divider(),
            _InfoRow(label: '🌍 Units', value: 'Metric (kg)'),
            _Divider(),
            _ActionRow(label: '📊 Share Stats', onTap: onShare),
            _Divider(),
            _ActionRow(label: '🔄 Redo Onboarding', onTap: onRedo ?? () {}),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, color: AppColors.border, indent: 0);
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final VoidCallback onTap;
  const _ToggleRow({required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTheme.bodyStyle(14, weight: FontWeight.w500)),
          GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 46, height: 26,
              decoration: BoxDecoration(
                color: value ? AppColors.red.withOpacity(0.3) : AppColors.bg3,
                border: Border.all(color: value ? AppColors.red.withOpacity(0.4) : AppColors.border),
                borderRadius: BorderRadius.circular(13),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 250),
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.all(3),
                  child: Container(
                    width: 18, height: 18,
                    decoration: BoxDecoration(
                      color: value ? AppColors.red : AppColors.text3,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTheme.bodyStyle(14, weight: FontWeight.w500)),
          Text(value, style: AppTheme.bodyStyle(13, color: AppColors.text2)),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _ActionRow({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTheme.bodyStyle(14, weight: FontWeight.w500)),
            Text('›', style: AppTheme.bodyStyle(18, color: AppColors.text2)),
          ],
        ),
      ),
    );
  }
}
