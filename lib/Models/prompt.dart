class Prompt {
  String? recipientId;
  String? text;

  Prompt({this.recipientId, this.text});

  Prompt.fromJson(Map<String, dynamic> json) {
    if (json["recipient_id"] is String) {
      recipientId = json["recipient_id"];
    }
    if (json["text"] is String) {
      text = json["text"];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["recipient_id"] = recipientId;
    _data["text"] = text;
    return _data;
  }
}
