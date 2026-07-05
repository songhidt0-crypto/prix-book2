import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/brands/presentation/screens/brands_screen.dart';
import '../../features/products/presentation/screens/products_screen.dart';
import '../../features/products/presentation/screens/product_form_screen.dart';
import '../../features/products/presentation/screens/product_detail_screen.dart';
import '../../features/suppliers/presentation/screens/suppliers_screen.dart';
import '../../features/suppliers/presentation/screens/supplier_form_screen.dart';
import '../../features/suppliers/presentation/screens/supplier_detail_screen.dart';
import '../../features/sessions/presentation/screens/session_screen.dart';
import '../../features/sessions/presentation/screens/session_summary_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../shared/widgets/main_scaffold.dart';

abstract class AppRoutes {
  static const String products = '/products';
  static const String productDetail = '/products/:id';
  static const String addProduct = '/products/add';
  static const String editProduct = '/products/:id/edit';

  static const String suppliers = '/suppliers';
  static const String supplierDetail = '/suppliers/:id';
  static const String addSupplier = '/suppliers/add';
  static const String editSupplier = '/suppliers/:id/edit';

  static const String session = '/session';
  static const String sessionSummary = '/session/summary';

  static const String settings = '/settings';
  static const String brands = '/settings/brands';
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.products,
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainScaffold(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.products,
          pageBuilder: (context, state) => _fade(const ProductsScreen()),
        ),
        GoRoute(
          path: AppRoutes.suppliers,
          pageBuilder: (context, state) => _fade(const SuppliersScreen()),
        ),
        GoRoute(
          path: AppRoutes.session,
          pageBuilder: (context, state) => _fade(const SessionScreen()),
        ),
        GoRoute(
          path: AppRoutes.settings,
          pageBuilder: (context, state) => _fade(const SettingsScreen()),
        ),
      ],
    ),

    // Products
    GoRoute(
      path: AppRoutes.addProduct,
      pageBuilder: (context, state) =>
          _slide(const ProductFormScreen(product: null)),
    ),
    GoRoute(
      path: '/products/:id',
      pageBuilder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        return _slide(ProductDetailScreen(productId: id ?? 0));
      },
      routes: [
        GoRoute(
          path: 'edit',
          pageBuilder: (context, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '');
            return _slide(ProductFormScreen(productId: id));
          },
        ),
      ],
    ),

    // Suppliers
    GoRoute(
      path: AppRoutes.addSupplier,
      pageBuilder: (context, state) =>
          _slide(const SupplierFormScreen(supplier: null)),
    ),
    GoRoute(
      path: '/suppliers/:id',
      pageBuilder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        return _slide(SupplierDetailScreen(supplierId: id ?? 0));
      },
      routes: [
        GoRoute(
          path: 'edit',
          pageBuilder: (context, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '');
            return _slide(SupplierFormScreen(supplierId: id));
          },
        ),
      ],
    ),

    // Session summary (full screen)
    GoRoute(
      path: AppRoutes.sessionSummary,
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return _slide(SessionSummaryScreen(sessionData: extra));
      },
    ),

    // Brands (settings sub-page)
    GoRoute(
      path: AppRoutes.brands,
      pageBuilder: (context, state) => _slide(const BrandsScreen()),
    ),
  ],
);

CustomTransitionPage<void> _fade(Widget child) {
  return CustomTransitionPage<void>(
    child: child,
    transitionsBuilder: (context, animation, _, child) =>
        FadeTransition(opacity: animation, child: child),
    transitionDuration: const Duration(milliseconds: 200),
  );
}

CustomTransitionPage<void> _slide(Widget child) {
  return CustomTransitionPage<void>(
    child: child,
    transitionsBuilder: (context, animation, _, child) => SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
      child: child,
    ),
    transitionDuration: const Duration(milliseconds: 300),
  );
}
