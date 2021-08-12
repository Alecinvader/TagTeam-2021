import 'package:flutter/cupertino.dart';

import '../tagteam.dart';

enum TeamAuthType { owner, manager, user }

class TeamAuthNotifier extends ChangeNotifier {
  TagTeam? currentTeam;
  TeamAuthType? authType;

  bool get isAdmin => authType == TeamAuthType.manager || authType == TeamAuthType.owner;

  void setActiveTeam(TagTeam team, String role) {
    currentTeam = team;
    authType = parseAuthType(role);

    notifyListeners();
  }

  void removeActiveTeam() {
    currentTeam = null;
    authType = null;
    notifyListeners();
  }

  void updateImage(String imageLink) {
    currentTeam?.imageLink = imageLink;
    notifyListeners();
  }

  parseAuthType(String value) {
    switch (value) {
      case 'owner':
        return TeamAuthType.owner;
      case 'manager':
        return TeamAuthType.manager;
    }
    return TeamAuthType.user;
  }
}
