class TagTeam {
  int? teamId;
  String? name;
  String? imageLink;
  String? ownerId;
  String? inviteCode;

  TagTeam();

  TagTeam.fromJson(Map json) {
    teamId = json['teamID'];
    name = json['name'];
    imageLink = json['imageLink'];
    ownerId = json['ownerID'];
    inviteCode = json['inviteCode'];
  }

  toJson() {
    return {
      'name': name,
      'imageLink': imageLink,
    };
  }
}
