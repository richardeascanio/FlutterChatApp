class Message {
  Message({
    this.from,
    this.to,
    this.message,
    this.createdAt,
    this.updatedAt,
    this.uid,
  });

  String from;
  String to;
  String message;
  DateTime createdAt;
  DateTime updatedAt;
  String uid;

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    from: json["from"],
    to: json["to"],
    message: json["message"],
    createdAt: DateTime.parse(json["createdAt"]),
    updatedAt: DateTime.parse(json["updatedAt"]),
    uid: json["uid"],
  );

  Map<String, dynamic> toJson() => {
    "from": from,
    "to": to,
    "message": message,
    "createdAt": createdAt.toIso8601String(),
    "updatedAt": updatedAt.toIso8601String(),
    "uid": uid,
  };
}