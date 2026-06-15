import 'dart:async';

import 'agora_call_invitation_service.dart';


//
// class CallListenerService {
//   final AgoraCallInvitationService inviteService;
//   final String cookie;
//   final int channelId;
//   final int myPartnerId;
//
//   Timer? _pollingTimer;
//   int? _lastCheckedMessageId;
//
//   CallListenerService({
//     required this.inviteService,
//     required this.cookie,
//     required this.channelId,
//     required this.myPartnerId,
//   });
//
//   // Starts checking the server every 3 seconds
//   void startListening({required Function(Map<String, dynamic> invite) onIncomingCall}) {
//     print("📡 Call listener started. Monitoring channel $channelId...");
//
//     _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
//       try {
//         final invitations = await inviteService.fetchCallInvitations(
//           cookie: cookie,
//           channelId: channelId,
//           myPartnerId: myPartnerId,
//           lastMessageId: _lastCheckedMessageId,
//         );
//
//         if (invitations.isNotEmpty) {
//           final latestInvite = invitations.last;
//
//           // Prevent showing the exact same call notification twice
//           _lastCheckedMessageId = latestInvite["message_id"];
//
//           print("📞 Incoming call detected! Data: $latestInvite");
//           onIncomingCall(latestInvite);
//         }
//       } catch (e) {
//         print("Error checking for call invitations: $e");
//       }
//     });
//   }
//
//   // Stop the radar when leaving the screen
//   void stopListening() {
//     _pollingTimer?.cancel();
//     print("🛑 Call listener stopped.");
//   }
// }


// class CallListenerService {
//   final AgoraCallInvitationService inviteService;
//   final String cookie;
//   final int channelId;
//   final int myPartnerId;
//
//   Timer? _pollingTimer;
//   int? _lastCheckedMessageId;
//
//   CallListenerService({
//     required this.inviteService,
//     required this.cookie,
//     required this.channelId,
//     required this.myPartnerId,
//   });
//
//   // Starts searching Odoo for new call invites every 3 seconds
//   void startListening({required Function(Map<String, dynamic> invite) onIncomingCall}) {
//     print("📡 Monitoring Odoo room thread $channelId for calls...");
//
//     _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
//       try {
//         final invitations = await inviteService.fetchCallInvitations(
//           cookie: cookie,
//           channelId: channelId,
//           myPartnerId: myPartnerId,
//           lastMessageId: _lastCheckedMessageId,
//         );
//
//         if (invitations.isNotEmpty) {
//           final latestInvite = invitations.last;
//           _lastCheckedMessageId = latestInvite["message_id"];
//
//           print("📞 Call catch hit from Odoo backend: $latestInvite");
//           onIncomingCall(latestInvite);
//         }
//       } catch (e) {
//         print("Error reading call logs from Odoo: $e");
//       }
//     });
//   }
//
//   void stopListening() {
//     _pollingTimer?.cancel();
//     print("🛑 Call listener engine stopped.");
//   }
// }

import 'dart:async';
import 'dart:convert'; // CRITICAL: Gives us jsonDecode

class CallListenerService {
  final AgoraCallInvitationService inviteService;
  final String cookie;
  final int channelId;
  final int myPartnerId;

  Timer? _pollingTimer;
  int? _lastCheckedMessageId;

  CallListenerService({
    required this.inviteService,
    required this.cookie,
    required this.channelId,
    required this.myPartnerId,
  });

  void startListening({required Function(Map<String, dynamic> invite) onIncomingCall}) {
    print("📡 Monitoring Odoo room thread $channelId for calls...");

    _pollingTimer = Timer.periodic(const Duration(seconds:60), (timer) async {
      try {
        // Fetch raw messages/invitations from your Odoo service
        final List<dynamic> historyMessages = await inviteService.fetchCallInvitations(
          cookie: cookie,
          channelId: channelId,
          myPartnerId: myPartnerId,
          lastMessageId: _lastCheckedMessageId,
        );

        if (historyMessages.isNotEmpty) {
          for (var msg in historyMessages) {
            // Update tracking pointers so we don't process the same message twice
            if (msg is Map && msg["message_id"] != null) {
              _lastCheckedMessageId = msg["message_id"];
            }

            // 1. Extract the raw text body from Odoo's response object
            // Adjust 'body' or 'text' depending on what your service map keys are named
            String rawText = msg["text"] ?? msg["body"] ?? "";

            // 2. Detect our structural call signature string
            if (rawText.contains("AGORA_CALL::")) {
              print("🎯 Target call signature intercepted!");

              // Clean up the string to leave only the pure JSON part
              String jsonString = rawText.replaceAll("AGORA_CALL::", "").trim();

              // Parse the string into a valid Flutter Map object
              Map<String, dynamic> callData = jsonDecode(jsonString);

              // 3. SAFETY CHECK: Only show the popup if the call is for ME
              // and ensure I am not reacting to a call I dialed out myself!
              if (callData["to_partner_id"] == myPartnerId && callData["from_partner_id"] != myPartnerId) {
                print("📞 Triggering UI Overlay Dialog Box on Receiver Screen...");

                // Inject the clean map back to your ChatPage UI handler
                onIncomingCall(callData);
                break;
              }
            }
          }
        }
      } catch (e) {
        print("Error reading call logs from Odoo background service: $e");
      }
    });
  }

  void stopListening() {
    _pollingTimer?.cancel();
    print("🛑 Call listener engine stopped.");
  }
}