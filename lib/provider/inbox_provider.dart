import 'package:flutter/cupertino.dart';
import '../model/thread_model.dart';
import '../services/odoo_discuss_service.dart';
import 'package:flutter/material.dart';

class InboxRowMeta {
  final List<dynamic> otherParticipants;
  final String? renamedGroupName;
  final int mySeenMessageId;

  const InboxRowMeta({
    required this.otherParticipants,
    required this.renamedGroupName,
    required this.mySeenMessageId,
  });
}

class InboxProvider extends ChangeNotifier {
  final OdooDiscussService service;
  InboxProvider(this.service);
  Map<int, int> _unreadCountersByChannel = {};

  Map<int, int> get unreadCountersByChannel => _unreadCountersByChannel;

  int unreadCountForChannel(int channelId) {
    return _unreadCountersByChannel[channelId] ?? 0;
  }

  bool isChannelUnread(int channelId) {
    return unreadCountForChannel(channelId) > 0;
  }

  final Map<int, InboxRowMeta> _rowMetaByChannel = {};

  Map<int, InboxRowMeta> get rowMetaByChannel => _rowMetaByChannel;

  InboxRowMeta? rowMetaForChannel(int channelId) {
    return _rowMetaByChannel[channelId];
  }

  void clearRowMetaCache() {
    _rowMetaByChannel.clear();
  }

  void removeRowMetaForChannel(int channelId) {
    _rowMetaByChannel.remove(channelId);
  }

  List<DirectMessage> _messages = [];
  List<Map<String, dynamic>> channels = [];
  bool _isLoading = false;
  String _errorMessage = '';
  Map<int, String?> _profileImages = {};

  Map<int, String?> get profileImages => _profileImages;
  List<DirectMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String channelErrorMessage = '';
  List<dynamic> _channels = [];

  Future<void> loadInboxRowMeta({
    required String cookie,
    required int partnerId,
    required List<DirectMessage> messages,
    required Future<List<dynamic>> Function(int channelId) loadParticipants,
    required Future<String?> Function(int channelId) loadRenamedGroupName,
    required Future<int> Function(int channelId) loadSeenMessageId,
  }) async {
    final channelIds = messages
        .where(
          (message) =>
              !message.body.contains("AGORA_CALL::") &&
              !message.body.contains('"agora_call":'),
        )
        .map((message) => message.channelId)
        .toSet()
        .where((channelId) => !_rowMetaByChannel.containsKey(channelId))
        .toList();

    if (channelIds.isEmpty) return;

    final entries = await Future.wait(
      channelIds.map((channelId) async {
        try {
          final rowData = await Future.wait([
            loadParticipants(channelId),
            loadRenamedGroupName(channelId),
            loadSeenMessageId(channelId),
          ]);

          return MapEntry(
            channelId,
            InboxRowMeta(
              otherParticipants: rowData[0] as List<dynamic>,
              renamedGroupName: rowData[1] as String?,
              mySeenMessageId: rowData[2] as int,
            ),
          );
        } catch (e) {
          debugPrint("Inbox row meta load failed for $channelId: $e");

          return MapEntry(
            channelId,
            const InboxRowMeta(
              otherParticipants: [],
              renamedGroupName: null,
              mySeenMessageId: 0,
            ),
          );
        }
      }),
    );

    for (final entry in entries) {
      _rowMetaByChannel[entry.key] = entry.value;
    }

    notifyListeners();
  }

  // Future<void> loadDirectMessages(
  //   String cookie,
  //   int partnerId, {
  //   bool silent = false,
  // }) async {
  //   if (!silent) {
  //     _isLoading = true;
  //   }
  //   _errorMessage = '';
  //   if (!silent) {
  //     _messages = [];
  //     _rowMetaByChannel.clear();
  //     notifyListeners();
  //   }
  //
  //   try {
  //     final List<Map<String, dynamic>> result = await service.loadInboxData(
  //       cookie: cookie,
  //       myPartnerId: partnerId,
  //     );
  //
  //     _messages = result.map((data) => DirectMessage.fromJson(data)).toList();
  //   } catch (e) {
  //     if (!silent) {
  //       _errorMessage = 'Error loading direct messages: $e';
  //     }
  //     print('DEBUG: $e');
  //   } finally {
  //     if (!silent) {
  //       _isLoading = false;
  //     }
  //     notifyListeners();
  //   }
  // }

