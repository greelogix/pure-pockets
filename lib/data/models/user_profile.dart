import 'package:hive/hive.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 1)
class UserProfile extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final double monthlyIncome;

  @HiveField(2)
  final double savingsTarget;

  @HiveField(3)
  final String country;

  @HiveField(4)
  final String currency;

  @HiveField(5)
  final bool onboardingCompleted;

  UserProfile({
    required this.name,
    required this.monthlyIncome,
    required this.savingsTarget,
    required this.country,
    required this.currency,
    this.onboardingCompleted = true,
  });
}
