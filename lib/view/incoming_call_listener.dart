import 'dart:async';
import 'package:flutter/material.dart';

//
// class IncomingCallListener {
// Timer? _timer;
// bool _isCallPageOpen = false;
// int? _lastRtcSessionId;
//
// void startListening({
// required BuildContext context,
// required String cookie,
// required int myPartnerId,
//   required Function(Map<String, dynamic> inviteData) onCallReceived,
// required Future<dynamic> Function({
// required String cookie,
// required String model,
// required String method,
// required List args,
// required Map<String, dynamic> kwargs,
// }) callKw,
// }) {
// _timer?.cancel();
// debugPrint("=====> [GLOBAL_RADAR] Polling Engine Initialized for Partner ID: $myPartnerId");
//
// _timer = Timer.periodic(const Duration(seconds: 3), (_) async {
// if (_isCallPageOpen) return;
//
// try {
// // STEP 1: Find all channels the current user is a member of to avoid snatching unrelated server calls
// final myChannelsResult = await callKw(
// cookie: cookie,
// model: 'discuss.channel.member',
// method: 'search_read',
// args: [
// [
// ['partner_id', '=', myPartnerId],
// ]
// ],
// kwargs: {
// 'fields': ['channel_id'],
// 'limit': 100,
// },
// );
//
// if (myChannelsResult == null || myChannelsResult.isEmpty) return;
//
// // Extract clean IDs of channels I belong to
// List<int> myChannelIds = [];
// for (final m in myChannelsResult) {
// final channelData = m['channel_id'];
// if (channelData is List && channelData.isNotEmpty) {
// myChannelIds.add(channelData[0] as int);
// }
// }
//
// if (myChannelIds.isEmpty) return;
//
// // STEP 2: Scan for active remote RTC sessions inside MY channels only
// final result = await callKw(
// cookie: cookie,
// model: 'discuss.channel.rtc.session',
// method: 'search_read',
// args: [
// [
// ['channel_id', 'in', myChannelIds],
// ['partner_id', '!=', myPartnerId],
// ]
// ],
// kwargs: {
// 'fields': [
// 'id',
// 'channel_id',
// 'partner_id',
// 'channel_member_id',
// ],
// 'limit': 1,
// 'order': 'id desc',
// },
// );
//
// if (result == null || result.isEmpty) return;
//
// final rtcSession = result[0];
// final int rtcSessionId = rtcSession['id'];
//
// // Guard: Skip processing if we've already evaluated or shown this specific session event frame
// if (_lastRtcSessionId == rtcSessionId) return;
//
// final channel = rtcSession['channel_id'];
// if (channel == null) return;
//
// final int incomingChannelId = channel[0];
// final String targetChannelName = channel.length > 1 ? channel[1].toString() : 'test_discuss';
//
// final rtcChannelMember = rtcSession['channel_member_id'];
// int? rtcChannelMemberId;
// if (rtcChannelMember is List && rtcChannelMember.isNotEmpty) {
// rtcChannelMemberId = rtcChannelMember.first as int;
// } else if (rtcChannelMember is int) {
// rtcChannelMemberId = rtcChannelMember;
// }
//
// // STEP 3: Grab all structural room members to cross-examine IDs and establish names
// final channelMembers = await callKw(
// cookie: cookie,
// model: 'discuss.channel.member',
// method: 'search_read',
// args: [
// [
// ['channel_id', '=', incomingChannelId],
// ]
// ],
// kwargs: {
// 'fields': ['id', 'partner_id'],
// 'limit': 100,
// },
// );
//
// if (channelMembers == null || channelMembers.isEmpty) return;
//
// Map<String, dynamic>? myChannelMember;
// Map<String, dynamic>? callerChannelMember;
//
// for (final member in channelMembers) {
// if (member is! Map) continue;
// final mappedMember = Map<String, dynamic>.from(member);
// final partner = mappedMember['partner_id'];
//
// if (partner is! List || partner.isEmpty) continue;
//
// if (partner.first == myPartnerId) {
// myChannelMember = mappedMember;
// } else if (mappedMember['id'] == rtcChannelMemberId) {
// callerChannelMember = mappedMember;
// } else if (callerChannelMember == null) {
// callerChannelMember = mappedMember;
// }
// }
//
// if (myChannelMember == null || callerChannelMember == null) return;
//
// final int myChannelMemberId = myChannelMember['id'];
// final caller = callerChannelMember['partner_id'] as List;
// final int callerPartnerId = caller.first as int;
// final String callerName = caller.length > 1 ? caller[1].toString() : "Incoming Caller";
//
// // STEP 4: Double check I haven't already initialized an engine session myself here
// final myExistingSession = await callKw(
// cookie: cookie,
// model: 'discuss.channel.rtc.session',
// method: 'search_read',
// args: [
// [
// ['channel_id', '=', incomingChannelId],
// ['partner_id', '=', myPartnerId],
// ]
// ],
// kwargs: {
// 'fields': ['id'],
// 'limit': 1,
// },
// );
//
// if (myExistingSession != null && myExistingSession.isNotEmpty) return;
//
// // Session validation complete! Block incoming triggers and cache last handled ID state
// _lastRtcSessionId = rtcSessionId;
// _isCallPageOpen = true;
//
// if (!context.mounted) {
// _isCallPageOpen = false;
// return;
// }
//
// // STEP 5: Launch UI Alert Overlay Modally over global context tree structure
// _showIncomingCallUi(
// context: context,
// callerName: callerName,
// fromPartnerId: callerPartnerId,
// targetChannel: targetChannelName,
// );
//
// } catch (e) {
// debugPrint("=====> [GLOBAL_RADAR_ERROR] Runtime exception caught: $e");
// _isCallPageOpen = false;
// }
// });
// }
//
// void _showIncomingCallUi({
// required BuildContext context,
// required String callerName,
// required int fromPartnerId,
// required String targetChannel,
// }) {
// showDialog(
// context: context,
// barrierDismissible: false,
// builder: (BuildContext dialogContext) {
// return AlertDialog(
// backgroundColor: const Color(0xff101828),
// shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
// title: const Text(
// "Incoming Call",
// style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
// textAlign: TextAlign.center,
// ),
// content: Column(
// mainAxisSize: MainAxisSize.min,
// children: [
// const Icon(Icons.phone_in_talk, color: Colors.greenAccent, size: 68),
// const SizedBox(height: 20),
// Text(
// "$callerName (User $fromPartnerId) is calling you...",
// style: const TextStyle(color: Colors.white70, fontSize: 15),
// textAlign: TextAlign.center,
// ),
// ],
// ),
// actionsAlignment: MainAxisAlignment.spaceEvenly,
// actions: [
// TextButton(
// onPressed: () {
// debugPrint("=====> [CALL_UI] User Clicked Decline.");
// Navigator.pop(dialogContext); // Close the Alert Window Box cleanly
// _isCallPageOpen = false;       // Unblock listener flag tracking loop
// },
// child: const Text("Decline", style: TextStyle(color: Colors.redAccent, fontSize: 16)),
// ),
// ElevatedButton(
// style: ElevatedButton.styleFrom(
// backgroundColor: Colors.green,
// shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
// padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
// ),
// onPressed: () async {
// debugPrint("=====> [CALL_UI] User Clicked Answer.");
// Navigator.pop(dialogContext); // Dismiss overlay dialog layout frame cleanly
//
// // Grab username properties cleanly via context state read hooks securely
// String currentUserName = "User";
// try {
// // Adaptive fallbacks if AuthProvider details vary slightly at implementation layers
// final dynamic authProv = context.read<Map<String, dynamic>>(); // Adjust to match your provider type
// currentUserName = authProv.userName ?? "User";
// } catch (_) {}
//
// // Execute safe structural route replacement swap out mapping layer to active stream viewport
// // REPLACE AgoraCallPage with your preferred call screen widget constructor parameters
// await Navigator.push(
// context,
// MaterialPageRoute(
// builder: (_) => AgoraCallPage(
// channelName: targetChannel,
// callerName: currentUserName,
// appId: "339***************fba", // Replace with your standard testingAppId handle variable references
// token: "007eJxTYOhd4hKf2P1tk69UJF+r1JLbt+adj7RdteKt6LrKH9ufaRspMBgbWxqYGiSlJhumpZpYJlkkJZumGponJ1qmmBtbpiUluotpZjUEMjLcE9jGxMgAgSA+D0NJanFJfEpmcXJpcTEDAwCl1COb",
// ),
// ),
// );
//
// // Once user leaves the Agora Call screen page later down the line, release background lock
// _isCallPageOpen = false;
// debugPrint("=====> [CALL_UI] Call screen terminated. Radar polling listener resumed.");
// },
// child: const Text("Answer", style: TextStyle(color: Colors.white, fontSize: 16)),
// )
// ],
// );
// },
// );
// }
//
// void stopListening() {
// _timer?.cancel();
// _timer = null;
// _isCallPageOpen = false;
// debugPrint("=====> [GLOBAL_RADAR] Call Invitation Service stopped.");
// }
// }
class IncomingCallListener {
  Timer? _timer;
  bool _isCallPageOpen = false;
  bool _isTickRunning = false;
  int? _lastCheckedCallId;
  DateTime? _listenerStartedAt;
  //
  // void startListening({
  //   required BuildContext context,
  //   required String cookie,
  //   required int myPartnerId,
  //   required Function(Map<String, dynamic> inviteData) onCallReceived,
  //   required Future<dynamic> Function({
  //     required String cookie,
  //     required String model,
  //     required String method,
  //     required List args,
  //     required Map<String, dynamic> kwargs,
  //   })
  //   callKw,
  // }) {
  //   _timer?.cancel();
  //   _listenerStartedAt = DateTime.now().subtract(const Duration(seconds: 30));
  //
  //   debugPrint(
  //     "=====> [GLOBAL_RADAR] Agora call polling initialized for Partner ID: $myPartnerId",
  //   );
  //
  //   _timer = Timer.periodic(const Duration(seconds: 3), (_) async {
  //     if (_isCallPageOpen) {
  //       debugPrint(
  //         "=====> [GLOBAL_RADAR] Loop skipped: A call UI or page is actively open.",
  //       );
  //       return;
  //     }
  //
  //     if (_isTickRunning) {
  //       debugPrint(
  //         "=====> [GLOBAL_RADAR] Loop skipped: Previous radar tick is still running.",
  //       );
  //       return;
  //     }
  //
  //     _isTickRunning = true;
  //
  //     try {
  //       final myChannelsResult = await callKw(
  //         cookie: cookie,
  //         model: 'discuss.channel.member',
  //         method: 'search_read',
  //         args: [
  //           [
  //             ['partner_id', '=', myPartnerId],
  //           ],
  //         ],
  //         kwargs: {
  //           'fields': ['channel_id'],
  //           'limit': 100,
  //         },
  //       );
  //
  //       debugPrint(
  //         "=====> [RADAR_ENGINE] My Channels query result: ${myChannelsResult?.length ?? 0} channels found.",
  //       );
  //
  //       if (myChannelsResult == null || myChannelsResult.isEmpty) {
  //         debugPrint(
  //           "=====> [RADAR_ENGINE] Exit: Current user does not belong to any channels.",
  //         );
  //         return;
  //       }
  //
  //       final List<int> myChannelIds = [];
  //
  //       for (final member in myChannelsResult) {
  //         if (member is! Map) continue;
  //
  //         final channelData = member['channel_id'];
  //         if (channelData is List &&
  //             channelData.isNotEmpty &&
  //             channelData.first is int) {
  //           myChannelIds.add(channelData.first as int);
  //         }
  //       }
  //
  //       if (myChannelIds.isEmpty) {
  //         debugPrint(
  //           "=====> [RADAR_ENGINE] Exit: Extracted channel ID list parsed out completely empty.",
  //         );
  //         return;
  //       }
  //
  //       final List<List<dynamic>> domain = [
  //         ['channel_id', 'in', myChannelIds],
  //         ['receiver_partner_id', '=', myPartnerId],
  //         ['state', '=', 'ringing'],
  //       ];
  //
  //       if (_lastCheckedCallId != null) {
  //         domain.add(['id', '>', _lastCheckedCallId]);
  //       }
  //
  //       final result = await callKw(
  //         cookie: cookie,
  //         model: 'discuss.agora.call',
  //         method: 'search_read',
  //         args: [domain],
  //         kwargs: {
  //           'fields': [
  //             'id',
  //             'name',
  //             'channel_id',
  //             'caller_partner_id',
  //             'receiver_partner_id',
  //             'call_type',
  //             'state',
  //             'started_at',
  //             'accepted_at',
  //             'ended_at',
  //             'duration_seconds',
  //           ],
  //           'order': 'id asc',
  //           'limit': 30,
  //         },
  //       );
  //
  //       debugPrint("=====> [RADAR_ENGINE] Agora call result: $result");
  //
  //       if (result == null || result.isEmpty) {
  //         debugPrint(
  //           "=====> [RADAR_ENGINE] Exit: No ringing Agora calls found.",
  //         );
  //         return;
  //       }
  //
  //       for (final rawCall in result) {
  //         if (rawCall is! Map) continue;
  //
  //         final call = Map<String, dynamic>.from(rawCall);
  //         final int? callId = _asInt(call['id']);
  //
  //         if (callId != null) {
  //           _lastCheckedCallId = callId;
  //         }
  //
  //         final callerPartner = call['caller_partner_id'];
  //         final receiverPartner = call['receiver_partner_id'];
  //         final channel = call['channel_id'];
  //
  //         final int? toPartnerId = _partnerIdFromRelation(receiverPartner);
  //         final int? fromPartnerId = _partnerIdFromRelation(callerPartner);
  //
  //         if (toPartnerId != myPartnerId) {
  //           debugPrint(
  //             "=====> [RADAR_ENGINE] Exit: Call is not for this user.",
  //           );
  //           continue;
  //         }
  //
  //         if (fromPartnerId == myPartnerId) {
  //           debugPrint(
  //             "=====> [RADAR_ENGINE] Exit: Ignoring own outgoing call.",
  //           );
  //           continue;
  //         }
  //
  //         final startedAt = DateTime.tryParse(
  //           call['started_at']?.toString() ?? '',
  //         );
  //         if (startedAt != null &&
  //             _listenerStartedAt != null &&
  //             startedAt.isBefore(_listenerStartedAt!)) {
  //           debugPrint("=====> [RADAR_ENGINE] Exit: Ignoring old call.");
  //           continue;
  //         }
  //
  //         if (!context.mounted) {
  //           debugPrint(
  //             "=====> [RADAR_ENGINE] Exit Failure: Context is unmounted.",
  //           );
  //           return;
  //         }
  //
  //         debugPrint("=====> [RADAR_ENGINE] Incoming Agora call accepted.");
  //
  //         _isCallPageOpen = true;
  //
  //         onCallReceived({
  //           'call_id': callId,
  //           'type': 'agora_incoming_call',
  //           'agora_call': true,
  //           'agora_channel_name': call['name'],
  //           'channel_id': channel is List && channel.isNotEmpty
  //               ? channel.first
  //               : channel,
  //           'call_type': call['call_type'],
  //           'state': call['state'],
  //           'from_partner_id': fromPartnerId,
  //           'from_partner_name': _partnerNameFromRelation(callerPartner),
  //           'to_partner_id': toPartnerId,
  //           'to_partner_name': _partnerNameFromRelation(receiverPartner),
  //           'started_at': call['started_at'],
  //           'accepted_at': call['accepted_at'],
  //           'ended_at': call['ended_at'],
  //           'duration_seconds': call['duration_seconds'],
  //         });
  //         return;
  //       }
  //     } catch (e) {
  //       debugPrint("=====> [GLOBAL_RADAR_ERROR] Runtime exception caught: $e");
  //       _isCallPageOpen = false;
  //     } finally {
  //       _isTickRunning = false;
  //     }
  //   });
  // }
  void startListening({
    required BuildContext context,
    required String cookie,
    required int myPartnerId,
    required Function(Map<String, dynamic> inviteData) onCallReceived,
    required Future<dynamic> Function({
    required String cookie,
    required String model,
    required String method,
    required List args,
    required Map<String, dynamic> kwargs,
    }) callKw,
  }) {
    _timer?.cancel();

    // We no longer rely on fragile client-side clock time arithmetic!
    debugPrint(
      "=====> [GLOBAL_RADAR] Agora call polling initialized for Partner ID: $myPartnerId",
    );

    _timer = Timer.periodic(const Duration(seconds: 3), (_) async {
      if (_isCallPageOpen) {
        debugPrint(
          "=====> [GLOBAL_RADAR] Loop skipped: A call UI or page is actively open.",
        );
        return;
      }

      if (_isTickRunning) {
        debugPrint(
          "=====> [GLOBAL_RADAR] Loop skipped: Previous radar tick is still running.",
        );
        return;
      }

      _isTickRunning = true;

      try {
        final myChannelsResult = await callKw(
          cookie: cookie,
          model: 'discuss.channel.member',
          method: 'search_read',
          args: [
            [
              ['partner_id', '=', myPartnerId],
            ],
          ],
          kwargs: {
            'fields': ['channel_id'],
            'limit': 100,
          },
        );

        debugPrint(
          "=====> [RADAR_ENGINE] My Channels query result: ${myChannelsResult?.length ?? 0} channels found.",
        );

        if (myChannelsResult == null || myChannelsResult.isEmpty) {
          debugPrint(
            "=====> [RADAR_ENGINE] Exit: Current user does not belong to any channels.",
          );
          return;
        }

        final List<int> myChannelIds = [];
        for (final member in myChannelsResult) {
          if (member is! Map) continue;
          final channelData = member['channel_id'];
          if (channelData is List &&
              channelData.isNotEmpty &&
              channelData.first is int) {
            myChannelIds.add(channelData.first as int);
          }
        }

        if (myChannelIds.isEmpty) {
          debugPrint(
            "=====> [RADAR_ENGINE] Exit: Extracted channel ID list parsed out completely empty.",
          );
          return;
        }

        final List<List<dynamic>> domain = [
          ['channel_id', 'in', myChannelIds],
          ['receiver_partner_id', '=', myPartnerId],
          ['state', '=', 'ringing'],
        ];

        // Sequential database verification guard
        if (_lastCheckedCallId != null) {
          domain.add(['id', '>', _lastCheckedCallId]);
        }

        final result = await callKw(
          cookie: cookie,
          model: 'discuss.agora.call',
          method: 'search_read',
          args: [domain],
          kwargs: {
            'fields': [
              'id',
              'name',
              'channel_id',
              'caller_partner_id',
              'receiver_partner_id',
              'call_type',
              'state',
              'started_at',
              'accepted_at',
              'ended_at',
              'duration_seconds',
            ],
            'order': 'id asc',
            'limit': 30,
          },
        );

        debugPrint("=====> [RADAR_ENGINE] Agora call result: $result");

        if (result == null || result.isEmpty) {
          debugPrint(
            "=====> [RADAR_ENGINE] Exit: No ringing Agora calls found.",
          );
          return;
        }

        for (final rawCall in result) {
          if (rawCall is! Map) continue;

          final call = Map<String, dynamic>.from(rawCall);
          final int? callId = _asInt(call['id']);

          final callerPartner = call['caller_partner_id'];
          final receiverPartner = call['receiver_partner_id'];
          final channel = call['channel_id'];

          final int? toPartnerId = _partnerIdFromRelation(receiverPartner);
          final int? fromPartnerId = _partnerIdFromRelation(callerPartner);

          if (toPartnerId != myPartnerId) {
            debugPrint("=====> [RADAR_ENGINE] Exit: Call is not for this user.");
            continue;
          }

          if (fromPartnerId == myPartnerId) {
            // If it's our own call, update the index pointer so we don't query it again, but don't show UI
            if (callId != null) _lastCheckedCallId = callId;
            debugPrint("=====> [RADAR_ENGINE] Exit: Ignoring own outgoing call.");
            continue;
          }

          // --- TIMEZONE CONVERSION FIX ---
          // Instead of directly matching raw device local clocks to UTC strings,
          // we parse the server string explicitly as a UTC instance, then translate to device time.
          final rawStartedAt = call['started_at']?.toString() ?? '';
          DateTime? startedAtUtc;
          if (rawStartedAt.isNotEmpty) {
            // Append 'Z' if missing to force parsing as standard ISO/UTC text
            final normalizedString = rawStartedAt.endsWith('Z') ? rawStartedAt : '${rawStartedAt}Z';
            startedAtUtc = DateTime.tryParse(normalizedString);
          }

          if (startedAtUtc != null) {
            final nowUtc = DateTime.now().toUtc();
            // Reject calls that have been floating in a ringing state for over 2 minutes (stale)
            if (nowUtc.difference(startedAtUtc).inMinutes > 2) {
              if (callId != null) _lastCheckedCallId = callId;
              debugPrint("=====> [RADAR_ENGINE] Exit: Ignoring old stale call record.");
              continue;
            }
          }

          if (!context.mounted) {
            debugPrint(
              "=====> [RADAR_ENGINE] Exit Failure: Context is unmounted.",
            );
            return;
          }

          // CRITICAL FIX: Only step the cursor pointer forward when a call is successfully accepted/consumed
          if (callId != null) {
            _lastCheckedCallId = callId;
          }

          debugPrint("=====> [RADAR_ENGINE] Incoming Agora call accepted.");
          _isCallPageOpen = true;

          onCallReceived({
            'call_id': callId,

            'type': 'agora_incoming_call',
            'agora_call': true,
            'agora_channel_name': call['name'],
            'channel_id': channel is List && channel.isNotEmpty ? channel.first : channel,
            'call_type': call['call_type'],
            'state': call['state'],
            'from_partner_id': fromPartnerId,
            'from_partner_name': _partnerNameFromRelation(callerPartner),
            'to_partner_id': toPartnerId,
            'to_partner_name': _partnerNameFromRelation(receiverPartner),
            'started_at': call['started_at'],
            'accepted_at': call['accepted_at'],
            'ended_at': call['ended_at'],
            'duration_seconds': call['duration_seconds'],
          });
          return;
        }
      } catch (e) {
        debugPrint("=====> [GLOBAL_RADAR_ERROR] Runtime exception caught: $e");
        _isCallPageOpen = false;
      } finally {
        _isTickRunning = false;
      }
    });
  }
  int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  int? _partnerIdFromRelation(dynamic relation) {
    if (relation is List && relation.isNotEmpty) return _asInt(relation.first);
    return _asInt(relation);
  }

  String? _partnerNameFromRelation(dynamic relation) {
    if (relation is List && relation.length > 1) return relation[1]?.toString();
    return null;
  }

  void resetCallState() {
    debugPrint(
      "=====> [GLOBAL_RADAR] Public state reset triggered. Radar loop unblocked.",
    );
    _isCallPageOpen = false;
  }

  void stopListening() {
    _timer?.cancel();
    _timer = null;
    _isCallPageOpen = false;
    _isTickRunning = false;
    debugPrint(
      "=====> [GLOBAL_RADAR] Call Invitation Service completely stopped.",
    );
  }
}
