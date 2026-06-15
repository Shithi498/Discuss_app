import 'dart:convert';
import 'package:http/http.dart' as http;

import '../model/search_model.dart';
import '../model/thread_model.dart';

class OdooSession {
  final String baseUrl;
  final String db;
  final int uid;
  final String sessionId;
  final Map<String, dynamic>? userContext;

  OdooSession({
    required this.baseUrl,
    required this.db,
    required this.uid,
    required this.sessionId,
    this.userContext,
  });

  String get cookie => 'session_id=$sessionId';
}

class OdooDiscussService {
  final String baseUrl;

  OdooDiscussService({required this.baseUrl});

  Uri _authenticateUri() =>
      Uri.parse('$baseUrl/web/session/authenticate');

  Uri _callKwUri(String model, String method) =>
      Uri.parse('$baseUrl/web/dataset/call_kw/$model/$method');

  Map<String, String> _headers({String? cookie}) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (cookie != null) 'Cookie': cookie,
    };
  }

  Future<OdooSession> login({
    required String db,
    required String login,
    required String password,
  }) async {
    final response = await http.post(
      _authenticateUri(),
      headers: _headers(),
      body: jsonEncode({
        'jsonrpc': '2.0',
        'params': {
          'db': db,
          'login': login,
          'password': password,
        },
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Login failed: HTTP ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;

    if (json['error'] != null) {
      print('Login failed: ${json['error']}');
      throw Exception('Login failed: ${json['error']}');
    }

    final result = json['result'] as Map<String, dynamic>?;
    final uid = result?['uid'];

    if (uid == null || uid is! int || uid <= 0) {
      throw Exception('Login failed: wrong db/login/password');
    }

    final rawCookie = response.headers['set-cookie'];
    if (rawCookie == null || !rawCookie.contains('session_id=')) {
      throw Exception('Login failed: session cookie not found');
    }

    final sessionId = _extractSessionId(rawCookie);

    final context = await getUserContext(
      cookie: 'session_id=$sessionId',
      uid: uid,
    );

    return OdooSession(
      baseUrl: baseUrl,
      db: db,
      uid: uid,
      sessionId: sessionId,
      userContext: context,
    );
  }
  String _extractSessionId(String rawCookie) {
    final parts = rawCookie.split(';');
    for (final p in parts) {
      final item = p.trim();
      if (item.startsWith('session_id=')) {
        return item.substring('session_id='.length);
      }
    }
    throw Exception('session_id not found in cookie');
  }

  Future<dynamic> callKw({
     String? cookie,
    required String model,
    required String method,
    List<dynamic> args = const [],
    Map<String, dynamic> kwargs = const {},
  }) async {
    final response = await http.post(
      _callKwUri(model, method),
      headers: _headers(cookie: cookie),
      body: jsonEncode({
        'jsonrpc': '2.0',
        'method': 'call',
        'params': {
          'model': model,
          'method': method,
          'args': args,
          'kwargs': kwargs,
        },
        'id': DateTime.now().millisecondsSinceEpoch,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'callKw failed: HTTP ${response.statusCode}, body: ${response.body}',
      );
    }

    final json = jsonDecode(response.body);

    if (json['error'] != null) {
      throw Exception('Odoo RPC error: ${json['error']}');
    }

    return json['result'];
  }


  Future<List<SearchUser>> searchUsers({
    required String cookie,
    required String query,
  }) async {
    final String text = query.trim();

    if (text.isEmpty) return [];

    final result = await callKw(
      cookie: cookie,
      model: 'res.users',
      method: 'search_read',
      args: [
        [
          '|',
          ['name', 'ilike', text],
          ['email', 'ilike', text],
          ['active', '=', true],
        ]
      ],
      kwargs: {
        'fields': ['id', 'name', 'email', 'partner_id'],
        'limit': 20,
        'order': 'name asc',
      },
    );

    final List rows = List.from(result);

    return rows.map((e) {
      final m = Map<String, dynamic>.from(e);

      int? partnerId;
      if (m['partner_id'] is List && (m['partner_id'] as List).isNotEmpty) {
        partnerId = m['partner_id'][0] as int;
      }


      return SearchUser(
        id: m['id'] as int,
        partnerId: partnerId,
        name: m['name'] ,
        email: m['email'] ,
        phone:  m['email'],
        imageUrl:  m['email'],
      );
    }).toList();
  }

  // Future<int> createOrGetThread({
  //   required String cookie,
  //   required int partnerId,
  // }) async {
  //   final result = await callKw(
  //     cookie: cookie,
  //     model: 'discuss.channel',
  //     method: 'channel_get',
  //     args: [
  //    //   [partnerId],
  //     ],
  //     kwargs: {
  //       'partners_to': [partnerId],
  //     },
  //   );
  //
  //   return result['id'] as int;
  // }

  // Future<int> createOrGetThread({
  //   required String cookie,
  //    required List<int> partnerId,
  // }) async {
  //   // if (partnerId <= 0) {
  //   //   throw Exception('Invalid partnerId: $partnerId');
  //   // }
  //
  //   final partnerData = await callKw(
  //     cookie: cookie,
  //     model: 'res.partner',
  //     method: 'read',
  //     args: [
  //      // [partnerId],
  //       partnerId,
  //       ['id', 'name'],
  //     ],
  //   );
  //
  //   if (partnerData == null || partnerData.isEmpty) {
  //     throw Exception('Partner not found for id: $partnerId');
  //   }
  //
  //   final name = partnerData[0]['name'];
  //   if (name == false || name == null || name.toString().trim().isEmpty) {
  //     await callKw(
  //       cookie: cookie,
  //       model: 'res.partner',
  //       method: 'write',
  //       args: [
  //         [partnerId],
  //         {'name': 'No Name'},
  //       ],
  //     );
  //   }
  //
  //
  //   final result = await callKw(
  //     cookie: cookie,
  //     model: 'discuss.channel',
  //     method: 'channel_get',
  //     args: [],
  //     kwargs: {
  //      // 'partners_to': [partnerId],
  //       'partners_to': partnerId,
  //     },
  //   );
  //
  //   return result['id'] as int;
  // }
  Future<int?> createAttachment({
    required String cookie,
    required int channelId,
    required String fileName,
    required String base64Data,
    required String mimeType,
  }) async {
    final result = await callKw(
      cookie: cookie,
      model: 'ir.attachment',
      method: 'create',
      args: [
        {
          'name': fileName,
          'datas': base64Data,
          'mimetype': mimeType,
          'res_model': 'discuss.channel',
          'res_id': channelId,
          'type': 'binary',
        }
      ],
      kwargs: {},
    );

    // Odoo 'create' returns the new record's integer ID if successful
    if (result is int) {
      return result;
    } else if (result is List && result.isNotEmpty) {
      return result.first as int;
    }
    return null;
  }
  Future<bool> messagePostWithAttachment({
    required String cookie,
    required int channelId,
    required String bodyText,
    required int attachmentId,
  }) async {
    final result = await callKw(
      cookie: cookie,
      model: 'discuss.channel',
      method: 'message_post',
      args: [
        [channelId], // list of channel IDs to post to
      ],
      kwargs: {
        'body': bodyText,
        'message_type': 'comment',
        'subtype_xmlid': 'mail.mt_comment',
        'attachment_ids': [attachmentId], // array of attachment IDs
      },
    );

    // Odoo message_post returns the created message ID or metadata if successful
    return result != null;
  }

  Future<List<dynamic>> fetchAttachments({
    required String cookie,
    required List<int> attachmentIds,
  }) async {
    // If the list is empty, return immediately to save a network request
    if (attachmentIds.isEmpty) return [];

    final result = await callKw(
      cookie: cookie,
      model: 'ir.attachment',
      method: 'search_read',
      args: [
        [
          ['id', 'in', attachmentIds] // Filters to match only these attachment IDs
        ],
        [
          'id',
          'name',
          'mimetype',
          'file_size',
          'res_model',
          'res_id',
          'create_date'
        ] // Fields to return
      ],
      kwargs: {},
    );


    if (result is List) {
      print("File result: $result");
      return result;
    }
    return [];
  }
  Future<bool> renameGroup({
    required String cookie,
    required int channelId,
    required String newName,
  }) async {
    final result = await callKw(
      cookie: cookie,
      model: 'discuss.channel',
      method: 'write',
      args: [
        [channelId], // list of channel IDs to update
        {'name': newName}, // new group name
      ],
      kwargs: {},
    );

    // Odoo write returns true if successful
    return result == true;
  }


  Future<String?> loadGroupName({
    required String cookie,
    required int channelId,
  }) async {
    final result = await callKw(
      cookie: cookie,
      model: 'discuss.channel',
      method: 'search_read',
      args: [
        [
          ['id', '=', channelId], // search for the channel by its ID
        ],
        ['name'], // fields to read
      ],
      kwargs: {},
    );

    if (result != null && result.isNotEmpty) {
      return result[0]['name']?.toString(); // return the name of the channel
    }
    return null; // return null if not found
  }
  Future<int> createOrGetThread({
    required String cookie,
    required int partnerId,
    required List<int> memberId,
  }) async {

    if (memberId.length > 2) {

      return createGroup(cookie: cookie, partnerIds: memberId, );
    }
    final partnerData = await callKw(
      cookie: cookie,
      model: 'res.partner',
      method: 'read',
      args: [
        partnerId,
        ['id', 'name'],
      ],
    );

    if (partnerData == null || partnerData.isEmpty) {
      throw Exception('Partner not found for id: $partnerId');
    }

    final name = partnerData[0]['name'];
    if (name == false || name == null || name.toString().trim().isEmpty) {
      await callKw(
        cookie: cookie,
        model: 'res.partner',
        method: 'write',
        args: [
          partnerId,
          {'name': 'No Name'},
        ],
      );
    }

    final result = await callKw(
      cookie: cookie,
      model: 'discuss.channel',
      method: 'channel_get',
      args: [],
      kwargs: {
        'partners_to': memberId,
      },
    );

    return result['id'] as int;
  }

  Future<dynamic> sendChatMessage({
    required String cookie,
    required int channelId,
    required String text,
  }) async {
    final message = text.trim();
    if (message.isEmpty) {
      throw Exception('Message cannot be empty');
    }

    final result = await callKw(
      cookie: cookie,
      model: 'discuss.channel',
      method: 'message_post',
      args: [channelId],
      kwargs: {
        'body': message,
        'message_type': 'comment',
        'subtype_xmlid': 'mail.mt_comment',
      },
    );

    return result!=null;
  }

  // Future<List<Map<String, dynamic>>> loadMessages({
  //   required String cookie,
  //   required int channelId,
  // }) async {
  //   final result = await callKw(
  //     cookie: cookie,
  //     model: 'mail.message',
  //     method: 'search_read',
  //     args: [
  //       [
  //         ['model', '=', 'discuss.channel'],
  //         ['res_id', '=', channelId],
  //       ]
  //     ],
  //     kwargs: {
  //       'fields': [
  //         'id',
  //         'body',
  //         'author_id',
  //         'date',
  //         'res_id',
  //         'reaction_ids',
  //         'channel_type'
  //       ],
  //       'order': 'date asc',
  //       'limit': 50,
  //     },
  //   );
  //   return List<Map<String, dynamic>>.from(result);
  // }

  Future<List<Map<String, dynamic>>> loadMessages({
    required String cookie,
    required int channelId,
  }) async {
    try {
      final result = await callKw(
        cookie: cookie,
        model: 'mail.message',
        method: 'search_read',
        args: [
          [
            ['model', '=', 'discuss.channel'],
            ['res_id', '=', channelId],
          ]
        ],
        kwargs: {
          'fields': [
            'id',
            'body',
            'author_id',
            'date',
            'res_id',
            'reaction_ids',
'partner_ids',
'attachment_ids'
          ],
          'order': 'date asc',
          'limit': 50,
        },
      );

      if (result == null || result.isEmpty) {
        print('No messages found for this channel');
        return [];
      }

      return List<Map<String, dynamic>>.from(result);
    } catch (e) {

      print('Error fetching messages: $e');
      return [];
    }
  }
  Future<bool> deleteMessage({
    required String cookie,
    required int messageId,
  }) async {
    try {
      // Matches Odoo's delete pattern exactly
      final result = await callKw(
        cookie: cookie,
        model: 'mail.message',
        method: 'unlink',
        args: [
          [messageId], // Array containing the target message ID(s) to remove
        ],
        kwargs: {}, // unlink operations do not require extra kwargs modifiers
      );

      // Odoo 'unlink' methods return true on a successful record deletion transaction
      if (result == true) {
        print('Message $messageId successfully deleted from the Odoo server.');
        return true;
      }

      print('Failed to delete message $messageId: Server rejected the transaction.');
      return false;
    } catch (e) {
      print('Error executing unlink on mail.message: $e');
      return false;
    }
  }
  Future<bool> updateMessage({
    required String cookie,
    required int messageId,
    required String updatedText,
  }) async {
    try {
      // Matches your given Odoo RPC pattern exactly
      final result = await callKw(
        cookie: cookie,
        model: 'mail.message',
        method: 'write',
        args: [
          [messageId], // The ID(s) of the message record to alter
          {
            'body': updatedText, // The key-value fields containing payload updates
          }
        ],
        kwargs: {}, // 'write' operations typically do not require extra kwargs modifiers
      );

      // Odoo 'write' methods return true on a successful record update transaction
      if (result == true) {
        print('Message $messageId updated successfully on Odoo server.');
        return true;
      }

      print('Failed to update message $messageId: Server returned false.');
      return false;
    } catch (e) {
      print('Error executing write on mail.message: $e');
      return false;
    }
  }
  Future<int> createGroup({
    required String cookie,
    required List<int> partnerIds,
    //String name = "New Group",
  }) async {
    final result = await callKw(
      cookie: cookie,
      model: 'discuss.channel',
      method: 'create_group',
      args: [

        partnerIds,
       // name,
      ],
      kwargs: {

      },
    );
    print('Odoo Channel Create Result: $result');
    return result['id'] as int;
  }
  // Future<bool> createGroup({
  //   required String cookie,
  //   required int channelId,
  //   required List<int> partnerIds,
  // }) async {
  //   if (partnerIds.isEmpty) return false;
  //
  //   try {
  //     final result = await callKw(
  //       cookie: cookie,
  //       model: 'discuss.channel',
  //       method: 'add_members',
  //
  //       args: [
  //         [channelId],
  //       ],
  //
  //       kwargs: {
  //         'partner_ids': partnerIds,
  //       },
  //     );
  //
  //     print("Add member result: $result");
  //     return true;
  //   } catch (e) {
  //     print("Odoo RPC error: $e");
  //     return false;
  //   }
  // }

  Future<void> markChannelAsRead({
    required String cookie,
    required int channelId,
    required int lastMessageId,
  }) async {
    final url = Uri.parse('$baseUrl/discuss/channel/set_last_seen_message');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Cookie': cookie,
      },
      body: jsonEncode({
        "jsonrpc": "2.0",
        "method": "call",
        "params": {
          "channel_id": channelId,
          "last_message_id": lastMessageId,
        },
        "id": DateTime.now().millisecondsSinceEpoch,
      }),
    );

    final data = jsonDecode(response.body);
print("read data,$data");
    if (data['error'] != null) {
      throw Exception("Odoo RPC error: ${data['error']}");
    }
  }

  // Future<List<int>> getOtherParticipantPartnerIds({
  //   required String cookie,
  //   required int channelId,
  //   required int myPartnerId,
  // }) async {
  //   final result = await callKw(
  //     cookie: cookie,
  //     model: 'discuss.channel.member',
  //     method: 'search_read',
  //     args: [
  //       [
  //         ['channel_id', '=', channelId],
  //       ]
  //     ],
  //     kwargs: {
  //       'fields': ['partner_id', 'seen_message_id','display_name'],
  //       'limit': 100,
  //     },
  //   );
  //
  //   print("CHANNEL MEMBERS RESULT: $result");
  //
  //   final ids = <int>[];
  //
  //   for (final item in result) {
  //     final partner = item['partner_id'];
  //
  //     if (partner is List && partner.isNotEmpty) {
  //       final id = partner[0];
  //
  //       if (id is int && id != myPartnerId) {
  //         ids.add(id);
  //       }
  //     }
  //   }
  //
  //   print("CORRECT OTHER PARTNER IDS: $ids");
  //   return ids;
  // }

  Future<List<Map<String, dynamic>>> getOtherParticipantPartnerIds({
    required String cookie,
    required int channelId,
     int? myPartnerId,
     List<int>? myPartnerIds,
  }) async {
    final result = await callKw(
      cookie: cookie,
      model: 'discuss.channel.member',
      method: 'search_read',
      args: [
        [
          ['channel_id', '=', channelId],
        ]
      ],
      kwargs: {
        'fields': ['partner_id', 'display_name'],
        'limit': 100,
      },
    );

    print("CHANNEL MEMBERS RESULT: $result");

    final participants = <Map<String, dynamic>>[];

    for (final item in result) {
      final partner = item['partner_id'];

      if (partner is List && partner.isNotEmpty) {
        final partnerId = partner[0];
        final displayName = item['display_name'] ?? 'Unknown';


        if (partnerId is int && partnerId != myPartnerId) {
          participants.add({
            'partner_id': partnerId,
            'display_name': displayName,
          });
        }
      }
    }

    print("Other participants with names: $participants");
    return participants;
   }
//   Future<Map<int, bool>> loadMessageReadStatus({
//     required String cookie,
//     required int channelId,
//     required List<int> messageIds,
//     required List<int> participantPartnerIds,
//   }) async {
//     if (messageIds.isEmpty || participantPartnerIds.isEmpty) {
//       return {};
//     }
//
//     final result = await callKw(
//       cookie: cookie,
//       model: 'discuss.channel.member',
//       method: 'search_read',
//       args: [
//         [
//           ['channel_id', '=', channelId],
//           ['partner_id', 'in', participantPartnerIds],
//         ]
//       ],
//       kwargs: {
//         'fields': [
//           'partner_id',
//           'seen_message_id',
//           'last_seen_dt',
//         ],
//         'limit': 100,
//       },
//     );
// print("result for msg seen status,$result");
//     final Map<int, bool> readStatus = {
//       for (final id in messageIds) id: false,
//     };
//
//     int maxSeenMessageId = 0;
//
//     for (final item in result) {
//       final seenMessage = item['seen_message_id'];
//
//       if (seenMessage is List && seenMessage.isNotEmpty) {
//         final seenId = seenMessage[0];
//
//         if (seenId is int && seenId > maxSeenMessageId) {
//           maxSeenMessageId = seenId;
//         }
//       }
//     }
//
//     for (final messageId in messageIds) {
//       if (messageId <= maxSeenMessageId) {
//         readStatus[messageId] = true;
//       }
//     }
//
//     print("Max seen message id: $maxSeenMessageId");
//     print("Read status: $readStatus");
//
//     return readStatus;
//   }

  Future<Map<int, bool>> loadMessageReadStatus({
    required String cookie,
    required int channelId,
    required List<int> messageIds,
    required List<int> participantPartnerIds,

  }) async {
 print("para type is not an issue then");
    if (messageIds.isEmpty || participantPartnerIds.isEmpty) {
      return {for (final id in messageIds) id: false};
    }

    try {
      final result = await callKw(
        cookie: cookie,
        model: 'discuss.channel.member',
        method: 'search_read',
        args: [
          [
      ['channel_id', '=', channelId],
        ['partner_id', 'in', participantPartnerIds],
          ]
        ],
        kwargs: {
          'fields': [
            'partner_id',
            'seen_message_id',
            'last_seen_dt',
          ],
          'limit': 100,
        },
      );

      print("result for msg seen status: $result");


      if (result == null) {
        throw Exception('Failed to fetch read status: Server returned null.');
      }

      if (result is! List) {
        throw Exception('Unexpected response format from Odoo: Expected List, got ${result.runtimeType}');
      }

      final Map<int, bool> readStatus = {
        for (final id in messageIds) id: false,
      };

      int maxSeenMessageId = 0;

      for (final item in result) {
        final seenMessage = item['seen_message_id'];


        if (seenMessage is List && seenMessage.isNotEmpty) {
          final dynamic seenId = seenMessage[0];

          if (seenId is int && seenId > maxSeenMessageId) {
            maxSeenMessageId = seenId;
          }
        } else if (seenMessage is int) {

          if (seenMessage > maxSeenMessageId) {
            maxSeenMessageId = seenMessage;
          }
        }
      }

      for (final messageId in messageIds) {
        if (messageId <= maxSeenMessageId) {
          readStatus[messageId] = true;
        }
      }

      print("Max seen message id: $maxSeenMessageId");
      return readStatus;

    } catch (e, stackTrace) {

      print("Error in loadMessageReadStatus: $e");
      print("Stacktrace: $stackTrace");

      throw Exception('Error loading message read status: ${e.toString()}');
    }
  }
  // Future<void> reactToMessage({
  //   required String cookie,
  //   required int messageId,
  //   required String emoji,
  // }) async {
  //   await callKw(
  //     cookie: cookie,
  //     model: 'mail.message.reaction',
  //     method: 'message_add_reaction',
  //     args: [
  //       [messageId],
  //     ],
  //     kwargs: {
  //       'content': emoji,
  //     },
  //
  //   );
  // }


  Future<dynamic> reactToMessage({
    required String cookie,
    required int messageId,
    required String emoji,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/mail/message/reaction'),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': cookie,
      },
      body: jsonEncode({
        "jsonrpc": "2.0",
        "method": "call",
        "params": {
          "message_id": messageId,
          "content": emoji,
          "action": "add",
        },
      }),
    );

    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    final decoded = jsonDecode(response.body);

    if (decoded['error'] != null) {
      throw Exception('Reaction failed: ${decoded['error']}');
    }

    return decoded['result'];
  }

 //
 //  Future<List<Map<String, dynamic>>> loadInboxData({
 //    required String cookie,
 //    int? limit = 20,
 //    required int myPartnerId,
 //  }) async {
 //    try {
 //
 //      final result = await callKw(
 //        cookie: cookie,
 //        model: 'mail.message',
 //        method: 'search_read',
 //        args: [
 //          [
 //
 //            ['message_type', 'in', ['comment', 'email']],
 //            ['subtype_id', '!=', false],
 //           '|',
 //           ['partner_ids', 'in', [myPartnerId]], // You received it
 //             ['author_id', '=', myPartnerId],
 //            ['channel_ids.channel_member_ids.partner_id', '=', myPartnerId],
 //
 //          ],
 //
 //          ["id", "author_id", "body", "subject", "date", "model", "record_name", "display_name", "partner_ids","res_id","message_type",]
 //
 //        ],
 //        kwargs: {
 //          'limit': limit,
 //          'order': 'date desc',
 //        },
 //      );
 //      final cleanList = <Map<String, dynamic>>[];
 //
 //      for (final raw in result as List) {
 //        final msg = Map<String, dynamic>.from(raw);
 //        final String rawBody = msg['body'].toString();
 //
 //        // Strips out all HTML structures (<p>, <b>, etc.) and converts common entities
 //        final String cleanBody = rawBody
 //            .replaceAll(RegExp(r'<[^>]*>'), '')
 //            .replaceAll('&quot;', '"')
 //            .replaceAll('&#34;', '"')
 //            .replaceAll('&amp;', '&')
 //            .trim();
 //
 //        msg['body'] = cleanBody; // Replace with clean text
 //        cleanList.add(msg);
 //      }
 //
 //      print("loadInboxData (Cleaned), $cleanList");
 //      return cleanList;
 // //  print("loadInboxData, $result");
 //    //  return List<Map<String, dynamic>>.from(result);
 //    } catch (e) {
 //      print('Error fetching inbox: $e');
 //      return [];
 //    }
 //  }

  Future<List<Map<String, dynamic>>> loadInboxData({
    required String cookie,
    int? limit = 20,
    required int myPartnerId,
  }) async {
    try {
      // STEP 1: Find all channel IDs where the user is an active member
      final List<dynamic> userChannels = await callKw(
        cookie: cookie,
        model: 'discuss.channel', // Points to Odoo's core channel table
        method: 'search_read',
        args: [
          [
            ['channel_member_ids.partner_id', '=', myPartnerId]
          ],
          ['id','name']
        ],
        kwargs: {},
      );

      // Extract the channel integer IDs into a clean Dart List
      final List<int> allowedChannelIds = userChannels
          .map<int>((ch) => ch['id'] as int)
          .toList();

      // If the user isn't in any channels yet, return an empty list early safely
      if (allowedChannelIds.isEmpty) {
        print("loadInboxData: User belongs to 0 channels.");
        return [];
      }

      // STEP 2: Fetch all messages belonging to those specific channels
      final result = await callKw(
        cookie: cookie,
        model: 'mail.message',
        method: 'search_read',
        args: [
          [
            ['message_type', 'in', ['comment', 'email']],
            ['subtype_id', '!=', false],

            ['res_id', 'in', allowedChannelIds],
            ['model', '=', 'discuss.channel'],
          ],
          // [
          //   "id", "author_id", "body", "subject", "date", "model",
          //   "record_name", "display_name", "partner_ids", "res_id", "message_type"
          // ]
          ["id", "author_id", "body", "subject", "date", "model", "record_name", "display_name", "partner_ids","res_id","message_type",]
        ],
        kwargs: {
          'limit': limit,
          'order': 'date desc',
        },
      );

      final cleanList = <Map<String, dynamic>>[];

      for (final raw in result as List) {
        final msg = Map<String, dynamic>.from(raw);
        final String rawBody = msg['body'].toString();

        // Clean the HTML paragraph strings safely
        final String cleanBody = rawBody
            .replaceAll(RegExp(r'<[^>]*>'), '')
            .replaceAll('&quot;', '"')
            .replaceAll('&#34;', '"')
            .replaceAll('&amp;', '&')
            .trim();

        msg['body'] = cleanBody;
        cleanList.add(msg);
      }

      print("loadInboxData (DMs & Groups Loaded Successfully), $cleanList");
      return cleanList;

    } catch (e) {
      print('Error fetching inbox: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getUserContext({
    required String cookie,
    required int uid,
  }) async {
    final result = await callKw(
      cookie: cookie,
      model: 'res.users',
      method: 'read',
      args: [
        [uid]
      ],
      kwargs: {
        'fields': ['id', 'name', 'login', 'email', 'partner_id', 'create_date'],
      },
    );

    if (result is List && result.isNotEmpty) {
      return result.first as Map<String, dynamic>;
    }
    return null;
  }

  Future<int> getChatCount({
    required String cookie,
    required int partnerId,
  }) async {
    final result = await callKw(
      cookie: cookie,
      model: 'discuss.channel',
      method: 'search_count',
      args: [
        [
          ['channel_partner_ids', 'in', [partnerId]]
        ]
      ],
      kwargs: {},
    );

    return (result ?? 0) as int;
  }

  Future<int> getMessageCount({
    required String cookie,
    required int partnerId,
  }) async {
    final result = await callKw(
      cookie: cookie,
      model: 'mail.message',
      method: 'search_count',
      args: [
        [
          ['author_id', '=', partnerId]
        ]
      ],
      kwargs: {},
    );
print("result,$result ");
    return (result ?? 0) as int;
  }
  Future<Map<String, dynamic>?> getPartnerProfile({
    required String cookie,
    required int partnerId,
  }) async {
    final result = await callKw(
      cookie: cookie,
      model: 'res.partner',
      method: 'read',
      args: [
        [partnerId]
      ],
      kwargs: {
        'fields': [
          'id',
          'name',
          'email',
          'phone',
          'mobile',
          'street',
          'city',
          'country_id',
          'image_1920',
          'company_name',
          'function',
        ],
      },
    );

    if (result is List && result.isNotEmpty) {
      return result.first;
    }
    return null;
  }
  Future<int?> getCurrentUserPartnerId({
    required String cookie,
    required int uid,
  }) async {
    final user = await getUserContext(cookie: cookie, uid: uid);
    if (user == null) return null;

    final partner = user['partner_id'];
    if (partner is List && partner.isNotEmpty) {
      return partner.first as int;
    }
    return null;
  }

  Future<List<dynamic>> listChannels({
    required String cookie,
    int limit = 50,
  }) async {
    final result = await callKw(
      cookie: cookie,
      model: 'mail.channel',
      method: 'search_read',
      args: [
        []
      ],
      kwargs: {
        'fields': ['id', 'name', 'channel_type', 'create_date'],
        'limit': limit,
        'order': 'id desc',
      },
    );

    return (result as List).cast<dynamic>();
  }

  Future<List<dynamic>> listChannelsForCurrentPartner({
    required String cookie,
    required int partnerId,
    int limit = 50,
  }) async {
    final result = await callKw(
      cookie: cookie,
      model: 'mail.channel',
      method: 'search_read',
      args: [
        [
          ['channel_partner_ids', 'in', [partnerId]]
        ]
      ],
      kwargs: {
        'fields': ['id', 'name', 'channel_type', 'create_date'],
        'limit': limit,
        'order': 'id desc',
      },
    );

    return (result as List).cast<dynamic>();
  }

  Future<List<dynamic>> getChannelMessages({
    required String cookie,
    required int channelId,
    int limit = 30,
    int offset = 0,
  }) async {
    final result = await callKw(
      cookie: cookie,
      model: 'mail.message',
      method: 'search_read',
      args: [
        [
          ['model', '=', 'mail.channel'],
          ['res_id', '=', channelId],
        ]
      ],
      kwargs: {
        'fields': [
          'id',
          'body',
          'author_id',
          'date',
          'message_type',
          'subtype_id',
        ],
        'limit': limit,
        'offset': offset,
        'order': 'date desc',
      },
    );

    return (result as List).cast<dynamic>();
  }

  Future<dynamic> sendMessageToChannel({
    required String cookie,
    required int channelId,
    required String body,
  }) async {
    final result = await callKw(
      cookie: cookie,
      model: 'mail.channel',
      method: 'message_post',
      args: [channelId],
      kwargs: {
        'body': body,
        'message_type': 'comment',
      },
    );

    return result;
  }

  // Future<dynamic> startAudioCall17({
  //   required String cookie,
  //   required int channelId,
  //   required int partnerId,
  // }) async {
  //   try {
  //     final result = await callKw(
  //       cookie: cookie,
  //       model: 'discuss.channel.rtc.session',
  //       method: 'create', // Standard Odoo create
  //       args: [{
  //         'channel_id': channelId,
  //         'partner_id': partnerId,
  //         'is_camera_on': false,
  //         'is_deaf': false,       // Assuming the partner is not deaf
  //         'is_muted': false,      // Assuming the partner is not muted
  //         'is_screen_sharing_on': false, //
  //       }],
  //       kwargs: {},
  //     );
  //
  //     print("call result, $result");
  //     return result;
  //   } catch (e) {
  //     print("Error joining RTC call: $e");
  //     rethrow;
  //   }
  // }

  // Future<dynamic> startAudioCall17({
  //   required String cookie,
  //   required int channelId,
  //   required int partnerId,
  //   required int memberId
  // }) async {
  //   try {
  //
  //     print("Starting audio call with the following parameters:");
  //     print("Cookie: $cookie");
  //     print("Channel ID: $channelId");
  //     print("Partner ID: $partnerId");
  //
  //     final callArgs = {
  //       'channel_id': channelId,
  //       'partner_id': partnerId,
  //       'is_camera_on': true,
  //       'is_deaf': false,
  //       'is_muted': false,
  //       'is_screen_sharing_on': false,
  //       'channel_member_id':memberId
  //     };
  //
  //
  //     print("Call Arguments: $callArgs");
  //
  //     final result = await callKw(
  //       cookie: cookie,
  //       model: 'discuss.channel.rtc.session',
  //       method: 'create',
  //       args: [callArgs],
  //       kwargs: {},
  //     );
  //
  //
  //     print("Call result: $result");
  //
  //     return result;
  //   } catch (e) {
  //
  //     print("Error joining RTC call: $e");
  //
  //
  //     print("Failed with the following parameters:");
  //     print("Cookie: $cookie");
  //     print("Channel ID: $channelId");
  //     print("Partner ID: $partnerId");
  //
  //
  //     rethrow;
  //   }
  // }
  Future<dynamic> startAudioCall17({
    required String cookie,
    required int channelId,
    required int partnerId,
  }) async {

    try {

      final realMemberId = await getMyChannelMemberId(
        cookie: cookie,
        channelId: channelId,
        partnerId: partnerId,
      );

      if (realMemberId == null) {
        throw Exception(
          "No discuss.channel.member found",
        );
      }

      print("REAL MEMBER ID: $realMemberId");

      final callArgs = {
       // 'channel_id': channelId,
       // 'partner_id': partnerId,
       // 'is_camera_on': false,
      //  'is_deaf': false,
    //    'is_muted': false,
       // 'is_screen_sharing_on': false,
        'channel_member_id': realMemberId,
      };

      print("Call Arguments: $callArgs");

      final result = await callKw(
        cookie: cookie,
        model: 'discuss.channel.rtc.session',
        method: 'create',
        args: [callArgs],
        kwargs: {},
      );

      print("Call result: $result");

      return result;

    } catch (e) {

      print("Error joining RTC call: $e");

      rethrow;
    }
  }

  //
  // Future<dynamic> receiveAudioCall17({
  //   required String cookie,
  //   required int channelId,
  //   required int myPartnerId,
  //   required int myMemberId,
  // }) async {
  //   try {
  //     print("Receiving audio call...");
  //     print("Cookie: $cookie");
  //     print("Channel ID: $channelId");
  //     print("My Partner ID: $myPartnerId");
  //     print("My Member ID: $myMemberId");
  //
  //     final callArgs = {
  //       'channel_id': channelId,
  //       'partner_id': myPartnerId,
  //       'is_camera_on': false,
  //       'is_deaf': false,
  //       'is_muted': false,
  //       'is_screen_sharing_on': false,
  //       'channel_member_id': myMemberId,
  //     };
  //
  //     print("Receive Call Arguments: $callArgs");
  //
  //     final result = await callKw(
  //       cookie: cookie,
  //       model: 'discuss.channel.rtc.session',
  //       method: 'create',
  //       args: [callArgs],
  //       kwargs: {},
  //     );
  //
  //     print("Receive call result: $result");
  //
  //     return result;
  //   } catch (e) {
  //     print("Error receiving RTC call: $e");
  //     print("Failed with:");
  //     print("Cookie: $cookie");
  //     print("Channel ID: $channelId");
  //     print("My Partner ID: $myPartnerId");
  //     print("My Member ID: $myMemberId");
  //
  //     rethrow;
  //   }
  // }
  Future<int?> getMyChannelMemberId({
    required String cookie,
    required int channelId,
    required int partnerId,
  }) async {

    final result = await callKw(
      cookie: cookie,
      model: 'discuss.channel.member',
      method: 'search_read',
      args: [
        [
          ['channel_id', '=', channelId],
          ['partner_id', '=', partnerId],
        ]
      ],
      kwargs: {
        'fields': ['id', 'partner_id'],
        'limit': 1,
      },
    );

    print("MY CHANNEL MEMBER RESULT: $result");

    if (result == null || result.isEmpty) {
      return null;
    }

    return result[0]['id'];
  }
  // Future<dynamic> receiveAudioCall17({
  //   required String cookie,
  //   required int channelId,
  //   required int myPartnerId,
  // }) async {
  //   try {
  //     final realMemberId = await getOtherParticipantPartnerIds(
  //       cookie: cookie,
  //       channelId: channelId,
  //       myPartnerId: myPartnerId,
  //     );
  //
  //     if (realMemberId == null) {
  //       throw Exception("No discuss.channel.member found for this channel/user");
  //     }
  //
  //     final callArgs = {
  //       'channel_id': channelId,
  //       'partner_id': myPartnerId,
  //       'is_camera_on': false,
  //       'is_deaf': false,
  //       'is_muted': false,
  //       'is_screen_sharing_on': false,
  //       'channel_member_id': realMemberId,
  //     };
  //
  //     print("Receive Call Arguments: $callArgs");
  //
  //     final result = await callKw(
  //       cookie: cookie,
  //       model: 'discuss.channel.rtc.session',
  //       method: 'create',
  //       args: [callArgs],
  //       kwargs: {},
  //     );
  //
  //     print("Receive call result: $result");
  //
  //     return result;
  //   } catch (e) {
  //     print("Error receiving RTC call: $e");
  //     rethrow;
  //   }
  // }
  Future<int> getCurrentPartnerId({
    required String cookie,
    required int uid,
  }) async {
    final result = await callKw(
      cookie: cookie,
      model: 'res.users',
      method: 'read',
      args: [
        [uid],
        ['partner_id'],
      ],
      kwargs: {},
    );

    print("CURRENT USER RESULT: $result");

    if (result == null || result.isEmpty) {
      throw Exception("No res.users found for uid=$uid");
    }

    final partner = result[0]['partner_id'];

    if (partner == false || partner == null || partner is! List || partner.isEmpty) {
      throw Exception("No partner_id found for uid=$uid");
    }

    return partner[0] as int;
  }

  Future<dynamic> receiveAudioCall17({
    required String cookie,
    required int channelId,
    required int partnerId,
  }) async {
    try {
      print("DEBUG channelId: $channelId");
      print("DEBUG myPartnerId: $partnerId");

      final realMemberId = await getMyChannelMemberId(
        cookie: cookie,
        channelId: channelId,
        partnerId: partnerId,
      );

      if (realMemberId == null) {
        throw Exception(
          "No discuss.channel.member found for channelId=$channelId and partnerId=$partnerId",
        );
      }

      final callArgs = {
        'channel_member_id': realMemberId,
        'is_camera_on': false,
        'is_deaf': false,
        'is_muted': false,
        'is_screen_sharing_on': false,
      };

      print("Receive Call Arguments: $callArgs");

      final result = await callKw(
        cookie: cookie,
        model: 'discuss.channel.rtc.session',
        method: 'create',
        args: [callArgs],
        kwargs: {},
      );

      print("Receive call result: $result");

      return result;
    } catch (e) {
      print("Error receiving RTC call: $e");
      rethrow;
    }
  }

  // Future<dynamic> receiveAudioCall17({
  //   required String cookie,
  //   required int channelId,
  //   required int myPartnerId,
  // }) async {
  //   try {
  //
  //     final realMemberId = await getMyChannelMemberId(
  //       cookie: cookie,
  //       channelId: channelId,
  //       partnerId: myPartnerId,
  //     );
  //
  //     if (realMemberId == null) {
  //       throw Exception(
  //         "No discuss.channel.member found for this channel/user",
  //       );
  //     }
  //
  //     final callArgs = {
  //       'channel_id': channelId,
  //       'partner_id': myPartnerId,
  //       'is_camera_on': false,
  //       'is_deaf': false,
  //       'is_muted': false,
  //       'is_screen_sharing_on': false,
  //       'channel_member_id': realMemberId,
  //     };
  //
  //     print("Receive Call Arguments: $callArgs");
  //
  //     final result = await callKw(
  //       cookie: cookie,
  //       model: 'discuss.channel.rtc.session',
  //       method: 'create',
  //       args: [callArgs],
  //       kwargs: {},
  //     );
  //
  //     print("Receive call result: $result");
  //
  //     return result;
  //
  //   } catch (e) {
  //
  //     print("Error receiving RTC call: $e");
  //
  //     rethrow;
  //   }
  // }

  Future<dynamic> endAudioCall({
    required String cookie,
    required int channelId,
  }) async {
    try {
      final result = await callKw(
        cookie: cookie,
        model: 'discuss.channel.rtc.session',
        method: 'unlink',
        args: [channelId],
        kwargs: {},
      );
      return result;
    } catch (e) {
      print("Error leaving RTC call: $e");
      rethrow;
    }
  }

  Future<List<dynamic>> fieldsGet({
    required String cookie,
    required String model,
  }) async {
    final result = await callKw(
      cookie: cookie,
      model: model,
      method: 'fields_get',
      args: const [],
      kwargs: {
        'attributes': ['string', 'type', 'relation', 'required', 'readonly'],
      },
    );

    if (result is Map<String, dynamic>) {
      return result.entries
          .map((e) => {
        'name': e.key,
        ...((e.value as Map).cast<String, dynamic>()),
      })
          .toList();
    }

    return [];
  }
}
