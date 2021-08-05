class User {
  String? uid;
  String? displayName;
  String? profilePicture;

  User.fromJson(Map json) {
    uid = json['userID'];
    displayName = json['displayName'];
    profilePicture = json['profilePicture'];
  }
}
