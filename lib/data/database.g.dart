// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $SavedWorkoutsTable extends SavedWorkouts
    with TableInfo<$SavedWorkoutsTable, SavedWorkout> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavedWorkoutsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _repsMeta = const VerificationMeta('reps');
  @override
  late final GeneratedColumn<int> reps = GeneratedColumn<int>(
    'reps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _distanceMMeta = const VerificationMeta(
    'distanceM',
  );
  @override
  late final GeneratedColumn<int> distanceM = GeneratedColumn<int>(
    'distance_m',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetSMeta = const VerificationMeta(
    'targetS',
  );
  @override
  late final GeneratedColumn<double> targetS = GeneratedColumn<double>(
    'target_s',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _restSMeta = const VerificationMeta('restS');
  @override
  late final GeneratedColumn<int> restS = GeneratedColumn<int>(
    'rest_s',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _splitEveryMMeta = const VerificationMeta(
    'splitEveryM',
  );
  @override
  late final GeneratedColumn<int> splitEveryM = GeneratedColumn<int>(
    'split_every_m',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startSignalMeta = const VerificationMeta(
    'startSignal',
  );
  @override
  late final GeneratedColumn<bool> startSignal = GeneratedColumn<bool>(
    'start_signal',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("start_signal" IN (0, 1))',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<FinishMode, String> finishMode =
      GeneratedColumn<String>(
        'finish_mode',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<FinishMode>($SavedWorkoutsTable.$converterfinishMode);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    name,
    reps,
    distanceM,
    targetS,
    restS,
    splitEveryM,
    startSignal,
    finishMode,
    id,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'saved_workouts';
  @override
  VerificationContext validateIntegrity(
    Insertable<SavedWorkout> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('reps')) {
      context.handle(
        _repsMeta,
        reps.isAcceptableOrUnknown(data['reps']!, _repsMeta),
      );
    } else if (isInserting) {
      context.missing(_repsMeta);
    }
    if (data.containsKey('distance_m')) {
      context.handle(
        _distanceMMeta,
        distanceM.isAcceptableOrUnknown(data['distance_m']!, _distanceMMeta),
      );
    } else if (isInserting) {
      context.missing(_distanceMMeta);
    }
    if (data.containsKey('target_s')) {
      context.handle(
        _targetSMeta,
        targetS.isAcceptableOrUnknown(data['target_s']!, _targetSMeta),
      );
    } else if (isInserting) {
      context.missing(_targetSMeta);
    }
    if (data.containsKey('rest_s')) {
      context.handle(
        _restSMeta,
        restS.isAcceptableOrUnknown(data['rest_s']!, _restSMeta),
      );
    } else if (isInserting) {
      context.missing(_restSMeta);
    }
    if (data.containsKey('split_every_m')) {
      context.handle(
        _splitEveryMMeta,
        splitEveryM.isAcceptableOrUnknown(
          data['split_every_m']!,
          _splitEveryMMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_splitEveryMMeta);
    }
    if (data.containsKey('start_signal')) {
      context.handle(
        _startSignalMeta,
        startSignal.isAcceptableOrUnknown(
          data['start_signal']!,
          _startSignalMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startSignalMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SavedWorkout map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavedWorkout(
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      reps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reps'],
      )!,
      distanceM: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}distance_m'],
      )!,
      targetS: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_s'],
      )!,
      restS: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rest_s'],
      )!,
      splitEveryM: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}split_every_m'],
      )!,
      startSignal: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}start_signal'],
      )!,
      finishMode: $SavedWorkoutsTable.$converterfinishMode.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}finish_mode'],
        )!,
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SavedWorkoutsTable createAlias(String alias) {
    return $SavedWorkoutsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<FinishMode, String, String> $converterfinishMode =
      const EnumNameConverter<FinishMode>(FinishMode.values);
}

