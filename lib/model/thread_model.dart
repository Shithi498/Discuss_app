
class DirectMessage {
  final int id;
  final int authorId;
  final String authorName;
  final String body;
  final String subject;
  final String date;
  final String displayName;
  final String recordName;
  final List<int> partnerIds;
  final int channelId;
  final int channel_partner_ids;
  final List<Map<String, dynamic>> otherParticipants;
  final String? renamedGroupName;
  final int mySeenMessageId;
  final String channelType;
  final int unreadCount;

  DirectMessage({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.body,
    required this.subject,
    required this.date,
    required this.displayName,
    required this.partnerIds,
    required this.channelId,
    required this.channel_partner_ids,
    required this.recordName,
    required this.otherParticipants,
    required this.renamedGroupName,
    required this.mySeenMessageId,
    required this.channelType,
    required this.unreadCount,
  });

  factory DirectMessage.fromJson(Map<String, dynamic> json) {
    int extractedId = 0;
    String extractedName = 'Unknown Author';

    if (json['author_id'] is List && json['author_id'].isNotEmpty) {
      extractedId = json['author_id'][0] is int ? json['author_id'][0] : 0;
      extractedName = json['author_id'].length > 1
          ? json['author_id'][1].toString()
          : 'Unknown Author';
    }

    String Name = json['display_name'] is String ? json['display_name'] : '';
    String RecordName = json['record_name'] is String ? json['record_name'] : '';
    if (Name.contains(extractedName)) {
      Name = Name.replaceAll(extractedName, ',');

      Name = Name
          .replaceAll(RegExp(r',\s*,+'), ',')
          .replaceAll(RegExp(r'^,|,$'), '')
          .trim();
    }

    final participantsRaw = json['other_participants'];
    final otherParticipants = participantsRaw is List
        ? participantsRaw
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList()
        : <Map<String, dynamic>>[];

    List<int> extractedPartnerIds = [];
    if (json['partner_ids'] is List) {
      extractedPartnerIds = List<int>.from(json['partner_ids'].whereType<int>());
    } else if (json['res_id'] is List) {
      extractedPartnerIds = List<int>.from(json['res_id'].whereType<int>());
    } else if (json['res_id'] is int) {
      extractedPartnerIds = [json['res_id']];
    }

    return DirectMessage(
      id: json['id'] ?? 0,
      authorId: extractedId,
      authorName: extractedName,
      date: json['date'] is String ? json['date'] : '',

      body: json['body'] is String ? json['body'] : '',

      subject: json['subject'] is String ? json['subject'] : 'No Subject',
      displayName: Name,
      recordName: RecordName,
      partnerIds:  extractedPartnerIds,
      channelId: json['res_id'] ?? 0,
      channel_partner_ids: json['channel_partner_ids'] ?? 0,
      otherParticipants: otherParticipants,
      renamedGroupName: json['renamed_group_name'] is String
          ? json['renamed_group_name']
          : null,
      mySeenMessageId: json['my_seen_message_id'] is int
          ? json['my_seen_message_id']
          : 0,
      channelType: json['channel_type']?.toString() ?? '',
      unreadCount: json['unread_count'] is int ? json['unread_count'] : 0,
    );
  }
}
