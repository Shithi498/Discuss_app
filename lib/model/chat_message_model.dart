class ChatMessage {
  final int id;
  final String text;
  final String authorName;
  final int authorId;
  final String date;
  List<String> reactions;
final int resID;
  final List<int> attachmentIds;
  //final bool isRead;
  ChatMessage({
    required this.id,
    required this.text,
    required this.authorName,
    required this.authorId,
    required this.date, required this.reactions, required this.resID, required this.attachmentIds,
    //required this.isRead,
  });
  static String cleanHtml(String html) {
    return html.replaceAll(RegExp(r'<[^>]*>'), '').trim();
  }
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final rawAttachments = json['attachment_ids'];
    List<int> parsedAttachmentIds = [];
    if (rawAttachments is List) {
      parsedAttachmentIds = List<int>.from(rawAttachments);
    }
    final author = json['author_id'] as List?;
  //  List<String> reactions = [];

    // if (json['reaction_ids'] is List) {
    //
    //   reactions = List.generate(
    //     (json['reaction_ids'] as List).length,
    //         (index) => '👍',
    //   );
    // }
    final rawReactions = json['reactions'] ?? [];

    final reactions = rawReactions is List
        ? rawReactions.map((e) => e.toString()).toList()
        : <String>[];

    return ChatMessage(
      id: json['id'],
      text: cleanHtml(json['body'] ?? ''),
      authorId: author != null ? author[0] : 0,
      authorName: author != null ? author[1] : '',
      date: json['date'] ?? '',
      reactions:  reactions ,
    resID: json['res_id'],
      attachmentIds: parsedAttachmentIds,
    //  isRead: (json['seen_message_id'] ?? false),
    );
  }
}