/// How a rep ends.
enum FinishMode {
  /// The rep ends on its own at the target time. Made for training alone:
  /// the beeps tell the runner whether they are on pace, nothing is measured.
  auto,

  /// A partner taps the screen as the runner crosses the line, which records
  /// the time.
  tap,
}

/// One timed sprint workout: [reps] runs of [distanceM] metres, each with a
/// [targetS] goal time and [restS] seconds of rest between them.
class Workout {
  const Workout({
    required this.name,
    required this.reps,
    required this.distanceM,
    required this.targetS,
    required this.restS,
    this.splitEveryM = 10,
    this.startSignal = true,
    this.finishMode = FinishMode.auto,
  });

  final String name;
  final int reps;
  final int distanceM;
  final double targetS;
  final int restS;

  /// Distance between split beeps. 0 turns split beeps off.
  final int splitEveryM;

  /// Whether each rep starts with "marks, set" and a random hold before go.
  final bool startSignal;

  final FinishMode finishMode;

  int get totalDistanceM => reps * distanceM;

  /// Distances where a split beep sounds, excluding the start and the finish
  /// (the finish has its own cue).
  List<int> get splitDistances {
    if (splitEveryM <= 0) return const [];
    return [for (var d = splitEveryM; d < distanceM; d += splitEveryM) d];
  }

  /// Time into the rep at which the runner should pass [distance] to be on
  /// target pace. Assumes even pace, which is what a pacer beep can promise.
  double targetTimeAt(int distance) => targetS * distance / distanceM;

  Workout copyWith({
    String? name,
    int? reps,
    int? distanceM,
    double? targetS,
    int? restS,
    int? splitEveryM,
    bool? startSignal,
    FinishMode? finishMode,
  }) {
    return Workout(
      name: name ?? this.name,
      reps: reps ?? this.reps,
      distanceM: distanceM ?? this.distanceM,
      targetS: targetS ?? this.targetS,
      restS: restS ?? this.restS,
      splitEveryM: splitEveryM ?? this.splitEveryM,
      startSignal: startSignal ?? this.startSignal,
      finishMode: finishMode ?? this.finishMode,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Workout &&
      other.name == name &&
      other.reps == reps &&
      other.distanceM == distanceM &&
      other.targetS == targetS &&
      other.restS == restS &&
      other.splitEveryM == splitEveryM &&
      other.startSignal == startSignal &&
      other.finishMode == finishMode;

  @override
  int get hashCode => Object.hash(
    name,
    reps,
    distanceM,
    targetS,
    restS,
    splitEveryM,
    startSignal,
    finishMode,
  );

  static const presets = [
    Workout(
      name: 'Acceleration',
      reps: 6,
      distanceM: 30,
      targetS: 4.6,
      restS: 120,
    ),
    Workout(
      name: 'Block starts',
      reps: 8,
      distanceM: 10,
      targetS: 1.9,
      restS: 90,
      splitEveryM: 0,
    ),
    Workout(
      name: 'Beep pacer',
      reps: 4,
      distanceM: 60,
      targetS: 7.8,
      restS: 180,
    ),
    Workout(
      name: 'Tempo 100s',
      reps: 8,
      distanceM: 100,
      targetS: 16,
      restS: 60,
      splitEveryM: 25,
      startSignal: false,
    ),
  ];
}