  Future<void> loadDirectMessages(
      String cookie,
      int partnerId, {
        bool silent = false,
      }) async {
    if (!silent) {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();
    }

    try {
      final cached = await service.loadInboxCache(partnerId);
      if (cached.isNotEmpty) {
        _messages = cached.map((data) => DirectMessage.fromJson(data)).toList();
        _isLoading = false;
        notifyListeners();
      }

      final fresh = await service.loadInboxData(
        cookie: cookie,
        myPartnerId: partnerId,
      );

      await service.saveInboxCache(partnerId, fresh);

      _messages = fresh.map((data) => DirectMessage.fromJson(data)).toList();
    } catch (e) {
      if (!silent) {
        _errorMessage = 'Error loading direct messages: $e';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUnreadCounters(
    String cookie,
    int partnerId, {
    bool silent = false,
  }) async {
    if (!silent) {
      _isLoading = true;
    }

    _errorMessage = '';

    if (!silent) {
      _unreadCountersByChannel = {};
      notifyListeners();
    }

    try {
      final Map<int, int> result = await service
          .loadUnreadCountersForMyChannels(
            cookie: cookie,
            partnerId: partnerId,
          );

      _unreadCountersByChannel = result;
    } catch (e) {
      if (!silent) {
        _errorMessage = 'Error loading unread counters: $e';
      }

      print('DEBUG UNREAD COUNTER ERROR: $e');
    } finally {
      if (!silent) {
        _isLoading = false;
      }

      notifyListeners();
    }
  }

  int get totalUnreadCounter {
    return _unreadCountersByChannel.values.fold(0, (sum, value) => sum + value);
  }

  Future<void> loadUserProfileImage({
    required String cookie,
    required int uid,
  }) async {
    try {
      final result = await service.callKw(
        cookie: cookie,
        model: 'res.partner',
        method: 'read',
        args: [
          [uid],
        ],
        kwargs: {
          'fields': ['id', 'image_1920'],
        },
      );

      if (result is List && result.isNotEmpty) {
        final data = Map<String, dynamic>.from(result.first);

        final image = data['image_1920'];

        _profileImages[uid] = (image != null && image.toString().isNotEmpty)
            ? image
            : null;

        notifyListeners();
      }
    } catch (e) {
      print('PROFILE IMAGE ERROR: $e');
    }
  }

  Map<String, dynamic>? inboxData;
  bool inboxLoading = false;
  //
  // Future<void> loadInboxPopup({
  //   required String cookie,
  //   required int partnerId,
  // }) async {
  //   inboxLoading = true;
  //   notifyListeners();
  //
  //   try {
  //     inboxData = await service.getInboxNotifications(
  //       cookie: cookie,
  //       partnerId: partnerId,
  //     );
  //   } catch (e) {
  //     debugPrint("Inbox error: $e");
  //   }
  //
  //   inboxLoading = false;
  //   notifyListeners();
  // }

  Future<void> loadChannels(String cookie,int partnerId,) async {

    channelErrorMessage = '';
    channels = [];
    notifyListeners();

    try {
      final result = await service.loadChannels(cookie: cookie,partnerId:partnerId );

      channels = result
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    } catch (e) {
      channelErrorMessage = 'Error loading channels: $e';
      print('DEBUG CHANNEL: $e');
    } finally {
      notifyListeners();
    }
  }

  Future<bool> createChannel({
    required String cookie,
    required String name,
    required String description,
    required List<int> partnerIds,
  }) async {
    _isLoading = true;
    _errorMessage;
    notifyListeners();

    try {
      final dynamic newChannelId = await service.createChannel(
        cookie: cookie,
        channelName: name,
      );

      if (newChannelId != null && newChannelId is int) {
        final newChannelLocal = {
          'id': newChannelId,
          'name': name,
          'channel_type': 'channel',
          'write_date': DateTime.now()
              .toIso8601String(), // Temporary fallback string
        };

        _channels.insert(0, newChannelLocal);

        _isLoading = false;
        notifyListeners();
        return true; // Operation succeeded
      }

      _errorMessage = "Server failed to return a valid Channel ID.";
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = "Failed to create channel: $e";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
