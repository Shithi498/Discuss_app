import 'package:flutter/material.dart';
import '../services/odoo_discuss_service.dart';


import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class NotificationProvider extends ChangeNotifier {
  final OdooDiscussService service;

  NotificationProvider(this.service);

  bool _isLoading = false;
  String _errorMessage = '';
  List<dynamic> _notifications = [];

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  List<dynamic> get notifications => _notifications;

  Future<void> loadNotificationList({
    required String cookie,
    int limit = 20,
    required int partnerId
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final result = await service.fetchNotificationList(cookie: cookie, );
      _notifications = result;
    } catch (e) {
      _errorMessage = 'Error fetching notifications: $e';
      print('DEBUG NOTIFICATION ERROR: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}