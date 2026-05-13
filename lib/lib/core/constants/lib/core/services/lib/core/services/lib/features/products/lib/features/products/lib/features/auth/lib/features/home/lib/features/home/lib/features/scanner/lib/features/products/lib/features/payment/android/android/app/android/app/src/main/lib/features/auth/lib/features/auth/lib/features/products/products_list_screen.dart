import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_shield/core/constants/app_colors.dart';
import 'package:smart_shield/core/services/local_storage_service.dart';
import 'package:smart_shield/features/products/product_model.dart';
import 'package:smart_shield/features/products/add_product_screen.dart';

class ProductsListScreen extends StatefulWidget {
  const ProductsListScreen({super.key});

  @override
  State<ProductsListScreen> createState() => _ProductsListScreenState();
}

class _ProductsListScreenState extends State<ProductsListScreen> {
  List<ProductModel> _products = [];
  final _localStorage = LocalStorageService();

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() {
    setState(() {
      _products = _localStorage.getAllProducts();
      _products.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
    });
  }

  Color _getExpiryColor(ProductModel product) {
    if (product.isExpired) return AppColors.danger;
    if (product.isExpiringSoon) return AppColors.warning;
    if (product.isExpiringThisMonth) return Colors.orange;
    return AppColors.success;
  }

  String _getExpiryText(ProductModel product) {
    if (product.isExpired) return 'منتهي الصلاحية!';
    if (product.daysRemaining == 0) return 'ينتهي اليوم!';
    return 'باقي ${product.daysRemaining} يوم';
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          title: const Text('المنتجات',
              style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold)),
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _loadProducts,
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.primary,
          onPressed: () async {
            await Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AddProductScreen()));
            _loadProducts();
          },
          child: const Icon(Icons.add, color: Colors.white),
        ),
        body: _products.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('📦', style: TextStyle(fontSize: 64)),
                    SizedBox(height: 16),
                    Text('مفيش منتجات لسه',
                        style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 18,
                            color: AppColors.textSecondary)),
                    SizedBox(height: 8),
                    Text('اضغط + عشان تضيف منتج',
                        style: TextStyle(
                            fontFamily: 'Cairo',
                            color: AppColors.textSecondary)),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  final product = _products[index];
                  final color = _getExpiryColor(product);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: color.withOpacity(0.3)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            product.isExpired
                                ? Icons.warning
                                : Icons.inventory_2_outlined,
                            color: color,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(product.name,
                                  style: const TextStyle(
                                      fontFamily: 'Cairo',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15)),
                              Text('باركود: ${product.barcode}',
                                  style: const TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 12,
                                      color: AppColors.textSecondary)),
                              Text(
                                  DateFormat('dd/MM/yyyy')
                                      .format(product.expiryDate),
                                  style: const TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 12,
                                      color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _getExpiryText(product),
                            style: TextStyle(
                                color: color,
                                fontFamily: 'Cairo',
                                fontSize: 11,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
