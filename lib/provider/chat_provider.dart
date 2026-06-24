import 'package:flutter/cupertino.dart';
import '../model/chat_message_model.dart';
import '../model/group_participents.dart';
import '../services/odoo_discuss_service.dart';



// class ChatProvider extends ChangeNotifier {
//   final OdooDiscussService service;
//
//   ChatProvider(this.service);
//
//   bool loading = false;
//   String? error;
//   List<ChatMessage> messages= [];
//
//   Future<void> loadChatMessages({
//     required String cookie,
//     required int channelId,
//   }) async {
//     loading = true;
//     notifyListeners();
// print("channelId,$channelId");
//     try {
//       final raw = await service.loadMessages(
//         cookie: cookie,
//         channelId: channelId,
//       );
//       print("messages from chatpage : $raw  ");
//       messages = raw.map((e) => ChatMessage.fromJson(e)).toList();
//
//     } catch (e) {
//       error = e.toString();
//       print("messages from chatpage : $e ");
//     }
//
//     loading = false;
//     notifyListeners();
//   }
// }

class ChatProvider extends ChangeNotifier {
  final OdooDiscussService service;

  ChatProvider(this.service);

  bool loading = false;
  String? error;
  List<ChatMessage> messages = [];

  Future<bool> deleteMessageFromChat({
    required String cookie,
    required int messageId,
    required int channelId,
  }) async {
    // 1. Set loading state and clear previous errors
    loading = true;
    error = null;
    notifyListeners();

    print("=== [PROVIDER DELETE MESSAGE] ===");
    print("Target messageId: $messageId | channelId: $channelId");

    try {
      // 2. Fire the backend unlink deletion request via your service layer
      final success = await service.deleteMessage(
        cookie: cookie,
        messageId: messageId,
      );

      if (success) {
        print("Message deleted on server. Syncing local UI list array...");

        // 3. Re-fetch current message records from the channel to keep state synced with Odoo
        final raw = await service.loadMessages(
          cookie: cookie,
          channelId: channelId,
        );

        final filteredRaw = raw.where((e) {
          final body = e['body']?.toString() ?? "";
          return !body.contains('RTC_SIGNAL::');
        }).toList();

        // Update the main messages collection list
        messages = filteredRaw.map((e) => ChatMessage.fromJson(e)).toList();

        // 4. Memory Optimization: Purge attachments tracker cache for the deleted message instance
        if (messageAttachments.containsKey(messageId)) {
          messageAttachments.remove(messageId);
          print("Cleared attachments metadata cache entry for deleted message $messageId");
        }

        loading = false;
        notifyListeners(); // Force layout rebuild across listening widgets
        return true;
      } else {
        throw Exception("Odoo server rejected the deletion transaction or returned false.");
      }
    } catch (e) {
      error = e.toString();
      print("Error executing message state deletion in provider: $e");

      loading = false;
      notifyListeners();
      return false;
    } finally {
      print("=== [PROVIDER DELETE ACTION END] ===");
    }
  }

  List<GroupParticipant> _participants = [];
  List<GroupParticipant> get participants => _participants;

  Future<void> loadAllChannelMembers({
    required String cookie,
    required int channelId,
  }) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final rawMembers = await service.getChannelMembers(
        cookie: cookie,
        channelId: channelId,
      );

      _participants.clear();

