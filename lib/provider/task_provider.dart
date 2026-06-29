import 'package:flutter/material.dart';
import '../services/odoo_discuss_service.dart';

// class TaskProvider extends ChangeNotifier {
//   final OdooDiscussService service;
//
//   TaskProvider(this.service);
//
//   bool loading = false;
//   String? error;
//
//   List<dynamic> assignedTasks = [];
//   Map<String, dynamic>? selectedTask;
//
//   Future<void> fetchAssignedTasks({
//     required String cookie,
//     required int userId,
//   }) async {
//     loading = true;
//     error = null;
//     notifyListeners();
//
//     try {
//       assignedTasks = await service.getAssignedTasks(
//         cookie: cookie,
//         userId: userId,
//       );
//
//       print("Assigned tasks: $assignedTasks");
//     } catch (e) {
//       error = e.toString();
//       assignedTasks = [];
//     }
//
//     loading = false;
//     notifyListeners();
//   }
//
//   Future<void> fetchTaskById({
//     required String cookie,
//     required int taskId,
//   }) async {
//     loading = true;
//     error = null;
//     notifyListeners();
//
//     try {
//       selectedTask = await service.getTaskById(
//         cookie: cookie,
//         taskId: taskId,
//       );
//
//       print("Selected task: $selectedTask");
//     } catch (e) {
//       error = e.toString();
//       selectedTask = null;
//     }
//
//     loading = false;
//     notifyListeners();
//   }
//
//   void clearSelectedTask() {
//     selectedTask = null;
//     notifyListeners();
//   }
// }

class TaskProvider extends ChangeNotifier {
  final OdooDiscussService service;

  TaskProvider(this.service);

  bool loading = false;
  String? error;

  List<dynamic> assignedTasks = [];
  Map<String, dynamic>? selectedTask;

  // --- Add these variables to track state globally ---
  bool hasUncheckedTaskNotification = false;
  int lastTaskCount = 0;

  Future<void> fetchAssignedTasks({
    required String cookie,
    required int userId,
  }) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      assignedTasks = await service.getAssignedTasks(
        cookie: cookie,
        userId: userId,
      );

      print("Assigned tasks: $assignedTasks");
    } catch (e) {
      error = e.toString();
      assignedTasks = [];
    }

    loading = false;
    notifyListeners();
  }

  // --- Add a method to clear the notification badge ---
  void markNotificationsAsRead() {
    hasUncheckedTaskNotification = false;
    lastTaskCount = assignedTasks.length;
    notifyListeners(); // This triggers UI updates across pages
  }

  // --- Add a method to handle background/periodic checks ---
  void updateNotificationStatus() {
    if (assignedTasks.length > lastTaskCount) {
      hasUncheckedTaskNotification = true;
    }
    lastTaskCount = assignedTasks.length;
    notifyListeners();
  }

  Future<void> fetchTaskById({
    required String cookie,
    required int taskId,
  }) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      selectedTask = await service.getTaskById(
        cookie: cookie,
        taskId: taskId,
      );

      print("Selected task: $selectedTask");
    } catch (e) {
      error = e.toString();
      selectedTask = null;
    }

    loading = false;
    notifyListeners();
  }

  void clearSelectedTask() {
    selectedTask = null;
    notifyListeners();
  }
}