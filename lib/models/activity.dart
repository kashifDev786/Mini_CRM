import 'package:hive/hive.dart';

part 'activity.g.dart';

@HiveType(typeId: 3)
class Activity extends HiveObject {
  @HiveField(0)
  final String message;

  @HiveField(1)
  final DateTime timestamp;

  Activity({required this.message, required this.timestamp});
}
