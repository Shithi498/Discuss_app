import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../model/search_model.dart';
import '../model/thread_model.dart';

class OdooSession {
  final String baseUrl;
  final String db;
  final int uid;
  final String sessionId;
  final Map<String, dynamic>? userContext;

  OdooSession({
    required this.baseUrl,
    required this.db,
    required this.uid,
    required this.sessionId,
    this.userContext,
  });

  String get cookie => 'session_id=$sessionId';
}

class OdooDiscussService {
  final String baseUrl;

  OdooDiscussService({required this.baseUrl});

  Uri _authenticateUri() =>
      Uri.parse('$baseUrl/web/session/authenticate');

  Uri _callKwUri(String model, String method) =>
      Uri.parse('$baseUrl/web/dataset/call_kw/$model/$method');

  Map<String, String> _headers({String? cookie}) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (cookie != null) 'Cookie': cookie,
    };
  }

  Future<OdooSession> login({
    required String db,
    required String login,
    required String password,
  }) async {
    final response = await http.post(
      _authenticateUri(),
      headers: _headers(),
      body: jsonEncode({
        'jsonrpc': '2.0',
        'params': {
          'db': db,
          'login': login,
          'password': password,
        },
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Login failed: HTTP ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;

    if (json['error'] != null) {
      print('Login failed: ${json['error']}');
      throw Exception('Login failed: ${json['error']}');
    }

    final result = json['result'] as Map<String, dynamic>?;
    final uid = result?['uid'];

    if (uid == null || uid is! int || uid <= 0) {
      throw Exception('Login failed: wrong db/login/password');
    }

    final rawCookie = response.headers['set-cookie'];
    if (rawCookie == null || !rawCookie.contains('session_id=')) {
      throw Exception('Login failed: session cookie not found');
    }

    final sessionId = _extractSessionId(rawCookie);

    final context = await getUserContext(
      cookie: 'session_id=$sessionId',
      uid: uid,
    );

    return OdooSession(
      baseUrl: baseUrl,
      db: db,
      uid: uid,
      sessionId: sessionId,
      userContext: context,
    );
  }
  String _extractSessionId(String rawCookie) {
    final parts = rawCookie.split(';');
    for (final p in parts) {
      final item = p.trim();
      if (item.startsWith('session_id=')) {
        return item.substring('session_id='.length);
      }
    }
    throw Exception('session_id not found in cookie');
  }

  Future<dynamic> callKw({
     String? cookie,
    required String model,
    required String method,
    List<dynamic> args = const [],
    Map<String, dynamic> kwargs = const {},
  }) async {
    final response = await http.post(
      _callKwUri(model, method),
      headers: _headers(cookie: cookie),
      body: jsonEncode({
        'jsonrpc': '2.0',
        'method': 'call',
        'params': {
          'model': model,
          'method': method,
          'args': args,
          'kwargs': kwargs,
        },
        'id': DateTime.now().millisecondsSinceEpoch,
      }),
    );
    print("URL = ${_callKwUri(model, method)}");
    print("MODEL = $model");
    print("METHOD = $method");
    if (response.statusCode != 200) {
      throw Exception(
        'callKw failed: HTTP ${response.statusCode}, body: ${response.body}',
      );
    }

    final json = jsonDecode(response.body);

    if (json['error'] != null) {
      throw Exception('Odoo RPC error: ${json['error']}');
    }

    return json['result'];
  }


  // Future<Map<String, dynamic>?> fetchUserInfo({
  //   required int uid,
  // }) async {
  //   final response = await callKw(
  //     model: 'res.users',
  //     method: 'search_read',
  //     args: [
  //       [
  //         ['id', '=', uid],
  //       ]
  //     ],
  //     kwargs: {
  //       'fields': [
  //         'id',
  //         'name',
  //         'email',
  //         'login',
  //         'employee_id',
  //         'image_1920',
  //         'address_id'
  //       ],
  //       'limit': 1,
  //     },
  //   );
  //
  //   final users = List<Map<String, dynamic>>.from(response);
  //   print("user info, $users");
  //   if (users.isEmpty) {
  //     return null;
  //   }
  //
  //   return users.first;
  // }
  // Future<bool> updateUserInfo({
  //   required int uid,
  //   String? name,
  //   String? email,
  //   String? login,
  //   String? image1920,
  // }) async {
  //   final values = <String, dynamic>{};
  //
  //   if (name != null) values['name'] = name;
  //   if (email != null) values['email'] = email;
  //   if (login != null) values['login'] = login;
  //   if (image1920 != null) values['image_1920'] = image1920;
  //
  //   if (values.isEmpty) {
  //     return false;
  //   }
  //
  //   final response = await callKw(
  //     model: 'res.users',
  //     method: 'write',
  //     args: [
  //       [uid],
  //       values,
  //     ],
  //     kwargs: {},
  //   );
  //
  //   return response == true;
  // }
  // Future<Map<String, dynamic>?> fetchEmployeeInfo({
  //   required int employeeId,
  // }) async {
  //   final response = await callKw(
  //     model: 'hr.employee',
  //     method: 'search_read',
  //     args: [
  //       [
  //         ['id', '=', employeeId],
  //       ]
  //     ],
  //     kwargs: {
  //       'fields': [
  //         'id',
  //         'name',
  //         'work_email',
  //         'work_phone',
  //         'mobile_phone',
  //         'department_id',
  //         'job_id',
  //         'parent_id',
  //         // Personal info
  //         'birthday',
  //         'marital',
  //         'identification_id',
  //
  //         // Private address / contact
  //         'private_street',
  //         'private_street2',
  //         'private_city',
  //         'private_state_id',
  //         'private_zip',
  //         'private_country_id',
  //         'private_phone',
  //         'private_email',
  //         'country_id',
  //         // Emergency contact
  //         'emergency_contact',
  //         'emergency_phone',
  //         'address_id'
  //       ],
  //       'limit': 1,
  //     },
  //   );
  //
  //   final employees = List<Map<String, dynamic>>.from(response);
  //
  //   if (employees.isEmpty) {
  //     return null;
  //   }
  //
  //   return employees.first;
  // }
  //
  // Future<bool> updateEmployeeInfo({
  //   required int employeeId,
  //
  //   String? name,
  //   String? workEmail,
  //   String? workPhone,
  //   String? mobilePhone,
  //
  //   int? departmentId,
  //   int? jobId,
  //   int? parentId,
  //
  //
  //   String? birthday,
  //   String? marital,
  //   String? identificationId,
  //
  //
  //   String? privateStreet,
  //   String? privateStreet2,
  //   String? privateCity,
  //   int? privateStateId,
  //   String? privateZip,
  //   int? privateCountryId,
  //   String? privatePhone,
  //   String? privateEmail,
  //
  //   String? emergencyContact,
  //   String? emergencyPhone,
  // }) async {
  //   final values = <String, dynamic>{};
  //
  //   if (name != null) values['name'] = name;
  //   if (workEmail != null) values['work_email'] = workEmail;
  //   if (workPhone != null) values['work_phone'] = workPhone;
  //   if (mobilePhone != null) values['mobile_phone'] = mobilePhone;
  //
  //   if (departmentId != null) values['department_id'] = departmentId;
  //   if (jobId != null) values['job_id'] = jobId;
  //   if (parentId != null) values['parent_id'] = parentId;
  //
  //   if (birthday != null) values['birthday'] = birthday;
  //   if (marital != null) values['marital'] = marital;
  //   if (identificationId != null) values['identification_id'] = identificationId;
  //
  //   if (privateStreet != null) values['private_street'] = privateStreet;
  //   if (privateStreet2 != null) values['private_street2'] = privateStreet2;
  //   if (privateCity != null) values['private_city'] = privateCity;
  //   if (privateStateId != null) values['private_state_id'] = privateStateId;
  //   if (privateZip != null) values['private_zip'] = privateZip;
  //   if (privateCountryId != null) values['private_country_id'] = privateCountryId;
  //   if (privatePhone != null) values['private_phone'] = privatePhone;
  //   if (privateEmail != null) values['private_email'] = privateEmail;
  //
  //   if (emergencyContact != null) {
  //     values['emergency_contact'] = emergencyContact;
  //   }
  //
  //   if (emergencyPhone != null) {
  //     values['emergency_phone'] = emergencyPhone;
  //   }
  //
  //   if (values.isEmpty) {
  //     return false;
  //   }
  //
  //   final response = await callKw(
  //     model: 'hr.employee',
  //     method: 'write',
  //     args: [
  //       [employeeId],
  //       values,
  //     ],
  //     kwargs: {},
  //   );
  //
  //   return response == true;
  // }
  //
  // Future<List<Map<String, dynamic>>> fetchCountries() async {
  //   print("========== FETCH COUNTRIES START ==========");
  //
  //   try {
  //     final result = await callKw(
  //       model: "res.country",
  //       method: "search_read",
  //       args: [
  //         [], // domain
  //       ],
  //       kwargs: {
  //         "fields": ["id", "name"],
  //         "order": "name asc",
  //       },
  //     );
  //
  //     print("FETCH COUNTRIES RESULT: $result");
  //     print("FETCH COUNTRIES TYPE: ${result.runtimeType}");
  //     print("========== FETCH COUNTRIES END ==========");
  //
  //     if (result is List) {
  //       return result
  //           .whereType<Map>()
  //           .map((item) => Map<String, dynamic>.from(item))
  //           .toList();
  //     }
  //
  //     return [];
  //   } catch (e, stackTrace) {
  //     print("========== FETCH COUNTRIES ERROR ==========");
  //     print("ERROR: $e");
  //     print("STACKTRACE:");
  //     print(stackTrace);
  //     print("========== FETCH COUNTRIES ERROR END ==========");
  //
  //     rethrow;
  //   }
  // }
  //
  // Future<int> getEmployeeId(int uid) async {
  //   final result = await callKw(
  //     model: "hr.employee",
  //     method: "search_read",
  //     args: [
  //       [
  //         ["user_id", "=", uid]
  //       ]
  //     ],
  //     kwargs: {"fields": ["id"], "limit": 1},
  //   );
  //
  //   if ((result as List).isEmpty) {
  //     throw Exception("No employee linked to this user (Employee → Related User missing)");
  //   }
  //   return result[0]["id"] as int;
  // }
  // Future<List<Map<String, dynamic>>> fetchEmployeeContractInfo({
  //   required int employeeId,
  // }) async {
  //   try {
  //     final response = await callKw(
  //       model: 'hr.contract',
  //       method: 'search_read',
  //       args: [
  //         [
  //           ['employee_id', '=', employeeId],
  //           ['state', 'in', ['open', 'close', 'draft']],
  //         ]
  //       ],
  //       kwargs: {
  //         'fields': [
  //           'id',
  //           'name',
  //           'employee_id',
  //           'date_start',
  //           'contract_type_id',
  //           'state',
  //           'resource_calendar_id'
  //         ],
  //         'order': 'date_start desc',
  //         'limit': 1,
  //       },
  //     );
  //
  //     // Check response type and content
  //     if (response == null) {
  //       debugPrint("fetchEmployeeContractInfo: response is null");
  //       return [];
  //     }
  //
  //     if (response is! List) {
  //       debugPrint("fetchEmployeeContractInfo: response is not a List: $response");
  //       return [];
  //     }
  //
  //     debugPrint("fetchEmployeeContractInfo response: $response");
  //
  //     // Make sure all entries are maps
  //     final contracts = <Map<String, dynamic>>[];
  //     for (var item in response) {
  //       if (item is Map<String, dynamic>) {
  //         contracts.add(item);
  //       } else {
  //         debugPrint("fetchEmployeeContractInfo: item is not Map: $item");
  //       }
  //     }
  //
  //     return contracts;
  //   } catch (e, st) {
  //     debugPrint("Error in fetchEmployeeContractInfo: $e\n$st");
  //     return [];
  //   }
  // }
  // Future<Map<String, dynamic>?> fetchCurrentUserEmployeeDetails({
  //   required int uid,
  // }) async {
  //   final user = await fetchUserInfo(uid: uid);
  //
  //   if (user == null) {
  //     return null;
  //   }
  //
  //   final employeeId = _getMany2oneId(user['employee_id']);
  //
  //   if (employeeId == null) {
  //     return {
  //       'user_id': user['id'],
  //       'name': user['name'],
  //       'email': user['email'],
  //       'employee_id': null,
  //     };
  //   }
  //
  //   final employee = await fetchEmployeeInfo(employeeId: employeeId);
  //
  //   if (employee == null) {
  //     return {
  //       'user_id': user['id'],
  //       'name': user['name'],
  //       'email': user['email'],
  //       'employee_id': employeeId,
  //     };
  //   }
  //
  //   return {
  //     'user_id': user['id'],
  //     'employee_id': employee['id'],
  //     'address_id' : user['address_id'],
  //     // Basic
  //     'name': employee['name'] ?? user['name'],
  //     'email': employee['work_email'] ?? user['email'],
  //     'phone': employee['work_phone'] ?? employee['mobile_phone'],
  //     'job_id': employee['job_id'] ,
  //
  //     // HR info
  //     'department': _getMany2oneName(employee['department_id']),
  //     'department_id': _getMany2oneId(employee['department_id']),
  //
  //     // Personal info
  //     'date_of_birth': employee['birthday'],
  //     'marital_status': employee['marital'],
  //     'national_id': employee['identification_id'],
  //     'country_id' :employee['country_id'],
  //
  //     // Present/private address
  //     'present_address': _buildAddress(employee),
  //
  //     // Private contact
  //     'private_phone': employee['private_phone'],
  //     'private_email': employee['private_email'],
  //
  //     // Emergency
  //     'emergency_contact_name': employee['emergency_contact'],
  //     'emergency_contact_phone': employee['emergency_phone'],
  //     'image_1920' : user['image_1920']
  //   };
  // }
  //
  // Future<bool> updateCurrentUserEmployeeDetails({
  //   required int uid,
  //
  //   // User fields
  //   String? name,
  //   String? email,
  //   String? login,
  //   //  String? image1920,
  //
  //   // Employee fields
  //   String? workPhone,
  //   String? mobilePhone,
  //   String? birthday,
  //   String? marital,
  //   String? nationalId,
  //
  //   // Address
  //   String? privateStreet,
  //   String? privateStreet2,
  //   String? privateCity,
  //   int? privateStateId,
  //   String? privateZip,
  //   int? privateCountryId,
  //
  //   // Private contact
  //   String? privatePhone,
  //   String? privateEmail,
  //
  //   // Emergency
  //   String? emergencyContactName,
  //   String? emergencyContactPhone,
  //   String? imageBase64,
  //   int? country_id
  // }) async {
  //   final user = await fetchUserInfo(uid: uid);
  //
  //   if (user == null) {
  //     return false;
  //   }
  //
  //   final employeeId = _getMany2oneId(user['employee_id']);
  //
  //   bool userUpdated = true;
  //   bool employeeUpdated = true;
  //
  //
  //   final userValues = <String, dynamic>{};
  //
  //   if (name != null) userValues['name'] = name;
  //   if (email != null) userValues['email'] = email;
  //   if (login != null) userValues['login'] = login;
  //   if (imageBase64 != null) userValues['image_1920'] =imageBase64;
  //
  //   if (userValues.isNotEmpty) {
  //     final userResponse = await callKw(
  //       model: 'res.users',
  //       method: 'write',
  //       args: [
  //         [uid],
  //         userValues,
  //       ],
  //       kwargs: {},
  //     );
  //
  //     userUpdated = userResponse == true;
  //   }
  //
  //
  //   if (employeeId != null) {
  //     final employeeValues = <String, dynamic>{};
  //
  //     if (name != null) employeeValues['name'] = name;
  //     if (email != null) employeeValues['work_email'] = email;
  //     if (workPhone != null) employeeValues['work_phone'] = workPhone;
  //     if (mobilePhone != null) employeeValues['mobile_phone'] = mobilePhone;
  //
  //     if (birthday != null) employeeValues['birthday'] = birthday;
  //     if (marital != null) employeeValues['marital'] = marital;
  //     if (nationalId != null) employeeValues['identification_id'] = nationalId;
  //
  //     if (privateStreet != null) employeeValues['private_street'] = privateStreet;
  //     if (privateStreet2 != null) employeeValues['private_street2'] = privateStreet2;
  //     if (privateCity != null) employeeValues['private_city'] = privateCity;
  //     if (privateStateId != null) employeeValues['private_state_id'] = privateStateId;
  //     if (privateZip != null) employeeValues['private_zip'] = privateZip;
  //     if (privateCountryId != null) employeeValues['private_country_id'] = privateCountryId;
  //
  //     if (privatePhone != null) employeeValues['private_phone'] = privatePhone;
  //     if (privateEmail != null) employeeValues['private_email'] = privateEmail;
  //     if (country_id != null) employeeValues['country_id'] = country_id;
  //
  //     if (emergencyContactName != null) {
  //       employeeValues['emergency_contact'] = emergencyContactName;
  //     }
  //
  //     if (emergencyContactPhone != null) {
  //       employeeValues['emergency_phone'] = emergencyContactPhone;
  //     }
  //
  //     if (employeeValues.isNotEmpty) {
  //       final employeeResponse = await callKw(
  //         model: 'hr.employee',
  //         method: 'write',
  //         args: [
  //           [employeeId],
  //           employeeValues,
  //         ],
  //         kwargs: {},
  //       );
  //
  //       employeeUpdated = employeeResponse == true;
  //     }
  //   }
  //
  //   return userUpdated && employeeUpdated;
  // }
  //
  // int? _getMany2oneId(dynamic value) {
  //   if (value is List && value.isNotEmpty) {
  //     return value[0];
  //   }
  //   return null;
  // }
  //
  // String _getMany2oneName(dynamic value) {
  //   if (value is List && value.length > 1) {
  //     return value[1].toString();
  //   }
  //   return "";
  // }
  //
  // String _buildAddress(Map<String, dynamic> employee) {
  //   final parts = [
  //     employee['private_street'],
  //     employee['private_street2'],
  //     employee['private_city'],
  //     _getMany2oneName(employee['private_state_id']),
  //     employee['private_zip'],
  //     _getMany2oneName(employee['private_country_id']),
  //   ];
  //
  //   return parts
  //       .where((value) => value != null && value != false && value.toString().trim().isNotEmpty)
  //       .map((value) => value.toString())
  //       .join(', ');
  // }

  Future<List<SearchUser>> searchUsers({
    required String cookie,
    required String query,
  }) async {
    final String text = query.trim();

    if (text.isEmpty) return [];

    final result = await callKw(
      cookie: cookie,
      model: 'res.users',
      method: 'search_read',
      args: [
        [
          '|',
          ['name', 'ilike', text],
          ['email', 'ilike', text],
          ['active', '=', true],
        ]
      ],
      kwargs: {
        'fields': ['id', 'name', 'email', 'partner_id'],
        'limit': 20,
        'order': 'name asc',
      },
    );

    final List rows = List.from(result);

    return rows.map((e) {
      final m = Map<String, dynamic>.from(e);
      return SearchUser.fromJson(m, baseUrl);
    }).toList();
  }

  // Future<int> createOrGetThread({
  //   required String cookie,
  //   required int partnerId,
  // }) async {
  //   final result = await callKw(
  //     cookie: cookie,
  //     model: 'discuss.channel',
  //     method: 'channel_get',
  //     args: [
  //    //   [partnerId],
  //     ],
  //     kwargs: {
  //       'partners_to': [partnerId],
  //     },
  //   );
  //
  //   return result['id'] as int;
  // }

  // Future<int> createOrGetThread({
  //   required String cookie,
  //    required List<int> partnerId,
  // }) async {
  //   // if (partnerId <= 0) {
  //   //   throw Exception('Invalid partnerId: $partnerId');
  //   // }
  //
  //   final partnerData = await callKw(
  //     cookie: cookie,
  //     model: 'res.partner',
  //     method: 'read',
  //     args: [
  //      // [partnerId],
  //       partnerId,
  //       ['id', 'name'],
  //     ],
  //   );
  //
  //   if (partnerData == null || partnerData.isEmpty) {
  //     throw Exception('Partner not found for id: $partnerId');
  //   }
  //
  //   final name = partnerData[0]['name'];
  //   if (name == false || name == null || name.toString().trim().isEmpty) {
  //     await callKw(
  //       cookie: cookie,
  //       model: 'res.partner',
  //       method: 'write',
  //       args: [
  //         [partnerId],
  //         {'name': 'No Name'},
  //       ],
  //     );
  //   }
  //
  //
  //   final result = await callKw(
  //     cookie: cookie,
  //     model: 'discuss.channel',
  //     method: 'channel_get',
  //     args: [],
  //     kwargs: {
  //      // 'partners_to': [partnerId],
  //       'partners_to': partnerId,
  //     },
  //   );
  //
  //   return result['id'] as int;
  // }
  Future<int?> createAttachment({
    required String cookie,
    required int channelId,
    required String fileName,
    required String base64Data,
    required String mimeType,
  }) async {
    final result = await callKw(
      cookie: cookie,
      model: 'ir.attachment',
      method: 'create',
      args: [
        {
          'name': fileName,
          'datas': base64Data,
          'mimetype': mimeType,
          'res_model': 'discuss.channel',
          'res_id': channelId,
          'type': 'binary',
        }
      ],
      kwargs: {},
    );

    if (result is int) {
      return result;
    } else if (result is List && result.isNotEmpty) {
      return result.first as int;
    }
    return null;
  }
  // Future<List<Map<String, dynamic>>> fetchNotificationList({
  //   required String cookie,
  //   int limit = 20,
  // }) async {
  //   try {
  //     final channels = await callKw(
  //       cookie: cookie,
  //       model: 'discuss.channel',
  //       method: 'search_read',
  //       args: [
  //         []
  //       ],
  //       kwargs: {
  //         'fields': ['id', 'name', 'channel_type', 'write_date'],
  //         'limit': limit,
  //         'order': 'write_date desc',
  //       },
  //     );
  //
  //     if (channels is! List) return [];
  //
  //     final List<Map<String, dynamic>> dropdownItems = [];
  //
  //     for (final channel in channels) {
  //       final channelId = channel['id'];
  //
  //       final messages = await callKw(
  //         cookie: cookie,
  //         model: 'mail.message',
  //         method: 'search_read',
  //         args: [
  //           [
  //             ['model', '=', 'discuss.channel'],
  //             ['res_id', '=', channelId],
  //             ['message_type', '=', 'comment'],
  //           ]
  //         ],
  //         kwargs: {
  //           'fields': [
  //             'id',
  //             'body',
  //             'author_id',
  //             'date',
  //             'message_type',
  //             'subtype_id'
  //           ],
  //           'limit': 1,
  //           'order': 'date desc',
  //         },
  //       );
  //
  //       Map<String, dynamic>? lastMessage;
  //
  //       if (messages is List && messages.isNotEmpty) {
  //         lastMessage = Map<String, dynamic>.from(messages.first);
  //       }
  //
  //       dropdownItems.add({
  //         'channel_id': channelId,
  //         'name': channel['name'],
  //         'channel_type': channel['channel_type'],
  //         'last_message': cleanHtml(lastMessage?['body'] ?? ''),
  //         'author_id': lastMessage?['author_id'],
  //         'date': lastMessage?['date'] ?? channel['write_date'],
  //         'message_id': lastMessage?['id'],
  //       });
  //     }
  //
  //     dropdownItems.sort((a, b) {
  //       final aDate = DateTime.tryParse(a['date'] ?? '') ?? DateTime(1970);
  //       final bDate = DateTime.tryParse(b['date'] ?? '') ?? DateTime(1970);
  //       return bDate.compareTo(aDate);
  //     });
  //
  //     print("Discuss dropdown result: $dropdownItems");
  //     return dropdownItems;
  //   } catch (e, stackTrace) {
  //     print("❌ Error fetching discuss dropdown:");
  //     print("Error: $e");
  //     print("StackTrace: $stackTrace");
  //     return [];
  //   }
  // }
  //
  // String cleanHtml(String html) {
  //   return html
  //       .replaceAll(RegExp(r'<[^>]*>'), '')
  //       .replaceAll('&nbsp;', ' ')
  //       .trim();
  // }

  Future<List<Map<String, dynamic>>> fetchDiscussDropdownExact({
    required String cookie,
    required int currentPartnerId,
    int limit = 50,
  }) async {
    try {
      final channels = await callKw(
        cookie: cookie,
        model: 'discuss.channel',
        method: 'search_read',
        args: [
          [
            ['is_member', '=', true],
          ]
        ],
        kwargs: {
          'fields': ['id', 'name', 'channel_type', 'avatar_128', 'write_date'],
          'limit': limit,
          'order': 'write_date desc',
        },
      );

      if (channels is! List || channels.isEmpty) return [];

      final channelIds = channels.map((e) => e['id']).toList();

      final previews = await callKw(
        cookie: cookie,
        model: 'discuss.channel',
        method: 'channel_fetch_preview',
        args: [channelIds],
        kwargs: {},
      );

      final members = await callKw(
        cookie: cookie,
        model: 'discuss.channel.member',
        method: 'search_read',
        args: [
          [
            ['channel_id', 'in', channelIds],
            ['partner_id', '=', currentPartnerId],
          ]
        ],
        kwargs: {
          'fields': [
            'channel_id',
            'message_unread_counter',
            'is_pinned',
            'last_interest_dt',
            'custom_channel_name',
          ],
        },
      );

      final previewMap = <int, Map<String, dynamic>>{};
      if (previews is List) {
        for (final p in previews) {
          previewMap[p['id']] = Map<String, dynamic>.from(p);
        }
      }

      final memberMap = <int, Map<String, dynamic>>{};
      if (members is List) {
        for (final m in members) {
          final channel = m['channel_id'];
          if (channel is List && channel.isNotEmpty) {
            memberMap[channel[0]] = Map<String, dynamic>.from(m);
          }
        }
      }

      final result = <Map<String, dynamic>>[];

      for (final ch in channels) {
        final channelId = ch['id'];
        final preview = previewMap[channelId];
        final member = memberMap[channelId];

        final lastMessage = preview?['last_message'];
        final body = lastMessage is Map ? lastMessage['body'] : '';
        final author = lastMessage is Map ? lastMessage['author_id'] : null;

        result.add({
          'channel_id': channelId,
          'name': member?['custom_channel_name'] ?? ch['name'],
          'channel_type': ch['channel_type'],
          'avatar_128': ch['avatar_128'],
          'last_message': formatOdooDiscussPreview(
            body: body,
            authorId: author,
            currentPartnerId: currentPartnerId,
          ),
          'date': lastMessage is Map ? lastMessage['date'] : member?['last_interest_dt'],
          'unread_count': member?['message_unread_counter'] ?? 0,
          'is_pinned': member?['is_pinned'] ?? false,
        });
      }

      result.removeWhere((e) => e['is_pinned'] != true);

      result.sort((a, b) {
        final ad = DateTime.tryParse(a['date']?.toString() ?? '') ?? DateTime(1970);
        final bd = DateTime.tryParse(b['date']?.toString() ?? '') ?? DateTime(1970);
        return bd.compareTo(ad);
      });

      print("Discuss dropdown exact result: $result");
      return result;
    } catch (e, stackTrace) {
      print("❌ Discuss dropdown error: $e");
      print(stackTrace);
      return [];
    }
  }

  String formatOdooDiscussPreview({
    required dynamic body,
    required dynamic authorId,
    required int currentPartnerId,
  }) {
    final text = cleanHtml(body?.toString() ?? '');

    String authorName = '';
    int? authorPartnerId;

    if (authorId is List && authorId.isNotEmpty) {
      authorPartnerId = authorId[0];
      if (authorId.length > 1) {
        authorName = authorId[1].toString();
      }
    }

    if (text.startsWith('AGORA_CALL::')) {
      return authorName.isNotEmpty ? '$authorName is calling you.' : 'Incoming call';
    }

    if (text.contains('Discuss Agora Call created')) {
      return authorName.isNotEmpty
          ? '$authorName started a live conference'
          : 'started a live conference';
    }

    if (authorPartnerId == currentPartnerId) {
      return text.isEmpty ? 'You:' : 'You: $text';
    }

    if (authorName.isNotEmpty) {
      return '$authorName: $text';
    }

    return text;
  }


  String cleanHtml(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .trim();
  }
  // Future<List<dynamic>> fetchNotificationList({
  //   required String cookie,
  //   required int partnerId,
  //   int limit = 20,
  // }) async {
  //   try {
  //     final result = await callKw(
  //       cookie: cookie,
  //       model: 'mail.message',
  //       method: 'search_read',
  //       args: [
  //         [
  //        //   ['needaction', '=', true], // Pulls items bound to the notification badge
  //       //    ['partner_ids', 'in', [partnerId]], // Filters to notifications belonging to this user
  //         ]
  //       ],
  //       kwargs: {
  //         'fields': [
  //           'id',
  //           'body',
  //           'author_id',
  //           'date',
  //           'message_type',
  //           'subtype_id'
  //         ],
  //         'limit': limit,
  //         'order': 'date desc', // Sorted by freshest notifications first
  //       },
  //     );
  //
  //     print("Discuss notification result: $result");
  //
  //     if (result is List) {
  //       return result;
  //     } else {
  //       print("Unexpected result type: ${result.runtimeType}");
  //       print("Unexpected result value: $result");
  //       return [];
  //     }
  //   } catch (e, stackTrace) {
  //     print("❌ Error fetching discuss notifications:");
  //     print("Error: $e");
  //     print("StackTrace: $stackTrace");
  //     return [];
  //   }
  // }
  Future<List<Map<String, dynamic>>> fetchNotificationList({
    required String cookie,
    int limit = 20,
  }) async {
    try {
      final channels = await callKw(
        cookie: cookie,
        model: 'discuss.channel',
        method: 'search_read',
        args: [
          []
        ],
        kwargs: {
          'fields': ['id', 'name', 'channel_type', 'write_date'],
          'limit': limit,
          'order': 'write_date desc',
        },
      );

      if (channels is! List) return [];

      final List<Map<String, dynamic>> dropdownItems = [];

      for (final channel in channels) {
        final channelId = channel['id'];

        final messages = await callKw(
          cookie: cookie,
          model: 'mail.message',
          method: 'search_read',
          args: [
            [
              ['model', '=', 'discuss.channel'],
              ['res_id', '=', channelId],
              ['message_type', '=', 'comment'],
            ]
          ],
          kwargs: {
            'fields': [
              'id',
              'body',
              'author_id',
              'date',
              'message_type',
              'subtype_id'
            ],
            'limit': 1,
            'order': 'date desc',
          },
        );

        Map<String, dynamic>? lastMessage;

        if (messages is List && messages.isNotEmpty) {
          lastMessage = Map<String, dynamic>.from(messages.first);
        }

        dropdownItems.add({
          'channel_id': channelId,
          'name': channel['name'],
          'channel_type': channel['channel_type'],
          'last_message': cleanHtml(lastMessage?['body'] ?? ''),
          'author_id': lastMessage?['author_id'],
          'date': lastMessage?['date'] ?? channel['write_date'],
          'message_id': lastMessage?['id'],
        });
      }

      dropdownItems.sort((a, b) {
        final aDate = DateTime.tryParse(a['date'] ?? '') ?? DateTime(1970);
        final bDate = DateTime.tryParse(b['date'] ?? '') ?? DateTime(1970);
        return bDate.compareTo(aDate);
      });

      print("Discuss dropdown result: $dropdownItems");
      return dropdownItems;
    } catch (e, stackTrace) {
      print("❌ Error fetching discuss dropdown:");
      print("Error: $e");
      print("StackTrace: $stackTrace");
      return [];
    }
  }
  Future<bool> messagePostWithAttachment({
    required String cookie,
    required int channelId,
    required String bodyText,
    required int attachmentId,
  }) async {
    final result = await callKw(
      cookie: cookie,
      model: 'discuss.channel',
      method: 'message_post',
      args: [
        [channelId],
      ],
      kwargs: {
        'body': bodyText,
        'message_type': 'comment',
        'subtype_xmlid': 'mail.mt_comment',
        'attachment_ids': [attachmentId],
      },
    );

    return result != null;
  }

  Future<List<dynamic>> fetchAttachments({
    required String cookie,
    required List<int> attachmentIds,
  }) async {

    if (attachmentIds.isEmpty) return [];

    final result = await callKw(
      cookie: cookie,
      model: 'ir.attachment',
      method: 'search_read',
      args: [
        [
          ['id', 'in', attachmentIds]
        ],
        [
          'id',
          'name',
          'mimetype',
          'file_size',
          'res_model',
          'res_id',
          'create_date'
        ]
      ],
      kwargs: {},
    );


    if (result is List) {
      print("File result: $result");
      return result;
    }
    return [];
  }
  Future<bool> renameGroup({
    required String cookie,
    required int channelId,
    required String newName,
  }) async {
    final result = await callKw(
      cookie: cookie,
      model: 'discuss.channel',
      method: 'write',
      args: [
        [channelId],
        {'name': newName},
      ],
      kwargs: {},
    );

    return result == true;
  }
  Future<List<Map<String, dynamic>>> loadChannelCache(int partnerId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('channel_cache_partner_$partnerId');

    if (raw == null || raw.isEmpty) return [];

    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];

    return decoded
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  Future<void> saveChannelCache(
      int partnerId,
      List<Map<String, dynamic>> rows,
      ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'channel_cache_partner_$partnerId',
      jsonEncode(rows),
    );
  }

  Future<String?> loadGroupName({
    required String cookie,
    required int channelId,
  }) async {
    final result = await callKw(
      cookie: cookie,
      model: 'discuss.channel',
      method: 'search_read',
      args: [
        [
          ['id', '=', channelId],
        ],
        ['name'],
      ],
      kwargs: {},
    );

    if (result != null && result.isNotEmpty) {
      return result[0]['name']?.toString();
    }
    return null;
  }
  Future<int> createOrGetThread({
    required String cookie,
    required int partnerId,
    required List<int> memberId,
  }) async {

    if (memberId.length > 2) {

      return createGroup(cookie: cookie, partnerIds: memberId, );
    }
    final partnerData = await callKw(
      cookie: cookie,
      model: 'res.partner',
      method: 'read',
      args: [
        partnerId,
        ['id', 'name'],
      ],
    );

    if (partnerData == null || partnerData.isEmpty) {
      throw Exception('Partner not found for id: $partnerId');
    }

    final name = partnerData[0]['name'];
    if (name == false || name == null || name.toString().trim().isEmpty) {
      await callKw(
        cookie: cookie,
        model: 'res.partner',
        method: 'write',
        args: [
          partnerId,
          {'name': 'No Name'},
        ],
      );
    }

    final result = await callKw(
      cookie: cookie,
      model: 'discuss.channel',
      method: 'channel_get',
      args: [],
      kwargs: {
        'partners_to': memberId,
      },
    );

    return result['id'] as int;
  }
  Future<List<Map<String, dynamic>>> fetchDiscussNotifications({
    required String cookie,
    required int myPartnerId,
    int limit = 50,
  }) async {
    try {
      // Call Odoo JSON-RPC 'search_read' method on 'mail.activity'
      final result = await callKw(
        cookie: cookie,
        model: 'mail.activity',
        method: 'search_read',
        args: [
          [
            ['user_id', '=', myPartnerId],           // Only activities for current user
            ['state', '=', 'planned'],               // Only pending notifications
            ['res_model', '=', 'discuss.channel'],   // Only related to chat threads
          ]
        ],
        kwargs: {
          'fields': [
            'id',            // Activity ID
            'res_id',        // Related record (chat channel)
            'res_model',     // Model (discuss.channel)
            'summary',       // Short notification text
            'note',          // Optional detailed text
            'user_id',       // Assigned user
            'date_deadline', // Activity deadline
            'activity_type_id', // Activity type
            'state',         // Status
            'create_uid',    // Who created the activity
          ],
          'order': 'date_deadline desc',
          'limit': limit,
        },
      );

      // Convert result to List<Map<String, dynamic>>
      final notifications = <Map<String, dynamic>>[];
      for (final raw in result as List) {
        notifications.add(Map<String, dynamic>.from(raw));
      }

      return notifications;
    } catch (e) {
      print("Error fetching Discuss notifications: $e");
      return [];
    }
  }
  Future<dynamic> sendChatMessage({
    required String cookie,
    required int channelId,
    required String text,
  }) async {
    final message = text.trim();
    if (message.isEmpty) {
      throw Exception('Message cannot be empty');
    }

    final result = await callKw(
      cookie: cookie,
      model: 'discuss.channel',
      method: 'message_post',
      args: [channelId],
      kwargs: {
        'body': message,
        'message_type': 'comment',
        'subtype_xmlid': 'mail.mt_comment',
      },
    );

    return result!=null;
  }

  // Future<List<Map<String, dynamic>>> loadMessages({
  //   required String cookie,
  //   required int channelId,
  // }) async {
  //   final result = await callKw(
  //     cookie: cookie,
  //     model: 'mail.message',
  //     method: 'search_read',
  //     args: [
  //       [
  //         ['model', '=', 'discuss.channel'],
  //         ['res_id', '=', channelId],
  //       ]
  //     ],
  //     kwargs: {
  //       'fields': [
  //         'id',
  //         'body',
  //         'author_id',
  //         'date',
  //         'res_id',
  //         'reaction_ids',
  //         'channel_type'
  //       ],
  //       'order': 'date asc',
  //       'limit': 50,
  //     },
  //   );
  //   return List<Map<String, dynamic>>.from(result);
  // }
  Future<bool> addMembersToChannel({
    required String cookie,
    required int channelId,
    required List<int> partnerIds,
  }) async {
    try {
      final commands = partnerIds.map((id) => [4, id]).toList();

      final result = await callKw(
        cookie: cookie,
        model: 'discuss.channel',
        method: 'write',
        args: [
          [channelId],
          {
            'channel_partner_ids': commands,
          },
        ],
        kwargs: {},
      );

      return result == true;
    } catch (e) {
      print('Error adding members to channel: $e');
      return false;
    }
  }
  Future<dynamic> createChannel({
    required String cookie,
    required String channelName,
     String? description,

  }) async {
    try {
      final result = await callKw(
        cookie: cookie,
        model: 'discuss.channel',
        method: 'create',

        args: [
          {
            'name': channelName,
            'channel_type': 'channel',
        //    'description': description,

          }
        ],
        kwargs: {},
      );


      return result;
    } catch (e) {
      print("Error creating channel: $e");
      return null;
    }
  }
//   Future<List<Map<String, dynamic>>> loadMessages({
//     required String cookie,
//     required int channelId,
//   }) async {
//     try {
//       final result = await callKw(
//         cookie: cookie,
//         model: 'mail.message',
//         method: 'search_read',
//         args: [
//           [
//             ['model', '=', 'discuss.channel'],
//             ['res_id', '=', channelId],
//           ]
//         ],
//         kwargs: {
//           'fields': [
//             'id',
//             'body',
//             'author_id',
//             'date',
//             'res_id',
//             'reaction_ids',
// 'partner_ids',
// 'attachment_ids'
//           ],
//           'order': 'date asc',
//           'limit': 50,
//         },
//       );
//
//       if (result == null || result.isEmpty) {
//         print('No messages found for this channel');
//         return [];
//       }
//
//       return List<Map<String, dynamic>>.from(result);
//     } catch (e) {
//
//       print('Error fetching messages: $e');
//       return [];
//     }
//   }

  Future<List<Map<String, dynamic>>> loadMessages({
    required String cookie,
    required int channelId,
  }) async {
    try {
      final result = await callKw(
        cookie: cookie,
        model: 'mail.message',
        method: 'search_read',
        args: [
          [
            ['model', '=', 'discuss.channel'],
            ['res_id', '=', channelId],
          ]
        ],
        kwargs: {
          'fields': [
            'id',
            'body',
            'author_id',
            'date',
            'res_id',
            'reaction_ids',
            'partner_ids',
            'attachment_ids',
          ],
          'order': 'date desc',
          'limit': 50,
        },
      );

      if (result == null || result.isEmpty) {
        print('No messages found for this channel');
        return [];
      }

      final messages = List<Map<String, dynamic>>.from(
        result.map((e) => Map<String, dynamic>.from(e)),
      ).reversed.toList();

      await loadMessageReactions(
        cookie: cookie,
        messages: messages,
      );

      //
      // try {
      //   final Set<int> reactionIds = {};
      //
      //   for (final msg in messages) {
      //     final rawReactionIds = msg['reaction_ids'];
      //
      //     if (rawReactionIds is List) {
      //       for (final id in rawReactionIds) {
      //         if (id is int) {
      //           reactionIds.add(id);
      //         }
      //       }
      //     }
      //   }
      //
      //   print("Reaction IDs found: $reactionIds");
      //
      //   if (reactionIds.isEmpty) {
      //     return messages;
      //   }
      //
      //   final reactionResult = await callKw(
      //     cookie: cookie,
      //     model: 'mail.message.reaction',
      //     method: 'search_read',
      //     args: [
      //       [
      //         ['id', 'in', reactionIds.toList()],
      //       ]
      //     ],
      //     kwargs: {
      //       'fields': [
      //         'id',
      //         'message_id',
      //         'content',
      //         'partner_id',
      //         'guest_id',
      //       ],
      //     },
      //   );
      //
      //   print("Reaction details result: $reactionResult");
      //
      //   final reactions = reactionResult is List
      //       ? List<Map<String, dynamic>>.from(
      //           reactionResult.map((e) => Map<String, dynamic>.from(e)),
      //         )
      //       : <Map<String, dynamic>>[];
      //
      //
      //   final Map<int, List<Map<String, dynamic>>> reactionsByMessage = {};
      //
      //   for (final reaction in reactions) {
      //     final rawMessage = reaction['message_id'];
      //
      //     int? messageId;
      //
      //     if (rawMessage is List && rawMessage.isNotEmpty) {
      //       messageId = rawMessage[0] as int?;
      //     } else if (rawMessage is int) {
      //       messageId = rawMessage;
      //     }
      //
      //     if (messageId == null) continue;
      //
      //     reactionsByMessage.putIfAbsent(messageId, () => []);
      //     reactionsByMessage[messageId]!.add(reaction);
      //   }
      //
      //
      //   for (final msg in messages) {
      //     final messageId = msg['id'];
      //
      //     if (messageId is int) {
      //       msg['reactions_data'] = reactionsByMessage[messageId] ?? [];
      //
      //
      //       msg['reactions'] = (msg['reactions_data'] as List)
      //           .map((r) {
      //             if (r is Map && r['content'] != null) {
      //               return r['content'].toString();
      //             }
      //             return '';
      //           })
      //           .where((e) => e.isNotEmpty)
      //           .toList();
      //     }
      //   }
      // } catch (e, stackTrace) {
      //   print('Reaction loading failed: $e');
      //   print('StackTrace: $stackTrace');
      // }

      print("Final messages with reactions: $messages");

      return messages;
    } catch (e, stackTrace) {
      print('Error fetching messages: $e');
      print('StackTrace: $stackTrace');
      return [];
    }
  }

  Future<void> loadMessageReactions({
    required String cookie,
    required List<Map<String, dynamic>> messages,
  }) async {
    try {
      final Set<int> reactionIds = {};

      for (final msg in messages) {
        final rawReactionIds = msg['reaction_ids'];

        if (rawReactionIds is List) {
          for (final id in rawReactionIds) {
            if (id is int) {
              reactionIds.add(id);
            }
          }
        }
      }

      print("Reaction IDs found: $reactionIds");

      if (reactionIds.isEmpty) {
        return;
      }

      final reactionResult = await callKw(
        cookie: cookie,
        model: 'mail.message.reaction',
        method: 'search_read',
        args: [
          [
            ['id', 'in', reactionIds.toList()],
          ]
        ],
        kwargs: {
          'fields': [
            'id',
            'message_id',
            'content',
            'partner_id',
            'guest_id',
          ],
        },
      );

      print("Reaction details result: $reactionResult");

      final reactions = reactionResult is List
          ? List<Map<String, dynamic>>.from(
        reactionResult.map((e) => Map<String, dynamic>.from(e)),
      )
          : <Map<String, dynamic>>[];

      final Map<int, List<Map<String, dynamic>>> reactionsByMessage = {};

      for (final reaction in reactions) {
        final rawMessage = reaction['message_id'];

        int? messageId;

        if (rawMessage is List && rawMessage.isNotEmpty) {
          messageId = rawMessage[0] as int?;
        } else if (rawMessage is int) {
          messageId = rawMessage;
        }

        if (messageId == null) continue;

        reactionsByMessage.putIfAbsent(messageId, () => []);
        reactionsByMessage[messageId]!.add(reaction);
      }

      for (final msg in messages) {
        final messageId = msg['id'];

        if (messageId is int) {
          msg['reactions_data'] = reactionsByMessage[messageId] ?? [];

          msg['reactions'] = (msg['reactions_data'] as List)
              .map((r) {
            if (r is Map && r['content'] != null) {
              return r['content'].toString();
            }
            return '';
          })
              .where((e) => e.isNotEmpty)
              .toList();
        }
      }
    } catch (e, stackTrace) {
      print('Reaction loading failed: $e');
      print('StackTrace: $stackTrace');
    }
  }
  Future<bool> deleteMessage({
    required String cookie,
    required int messageId,
  }) async {
    try {

      final result = await callKw(
        cookie: cookie,
        model: 'mail.message',
        method: 'unlink',
        args: [
          [messageId],
        ],
        kwargs: {},
      );

      if (result == true) {
        print('Message $messageId successfully deleted from the Odoo server.');
        return true;
      }

      print('Failed to delete message $messageId: Server rejected the transaction.');
      return false;
    } catch (e) {
      print('Error executing unlink on mail.message: $e');
      return false;
    }
  }
  Future<bool> updateMessage({
    required String cookie,
    required int messageId,
    required String updatedText,
  }) async {
    try {

      final result = await callKw(
        cookie: cookie,
        model: 'mail.message',
        method: 'write',
        args: [
          [messageId],
          {
            'body': updatedText,
          }
        ],
        kwargs: {},
      );


      if (result == true) {
        print('Message $messageId updated successfully on Odoo server.');
        return true;
      }

      print('Failed to update message $messageId: Server returned false.');
      return false;
    } catch (e) {
      print('Error executing write on mail.message: $e');
      return false;
    }
  }
  Future<int> createGroup({
    required String cookie,
    required List<int> partnerIds,
    //String name = "New Group",
  }) async {
    final result = await callKw(
      cookie: cookie,
      model: 'discuss.channel',
      method: 'create_group',
      args: [

        partnerIds,
       // name,
      ],
      kwargs: {

      },
    );
    print('Odoo Channel Create Result: $result');
    return result['id'] as int;
  }
  // Future<bool> createGroup({
  //   required String cookie,
  //   required int channelId,
  //   required List<int> partnerIds,
  // }) async {
  //   if (partnerIds.isEmpty) return false;
  //
  //   try {
  //     final result = await callKw(
  //       cookie: cookie,
  //       model: 'discuss.channel',
  //       method: 'add_members',
  //
  //       args: [
  //         [channelId],
  //       ],
  //
  //       kwargs: {
  //         'partner_ids': partnerIds,
  //       },
  //     );
  //
  //     print("Add member result: $result");
  //     return true;
  //   } catch (e) {
  //     print("Odoo RPC error: $e");
  //     return false;
  //   }
  // }

  Future<void> markChannelAsRead({
    required String cookie,
    required int channelId,
    required int lastMessageId,
  }) async {
    final url = Uri.parse('$baseUrl/discuss/channel/set_last_seen_message');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Cookie': cookie,
      },
      body: jsonEncode({
        "jsonrpc": "2.0",
        "method": "call",
        "params": {
          "channel_id": channelId,
          "last_message_id": lastMessageId,
        },
        "id": DateTime.now().millisecondsSinceEpoch,
      }),
    );

    final data = jsonDecode(response.body);
print("read data,$data");
    if (data['error'] != null) {
      throw Exception("Odoo RPC error: ${data['error']}");
    }
  }

  // Future<List<int>> getOtherParticipantPartnerIds({
  //   required String cookie,
  //   required int channelId,
  //   required int myPartnerId,
  // }) async {
  //   final result = await callKw(
  //     cookie: cookie,
  //     model: 'discuss.channel.member',
  //     method: 'search_read',
  //     args: [
  //       [
  //         ['channel_id', '=', channelId],
  //       ]
  //     ],
  //     kwargs: {
  //       'fields': ['partner_id', 'seen_message_id','display_name'],
  //       'limit': 100,
  //     },
  //   );
  //
  //   print("CHANNEL MEMBERS RESULT: $result");
  //
  //   final ids = <int>[];
  //
  //   for (final item in result) {
  //     final partner = item['partner_id'];
  //
  //     if (partner is List && partner.isNotEmpty) {
  //       final id = partner[0];
  //
  //       if (id is int && id != myPartnerId) {
  //         ids.add(id);
  //       }
  //     }
  //   }
  //
  //   print("CORRECT OTHER PARTNER IDS: $ids");
  //   return ids;
  // }
  Future<List<dynamic>> getChannelMembers({
    required String cookie,
    required int channelId,
  }) async {
    final result = await callKw(
      cookie: cookie,
      model: 'discuss.channel.member',
      method: 'search_read',
      args: [
        [
          ['channel_id', '=', channelId],
        ]
      ],
      kwargs: {
        'fields': [
          'id',
          'partner_id',
          'display_name',
        ],
      },
    );

    return result is List ? result : [];
  }

