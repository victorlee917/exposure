import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Rolls])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();

        // Pre-populate data when the database is first created
        await into(rolls).insert(
          RollsCompanion.insert(
            title: 'Picture Roll',
            type: 'vertical_picture',
            description: const Value('Capture Moments with Picture'),
            imageRatio: const Value(2 / 3),
            freeYn: const Value(true),
          ),
        );
        await into(rolls).insert(
          RollsCompanion.insert(
            title: 'Movie Roll',
            type: 'movie',
            description: const Value('Capture Moments with Movie'),
            imageRatio: const Value(2 / 3),
            freeYn: const Value(false),
          ),
        );
        await into(rolls).insert(
          RollsCompanion.insert(
            title: 'Music Roll',
            type: 'music',
            description: const Value('Capture Moments with Music'),
            imageRatio: const Value(1 / 1),
            freeYn: const Value(false),
          ),
        );
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from == 1) {
          await m.addColumn(rolls, rolls.description);
          await m.addColumn(rolls, rolls.imageRatio);
          await m.addColumn(rolls, rolls.freeYn);
        }
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
