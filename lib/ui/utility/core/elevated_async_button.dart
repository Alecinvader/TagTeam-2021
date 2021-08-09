import 'package:flutter/material.dart';
import 'package:tagteamprod/server/responses/server_response.dart';

class AsyncElevatedButton extends StatefulWidget {
  final Widget child;
  final ButtonStyle? buttonStyle;

  /// An async function that returns a [String] to display as an error message or [null]
  final ValueGetter<Future<ServerResponse>?> onPressed;

  AsyncElevatedButton({
    Key? key,
    required this.child,
    required this.onPressed,
    this.buttonStyle,
  }) : super(key: key);

  @override
  _AsyncElevatedButtonState createState() => _AsyncElevatedButtonState();
}

class _AsyncElevatedButtonState extends State<AsyncElevatedButton> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: widget.buttonStyle ?? ElevatedButton.styleFrom(),
      child: widget.child,
      onPressed: isLoading ? null : () => this.onPressed(context),
    );
  }

  Future<void> onPressed(BuildContext context) async {
    setState(() {
      isLoading = true;
    });

    ServerResponse? errorMessage = await widget.onPressed();

    // if (errorMessage != null && errorMessage.isNotEmpty) {
    //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //     content: Text(errorMessage),
    //   ));
    // }

    setState(() {
      isLoading = false;
    });
  }
}
