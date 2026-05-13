import 'package:flutter/material.dart';
import 'package:smart_shield/core/constants/app_colors.dart';
import 'package:smart_shield/core/services/local_storage_service.dart';
import 'package:smart_shield/features/products/product_model.dart';

class BranchesScreen extends StatefulWidget {
  const BranchesScreen({super.key});

  @override
  State<BranchesScreen> createState() => _BranchesScreenState();
}

class _BranchesScreenState extends State<BranchesScreen> {
  Map<String, List<ProductModel>> _branchProducts = {};

  @override
  void initState() {
    super.initState();
    _loadBranches();
  }

  void _loadBranches() {
    final products = LocalStorageService().getAllProducts();
    final Map<String, List<ProductModel>> grouped = {};
    for (final product in products) {
      grouped.putIfAbsent(product.branchId, () => []).add(product);
    }
    setState(() => _branchProducts = grouped);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          title: const Text('إدارة الفروع',
              style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold)),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: _branchProducts.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('🏪', style: TextStyle(fontSize: 64)),
                    SizedBox(height: 16),
                    Text('مفيش فروع لسه',
                        style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 18,
                            color: AppColors.textSecondary)),
                    SizedBox(height: 8),
                    Text('أضف منتجات عشان تظهر الفروع',
                        style: TextStyle(
                            fontFamily: 'Cairo',
                            color: AppColors.textSecondary)),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _branchProducts.length,
                itemBuilder: (context, index) {
                  final branchId = _branchProducts.keys.elementAt(index);
                  final products = _branchProducts[branchId]!;
                  final expiredCount =
                      products.where((p) => p.isExpired).length;
                  final soonCount =
                      products.where((p) => p.isExpiringSoon).length;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        // Branch Header
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.store,
                                  color: AppColors.primary),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text('فرع $branchId',
                                    style: const TextStyle(
                                        fontFamily: 'Cairo',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: AppColors.primary)),
                              ),
                              Text('${products.length} منتج',
                                  style: const TextStyle(
                                      fontFamily: 'Cairo',
                                      color: AppColors.textSecondary)),
                            ],
                          ),
                        ),

                        // Stats
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              _buildStat('منتهية', expiredCount,
                                  AppColors.danger),
                              const SizedBox(width: 12),
                              _buildStat('قريبة الانتهاء', soonCount,
                                  AppColors.warning),
                              const SizedBox(width: 12),
                              _buildStat(
                                  'سليمة',
                                  products.length - expiredCount - soonCount,
                                  AppColors.success),
                            ],
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

  Widget _buildStat(String label, int count, Color color) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Text('$count',
                  style: TextStyle(
                      color: color,
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.bold,
                      fontSize: 20)),
              Text(label,
                  style: TextStyle(
                      color: color,
                      fontFamily: 'Cairo',
                      fontSize: 11)),
            ],
          ),
        ),
      );
}
