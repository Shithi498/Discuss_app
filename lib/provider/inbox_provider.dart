import 'package:flutter/cupertino.dart';
import '../model/thread_model.dart';
import '../services/odoo_discuss_service.dart';
import 'package:flutter/material.dart';

class InboxProvider extends ChangeNotifier {
  final OdooDiscussService service;
  InboxProvider(this.service);


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
  Future<void> loadDirectMessages(String cookie, int partnerId) async {
    _isLoading = true;
    _errorMessage = '';
    _messages = [];
    notifyListeners();

    try {

      final List<Map<String, dynamic>> result = await service.loadInboxData(
        cookie: cookie,
        myPartnerId:partnerId
      );


      _messages = result.map((data) => DirectMessage.fromJson(data)).toList();

    } catch (e) {

      _errorMessage = 'Error loading direct messages: $e';
      print('DEBUG: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
          [uid]
        ],
        kwargs: {
          'fields': ['id', 'image_1920'],
        },
      );

      if (result is List && result.isNotEmpty) {
        final data = Map<String, dynamic>.from(result.first);

        final image = data['image_1920'];

        _profileImages[uid] =
        (image != null && image.toString().isNotEmpty)
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

  Future<void> loadInboxPopup({
    required String cookie,
    required int partnerId,
  }) async {
    inboxLoading = true;
    notifyListeners();

    try {
      inboxData = await service.getInboxNotifications(
        cookie: cookie,
        partnerId: partnerId,
      );
    } catch (e) {
      debugPrint("Inbox error: $e");
    }

    inboxLoading = false;
    notifyListeners();
  }

  Future<void> loadChannels(String cookie) async {
    channelErrorMessage = '';
    channels = [];
    notifyListeners();

    try {
      final result = await service.loadChannels(cookie: cookie);

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
    _errorMessage ;
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
          'write_date': DateTime.now().toIso8601String(), // Temporary fallback string
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