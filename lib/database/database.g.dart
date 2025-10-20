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
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
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
    type,
    description,
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
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
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
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
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
  final String type;
  final String? description;
  final double imageRatio;
  final bool freeYn;
  final DateTime createdAt;
  const Roll({
    required this.id,
    required this.title,
    required this.type,
    this.description,
    required this.imageRatio,
    required this.freeYn,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['image_ratio'] = Variable<double>(imageRatio);
    map['free_yn'] = Variable<bool>(freeYn);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  RollsCompanion toCompanion(bool nullToAbsent) {
    return RollsCompanion(
      id: Value(id),
      title: Value(title),
      type: Value(type),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
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
      type: serializer.fromJson<String>(json['type']),
      description: serializer.fromJson<String?>(json['description']),
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
      'type': serializer.toJson<String>(type),
      'description': serializer.toJson<String?>(description),
      'imageRatio': serializer.toJson<double>(imageRatio),
      'freeYn': serializer.toJson<bool>(freeYn),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Roll copyWith({
    int? id,
    String? title,
    String? type,
    Value<String?> description = const Value.absent(),
    double? imageRatio,
    bool? freeYn,
    DateTime? createdAt,
  }) => Roll(
    id: id ?? this.id,
    title: title ?? this.title,
    type: type ?? this.type,
    description: description.present ? description.value : this.description,
    imageRatio: imageRatio ?? this.imageRatio,
    freeYn: freeYn ?? this.freeYn,
    createdAt: createdAt ?? this.createdAt,
  );
  Roll copyWithCompanion(RollsCompanion data) {
    return Roll(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      type: data.type.present ? data.type.value : this.type,
      description: data.description.present
          ? data.description.value
          : this.description,
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
          ..write('type: $type, ')
          ..write('description: $description, ')
          ..write('imageRatio: $imageRatio, ')
          ..write('freeYn: $freeYn, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, title, type, description, imageRatio, freeYn, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Roll &&
          other.id == this.id &&
          other.title == this.title &&
          other.type == this.type &&
          other.description == this.description &&
          other.imageRatio == this.imageRatio &&
          other.freeYn == this.freeYn &&
          other.createdAt == this.createdAt);
}

class RollsCompanion extends UpdateCompanion<Roll> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> type;
  final Value<String?> description;
  final Value<double> imageRatio;
  final Value<bool> freeYn;
  final Value<DateTime> createdAt;
  const RollsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.type = const Value.absent(),
    this.description = const Value.absent(),
    this.imageRatio = const Value.absent(),
    this.freeYn = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  RollsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required String type,
    this.description = const Value.absent(),
    this.imageRatio = const Value.absent(),
    this.freeYn = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : title = Value(title),
       type = Value(type);
  static Insertable<Roll> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? type,
    Expression<String>? description,
    Expression<double>? imageRatio,
    Expression<bool>? freeYn,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (type != null) 'type': type,
      if (description != null) 'description': description,
      if (imageRatio != null) 'image_ratio': imageRatio,
      if (freeYn != null) 'free_yn': freeYn,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  RollsCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String>? type,
    Value<String?>? description,
    Value<double>? imageRatio,
    Value<bool>? freeYn,
    Value<DateTime>? createdAt,
  }) {
    return RollsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      description: description ?? this.description,
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
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
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
          ..write('type: $type, ')
          ..write('description: $description, ')
          ..write('imageRatio: $imageRatio, ')
          ..write('freeYn: $freeYn, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $RollsTable rolls = $RollsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [rolls];
}

typedef $$RollsTableCreateCompanionBuilder =
    RollsCompanion Function({
      Value<int> id,
      required String title,
      required String type,
      Value<String?> description,
      Value<double> imageRatio,
      Value<bool> freeYn,
      Value<DateTime> createdAt,
    });
typedef $$RollsTableUpdateCompanionBuilder =
    RollsCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<String> type,
      Value<String?> description,
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

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
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

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
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

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

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
                Value<String> type = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<double> imageRatio = const Value.absent(),
                Value<bool> freeYn = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => RollsCompanion(
                id: id,
                title: title,
                type: type,
                description: description,
                imageRatio: imageRatio,
                freeYn: freeYn,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                required String type,
                Value<String?> description = const Value.absent(),
                Value<double> imageRatio = const Value.absent(),
                Value<bool> freeYn = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => RollsCompanion.insert(
                id: id,
                title: title,
                type: type,
                description: description,
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

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$RollsTableTableManager get rolls =>
      $$RollsTableTableManager(_db, _db.rolls);
}
