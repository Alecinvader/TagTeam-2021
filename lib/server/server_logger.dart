import 'dart:developer';

class ServerLogger {
  void logInteraction(
    Uri endpoint,
    String response, {
    String? request,
    Duration? duration,
  }) {
    String output = "\n";
    output += "\tendpoint:\t" + endpoint.toString() + "\n";
    if (request != null) {
      output += "\trequest:\t" + request + "\n";
    }
    if (duration != null) {
      output += "\ttime:\t\t" + getTimeString(duration) + "\n";
    }
    output += "\tresponse:\t" + response.substring(0, response.length) + "\n";
    log(output);
    // print(output);
  }

  String getTimeString(Duration duration) {
    String output = "";

    if (duration.inMinutes != 0) {
      output += "${duration.inMinutes} min ";
    }
    if (duration.inSeconds != 0) {
      output += "${duration.inSeconds} sec";
    }
    if (duration.inMilliseconds != 0) {
      output += "${duration.inMilliseconds} ms";
    }

    return output;
  }
}
