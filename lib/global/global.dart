import 'package:shared_preferences/shared_preferences.dart';

import '../assistantMethods/cart_methods.dart';



SharedPreferences? sharedPreferences;
CartMethods cartMethods = CartMethods();
String? previousEarning = "";

String fcmServerToken = "key=AAAADJ4ZBe4:APA91bGgIqLWdNT0itfN4INS6NLdDWmzC7dlnvi-ulmWd1BLdoPUeGkvkBARxATRr_8pkaHSCsOMZXs7MepWX05NN04Nvl4uvbamXcV2v2eXbcNAQn8tD3Iil2c8XzDgYI2O2eLDjtmE";