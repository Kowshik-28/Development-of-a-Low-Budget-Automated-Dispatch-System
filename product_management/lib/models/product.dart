import 'package:hive/hive.dart';
part 'product.g.dart';

@HiveType(typeId: 0)
class Product extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  String location;

  @HiveField(3)
  final String qrCode;

  Product({required this.id, required this.name, required this.location, required this.qrCode});
}
