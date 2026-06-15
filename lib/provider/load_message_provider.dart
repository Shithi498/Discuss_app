// // import 'package:flutter/cupertino.dart';
// // import '../model/load_message_model.dart';
// // import '../repo/load_message_repo.dart';
// // import '../repo/read_msg_repo.dart';
// //
// // class LoadMessageProvider extends ChangeNotifier {
// //   final LoadMessageRepo repo;
// //   ReadMessageRepo? readRepo ;
// //
// //   LoadMessageProvider({required this.repo,this.readRepo});
// //
// //
// //   final Map<int, List<loadMessage>> _messagesByThread = {};
// //   final Map<int, bool> _readMessages = {};
// //
// //   final Map<int, String> _threadNames = {};
// //
// //   bool loading = false;
// //   String? error;
// //
// //
// //   List<loadMessage> messagesForThread(int threadId,) =>
// //       _messagesByThread[threadId] ?? [];
// //
// //
// //
// //   String? threadNameFor(int threadId) => _threadNames[threadId];
// //
// //
// //   Future<void> loadMessages(int threadId) async {
// //     loading = true;
// //     error = null;
// //     notifyListeners();
// //
// //     try {
// //
// //       final result = await repo.fetchMessages(
// //         threadId: threadId,
// //
// //       );
// //
// //
// //       _messagesByThread[threadId] = result.messages;
// //       _threadNames[threadId] = result.threadName;
// //
// //     } catch (e) {
// //       error = e.toString();
// //     }
// //
// //     loading = false;
// //     notifyListeners();
// //   }
// //
// //   Future<void> readMessages(int msgId) async {
// //     loading = true;
// //     error = null;
// //     notifyListeners();
// //
// //     try {
// //       final markedCount = await readRepo?.markThreadAsRead(msgId: msgId);
// //
// //       if (markedCount != null && markedCount > 0) {
// //         _readMessages[msgId] = true;
// //       }
// //     } catch (e) {
// //       error = e.toString();
// //     }
// //
// //     loading = false;
// //     notifyListeners();
// //   }
// //
// // }
//
// import 'package:flutter/cupertino.dart';
// import '../model/load_message_model.dart';
//
// class LoadMessageProvider extends ChangeNotifier {
//
//   LoadMessageProvider({
//     required this.repo,
//     this.readRepo,
//   });
//
//   final Map<int, List<loadMessage>> _messagesByThread = {};
//   final Map<int, bool> _readMessages = {};
//   final Map<int, String> _threadNames = {};
//
//   bool loading = false;
//   String? error;
//
//
//   List<loadMessage> messagesForThread(int threadId) =>
//       _messagesByThread[threadId] ?? [];
//
//
//   String? threadNameFor(int threadId) => _threadNames[threadId];
//
//
//  // bool isMessageRead(int msgId) => _readMessages[msgId] ?? false;
//
//
//   Future<void> loadMessages(int threadId) async {
//     loading = true;
//     error = null;
//     notifyListeners();
//
//     try {
//       final result = await repo.fetchMessages(
//         threadId: threadId,
//       );
//
//       _messagesByThread[threadId] = result.messages;
//       _threadNames[threadId] = result.threadName;
//     } catch (e) {
//       error = e.toString();
//     }
//
//     loading = false;
//     notifyListeners();
//   }
//
//
//
//
// }