      for (final member in rawMembers) {
        final rawPartner = member['partner_id'];

        int? partnerId;
        String name = 'Unknown User';

        if (rawPartner is List && rawPartner.length >= 2) {
          partnerId = rawPartner[0] as int?;
          name = rawPartner[1].toString();
        }

        if (partnerId == null) continue;

        _participants.add(
          GroupParticipant(
            partnerId: partnerId,
            displayName: name,
          ),
        );
      }
    } catch (e) {
      error = e.toString();
      print("Load channel members error: $e");
    } finally {
      loading = false;
      notifyListeners();
    }
  }


  // Future<void> loadChannelParticipants({
  //   required String cookie,
  //   required int channelId,
  //   required int myPartnerId,
  //   List<int>? myPartnerIds,
  // }) async {
  //   loading = true;
  //   error = null;
  //   notifyListeners();
  //
  //   try {
  //     // 1. Invoke the API service to get other participants
  //     final otherParticipants = await service.getOtherParticipantPartnerIds(
  //       cookie: cookie,
  //       channelId: channelId,
  //       myPartnerId: myPartnerId,
  //       myPartnerIds: myPartnerIds,
  //     );
  //
  //     print("Other participants fetched from service: $otherParticipants");
  //     _participants.clear();
  //
  //     if (otherParticipants.isEmpty) {
  //       loading = false;
  //       notifyListeners();
  //       return;
  //     }
  //
  //     for (var participant in otherParticipants) {
  //       final rawPartner = participant['partner_id'];
  //
  //       int? extractedId;
  //       String extractedName = 'Unknown User';
  //
  //       // 1. Prioritize extracting cleanly from the relational array pair [ID, Name]
  //       if (rawPartner is List && rawPartner.length >= 2) {
  //         extractedId = rawPartner[0] as int?;
  //         extractedName = rawPartner[1].toString();
  //       }
  //       // Fallback if it arrives pre-separated
  //       else if (rawPartner is int) {
  //         extractedId = rawPartner;
  //         extractedName = participant['display_name']?.toString() ?? 'Unknown User';
  //       }
  //
  //       // ─── THE BULLETPROOF STRING CLEANING METHOD ───
  //
  //       // A. Strip all straight AND curly/smart quotation marks right away
  //       extractedName = extractedName
  //           .replaceAll('"', '')
  //           .replaceAll("'", "")
  //           .replaceAll('“', '') // Left curly double quote
  //           .replaceAll('”', '') // Right curly double quote
  //           .replaceAll('‘', '') // Left curly single quote
  //           .replaceAll('’', '') // Right curly single quote
  //           .trim();
  //
  //       // B. Aggressively remove 'in False' using a loose global RegExp case-insensitive check
  //       // Now that quotes are gone, "saiful bhai in False" easily becomes "saiful bhai"
  //       extractedName = extractedName.replaceAll(RegExp(r'\s+in\s+false', caseSensitive: false), '').trim();
  //
  //       // C. Final fallback safety validation check
  //       if (extractedName.isEmpty || extractedName.toLowerCase() == 'false') {
  //         extractedName = 'Unknown User';
  //       }
  //
  //       // Safety exits
  //       if (extractedId == null) continue;
  //       if (extractedId == myPartnerId) continue;
  //
  //       final groupParticipant = GroupParticipant(
  //         partnerId: extractedId,
  //         displayName: extractedName,
  //       );
  //
  //       _participants.add(groupParticipant);
  //     }
  //
  //     // Fixed internal interpolation log crash potential by printing length
  //     print("Successfully loaded ${_participants.length} group participants into state.");
  //
  //   } catch (e) {
  //     error = e.toString();
  //     print("Fetch participants runtime error: $e");
  //   } finally {
  //     loading = false;
  //     notifyListeners();
  //   }
  // }
  Future<bool> addMembersToChannel({
    required String cookie,
    required int channelId,
    required List<int> partnerIds,
    required int myPartnerId,
  }) async {
    loading = true;
    error = null;
    notifyListeners();

    print("=== [PROVIDER ADD MULTIPLE MEMBERS] ===");
    print("channelId: $channelId | partnerIds: $partnerIds");

    try {
      final success = await service.addMembersToChannel(
        cookie: cookie,
        channelId: channelId,
        partnerIds: partnerIds,
      );

      if (success) {
        print("Members added successfully.");

        // await loadChannelParticipants(
        //   cookie: cookie,
        //   channelId: channelId,
        //   myPartnerId: myPartnerId,
        // );
        await loadAllChannelMembers(
          cookie: cookie!,
          channelId: channelId,
        );
        loading = false;
        notifyListeners();
        return true;
      } else {
        throw Exception("Odoo server returned false while adding members.");
      }
    } catch (e) {
      error = e.toString();
      print("Error adding members to channel: $e");

      loading = false;
      notifyListeners();
      return false;
    } finally {
      print("=== [PROVIDER ADD MULTIPLE MEMBERS END] ===");
    }
  }

  Future<bool> editMessageInChat({
    required String cookie,
    required int messageId,
    required int channelId,
    required String updatedText,
  }) async {
    loading = true;
    error = null;
    notifyListeners();

    print("Updating messageId: $messageId in channelId: $channelId");

    try {
      // 1. Fire the server mutation request via your backend service layer
      final success = await service.updateMessage(
        cookie: cookie,
        messageId: messageId,
        updatedText: updatedText,
      );

      if (success) {
        print("Message successfully updated on server. Reloading chat timeline...");

        // 2. Fetch up-to-date message records so local UI array stays synced with Odoo
        final raw = await service.loadMessages(
          cookie: cookie,
          channelId: channelId,
        );

        final filteredRaw = raw.where((e) {
          final body = e['body']?.toString() ?? "";
          return !body.contains('RTC_SIGNAL::');
        }).toList();

        messages = filteredRaw.map((e) => ChatMessage.fromJson(e)).toList();

        loading = false;
        notifyListeners();
        return true;
      } else {
        throw Exception("Odoo server returned operation rejection status code.");
      }
    } catch (e) {
      error = e.toString();
      print("Error changing message state in provider: $e");

      loading = false;
      notifyListeners();
      return false;
    }
  }


  Future<void> loadChatMessages({
    required String cookie,
    required int channelId,
  }) async {
    loading = true;
    error = null;
    notifyListeners();

    print("channelId,$channelId");

    try {
      final raw = await service.loadMessages(
        cookie: cookie,
        channelId: channelId,
      );

      final filteredRaw = raw.where((e) {
        final body = e['body']?.toString() ?? "";
        return !body.contains('RTC_SIGNAL::');
      }).toList();

      print("messages from chatpage : $filteredRaw");

      messages = filteredRaw.map((e) => ChatMessage.fromJson(e)).toList();
    } catch (e) {
      error = e.toString();
      print("messages from chatpage : $e");
    }

    loading = false;
    notifyListeners();
  }
  Future<bool> uploadAndSendFile({
    required String cookie,
    required int channelId,
    required String fileName,
    required String base64Data,
    required String mimeType,
    String bodyText = "Sent an attachment",
  }) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      // Step 1: Create the attachment record using your service method
      print("=====> [PROVIDER] Creating attachment for file: $fileName");
      final int? attachmentId = await service.createAttachment(
        cookie: cookie,
        channelId: channelId,
        fileName: fileName,
        base64Data: base64Data,
        mimeType: mimeType,
      );

      if (attachmentId == null) {
        throw Exception("Failed to generate an attachment ID from Odoo server.");
      }

      print("=====> [PROVIDER] Attachment generated successfully. ID: $attachmentId");

      // Step 2: Post the actual chat message linking the newly made attachment ID
      print("=====> [PROVIDER] Posting message with attachment reference...");
      final bool messageSent = await service.messagePostWithAttachment(
        cookie: cookie,
        channelId: channelId,
        bodyText: bodyText,
        attachmentId: attachmentId,
      );

      if (!messageSent) {
        throw Exception("Attachment record was created, but failed to post message text.");
      }

      print("=====> [PROVIDER] File shared successfully. Refreshing chat UI messages...");

      // Step 3: Automatically reload the chat screen list items on completion
      await loadChatMessages(cookie: cookie, channelId: channelId);

      return true;

    } catch (e) {
      error = e.toString();
      print("=====> [PROVIDER ERROR] uploadAndSendFile failed: $e");
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // Example implementation pattern inside ChatProvider:
  // Ensure this exists inside your ChatProvider class
  Map<int, List<dynamic>> messageAttachments = {}; // Key: messageId, Value: List of attachments metadata

  Future<void> loadFilesForMessage({
    required String cookie,
    required int messageId, // Pass the parent message ID to match them later
    required List<int> attachmentIds,
  }) async {
    if (attachmentIds.isEmpty) return;
    try {
      final List<dynamic> attachmentsMetadata = await service.fetchAttachments(
        cookie: cookie,
        attachmentIds: attachmentIds,
      );

      messageAttachments[messageId] = attachmentsMetadata;
      print("load file from provider, ${messageAttachments[messageId] }");
      notifyListeners(); // Force UI rebuild when files load successfully
    } catch (e) {
      print("Error fetching attachments: $e");
    }
  }
  Future<bool> renameGroup({
    required String cookie,
    required int channelId,
    required String newName,
  }) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final result = await service.callKw(
        cookie: cookie,
        model: 'discuss.channel',
        method: 'write',
        args: [
          [channelId],       // list of channel IDs to update
          {'name': newName}, // fields to update
        ],
        kwargs: {},
      );

      if (result == true) {
        // Update the local messages or UI if needed
        notifyListeners();
        return true;
      } else {
        error = "Failed to rename group";
        notifyListeners();
        return false;
      }
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    } finally {
      loading = false;
    }
  }
  Future<String?> loadrename({
    required String cookie,
    required int channelId,
  }) async {
    loading = true;
    error = null;
    notifyListeners();

    print("channelId: $channelId");

    try {
      // Call the service to get the group name
      final raw = await service.loadGroupName(cookie: cookie, channelId: channelId);

      print("Group name from chat page: $raw");

      return raw; // return the group name
    } catch (e) {
      error = e.toString();
      print("Error loading group name: $e");
      return null; // return null on error
    } finally {
      loading = false;
      notifyListeners();
    }
  }


}







