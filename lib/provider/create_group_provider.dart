import 'package:flutter/foundation.dart';
import '../services/odoo_discuss_service.dart';

class GroupMemberProvider extends ChangeNotifier {
  final OdooDiscussService service;

  GroupMemberProvider(this.service);

  bool loading = false;
  String? error;

  List<Map<String, dynamic>> addedMembers = [];
  Future<bool> addMembersToGroup({
    required String cookie,
     int? channelId,
    required List<int> partnerIds,
  }) async {
    if (partnerIds.isEmpty) {
      error = "No partner selected";
      notifyListeners();
      return false;
    }

    loading = true;
    error = null;
    notifyListeners();

    try {
      await service.createGroup(
        cookie: cookie,
     //   channelId: channelId!,
        partnerIds: partnerIds,
      );

      print("Group members added successfully");

      loading = false;
      notifyListeners();

      return true;
    } catch (e) {
      error = e.toString();
      print("Add group member error: $e");

      loading = false;
      notifyListeners();

      return false;
    }
  }

  void clear() {
    loading = false;
    error = null;
    addedMembers.clear();
    notifyListeners();
  }
}
