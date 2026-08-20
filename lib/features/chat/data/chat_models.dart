class ChatColleague {
  const ChatColleague({
    required this.userId,
    required this.employeeId,
    required this.displayName,
    this.jobTitle,
    this.department,
    this.employeeCode,
    this.officeName,
  });

  final String userId;
  final String employeeId;
  final String displayName;
  final String? jobTitle;
  final String? department;
  final String? employeeCode;
  final String? officeName;

  String get initial => displayName.isNotEmpty ? displayName.substring(0, 1).toUpperCase() : '?';

  String get subtitle {
    final parts = [
      if (jobTitle != null && jobTitle!.isNotEmpty) jobTitle!,
      if (officeName != null && officeName!.isNotEmpty) officeName!,
    ];
    return parts.join(' · ');
  }

  factory ChatColleague.fromJson(Map<String, dynamic> json) => ChatColleague(
        userId: json['userId'] as String,
        employeeId: json['employeeId'] as String? ?? json['userId'] as String,
        displayName: json['displayName']?.toString() ?? 'Employee',
        jobTitle: json['jobTitle']?.toString(),
        department: json['department']?.toString(),
        employeeCode: json['employeeCode']?.toString(),
        officeName: json['officeName']?.toString(),
      );
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.type,
    required this.createdAt,
    this.body,
    this.attachmentUrl,
  });

  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String type;
  final String? body;
  final String? attachmentUrl;
  final DateTime createdAt;

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] as String,
        conversationId: json['conversationId'] as String,
        senderId: json['senderId'] as String,
        senderName: json['senderName']?.toString() ?? 'Employee',
        type: json['type']?.toString() ?? 'TEXT',
        body: json['body']?.toString(),
        attachmentUrl: json['attachmentUrl']?.toString(),
        createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
      );
}

class ChatConversation {
  const ChatConversation({
    required this.id,
    required this.type,
    required this.title,
    required this.unreadCount,
    required this.createdAt,
    required this.updatedAt,
    this.name,
    this.peer,
    this.lastMessage,
  });

  final String id;
  final String type;
  final String title;
  final String? name;
  final ChatColleague? peer;
  final ChatMessage? lastMessage;
  final int unreadCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get initial => title.isNotEmpty ? title.substring(0, 1).toUpperCase() : '?';

  ChatConversation copyWith({ChatMessage? lastMessage, int? unreadCount, DateTime? updatedAt}) {
    return ChatConversation(
      id: id,
      type: type,
      title: title,
      name: name,
      peer: peer,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    final peer = json['peer'] as Map<String, dynamic>?;
    final last = json['lastMessage'] as Map<String, dynamic>?;
    return ChatConversation(
      id: json['id'] as String,
      type: json['type']?.toString() ?? 'DIRECT',
      title: json['title']?.toString() ?? 'Chat',
      name: json['name']?.toString(),
      peer: peer == null ? null : ChatColleague.fromJson(peer),
      lastMessage: last == null ? null : ChatMessage.fromJson(last),
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
      updatedAt: DateTime.parse(json['updatedAt'] as String).toLocal(),
    );
  }
}

class ChatListData {
  const ChatListData({this.items = const [], this.unreadTotal = 0});
  final List<ChatConversation> items;
  final int unreadTotal;
}
