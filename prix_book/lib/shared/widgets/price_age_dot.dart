import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';

/// Color-coded freshness indicator per Spec Section 4.4
class PriceAgeDot extends StatelessWidget {
  final DateTime recordedAt;
  final double size;

  const PriceAgeDot({
    super.key,
    required this.recordedAt,
    this.size = 10,
  });

  Color _color() {
    final days = DateFormatter.priceAgeDays(recordedAt);
    if (days < 7) return AppColors.priceFresh;
    if (days <= 30) return AppColors.priceAging;
    return AppColors.priceStale;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _color(),
        shape: BoxShape.circle,
      ),
    );
  }
}
