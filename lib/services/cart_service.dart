import 'package:shared_preferences/shared_preferences.dart';

class CartService {
  static const String _cartIdKey = 'current_cart_id';

  static Future<int?> getCartId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_cartIdKey);
  }

  static Future<void> setCartId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_cartIdKey, id);
  }

  static Future<void> clearCartId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartIdKey);
  }
}