class SavedWorkout extends DataClass implements Insertable<SavedWorkout> {
  final String name;
  final int reps;
  final int distanceM;
  final double targetS;
  final int restS;
  final int splitEveryM;
  final bool startSignal;
  final FinishMode finishMode;
  final String id;
  final DateTime createdAt;
  const SavedWorkout({
    required this.name,
    required this.reps,
    required this.distanceM,
    required this.targetS,
    required this.restS,
    required this.splitEveryM,
    required this.startSignal,
    required this.finishMode,
    required this.id,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['name'] = Variable<String>(name);
    map['reps'] = Variable<int>(reps);
    map['distance_m'] = Variable<int>(distanceM);
    map['target_s'] = Variable<double>(targetS);
    map['rest_s'] = Variable<int>(restS);
    map['split_every_m'] = Variable<int>(splitEveryM);
    map['start_signal'] = Variable<bool>(startSignal);
    {
      map['finish_mode'] = Variable<String>(
        $SavedWorkoutsTable.$converterfinishMode.toSql(finishMode),
      );
    }
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SavedWorkoutsCompanion toCompanion(bool nullToAbsent) {
    return SavedWorkoutsCompanion(
      name: Value(name),
      reps: Value(reps),
      distanceM: Value(distanceM),
      targetS: Value(targetS),
      restS: Value(restS),
      splitEveryM: Value(splitEveryM),
      startSignal: Value(startSignal),
      finishMode: Value(finishMode),
      id: Value(id),
      createdAt: Value(createdAt),
    );
  }

  factory SavedWorkout.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavedWorkout(
      name: serializer.fromJson<String>(json['name']),
      reps: serializer.fromJson<int>(json['reps']),
      distanceM: serializer.fromJson<int>(json['distanceM']),
      targetS: serializer.fromJson<double>(json['targetS']),
      restS: serializer.fromJson<int>(json['restS']),
      splitEveryM: serializer.fromJson<int>(json['splitEveryM']),
      startSignal: serializer.fromJson<bool>(json['startSignal']),
      finishMode: $SavedWorkoutsTable.$converterfinishMode.fromJson(
        serializer.fromJson<String>(json['finishMode']),
      ),
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'name': serializer.toJson<String>(name),
      'reps': serializer.toJson<int>(reps),
      'distanceM': serializer.toJson<int>(distanceM),
      'targetS': serializer.toJson<double>(targetS),
      'restS': serializer.toJson<int>(restS),
      'splitEveryM': serializer.toJson<int>(splitEveryM),
      'startSignal': serializer.toJson<bool>(startSignal),
      'finishMode': serializer.toJson<String>(
        $SavedWorkoutsTable.$converterfinishMode.toJson(finishMode),
      ),
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SavedWorkout copyWith({
    String? name,
    int? reps,
    int? distanceM,
    double? targetS,
    int? restS,
    int? splitEveryM,
    bool? startSignal,
    FinishMode? finishMode,
    String? id,
    DateTime? createdAt,
  }) => SavedWorkout(
    name: name ?? this.name,
    reps: reps ?? this.reps,
    distanceM: distanceM ?? this.distanceM,
    targetS: targetS ?? this.targetS,
    restS: restS ?? this.restS,
    splitEveryM: splitEveryM ?? this.splitEveryM,
    startSignal: startSignal ?? this.startSignal,
    finishMode: finishMode ?? this.finishMode,
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
  );
  SavedWorkout copyWithCompanion(SavedWorkoutsCompanion data) {
    return SavedWorkout(
      name: data.name.present ? data.name.value : this.name,
      reps: data.reps.present ? data.reps.value : this.reps,
      distanceM: data.distanceM.present ? data.distanceM.value : this.distanceM,
      targetS: data.targetS.present ? data.targetS.value : this.targetS,
      restS: data.restS.present ? data.restS.value : this.restS,
      splitEveryM: data.splitEveryM.present
          ? data.splitEveryM.value
          : this.splitEveryM,
      startSignal: data.startSignal.present
          ? data.startSignal.value
          : this.startSignal,
      finishMode: data.finishMode.present
          ? data.finishMode.value
          : this.finishMode,
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavedWorkout(')
          ..write('name: $name, ')
          ..write('reps: $reps, ')
          ..write('distanceM: $distanceM, ')
          ..write('targetS: $targetS, ')
          ..write('restS: $restS, ')
          ..write('splitEveryM: $splitEveryM, ')
          ..write('startSignal: $startSignal, ')
          ..write('finishMode: $finishMode, ')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

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
    id,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavedWorkout &&
          other.name == this.name &&
          other.reps == this.reps &&
          other.distanceM == this.distanceM &&
          other.targetS == this.targetS &&
          other.restS == this.restS &&
          other.splitEveryM == this.splitEveryM &&
          other.startSignal == this.startSignal &&
          other.finishMode == this.finishMode &&
          other.id == this.id &&
          other.createdAt == this.createdAt);
}

class SavedWorkoutsCompanion extends UpdateCompanion<SavedWorkout> {
  final Value<String> name;
  final Value<int> reps;
  final Value<int> distanceM;
  final Value<double> targetS;
  final Value<int> restS;
  final Value<int> splitEveryM;
  final Value<bool> startSignal;
  final Value<FinishMode> finishMode;
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SavedWorkoutsCompanion({
    this.name = const Value.absent(),
    this.reps = const Value.absent(),
    this.distanceM = const Value.absent(),
    this.targetS = const Value.absent(),
    this.restS = const Value.absent(),
    this.splitEveryM = const Value.absent(),
    this.startSignal = const Value.absent(),
    this.finishMode = const Value.absent(),
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SavedWorkoutsCompanion.insert({
    required String name,
    required int reps,
    required int distanceM,
    required double targetS,
    required int restS,
    required int splitEveryM,
    required bool startSignal,
    required FinishMode finishMode,
    required String id,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : name = Value(name),
       reps = Value(reps),
       distanceM = Value(distanceM),
       targetS = Value(targetS),
       restS = Value(restS),
       splitEveryM = Value(splitEveryM),
       startSignal = Value(startSignal),
       finishMode = Value(finishMode),
       id = Value(id),
       createdAt = Value(createdAt);
  static Insertable<SavedWorkout> custom({
    Expression<String>? name,
    Expression<int>? reps,
    Expression<int>? distanceM,
    Expression<double>? targetS,
    Expression<int>? restS,
    Expression<int>? splitEveryM,
    Expression<bool>? startSignal,
    Expression<String>? finishMode,
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (name != null) 'name': name,
      if (reps != null) 'reps': reps,
      if (distanceM != null) 'distance_m': distanceM,
      if (targetS != null) 'target_s': targetS,
      if (restS != null) 'rest_s': restS,
      if (splitEveryM != null) 'split_every_m': splitEveryM,
      if (startSignal != null) 'start_signal': startSignal,
      if (finishMode != null) 'finish_mode': finishMode,
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SavedWorkoutsCompanion copyWith({
    Value<String>? name,
    Value<int>? reps,
    Value<int>? distanceM,
    Value<double>? targetS,
    Value<int>? restS,
    Value<int>? splitEveryM,
    Value<bool>? startSignal,
    Value<FinishMode>? finishMode,
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return SavedWorkoutsCompanion(
      name: name ?? this.name,
      reps: reps ?? this.reps,
      distanceM: distanceM ?? this.distanceM,
      targetS: targetS ?? this.targetS,
      restS: restS ?? this.restS,
      splitEveryM: splitEveryM ?? this.splitEveryM,
      startSignal: startSignal ?? this.startSignal,
      finishMode: finishMode ?? this.finishMode,
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (reps.present) {
      map['reps'] = Variable<int>(reps.value);
    }
    if (distanceM.present) {
      map['distance_m'] = Variable<int>(distanceM.value);
    }
    if (targetS.present) {
      map['target_s'] = Variable<double>(targetS.value);
    }
    if (restS.present) {
      map['rest_s'] = Variable<int>(restS.value);
    }
    if (splitEveryM.present) {
      map['split_every_m'] = Variable<int>(splitEveryM.value);
    }
    if (startSignal.present) {
      map['start_signal'] = Variable<bool>(startSignal.value);
    }
    if (finishMode.present) {
      map['finish_mode'] = Variable<String>(
        $SavedWorkoutsTable.$converterfinishMode.toSql(finishMode.value),
      );
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavedWorkoutsCompanion(')
          ..write('name: $name, ')
          ..write('reps: $reps, ')
          ..write('distanceM: $distanceM, ')
          ..write('targetS: $targetS, ')
          ..write('restS: $restS, ')
          ..write('splitEveryM: $splitEveryM, ')
          ..write('startSignal: $startSignal, ')
          ..write('finishMode: $finishMode, ')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionsTable extends Sessions with TableInfo<$SessionsTable, Session> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _repsMeta = const VerificationMeta('reps');
  @override
  late final GeneratedColumn<int> reps = GeneratedColumn<int>(
    'reps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _distanceMMeta = const VerificationMeta(
    'distanceM',
  );
  @override
  late final GeneratedColumn<int> distanceM = GeneratedColumn<int>(
    'distance_m',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetSMeta = const VerificationMeta(
    'targetS',
  );
  @override
  late final GeneratedColumn<double> targetS = GeneratedColumn<double>(
    'target_s',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _restSMeta = const VerificationMeta('restS');
  @override
  late final GeneratedColumn<int> restS = GeneratedColumn<int>(
    'rest_s',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _splitEveryMMeta = const VerificationMeta(
    'splitEveryM',
  );
  @override
  late final GeneratedColumn<int> splitEveryM = GeneratedColumn<int>(
    'split_every_m',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startSignalMeta = const VerificationMeta(
    'startSignal',
  );
  @override
  late final GeneratedColumn<bool> startSignal = GeneratedColumn<bool>(
    'start_signal',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("start_signal" IN (0, 1))',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<FinishMode, String> finishMode =
      GeneratedColumn<String>(
        'finish_mode',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<FinishMode>($SessionsTable.$converterfinishMode);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _finishedAtMeta = const VerificationMeta(
    'finishedAt',
  );
  @override
  late final GeneratedColumn<DateTime> finishedAt = GeneratedColumn<DateTime>(
    'finished_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rpeMeta = const VerificationMeta('rpe');
  @override
  late final GeneratedColumn<int> rpe = GeneratedColumn<int>(
    'rpe',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    name,
    reps,
    distanceM,
    targetS,
    restS,
    splitEveryM,
    startSignal,
    finishMode,
    id,
    finishedAt,
    rpe,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Session> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('reps')) {
      context.handle(
        _repsMeta,
        reps.isAcceptableOrUnknown(data['reps']!, _repsMeta),
      );
    } else if (isInserting) {
      context.missing(_repsMeta);
    }
    if (data.containsKey('distance_m')) {
      context.handle(
        _distanceMMeta,
        distanceM.isAcceptableOrUnknown(data['distance_m']!, _distanceMMeta),
      );
    } else if (isInserting) {
      context.missing(_distanceMMeta);
    }
    if (data.containsKey('target_s')) {
      context.handle(
        _targetSMeta,
        targetS.isAcceptableOrUnknown(data['target_s']!, _targetSMeta),
      );
    } else if (isInserting) {
      context.missing(_targetSMeta);
    }
    if (data.containsKey('rest_s')) {
      context.handle(
        _restSMeta,
        restS.isAcceptableOrUnknown(data['rest_s']!, _restSMeta),
      );
    } else if (isInserting) {
      context.missing(_restSMeta);
    }
    if (data.containsKey('split_every_m')) {
      context.handle(
        _splitEveryMMeta,
        splitEveryM.isAcceptableOrUnknown(
          data['split_every_m']!,
          _splitEveryMMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_splitEveryMMeta);
    }
    if (data.containsKey('start_signal')) {
      context.handle(
        _startSignalMeta,
        startSignal.isAcceptableOrUnknown(
          data['start_signal']!,
          _startSignalMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startSignalMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('finished_at')) {
      context.handle(
        _finishedAtMeta,
        finishedAt.isAcceptableOrUnknown(data['finished_at']!, _finishedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_finishedAtMeta);
    }
    if (data.containsKey('rpe')) {
      context.handle(
        _rpeMeta,
        rpe.isAcceptableOrUnknown(data['rpe']!, _rpeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Session map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Session(
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      reps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reps'],
      )!,
      distanceM: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}distance_m'],
      )!,
      targetS: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_s'],
      )!,
      restS: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rest_s'],
      )!,
      splitEveryM: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}split_every_m'],
      )!,
      startSignal: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}start_signal'],
      )!,
      finishMode: $SessionsTable.$converterfinishMode.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}finish_mode'],
        )!,
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      finishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}finished_at'],
      )!,
      rpe: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rpe'],
      ),
    );
  }

  @override
  $SessionsTable createAlias(String alias) {
    return $SessionsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<FinishMode, String, String> $converterfinishMode =
      const EnumNameConverter<FinishMode>(FinishMode.values);
}

class Session extends DataClass implements Insertable<Session> {
  final String name;
  final int reps;
  final int distanceM;
  final double targetS;
  final int restS;
  final int splitEveryM;
  final bool startSignal;
  final FinishMode finishMode;
  final String id;
  final DateTime finishedAt;

  /// Effort from 1 to 10, set on the summary screen.
  final int? rpe;
  const Session({
    required this.name,
    required this.reps,
    required this.distanceM,
    required this.targetS,
    required this.restS,
    required this.splitEveryM,
    required this.startSignal,
    required this.finishMode,
    required this.id,
    required this.finishedAt,
    this.rpe,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['name'] = Variable<String>(name);
    map['reps'] = Variable<int>(reps);
    map['distance_m'] = Variable<int>(distanceM);
    map['target_s'] = Variable<double>(targetS);
    map['rest_s'] = Variable<int>(restS);
    map['split_every_m'] = Variable<int>(splitEveryM);
    map['start_signal'] = Variable<bool>(startSignal);
    {
      map['finish_mode'] = Variable<String>(
        $SessionsTable.$converterfinishMode.toSql(finishMode),
      );
    }
    map['id'] = Variable<String>(id);
    map['finished_at'] = Variable<DateTime>(finishedAt);
    if (!nullToAbsent || rpe != null) {
      map['rpe'] = Variable<int>(rpe);
    }
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      name: Value(name),
      reps: Value(reps),
      distanceM: Value(distanceM),
      targetS: Value(targetS),
      restS: Value(restS),
      splitEveryM: Value(splitEveryM),
      startSignal: Value(startSignal),
      finishMode: Value(finishMode),
      id: Value(id),
      finishedAt: Value(finishedAt),
      rpe: rpe == null && nullToAbsent ? const Value.absent() : Value(rpe),
    );
  }

  factory Session.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Session(
      name: serializer.fromJson<String>(json['name']),
      reps: serializer.fromJson<int>(json['reps']),
      distanceM: serializer.fromJson<int>(json['distanceM']),
      targetS: serializer.fromJson<double>(json['targetS']),
      restS: serializer.fromJson<int>(json['restS']),
      splitEveryM: serializer.fromJson<int>(json['splitEveryM']),
      startSignal: serializer.fromJson<bool>(json['startSignal']),
      finishMode: $SessionsTable.$converterfinishMode.fromJson(
        serializer.fromJson<String>(json['finishMode']),
      ),
      id: serializer.fromJson<String>(json['id']),
      finishedAt: serializer.fromJson<DateTime>(json['finishedAt']),
      rpe: serializer.fromJson<int?>(json['rpe']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'name': serializer.toJson<String>(name),
      'reps': serializer.toJson<int>(reps),
      'distanceM': serializer.toJson<int>(distanceM),
      'targetS': serializer.toJson<double>(targetS),
      'restS': serializer.toJson<int>(restS),
      'splitEveryM': serializer.toJson<int>(splitEveryM),
      'startSignal': serializer.toJson<bool>(startSignal),
      'finishMode': serializer.toJson<String>(
        $SessionsTable.$converterfinishMode.toJson(finishMode),
      ),
      'id': serializer.toJson<String>(id),
      'finishedAt': serializer.toJson<DateTime>(finishedAt),
      'rpe': serializer.toJson<int?>(rpe),
    };
  }

  Session copyWith({
    String? name,
    int? reps,
    int? distanceM,
    double? targetS,
    int? restS,
    int? splitEveryM,
    bool? startSignal,
    FinishMode? finishMode,
    String? id,
    DateTime? finishedAt,
    Value<int?> rpe = const Value.absent(),
  }) => Session(
    name: name ?? this.name,
    reps: reps ?? this.reps,
    distanceM: distanceM ?? this.distanceM,
    targetS: targetS ?? this.targetS,
    restS: restS ?? this.restS,
    splitEveryM: splitEveryM ?? this.splitEveryM,
    startSignal: startSignal ?? this.startSignal,
    finishMode: finishMode ?? this.finishMode,
    id: id ?? this.id,
    finishedAt: finishedAt ?? this.finishedAt,
    rpe: rpe.present ? rpe.value : this.rpe,
  );
  Session copyWithCompanion(SessionsCompanion data) {
    return Session(
      name: data.name.present ? data.name.value : this.name,
      reps: data.reps.present ? data.reps.value : this.reps,
      distanceM: data.distanceM.present ? data.distanceM.value : this.distanceM,
      targetS: data.targetS.present ? data.targetS.value : this.targetS,
      restS: data.restS.present ? data.restS.value : this.restS,
      splitEveryM: data.splitEveryM.present
          ? data.splitEveryM.value
          : this.splitEveryM,
      startSignal: data.startSignal.present
          ? data.startSignal.value
          : this.startSignal,
      finishMode: data.finishMode.present
          ? data.finishMode.value
          : this.finishMode,
      id: data.id.present ? data.id.value : this.id,
      finishedAt: data.finishedAt.present
          ? data.finishedAt.value
          : this.finishedAt,
      rpe: data.rpe.present ? data.rpe.value : this.rpe,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Session(')
          ..write('name: $name, ')
          ..write('reps: $reps, ')
          ..write('distanceM: $distanceM, ')
          ..write('targetS: $targetS, ')
          ..write('restS: $restS, ')
          ..write('splitEveryM: $splitEveryM, ')
          ..write('startSignal: $startSignal, ')
          ..write('finishMode: $finishMode, ')
          ..write('id: $id, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('rpe: $rpe')
          ..write(')'))
        .toString();
  }

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
    id,
    finishedAt,
    rpe,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Session &&
          other.name == this.name &&
          other.reps == this.reps &&
          other.distanceM == this.distanceM &&
          other.targetS == this.targetS &&
          other.restS == this.restS &&
          other.splitEveryM == this.splitEveryM &&
          other.startSignal == this.startSignal &&
          other.finishMode == this.finishMode &&
          other.id == this.id &&
          other.finishedAt == this.finishedAt &&
          other.rpe == this.rpe);
}

class SessionsCompanion extends UpdateCompanion<Session> {
  final Value<String> name;
  final Value<int> reps;
  final Value<int> distanceM;
  final Value<double> targetS;
  final Value<int> restS;
  final Value<int> splitEveryM;
  final Value<bool> startSignal;
  final Value<FinishMode> finishMode;
  final Value<String> id;
  final Value<DateTime> finishedAt;
  final Value<int?> rpe;
  final Value<int> rowid;
  const SessionsCompanion({
    this.name = const Value.absent(),
    this.reps = const Value.absent(),
    this.distanceM = const Value.absent(),
    this.targetS = const Value.absent(),
    this.restS = const Value.absent(),
    this.splitEveryM = const Value.absent(),
    this.startSignal = const Value.absent(),
    this.finishMode = const Value.absent(),
    this.id = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.rpe = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionsCompanion.insert({
    required String name,
    required int reps,
    required int distanceM,
    required double targetS,
    required int restS,
    required int splitEveryM,
    required bool startSignal,
    required FinishMode finishMode,
    required String id,
    required DateTime finishedAt,
    this.rpe = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : name = Value(name),
       reps = Value(reps),
       distanceM = Value(distanceM),
       targetS = Value(targetS),
       restS = Value(restS),
       splitEveryM = Value(splitEveryM),
       startSignal = Value(startSignal),
       finishMode = Value(finishMode),
       id = Value(id),
       finishedAt = Value(finishedAt);
  static Insertable<Session> custom({
    Expression<String>? name,
    Expression<int>? reps,
    Expression<int>? distanceM,
    Expression<double>? targetS,
    Expression<int>? restS,
    Expression<int>? splitEveryM,
    Expression<bool>? startSignal,
    Expression<String>? finishMode,
    Expression<String>? id,
    Expression<DateTime>? finishedAt,
    Expression<int>? rpe,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (name != null) 'name': name,
      if (reps != null) 'reps': reps,
      if (distanceM != null) 'distance_m': distanceM,
      if (targetS != null) 'target_s': targetS,
      if (restS != null) 'rest_s': restS,
      if (splitEveryM != null) 'split_every_m': splitEveryM,
      if (startSignal != null) 'start_signal': startSignal,
      if (finishMode != null) 'finish_mode': finishMode,
      if (id != null) 'id': id,
      if (finishedAt != null) 'finished_at': finishedAt,
      if (rpe != null) 'rpe': rpe,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionsCompanion copyWith({
    Value<String>? name,
    Value<int>? reps,
    Value<int>? distanceM,
    Value<double>? targetS,
    Value<int>? restS,
    Value<int>? splitEveryM,
    Value<bool>? startSignal,
    Value<FinishMode>? finishMode,
    Value<String>? id,
    Value<DateTime>? finishedAt,
    Value<int?>? rpe,
    Value<int>? rowid,
  }) {
    return SessionsCompanion(
      name: name ?? this.name,
      reps: reps ?? this.reps,
      distanceM: distanceM ?? this.distanceM,
      targetS: targetS ?? this.targetS,
      restS: restS ?? this.restS,
      splitEveryM: splitEveryM ?? this.splitEveryM,
      startSignal: startSignal ?? this.startSignal,
      finishMode: finishMode ?? this.finishMode,
      id: id ?? this.id,
      finishedAt: finishedAt ?? this.finishedAt,
      rpe: rpe ?? this.rpe,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (reps.present) {
      map['reps'] = Variable<int>(reps.value);
    }
    if (distanceM.present) {
      map['distance_m'] = Variable<int>(distanceM.value);
    }
    if (targetS.present) {
      map['target_s'] = Variable<double>(targetS.value);
    }
    if (restS.present) {
      map['rest_s'] = Variable<int>(restS.value);
    }
    if (splitEveryM.present) {
      map['split_every_m'] = Variable<int>(splitEveryM.value);
    }
    if (startSignal.present) {
      map['start_signal'] = Variable<bool>(startSignal.value);
    }
    if (finishMode.present) {
      map['finish_mode'] = Variable<String>(
        $SessionsTable.$converterfinishMode.toSql(finishMode.value),
      );
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (finishedAt.present) {
      map['finished_at'] = Variable<DateTime>(finishedAt.value);
    }
    if (rpe.present) {
      map['rpe'] = Variable<int>(rpe.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('name: $name, ')
          ..write('reps: $reps, ')
          ..write('distanceM: $distanceM, ')
          ..write('targetS: $targetS, ')
          ..write('restS: $restS, ')
          ..write('splitEveryM: $splitEveryM, ')
          ..write('startSignal: $startSignal, ')
          ..write('finishMode: $finishMode, ')
          ..write('id: $id, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('rpe: $rpe, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RepsTable extends Reps with TableInfo<$RepsTable, Rep> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RepsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sessions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _repMeta = const VerificationMeta('rep');
  @override
  late final GeneratedColumn<int> rep = GeneratedColumn<int>(
    'rep',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeSMeta = const VerificationMeta('timeS');
  @override
  late final GeneratedColumn<double> timeS = GeneratedColumn<double>(
    'time_s',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _falseStartsMeta = const VerificationMeta(
    'falseStarts',
  );
  @override
  late final GeneratedColumn<int> falseStarts = GeneratedColumn<int>(
    'false_starts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [sessionId, rep, timeS, falseStarts];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reps';
  @override
  VerificationContext validateIntegrity(
    Insertable<Rep> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('rep')) {
      context.handle(
        _repMeta,
        rep.isAcceptableOrUnknown(data['rep']!, _repMeta),
      );
    } else if (isInserting) {
      context.missing(_repMeta);
    }
    if (data.containsKey('time_s')) {
      context.handle(
        _timeSMeta,
        timeS.isAcceptableOrUnknown(data['time_s']!, _timeSMeta),
      );
    }
    if (data.containsKey('false_starts')) {
      context.handle(
        _falseStartsMeta,
        falseStarts.isAcceptableOrUnknown(
          data['false_starts']!,
          _falseStartsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sessionId, rep};
  @override
  Rep map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Rep(
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      rep: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rep'],
      )!,
      timeS: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}time_s'],
      ),
      falseStarts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}false_starts'],
      )!,
    );
  }

  @override
  $RepsTable createAlias(String alias) {
    return $RepsTable(attachedDatabase, alias);
  }
}

class Rep extends DataClass implements Insertable<Rep> {
  final String sessionId;
  final int rep;
  final double? timeS;
  final int falseStarts;
  const Rep({
    required this.sessionId,
    required this.rep,
    this.timeS,
    required this.falseStarts,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['session_id'] = Variable<String>(sessionId);
    map['rep'] = Variable<int>(rep);
    if (!nullToAbsent || timeS != null) {
      map['time_s'] = Variable<double>(timeS);
    }
    map['false_starts'] = Variable<int>(falseStarts);
    return map;
  }

  RepsCompanion toCompanion(bool nullToAbsent) {
    return RepsCompanion(
      sessionId: Value(sessionId),
      rep: Value(rep),
      timeS: timeS == null && nullToAbsent
          ? const Value.absent()
          : Value(timeS),
      falseStarts: Value(falseStarts),
    );
  }

  factory Rep.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Rep(
      sessionId: serializer.fromJson<String>(json['sessionId']),
      rep: serializer.fromJson<int>(json['rep']),
      timeS: serializer.fromJson<double?>(json['timeS']),
      falseStarts: serializer.fromJson<int>(json['falseStarts']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sessionId': serializer.toJson<String>(sessionId),
      'rep': serializer.toJson<int>(rep),
      'timeS': serializer.toJson<double?>(timeS),
      'falseStarts': serializer.toJson<int>(falseStarts),
    };
  }

  Rep copyWith({
    String? sessionId,
    int? rep,
    Value<double?> timeS = const Value.absent(),
    int? falseStarts,
  }) => Rep(
    sessionId: sessionId ?? this.sessionId,
    rep: rep ?? this.rep,
    timeS: timeS.present ? timeS.value : this.timeS,
    falseStarts: falseStarts ?? this.falseStarts,
  );
  Rep copyWithCompanion(RepsCompanion data) {
    return Rep(
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      rep: data.rep.present ? data.rep.value : this.rep,
      timeS: data.timeS.present ? data.timeS.value : this.timeS,
      falseStarts: data.falseStarts.present
          ? data.falseStarts.value
          : this.falseStarts,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Rep(')
          ..write('sessionId: $sessionId, ')
          ..write('rep: $rep, ')
          ..write('timeS: $timeS, ')
          ..write('falseStarts: $falseStarts')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(sessionId, rep, timeS, falseStarts);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Rep &&
          other.sessionId == this.sessionId &&
          other.rep == this.rep &&
          other.timeS == this.timeS &&
          other.falseStarts == this.falseStarts);
}

class RepsCompanion extends UpdateCompanion<Rep> {
  final Value<String> sessionId;
  final Value<int> rep;
  final Value<double?> timeS;
  final Value<int> falseStarts;
  final Value<int> rowid;
  const RepsCompanion({
    this.sessionId = const Value.absent(),
    this.rep = const Value.absent(),
    this.timeS = const Value.absent(),
    this.falseStarts = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RepsCompanion.insert({
    required String sessionId,
    required int rep,
    this.timeS = const Value.absent(),
    this.falseStarts = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : sessionId = Value(sessionId),
       rep = Value(rep);
  static Insertable<Rep> custom({
    Expression<String>? sessionId,
    Expression<int>? rep,
    Expression<double>? timeS,
    Expression<int>? falseStarts,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sessionId != null) 'session_id': sessionId,
      if (rep != null) 'rep': rep,
      if (timeS != null) 'time_s': timeS,
      if (falseStarts != null) 'false_starts': falseStarts,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RepsCompanion copyWith({
    Value<String>? sessionId,
    Value<int>? rep,
    Value<double?>? timeS,
    Value<int>? falseStarts,
    Value<int>? rowid,
  }) {
    return RepsCompanion(
      sessionId: sessionId ?? this.sessionId,
      rep: rep ?? this.rep,
      timeS: timeS ?? this.timeS,
      falseStarts: falseStarts ?? this.falseStarts,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (rep.present) {
      map['rep'] = Variable<int>(rep.value);
    }
    if (timeS.present) {
      map['time_s'] = Variable<double>(timeS.value);
    }
    if (falseStarts.present) {
      map['false_starts'] = Variable<int>(falseStarts.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RepsCompanion(')
          ..write('sessionId: $sessionId, ')
          ..write('rep: $rep, ')
          ..write('timeS: $timeS, ')
          ..write('falseStarts: $falseStarts, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SavedWorkoutsTable savedWorkouts = $SavedWorkoutsTable(this);
  late final $SessionsTable sessions = $SessionsTable(this);
  late final $RepsTable reps = $RepsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    savedWorkouts,
    sessions,
    reps,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('reps', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$SavedWorkoutsTableCreateCompanionBuilder =
    SavedWorkoutsCompanion Function({
      required String name,
      required int reps,
      required int distanceM,
      required double targetS,
      required int restS,
      required int splitEveryM,
      required bool startSignal,
      required FinishMode finishMode,
      required String id,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$SavedWorkoutsTableUpdateCompanionBuilder =
    SavedWorkoutsCompanion Function({
      Value<String> name,
      Value<int> reps,
      Value<int> distanceM,
      Value<double> targetS,
      Value<int> restS,
      Value<int> splitEveryM,
      Value<bool> startSignal,
      Value<FinishMode> finishMode,
      Value<String> id,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$SavedWorkoutsTableFilterComposer
    extends Composer<_$AppDatabase, $SavedWorkoutsTable> {
  $$SavedWorkoutsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get distanceM => $composableBuilder(
    column: $table.distanceM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetS => $composableBuilder(
    column: $table.targetS,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get restS => $composableBuilder(
    column: $table.restS,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get splitEveryM => $composableBuilder(
    column: $table.splitEveryM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get startSignal => $composableBuilder(
    column: $table.startSignal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<FinishMode, FinishMode, String>
  get finishMode => $composableBuilder(
    column: $table.finishMode,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SavedWorkoutsTableOrderingComposer
    extends Composer<_$AppDatabase, $SavedWorkoutsTable> {
  $$SavedWorkoutsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get distanceM => $composableBuilder(
    column: $table.distanceM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetS => $composableBuilder(
    column: $table.targetS,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get restS => $composableBuilder(
    column: $table.restS,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get splitEveryM => $composableBuilder(
    column: $table.splitEveryM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get startSignal => $composableBuilder(
    column: $table.startSignal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get finishMode => $composableBuilder(
    column: $table.finishMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SavedWorkoutsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SavedWorkoutsTable> {
  $$SavedWorkoutsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get reps =>
      $composableBuilder(column: $table.reps, builder: (column) => column);

  GeneratedColumn<int> get distanceM =>
      $composableBuilder(column: $table.distanceM, builder: (column) => column);

  GeneratedColumn<double> get targetS =>
      $composableBuilder(column: $table.targetS, builder: (column) => column);

  GeneratedColumn<int> get restS =>
      $composableBuilder(column: $table.restS, builder: (column) => column);

  GeneratedColumn<int> get splitEveryM => $composableBuilder(
    column: $table.splitEveryM,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get startSignal => $composableBuilder(
    column: $table.startSignal,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<FinishMode, String> get finishMode =>
      $composableBuilder(
        column: $table.finishMode,
        builder: (column) => column,
      );

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SavedWorkoutsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SavedWorkoutsTable,
          SavedWorkout,
          $$SavedWorkoutsTableFilterComposer,
          $$SavedWorkoutsTableOrderingComposer,
          $$SavedWorkoutsTableAnnotationComposer,
          $$SavedWorkoutsTableCreateCompanionBuilder,
          $$SavedWorkoutsTableUpdateCompanionBuilder,
          (
            SavedWorkout,
            BaseReferences<_$AppDatabase, $SavedWorkoutsTable, SavedWorkout>,
          ),
          SavedWorkout,
          PrefetchHooks Function()
        > {
  $$SavedWorkoutsTableTableManager(_$AppDatabase db, $SavedWorkoutsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SavedWorkoutsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SavedWorkoutsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SavedWorkoutsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> name = const Value.absent(),
                Value<int> reps = const Value.absent(),
                Value<int> distanceM = const Value.absent(),
                Value<double> targetS = const Value.absent(),
                Value<int> restS = const Value.absent(),
                Value<int> splitEveryM = const Value.absent(),
                Value<bool> startSignal = const Value.absent(),
                Value<FinishMode> finishMode = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SavedWorkoutsCompanion(
                name: name,
                reps: reps,
                distanceM: distanceM,
                targetS: targetS,
                restS: restS,
                splitEveryM: splitEveryM,
                startSignal: startSignal,
                finishMode: finishMode,
                id: id,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String name,
                required int reps,
                required int distanceM,
                required double targetS,
                required int restS,
                required int splitEveryM,
                required bool startSignal,
                required FinishMode finishMode,
                required String id,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => SavedWorkoutsCompanion.insert(
                name: name,
                reps: reps,
                distanceM: distanceM,
                targetS: targetS,
                restS: restS,
                splitEveryM: splitEveryM,
                startSignal: startSignal,
                finishMode: finishMode,
                id: id,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SavedWorkoutsTable, SavedWorkout>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SavedWorkoutsTable,
                    SavedWorkout
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SavedWorkoutsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SavedWorkoutsTable,
      SavedWorkout,
      $$SavedWorkoutsTableFilterComposer,
      $$SavedWorkoutsTableOrderingComposer,
      $$SavedWorkoutsTableAnnotationComposer,
      $$SavedWorkoutsTableCreateCompanionBuilder,
      $$SavedWorkoutsTableUpdateCompanionBuilder,
      (
        SavedWorkout,
        BaseReferences<_$AppDatabase, $SavedWorkoutsTable, SavedWorkout>,
      ),
      SavedWorkout,
      PrefetchHooks Function()
    >;
typedef $$SessionsTableCreateCompanionBuilder =
    SessionsCompanion Function({
      required String name,
      required int reps,
      required int distanceM,
      required double targetS,
      required int restS,
      required int splitEveryM,
      required bool startSignal,
      required FinishMode finishMode,
      required String id,
      required DateTime finishedAt,
      Value<int?> rpe,
      Value<int> rowid,
    });
typedef $$SessionsTableUpdateCompanionBuilder =
    SessionsCompanion Function({
      Value<String> name,
      Value<int> reps,
      Value<int> distanceM,
      Value<double> targetS,
      Value<int> restS,
      Value<int> splitEveryM,
      Value<bool> startSignal,
      Value<FinishMode> finishMode,
      Value<String> id,
      Value<DateTime> finishedAt,
      Value<int?> rpe,
      Value<int> rowid,
    });

final class $$SessionsTableReferences
    extends BaseReferences<_$AppDatabase, $SessionsTable, Session> {
  $$SessionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RepsTable, List<Rep>> _repsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.reps,
    aliasName: 'sessions__id__reps__session_id',
  );

  $$RepsTableProcessedTableManager get repsRefs {
    final manager = $$RepsTableTableManager(
      $_db,
      $_db.reps,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_repsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SessionsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get distanceM => $composableBuilder(
    column: $table.distanceM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetS => $composableBuilder(
    column: $table.targetS,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get restS => $composableBuilder(
    column: $table.restS,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get splitEveryM => $composableBuilder(
    column: $table.splitEveryM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get startSignal => $composableBuilder(
    column: $table.startSignal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<FinishMode, FinishMode, String>
  get finishMode => $composableBuilder(
    column: $table.finishMode,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rpe => $composableBuilder(
    column: $table.rpe,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> repsRefs(
    Expression<bool> Function($$RepsTableFilterComposer f) f,
  ) {
    final $$RepsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reps,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RepsTableFilterComposer(
            $db: $db,
            $table: $db.reps,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get distanceM => $composableBuilder(
    column: $table.distanceM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetS => $composableBuilder(
    column: $table.targetS,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get restS => $composableBuilder(
    column: $table.restS,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get splitEveryM => $composableBuilder(
    column: $table.splitEveryM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get startSignal => $composableBuilder(
    column: $table.startSignal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get finishMode => $composableBuilder(
    column: $table.finishMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rpe => $composableBuilder(
    column: $table.rpe,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get reps =>
      $composableBuilder(column: $table.reps, builder: (column) => column);

  GeneratedColumn<int> get distanceM =>
      $composableBuilder(column: $table.distanceM, builder: (column) => column);

  GeneratedColumn<double> get targetS =>
      $composableBuilder(column: $table.targetS, builder: (column) => column);

  GeneratedColumn<int> get restS =>
      $composableBuilder(column: $table.restS, builder: (column) => column);

  GeneratedColumn<int> get splitEveryM => $composableBuilder(
    column: $table.splitEveryM,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get startSignal => $composableBuilder(
    column: $table.startSignal,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<FinishMode, String> get finishMode =>
      $composableBuilder(
        column: $table.finishMode,
        builder: (column) => column,
      );

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rpe =>
      $composableBuilder(column: $table.rpe, builder: (column) => column);

  Expression<T> repsRefs<T extends Object>(
    Expression<T> Function($$RepsTableAnnotationComposer a) f,
  ) {
    final $$RepsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reps,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RepsTableAnnotationComposer(
            $db: $db,
            $table: $db.reps,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionsTable,
          Session,
          $$SessionsTableFilterComposer,
          $$SessionsTableOrderingComposer,
          $$SessionsTableAnnotationComposer,
          $$SessionsTableCreateCompanionBuilder,
          $$SessionsTableUpdateCompanionBuilder,
          (Session, $$SessionsTableReferences),
          Session,
          PrefetchHooks Function({bool repsRefs})
        > {
  $$SessionsTableTableManager(_$AppDatabase db, $SessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> name = const Value.absent(),
                Value<int> reps = const Value.absent(),
                Value<int> distanceM = const Value.absent(),
                Value<double> targetS = const Value.absent(),
                Value<int> restS = const Value.absent(),
                Value<int> splitEveryM = const Value.absent(),
                Value<bool> startSignal = const Value.absent(),
                Value<FinishMode> finishMode = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<DateTime> finishedAt = const Value.absent(),
                Value<int?> rpe = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionsCompanion(
                name: name,
                reps: reps,
                distanceM: distanceM,
                targetS: targetS,
                restS: restS,
                splitEveryM: splitEveryM,
                startSignal: startSignal,
                finishMode: finishMode,
                id: id,
                finishedAt: finishedAt,
                rpe: rpe,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String name,
                required int reps,
                required int distanceM,
                required double targetS,
                required int restS,
                required int splitEveryM,
                required bool startSignal,
                required FinishMode finishMode,
                required String id,
                required DateTime finishedAt,
                Value<int?> rpe = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionsCompanion.insert(
                name: name,
                reps: reps,
                distanceM: distanceM,
                targetS: targetS,
                restS: restS,
                splitEveryM: splitEveryM,
                startSignal: startSignal,
                finishMode: finishMode,
                id: id,
                finishedAt: finishedAt,
                rpe: rpe,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SessionsTable, Session>(table),
                  $$SessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({repsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (repsRefs) db.reps],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (repsRefs)
                    await $_getPrefetchedDataByColumns<
                      Session,
                      $SessionsTable,
                      Rep,
                      $RepsTable
                    >(
                      currentTable: table,
                      referencedTable: $$SessionsTableReferences._repsRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$SessionsTableReferences(db, table, p0).repsRefs,
                      currentColumn: 'id',
                      referencedColumn: 'session_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionsTable,
      Session,
      $$SessionsTableFilterComposer,
      $$SessionsTableOrderingComposer,
      $$SessionsTableAnnotationComposer,
      $$SessionsTableCreateCompanionBuilder,
      $$SessionsTableUpdateCompanionBuilder,
      (Session, $$SessionsTableReferences),
      Session,
      PrefetchHooks Function({bool repsRefs})
    >;
typedef $$RepsTableCreateCompanionBuilder =
    RepsCompanion Function({
      required String sessionId,
      required int rep,
      Value<double?> timeS,
      Value<int> falseStarts,
      Value<int> rowid,
    });
typedef $$RepsTableUpdateCompanionBuilder =
    RepsCompanion Function({
      Value<String> sessionId,
      Value<int> rep,
      Value<double?> timeS,
      Value<int> falseStarts,
      Value<int> rowid,
    });

final class $$RepsTableReferences
    extends BaseReferences<_$AppDatabase, $RepsTable, Rep> {
  $$RepsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.sessions.createAlias('reps__session_id__sessions__id');

  $$SessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RepsTableFilterComposer extends Composer<_$AppDatabase, $RepsTable> {
  $$RepsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get rep => $composableBuilder(
    column: $table.rep,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get timeS => $composableBuilder(
    column: $table.timeS,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get falseStarts => $composableBuilder(
    column: $table.falseStarts,
    builder: (column) => ColumnFilters(column),
  );

  $$SessionsTableFilterComposer get sessionId {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RepsTableOrderingComposer extends Composer<_$AppDatabase, $RepsTable> {
  $$RepsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get rep => $composableBuilder(
    column: $table.rep,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get timeS => $composableBuilder(
    column: $table.timeS,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get falseStarts => $composableBuilder(
    column: $table.falseStarts,
    builder: (column) => ColumnOrderings(column),
  );

  $$SessionsTableOrderingComposer get sessionId {
    final $$SessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableOrderingComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RepsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RepsTable> {
  $$RepsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get rep =>
      $composableBuilder(column: $table.rep, builder: (column) => column);

  GeneratedColumn<double> get timeS =>
      $composableBuilder(column: $table.timeS, builder: (column) => column);

  GeneratedColumn<int> get falseStarts => $composableBuilder(
    column: $table.falseStarts,
    builder: (column) => column,
  );

  $$SessionsTableAnnotationComposer get sessionId {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RepsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RepsTable,
          Rep,
          $$RepsTableFilterComposer,
          $$RepsTableOrderingComposer,
          $$RepsTableAnnotationComposer,
          $$RepsTableCreateCompanionBuilder,
          $$RepsTableUpdateCompanionBuilder,
          (Rep, $$RepsTableReferences),
          Rep,
          PrefetchHooks Function({bool sessionId})
        > {
  $$RepsTableTableManager(_$AppDatabase db, $RepsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RepsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RepsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RepsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> sessionId = const Value.absent(),
                Value<int> rep = const Value.absent(),
                Value<double?> timeS = const Value.absent(),
                Value<int> falseStarts = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RepsCompanion(
                sessionId: sessionId,
                rep: rep,
                timeS: timeS,
                falseStarts: falseStarts,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String sessionId,
                required int rep,
                Value<double?> timeS = const Value.absent(),
                Value<int> falseStarts = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RepsCompanion.insert(
                sessionId: sessionId,
                rep: rep,
                timeS: timeS,
                falseStarts: falseStarts,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RepsTable, Rep>(table),
                  $$RepsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable: $$RepsTableReferences
                                    ._sessionIdTable(db),
                                referencedColumn: $$RepsTableReferences
                                    ._sessionIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RepsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RepsTable,
      Rep,
      $$RepsTableFilterComposer,
      $$RepsTableOrderingComposer,
      $$RepsTableAnnotationComposer,
      $$RepsTableCreateCompanionBuilder,
      $$RepsTableUpdateCompanionBuilder,
      (Rep, $$RepsTableReferences),
      Rep,
      PrefetchHooks Function({bool sessionId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SavedWorkoutsTableTableManager get savedWorkouts =>
      $$SavedWorkoutsTableTableManager(_db, _db.savedWorkouts);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db, _db.sessions);
  $$RepsTableTableManager get reps => $$RepsTableTableManager(_db, _db.reps);
}
