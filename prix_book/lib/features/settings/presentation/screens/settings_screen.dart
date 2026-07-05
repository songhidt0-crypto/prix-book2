import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/database_helper.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.settings)),
      body: ListView(
        children: [
          const _SectionHeader(title: 'البيانات'),
          _SettingsTile(
            icon: Icons.label_outline,
            title: AppStrings.manageBrands,
            subtitle: 'إدارة العلامات التجارية للمنتجات',
            onTap: () => context.push(AppRoutes.brands),
          ),
          const Divider(),
          const _SectionHeader(title: 'النسخ الاحتياطي'),
          _SettingsTile(
            icon: Icons.backup_outlined,
            title: AppStrings.exportBackup,
            subtitle: AppStrings.exportBackupSubtitle,
            onTap: () => _exportBackup(context, ref),
          ),
          const Divider(),
          const _SectionHeader(title: 'التطبيق'),
          _SettingsTile(
            icon: Icons.info_outline,
            title: AppStrings.about,
            subtitle: '${AppStrings.appName} v1.1.0',
            onTap: () => _showAboutDialog(context),
          ),
        ],
      ),
    );
  }

  Future<void> _exportBackup(BuildContext context, WidgetRef ref) async {
    try {
      final dbHelper = DatabaseHelper();
      final dbPath = await dbHelper.getDatabasePath();
      final file = File(dbPath);
      if (!await file.exists()) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('لا يوجد ملف قاعدة بيانات للتصدير')),
          );
        }
        return;
      }
      await Share.shareXFiles(
        [XFile(dbPath)],
        subject: 'prix_book_backup.db',
        text: 'نسخة احتياطية من دفتر الأسعار',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.errorGeneric)),
        );
      }
    }
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppStrings.appName,
      applicationVersion: '1.1.0',
      applicationLegalese: '© 2024 DZigner31',
      children: [
        const SizedBox(height: 12),
        const Text(
          'تطبيق مقارنة أسعار الجملة لأصحاب محلات القرطاسية في الجزائر.',
          textDirection: TextDirection.rtl,
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.primaryNavy,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryNavy),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle,
          style: const TextStyle(color: AppColors.textMuted)),
      trailing:
          const Icon(Icons.chevron_right, color: AppColors.textMuted),
      onTap: onTap,
    );
  }
}
