import 'package:flutter/material.dart';

import '../domain/countdown_item.dart';
import '../screens/countdown_crud_screen.dart';

class CountdownNavigation {
  const CountdownNavigation._();

  static Future<void> openCrud(
      BuildContext context, {
        CountdownItem? initial,
      }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CountdownCrudScreen(
          initial: initial,
        ),
      ),
    );
  }
}