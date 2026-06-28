

import 'dart:convert';
import 'dart:typed_data';

import 'package:discuss/view/search_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/auth_provider.dart';
import '../provider/employee_provider.dart';


// class ProfilePage extends StatelessWidget {
//   const ProfilePage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final auth = context.watch<AuthProvider>();
//     final employeePIno = context.watch<EmployeeProvider>();
//     final user = auth.userContext;
// final partner = employeePIno.profile;
//      employeePIno.loadProfile();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (!employeePIno.isLoading && employeePIno.profile == null) {
//         context.read<EmployeeProvider>().loadProfile();
//       }
//     });
//     print("employeePIno.profile");
//     print(employeePIno.profile);
//
//     if (user == null) {
//       return const Scaffold(
//         body: Center(child: Text("Not logged in")),
//       );
//     }
//     if (employeePIno.isLoading) {
//       return CircularProgressIndicator();
//     }
//
//     if (employeePIno.profile == null) {
//       return Text("No profile data");
//     }
//     final theme = Theme.of(context);
//
//     final String name = (user['name'] ?? 'User').toString();
//     final String email = (user['email'] ?? user['login'] ?? '—').toString();
//
//     final String phone =
//     (partner?['phone'] ?? partner?['mobile'] ?? '—').toString();
//
//     final String address =
//     (partner?['street'] ?? '—').toString();
//
//     final String city =
//     (partner?['city'] ?? '—').toString();
//
//     final String country = (() {
//       final c = partner?['country_id'];
//       if (c is List && c.length > 1) {
//         return c[1].toString();
//       }
//       return '—';
//     })();
//
//     final String company =
//     (partner?['company_name'] ?? '—').toString();
//
//     final String designation =
//     (partner?['function'] ?? '—').toString();
//
//     final String chats = (partner?['chat_count'] ?? 0).toString();
//     final String messages = (partner?['message_count'] ?? 0).toString();
//     final String joinedYear = (() {
//       final createDate = user['create_date'];
//       if (createDate is String && createDate.length >= 4) {
//         return createDate.substring(0, 4);
//       }
//       return '—';
//     })();
//
//     final String avatarLetter =
//     name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : 'U';
//
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F7FF),
//       appBar: AppBar(
//         title: const Text("Profile"),
//         centerTitle: true,
//         elevation: 0,
//         backgroundColor: Colors.transparent,
//         foregroundColor: Colors.black87,
//       ),
//       body: SafeArea(
//         child: ListView(
//           padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
//           children: [
//             _HeaderCard(
//               name: name,
//               email: email,
//
//               onEdit: () {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text("Edit profile tapped")),
//                 );
//               },
//             ),
//             const SizedBox(height: 14),
//
//             Row(
//               children: [
//                 Expanded(
//                   child: _StatCard(title: "Chats", value: chats),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: _StatCard(title: "Messages", value: messages),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: _StatCard(title: "Joined", value: joinedYear),
//                 ),
//               ],
//             ),
//
//             const SizedBox(height: 14),
//
//             const _SectionTitle(title: "Account"),
//
//             _SettingsCard(
//               children: [
//                 InfoCard(
//                   children: [
//                     _InfoItem(label: "Name", value: name),
//                     _InfoItem(label: "Email", value: email),
//                     _InfoItem(label: "Phone", value: phone ),
//                     _InfoItem(label: "Address", value: address),
//                     _InfoItem(label: "Designation", value: designation),
//                     _InfoItem(label: "City", value: city),
//                     _InfoItem(label: "Company", value: company),
//                     _InfoItem(label: "Joined", value: joinedYear),
//                   ],
//                 ),
//                 _SettingTile(
//                   icon: Icons.lock_outline,
//                   title: "Security",
//                   subtitle: "Password, devices",
//                   onTap: () {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text("Security tapped")),
//                     );
//                   },
//                 ),
//                 _SettingTile(
//                   icon: Icons.notifications_none,
//                   title: "Notifications",
//                   subtitle: "Mentions, message alerts",
//                   onTap: () {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text("Notifications tapped")),
//                     );
//                   },
//                 ),
//               ],
//             ),
//
//             const SizedBox(height: 14),
//
//             const _SectionTitle(title: "Preferences"),
//             _SettingsCard(
//               children: [
//                 _SettingTile(
//                   icon: Icons.palette_outlined,
//                   title: "Appearance",
//                   subtitle: "Theme, font size",
//                   onTap: () {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text("Appearance tapped")),
//                     );
//                   },
//                 ),
//                 _SettingTile(
//                   icon: Icons.language_outlined,
//                   title: "Language",
//                   subtitle: "English",
//                   onTap: () {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text("Language tapped")),
//                     );
//                   },
//                 ),
//               ],
//             ),
//
//             const SizedBox(height: 14),
//
//             const _SectionTitle(title: "Support"),
//             _SettingsCard(
//               children: [
//                 _SettingTile(
//                   icon: Icons.help_outline,
//                   title: "Help & FAQ",
//                   subtitle: "How to use the app",
//                   onTap: () {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text("Help & FAQ tapped")),
//                     );
//                   },
//                 ),
//                 _SettingTile(
//                   icon: Icons.privacy_tip_outlined,
//                   title: "Privacy policy",
//                   subtitle: "Your data & permissions",
//                   onTap: () {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text("Privacy policy tapped")),
//                     );
//                   },
//                 ),
//               ],
//             ),
//
//             const SizedBox(height: 18),
//
//             SizedBox(
//               height: 52,
//               child: FilledButton.icon(
//                 style: FilledButton.styleFrom(
//                   backgroundColor: Colors.redAccent,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(14),
//                   ),
//                 ),
//                 onPressed: auth.loading
//                     ? null
//                     : () async {
//                   await auth.logout(context);
//                 },
//                 icon: const Icon(Icons.logout),
//                 label: Text(
//                   auth.loading ? "Logging out..." : "Logout",
//                   style: const TextStyle(fontWeight: FontWeight.w700),
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 10),
//
//             Center(
//               child: Text(
//                 "Discuss • v1.0.0",
//                 style: theme.textTheme.bodySmall?.copyWith(
//                   color: Colors.black45,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

