// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $RollsTable extends Rolls with TableInfo<$RollsTable, Roll> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RollsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imageRatioMeta = const VerificationMeta(
    'imageRatio',
  );
  @override
  late final GeneratedColumn<double> imageRatio = GeneratedColumn<double>(
    'image_ratio',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(2 / 3),
  );
  static const VerificationMeta _freeYnMeta = const VerificationMeta('freeYn');
  @override
  late final GeneratedColumn<bool> freeYn = GeneratedColumn<bool>(
    'free_yn',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("free_yn" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    description,
    type,
    imageRatio,
    freeYn,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rolls';
  @override
  VerificationContext validateIntegrity(
    Insertable<Roll> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('image_ratio')) {
      context.handle(
        _imageRatioMeta,
        imageRatio.isAcceptableOrUnknown(data['image_ratio']!, _imageRatioMeta),
      );
    }
    if (data.containsKey('free_yn')) {
      context.handle(
        _freeYnMeta,
        freeYn.isAcceptableOrUnknown(data['free_yn']!, _freeYnMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Roll map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Roll(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      imageRatio: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}image_ratio'],
      )!,
      freeYn: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}free_yn'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $RollsTable createAlias(String alias) {
    return $RollsTable(attachedDatabase, alias);
  }
}

class Roll extends DataClass implements Insertable<Roll> {
  final int id;
  final String title;
  final String? description;
  final String type;
  final double imageRatio;
  final bool freeYn;
  final DateTime createdAt;
  const Roll({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    required this.imageRatio,
    required this.freeYn,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['type'] = Variable<String>(type);
    map['image_ratio'] = Variable<double>(imageRatio);
    map['free_yn'] = Variable<bool>(freeYn);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  RollsCompanion toCompanion(bool nullToAbsent) {
    return RollsCompanion(
      id: Value(id),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      type: Value(type),
      imageRatio: Value(imageRatio),
      freeYn: Value(freeYn),
      createdAt: Value(createdAt),
    );
  }

  factory Roll.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Roll(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      type: serializer.fromJson<String>(json['type']),
      imageRatio: serializer.fromJson<double>(json['imageRatio']),
      freeYn: serializer.fromJson<bool>(json['freeYn']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'type': serializer.toJson<String>(type),
      'imageRatio': serializer.toJson<double>(imageRatio),
      'freeYn': serializer.toJson<bool>(freeYn),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Roll copyWith({
    int? id,
    String? title,
    Value<String?> description = const Value.absent(),
    String? type,
    double? imageRatio,
    bool? freeYn,
    DateTime? createdAt,
  }) => Roll(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    type: type ?? this.type,
    imageRatio: imageRatio ?? this.imageRatio,
    freeYn: freeYn ?? this.freeYn,
    createdAt: createdAt ?? this.createdAt,
  );
  Roll copyWithCompanion(RollsCompanion data) {
    return Roll(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      type: data.type.present ? data.type.value : this.type,
      imageRatio: data.imageRatio.present
          ? data.imageRatio.value
          : this.imageRatio,
      freeYn: data.freeYn.present ? data.freeYn.value : this.freeYn,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Roll(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('type: $type, ')
          ..write('imageRatio: $imageRatio, ')
          ..write('freeYn: $freeYn, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, title, description, type, imageRatio, freeYn, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Roll &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.type == this.type &&
          other.imageRatio == this.imageRatio &&
          other.freeYn == this.freeYn &&
          other.createdAt == this.createdAt);
}

class RollsCompanion extends UpdateCompanion<Roll> {
  final Value<int> id;
  final Value<String> title;
  final Value<String?> description;
  final Value<String> type;
  final Value<double> imageRatio;
  final Value<bool> freeYn;
  final Value<DateTime> createdAt;
  const RollsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.type = const Value.absent(),
    this.imageRatio = const Value.absent(),
    this.freeYn = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  RollsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
    required String type,
    this.imageRatio = const Value.absent(),
    this.freeYn = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : title = Value(title),
       type = Value(type);
  static Insertable<Roll> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? type,
    Expression<double>? imageRatio,
    Expression<bool>? freeYn,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (type != null) 'type': type,
      if (imageRatio != null) 'image_ratio': imageRatio,
      if (freeYn != null) 'free_yn': freeYn,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  RollsCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String?>? description,
    Value<String>? type,
    Value<double>? imageRatio,
    Value<bool>? freeYn,
    Value<DateTime>? createdAt,
  }) {
    return RollsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      imageRatio: imageRatio ?? this.imageRatio,
      freeYn: freeYn ?? this.freeYn,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (imageRatio.present) {
      map['image_ratio'] = Variable<double>(imageRatio.value);
    }
    if (freeYn.present) {
      map['free_yn'] = Variable<bool>(freeYn.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RollsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('type: $type, ')
          ..write('imageRatio: $imageRatio, ')
          ..write('freeYn: $freeYn, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $UserFilmRollsTable extends UserFilmRolls
    with TableInfo<$UserFilmRollsTable, UserFilmRoll> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserFilmRollsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 500),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalExposureMeta = const VerificationMeta(
    'totalExposure',
  );
  @override
  late final GeneratedColumn<int> totalExposure = GeneratedColumn<int>(
    'total_exposure',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentExposureMeta = const VerificationMeta(
    'currentExposure',
  );
  @override
  late final GeneratedColumn<int> currentExposure = GeneratedColumn<int>(
    'current_exposure',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _developedYnMeta = const VerificationMeta(
    'developedYn',
  );
  @override
  late final GeneratedColumn<bool> developedYn = GeneratedColumn<bool>(
    'developed_yn',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("developed_yn" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    description,
    totalExposure,
    type,
    currentExposure,
    developedYn,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_film_rolls';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserFilmRoll> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('total_exposure')) {
      context.handle(
        _totalExposureMeta,
        totalExposure.isAcceptableOrUnknown(
          data['total_exposure']!,
          _totalExposureMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalExposureMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('current_exposure')) {
      context.handle(
        _currentExposureMeta,
        currentExposure.isAcceptableOrUnknown(
          data['current_exposure']!,
          _currentExposureMeta,
        ),
      );
    }
    if (data.containsKey('developed_yn')) {
      context.handle(
        _developedYnMeta,
        developedYn.isAcceptableOrUnknown(
          data['developed_yn']!,
          _developedYnMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserFilmRoll map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserFilmRoll(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      totalExposure: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_exposure'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      currentExposure: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_exposure'],
      )!,
      developedYn: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}developed_yn'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $UserFilmRollsTable createAlias(String alias) {
    return $UserFilmRollsTable(attachedDatabase, alias);
  }
}

class UserFilmRoll extends DataClass implements Insertable<UserFilmRoll> {
  final int id;
  final String title;
  final String? description;
  final int totalExposure;
  final String type;
  final int currentExposure;
  final bool developedYn;
  final DateTime createdAt;
  final DateTime updatedAt;
  const UserFilmRoll({
    required this.id,
    required this.title,
    this.description,
    required this.totalExposure,
    required this.type,
    required this.currentExposure,
    required this.developedYn,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['total_exposure'] = Variable<int>(totalExposure);
    map['type'] = Variable<String>(type);
    map['current_exposure'] = Variable<int>(currentExposure);
    map['developed_yn'] = Variable<bool>(developedYn);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UserFilmRollsCompanion toCompanion(bool nullToAbsent) {
    return UserFilmRollsCompanion(
      id: Value(id),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      totalExposure: Value(totalExposure),
      type: Value(type),
      currentExposure: Value(currentExposure),
      developedYn: Value(developedYn),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory UserFilmRoll.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserFilmRoll(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      totalExposure: serializer.fromJson<int>(json['totalExposure']),
      type: serializer.fromJson<String>(json['type']),
      currentExposure: serializer.fromJson<int>(json['currentExposure']),
      developedYn: serializer.fromJson<bool>(json['developedYn']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'totalExposure': serializer.toJson<int>(totalExposure),
      'type': serializer.toJson<String>(type),
      'currentExposure': serializer.toJson<int>(currentExposure),
      'developedYn': serializer.toJson<bool>(developedYn),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UserFilmRoll copyWith({
    int? id,
    String? title,
    Value<String?> description = const Value.absent(),
    int? totalExposure,
    String? type,
    int? currentExposure,
    bool? developedYn,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => UserFilmRoll(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    totalExposure: totalExposure ?? this.totalExposure,
    type: type ?? this.type,
    currentExposure: currentExposure ?? this.currentExposure,
    developedYn: developedYn ?? this.developedYn,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  UserFilmRoll copyWithCompanion(UserFilmRollsCompanion data) {
    return UserFilmRoll(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      totalExposure: data.totalExposure.present
          ? data.totalExposure.value
          : this.totalExposure,
      type: data.type.present ? data.type.value : this.type,
      currentExposure: data.currentExposure.present
          ? data.currentExposure.value
          : this.currentExposure,
      developedYn: data.developedYn.present
          ? data.developedYn.value
          : this.developedYn,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserFilmRoll(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('totalExposure: $totalExposure, ')
          ..write('type: $type, ')
          ..write('currentExposure: $currentExposure, ')
          ..write('developedYn: $developedYn, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    totalExposure,
    type,
    currentExposure,
    developedYn,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserFilmRoll &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.totalExposure == this.totalExposure &&
          other.type == this.type &&
          other.currentExposure == this.currentExposure &&
          other.developedYn == this.developedYn &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class UserFilmRollsCompanion extends UpdateCompanion<UserFilmRoll> {
  final Value<int> id;
  final Value<String> title;
  final Value<String?> description;
  final Value<int> totalExposure;
  final Value<String> type;
  final Value<int> currentExposure;
  final Value<bool> developedYn;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const UserFilmRollsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.totalExposure = const Value.absent(),
    this.type = const Value.absent(),
    this.currentExposure = const Value.absent(),
    this.developedYn = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  UserFilmRollsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
    required int totalExposure,
    required String type,
    this.currentExposure = const Value.absent(),
    this.developedYn = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : title = Value(title),
       totalExposure = Value(totalExposure),
       type = Value(type);
  static Insertable<UserFilmRoll> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<int>? totalExposure,
    Expression<String>? type,
    Expression<int>? currentExposure,
    Expression<bool>? developedYn,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (totalExposure != null) 'total_exposure': totalExposure,
      if (type != null) 'type': type,
      if (currentExposure != null) 'current_exposure': currentExposure,
      if (developedYn != null) 'developed_yn': developedYn,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  UserFilmRollsCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String?>? description,
    Value<int>? totalExposure,
    Value<String>? type,
    Value<int>? currentExposure,
    Value<bool>? developedYn,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return UserFilmRollsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      totalExposure: totalExposure ?? this.totalExposure,
      type: type ?? this.type,
      currentExposure: currentExposure ?? this.currentExposure,
      developedYn: developedYn ?? this.developedYn,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (totalExposure.present) {
      map['total_exposure'] = Variable<int>(totalExposure.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (currentExposure.present) {
      map['current_exposure'] = Variable<int>(currentExposure.value);
    }
    if (developedYn.present) {
      map['developed_yn'] = Variable<bool>(developedYn.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserFilmRollsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('totalExposure: $totalExposure, ')
          ..write('type: $type, ')
          ..write('currentExposure: $currentExposure, ')
          ..write('developedYn: $developedYn, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $RollsTable rolls = $RollsTable(this);
  late final $UserFilmRollsTable userFilmRolls = $UserFilmRollsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [rolls, userFilmRolls];
}

typedef $$RollsTableCreateCompanionBuilder =
    RollsCompanion Function({
      Value<int> id,
      required String title,
      Value<String?> description,
      required String type,
      Value<double> imageRatio,
      Value<bool> freeYn,
      Value<DateTime> createdAt,
    });
typedef $$RollsTableUpdateCompanionBuilder =
    RollsCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<String?> description,
      Value<String> type,
      Value<double> imageRatio,
      Value<bool> freeYn,
      Value<DateTime> createdAt,
    });

class $$RollsTableFilterComposer extends Composer<_$AppDatabase, $RollsTable> {
  $$RollsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get imageRatio => $composableBuilder(
    column: $table.imageRatio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get freeYn => $composableBuilder(
    column: $table.freeYn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RollsTableOrderingComposer
    extends Composer<_$AppDatabase, $RollsTable> {
  $$RollsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get imageRatio => $composableBuilder(
    column: $table.imageRatio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get freeYn => $composableBuilder(
    column: $table.freeYn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RollsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RollsTable> {
  $$RollsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get imageRatio => $composableBuilder(
    column: $table.imageRatio,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get freeYn =>
      $composableBuilder(column: $table.freeYn, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$RollsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RollsTable,
          Roll,
          $$RollsTableFilterComposer,
          $$RollsTableOrderingComposer,
          $$RollsTableAnnotationComposer,
          $$RollsTableCreateCompanionBuilder,
          $$RollsTableUpdateCompanionBuilder,
          (Roll, BaseReferences<_$AppDatabase, $RollsTable, Roll>),
          Roll,
          PrefetchHooks Function()
        > {
  $$RollsTableTableManager(_$AppDatabase db, $RollsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RollsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RollsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RollsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<double> imageRatio = const Value.absent(),
                Value<bool> freeYn = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => RollsCompanion(
                id: id,
                title: title,
                description: description,
                type: type,
                imageRatio: imageRatio,
                freeYn: freeYn,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                Value<String?> description = const Value.absent(),
                required String type,
                Value<double> imageRatio = const Value.absent(),
                Value<bool> freeYn = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => RollsCompanion.insert(
                id: id,
                title: title,
                description: description,
                type: type,
                imageRatio: imageRatio,
                freeYn: freeYn,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RollsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RollsTable,
      Roll,
      $$RollsTableFilterComposer,
      $$RollsTableOrderingComposer,
      $$RollsTableAnnotationComposer,
      $$RollsTableCreateCompanionBuilder,
      $$RollsTableUpdateCompanionBuilder,
      (Roll, BaseReferences<_$AppDatabase, $RollsTable, Roll>),
      Roll,
      PrefetchHooks Function()
    >;
typedef $$UserFilmRollsTableCreateCompanionBuilder =
    UserFilmRollsCompanion Function({
      Value<int> id,
      required String title,
      Value<String?> description,
      required int totalExposure,
      required String type,
      Value<int> currentExposure,
      Value<bool> developedYn,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$UserFilmRollsTableUpdateCompanionBuilder =
    UserFilmRollsCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<String?> description,
      Value<int> totalExposure,
      Value<String> type,
      Value<int> currentExposure,
      Value<bool> developedYn,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$UserFilmRollsTableFilterComposer
    extends Composer<_$AppDatabase, $UserFilmRollsTable> {
  $$UserFilmRollsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalExposure => $composableBuilder(
    column: $table.totalExposure,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentExposure => $composableBuilder(
    column: $table.currentExposure,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get developedYn => $composableBuilder(
    column: $table.developedYn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserFilmRollsTableOrderingComposer
    extends Composer<_$AppDatabase, $UserFilmRollsTable> {
  $$UserFilmRollsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalExposure => $composableBuilder(
    column: $table.totalExposure,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentExposure => $composableBuilder(
    column: $table.currentExposure,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get developedYn => $composableBuilder(
    column: $table.developedYn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserFilmRollsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserFilmRollsTable> {
  $$UserFilmRollsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalExposure => $composableBuilder(
    column: $table.totalExposure,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get currentExposure => $composableBuilder(
    column: $table.currentExposure,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get developedYn => $composableBuilder(
    column: $table.developedYn,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UserFilmRollsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserFilmRollsTable,
          UserFilmRoll,
          $$UserFilmRollsTableFilterComposer,
          $$UserFilmRollsTableOrderingComposer,
          $$UserFilmRollsTableAnnotationComposer,
          $$UserFilmRollsTableCreateCompanionBuilder,
          $$UserFilmRollsTableUpdateCompanionBuilder,
          (
            UserFilmRoll,
            BaseReferences<_$AppDatabase, $UserFilmRollsTable, UserFilmRoll>,
          ),
          UserFilmRoll,
          PrefetchHooks Function()
        > {
  $$UserFilmRollsTableTableManager(_$AppDatabase db, $UserFilmRollsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserFilmRollsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserFilmRollsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserFilmRollsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int> totalExposure = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> currentExposure = const Value.absent(),
                Value<bool> developedYn = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => UserFilmRollsCompanion(
                id: id,
                title: title,
                description: description,
                totalExposure: totalExposure,
                type: type,
                currentExposure: currentExposure,
                developedYn: developedYn,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                Value<String?> description = const Value.absent(),
                required int totalExposure,
                required String type,
                Value<int> currentExposure = const Value.absent(),
                Value<bool> developedYn = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => UserFilmRollsCompanion.insert(
                id: id,
                title: title,
                description: description,
                totalExposure: totalExposure,
                type: type,
                currentExposure: currentExposure,
                developedYn: developedYn,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserFilmRollsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserFilmRollsTable,
      UserFilmRoll,
      $$UserFilmRollsTableFilterComposer,
      $$UserFilmRollsTableOrderingComposer,
      $$UserFilmRollsTableAnnotationComposer,
      $$UserFilmRollsTableCreateCompanionBuilder,
      $$UserFilmRollsTableUpdateCompanionBuilder,
      (
        UserFilmRoll,
        BaseReferences<_$AppDatabase, $UserFilmRollsTable, UserFilmRoll>,
      ),
      UserFilmRoll,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$RollsTableTableManager get rolls =>
      $$RollsTableTableManager(_db, _db.rolls);
  $$UserFilmRollsTableTableManager get userFilmRolls =>
      $$UserFilmRollsTableTableManager(_db, _db.userFilmRolls);
}
