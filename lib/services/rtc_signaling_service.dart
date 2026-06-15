import 'dart:convert';


// class RtcSignalingService {
//   final Future<dynamic> Function({
//     required String cookie,
//     required String model,
//     required String method,
//     required List args,
//     required Map<String, dynamic> kwargs,
//   })
//   callKw;
//
//   RtcSignalingService({required this.callKw});
//
//   Future<void> sendSignal({
//     required String cookie,
//     required int channelId,
//     required int fromPartnerId,
//     required String type,
//     required Map<String, dynamic> data,
//     String? sessionId,
//   }) async {
//     final payload = {
//       'rtc_signal': true,
//       'type': type,
//       'from_partner_id': fromPartnerId,
//       if (sessionId != null) 'session_id': sessionId,
//       'data': data,
//       'time': DateTime.now().toIso8601String(),
//     };
//
//     final body = "RTC_SIGNAL::${jsonEncode(payload)}";
//     print("Sending signal with payload: $payload");
//
//     await callKw(
//       cookie: cookie,
//       model: 'discuss.channel',
//       method: 'message_post',
//       args: [channelId],
//       kwargs: {'body': body, 'message_type': 'notification'},
//     );
//
//     print("Sent RTC Signal: $type");
//   }
//
//   Future<List<Map<String, dynamic>>> fetchSignals({
//     required String cookie,
//     required int channelId,
//     required int myPartnerId,
//      String? currentSessionId,
//     int? lastMessageId,
//   }) async {
//     final domain = [
//       ['model', '=', 'discuss.channel'],
//       ['res_id', '=', channelId],
//       ['body', 'ilike', 'RTC_SIGNAL::'],
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
//         'limit': 100,
//       },
//     );
//
//     final signals = <Map<String, dynamic>>[];
//     final messages = List<Map<String, dynamic>>.from(
//       (result as List).map((message) => Map<String, dynamic>.from(message)),
//     );
//
//     if (lastMessageId == null) {
//       messages.sort((a, b) => (a['id'] as int).compareTo(b['id'] as int));
//     }
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
//       if (!cleanBody.contains('RTC_SIGNAL::')) continue;
//
//       final jsonPart = cleanBody.split('RTC_SIGNAL::').last.trim();
//
//       try {
//         final decoded = jsonDecode(jsonPart);
//
//         if (decoded['from_partner_id'] == myPartnerId) {
//           continue;
//         }
//
//         if (currentSessionId != null &&
//             currentSessionId.isNotEmpty &&
//             decoded['session_id'] != currentSessionId) {
//           print("IGNORING OLD SIGNAL: ${decoded['session_id']}");
//           continue;
//         }
//
//         signals.add({'message_id': msg['id'], ...decoded});
//
//         print("Received message body: $body");
//       } catch (e) {
//         print("Signal parse error: $e");
//       }
//     }
//
//     return signals;
//   }
//
//   // Future<List<Map<String, dynamic>>> fetchSignals({
//   //   required String cookie,
//   //   required int channelId,
//   //   required int myPartnerId,
//   //   String? currentSessionId,
//   //   int? lastMessageId,
//   //   int limit = 50,
//   // }) async {
//   //   final domain = [
//   //     ['model', '=', 'discuss.channel'],
//   //     ['res_id', '=', channelId],
//   //     ['body', 'ilike', 'RTC_SIGNAL::'],
//   //   ];
//   //
//   //   // Important: after session is known, fetch only that session's signals
//   //   if (currentSessionId != null && currentSessionId.isNotEmpty) {
//   //     domain.add(['body', 'ilike', '"session_id":"$currentSessionId"']);
//   //   }
//   //
//   //   if (lastMessageId != null) {
//   //     domain.add(['id', '>', lastMessageId]);
//   //   }
//   //
//   //   final result = await callKw(
//   //     cookie: cookie,
//   //     model: 'mail.message',
//   //     method: 'search_read',
//   //     args: [domain],
//   //     kwargs: {
//   //       'fields': ['id', 'body'],
//   //       'order': lastMessageId == null ? 'id desc' : 'id asc',
//   //       'limit': limit,
//   //     },
//   //   );
//   //
//   //   final messages = List<Map<String, dynamic>>.from(
//   //     (result as List).map((m) => Map<String, dynamic>.from(m)),
//   //   );
//   //
//   //   if (lastMessageId == null) {
//   //     messages.sort((a, b) => (a['id'] as int).compareTo(b['id'] as int));
//   //   }
//   //
//   //   final signals = <Map<String, dynamic>>[];
//   //
//   //   for (final msg in messages) {
//   //     final body = msg['body'].toString();
//   //
//   //     final cleanBody = body
//   //         .replaceAll(RegExp(r'<[^>]*>'), '')
//   //         .replaceAll('&quot;', '"')
//   //         .replaceAll('&#34;', '"')
//   //         .replaceAll('&#39;', "'")
//   //         .replaceAll('&apos;', "'")
//   //         .replaceAll('&amp;', '&');
//   //
//   //     if (!cleanBody.contains('RTC_SIGNAL::')) continue;
//   //
//   //     final jsonPart = cleanBody.split('RTC_SIGNAL::').last.trim();
//   //
//   //     try {
//   //       final decoded = jsonDecode(jsonPart);
//   //
//   //       if (decoded['from_partner_id'] == myPartnerId) {
//   //         continue;
//   //       }
//   //
//   //       if (currentSessionId != null &&
//   //           currentSessionId.isNotEmpty &&
//   //           decoded['session_id']?.toString() != currentSessionId) {
//   //         print("IGNORING OLD SIGNAL: ${decoded['session_id']}");
//   //         continue;
//   //       }
//   //
//   //       signals.add({'message_id': msg['id'], ...decoded});
//   //     } catch (e) {
//   //       print("Signal parse error: $e");
//   //     }
//   //   }
//   //
//   //   return signals;
//   // }
// }


