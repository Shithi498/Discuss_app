import 'package:flutter/cupertino.dart';

import '../model/call_model.dart';
import '../services/odoo_discuss_service.dart';

// class CallProvider extends ChangeNotifier {
//   final OdooDiscussService service;
//
//   CallProvider(this.service);
//
//   bool loading = false;
//   bool isCallActive = false;
//   String? error;
//
//
//   List<CallModel> activeSessions = [];
//
//   Future<void> startAudioCall({
//     required String cookie,
//     required int channelId,
//     required int partnerId,
//     required int memberId,
//   }) async {
//     loading = true;
//     notifyListeners();
//
//     try {
//       final response = await service.startAudioCall17(
//         cookie: cookie,
//         channelId: channelId,
//         partnerId: partnerId,
//           memberId: memberId
//       );
//
//
//       if (response != null && response is List) {
//         activeSessions = response
//             .map((data) => CallModel.fromJson(data as Map<String, dynamic>))
//             .toList();
//       }
//
//       isCallActive = true;
//       error = null;
//     } catch (e) {
//       error = "Failed to start call: ${e.toString()}";
//       isCallActive = false;
//     }
//
//     loading = false;
//     notifyListeners();
//   }
//
//   Future<void> endAudioCall({
//     required String cookie,
//     required int channelId,
//   }) async {
//     loading = true;
//     notifyListeners();
//
//     try {
//       await service.endAudioCall(
//         cookie: cookie,
//         channelId: channelId,
//       );
//       isCallActive = false;
//       activeSessions = [];
//       error = null;
//     } catch (e) {
//       error = "Failed to end call: ${e.toString()}";
//     }
//
//     loading = false;
//     notifyListeners();
//   }
// }

class CallProvider extends ChangeNotifier {
  final OdooDiscussService service;

  CallProvider({required this.service});

  bool loading = false;
  bool isCallActive = false;
  String? error;

  List<CallModel> activeSessions = [];

  Future<void> startAudioCall({
    required String cookie,
    required int channelId,
    required int partnerId,
    required int memberId,
  }) async {
    loading = true;
    notifyListeners();

    try {
      final response = await service.startAudioCall17(
        cookie: cookie,
        channelId: channelId,
        partnerId: partnerId,
        //memberId: memberId,
      );

      if (response != null && response is List) {
        activeSessions = response
            .map((data) => CallModel.fromJson(data as Map<String, dynamic>))
            .toList();
      }

      isCallActive = true;
      error = null;
    } catch (e) {
      error = "Failed to start call: ${e.toString()}";
      isCallActive = false;
    }

    loading = false;
    notifyListeners();
  }

  Future<void> receiveAudioCall({
    required String cookie,
    required int channelId,
    required int partnerId,
  }) async {
    loading = true;
    notifyListeners();

    try {
      final response = await service.receiveAudioCall17(
        cookie: cookie,
        channelId: channelId,
        partnerId: partnerId,
      );

      if (response != null && response is List) {
        activeSessions = response
            .map((data) => CallModel.fromJson(data as Map<String, dynamic>))
            .toList();
      }

      isCallActive = true;
      error = null;
    } catch (e) {
      error = "Failed to receive call: ${e.toString()}";
      isCallActive = false;
    }

    loading = false;
    notifyListeners();
  }

  Future<void> endAudioCall({
    required String cookie,
    required int channelId,
  }) async {
    loading = true;
    notifyListeners();

    try {
      await service.endAudioCall(cookie: cookie, channelId: channelId);

      isCallActive = false;
      activeSessions = [];
      error = null;
    } catch (e) {
      error = "Failed to end call: ${e.toString()}";
    }

    loading = false;
    notifyListeners();
  }
}
