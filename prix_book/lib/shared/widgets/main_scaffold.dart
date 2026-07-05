import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/router/app_router.dart';
import '../../features/sessions/presentation/providers/session_provider.dart';

class MainScaffold extends ConsumerWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith(AppRoutes.suppliers)) return 1;
    if (location.startsWith(AppRoutes.session)) return 2;
    if (location.startsWith(AppRoutes.settings)) return 3;
    return 0;
  }

  void _onTabTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.products);
        break;
      case 1:
        context.go(AppRoutes.suppliers);
        break;
      case 2:
        context.go(AppRoutes.session);
        break;
      case 3:
        context.go(AppRoutes.settings);
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionState = ref.watch(sessionProvider);
    final currentIndex = _currentIndex(context);

    return Scaffold(
      body: Column(
        children: [
          // Active session banner (Spec Section 5.1)
          if (sessionState.isActive) _SessionBanner(sessionState: sessionState),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (i) => _onTabTapped(context, i),
        backgroundColor: AppColors.white,
        indicatorColor: AppColors.primaryNavy.withAlpha(31),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: AppStrings.tabProducts,
          ),
          NavigationDestination(
            icon: Icon(Icons.store_outlined),
            selectedIcon: Icon(Icons.store),
            label: AppStrings.tabSuppliers,
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            selectedIcon: Icon(Icons.shopping_cart),
            label: AppStrings.startSession,
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: AppStrings.tabSettings,
          ),
        ],
      ),
    );
  }
}

class _SessionBanner extends ConsumerWidget {
  final SessionState sessionState;
  const _SessionBanner({required this.sessionState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => context.go(AppRoutes.session),
      child: Container(
        color: AppColors.amberOrange,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: SafeArea(
          bottom: false,
          child: Row(
            children: [
              const Icon(Icons.shopping_cart, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${AppStrings.sessionActive} • '
                  '${sessionState.pricesRecordedCount} ${AppStrings.pricesRecorded}'
                  '${sessionState.currentSupplier != null ? " • ${sessionState.currentSupplier!.name}" : ""}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                AppStrings.endSession,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
