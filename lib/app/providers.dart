import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../audio/cue_player.dart';
import '../data/database.dart';
import '../timer/workout.dart';

/// Overridden in main with the real player, and in tests with a silent one.
final cuePlayerProvider = Provider<CuePlayer>(
  (ref) => throw UnimplementedError('cuePlayerProvider must be overridden'),
);

/// Overridden in tests with an in-memory database.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final sessionsProvider = StreamProvider<List<StoredSession>>(
  (ref) => ref.watch(databaseProvider).watchSessions(),
);

final savedWorkoutsProvider = StreamProvider<List<(String, Workout)>>(
  (ref) => ref.watch(databaseProvider).watchWorkouts(),
);

/// The workout the home screen will start, edited live by the builder.
final workoutProvider = NotifierProvider<WorkoutNotifier, Workout>(
  WorkoutNotifier.new,
);

class WorkoutNotifier extends Notifier<Workout> {
  @override
  Workout build() => Workout.presets.first;

  void set(Workout workout) => state = workout;
}
