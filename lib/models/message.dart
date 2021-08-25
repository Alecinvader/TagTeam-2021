enum MessageType {
  text,
  image,
}

class Message {
  String? senderId;
  String? senderDisplayName;
  String? senderPhoto;

  bool? imageFinalized;
  bool? deleted;
  bool? isFileImage = false;

  MessageType? messageType;
  String? imagePath;

  String? message;
  String? messageId;
  DateTime? createdAt;
  int? channelId;

  Message(
      {this.messageType,
      this.imageFinalized,
      this.message,
      this.imagePath,
      this.channelId,
      this.senderDisplayName,
      this.senderId,
      this.senderPhoto,
      this.createdAt,
      this.messageId,
      this.deleted,
      this.isFileImage});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
        senderId: json['senderID'],
        senderDisplayName: json['senderDisplayName'],
        senderPhoto: json['senderPhoto'],
        message: json['message'],
        imagePath: json['imagePath'],
        createdAt: DateTime.tryParse(json['createdAt'])?.toLocal() ?? null,
        channelId: json['channelID'],
        messageType: parseMessageType(json['messageType']),
        imageFinalized: json['imageFinalized'],
        deleted: json['deleted'],
        messageId: json['messageID']);
  }

  Map<String, dynamic> toJson() {
    return {"message": message, "imagePath": imagePath, "messageType": messageType.toString()};
  }

  Map<String, dynamic> toCompleteJson() {
    return <String, dynamic>{
      ...toJson(),
      "channelID": this.channelId,
      "senderID": this.senderId,
      "senderPhoto": this.senderPhoto,
      "senderDisplayName": this.senderDisplayName,
      "createdAt": this.createdAt!.toIso8601String(),
    };
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
