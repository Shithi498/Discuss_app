import 'package:flutter/material.dart';
import '../model/search_model.dart';
import '../services/odoo_discuss_service.dart';

class SearchProvider extends ChangeNotifier {
  final OdooDiscussService service;

  SearchProvider(this.service);

  bool loading = false;
  String? error;
  List<SearchUser> partners = [];

  Future<void> search(String txt, String cookie) async {
    if (txt.trim().isEmpty) {
      partners = [];
      error = null;
      notifyListeners();
      return;
    }

    loading = true;
    error = null;
    notifyListeners();

    try {
      partners = await service.searchUsers(
        cookie: cookie,
        query: txt,
      );

print("Search partners. $partners");

    } catch (e) {
      error = e.toString();
      partners = [];
    }

    loading = false;
    notifyListeners();
  }
}
