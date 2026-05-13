import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:smart_shield/features/products/product_model.dart';
import 'package:smart_shield/core/services/local_storage_service.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocalStorageService _local;
  static const String _encryptionKey = 'SmartShield2024SecureKey32BytesXX';

  FirebaseService(this._local);

  String _encrypt(String plainText) {
    final key = enc.Key.fromUtf8(_encryptionKey);
    final iv = enc.IV.fromLength(16);
    final encrypter = enc.Encrypter(enc.AES(key));
    return encrypter.encrypt(plainText, iv: iv).base64;
  }

  String _decrypt(String encryptedText) {
    final key = enc.Key.fromUtf8(_encryptionKey);
    final iv = enc.IV.fromLength(16);
    final encrypter = enc.Encrypter(enc.AES(key));
    return encrypter.decrypt64(encryptedText, iv: iv);
  }

  Future<void> addProduct(ProductModel product, String userId) async {
    final barcodeHash = sha256.convert(utf8.encode(product.barcode)).toString();
    final encryptedData = {
      'name': _encrypt(product.name),
      'barcode': _encrypt(product.barcode),
      'barcodeHash': barcodeHash,
      'expiryDate': product.expiryDate.toIso8601String(),
      'alertType': product.alertType,
      'branchId': product.branchId,
      'createdAt': FieldValue.serverTimestamp(),
      'userId': userId,
    };
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('products')
        .doc(product.id)
        .set(encryptedData);
  }

  Future<List<ProductModel>> getProducts(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('products')
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return ProductModel(
        id: doc.id,
        name: _decrypt(data['name']),
        barcode: _decrypt(data['barcode']),
        expiryDate: DateTime.parse(data['expiryDate']),
        alertType: data['alertType'],
        branchId: data['branchId'],
      );
    }).toList();
  }

  Future<void> updateSubscription({
    required String userId,
    required bool status,
    required DateTime expiryDate,
  }) async {
    await _firestore.collection('users').doc(userId).update({
      'subscriptionStatus': status,
      'subscriptionExpiry': expiryDate.toIso8601String(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> syncPendingData(String userId) async {
    if (!_local.hasPendingSync()) return;
    final pending = _local.getAllPendingSync();
    for (final entry in pending.entries) {
      try {
        final data = Map<String, dynamic>.from(entry.value);
        final action = data['action'] as String;
        if (action == 'add') {
          final product = ProductModel.fromMap(
              Map<String, dynamic>.from(data['product']));
          await addProduct(product, userId);
        }
        await _local.removeFromPendingSync(entry.key);
      } catch (e) {
        continue;
      }
    }
  }
}
