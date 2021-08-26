class ChatNotification {
  String? firebaseId;
  String? _teamId;
  String? type;

  int? get teamId => _teamId != null ? int.tryParse(_teamId!) : null;

  ChatNotification.fromJson(Map<String, dynamic> json) {
    firebaseId = json['firebaseID'];
    type = json['type'];
    _teamId = json['teamID'];
  }
}
