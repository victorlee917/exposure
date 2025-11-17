import 'package:drift/drift.dart';

@DataClassName('Roll')
class Rolls extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 50)();
  TextColumn get description => text().withLength(max: 100).nullable()();
  TextColumn get type => text()();
  RealColumn get imageRatio => real().withDefault(const Constant(3 / 2))();
  BoolColumn get freeYn => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('UserFilmRoll')
class UserFilmRolls extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 50)();
  TextColumn get description => text().withLength(max: 100).nullable()();
  IntColumn get totalExposure => integer()();
  TextColumn get type => text()();
  IntColumn get currentExposure => integer().withDefault(const Constant(0))();
  BoolColumn get developedYn => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
