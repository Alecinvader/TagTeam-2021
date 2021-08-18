class UserRequest {
  String? email;
  String? pass;
  String? token;
  String? displayName;
  String? profileImage;
  String? uid;

  UserRequest({this.uid, this.email, this.displayName, this.profileImage, this.token});

  toJson() {
    return {'displayName': displayName, 'photoURL': profileImage, 'token': token, 'email': email, 'uid': uid};
  }
}