class RtcSignalingService {
  final Future<dynamic> Function({
  required String cookie,
  required String model,
  required String method,
  required List args,
  required Map<String, dynamic> kwargs,
  }) callKw;

  RtcSignalingService({required this.callKw});

  Future<void> sendSignal({
    required String cookie,
    required int channelId,
    required int fromPartnerId,
    required String type,
    required Map<String, dynamic> data,
    required String? sessionId,
  }) async {
    final payload = {
      'rtc_signal': true,
      'type': type,
      'from_partner_id': fromPartnerId,
      'session_id': sessionId,
      'data': data,
      'time': DateTime.now().toIso8601String(),
    };

    final body = "RTC_SIGNAL::${jsonEncode(payload)}";

    print("Sending signal with payload: $payload");

    await callKw(
      cookie: cookie,
      model: 'discuss.channel',
      method: 'message_post',
      args: [channelId],
      kwargs: {
        'body': body,
        'message_type': 'notification',
      },
    );

    print("Sent RTC Signal: $type");
  }

  Future<List<Map<String, dynamic>>> fetchSignals({
    required String cookie,
    required int channelId,
    required int myPartnerId,
    String? currentSessionId,
    int? lastMessageId,
    int limit = 50,
  }) async {
    final domain = [
      ['model', '=', 'discuss.channel'],
      ['res_id', '=', channelId],
      ['body', 'ilike', 'RTC_SIGNAL::'],
    ];

    // Important: after session is known,
    // fetch only signals for that exact RTC session.
    if (currentSessionId != null && currentSessionId.isNotEmpty) {
      domain.add([
        'body',
        'ilike',
        '"session_id":"$currentSessionId"',
      ]);
    }

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
        'order': lastMessageId == null ? 'id desc' : 'id asc',
        'limit': limit,
      },
    );

    final messages = List<Map<String, dynamic>>.from(
      (result as List).map(
            (message) => Map<String, dynamic>.from(message),
      ),
    );

    // If fetching latest messages, Odoo returns desc.
    // We sort asc so signals are processed in correct order.
    if (lastMessageId == null) {
      messages.sort(
            (a, b) => (a['id'] as int).compareTo(b['id'] as int),
      );
    }

    final signals = <Map<String, dynamic>>[];

    for (final msg in messages) {
      final body = msg['body'].toString();

      final cleanBody = body
          .replaceAll(RegExp(r'<[^>]*>'), '')
          .replaceAll('&quot;', '"')
          .replaceAll('&#34;', '"')
          .replaceAll('&#39;', "'")
          .replaceAll('&apos;', "'")
          .replaceAll('&amp;', '&');

      if (!cleanBody.contains('RTC_SIGNAL::')) {
        continue;
      }

      final jsonPart = cleanBody.split('RTC_SIGNAL::').last.trim();

      try {
        final decoded = Map<String, dynamic>.from(jsonDecode(jsonPart));

        // Do not process my own signal again.
        if (decoded['from_partner_id'] == myPartnerId) {
          continue;
        }

        // Extra safety check.
        if (currentSessionId != null &&
            currentSessionId.isNotEmpty &&
            decoded['session_id']?.toString() != currentSessionId) {
          print("IGNORING OLD SIGNAL: ${decoded['session_id']}");
          continue;
        }

        signals.add({
          'message_id': msg['id'],
          ...decoded,
        });
      } catch (e) {
        print("Signal parse error: $e");
      }
    }

    return signals;
  }
}