//   Future<List<dynamic>> getAssignedTasks({
//     required String cookie,
//     required int userId,
//   }) async {
//     final result = await callKw(
//       cookie: cookie,
//       model: 'project.task',
//       method: 'search_read',
//       args: [
//         [
//           ['user_ids', 'in', [userId]],
//         ]
//       ],
//       kwargs: {
//         'fields': [
//           'id',
//           'name',
//           'user_ids',
//           'project_id',
//           'date_deadline',
//           'stage_id',
//         ],
//       },
//     );
// print("Assigned task, $result");
//     return result is List ? result : [];
//   }

  Future<List<dynamic>> getAssignedTasks({
    required String cookie,
    required int userId,
  }) async {
    try {
      print("Fetching assigned tasks for userId: $userId");

      final result = await callKw(
        cookie: cookie,
        model: 'project.task',
        method: 'search_read',
        args: [
          [
            ['user_ids', '=', userId],
          ]
        ],
        kwargs: {
          'fields': [
            'id',
            'name',
            'user_ids',
            'project_id',
            'date_deadline',
            'stage_id',
          ],
          'limit': 50,
        },
      );

      print("Assigned task raw result: $result");

      if (result is List) {
        return result;
      } else {
        print("Unexpected result type: ${result.runtimeType}");
        return [];
      }
    } catch (e, stackTrace) {
      print("getAssignedTasks error: $e");
      print("getAssignedTasks stackTrace: $stackTrace");
      return [];
    }
  }
  Future<Map<String, dynamic>?> getTaskById({
    required String cookie,
    required int taskId,
  }) async {
    final result = await callKw(
      cookie: cookie,
      model: 'project.task',
      method: 'read',
      args: [
        [taskId],
      ],
      kwargs: {
        'fields': ['id', 'name', 'user_ids', 'project_id'],
      },
    );

    return result is List && result.isNotEmpty ? result.first : null;
  }


  Future<List<Map<String, dynamic>>> getOtherParticipantPartnerIds({
    required String cookie,
    required int channelId,
     int? myPartnerId,
     List<int>? myPartnerIds,
  }) async {
    final result = await callKw(
      cookie: cookie,
      model: 'discuss.channel.member',
      method: 'search_read',
      args: [
        [
          ['channel_id', '=', channelId],
        ]
      ],
      kwargs: {
        'fields': ['partner_id', 'display_name'],
        'limit': 100,
      },
    );

    print("CHANNEL MEMBERS RESULT: $result");

    final participants = <Map<String, dynamic>>[];

    for (final item in result) {
      final partner = item['partner_id'];

      if (partner is List && partner.isNotEmpty) {
        final partnerId = partner[0];
        final partnerName = partner.length > 1
            ? partner[1].toString()
            : 'Unknown';


        if (partnerId is int && partnerId != myPartnerId) {
          participants.add({
            'partner_id': partnerId,
            'display_name': partnerName,
          });
        }
      }
    }

    print("Other participants with names: $participants");
    return participants;
   }
