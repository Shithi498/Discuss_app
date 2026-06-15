import 'package:agora_token_service/agora_token_service.dart';
import 'package:discuss/provider/auth_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as context; // Note: You might want to rename this alias if it clashes with BuildContext
import 'package:provider/provider.dart';

// Future<String> generateAgoraToken(BuildContext context,) async {
//
//   final appId = "339050bec1fe49b8bc5e17ca9d739fba";
//
//   final appCert ="81e80700170d4e21b11db2100c5ad50e";
//
//
//   String channelName="test_discuss";
//   // Get current user UID from AuthProvider
//   final auth = Provider.of<AuthProvider>(context, listen: false);
//   final uid = (auth.partnerId ?? 0).toString(); // Keeping as int
//
//   final currentTs = DateTime.now().millisecondsSinceEpoch ~/ 1000;
//   final expireSeconds = 3600; // 1 hour token
//   final privilegeExpireTs = currentTs + expireSeconds;
//
//   // FIX: Use 'buildWithUid' for integer UIDs and 'RtcRole.publisher' for the enum
//   final token = RtcTokenBuilder.build(
//     appId: appId,
//     appCertificate: appCert,
//     channelName: channelName,
//     uid: uid,
//     role: RtcRole.publisher,
//     expireTimestamp: privilegeExpireTs,
//   );
//   print("generated token,$token");
//   return token;
// }

Future<String> generateAgoraToken(int uid) async {
  final appId = "339050bec1fe49b8bc5e17ca9d739fba";
  final appCert = "81e80700170d4e21b11db2100c5ad50e";
  String channelName = "test_discuss";

  final currentTs = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  final expireSeconds = 3600; // 1 hour
  final privilegeExpireTs = currentTs + expireSeconds;

  final token = RtcTokenBuilder.build(
    appId: appId,
    appCertificate: appCert,
    channelName: channelName,
    uid: uid.toString(),
     role: RtcRole.publisher,// enum, not string
    expireTimestamp: privilegeExpireTs,
  );

  print("generated token inside function: $token");
  return token;
}