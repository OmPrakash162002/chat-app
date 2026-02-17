class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final String type;
  final bool read;
  final DateTime createdAt;
  final DateTime? readAt;
  final Map<String, dynamic>? sender;
  final Map<String, dynamic>? receiver;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    this.type = 'text',
    this.read = false,
    required this.createdAt,
    this.readAt,
    this.sender,
    this.receiver,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['_id'] ?? json['id'] ?? '',
      senderId: json['sender'] is Map ? json['sender']['_id'] : json['sender'],
      receiverId: json['receiver'] is Map ? json['receiver']['_id'] : json['receiver'],
      content: json['content'] ?? '',
      type: json['type'] ?? 'text',
      read: json['read'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt']) : null,
      sender: json['sender'] is Map ? json['sender'] : null,
      receiver: json['receiver'] is Map ? json['receiver'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'type': type,
      'read': read,
      'createdAt': createdAt.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
    };
  }
}
