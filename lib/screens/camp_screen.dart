import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/fight_camp_inputs.dart';
import '../theme/app_theme.dart';

class CampScreen extends StatefulWidget {
  const CampScreen({super.key});

  @override
  State<CampScreen> createState() => _CampScreenState();
}

class _CampScreenState extends State<CampScreen> {
  final FightCampFormState _form = FightCampFormState();
  late final TextEditingController _currentWeightCtrl;
  late final TextEditingController _targetWeightCtrl;

  void _toast(String msg) {
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
    Future.delayed(const Duration(milliseconds: 2800), entry.remove);
  }

  Future<void> _pickFightDate() async {
    final now = DateTime.now();
    final initial = _form.fightDate ?? now.add(const Duration(days: 56));
    final d = await showDatePicker(
      context: context,
      initialDate: initial.isAfter(now) ? initial : now.add(const Duration(days: 1)),
      firstDate: DateTime(now.year, now.month, now.day).add(const Duration(days: 1)),
      lastDate: DateTime(now.year + 3),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.red,
            surface: AppColors.bg2,
            onSurface: AppColors.text,
          ),
        ),
        child: child!,
      ),
    );
    if (d != null) setState(() => _form.fightDate = d);
  }

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final first = DateTime(now.year - 1, now.month, now.day);
    final last = _form.fightDate ?? DateTime(now.year + 3);
    final initial = _form.startDate ?? now;
    final d = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(last) ? initial : last,
      firstDate: first,
      lastDate: last,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.red,
            surface: AppColors.bg2,
            onSurface: AppColors.text,
          ),
        ),
        child: child!,
      ),
    );
    if (d != null) setState(() => _form.startDate = d);
  }

  void _onEquipmentSelect(CampEquipment e, bool selected) {
    setState(() {
      if (e == CampEquipment.none) {
        if (selected) {
          _form.equipment.clear();
          _form.equipment.add(CampEquipment.none);
        } else {
          _form.equipment.remove(CampEquipment.none);
          if (_form.equipment.isEmpty) {
            _form.equipment.add(CampEquipment.none);
          }
        }
        return;
      }
      if (selected) {
        _form.equipment.remove(CampEquipment.none);
        _form.equipment.add(e);
      } else {
        _form.equipment.remove(e);
        if (_form.equipment.isEmpty) {
          _form.equipment.add(CampEquipment.none);
        }
      }
    });
  }

  Future<void> _addInjury() async {
    final entry = await showModalBottomSheet<InjuryEntry?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: _AddInjurySheet(showMessage: _toast),
      ),
    );
    if (!mounted) return;
    if (entry != null) setState(() => _form.injuries.add(entry));
  }

  InputDecoration _fieldDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: AppTheme.bodyStyle(15, color: AppColors.text3),
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      );

  void _submit() {
    final err = validateFightCampForm(_form);
    if (err != null) {
      _toast(err);
      return;
    }
    final payload = buildPayloadIfValid(_form)!;
    debugPrint(payload.toJsonString(pretty: true));

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final json = payload.toJsonString(pretty: true);
        return DraggableScrollableSheet(
          initialChildSize: 0.72,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          builder: (_, scrollCtrl) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.bg2,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.text3,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('CAMP PLAN INPUT', style: AppTheme.headingStyle(24)),
                  const SizedBox(height: 6),
                  Text(
                    'Payload is ready for your model. JSON copied shape matches your schema.',
                    style: AppTheme.bodyStyle(13, color: AppColors.text2),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await Clipboard.setData(ClipboardData(text: json));
                            if (ctx.mounted) Navigator.pop(ctx);
                            _toast('JSON copied to clipboard');
                          },
                          icon: const Icon(Icons.copy, size: 18, color: AppColors.red),
                          label: Text('COPY JSON', style: AppTheme.bodyStyle(13, weight: FontWeight.w700, color: AppColors.red)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.red,
                            side: const BorderSide(color: AppColors.red),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.surfaceH,
                            foregroundColor: AppColors.text,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text('CLOSE', style: AppTheme.headingStyle(15)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.bg3,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: SingleChildScrollView(
                        controller: scrollCtrl,
                        child: SelectableText(
                          json,
                          style: AppTheme.bodyStyle(12, color: AppColors.text2).copyWith(
                            fontFamily: 'monospace',
                            height: 1.35,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  FightCampPayload? get _previewPayload => buildPayloadIfValid(_form);

  @override
  void initState() {
    super.initState();
    _currentWeightCtrl = TextEditingController();
    _targetWeightCtrl = TextEditingController();
    _currentWeightCtrl.addListener(() => _form.currentWeightText = _currentWeightCtrl.text);
    _targetWeightCtrl.addListener(() => _form.targetWeightText = _targetWeightCtrl.text);
    _form.equipment.add(CampEquipment.none);
  }

  @override
  void dispose() {
    _currentWeightCtrl.dispose();
    _targetWeightCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final preview = _previewPayload;

    return Column(
      children: [
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
              Icon(Icons.flag_outlined, color: AppColors.red.withOpacity(0.9), size: 28),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tell us about your camp. We use these inputs to build training, recovery, and week-by-week structure once your model is connected.',
                  style: AppTheme.bodyStyle(13, color: AppColors.text2),
                ),
                const SizedBox(height: 18),
                _SectionCard(
                  title: 'Dates',
                  child: Column(
                    children: [
                      _DateRow(
                        label: 'Fight date',
                        value: _form.fightDate,
                        onTap: _pickFightDate,
                        requiredMark: true,
                      ),
                      const SizedBox(height: 10),
                      _DateRow(
                        label: 'Camp start',
                        value: _form.startDate,
                        onTap: _pickStartDate,
                        requiredMark: true,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Fight date doubles as camp end — no separate end date.',
                        style: AppTheme.bodyStyle(11, color: AppColors.text3),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (preview != null) _DerivedSummaryCard(derived: preview.derived),
                if (preview != null) const SizedBox(height: 12),
                _SectionCard(
                  title: 'Your profile',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Skill (1–10)', style: AppTheme.bodyStyle(12, color: AppColors.text3)),
                      Row(
                        children: [
                          Text('${_form.fighterSkill}',
                              style: AppTheme.headingStyle(28, color: AppColors.red)),
                          Expanded(
                            child: Slider(
                              value: _form.fighterSkill.toDouble(),
                              min: 1,
                              max: 10,
                              divisions: 9,
                              activeColor: AppColors.red,
                              onChanged: (v) => setState(() => _form.fighterSkill = v.round()),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Weight', style: AppTheme.bodyStyle(12, color: AppColors.text3)),
                      const SizedBox(height: 8),
                      SegmentedButton<WeightUnit>(
                        segments: const [
                          ButtonSegment(value: WeightUnit.kg, label: Text('kg')),
                          ButtonSegment(value: WeightUnit.lbs, label: Text('lbs')),
                        ],
                        selected: {_form.weightUnit},
                        onSelectionChanged: (s) =>
                            setState(() => _form.weightUnit = s.first),
                        style: ButtonStyle(
                          foregroundColor:
                              MaterialStateProperty.resolveWith((states) {
                            if (states.contains(MaterialState.selected)) {
                              return AppColors.text;
                            }
                            return AppColors.text2;
                          }),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _currentWeightCtrl,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              style: AppTheme.bodyStyle(16),
                              decoration: _fieldDecoration('Current'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _targetWeightCtrl,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              style: AppTheme.bodyStyle(16),
                              decoration: _fieldDecoration('Target'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Weights are validated against ~1% body weight change per week over your camp.',
                        style: AppTheme.bodyStyle(11, color: AppColors.text3),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _SectionCard(
                  title: 'Injuries & limitations',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_form.injuries.isEmpty)
                        Text(
                          'None added — optional.',
                          style: AppTheme.bodyStyle(13, color: AppColors.text3),
                        )
                        else
                        for (var idx = 0; idx < _form.injuries.length; idx++)
                          _InjuryRow(
                            key: ObjectKey(_form.injuries[idx]),
                            entry: _form.injuries[idx],
                            onRemove: () => setState(() => _form.injuries.removeAt(idx)),
                          ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: _addInjury,
                        icon: const Icon(Icons.add, size: 18, color: AppColors.red),
                        label: Text('ADD ENTRY', style: AppTheme.bodyStyle(13, weight: FontWeight.w700, color: AppColors.red)),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.red.withOpacity(0.5)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _SectionCard(
                  title: 'Opponent',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Style', style: AppTheme.bodyStyle(12, color: AppColors.text3)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: OpponentStyle.values.map((s) {
                          final on = _form.opponentStyle == s;
                          return ChoiceChip(
                            label: Text(s.label),
                            selected: on,
                            onSelected: (v) {
                              if (v) setState(() => _form.opponentStyle = s);
                            },
                            selectedColor: AppColors.red.withOpacity(0.22),
                            labelStyle: AppTheme.bodyStyle(
                              12,
                              weight: FontWeight.w600,
                              color: on ? AppColors.text : AppColors.text2,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),
                      Text('Their level (1–10)', style: AppTheme.bodyStyle(12, color: AppColors.text3)),
                      Row(
                        children: [
                          Text('${_form.opponentSkill}',
                              style: AppTheme.headingStyle(28, color: AppColors.blue)),
                          Expanded(
                            child: Slider(
                              value: _form.opponentSkill.toDouble(),
                              min: 1,
                              max: 10,
                              divisions: 9,
                              activeColor: AppColors.blue,
                              onChanged: (v) => setState(() => _form.opponentSkill = v.round()),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _SectionCard(
                  title: 'Equipment',
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: CampEquipment.values.map((e) {
                      final on = _form.equipment.contains(e);
                      return FilterChip(
                        label: Text(e.label),
                        selected: on,
                        onSelected: (v) => _onEquipmentSelect(e, v),
                        selectedColor: AppColors.blue.withOpacity(0.22),
                        checkmarkColor: AppColors.blue,
                        labelStyle: AppTheme.bodyStyle(
                          12,
                          weight: FontWeight.w600,
                          color: on ? AppColors.text : AppColors.text2,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),
                _SectionCard(
                  title: 'Time available',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hours per day (0.5–6)', style: AppTheme.bodyStyle(12, color: AppColors.text3)),
                      Row(
                        children: [
                          Text(
                            _form.hoursPerDay.toStringAsFixed(
                                _form.hoursPerDay == _form.hoursPerDay.roundToDouble() ? 0 : 1),
                            style: AppTheme.headingStyle(26, color: AppColors.gold),
                          ),
                          Text(' h', style: AppTheme.bodyStyle(14, color: AppColors.text2)),
                          Expanded(
                            child: Slider(
                              value: _form.hoursPerDay.clamp(0.5, 6.0),
                              min: 0.5,
                              max: 6,
                              divisions: 22,
                              activeColor: AppColors.gold,
                              onChanged: (v) => setState(() => _form.hoursPerDay = v),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Days per week (1–7)', style: AppTheme.bodyStyle(12, color: AppColors.text3)),
                      Row(
                        children: [
                          Text('${_form.daysPerWeek}',
                              style: AppTheme.headingStyle(26, color: AppColors.gold)),
                          Expanded(
                            child: Slider(
                              value: _form.daysPerWeek.toDouble(),
                              min: 1,
                              max: 7,
                              divisions: 6,
                              activeColor: AppColors.gold,
                              onChanged: (v) => setState(() => _form.daysPerWeek = v.round()),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text('BUILD CAMP PAYLOAD', style: AppTheme.headingStyle(18, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Owns [TextEditingController]s so they are disposed only when the route removes this
/// widget — not when [showModalBottomSheet]'s future completes (avoids use-after-dispose).
class _AddInjurySheet extends StatefulWidget {
  final void Function(String) showMessage;

  const _AddInjurySheet({required this.showMessage});

  @override
  State<_AddInjurySheet> createState() => _AddInjurySheetState();
}

class _AddInjurySheetState extends State<_AddInjurySheet> {
  late final TextEditingController _typeCtrl;
  late final TextEditingController _restrictCtrl;
  InjurySeverity _severity = InjurySeverity.mild;

  InputDecoration _decoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: AppTheme.bodyStyle(15, color: AppColors.text3),
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      );

  @override
  void initState() {
    super.initState();
    _typeCtrl = TextEditingController();
    _restrictCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _typeCtrl.dispose();
    _restrictCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxH = MediaQuery.sizeOf(context).height * 0.92;
    return Container(
      constraints: BoxConstraints(maxHeight: maxH),
      decoration: const BoxDecoration(
        color: AppColors.bg2,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('ADD LIMITATION', style: AppTheme.headingStyle(22)),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: AppColors.text2),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Describe injury or limitation and any restrictions.',
                style: AppTheme.bodyStyle(13, color: AppColors.text2),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _typeCtrl,
                style: AppTheme.bodyStyle(16),
                decoration: _decoration('Type (e.g. knee injury)'),
              ),
              const SizedBox(height: 12),
              Text('Severity', style: AppTheme.bodyStyle(12, color: AppColors.text3)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: InjurySeverity.values.map((s) {
                  final on = _severity == s;
                  return FilterChip(
                    label: Text(s.label),
                    selected: on,
                    onSelected: (_) => setState(() => _severity = s),
                    selectedColor: AppColors.red.withOpacity(0.25),
                    checkmarkColor: AppColors.red,
                    labelStyle: AppTheme.bodyStyle(13,
                        color: on ? AppColors.text : AppColors.text2),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _restrictCtrl,
                style: AppTheme.bodyStyle(16),
                maxLines: 2,
                decoration: _decoration('Restrictions (comma-separated)'),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final t = _typeCtrl.text.trim();
                    if (t.isEmpty) {
                      widget.showMessage('Enter a short type or label.');
                      return;
                    }
                    final parts = _restrictCtrl.text
                        .split(',')
                        .map((s) => s.trim())
                        .where((s) => s.isNotEmpty)
                        .toList();
                    Navigator.pop(
                      context,
                      InjuryEntry(
                        type: t,
                        severity: _severity,
                        restrictions: parts,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: Text('ADD', style: AppTheme.headingStyle(16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InjuryRow extends StatelessWidget {
  final InjuryEntry entry;
  final VoidCallback onRemove;
  const _InjuryRow({super.key, required this.entry, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bg3,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.type, style: AppTheme.bodyStyle(14, weight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(entry.severity.label, style: AppTheme.bodyStyle(12, color: AppColors.text2)),
                if (entry.restrictions.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    entry.restrictions.join(' • '),
                    style: AppTheme.bodyStyle(12, color: AppColors.text3),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.close, size: 20, color: AppColors.text3),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(), style: AppTheme.bodyStyle(13, weight: FontWeight.w800, color: AppColors.text)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _DateRow extends StatelessWidget {
  final String label;
  final DateTime? value;
  final VoidCallback onTap;
  final bool requiredMark;
  const _DateRow({
    required this.label,
    required this.value,
    required this.onTap,
    this.requiredMark = false,
  });

  String _fmt(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.bg3,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                requiredMark ? '$label *' : label,
                style: AppTheme.bodyStyle(13, weight: FontWeight.w600, color: AppColors.text2),
              ),
            ),
            Text(
              value != null ? _fmt(value!) : 'Select',
              style: AppTheme.bodyStyle(14, weight: FontWeight.w700, color: value != null ? AppColors.text : AppColors.text3),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.red),
          ],
        ),
      ),
    );
  }
}

class _DerivedSummaryCard extends StatelessWidget {
  final FightCampDerived derived;
  const _DerivedSummaryCard({required this.derived});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.blue.withOpacity(0.12), AppColors.purple.withOpacity(0.06)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: AppColors.blue.withOpacity(0.25)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('DERIVED (AUTO)', style: AppTheme.bodyStyle(12, weight: FontWeight.w800, color: AppColors.blue)),
          const SizedBox(height: 10),
          _DerivedLine(
            label: 'Camp length',
            value:
                '${derived.campDurationDays} days (${derived.campDurationWeeks.toStringAsFixed(1)} wks)',
          ),
          _DerivedLine(
            label: 'Weight delta (kg)',
            value: '${derived.weightDeltaKg >= 0 ? '+' : ''}${derived.weightDeltaKg.toStringAsFixed(2)}',
          ),
          _DerivedLine(
            label: 'Implied weekly weight change (kg)',
            value: '${derived.impliedWeeklyWeightRateKg >= 0 ? '+' : ''}${derived.impliedWeeklyWeightRateKg.toStringAsFixed(3)}',
          ),
          _DerivedLine(
            label: 'Max safe total delta (kg, ~1%/wk)',
            value: derived.maxSafeTotalDeltaKg.toStringAsFixed(2),
          ),
          _DerivedLine(
            label: 'Weekly training capacity (h)',
            value: derived.weeklyTrainingHours.toStringAsFixed(1),
          ),
        ],
      ),
    );
  }
}

class _DerivedLine extends StatelessWidget {
  final String label;
  final String value;
  const _DerivedLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(label, style: AppTheme.bodyStyle(12, color: AppColors.text3)),
          ),
          Text(value, style: AppTheme.bodyStyle(12, weight: FontWeight.w700, color: AppColors.text)),
        ],
      ),
    );
  }
}
