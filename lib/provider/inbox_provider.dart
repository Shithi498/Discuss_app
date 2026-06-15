import 'package:flutter/cupertino.dart';

import '../model/thread_model.dart';
import '../services/odoo_discuss_service.dart';

import 'package:flutter/material.dart';




class InboxProvider extends ChangeNotifier {
  final OdooDiscussService service;
  InboxProvider(this.service);


  List<DirectMessage> _messages = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<DirectMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

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
}