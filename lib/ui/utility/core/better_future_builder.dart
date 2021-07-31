import 'package:flutter/material.dart';

typedef ErrorBuilder = Widget Function(BuildContext context, Object? error);
typedef WidgetBuilder<T> = Widget Function(BuildContext context, T? data);
typedef WaitingBuilder<T> = Widget Function(BuildContext context, AsyncSnapshot<T?> snapshot);

class SimpleFutureBuilder<T> extends StatelessWidget {
  final Future<T> future;
  final ErrorBuilder onError;
  final WidgetBuilder<T> builder;
  final WaitingBuilder<T> onWaiting;
  final bool silentRebuild;
  final bool hasLocalData;
  final bool enableSilentInitialRefresh;

  SimpleFutureBuilder({
    required this.future,
    required this.builder,
    this.silentRebuild = false,
    this.onError = defaultErrorBuilder,
    this.onWaiting = defaultWaitingBuilder,
    Key? key,
    this.hasLocalData = false,
    this.enableSilentInitialRefresh = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
          case ConnectionState.active:
            if (hasLocalData) {
              return this.builder(context, snapshot.data as T);
            }

            if (enableSilentInitialRefresh && silentRebuild && snapshot.hasData) {
              return this.builder(context, snapshot.data as T);
            }

            if (silentRebuild && !enableSilentInitialRefresh) {
              return this.builder(context, snapshot.data as T);
            }

            return this.onWaiting(context, snapshot as AsyncSnapshot<T?>);
          case ConnectionState.done:
          default:
            if (snapshot.hasError) {
              return this.onError(context, snapshot.error);
              // throw snapshot.error;
            } else {
              return this.builder(context, snapshot.data as T);
            }
        }
      },
    );
  }
}

Widget defaultErrorBuilder(BuildContext context, Object? error) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        error.toString(),
        style: TextStyle(
          color: Colors.red,
        ),
      ),
    ),
  );
}

Widget defaultWaitingBuilder(BuildContext context, AsyncSnapshot snapshot) {
  return Center(
    child: CircularProgressIndicator(),
  );
}
