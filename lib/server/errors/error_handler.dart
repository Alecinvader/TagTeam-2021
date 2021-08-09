import 'package:flutter/material.dart';
import 'package:tagteamprod/ui/login/sign_in.dart';

typedef ValueHandler<T> = Function(T value);
typedef ValueChanger<From, To> = To Function(From map);

/// An [ErrorHandler] is a class that lets you have an explicit [try] [catch] statement
/// If an error occurs, then `onError` will be called
abstract class ErrorHandler {
  BuildContext? context;
  ErrorHandler(this.context);

  /// wraps a [Function] in a [try] [catch] and calls [onError] if an error occurs
  // T handle<T>(ValueGetter<T> function) {
  //   try {
  //     return function();
  //   } catch (error) {
  //     this.onError(error);
  //     throw (error);
  //   }
  // }

  /// awaits a [Future] in a [try] [catch] and calls [onError] if an error occurs
  Future<T> handleAsync<T>(Future<T> future) async {
    try {
      // wait for the future in a try catch
      final response = await future;
      return response;
    } catch (error) {
      this.onError(error);
      throw (error);
    }
  }

  void onError(error);

  Future<void> showReLoginDialog() async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();

    // if (prefs.containsKey('userKey')) {
    //   await prefs.remove('userKey');
    //   await prefs.remove('username');
    // }

    await Navigator.of(context!)
        .pushAndRemoveUntil(MaterialPageRoute(builder: (context) => SignIn()), (Route<dynamic> route) => false);
  }
}
