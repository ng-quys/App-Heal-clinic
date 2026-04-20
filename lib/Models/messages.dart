class Messages{

  String chatRoomId;
  String imageUrl;
  String messageId;
  String receiverId;
  String senderId;
  String senderRole;
  String text;
  DateTime createAt;

  Messages({
    required this.chatRoomId,
    required this.imageUrl,
    required this.messageId,
    required this.receiverId,
    required this.senderId,
    required this.senderRole,
    required this.text,
    required this.createAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'chatRoomId': chatRoomId,
      'imageUrl': imageUrl,
      'messageId': messageId,
      'receiverId': receiverId,
      'senderId': senderId,
      'senderRole': senderRole,
      'text': text,
      'createAt': createAt,
    };
  }

  factory Messages.fromMap(Map<String, dynamic> map) {
    return Messages(
      chatRoomId: map['chatRoomId'],
      imageUrl: map['imageUrl'],
      messageId: map['messageId'],
      receiverId: map['receiverId'],
      senderId: map['senderId'],
      senderRole: map['senderRole'],
      text: map['text'],
      createAt: map['createAt'] as DateTime,);
  }


}