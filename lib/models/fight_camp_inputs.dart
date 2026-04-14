import 'dart:convert';

/// Weight shown in UI; [FightCampPayload] always stores kg for the backend shape.
enum WeightUnit { kg, lbs }

const double _lbsPerKg = 2.2046226218;

double displayWeightToKg(double value, WeightUnit unit) =>
    unit == WeightUnit.kg ? value : value / _lbsPerKg;

double kgToDisplay(double kg, WeightUnit unit) =>
    unit == WeightUnit.kg ? kg : kg * _lbsPerKg;

enum OpponentStyle {
  pressureFighter('pressure_fighter', 'Pressure fighter'),
  counterPuncher('counter_puncher', 'Counter puncher'),
  outboxer('outboxer', 'Outboxer'),
  brawler('brawler', 'Brawler'),
  unknown('unknown', 'Unknown');

  final String apiValue;
  final String label;
  const OpponentStyle(this.apiValue, this.label);
}

enum InjurySeverity {
  mild('mild', 'Mild'),
  moderate('moderate', 'Moderate'),
  severe('severe', 'Severe');

  final String apiValue;
  final String label;
  const InjurySeverity(this.apiValue, this.label);
}

class InjuryEntry {
  final String type;
  final InjurySeverity severity;
  final List<String> restrictions;

  const InjuryEntry({
    required this.type,
    required this.severity,
    required this.restrictions,
  });

  Map<String, dynamic> toJson() => {
        'type': type,
        'severity': severity.apiValue,
        'restrictions': restrictions,
      };
}

enum CampEquipment {
  heavyBag('heavy_bag', 'Heavy bag'),
  doubleEndBag('double_end_bag', 'Double-end bag'),
  speedBag('speed_bag', 'Speed bag'),
  jumpRope('jump_rope', 'Jump rope'),
  weights('weights', 'Weights'),
  boxingRing('boxing_ring', 'Boxing ring'),
  coach('coach', 'Coach'),
  none('none', 'None');

  final String apiValue;
  final String label;
  const CampEquipment(this.apiValue, this.label);
}

/// Raw form state (nullable until user picks dates / optional fields).
class FightCampFormState {
  DateTime? fightDate;
  DateTime? startDate;
  int fighterSkill = 5;
  String currentWeightText = '';
  String targetWeightText = '';
  WeightUnit weightUnit = WeightUnit.kg;
  final List<InjuryEntry> injuries = [];
  OpponentStyle opponentStyle = OpponentStyle.unknown;
  int opponentSkill = 5;
  final Set<CampEquipment> equipment = {};
  double hoursPerDay = 2;
  int daysPerWeek = 5;
}

class FightCampDerived {
  final int campDurationDays;
  final double campDurationWeeks;
  final double currentWeightKg;
  final double targetWeightKg;
  final double weightDeltaKg;
  final double maxSafeTotalDeltaKg;
  final double impliedWeeklyWeightRateKg;
  final double weeklyTrainingHours;

  const FightCampDerived({
    required this.campDurationDays,
    required this.campDurationWeeks,
    required this.currentWeightKg,
    required this.targetWeightKg,
    required this.weightDeltaKg,
    required this.maxSafeTotalDeltaKg,
    required this.impliedWeeklyWeightRateKg,
    required this.weeklyTrainingHours,
  });
}

/// Validated payload matching the suggested backend JSON (weights in kg).
class FightCampPayload {
  final String fightDateIso;
  final String startDateIso;
  final int fighterSkill;
  final double currentWeightKg;
  final double targetWeightKg;
  final String weightUnit;
  final List<InjuryEntry> injuries;
  final OpponentStyle opponentStyle;
  final int opponentSkill;
  final List<String> equipment;
  final double hoursPerDay;
  final int daysPerWeek;
  final FightCampDerived derived;

  const FightCampPayload({
    required this.fightDateIso,
    required this.startDateIso,
    required this.fighterSkill,
    required this.currentWeightKg,
    required this.targetWeightKg,
    required this.weightUnit,
    required this.injuries,
    required this.opponentStyle,
    required this.opponentSkill,
    required this.equipment,
    required this.hoursPerDay,
    required this.daysPerWeek,
    required this.derived,
  });

  Map<String, dynamic> toJson() => {
        'fight_date': fightDateIso,
        'start_date': startDateIso,
        'fighter_profile': {
          'skill_level': fighterSkill,
          'current_weight': currentWeightKg,
          'target_weight': targetWeightKg,
          'weight_unit': weightUnit,
          'injuries': injuries.map((e) => e.toJson()).toList(),
        },
        'opponent_profile': {
          'style': opponentStyle.apiValue,
          'skill_level': opponentSkill,
        },
        'resources': {
          'equipment': equipment,
        },
        'availability': {
          'hours_per_day': hoursPerDay,
          'days_per_week': daysPerWeek,
        },
      };

