// import 'package:flutter/foundation.dart';
// import '../repo/read_msg_repo.dart';
//
//
// class ReadMessageProvider extends ChangeNotifier {
//   final ReadMessageRepo repo;
//
//   ReadMessageProvider({required this.repo});
//
//   bool _loading = false;
//   String? _error;
//
//
//   final Map<int, bool> _readStatus = {};
//
//   bool get loading => _loading;
//   String? get error => _error;
//
//
//   bool isMessageRead(int msgId) => _readStatus[msgId] ?? false;
//
//   final Set<int> _alreadyCalled = {};
//   // Future<void> markMessageAsRead(int msgId, int threadId) async {
//   //   _error = null;
//   //   _loading = true;
//   //   notifyListeners();
//   //
//   //   try {
//   //     final markedCount = await repo.markThreadAsRead(msgId: msgId,threadId: threadId);
//   //
//   //     if (markedCount != null && markedCount > 0) {
//   //       _readStatus[msgId] = true;
//   //     } else if (markedCount == null) {
//   //
//   //       _error = repo.error ?? "Failed to mark message as read";
//   //     }
//   //   } catch (e) {
//   //     _error = "Error marking message as read: $e";
//   //   }
//   //
//   //   _loading = false;
//   //   notifyListeners();
//   // }
//
//   Future<void> markMessageAsRead(int msgId, int threadId) async {
//     if (_readStatus[msgId] == true || _alreadyCalled.contains(msgId)) return;
//
//     // ✅ mark read immediately (local)
//     _readStatus[msgId] = true;
//     _alreadyCalled.add(msgId);
//     notifyListeners();
//
//     await repo.markThreadAsRead(msgId: msgId, threadId: threadId);
//     print(" didn't STOPed");
//   }
//
//
//   void setLocalRead(int msgId, {bool isRead = true}) {
//     _readStatus[msgId] = isRead;
//     notifyListeners();
//   }
//
//
//   void clear() {
//     _readStatus.clear();
//     _error = null;
//     _loading = false;
//     notifyListeners();
//   }
// }
