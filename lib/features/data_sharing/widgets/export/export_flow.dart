import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/share/share_method.dart';
import '../../providers/export_controller.dart';
import '../../providers/share_method_provider.dart';
import '../../screens/qr_display_screen.dart';
import 'export_method_bottom_sheet.dart';


class ExportFlow {
  const ExportFlow._();

  static Future<void> start(
      BuildContext context,
      WidgetRef ref,
      ) async {
    final method = await showModalBottomSheet<ShareMethod>(
      context: context,
      builder: (_) => ExportMethodBottomSheet(
        onSelected: (method) {
          Navigator.of(context).pop(method);
        },
      ),
    );

    if (method == null || !context.mounted) {
      return;
    }

    ref
        .read(
      shareMethodNotifierProvider.notifier,
    )
        .setMethod(method);

    final archive = await ref
        .read(
      exportControllerProvider.notifier,
    )
        .export();

    if (archive == null || !context.mounted) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QrDisplayScreen(
          archive: archive,
        ),
      ),
    );
  }
}