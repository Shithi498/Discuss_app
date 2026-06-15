import 'dart:convert';

// class AgoraCallInvitationService {
//   final Future<dynamic> Function({
//   required String cookie,
//   required String model,
//   required String method,
//   required List args,
//   required Map<String, dynamic> kwargs,
//   }) callKw;
//
//   AgoraCallInvitationService({required this.callKw});
//
//   Future<void> sendCallInvitation({
//     required String cookie,
//     required int channelId,
//     required int fromPartnerId,
//     required int toPartnerId,
//     required String agoraChannelName,
//   }) async {
//     final payload = {
//       "agora_call": true,
//       "type": "incoming_call",
//       "from_partner_id": fromPartnerId,
//       "to_partner_id": toPartnerId,
//       "agora_channel_name": agoraChannelName,
//       "time": DateTime.now().toIso8601String(),
//     };
//
//     await callKw(
//       cookie: cookie,
//       model: "discuss.channel",
//       method: "message_post",
//       args: [channelId],
//       kwargs: {
//         "body": "AGORA_CALL::${jsonEncode(payload)}",
//         "message_type": "notification",
//       },
//     );
//
//     print("Agora call invitation sent: $payload");
//   }
//
//   Future<List<Map<String, dynamic>>> fetchCallInvitations({
//     required String cookie,
//     required int channelId,
//     required int myPartnerId,
//     int? lastMessageId,
//   }) async {
//     final domain = [
//       ['model', '=', 'discuss.channel'],
//       ['res_id', '=', channelId],
//       ['body', 'ilike', 'AGORA_CALL::'],
//     ];
//
//     if (lastMessageId != null) {
//       domain.add(['id', '>', lastMessageId]);
//     }
//
//     final result = await callKw(
//       cookie: cookie,
//       model: 'mail.message',
//       method: 'search_read',
//       args: [domain],
//       kwargs: {
//         'fields': ['id', 'body'],
//         'order': lastMessageId == null ? 'id desc' : 'id asc',
//         'limit': 30,
//       },
//     );
//
//     final messages = List<Map<String, dynamic>>.from(
//       (result as List).map((m) => Map<String, dynamic>.from(m)),
//     );
//
//     final invitations = <Map<String, dynamic>>[];
//
//     for (final msg in messages) {
//       final body = msg['body'].toString();
//
//       final cleanBody = body
//           .replaceAll(RegExp(r'<[^>]*>'), '')
//           .replaceAll('&quot;', '"')
//           .replaceAll('&#34;', '"')
//           .replaceAll('&#39;', "'")
//           .replaceAll('&apos;', "'")
//           .replaceAll('&amp;', '&');
//
//       if (!cleanBody.contains("AGORA_CALL::")) continue;
//
//       final jsonPart = cleanBody.split("AGORA_CALL::").last.trim();
//
//       try {
//         final decoded = Map<String, dynamic>.from(jsonDecode(jsonPart));
//
//         if (decoded["to_partner_id"] != myPartnerId) {
//           continue;
//         }
//
//         invitations.add({
//           "message_id": msg["id"],
//           ...decoded,
//         });
//       } catch (e) {
//         print("Agora invitation parse error: $e");
//       }
//     }
//
//     return invitations;
//   }
// }

class AgoraCallInvitationService {
  final Future<dynamic> Function({
  required String cookie,
  required String model,
  required String method,
  required List args,
  required Map<String, dynamic> kwargs,
  }) callKw;

  AgoraCallInvitationService({required this.callKw});

  int? _asInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  Future<void> sendCallInvitation({
    required String cookie,
    required int channelId,
    required int fromPartnerId,
    required int toPartnerId,
    required String agoraChannelName,
    required String callType,
  }) async {
    final payload = {
      "agora_call": true,
      "type": "incoming_call",
      "call_type": callType,
      "from_partner_id": fromPartnerId,
      "to_partner_id": toPartnerId,
      "agora_channel_name": agoraChannelName,
      "time": DateTime.now().toIso8601String(),
    };

    await callKw(
      cookie: cookie,
      //model: "discuss.channel",
      model: "discuss.agora.call",
      method: "message_post",
      args: [channelId],
      kwargs: {
        "body": "AGORA_CALL::${jsonEncode(payload)}",
        "message_type": "notification",
      },
    );

    print("Agora call invitation sent: $payload");
  }

  Future<List<Map<String, dynamic>>> fetchCallInvitations({
    required String cookie,
    required int channelId,
    required int myPartnerId,
    int? lastMessageId,
  }) async {
    final domain = [
      ['model', '=', 'discuss.channel'],
      ['res_id', '=', channelId],
      ['body', 'ilike', 'AGORA_CALL::'],
    ];

    if (lastMessageId != null) {
      domain.add(['id', '>', lastMessageId]);
    }

    final result = await callKw(
      cookie: cookie,
      model: 'mail.message',
      method: 'search_read',
      args: [domain],
      kwargs: {
        'fields': ['id', 'body'],
        'order': 'id asc',
        'limit': 30,
      },
    );

    final invitations = <Map<String, dynamic>>[];

    for (final raw in result as List) {
      final msg = Map<String, dynamic>.from(raw);
      final body = msg['body'].toString();

      final cleanBody = body
          .replaceAll(RegExp(r'<[^>]*>'), '')
          .replaceAll('&quot;', '"')
          .replaceAll('&#34;', '"')
          .replaceAll('&#39;', "'")
          .replaceAll('&apos;', "'")
          .replaceAll('&amp;', '&');

      if (!cleanBody.contains("AGORA_CALL::")) continue;

      final jsonPart = cleanBody.split("AGORA_CALL::").last.trim();

      try {
        final decoded = Map<String, dynamic>.from(jsonDecode(jsonPart));

        if (_asInt(decoded["to_partner_id"]) != myPartnerId) continue;
        if (decoded["type"] != "incoming_call") continue;

        invitations.add({
          "message_id": msg["id"],
          ...decoded,
        });
      } catch (e) {
        print("Agora invitation parse error: $e");
      }
    }

    return invitations;
  }
}
