import 'package:drift/drift.dart';

@DataClassName('Roll')
class Rolls extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 50)();
  TextColumn get type => text()();
  TextColumn get description => text().nullable()();
  RealColumn get imageRatio => real().withDefault(const Constant(2 / 3))();
  BoolColumn get freeYn => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
