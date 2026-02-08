import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<bool> launchStripeCheckout(
  BuildContext context,
  String url, {
  required String invalidUrlMessage,
  required String launchFailedMessage,
}) async {
  final uri = Uri.tryParse(url);
  if (uri == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(invalidUrlMessage)),
    );
    return false;
  }

  final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!ok && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(launchFailedMessage)),
    );
  }
  return ok;
}
