import 'package:flutter/foundation.dart';


import '../services/odoo_discuss_service.dart';

class ReactionProvider extends ChangeNotifier {
  final OdooDiscussService service;

  ReactionProvider(this.service);

  bool _isReacting = false;
  String _errorMessage = '';

  bool get isReacting => _isReacting;
  String get errorMessage => _errorMessage;


  Future<void> reactToMessage({
    required String cookie,
    required int messageId,
    required String emoji,
  }) async {
    _isReacting = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await service.reactToMessage(
        cookie: cookie,
        messageId: messageId,
        emoji: emoji,
      );

    } catch (e) {
      _errorMessage = 'Error reacting to message: $e';
      print('DEBUG REACTION ERROR: $e');
    } finally {
      _isReacting = false;
      notifyListeners();
    }
  }

  Future<void> loadMessageReactions({
    required String cookie,
    required List<Map<String, dynamic>> messages,
  }) async {
    _isReacting = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await service.loadMessageReactions(
        cookie: cookie,
        messages: messages,
      );
    } catch (e) {
      _errorMessage = 'Error loading message reactions: $e';
      print('DEBUG LOAD REACTION ERROR: $e');
    } finally {
      _isReacting = false;
      notifyListeners();
    }
  }
}
