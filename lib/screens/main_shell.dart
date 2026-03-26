import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/storage.dart';
import 'home_screen.dart';
import 'train_screen.dart';
import 'camp_screen.dart';
import 'discover_screen.dart';
import 'profile_screen.dart';
import 'onboarding_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => MainShellState();

  static MainShellState? of(BuildContext context) =>
      context.findAncestorStateOfType<MainShellState>();
}

class MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  void switchTab(int index) => setState(() => _currentIndex = index);

  final List<Widget> _screens = [
    const HomeScreen(),
    const TrainScreen(),
    const CampScreen(),
    const DiscoverScreen(),
    const ProfileScreen(),
  ];

  Future<void> resetOnboarding() async {
    await Storage.clearOnboarding();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const OnboardingScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          // Mesh background gradient
          Positioned.fill(
            child: CustomPaint(painter: _MeshPainter()),
          ),
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
        ],
      ),
      bottomNavigationBar: _PowerCornerNavBar(
        currentIndex: _currentIndex,
        onTap: switchTab,
      ),
    );
  }
}

class _PowerCornerNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _PowerCornerNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72 + MediaQuery.of(context).padding.bottom,
      decoration: BoxDecoration(
        color: AppColors.bg.withOpacity(0.95),
        border: const Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: Icons.home_outlined,
              label: 'Home',
              active: currentIndex == 0,
              onTap: () => onTap(0),
            ),
            _NavItem(
              icon: Icons.fitness_center_outlined,
              label: 'Train',
              active: currentIndex == 1,
              onTap: () => onTap(1),
            ),
            // FAB center button
            GestureDetector(
              onTap: () => onTap(1),
              child: Container(
                width: 54,
                height: 54,
                margin: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.red, Color(0xFFC1121F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.red.withOpacity(0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('🥊', style: TextStyle(fontSize: 24)),
                ),
              ),
            ),
            _NavItem(
              icon: Icons.explore_outlined,
              label: 'Discover',
              active: currentIndex == 3,
              onTap: () => onTap(3),
            ),
            _NavItem(
              icon: Icons.person_outline,
              label: 'Profile',
              active: currentIndex == 4,
              onTap: () => onTap(4),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.red : AppColors.text3;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(label, style: AppTheme.bodyStyle(10, weight: FontWeight.w500, color: color)),
          ],
        ),
      ),
    );
  }
}

class _MeshPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    // Red top-right glow
    final redGradient = RadialGradient(
      center: const Alignment(0.6, -0.7),
      radius: 0.8,
      colors: [
        AppColors.red.withOpacity(0.08),
        Colors.transparent,
      ],
    );
    paint.shader = redGradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Blue bottom-left glow
    final blueGradient = RadialGradient(
      center: const Alignment(-0.8, 0.7),
      radius: 0.7,
      colors: [
        AppColors.blue.withOpacity(0.06),
        Colors.transparent,
      ],
    );
    paint.shader = blueGradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(_MeshPainter oldDelegate) => false;
}
