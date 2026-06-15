// import 'package:flutter/foundation.dart';
//
// import '../model/thread_model.dart';
// import '../repo/marked_read_repo.dart';
// import '../services/odoo_discuss_service.dart';
//
// class MessageReadStatusProvider extends ChangeNotifier {
//   final OdooDiscussService service;
//
//   MessageReadStatusProvider(this.service);
//
//   bool loading = false;
//   String? error;
//
//   final Map<int, bool> _readStatus = {};
//
//   Map<int, bool> get readStatus => _readStatus;
//
//   bool isMessageRead(int messageId) {
//     return _readStatus[messageId] ?? false;
//   }
//
//   Future<void> loadReadStatus({
//     required String cookie,
//     required int channelId,
//     required List<int> messageIds,
//   //  required List<int> participantPartnerIds,
//     required int myPartnerId,
//   }) async {
//     // if (messageIds.isEmpty || participantPartnerIds.isEmpty) {
//     //   return;
//     // }
//
//     loading = true;
//     error = null;
//     notifyListeners();
//
//     try {
//
//       final otherPartnerIds =
//       await service.getOtherParticipantPartnerIds(
//         cookie: cookie,
//         channelId: channelId,
//         myPartnerId: myPartnerId,
//       );
//
//       print("Other partner ids for seen status: $otherPartnerIds");
//
//       if (otherPartnerIds.isEmpty) {
//         _readStatus.clear();
//         for (final id in messageIds) {
//           _readStatus[id] = false;
//         }
//         loading = false;
//         notifyListeners();
//         return;
//       }
//
//       final result = await service.loadMessageReadStatus(
//         cookie: cookie,
//         channelId: channelId,
//         messageIds: messageIds,
//         participantPartnerIds: otherPartnerIds,
//       );
//
//       _readStatus.clear();
//       _readStatus.addAll(result);
//       print("_readStatus,$_readStatus");
//     } catch (e) {
//       error = e.toString();
//       print("Read status error: $e");
//     }
//
//     loading = false;
//     notifyListeners();
//   }
// }
import 'package:flutter/cupertino.dart';

import '../model/group_participents.dart';
import '../services/odoo_discuss_service.dart';

class MessageReadStatusProvider extends ChangeNotifier {
  final OdooDiscussService service;

  MessageReadStatusProvider(this.service);

  bool loading = false;
  String? error;

  final Map<int, bool> _readStatus = {};
  final List<GroupParticipant> _participants = [];

  Map<int, bool> get readStatus => _readStatus;
  List<GroupParticipant> get participants => _participants;
  late final List<String> _participantNames = [];
  List<String> get participantNames => _participantNames;
  bool isMessageRead(int messageId) {
    return _readStatus[messageId] ?? false;
  }

  Future<void> loadReadStatus({

    required String cookie,

    required int channelId,

    required List<int> messageIds,

    required int myPartnerId,

    required List<int>? myPartnerIds,

  }) async {

    loading = true;

    error = null;

    notifyListeners();



    try {



      final otherParticipants = await service.getOtherParticipantPartnerIds(

          cookie: cookie,

          channelId: channelId,

          myPartnerId: myPartnerId,
        //  myPartnerId: [myPartnerId],
          myPartnerIds: myPartnerIds

      );



      print("Other participants: $otherParticipants");





      if (otherParticipants.isEmpty) {

        _readStatus.clear();

        for (final id in messageIds) {

          _readStatus[id] = false;

        }

        loading = false;

        notifyListeners();

        return;

      }



      final participantPartnerIds = otherParticipants.map<int>((participant) {

        return participant['partner_id'];

      }).toList();



      print("Extracted participant partner ids: $participantPartnerIds");

      print("Type of list: ${participantPartnerIds.runtimeType}");
      // _participants.clear();
      //
      // for (var participant in otherParticipants) {
      //
      //   final groupParticipant = GroupParticipant(
      //
      //     partnerId: participant['partner_id'],
      //
      //     displayName: participant['display_name'],
      //
      //   );
      //
      //   _participants.add(groupParticipant);
      //
      // }



// final result = await service.loadMessageReadStatus(

// cookie: cookie,

// channelId: channelId,

// messageIds: messageIds,

// participantPartnerIds: participantPartnerIds,

// );
      final result = await service.loadMessageReadStatus(

        cookie: cookie,

        channelId: channelId,

        messageIds: messageIds,

        participantPartnerIds: participantPartnerIds,

      );

      print(result);

      _readStatus.clear();

      _readStatus.addAll(result);

      print("_readStatus: $_readStatus");

      _participants.clear();

      for (var participant in otherParticipants) {

        final groupParticipant = GroupParticipant(

          partnerId: participant['partner_id'],

          displayName: participant['display_name'],

        );

        _participants.add(groupParticipant);

      }

    } catch (e) {

      error = e.toString();

      print("Read status error: $e");

    }



    loading = false;

    notifyListeners();

  }


  // String getDisplayNameForPartnerId(List<int> partnerId) {
  //   final participant = _participants.firstWhere(
  //         (p) => p.partnerId == partnerId,
  //     orElse: () => GroupParticipant(partnerId: partnerId, displayName: 'Unknown'),
  //   );
  //   return participant.displayName;
  // }

  String getDisplayNameForPartnerId(List<int> partnerIds) {

    final participant = _participants.firstWhere(
          (p) => partnerIds.contains(p.partnerId),
      orElse: () => GroupParticipant(partnerId:[1], displayName: 'Unknown'),
    );

    return participant.displayName;
  }
}