// class _ProfilePageState extends State<ProfilePage> {
//   bool _didRequestProfile = false;
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//
//     if (!_didRequestProfile) {
//       _didRequestProfile = true;
//       Future.microtask(() {
//         context.read<EmployeeProvider>().loadProfile();
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final auth = context.watch<AuthProvider>();
//     final employeeInfo = context.watch<EmployeeProvider>();
//     final user = auth.userContext;
//     final partner = employeeInfo.profile;
//     final theme = Theme.of(context);
//
//     if (user == null) {
//       return const Scaffold(
//         body: Center(
//           child: Text("Not logged in"),
//         ),
//       );
//     }
//
//     if (employeeInfo.isLoading) {
//       return const Scaffold(
//         body: Center(
//           child: CircularProgressIndicator(),
//         ),
//       );
//     }
//
//     if (employeeInfo.error != null) {
//       return Scaffold(
//         appBar: AppBar(
//           title: const Text("Profile"),
//           centerTitle: true,
//         ),
//         body: Center(
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Text(
//               employeeInfo.error!,
//               textAlign: TextAlign.center,
//             ),
//           ),
//         ),
//       );
//     }
//
//     if (partner == null) {
//       return Scaffold(
//           appBar: AppBar(
//             title: const Text("Profile"),
//             centerTitle: true,
//             elevation: 0,
//             backgroundColor: Colors.transparent,
//             foregroundColor: Colors.black87,
//             actions: [
//               IconButton(
//                 icon: const Icon(Icons.search),
//                 onPressed: () {
//                   Navigator.of(context).push(
//                     MaterialPageRoute(
//                       builder: (_) => SearchPage(
//                         source: SearchSource.chat, channelId: null,
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ],
//           ),
//         body: const Center(
//           child: Text("No profile data"),
//         ),
//       );
//     }
//
//     final String name = (partner['name'] ?? user['name'] ?? 'User').toString();
//     final String email =
//     (partner['email'] ?? user['email'] ?? user['login'] ?? '—').toString();
//     final String phone =
//     (partner['phone'] ?? partner['mobile'] ?? '—').toString();
//     final String address = (partner['street'] ?? '—').toString();
//     final String city = (partner['city'] ?? '—').toString();
//     final String company = (partner['company_name'] ?? '—').toString();
//     final String designation = (partner['function'] ?? '—').toString();
//     final String chats = (partner['chat_count'] ?? 0).toString();
//     final String messages = (partner['message_count']).toString();
//     print("messages,$messages");
// print("chats,$chats");
//     final String country = (() {
//       final c = partner['country_id'];
//       if (c is List && c.length > 1) {
//         return c[1].toString();
//       }
//       return '—';
//     })();
//
//     final String joinedYear = (() {
//       final createDate = user['create_date'];
//       if (createDate is String && createDate.length >= 4) {
//         return createDate.substring(0, 4);
//       }
//       return '—';
//     })();
//
//     final String avatarLetter =
//     name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : 'U';
//
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F7FF),
//       appBar: AppBar(
//         title: const Text("Profile"),
//         centerTitle: true,
//         elevation: 0,
//         backgroundColor: Colors.transparent,
//         foregroundColor: Colors.black87,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.search),
//             onPressed: () {
//
//                     Navigator.of(context).push(
//                       MaterialPageRoute(
//                         builder: (_) => SearchPage(
//                           source: SearchSource.profile, channelId: null,
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ],
//
//
//
//       ),
//       body: SafeArea(
//         child: ListView(
//           padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
//           children: [
//             _HeaderCard(
//               name: name,
//               email: email,
//
//               onEdit: () {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text("Edit profile tapped")),
//                 );
//               },
//             ),
//             const SizedBox(height: 14),
//
//             Row(
//               children: [
//                 Expanded(
//                   child: _StatCard(title: "Chats", value: chats),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: _StatCard(title: "Messages", value: messages),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: _StatCard(title: "Joined", value: joinedYear),
//                 ),
//               ],
//             ),
//
//             const SizedBox(height: 14),
//
//             const _SectionTitle(title: "Personal info"),
//             InfoCard(
//               children: [
//                 _InfoItem(label: "Name", value: name),
//                 _InfoItem(label: "Email", value: email),
//                 _InfoItem(label: "Phone", value: phone),
//                 _InfoItem(label: "Address", value: address),
//                 _InfoItem(label: "City", value: city),
//                 _InfoItem(label: "Country", value: country),
//                 _InfoItem(label: "Company", value: company),
//                 _InfoItem(label: "Designation", value: designation),
//                 _InfoItem(label: "Joined", value: joinedYear),
//               ],
//             ),
//
//             const SizedBox(height: 14),
//
//             // const _SectionTitle(title: "Preferences"),
//             // _SettingsCard(
//             //   children: [
//             //     _SettingTile(
//             //       icon: Icons.palette_outlined,
//             //       title: "Appearance",
//             //       subtitle: "Theme, font size",
//             //       onTap: () {
//             //         ScaffoldMessenger.of(context).showSnackBar(
//             //           const SnackBar(content: Text("Appearance tapped")),
//             //         );
//             //       },
//             //     ),
//             //     _SettingTile(
//             //       icon: Icons.language_outlined,
//             //       title: "Language",
//             //       subtitle: "English",
//             //       onTap: () {
//             //         ScaffoldMessenger.of(context).showSnackBar(
//             //           const SnackBar(content: Text("Language tapped")),
//             //         );
//             //       },
//             //     ),
//             //   ],
//             // ),
//
//             const SizedBox(height: 14),
//
//             const _SectionTitle(title: "Support"),
//             _SettingsCard(
//               children: [
//                 _SettingTile(
//                   icon: Icons.help_outline,
//                   title: "Help & FAQ",
//                   subtitle: "How to use the app",
//                   onTap: () {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text("Help & FAQ tapped")),
//                     );
//                   },
//                 ),
//                 _SettingTile(
//                   icon: Icons.privacy_tip_outlined,
//                   title: "Privacy policy",
//                   subtitle: "Your data & permissions",
//                   onTap: () {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text("Privacy policy tapped")),
//                     );
//                   },
//                 ),
//               ],
//             ),
//
//             const SizedBox(height: 18),
//
//             SizedBox(
//               height: 52,
//               child: FilledButton.icon(
//                 style: FilledButton.styleFrom(
//                   backgroundColor: Colors.redAccent,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(14),
//                   ),
//                 ),
//                 onPressed: auth.loading
//                     ? null
//                     : () async {
//                   await auth.logout(context);
//                 },
//                 icon: const Icon(Icons.logout),
//                 label: Text(
//                   auth.loading ? "Logging out..." : "Logout",
//                   style: const TextStyle(fontWeight: FontWeight.w700),
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 10),
//
//             Center(
//               child: Text(
//                 "Discuss • v1.0.0",
//                 style: theme.textTheme.bodySmall?.copyWith(
//                   color: Colors.black45,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
//
//
// class _InfoItem extends StatelessWidget {
//   final String label;
//   final String value;
//
//   const _InfoItem({
//     required this.label,
//     required this.value,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 92,
//             child: Text(
//               label,
//               style: const TextStyle(
//                 fontSize: 13,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.black54,
//               ),
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Text(
//               value.isEmpty ? '—' : value,
//               style: const TextStyle(
//                 fontSize: 15,
//                 fontWeight: FontWeight.w500,
//                 color: Colors.black87,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _HeaderCard extends StatelessWidget {
//   final String name;
//   final String email;
//   final VoidCallback onEdit;
//
//   const _HeaderCard({
//     required this.name,
//     required this.email,
//
//     required this.onEdit,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(18),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.12),
//             blurRadius: 18,
//             offset: const Offset(0, 10),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           _Avatar(name: name),
//           const SizedBox(width: 14),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   name,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 18,
//                     fontWeight: FontWeight.w800,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   email,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: TextStyle(
//                     color: Colors.white.withOpacity(0.9),
//                     fontSize: 13,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//
//               ],
//             ),
//           ),
//           const SizedBox(width: 10),
//           IconButton(
//             onPressed: onEdit,
//             style: IconButton.styleFrom(
//               backgroundColor: Colors.white.withOpacity(0.18),
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(14),
//               ),
//             ),
//             icon: const Icon(Icons.edit_outlined),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _Avatar extends StatelessWidget {
//   final String name;
//   const _Avatar({required this.name});
//
//   @override
//   Widget build(BuildContext context) {
//     final initials = _initials(name);
//     return Container(
//       width: 60,
//       height: 60,
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.18),
//         borderRadius: BorderRadius.circular(18),
//         border: Border.all(color: Colors.white.withOpacity(0.25)),
//       ),
//       child: Center(
//         child: Text(
//           initials,
//           style: const TextStyle(
//             color: Colors.white,
//             fontSize: 20,
//             fontWeight: FontWeight.w900,
//             letterSpacing: 0.5,
//           ),
//         ),
//       ),
//     );
//   }
//
//   String _initials(String s) {
//     final parts = s.trim().split(RegExp(r'\s+'));
//     if (parts.isEmpty) return "U";
//     if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
//     return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
//   }
// }
//
// class _Chip extends StatelessWidget {
//   final String text;
//   const _Chip({required this.text});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.18),
//         borderRadius: BorderRadius.circular(999),
//         border: Border.all(color: Colors.white.withOpacity(0.20)),
//       ),
//       child: Text(
//         text,
//         maxLines: 1,
//         overflow: TextOverflow.ellipsis,
//         style: TextStyle(
//           color: Colors.white.withOpacity(0.95),
//           fontSize: 12,
//           fontWeight: FontWeight.w700,
//         ),
//       ),
//     );
//   }
// }


