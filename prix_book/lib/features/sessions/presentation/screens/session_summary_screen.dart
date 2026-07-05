import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/dzd_formatter.dart';
import '../../../prices/presentation/providers/price_provider.dart';
import '../../../products/presentation/providers/products_provider.dart';

class SessionSummaryScreen extends ConsumerWidget {
  final Map<String, dynamic>? sessionData;

  const SessionSummaryScreen({super.key, this.sessionData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pricesRecorded = (sessionData?['pricesRecorded'] as int?) ?? 0;
    final supplierNames =
        (sessionData?['supplierNames'] as List?)?.cast<String>() ?? [];
    final durationMinutes = (sessionData?['durationMinutes'] as int?) ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.sessionSummary),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SummaryHeader(
            pricesRecorded: pricesRecorded,
            supplierNames: supplierNames,
            durationMinutes: durationMinutes,
          ),
          const SizedBox(height: 24),
          Text(
            AppStrings.bestPriceList,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          const _BestPricesList(),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => context.go(AppRoutes.products),
            child: const Text(AppStrings.close),
          ),
        ],
      ),
    );
  }
}

class _SummaryHeader extends StatelessWidget {
  final int pricesRecorded;
  final List<String> supplierNames;
  final int durationMinutes;

  const _SummaryHeader({
    required this.pricesRecorded,
    required this.supplierNames,
    required this.durationMinutes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryNavy, Color(0xFF2A5F8F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.check_circle, color: Colors.white, size: 48),
          const SizedBox(height: 12),
          const Text(
            AppStrings.sessionEnded,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(
                label: AppStrings.pricesRecorded,
                value: '$pricesRecorded',
                icon: Icons.price_change,
              ),
              _StatItem(
                label: AppStrings.suppliersVisited,
                value: '${supplierNames.length}',
                icon: Icons.store,
              ),
              _StatItem(
                label: AppStrings.sessionDuration,
                value: DateFormatter.formatDuration(
                    Duration(minutes: durationMinutes)),
                icon: Icons.timer,
              ),
            ],
          ),
          if (supplierNames.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: supplierNames
                  .map((name) => Chip(
                        label: Text(name,
                            style: const TextStyle(color: Colors.white)),
                        backgroundColor: Colors.white.withAlpha(51),
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700)),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }
}

class _BestPricesList extends ConsumerWidget {
  const _BestPricesList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider).products;

    return Column(
      children: products.where((p) => p.id != null).map((product) {
        final pricesAsync = ref.watch(latestPricesProvider(product.id!));
        return pricesAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (prices) {
            if (prices.isEmpty) return const SizedBox.shrink();
            final best = prices.first;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.inventory_2_outlined,
                    color: AppColors.primaryNavy),
                title: Text(product.name,
                    style:
                        const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(
                  '${AppStrings.buyFrom}: ${best.supplierName ?? "—"}',
                  style: const TextStyle(color: AppColors.textMuted),
                ),
                trailing: Text(
                  DZDFormatter.format(best.price),
                  style: const TextStyle(
                    color: AppColors.emeraldGreen,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}