  String toJsonString({bool pretty = false}) {
    final encoder =
        pretty ? const JsonEncoder.withIndent('  ') : const JsonEncoder();
    return encoder.convert(toJson());
  }
}

String _dateOnlyIso(DateTime d) {
  final y = d.year.toString().padLeft(4, '0');
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '$y-$m-$day';
}

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Returns null if valid; otherwise an error message for the user.
String? validateFightCampForm(FightCampFormState s) {
  final fight = s.fightDate;
  final start = s.startDate;
  if (fight == null) return 'Choose your fight date.';
  if (start == null) return 'Choose your camp start date.';

  final today = _dateOnly(DateTime.now());
  final fightD = _dateOnly(fight);
  final startD = _dateOnly(start);

  if (!fightD.isAfter(today)) {
    return 'Fight date must be in the future (after today).';
  }
  if (startD.isAfter(fightD)) {
    return 'Start date must be on or before fight date.';
  }

  final campDays = fightD.difference(startD).inDays;
  if (campDays < 1) {
    return 'Camp needs at least one full day between start and fight.';
  }

  final current = double.tryParse(s.currentWeightText.replaceAll(',', '.'));
  final target = double.tryParse(s.targetWeightText.replaceAll(',', '.'));
  if (current == null || current <= 0) {
    return 'Enter a valid current weight (greater than 0).';
  }
  if (target == null || target <= 0) {
    return 'Enter a valid target weight (greater than 0).';
  }

  final currentKg = displayWeightToKg(current, s.weightUnit);
  final targetKg = displayWeightToKg(target, s.weightUnit);

  final weeks = campDays / 7.0;
  final maxWeeklyFrac = 0.01;
  final maxTotalDelta = currentKg * maxWeeklyFrac * weeks;
  final deltaKg = (targetKg - currentKg).abs();
  if (deltaKg > maxTotalDelta + 1e-6) {
    return 'Weight change is aggressive for this camp length. '
        'At ~1% body weight per week, you can shift about '
        '${maxTotalDelta.toStringAsFixed(1)} kg over ${weeks.toStringAsFixed(1)} weeks '
        '($campDays days). Adjust dates, weights, or confirm with a coach.';
  }

  if (s.hoursPerDay < 0.5 || s.hoursPerDay > 6) {
    return 'Training time per day must be between 0.5 and 6 hours.';
  }
  if (s.daysPerWeek < 1 || s.daysPerWeek > 7) {
    return 'Training days per week must be between 1 and 7.';
  }

  if (s.fighterSkill < 1 || s.fighterSkill > 10) {
    return 'Your skill level must be between 1 and 10.';
  }
  if (s.opponentSkill < 1 || s.opponentSkill > 10) {
    return 'Opponent skill must be between 1 and 10.';
  }

  return null;
}

FightCampPayload? buildPayloadIfValid(FightCampFormState s) {
  final err = validateFightCampForm(s);
  if (err != null) return null;

  final fightD = _dateOnly(s.fightDate!);
  final startD = _dateOnly(s.startDate!);
  final campDays = fightD.difference(startD).inDays;
  final weeks = campDays / 7.0;

  final current = double.parse(s.currentWeightText.replaceAll(',', '.'));
  final target = double.parse(s.targetWeightText.replaceAll(',', '.'));
  final currentKg = displayWeightToKg(current, s.weightUnit);
  final targetKg = displayWeightToKg(target, s.weightUnit);
  final deltaKg = targetKg - currentKg;
  final maxTotalDelta = currentKg * 0.01 * weeks;
  final impliedWeekly = weeks > 0 ? deltaKg.abs() / weeks : 0.0;

  final equipment = s.equipment.map((e) => e.apiValue).toList()..sort();

  final derived = FightCampDerived(
    campDurationDays: campDays,
    campDurationWeeks: weeks,
    currentWeightKg: currentKg,
    targetWeightKg: targetKg,
    weightDeltaKg: deltaKg,
    maxSafeTotalDeltaKg: maxTotalDelta,
    impliedWeeklyWeightRateKg: impliedWeekly,
    weeklyTrainingHours: s.hoursPerDay * s.daysPerWeek,
  );

  return FightCampPayload(
    fightDateIso: _dateOnlyIso(fightD),
    startDateIso: _dateOnlyIso(startD),
    fighterSkill: s.fighterSkill,
    currentWeightKg: double.parse(currentKg.toStringAsFixed(2)),
    targetWeightKg: double.parse(targetKg.toStringAsFixed(2)),
    weightUnit: s.weightUnit == WeightUnit.kg ? 'kg' : 'lbs',
    injuries: List.unmodifiable(s.injuries),
    opponentStyle: s.opponentStyle,
    opponentSkill: s.opponentSkill,
    equipment: equipment,
    hoursPerDay: s.hoursPerDay,
    daysPerWeek: s.daysPerWeek,
    derived: derived,
  );
}
