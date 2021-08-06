enum MessageType {
  text,
  image,
}

class Message {
  String? senderId;
  String? senderDisplayName;
  String? senderPhoto;

  MessageType? messageType;
  String? imagePath;

  String? message;
  DateTime? createdAt;
  int? channelId;

  Message(
      {this.messageType,
      this.message,
      this.imagePath,
      this.channelId,
      this.senderDisplayName,
      this.senderId,
      this.senderPhoto,
      this.createdAt});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
        senderId: json['senderID'],
        senderDisplayName: json['senderDisplayName'],
        senderPhoto: json['senderPhoto'],
        message: json['message'],
        imagePath: json['imagePath'],
        createdAt: DateTime.tryParse(json['createdAt']),
        channelId: json['channelID'],
        messageType: parseMessageType(json['messageType']));
  }

  toJson() {
    return {"message": message, "imagePath": imagePath, "messageType": messageType.toString()};
  }

  static MessageType parseMessageType(String? typeString) {
    if (typeString == "MessageType.text") {
      return MessageType.text;
    } else if (typeString == "MessageType.image") {
      return MessageType.image;
    }

    return MessageType.text;
  }
}
