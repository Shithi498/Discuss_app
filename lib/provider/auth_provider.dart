import 'dart:convert';

import 'package:discuss/view/home_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../model/user_model.dart';
import '../services/odoo_discuss_service.dart';
import '../view/login_screen.dart';

class AuthProvider extends ChangeNotifier {
  final OdooDiscussService repo;

  AuthProvider({required this.repo});

  OdooSession? session;
  OdooUser? user;
  bool _loading = false;
  bool get loading => _loading;
  bool autologgeedin = false;
  String? _error;
  String? get error => _error;

  bool get isLoggedIn => session != null;

  String? get sessionCookie => session?.cookie;
  int? get uid => session?.uid;
  Map<String, dynamic>? get userContext => session?.userContext;
  String? get userName => session?.userContext?['name'];

  int? get partnerId {
    final partner = session?.userContext?['partner_id'];
    if (partner is List && partner.isNotEmpty) {
      return partner.first as int;
    }
    return null;
  }



  Future<void> login({
    required String db,
    required String login,
    required String password,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await repo.login(
        db: db,
        login: login,
        password: password,
      );

      session = result;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('session_id', result.sessionId);
      await prefs.setString('base_url', result.baseUrl);
      await prefs.setString('db', result.db);
      await prefs.setInt('uid', result.uid);
    } catch (e) {
      _error = e.toString();
      session = null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
  // Future<void> tryAutoLogin(BuildContext context) async {
  //   _loading = true;
  //   notifyListeners();
  //
  //   final prefs = await SharedPreferences.getInstance();
  //   final sessionId = prefs.getString('sessionCookie');
  //
  //   if (sessionId  == null) {
  //     debugPrint("❗ No session found, login needed");
  //     _loading = false;
  //     notifyListeners();
  //     return;
  //   }
  //
  //   debugPrint("✅ Found stored cookie: $sessionId ");
  //
  //   final res = await http.post(
  //     // Uri.parse("http://72.61.250.60:8069/web/session/get_session_info"),
  //     //   Uri.parse("https://sdi.kendroo.com/web/session/get_session_info"),
  //     Uri.parse("https://demo.kendroo.com/web/session/get_session_info"),
  //     headers: {
  //       "Content-Type": "application/json",
  //       "Cookie": sessionId !,
  //     },
  //     body: jsonEncode({
  //       "jsonrpc": "2.0",
  //       "params": {},
  //     }),
  //   );
  //
  //   debugPrint("🔹 AutoLogin Status: ${res.statusCode}");
  //   debugPrint("🔹 AutoLogin Body: ${res.body}");
  //
  //   try {
  //     if (res.statusCode == 200) {
  //       final data = jsonDecode(res.body);
  //       final result = data['result'];
  //
  //       if (result != null && result['uid'] != null) {
  //         user = OdooUser.fromJson(result);
  //         debugPrint("✅ AutoLogin successful → Dashboard");
  //         autologgeedin=true;
  //         Navigator.of(context).pushReplacement(
  //           MaterialPageRoute(builder: (_) => HomePage()),
  //         );
  //       } else {
  //         debugPrint("⚠ Cookie invalid → Login required");
  //       }
  //     } else {
  //       debugPrint("⚠ Session expired → Login required");
  //     }
  //   } catch (e) {
  //     debugPrint("❌ Error parsing auto login response: $e");
  //   }
  //
  //   _loading = false;
  //   notifyListeners();
  // }
  Future<bool> tryAutoLogin({
    required String db,
    required String baseUrl,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedSessionId = prefs.getString('session_id');
      final savedUid = prefs.getInt('uid');

      if (savedSessionId == null || savedUid == null) {
        session = null;
        return false;
      }

      final cookie = 'session_id=$savedSessionId';

      final context = await repo.getUserContext(
        cookie: cookie,
        uid: savedUid,
      );

      session = OdooSession(
        baseUrl: baseUrl,
        db: db,
        uid: savedUid,
        sessionId: savedSessionId,
        userContext: context,
      );
      return true;
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('session_id');
      await prefs.remove('uid');
      await prefs.remove('base_url');
      await prefs.remove('db');

      session = null;
      _error = null;
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> logout(BuildContext context) async {
    _loading = true;
    notifyListeners();

    try {
      session = null;

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('session_id');
      await prefs.remove('uid');
      await prefs.remove('base_url');
      await prefs.remove('db');

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
      );
    } catch (e) {
      debugPrint('Logout error: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
