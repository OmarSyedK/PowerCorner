import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  String _activeSection = 'gyms';

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
              Text('DISCOVER', style: AppTheme.headingStyle(26)),
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
                child: const Icon(Icons.search, color: AppColors.text2, size: 20),
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
                // Chips
                _ChipRow(
                  chips: const ['Gyms', 'Trainers', 'Gear', 'Events'],
                  keys: const ['gyms', 'trainers', 'gear', 'events'],
                  active: _activeSection,
                  onTap: (k) => setState(() => _activeSection = k),
                ),
                if (_activeSection == 'gyms') _GymsSection(),
                if (_activeSection == 'trainers') _TrainersSection(onBook: _toast),
                if (_activeSection == 'gear') _GearSection(onView: _toast),
                if (_activeSection == 'events') _EventsSection(onRsvp: _toast),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }
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
              child: Text(chips[i],
                  style: AppTheme.bodyStyle(13, weight: FontWeight.w500,
                      color: isActive ? Colors.white : AppColors.text2)),
            ),
          );
        }),
      ),
    );
  }
}

// ─── Gyms ───────────────────────────────────────────
class _GymsSection extends StatelessWidget {
  const _GymsSection();

  @override
  Widget build(BuildContext context) {
    final gyms = [
      (['Sparring', 'Pro Coaches'], "Champion's Den", '⭐ 4.8 · 0.8km · Open Now', const Color(0xFF1A0A0E)),
      (['Beginners', 'Classes'], 'Iron Fist Boxing', '⭐ 4.6 · 1.3km · Open Now', const Color(0xFF0A0A1E)),
      (['Amateur Fights', 'Youth'], 'The Ring Boxing Club', '⭐ 4.5 · 2.1km · Closes 9PM', const Color(0xFF0A1A1A)),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('NEARBY GYMS', style: AppTheme.bodyStyle(15, weight: FontWeight.w700)),
              Text('Map View', style: AppTheme.bodyStyle(13, weight: FontWeight.w600, color: AppColors.red)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            children: gyms.map((g) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 90, height: 80,
                      decoration: BoxDecoration(
                        color: g.$4,
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(15)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(g.$2, style: AppTheme.bodyStyle(14, weight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text(g.$3, style: AppTheme.bodyStyle(12, color: AppColors.text2)),
                            const SizedBox(height: 6),
                            Row(children: g.$1.map((t) => Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(color: AppColors.bg3, borderRadius: BorderRadius.circular(8)),
                                child: Text(t, style: AppTheme.bodyStyle(11, color: AppColors.text3)),
                              ),
                            )).toList()),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }
}

// ─── Trainers ────────────────────────────────────────
class _TrainersSection extends StatelessWidget {
  final void Function(String) onBook;
  const _TrainersSection({required this.onBook});

  @override
  Widget build(BuildContext context) {
    final trainers = [
      ('MC', 'Mike Castillo', 'Head Coach • 18 yrs exp', 'Competition Prep', AppColors.red),
      ('SR', 'Sofia Reyes', 'Strength Coach • 10 yrs exp', 'S&C, Weight Cut', AppColors.purple),
      ('JA', 'James Afolabi', 'Technical Coach • 22 yrs exp', 'Defense, Footwork', AppColors.blue),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
          child: Text('TOP TRAINERS', style: AppTheme.bodyStyle(15, weight: FontWeight.w700)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            children: trainers.map((t) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [t.$5, t.$5.withOpacity(0.6)],
                          begin: Alignment.topLeft, end: Alignment.bottomRight,
                        ),
                      ),
                      child: Center(child: Text(t.$1, style: AppTheme.bodyStyle(16, weight: FontWeight.w700, color: Colors.white))),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(t.$2, style: AppTheme.bodyStyle(14, weight: FontWeight.w700)),
                        Text(t.$3, style: AppTheme.bodyStyle(12, color: AppColors.text2)),
                        Text(t.$4, style: AppTheme.bodyStyle(12, color: AppColors.text3)),
                      ]),
                    ),
                    GestureDetector(
                      onTap: () => onBook('📅 Booking ${t.$2}...'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(color: AppColors.red, borderRadius: BorderRadius.circular(20)),
                        child: Text('Book', style: AppTheme.bodyStyle(13, weight: FontWeight.w700, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }
}

// ─── Gear ────────────────────────────────────────────
class _GearSection extends StatelessWidget {
  final void Function(String) onView;
  const _GearSection({required this.onView});

  @override
  Widget build(BuildContext context) {
    final gear = [
      ('🥊', 'Pro Training Gloves', '\$89.99'),
      ('👊', 'Hand Wraps 4.5m', '\$12.99'),
      ('🎽', 'Elite Boxing Shorts', '\$54.99'),
      ('🏆', 'Leather Speed Bag', '\$119.99'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
          child: Text('SHOP GEAR', style: AppTheme.bodyStyle(15, weight: FontWeight.w700)),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 0.85,
          ),
          itemCount: gear.length,
          itemBuilder: (_, i) {
            final g = gear[i];
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Container(
                    width: 60, height: 60,
                    decoration: BoxDecoration(color: AppColors.bg3, borderRadius: BorderRadius.circular(12)),
                    child: Center(child: Text(g.$1, style: const TextStyle(fontSize: 32))),
                  ),
                  const SizedBox(height: 10),
                  Text(g.$2, style: AppTheme.bodyStyle(13, weight: FontWeight.w600), textAlign: TextAlign.center),
                  const SizedBox(height: 4),
                  Text(g.$3, style: AppTheme.bodyStyle(14, weight: FontWeight.w700, color: AppColors.red)),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => onView('🛒 Opening product...'),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceH,
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(child: Text('View', style: AppTheme.bodyStyle(13, weight: FontWeight.w600, color: AppColors.text2))),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

// ─── Events ───────────────────────────────────────────
class _EventsSection extends StatelessWidget {
  final void Function(String) onRsvp;
  const _EventsSection({required this.onRsvp});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
          child: Text('UPCOMING EVENTS', style: AppTheme.bodyStyle(15, weight: FontWeight.w700)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            children: [
              _EventCard(
                month: 'MAR', day: '28',
                name: 'Amateur Night – City Arena',
                meta: '8 Bouts • Tickets from \$25',
                isFeatured: false,
                onRsvp: () => onRsvp('🎟️ RSVP saved!'),
              ),
              const SizedBox(height: 10),
              _EventCard(
                month: 'APR', day: '2',
                name: 'Regional Championship',
                meta: 'Junior & Senior Divisions',
                isFeatured: false,
                onRsvp: () => onRsvp('🎟️ RSVP saved!'),
              ),
              const SizedBox(height: 10),
              _EventCard(
                month: 'APR', day: '5',
                name: '🥊 YOUR FIGHT NIGHT',
                meta: 'vs. Marcus Rivera • Main Event',
                isFeatured: true,
                onRsvp: null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EventCard extends StatelessWidget {
  final String month, day, name, meta;
  final bool isFeatured;
  final VoidCallback? onRsvp;
  const _EventCard({
    required this.month, required this.day, required this.name,
    required this.meta, required this.isFeatured, required this.onRsvp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isFeatured ? AppColors.red.withOpacity(0.07) : AppColors.surface,
        border: Border.all(color: isFeatured ? AppColors.red.withOpacity(0.35) : AppColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: isFeatured ? AppColors.red.withOpacity(0.2) : AppColors.bg3,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(month, style: AppTheme.bodyStyle(9, weight: FontWeight.w700, color: AppColors.text3)),
                Text(day, style: AppTheme.headingStyle(18)),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: AppTheme.bodyStyle(14, weight: FontWeight.w700)),
              Text(meta, style: AppTheme.bodyStyle(12, color: AppColors.text2)),
            ]),
          ),
          if (onRsvp != null)
            GestureDetector(
              onTap: onRsvp,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceH,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('RSVP', style: AppTheme.bodyStyle(12, weight: FontWeight.w600, color: AppColors.text2)),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('YOUR FIGHT', style: AppTheme.bodyStyle(10, weight: FontWeight.w700, color: AppColors.red)),
            ),
        ],
      ),
    );
  }
}


