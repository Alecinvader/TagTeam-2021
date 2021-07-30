import 'package:firebase_auth/firebase_auth.dart';
import 'package:tagteamprod/server/auth_api.dart';
import 'package:tagteamprod/server/errors/error_handler.dart';

class LoginServices {
  final AuthServer api = new AuthServer();

  Future<void> login(String email, String pass, ErrorHandler handler) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: pass);

      api.post('/user/signin', {}, {}, handler, (json) {
        return json;
      });
    } catch (error) {
      print(error);
      throw error;
    }
  }
}