//
// class _StatCard extends StatelessWidget {
//   final String title;
//   final String value;
//
//   const _StatCard({required this.title, required this.value});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 76,
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: const Color(0xFFE7EAF4)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 10,
//             offset: const Offset(0, 6),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: const TextStyle(
//               color: Colors.black54,
//               fontSize: 12,
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//           const SizedBox(height: 6),
//           Text(
//             value,
//             style: const TextStyle(
//               color: Colors.black87,
//               fontSize: 18,
//               fontWeight: FontWeight.w900,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
//
// class _SectionTitle extends StatelessWidget {
//   final String title;
//   const _SectionTitle({required this.title});
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(2, 2, 2, 10),
//       child: Text(
//         title,
//         style: const TextStyle(
//           fontSize: 14,
//           fontWeight: FontWeight.w900,
//           color: Colors.black87,
//         ),
//       ),
//     );
//   }
// }
//
// class _SettingsCard extends StatelessWidget {
//   final List<Widget> children;
//   const _SettingsCard({required this.children});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: const Color(0xFFE7EAF4)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 10,
//             offset: const Offset(0, 6),
//           ),
//         ],
//       ),
//       child: Column(children: _withDividers(children)),
//     );
//   }
//
//   List<Widget> _withDividers(List<Widget> items) {
//     final out = <Widget>[];
//     for (var i = 0; i < items.length; i++) {
//       out.add(items[i]);
//       if (i != items.length - 1) {
//         out.add(const Divider(height: 1, thickness: 1, color: Color(0xFFEFF2F8)));
//       }
//     }
//     return out;
//   }
// }
// class InfoCard extends StatelessWidget {
//    final List<Widget> children;
//
//   const InfoCard({required this.children});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: const Color(0xFFE7EAF4)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 10,
//             offset: const Offset(0, 6),
//           ),
//         ],
//       ),
//       child: Column(
//         children: _withDividers(children),
//       ),
//     );
//   }
//
//   List<Widget> _withDividers(List<Widget> items) {
//     final out = <Widget>[];
//     for (var i = 0; i < items.length; i++) {
//       out.add(items[i]);
//       if (i != items.length - 1) {
//         out.add(
//           const Divider(
//             height: 1,
//             thickness: 1,
//             color: Color(0xFFEFF2F8),
//           ),
//         );
//       }
//     }
//     return out;
//   }
// }
// class _SettingTile extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final String subtitle;
//   final VoidCallback onTap;
//
//   const _SettingTile({
//     required this.icon,
//     required this.title,
//     required this.subtitle,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
//       leading: Container(
//         width: 40,
//         height: 40,
//         decoration: BoxDecoration(
//           color: const Color(0xFFEAF1FF),
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Icon(icon, color: const Color(0xFF1D4ED8)),
//       ),
//       title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
//       subtitle: Text(subtitle),
//       trailing: const Icon(Icons.chevron_right),
//       onTap: onTap,
//     );
//   }
// }
class _ProfilePageState extends State<ProfilePage> {
  bool _didRequestProfile = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_didRequestProfile) {
      _didRequestProfile = true;
      Future.microtask(() {
        context.read<EmployeeProvider>().loadProfile();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final employeeInfo = context.watch<EmployeeProvider>();
    final user = auth.userContext;
    final partner = employeeInfo.profile;
    final rawImageBytes = employeeInfo.profile?['image_bytes'];
    final Uint8List? imageBytes =
        rawImageBytes is Uint8List ? rawImageBytes : null;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Not logged in")),
      );
    }

    if (employeeInfo.isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xffF8F6F8),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xff714B67),
          ),
        ),
      );
    }

    if (employeeInfo.error != null) {
      return Scaffold(
        backgroundColor: const Color(0xffF8F6F8),
        appBar: _profileAppBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              employeeInfo.error!,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    if (partner == null) {
      return Scaffold(
        backgroundColor: const Color(0xffF8F6F8),
        appBar: _profileAppBar(),
        body: const Center(child: Text("No profile data")),
      );
    }

    final String name = (partner['name'] ?? user['name'] ?? 'User').toString();
    final String email =
    (partner['email'] ?? user['email'] ?? user['login'] ?? '—').toString();
    final String phone =
    (partner['phone'] ?? partner['mobile'] ?? '—').toString();
    final String address = (partner['street'] ?? '—').toString();
    final String city = (partner['city'] ?? '—').toString();
    final String company = (partner['company_name'] ?? '—').toString();
    final String designation = (partner['function'] ?? '—').toString();

    final String country = (() {
      final c = partner['country_id'];
      if (c is List && c.length > 1) return c[1].toString();
      return '—';
    })();

    final String joinedYear = (() {
      final createDate = user['create_date'];
      if (createDate is String && createDate.length >= 4) {
        return createDate.substring(0, 4);
      }
      return '—';
    })();

    final String avatarLetter =
    name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : 'U';

    return Scaffold(
      backgroundColor: const Color(0xffF8F6F8),
      appBar: _profileAppBar(),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
            color: const Color(0xff714B67),
            child: Column(
              children: [
                // CircleAvatar(
                //   radius: 46,
                //   backgroundColor: const Color(0xffF3EEF5),
                //   child:
                //   Text(
                //     avatarLetter,
                //     style: const TextStyle(
                //       color: Color(0xff714B67),
                //       fontSize: 34,
                //       fontWeight: FontWeight.bold,
                //     ),
                //   ),
                // ),
              CircleAvatar(
              radius: 46,
              backgroundColor: const Color(0xffF3EEF5),
              backgroundImage: imageBytes != null
                  ? MemoryImage(imageBytes)
                  : null,
              child: imageBytes == null
                  ? Text(
                avatarLetter,
                style: const TextStyle(
                  color: Color(0xff714B67),
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              )
                  : null,
            ),
                const SizedBox(height: 14),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xffF3EEF5),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _profileTile(Icons.phone_outlined, "Phone", phone),
                _profileTile(Icons.business_outlined, "Company", company),
                _profileTile(Icons.work_outline, "Designation", designation),
                _profileTile(Icons.location_on_outlined, "Address", address),
                _profileTile(Icons.location_city_outlined, "City", city),
                _profileTile(Icons.flag_outlined, "Country", country),
                _profileTile(Icons.calendar_month_outlined, "Joined", joinedYear),

                const SizedBox(height: 18),

                _logoutTile(
                  loading: auth.loading,
                  onTap: auth.loading
                      ? null
                      : () async {
                    await auth.logout(context);
                  },
                ),

                const SizedBox(height: 18),

                const Center(
                  child: Text(
                    "Discuss • v1.0.0",
                    style: TextStyle(
                      color: Colors.black45,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _profileAppBar() {
    return AppBar(
      backgroundColor: const Color(0xff714B67),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      title: const Text(
        "Profile",
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      actions: [
        // IconButton(
        //   icon: const Icon(Icons.search),
        //   onPressed: () {
        //     Navigator.of(context).push(
        //       MaterialPageRoute(
        //         builder: (_) => SearchPage(
        //           source: SearchSource.profile,
        //           channelId: null,
        //         ),
        //       ),
        //     );
        //   },
        // ),
      ],
    );
  }

  Widget _profileTile(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xffE7DDE6)),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: const Color(0xff714B67),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
        subtitle: Text(
          value.isEmpty ? "—" : value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _logoutTile({
    required bool loading,
    required VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xff714B67),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xffE7DDE6)),

      ),
      child: ListTile(
        onTap: onTap,
        leading: const Icon(
          Icons.logout,
          color: Colors.white,
        ),
        title: Text(
          loading ? "Logging out..." : "Logout",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
