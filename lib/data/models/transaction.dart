import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 0)
class Transaction extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final String category;

  @HiveField(3)
  final String merchant;

  @HiveField(4)
  final DateTime date;

  @HiveField(5)
  final bool isIncome;

  @HiveField(6)
  final String? receiptPath;

  Transaction({
    required this.id,
    required this.amount,
    required this.category,
    required this.merchant,
    required this.date,
    this.isIncome = false,
    this.receiptPath,
  });
}
