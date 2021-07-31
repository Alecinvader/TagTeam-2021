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
        createdAt: DateTime.tryParse(json['createdAt']),
        channelId: json['channelID']);
  }

  toJson() {
    return {"message": message, "imagePath": imagePath, "messageType": messageType.toString()};
  }
}
