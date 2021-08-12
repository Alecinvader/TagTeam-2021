import 'package:flutter/material.dart';

import 'error_handler.dart';

class SnackbarErrorHandler extends ErrorHandler {
  BuildContext? context;
  final bool showSnackBar;
  final VoidCallback? onErrorHandler;
  final String? overrideErrorMessage;

  SnackbarErrorHandler(this.context, {this.onErrorHandler, this.showSnackBar = true, this.overrideErrorMessage})
      : super(context);

  @override
  void onError(error) {
    if (showSnackBar) {
      ScaffoldMessenger.maybeOf(context!)!.showSnackBar(
        new SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.white,
              ),
              const SizedBox(
                width: 12.0,
              ),
              Flexible(child: Text(overrideErrorMessage ?? error.toString()))
            ],
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    if (onErrorHandler != null) onErrorHandler!();
  }
}
