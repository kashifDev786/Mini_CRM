import 'package:hive/hive.dart';

part 'contacts_model.g.dart';

@HiveType(typeId: 1)
class Contact extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String email;

  @HiveField(3)
  String phone;

  Contact({required this.id, required this.name, required this.email, required this.phone});
}
