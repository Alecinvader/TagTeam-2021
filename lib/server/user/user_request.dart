class UserRequest {
  String? email;
  String? pass;
  String? token;
  String? displayName;
  String? profileImage;

  UserRequest({this.pass, this.email, this.displayName, this.profileImage, this.token});

  toJson() {
    return {'displayName': displayName, 'photoURL': profileImage, 'token': token, 'password': pass, 'email': email};
  }
}
