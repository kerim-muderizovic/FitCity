import 'package:flutter/material.dart';

PreferredSizeWidget buildMobileAppBar(
  BuildContext context, {
  String? title,
  List<Widget>? actions,
}) {
  return AppBar(
    title: title == null ? null : Text(title),
    actions: actions,
    leading: Navigator.of(context).canPop() ? const BackButton() : null,
  );
}