//   Future<Map<int, bool>> loadMessageReadStatus({
//     required String cookie,
//     required int channelId,
//     required List<int> messageIds,
//     required List<int> participantPartnerIds,
//   }) async {
//     if (messageIds.isEmpty || participantPartnerIds.isEmpty) {
//       return {};
//     }
//
//     final result = await callKw(
//       cookie: cookie,
//       model: 'discuss.channel.member',
//       method: 'search_read',
//       args: [
//         [
//           ['channel_id', '=', channelId],
//           ['partner_id', 'in', participantPartnerIds],
//         ]
//       ],
//       kwargs: {
//         'fields': [
//           'partner_id',
//           'seen_message_id',
//           'last_seen_dt',
//         ],
//         'limit': 100,
//       },
//     );
// print("result for msg seen status,$result");
//     final Map<int, bool> readStatus = {
//       for (final id in messageIds) id: false,
//     };
//
//     int maxSeenMessageId = 0;
//
//     for (final item in result) {
//       final seenMessage = item['seen_message_id'];
//
//       if (seenMessage is List && seenMessage.isNotEmpty) {
//         final seenId = seenMessage[0];
//
//         if (seenId is int && seenId > maxSeenMessageId) {
//           maxSeenMessageId = seenId;
//         }
//       }
//     }
//
//     for (final messageId in messageIds) {
//       if (messageId <= maxSeenMessageId) {
//         readStatus[messageId] = true;
//       }
//     }
//
//     print("Max seen message id: $maxSeenMessageId");
//     print("Read status: $readStatus");
//
//     return readStatus;
//   }

  Future<Map<int, bool>> loadMessageReadStatus({
    required String cookie,
    required int channelId,
    required List<int> messageIds,
    required List<int> participantPartnerIds,

  }) async {
 print("para type is not an issue then");
    if (messageIds.isEmpty || participantPartnerIds.isEmpty) {
      return {for (final id in messageIds) id: false};
    }

    try {
      final result = await callKw(
        cookie: cookie,
        model: 'discuss.channel.member',
        method: 'search_read',
        args: [
          [
      ['channel_id', '=', channelId],
        ['partner_id', 'in', participantPartnerIds],
          ]
        ],
        kwargs: {
          'fields': [
            'partner_id',
            'seen_message_id',
            'last_seen_dt',
          ],
          'limit': 100,
        },
      );

      print("result for msg seen status: $result");


      if (result == null) {
        throw Exception('Failed to fetch read status: Server returned null.');
      }

      if (result is! List) {
        throw Exception('Unexpected response format from Odoo: Expected List, got ${result.runtimeType}');
      }

      final Map<int, bool> readStatus = {
        for (final id in messageIds) id: false,
      };

      int maxSeenMessageId = 0;

      for (final item in result) {
        final seenMessage = item['seen_message_id'];


        if (seenMessage is List && seenMessage.isNotEmpty) {
          final dynamic seenId = seenMessage[0];

          if (seenId is int && seenId > maxSeenMessageId) {
            maxSeenMessageId = seenId;
          }
        } else if (seenMessage is int) {

          if (seenMessage > maxSeenMessageId) {
            maxSeenMessageId = seenMessage;
          }
        }
      }

      for (final messageId in messageIds) {
        if (messageId <= maxSeenMessageId) {
          readStatus[messageId] = true;
        }
      }

      print("Max seen message id: $maxSeenMessageId");
      return readStatus;

    } catch (e, stackTrace) {

      print("Error in loadMessageReadStatus: $e");
      print("Stacktrace: $stackTrace");

      throw Exception('Error loading message read status: ${e.toString()}');
    }
  }
  // Future<void> reactToMessage({
  //   required String cookie,
  //   required int messageId,
  //   required String emoji,
  // }) async {
  //   await callKw(
  //     cookie: cookie,
  //     model: 'mail.message.reaction',
  //     method: 'message_add_reaction',
  //     args: [
  //       [messageId],
  //     ],
  //     kwargs: {
  //       'content': emoji,
  //     },
  //
  //   );
  // }


  Future<dynamic> reactToMessage({
    required String cookie,
    required int messageId,
    required String emoji,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/mail/message/reaction'),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': cookie,
      },
      body: jsonEncode({
        "jsonrpc": "2.0",
        "method": "call",
        "params": {
          "message_id": messageId,
          "content": emoji,
          "action": "add",
        },
      }),
    );

    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    final decoded = jsonDecode(response.body);

    if (decoded['error'] != null) {
      throw Exception('Reaction failed: ${decoded['error']}');
    }

    return decoded['result'];
  }


  // Future<List<dynamic>> loadChannels({
  //   required String cookie,
  //   required int partnerId,
  // }) async {
  //   try {
  //
  //     final result = await callKw(
  //       cookie: cookie,
  //       model: 'discuss.channel',
  //       method: 'search_read',
  //
  //       args: [
  //
  //         [
  //           ['channel_type', '=', 'channel'],
  //           ['channel_member_ids.partner_id', '=', partnerId],
  //         ]
  //       ],
  //       kwargs: {
  //         'fields': [
  //           'id',
  //           'name',
  //           'channel_type',
  //           'write_date',
  //         ],
  //         'order': 'write_date desc',
  //       },
  //     );
  //
  //     return result is List ? result : [];
  //   } catch (e) {
  //
  //     print("Error executing loadChannels: $e");
  //     return [];
  //   }
  // }

  Future<List<dynamic>> loadChannels({
    required String cookie,
    required int partnerId,
  }) async {
    try {
      final channels = await callKw(
        cookie: cookie,
        model: 'discuss.channel',
        method: 'search_read',
        args: [
          [
            ['channel_type', '=', 'channel'],
            ['channel_member_ids.partner_id', '=', partnerId],
          ]
        ],
        kwargs: {
          'fields': [
            'id',
            'name',
            'channel_type',
            'write_date',
          ],
          'order': 'write_date desc',
        },
      );

      if (channels is! List || channels.isEmpty) {
        return [];
      }

      final channelIds = channels
          .whereType<Map>()
          .map((channel) => channel['id'])
          .whereType<int>()
          .toList();

      if (channelIds.isEmpty) {
        return [];
      }

      final previews = await callKw(
        cookie: cookie,
        model: 'discuss.channel',
        method: 'channel_fetch_preview',
        args: [channelIds],
        kwargs: {},
      );

      final members = await callKw(
        cookie: cookie,
        model: 'discuss.channel.member',
        method: 'search_read',
        args: [
          [
            ['channel_id', 'in', channelIds],
            ['partner_id', '=', partnerId],
          ]
        ],
        kwargs: {
          'fields': [
            'channel_id',
            'message_unread_counter',
            'last_interest_dt',
          ],
        },
      );

      final previewByChannelId = <int, Map<String, dynamic>>{};
      if (previews is List) {
        for (final preview in previews) {
          if (preview is Map && preview['id'] is int) {
            previewByChannelId[preview['id'] as int] =
            Map<String, dynamic>.from(preview);
          }
        }
      }

      final memberByChannelId = <int, Map<String, dynamic>>{};
      if (members is List) {
        for (final rawMember in members) {
          if (rawMember is! Map) continue;

          final member = Map<String, dynamic>.from(rawMember);
          final rawChannel = member['channel_id'];

          int? channelId;
          if (rawChannel is List && rawChannel.isNotEmpty) {
            channelId = rawChannel.first is int ? rawChannel.first as int : null;
          } else if (rawChannel is int) {
            channelId = rawChannel;
          }

          if (channelId != null) {
            memberByChannelId[channelId] = member;
          }
        }
      }

      final rows = <Map<String, dynamic>>[];

      for (final rawChannel in channels.whereType<Map>()) {
        final channel = Map<String, dynamic>.from(rawChannel);
        final channelId = channel['id'];

        if (channelId is! int) continue;

        final preview = previewByChannelId[channelId];
        final member = memberByChannelId[channelId];

        final lastMessage = preview?['last_message'];
        final lastMessageMap = lastMessage is Map
            ? Map<String, dynamic>.from(lastMessage)
            : <String, dynamic>{};

        final body = lastMessageMap['body']?.toString() ?? '';
        final author = lastMessageMap['author_id'];

        rows.add({
          ...channel,
          'name': channel['name']?.toString() ?? '',
          'display_name': channel['name']?.toString() ?? '',
          'record_name': channel['name']?.toString() ?? '',
          'last_message': formatOdooDiscussPreview(
            body: body,
            authorId: author,
            currentPartnerId: partnerId,
          ),


          'last_interest_dt': lastMessageMap['date'] ??
              member?['last_interest_dt'] ??
              channel['write_date'] ??
              '',
          'message_unread_counter': member?['message_unread_counter'] ?? 0,
        });
      }

      return rows;
    } catch (e) {
      print("Error executing loadChannels: $e");
      return [];
    }
  }

  Future<Map<int, int>> loadUnreadCountersForMyChannels({
    required String cookie,
    required int partnerId,
  }) async {
    final Map<int, int> counters = {};

    try {
      final result = await callKw(
        cookie: cookie,
        model: 'discuss.channel.member',
        method: 'search_read',
        args: [
          [
            ['partner_id', '=', partnerId],
          ],
        ],
        kwargs: {
          'fields': [
            'channel_id',
            'message_unread_counter',
          ],
        },
      );

      if (result is List) {
        for (final row in result) {
          final channelValue = row['channel_id'];
          final unreadValue = row['message_unread_counter'];

          int? channelId;

          if (channelValue is List && channelValue.isNotEmpty) {
            channelId = channelValue.first as int?;
          } else if (channelValue is int) {
            channelId = channelValue;
          }

          final unreadCount = unreadValue is int
              ? unreadValue
              : int.tryParse(unreadValue.toString()) ?? 0;

          if (channelId != null) {
            counters[channelId] = unreadCount;
          }
        }
      }
    } catch (e) {
      debugPrint('LOAD ALL UNREAD COUNTERS ERROR: $e');
    }

    return counters;
  }
  String cleanOdooString(dynamic value) {
    if (value == null || value == false) return '';

    var text = value.toString().trim();

    if (text.isEmpty || text == 'false' || text == 'null') {
      return '';
    }

    text = text
        .replaceAll(RegExp(r'\s+in\s+false$', caseSensitive: false), '')
        .trim();

    return text;
  }


  Future<List<Map<String, dynamic>>> loadInboxData({
    required String cookie,
    int? limit = 100,
    required int myPartnerId,
  }) async {
    String cleanOdooString(dynamic value) {
      if (value == null || value == false) return '';

      final text = value.toString().trim();

      if (text.isEmpty || text == 'false' || text == 'null') {
        return '';
      }

      return text;
    }

    try {
      final channels = await callKw(
        cookie: cookie,
        model: 'discuss.channel',
        method: 'search_read',
        args: [
          [
            ['is_member', '=', true],
            ['channel_type', 'in', ['chat', 'group']],
          ],
        ],
        kwargs: {
          'fields': ['id', 'name', 'channel_type', 'write_date'],
          'limit': limit,
          'order': 'write_date desc',
        },
      );

      if (channels is! List || channels.isEmpty) {
        print("loadInboxData: User belongs to 0 inbox channels.");
        return [];
      }

      final channelIds = channels
          .whereType<Map>()
          .map((channel) => channel['id'])
          .whereType<int>()
          .toList();

      if (channelIds.isEmpty) {
        return [];
      }

      final previews = await callKw(
        cookie: cookie,
        model: 'discuss.channel',
        method: 'channel_fetch_preview',
        args: [channelIds],
        kwargs: {},
      );

      final members = await callKw(
        cookie: cookie,
        model: 'discuss.channel.member',
        method: 'search_read',
        args: [
          [
            ['channel_id', 'in', channelIds],
          ],
        ],
        kwargs: {
          'fields': [
            'channel_id',
            'partner_id',
            'display_name',
            'seen_message_id',
            'message_unread_counter',
            'last_interest_dt',
            'custom_channel_name',
          ],
          'limit': 1000,
        },
      );

      final previewByChannelId = <int, Map<String, dynamic>>{};
      if (previews is List) {
        for (final preview in previews) {
          if (preview is Map && preview['id'] is int) {
            previewByChannelId[preview['id'] as int] =
            Map<String, dynamic>.from(preview);
          }
        }
      }

      final membersByChannelId = <int, List<Map<String, dynamic>>>{};
      if (members is List) {
        for (final rawMember in members) {
          if (rawMember is! Map) continue;

          final member = Map<String, dynamic>.from(rawMember);
          final channel = member['channel_id'];

          if (channel is List && channel.isNotEmpty && channel.first is int) {
            final channelId = channel.first as int;
            membersByChannelId.putIfAbsent(channelId, () => []);
            membersByChannelId[channelId]!.add(member);
          }
        }
      }

      final inboxRows = <Map<String, dynamic>>[];

      for (final rawChannel in channels.whereType<Map>()) {
        final channel = Map<String, dynamic>.from(rawChannel);
        final channelId = channel['id'];

        if (channelId is! int) continue;

        final preview = previewByChannelId[channelId];
        final channelMembers = membersByChannelId[channelId] ?? [];

        Map<String, dynamic>? myMember;
        final otherParticipants = <Map<String, dynamic>>[];

        for (final member in channelMembers) {
          final partner = member['partner_id'];

          if (partner is! List || partner.isEmpty) continue;

          final partnerId = partner.first;
          final partnerName = partner.length > 1
              ? cleanOdooString(partner[1])
              : '';

          if (partnerId == myPartnerId) {
            myMember = member;
          } else if (partnerId is int) {
            otherParticipants.add({
              'partner_id': partnerId,
              'display_name': partnerName.isNotEmpty ? partnerName : 'Unknown',
            });
          }
        }

        final lastMessage = preview?['last_message'];
        final lastMessageMap = lastMessage is Map
            ? Map<String, dynamic>.from(lastMessage)
            : <String, dynamic>{};

        final rawBody = cleanOdooString(lastMessageMap['body']);
        final cleanBody = rawBody
            .replaceAll(RegExp(r'<[^>]*>'), '')
            .replaceAll('&quot;', '"')
            .replaceAll('&#34;', '"')
            .replaceAll('&amp;', '&')
            .replaceAll('&nbsp;', ' ')
            .trim();

        final author = lastMessageMap['author_id'];

        final seenMessage = myMember?['seen_message_id'];
        int seenMessageId = 0;

        if (seenMessage is List && seenMessage.isNotEmpty) {
          seenMessageId = seenMessage.first is int ? seenMessage.first as int : 0;
        } else if (seenMessage is int) {
          seenMessageId = seenMessage;
        }

        final customName = cleanOdooString(myMember?['custom_channel_name']);
       final channelName = cleanOdooString(channel['name']);

      //  final memberDisplayName = cleanOdooString(myMember?['display_name']);
        final participantTitle = otherParticipants
            .map((participant) => cleanOdooString(participant['display_name']))
            .where((name) => name.isNotEmpty)
            .join(', ');
        final inboxTitle = customName.isNotEmpty
            ? customName
            : channelName.isNotEmpty
            ? channelName
         //: memberDisplayName;
        : participantTitle;

        inboxRows.add({
          'id': lastMessageMap['id'] ?? channelId,
          'author_id': author is List ? author : [0, ''],
          'body': cleanBody,
          'subject': '',
          'date': lastMessageMap['date'] ??
              myMember?['last_interest_dt'] ??
              channel['write_date'] ??
              '',
          'model': 'discuss.channel',
          'record_name': inboxTitle,
          'display_name': inboxTitle,
          'partner_ids': [],
          'res_id': channelId,
          'message_type': lastMessageMap['message_type'] ?? 'comment',
          'channel_type': channel['channel_type'],
          'other_participants': otherParticipants,
          'renamed_group_name': inboxTitle,
          'my_seen_message_id': seenMessageId,
          'unread_count': myMember?['message_unread_counter'] is int
              ? myMember!['message_unread_counter']
              : 0,
        });
      }

      inboxRows.sort((a, b) {
        final dateA = DateTime.tryParse(a['date']?.toString() ?? '') ??
            DateTime(1900);
        final dateB = DateTime.tryParse(b['date']?.toString() ?? '') ??
            DateTime(1900);
        return dateB.compareTo(dateA);
      });

      print("loadInboxData (Inbox Channels Loaded Successfully), $inboxRows");
      return inboxRows;
    } catch (e) {
      print('Error fetching inbox: $e');
      return [];
    }
  }
  // Future<List<Map<String, dynamic>>> loadInboxData({
  //   required String cookie,
  //   int? limit = 100,
  //   required int myPartnerId,
  // }) async {
  //   try {
  //     final channels = await callKw(
  //       cookie: cookie,
  //       model: 'discuss.channel',
  //       method: 'search_read',
  //       args: [
  //         [
  //           ['is_member', '=', true],
  //           ['channel_type', 'in', ['chat', 'group']],
  //         ],
  //       ],
  //       kwargs: {
  //         'fields': ['id', 'name', 'channel_type', 'write_date'],
  //         'limit': limit,
  //         'order': 'write_date desc',
  //       },
  //     );
  //
  //     if (channels is! List || channels.isEmpty) {
  //       print("loadInboxData: User belongs to 0 inbox channels.");
  //       return [];
  //     }
  //
  //     final channelIds = channels
  //         .whereType<Map>()
  //         .map((channel) => channel['id'])
  //         .whereType<int>()
  //         .toList();
  //
  //     if (channelIds.isEmpty) {
  //       return [];
  //     }
  //
  //     final previews = await callKw(
  //       cookie: cookie,
  //       model: 'discuss.channel',
  //       method: 'channel_fetch_preview',
  //       args: [channelIds],
  //       kwargs: {},
  //     );
  //
  //     final members = await callKw(
  //       cookie: cookie,
  //       model: 'discuss.channel.member',
  //       method: 'search_read',
  //       args: [
  //         [
  //           ['channel_id', 'in', channelIds],
  //         ],
  //       ],
  //       kwargs: {
  //         'fields': [
  //           'channel_id',
  //           'partner_id',
  //           'display_name',
  //           'seen_message_id',
  //           'message_unread_counter',
  //           'last_interest_dt',
  //           'custom_channel_name',
  //         ],
  //         'limit': 1000,
  //       },
  //     );
  //
  //     final previewByChannelId = <int, Map<String, dynamic>>{};
  //     if (previews is List) {
  //       for (final preview in previews) {
  //         if (preview is Map && preview['id'] is int) {
  //           previewByChannelId[preview['id'] as int] =
  //           Map<String, dynamic>.from(preview);
  //         }
  //       }
  //     }
  //
  //     final membersByChannelId = <int, List<Map<String, dynamic>>>{};
  //     if (members is List) {
  //       for (final rawMember in members) {
  //         if (rawMember is! Map) continue;
  //
  //         final member = Map<String, dynamic>.from(rawMember);
  //         final channel = member['channel_id'];
  //         if (channel is List && channel.isNotEmpty && channel.first is int) {
  //           final channelId = channel.first as int;
  //           membersByChannelId.putIfAbsent(channelId, () => []);
  //           membersByChannelId[channelId]!.add(member);
  //         }
  //       }
  //     }
  //
  //     final inboxRows = <Map<String, dynamic>>[];
  //
  //     for (final rawChannel in channels.whereType<Map>()) {
  //       final channel = Map<String, dynamic>.from(rawChannel);
  //       final channelId = channel['id'];
  //
  //       if (channelId is! int) continue;
  //
  //       final preview = previewByChannelId[channelId];
  //       final channelMembers = membersByChannelId[channelId] ?? [];
  //       Map<String, dynamic>? myMember;
  //       final otherParticipants = <Map<String, dynamic>>[];
  //
  //       for (final member in channelMembers) {
  //         final partner = member['partner_id'];
  //
  //         if (partner is! List || partner.isEmpty) continue;
  //
  //         final partnerId = partner.first;
  //         final partnerName = partner.length > 1 ? partner[1].toString() : '';
  //
  //         if (partnerId == myPartnerId) {
  //           myMember = member;
  //         } else if (partnerId is int) {
  //           otherParticipants.add({
  //             'partner_id': partnerId,
  //             'display_name': partnerName,
  //           });
  //         }
  //       }
  //
  //       final lastMessage = preview?['last_message'];
  //       final lastMessageMap = lastMessage is Map
  //           ? Map<String, dynamic>.from(lastMessage)
  //           : <String, dynamic>{};
  //
  //       final rawBody = lastMessageMap['body']?.toString() ?? '';
  //       final cleanBody = rawBody
  //           .replaceAll(RegExp(r'<[^>]*>'), '')
  //           .replaceAll('&quot;', '"')
  //           .replaceAll('&#34;', '"')
  //           .replaceAll('&amp;', '&')
  //           .replaceAll('&nbsp;', ' ')
  //           .trim();
  //
  //       final author = lastMessageMap['author_id'];
  //       final seenMessage = myMember?['seen_message_id'];
  //       int seenMessageId = 0;
  //
  //       if (seenMessage is List && seenMessage.isNotEmpty) {
  //         seenMessageId = seenMessage.first is int ? seenMessage.first as int : 0;
  //       } else if (seenMessage is int) {
  //         seenMessageId = seenMessage;
  //       }
  //       final String customName = myMember?['custom_channel_name']?.toString() ?? '';
  //       final String channelName = channel['name']?.toString() ?? '';
  //       final String inboxTitle = customName.isNotEmpty ? customName : channelName;
  //       inboxRows.add({
  //         'id': lastMessageMap['id'] ?? channelId,
  //         'author_id': author is List ? author : [0, ''],
  //         'body': cleanBody,
  //         'subject': '',
  //         'date': lastMessageMap['date'] ??
  //             myMember?['last_interest_dt'] ??
  //             channel['write_date'] ??
  //             '',
  //         'model': 'discuss.channel',
  //         'record_name': myMember?['custom_channel_name'] ?? channel['name'] ?? '',
  //         'display_name': myMember?['custom_channel_name'] ?? channel['name'] ?? '',
  //
  //         'partner_ids': [],
  //         'res_id': channelId,
  //         'message_type': lastMessageMap['message_type'] ?? 'comment',
  //         'channel_type': channel['channel_type'],
  //         'other_participants': otherParticipants,
  //        'renamed_group_name': myMember?['custom_channel_name'],
  //
  //         'my_seen_message_id': seenMessageId,
  //         'unread_count': myMember?['message_unread_counter'] is int
  //             ? myMember!['message_unread_counter']
  //             : 0,
  //       });
  //     }
  //
  //     inboxRows.sort((a, b) {
  //       final dateA = DateTime.tryParse(a['date']?.toString() ?? '') ??
  //           DateTime(1900);
  //       final dateB = DateTime.tryParse(b['date']?.toString() ?? '') ??
  //           DateTime(1900);
  //       return dateB.compareTo(dateA);
  //     });
  //
  //     print("loadInboxData (Inbox Channels Loaded Successfully), $inboxRows");
  //     return inboxRows;
  //   } catch (e) {
  //     print('Error fetching inbox: $e');
  //     return [];
  //   }
  // }


  Future<List<Map<String, dynamic>>> loadInboxCache(int partnerId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('inbox_cache_partner_$partnerId');

    if (raw == null || raw.isEmpty) return [];

    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];

    return decoded
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  Future<void> saveInboxCache(
      int partnerId,
      List<Map<String, dynamic>> rows,
      ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'inbox_cache_partner_$partnerId',
      jsonEncode(rows),
    );
  }

  Future<String?> getUserProfileImage({
    required String cookie,
    required int partnerId,
  }) async {
    final result = await callKw(
      cookie: cookie,
      model: 'res.partner',
      method: 'read',
      args: [
        [partnerId]
      ],
      kwargs: {
        'fields': ['id', 'name', 'image_1920'],
      },
    );

    if (result is List && result.isNotEmpty) {
      final data = result.first as Map<String, dynamic>;

      final image = data['image_1920'];

      if (image != null && image.toString().isNotEmpty) {
        return image;
      }
    }

    return null;
  }

  Future<Map<String, dynamic>?> getUserContext({
    required String cookie,
    required int uid,
  }) async {
    final result = await callKw(
      cookie: cookie,
      model: 'res.users',
      method: 'read',
      args: [
        [uid]
      ],
      kwargs: {
        'fields': ['id', 'name', 'login', 'email', 'partner_id', 'create_date'],
      },
    );

    if (result is List && result.isNotEmpty) {
      return result.first as Map<String, dynamic>;
    }
    return null;
  }

  Future<int> getChatCount({
    required String cookie,
    required int partnerId,
  }) async {
    final result = await callKw(
      cookie: cookie,
      model: 'discuss.channel',
      method: 'search_count',
      args: [
        [
          ['channel_partner_ids', 'in', [partnerId]]
        ]
      ],
      kwargs: {},
    );

    return (result ?? 0) as int;
  }

  Future<int> getMessageCount({
    required String cookie,
    required int partnerId,
  }) async {
    final result = await callKw(
      cookie: cookie,
      model: 'mail.message',
      method: 'search_count',
      args: [
        [
          ['author_id', '=', partnerId]
        ]
      ],
      kwargs: {},
    );
print("result,$result ");
    return (result ?? 0) as int;
  }
  Future<Map<String, dynamic>?> getPartnerProfile({
    required String cookie,
    required int partnerId,
  }) async {
    final result = await callKw(
      cookie: cookie,
      model: 'res.partner',
      method: 'read',
      args: [
        [partnerId]
      ],
      kwargs: {
        'fields': [
          'id',
          'name',
          'email',
          'phone',
          'mobile',
          'street',
          'city',
          'country_id',
          'image_1920',
          'company_name',
          'function',
        ],
      },
    );

    if (result is List && result.isNotEmpty) {
      return result.first;
    }
    return null;
  }
  Future<int?> getCurrentUserPartnerId({
    required String cookie,
    required int uid,
  }) async {
    final user = await getUserContext(cookie: cookie, uid: uid);
    if (user == null) return null;

    final partner = user['partner_id'];
    if (partner is List && partner.isNotEmpty) {
      return partner.first as int;
    }
    return null;
  }

  Future<List<dynamic>> listChannels({
    required String cookie,
    int limit = 50,
  }) async {
    final result = await callKw(
      cookie: cookie,
      model: 'mail.channel',
      method: 'search_read',
      args: [
        []
      ],
      kwargs: {
        'fields': ['id', 'name', 'channel_type', 'create_date'],
        'limit': limit,
        'order': 'id desc',
      },
    );

    return (result as List).cast<dynamic>();
  }

  Future<List<dynamic>> listChannelsForCurrentPartner({
    required String cookie,
    required int partnerId,
    int limit = 50,
  }) async {
    final result = await callKw(
      cookie: cookie,
      model: 'mail.channel',
      method: 'search_read',
      args: [
        [
          ['channel_partner_ids', 'in', [partnerId]]
        ]
      ],
      kwargs: {
        'fields': ['id', 'name', 'channel_type', 'create_date'],
        'limit': limit,
        'order': 'id desc',
      },
    );

    return (result as List).cast<dynamic>();
  }

  Future<List<dynamic>> getChannelMessages({
    required String cookie,
    required int channelId,
    int limit = 30,
    int offset = 0,
  }) async {
    final result = await callKw(
      cookie: cookie,
      model: 'mail.message',
      method: 'search_read',
      args: [
        [
          ['model', '=', 'mail.channel'],
          ['res_id', '=', channelId],
        ]
      ],
      kwargs: {
        'fields': [
          'id',
          'body',
          'author_id',
          'date',
          'message_type',
          'subtype_id',
        ],
        'limit': limit,
        'offset': offset,
        'order': 'date desc',
      },
    );

    return (result as List).cast<dynamic>();
  }

  Future<dynamic> sendMessageToChannel({
    required String cookie,
    required int channelId,
    required String body,
  }) async {
    final result = await callKw(
      cookie: cookie,
      model: 'mail.channel',
      method: 'message_post',
      args: [channelId],
      kwargs: {
        'body': body,
        'message_type': 'comment',
      },
    );

    return result;
  }

  // Future<dynamic> startAudioCall17({
  //   required String cookie,
  //   required int channelId,
  //   required int partnerId,
  // }) async {
  //   try {
  //     final result = await callKw(
  //       cookie: cookie,
  //       model: 'discuss.channel.rtc.session',
  //       method: 'create', // Standard Odoo create
  //       args: [{
  //         'channel_id': channelId,
  //         'partner_id': partnerId,
  //         'is_camera_on': false,
  //         'is_deaf': false,       // Assuming the partner is not deaf
  //         'is_muted': false,      // Assuming the partner is not muted
  //         'is_screen_sharing_on': false, //
  //       }],
  //       kwargs: {},
  //     );
  //
  //     print("call result, $result");
  //     return result;
  //   } catch (e) {
  //     print("Error joining RTC call: $e");
  //     rethrow;
  //   }
  // }

  // Future<dynamic> startAudioCall17({
  //   required String cookie,
  //   required int channelId,
  //   required int partnerId,
  //   required int memberId
  // }) async {
  //   try {
  //
  //     print("Starting audio call with the following parameters:");
  //     print("Cookie: $cookie");
  //     print("Channel ID: $channelId");
  //     print("Partner ID: $partnerId");
  //
  //     final callArgs = {
  //       'channel_id': channelId,
  //       'partner_id': partnerId,
  //       'is_camera_on': true,
  //       'is_deaf': false,
  //       'is_muted': false,
  //       'is_screen_sharing_on': false,
  //       'channel_member_id':memberId
  //     };
  //
  //
  //     print("Call Arguments: $callArgs");
  //
  //     final result = await callKw(
  //       cookie: cookie,
  //       model: 'discuss.channel.rtc.session',
  //       method: 'create',
  //       args: [callArgs],
  //       kwargs: {},
  //     );
  //
  //
  //     print("Call result: $result");
  //
  //     return result;
  //   } catch (e) {
  //
  //     print("Error joining RTC call: $e");
  //
  //
  //     print("Failed with the following parameters:");
  //     print("Cookie: $cookie");
  //     print("Channel ID: $channelId");
  //     print("Partner ID: $partnerId");
  //
  //
  //     rethrow;
  //   }
  // }
  Future<dynamic> startAudioCall17({
    required String cookie,
    required int channelId,
    required int partnerId,
  }) async {

    try {

      final realMemberId = await getMyChannelMemberId(
        cookie: cookie,
        channelId: channelId,
        partnerId: partnerId,
      );

      if (realMemberId == null) {
        throw Exception(
          "No discuss.channel.member found",
        );
      }

      print("REAL MEMBER ID: $realMemberId");

      final callArgs = {
       // 'channel_id': channelId,
       // 'partner_id': partnerId,
       // 'is_camera_on': false,
      //  'is_deaf': false,
    //    'is_muted': false,
       // 'is_screen_sharing_on': false,
        'channel_member_id': realMemberId,
      };

      print("Call Arguments: $callArgs");

      final result = await callKw(
        cookie: cookie,
        model: 'discuss.channel.rtc.session',
        method: 'create',
        args: [callArgs],
        kwargs: {},
      );

      print("Call result: $result");

      return result;

    } catch (e) {

      print("Error joining RTC call: $e");

      rethrow;
    }
  }


  // Future<dynamic> receiveAudioCall17({
  //   required String cookie,
  //   required int channelId,
  //   required int myPartnerId,
  //   required int myMemberId,
  // }) async {
  //   try {
  //     print("Receiving audio call...");
  //     print("Cookie: $cookie");
  //     print("Channel ID: $channelId");
  //     print("My Partner ID: $myPartnerId");
  //     print("My Member ID: $myMemberId");
  //
  //     final callArgs = {
  //       'channel_id': channelId,
  //       'partner_id': myPartnerId,
  //       'is_camera_on': false,
  //       'is_deaf': false,
  //       'is_muted': false,
  //       'is_screen_sharing_on': false,
  //       'channel_member_id': myMemberId,
  //     };
  //
  //     print("Receive Call Arguments: $callArgs");
  //
  //     final result = await callKw(
  //       cookie: cookie,
  //       model: 'discuss.channel.rtc.session',
  //       method: 'create',
  //       args: [callArgs],
  //       kwargs: {},
  //     );
  //
  //     print("Receive call result: $result");
  //
  //     return result;
  //   } catch (e) {
  //     print("Error receiving RTC call: $e");
  //     print("Failed with:");
  //     print("Cookie: $cookie");
  //     print("Channel ID: $channelId");
  //     print("My Partner ID: $myPartnerId");
  //     print("My Member ID: $myMemberId");
  //
  //     rethrow;
  //   }
  // }
  Future<int?> getMyChannelMemberId({
    required String cookie,
    required int channelId,
    required int partnerId,
  }) async {

    final result = await callKw(
      cookie: cookie,
      model: 'discuss.channel.member',
      method: 'search_read',
      args: [
        [
          ['channel_id', '=', channelId],
          ['partner_id', '=', partnerId],
        ]
      ],
      kwargs: {
        'fields': ['id', 'partner_id'],
        'limit': 1,
      },
    );

    print("MY CHANNEL MEMBER RESULT: $result");

    if (result == null || result.isEmpty) {
      return null;
    }

    return result[0]['id'];
  }
  // Future<dynamic> receiveAudioCall17({
  //   required String cookie,
  //   required int channelId,
  //   required int myPartnerId,
  // }) async {
  //   try {
  //     final realMemberId = await getOtherParticipantPartnerIds(
  //       cookie: cookie,
  //       channelId: channelId,
  //       myPartnerId: myPartnerId,
  //     );
  //
  //     if (realMemberId == null) {
  //       throw Exception("No discuss.channel.member found for this channel/user");
  //     }
  //
  //     final callArgs = {
  //       'channel_id': channelId,
  //       'partner_id': myPartnerId,
  //       'is_camera_on': false,
  //       'is_deaf': false,
  //       'is_muted': false,
  //       'is_screen_sharing_on': false,
  //       'channel_member_id': realMemberId,
  //     };
  //
  //     print("Receive Call Arguments: $callArgs");
  //
  //     final result = await callKw(
  //       cookie: cookie,
  //       model: 'discuss.channel.rtc.session',
  //       method: 'create',
  //       args: [callArgs],
  //       kwargs: {},
  //     );
  //
  //     print("Receive call result: $result");
  //
  //     return result;
  //   } catch (e) {
  //     print("Error receiving RTC call: $e");
  //     rethrow;
  //   }
  // }
  Future<int> getCurrentPartnerId({
    required String cookie,
    required int uid,
  }) async {
    final result = await callKw(
      cookie: cookie,
      model: 'res.users',
      method: 'read',
      args: [
        [uid],
        ['partner_id'],
      ],
      kwargs: {},
    );

    print("CURRENT USER RESULT: $result");

    if (result == null || result.isEmpty) {
      throw Exception("No res.users found for uid=$uid");
    }

    final partner = result[0]['partner_id'];

    if (partner == false || partner == null || partner is! List || partner.isEmpty) {
      throw Exception("No partner_id found for uid=$uid");
    }

    return partner[0] as int;
  }

  Future<dynamic> receiveAudioCall17({
    required String cookie,
    required int channelId,
    required int partnerId,
  }) async {
    try {
      print("DEBUG channelId: $channelId");
      print("DEBUG myPartnerId: $partnerId");

      final realMemberId = await getMyChannelMemberId(
        cookie: cookie,
        channelId: channelId,
        partnerId: partnerId,
      );

      if (realMemberId == null) {
        throw Exception(
          "No discuss.channel.member found for channelId=$channelId and partnerId=$partnerId",
        );
      }

      final callArgs = {
        'channel_member_id': realMemberId,
        'is_camera_on': false,
        'is_deaf': false,
        'is_muted': false,
        'is_screen_sharing_on': false,
      };

      print("Receive Call Arguments: $callArgs");

      final result = await callKw(
        cookie: cookie,
        model: 'discuss.channel.rtc.session',
        method: 'create',
        args: [callArgs],
        kwargs: {},
      );

      print("Receive call result: $result");

      return result;
    } catch (e) {
      print("Error receiving RTC call: $e");
      rethrow;
    }
  }

  // Future<dynamic> receiveAudioCall17({
  //   required String cookie,
  //   required int channelId,
  //   required int myPartnerId,
  // }) async {
  //   try {
  //
  //     final realMemberId = await getMyChannelMemberId(
  //       cookie: cookie,
  //       channelId: channelId,
  //       partnerId: myPartnerId,
  //     );
  //
  //     if (realMemberId == null) {
  //       throw Exception(
  //         "No discuss.channel.member found for this channel/user",
  //       );
  //     }
  //
  //     final callArgs = {
  //       'channel_id': channelId,
  //       'partner_id': myPartnerId,
  //       'is_camera_on': false,
  //       'is_deaf': false,
  //       'is_muted': false,
  //       'is_screen_sharing_on': false,
  //       'channel_member_id': realMemberId,
  //     };
  //
  //     print("Receive Call Arguments: $callArgs");
  //
  //     final result = await callKw(
  //       cookie: cookie,
  //       model: 'discuss.channel.rtc.session',
  //       method: 'create',
  //       args: [callArgs],
  //       kwargs: {},
  //     );
  //
  //     print("Receive call result: $result");
  //
  //     return result;
  //
  //   } catch (e) {
  //
  //     print("Error receiving RTC call: $e");
  //
  //     rethrow;
  //   }
  // }

  Future<dynamic> endAudioCall({
    required String cookie,
    required int channelId,
  }) async {
    try {
      final result = await callKw(
        cookie: cookie,
        model: 'discuss.channel.rtc.session',
        method: 'unlink',
        args: [channelId],
        kwargs: {},
      );
      return result;
    } catch (e) {
      print("Error leaving RTC call: $e");
      rethrow;
    }
  }

  Future<List<dynamic>> fieldsGet({
    required String cookie,
    required String model,
  }) async {
    final result = await callKw(
      cookie: cookie,
      model: model,
      method: 'fields_get',
      args: const [],
      kwargs: {
        'attributes': ['string', 'type', 'relation', 'required', 'readonly'],
      },
    );

    if (result is Map<String, dynamic>) {
      return result.entries
          .map((e) => {
        'name': e.key,
        ...((e.value as Map).cast<String, dynamic>()),
      })
          .toList();
    }

    return [];
  }
}
