import 'package:hive_flutter/hive_flutter.dart';
import 'package:smart_shield/features/products/product_model.dart';

class LocalStorageService {
  static const String _productsBox = 'products_box';
  static const String _pendingSyncBox = 'pending_sync_box';
  static const String _userBox = 'user_box';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(ProductModelAdapter());
    await Hive.openBox<ProductModel>(_productsBox);
    await Hive.openBox<Map>(_pendingSyncBox);
    await Hive.openBox(_userBox);
  }

  Box<ProductModel> get _products => Hive.box<ProductModel>(_productsBox);
  Box<Map> get _pendingSync => Hive.box<Map>(_pendingSyncBox);
  Box get _user => Hive.box(_userBox);

  Future<void> saveProduct(ProductModel product) async {
    await _products.put(product.id, product);
  }

  Future<void> deleteProduct(String id) async {
    await _products.delete(id);
  }

  List<ProductModel> getAllProducts() {
    return _products.values.toList();
  }

  Future<void> addToPendingSync(String id, Map<String, dynamic> data) async {
    await _pendingSync.put(id, data);
  }

  Future<void> removeFromPendingSync(String id) async {
    await _pendingSync.delete(id);
  }

  Map<dynamic, Map> getAllPendingSync() {
    return _pendingSync.toMap();
  }

  bool hasPendingSync() => _pendingSync.isNotEmpty;

  Future<void> saveUserData(Map<String, dynamic> data) async {
    for (final entry in data.entries) {
      await _user.put(entry.key, entry.value);
    }
  }

  dynamic getUserData(String key) => _user.get(key);

  DateTime? getRegistrationDate() {
    final stored = _user.get('registrationDate');
    if (stored == null) return null;
    return DateTime.tryParse(stored.toString());
  }

  bool getIsVip() => _user.get('isVip', defaultValue: false);

  DateTime? getSubscriptionExpiry() {
    final stored = _user.get('subscriptionExpiry');
    if (stored == null) return null;
    return DateTime.tryParse(stored.toString());
  }
}
