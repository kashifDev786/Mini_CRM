import 'package:hive/hive.dart';

part 'lead.g.dart';

@HiveType(typeId: 0)
class Lead extends HiveObject {
  @HiveField(0)
  String id; // NEW ID FIELD

  @HiveField(1)
  String name;

  @HiveField(2)
  String email;

  @HiveField(3)
  String phone;

  @HiveField(4)
  String status;

  Lead({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.status = 'New',
  });
}
