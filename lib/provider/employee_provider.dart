// import 'dart:convert';
// import 'package:flutter/cupertino.dart';
// import 'package:http/http.dart' as http;
// import '../model/employee_model.dart';
// import 'auth_provider.dart';
//
// class EmployeeProvider extends ChangeNotifier {
//   final AuthProvider? auth;
//   EmployeeProvider(this.auth);
//
//   EmployeeResponse? _profile;
//   bool _isLoading = false;
//   String? _error;
//
//   EmployeeResponse? get profile => _profile;
//   bool get isLoading => _isLoading;
//   String? get error => _error;
//
//   Future<void> loadProfile() async {
//     if (auth?.sessionCookie == null) {
//       _error = 'No session cookie found';
//       notifyListeners();
//       return;
//     }
//
//     _isLoading = true;
//     _error = null;
//     notifyListeners();
//
//     try {
//       final url = Uri.parse('https://demo.kendroo.com/api/my/employee');
//       final res = await http.post(
//         url,
//         headers: {
//           'Content-Type': 'application/json',
//           'Cookie': auth!.sessionCookie!,
//         },
//         body: jsonEncode({
//           "jsonrpc": "2.0",
//           "method": "call",
//           "params": {},
//           "id": null,
//         }),
//       );
//
//       debugPrint('➡️ [Employee] POST $url');
//       debugPrint('➡️ [Employee] Cookie: ${auth!.sessionCookie}');
//       debugPrint('⬅️ [Employee] Response: ${res.statusCode} ${res.body}');
//
//       if (res.statusCode == 200) {
//         final data = jsonDecode(res.body);
//         _profile = EmployeeResponse.fromJson(data);
//       } else {
//         throw Exception('HTTP ${res.statusCode}: ${res.body}');
//       }
//     } catch (e, st) {
//       debugPrint('❌ [EmployeeProvider] Error: $e\n$st');
//       _error = 'Exception: $e';
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
//
//
//
//
// }


// employee_provider.dart
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;



import 'package:flutter/foundation.dart';

import '../services/odoo_discuss_service.dart';
import 'auth_provider.dart';

class EmployeeProvider extends ChangeNotifier {
  final OdooDiscussService service;
  final AuthProvider authProvider;

  EmployeeProvider({
    required this.service,
    required this.authProvider,
  });

  Map<String, dynamic>? _profile;
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String? get profileImage => _profile?['image_1920'];


  Uint8List? safeOdooImageDecode(dynamic image) {
    try {
      if (image == null) return null;

      String img = image.toString();

      if (img == "false" || img.isEmpty) return null;

      if (img.contains(',')) {
        img = img.split(',').last;
      }

      img = img.trim();

      final bytes = base64Decode(img);
      if (!_isSupportedImageBytes(bytes)) return null;

      return bytes;
    } catch (e) {
      print("❌ IMAGE DECODE FAILED: $e");
      return null;
    }
  }

  bool _isSupportedImageBytes(Uint8List bytes) {
    final isPng = bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47 &&
        bytes[4] == 0x0D &&
        bytes[5] == 0x0A &&
        bytes[6] == 0x1A &&
        bytes[7] == 0x0A;

    final isJpg = bytes.length >= 3 &&
        bytes[0] == 0xFF &&
        bytes[1] == 0xD8 &&
        bytes[2] == 0xFF;

    final isGif = bytes.length >= 6 &&
        bytes[0] == 0x47 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x38 &&
        (bytes[4] == 0x37 || bytes[4] == 0x39) &&
        bytes[5] == 0x61;

    final isWebp = bytes.length >= 12 &&
        bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x45 &&
        bytes[10] == 0x42 &&
        bytes[11] == 0x50;

    return isPng || isJpg || isGif || isWebp;
  }
  Future<void> loadProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final cookie = authProvider.sessionCookie;
      final uid = authProvider.uid;

      if (cookie == null || cookie.isEmpty || uid == null) {
        throw Exception('User is not logged in');
      }

      final userContext = await service.getUserContext(
        cookie: cookie,
        uid: uid,
      );

      if (userContext == null) {
        throw Exception('User context not found');
      }

      final partnerField = userContext['partner_id'];
      if (partnerField is! List || partnerField.isEmpty) {
        throw Exception('Partner ID not found');
      }

      final int partnerId = partnerField.first as int;

      final partner = await service.getPartnerProfile(
        cookie: cookie,
        partnerId: partnerId,
      );

      final chatCount = await service.getChatCount(
        cookie: cookie,
        partnerId: partnerId,
      );

      final messageCount = await service.getMessageCount(
        cookie: cookie,
        partnerId: partnerId,
      );
print("messageCount,$messageCount");
      if (partner == null) {
        throw Exception('Partner profile not found');
      }
      final rawImage = partner?['image_1920'];
      _profile = {
        ...partner,
        'uid': userContext['id'],
        'login': userContext['login'],
        'user_email': userContext['email'],
        'joined_create_date': userContext['create_date'],
        'partner_id': userContext['partner_id'],
        'chat_count': chatCount,
        'message_count': messageCount,
        'image_bytes': safeOdooImageDecode(rawImage),
      };


    } catch (e, st) {
      debugPrint('❌ [EmployeeProvider] Error: $e\n$st');
      _error = e.toString();
      _profile = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshProfile() async {
    await loadProfile();
  }

  void clearProfile() {
    _profile = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  int? get partnerId {
    final partner = _profile?['partner_id'];
    if (partner is List && partner.isNotEmpty) {
      return partner.first as int;
    }
    if (partner is int) {
      return partner;
    }
    return null;
  }

  String get userName => (_profile?['name'] ?? 'User').toString();

  String get email =>
      (_profile?['email'] ?? _profile?['user_email'] ?? _profile?['login'] ?? '—')
          .toString();

  String get phone =>
      (_profile?['phone'] ?? _profile?['mobile'] ?? '—').toString();

  String get joinedYear {
    final createDate =
        _profile?['joined_create_date'] ?? _profile?['create_date'];
    if (createDate is String && createDate.length >= 4) {
      return createDate.substring(0, 4);
    }
    return '—';
  }
}
