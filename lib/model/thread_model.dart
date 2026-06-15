
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
  });

  factory DirectMessage.fromJson(Map<String, dynamic> json) {

    int extractedId = 0;
    String extractedName = 'Unknown Author';

    int extractedPartnerId = 0;
    String extractedPartnerName = 'Unknown Partner';
    if (json['author_id'] is List) {
      extractedId = json['author_id'][0];
      extractedName = json['author_id'][1];
    }


    // List<int> extractedPartnerIds = [];
    // if (json['message_partner_ids'] is List) {
    //   extractedPartnerIds = List<int>.from(json['message_partner_ids']);
    // }

    String Name = json['display_name'] is String ? json['display_name'] : '';
    String RecordName = json['record_name'] is String ? json['record_name'] : '';
    if (Name.contains(extractedName)) {
      Name = Name.replaceAll(extractedName, ',');

      Name = Name
          .replaceAll(RegExp(r',\s*,+'), ',')
          .replaceAll(RegExp(r'^,|,$'), '')
          .trim();
    }

    List<int> extractedPartnerIds = [];
    if (json['res_id'] is List) {
      extractedPartnerIds = List<int>.from(json['res_id']);
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
    );
  }
}
