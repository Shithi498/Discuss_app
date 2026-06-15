class loadMessage {
  final int id;
  final int authorId;
  final int authorPartnerId;
  final int authorUserId;
  final String authorName;
  final String body;
  final String messageType;
  final bool isRead;
  final DateTime createdDate;
  final List<dynamic> attachments;
  final List<Reaction> reactions;
  final String image_url;
  final int read_by_count;

  loadMessage({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.body,
    required this.messageType,
    required this.isRead,
    required this.createdDate,
    required this.attachments, required this.authorPartnerId, required this.authorUserId, required this.reactions, required this.image_url,required this.read_by_count
  });

  factory loadMessage.fromJson(Map<String, dynamic> json) {
    final rawDate = json['created_date'] as String?;
    DateTime parsedDate = DateTime.now();
    if (rawDate != null) {

      final isoLike = rawDate.replaceFirst(' ', 'T');
      parsedDate = DateTime.tryParse(isoLike) ?? DateTime.now();
    }

    return loadMessage(
      id: json['id'] as int,
      authorId: json['author_id'] as int,
      authorPartnerId:json['author_partner_id'] as int,
      authorUserId:json['author_user_id'] as int,
      authorName: json['author_name'] as String,
      body: json['body'] as String,
      messageType: json['message_type'] as String,
      isRead: json['is_read'] as bool? ?? false,
      createdDate: parsedDate,
      attachments: (json['attachments'] as List<dynamic>? ?? []),
      reactions: (json['reactions'] as List<dynamic>? ?? [])
          .map((e) => Reaction.fromJson(e as Map<String, dynamic>))
          .toList(),
      image_url: json['author_image_url'] as String,
        read_by_count: json['read_by_count'] as int

    );
  }
}
class loadMessageThreadResult {
  final int threadId;
  final String threadName;
  final List<loadMessage> messages;

  loadMessageThreadResult({
    required this.threadId,
    required this.threadName,
    required this.messages,
  });

  factory loadMessageThreadResult.fromJson(Map<String, dynamic> json) {

    final result = json['result'] is Map<String, dynamic>
        ? json['result'] as Map<String, dynamic>
        : json;

    final msgs = (result['messages'] as List<dynamic>? ?? [])
        .map((m) => loadMessage.fromJson(m as Map<String, dynamic>))
        .toList();

    return loadMessageThreadResult(
      threadId: result['thread_id'] as int,
      threadName: result['thread_name'] as String,
      messages: msgs,
    );
  }
}
class Reaction {
  String content;
  int count;
  bool userReacted;

  Reaction({
    required this.content,
    required this.count,
    required this.userReacted,
  });

  factory Reaction.fromJson(Map<String, dynamic> json) {
    return Reaction(
      content: json['content'] as String,
      count: json['count'] as int,
      userReacted: json['user_reacted'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
     'content': content,
     'count': count,
     'user_reacted': userReacted,
   };
}
