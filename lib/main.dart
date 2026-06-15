import 'package:discuss/provider/auth_provider.dart';
import 'package:discuss/provider/call_provider.dart';
import 'package:discuss/provider/chat_provider.dart';
import 'package:discuss/provider/create_group_provider.dart';
import 'package:discuss/provider/employee_provider.dart';
import 'package:discuss/provider/inbox_provider.dart';
import 'package:discuss/provider/marked_read_provider.dart';
import 'package:discuss/provider/reaction_provider.dart';
import 'package:discuss/provider/search_provider.dart';

import 'package:discuss/services/odoo_discuss_service.dart';
import 'package:discuss/view/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  String url ="http://192.168.250.26:8069";
 // String url = "https://demo.kendroo.com";
  runApp(
    MultiProvider(
      providers: [

        ChangeNotifierProvider(
          create: (_) => AuthProvider(repo: OdooDiscussService(baseUrl: url)),
        ),

        ChangeNotifierProxyProvider<AuthProvider, EmployeeProvider>(
          create: (context) => EmployeeProvider(
            service: OdooDiscussService(baseUrl: url),
            authProvider: context.read<AuthProvider>(),
          ),
          update: (context, authProvider, previous) => EmployeeProvider(
            service: OdooDiscussService(baseUrl: url),
            authProvider: authProvider,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => SearchProvider(OdooDiscussService(baseUrl: url)),
        ),
        ChangeNotifierProvider(
          create: (_) => ChatProvider(OdooDiscussService(baseUrl: url)),
        ),
        ChangeNotifierProvider(
          create: (_) => InboxProvider(OdooDiscussService(baseUrl: url)),
        ),
        ChangeNotifierProvider(
          create: (_) => ReactionProvider(OdooDiscussService(baseUrl: url)),
        ),

        ChangeNotifierProvider(
          create: (_) =>
              MessageReadStatusProvider(OdooDiscussService(baseUrl: url)),
        ),

        ChangeNotifierProvider(
          create: (_) => GroupMemberProvider(OdooDiscussService(baseUrl: url)),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              CallProvider(service: OdooDiscussService(baseUrl: url)),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
      //  home: const InboxPage()
    );
  }
}
