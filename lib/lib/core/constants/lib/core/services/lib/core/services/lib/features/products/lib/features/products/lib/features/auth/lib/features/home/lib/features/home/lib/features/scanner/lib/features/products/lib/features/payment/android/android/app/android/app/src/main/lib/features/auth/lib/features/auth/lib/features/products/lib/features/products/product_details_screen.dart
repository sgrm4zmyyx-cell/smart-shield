import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_shield/core/constants/app_colors.dart';
import 'package:smart_shield/core/services/local_storage_service.dart';
import 'package:smart_shield/features/products/product_model.dart';

class ProductDetailsScreen extends StatelessWidget {
  final ProductModel product;
  const ProductDetailsScreen({super.key, required this.product});

  Color get _expiryColor {
    if (product.isExpired) return AppColors.danger;
    if (product.isExpiringSoon) return AppColors.warning;
    if (product.isExpiringThisMonth) return Colors.orange;
    return AppColors.success;
  }

  String get _expiryText {
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
          title: const Text('تفاصيل المنتج',
              style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold)),
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => Directionality(
                    textDirection: TextDirection.rtl,
                    child: AlertDialog(
                      title: const Text('حذف المنتج',
                          style: TextStyle(fontFamily: 'Cairo')),
                      content: const Text('هتحذف المنتج ده؟',
                          style: TextStyle(fontFamily: 'Cairo')),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('لا',
                              style: TextStyle(fontFamily: 'Cairo')),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.danger),
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('احذف',
                              style: TextStyle(
                                  color: Colors.white, fontFamily: 'Cairo')),
                        ),
                      ],
                    ),
                  ),
                );
                if (confirm == true) {
                  await LocalStorageService().deleteProduct(product.id);
                  if (context.mounted) Navigator.pop(context);
                }
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Status Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _expiryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _expiryColor.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Icon(
                      product.isExpired ? Icons.warning : Icons.inventory_2,
                      color: _expiryColor,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(product.name,
                        style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _expiryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(_expiryText,
                          style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Details
              _buildInfoCard([
                _buildInfoRow('📦', 'اسم المنتج', product.name),
                _buildInfoRow('🔢', 'الباركود', product.barcode),
                _buildInfoRow('📅', 'تاريخ الانتهاء',
                    DateFormat('dd/MM/yyyy').format(product.expiryDate)),
                _buildInfoRow('🏪', 'الفرع', 'فرع ${product.branchId}'),
                _buildInfoRow('🔔', 'نوع التنبيه',
                    product.alertType == 'Strong' ? 'قوي 🔴' : 'عادي 🔵'),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(children: children),
      );

  Widget _buildInfoRow(String emoji, String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          color: AppColors.textSecondary)),
                  Text(value,
                      style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                ],
              ),
            ),
          ],
        ),
      );
}
