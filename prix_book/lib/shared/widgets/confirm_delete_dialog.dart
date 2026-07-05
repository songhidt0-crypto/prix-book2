import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';

class ConfirmDeleteDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onConfirm;

  const ConfirmDeleteDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onConfirm,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDeleteDialog(
        title: title,
        message: message,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text(AppStrings.cancel),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.dangerRed,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop(true);
            onConfirm();
          },
          child: const Text(AppStrings.delete),
        ),
      ],
    );
  }
}
