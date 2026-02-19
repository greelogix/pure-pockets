import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data/models/transaction.dart';
import '../data/models/user_profile.dart';

class DatabaseService extends GetxService {
  late Box<Transaction> transactionBox;
  late Box<UserProfile> userProfileBox;
  late Box<double> monthlyGoalsBox;

  Future<DatabaseService> init() async {
    await Hive.initFlutter();
    
    // Register Adapters
    Hive.registerAdapter(TransactionAdapter());
    Hive.registerAdapter(UserProfileAdapter());
    
    // Open Boxes
    transactionBox = await Hive.openBox<Transaction>('transactions');
    userProfileBox = await Hive.openBox<UserProfile>('user_profile');
    monthlyGoalsBox = await Hive.openBox<double>('monthly_goals');
    
    return this;
  }

  UserProfile? getUserProfile() {
    if (userProfileBox.isNotEmpty) {
      return userProfileBox.getAt(0);
    }
    return null;
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    await userProfileBox.clear();
    await userProfileBox.add(profile);
  }
}
