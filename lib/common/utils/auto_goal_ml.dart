const int _minMl = 500;
const int _maxMl = 5000;
const int _stepMl = 50;
const int _mlPerKg = 35;

int snapDailyGoalMl(int raw) {
  var v = raw.clamp(_minMl, _maxMl);
  final offset = v - _minMl;
  v = _minMl + (offset / _stepMl).round() * _stepMl;
  return v.clamp(_minMl, _maxMl);
}

int goalMlFromWeightKg(int kg) => snapDailyGoalMl(kg * _mlPerKg);

bool hasWeightForAutoGoal(int? weightKg) => weightKg != null && weightKg > 0;

/// Auto-goal is only active when enabled in profile and a usable weight exists.
bool isAutoGoalEnabledForProfile({
  required bool isAutoGoalEnabled,
  required int? weightKg,
}) =>
    isAutoGoalEnabled && hasWeightForAutoGoal(weightKg);
