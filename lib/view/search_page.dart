
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../model/search_model.dart';
import '../provider/auth_provider.dart';


import '../provider/create_group_provider.dart';
import '../provider/search_provider.dart';
import 'chat_page.dart';
enum SearchSource {
  chat,
  profile,
}
class SearchPage extends StatefulWidget {
  final SearchSource source;
final int? channelId;
   SearchPage({
    super.key, required this.source, this.channelId,

  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

// class _SearchPageState extends State<SearchPage> {
//   final List<int> selectedPartnerIds = [];
//   final List<Map<String, dynamic>> selectedPartners = [];
//
//   void toggleSelectPartner(dynamic p, int effectivePartnerId) {
//     setState(() {
//       if (selectedPartnerIds.contains(effectivePartnerId)) {
//         selectedPartnerIds.remove(effectivePartnerId);
//         selectedPartners.removeWhere(
//               (item) => item['partnerId'] == effectivePartnerId,
//         );
//       } else {
//         selectedPartnerIds.add(effectivePartnerId);
//         selectedPartners.add({
//
//           'partnerId': effectivePartnerId,
//           'name': p.name ?? "User",
//           'image': p.imageUrl ?? "",
//           'email': p.email ?? "",
//           'phone': p.phone ?? "",
//         });
//       }
//     });
//   }
//
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     final prov = context.watch<SearchProvider>();
//     final auth = context.watch<AuthProvider>();
//     final cookie = auth.sessionCookie;
// final groupProv = context.watch<GroupMemberProvider>();
//     final bool fromChatPage = widget.source == SearchSource.chat;
//     final channelId = widget.channelId;
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(fromChatPage ? "Add People" : "Search Users"),
//         actions: [
//
//         ],
//       ),
//       //
//       // bottomNavigationBar: fromChatPage
//       //     ? SafeArea(
//       //   child: Container(
//       //     padding: const EdgeInsets.all(12),
//       //     child: ElevatedButton(
//       //       onPressed: selectedPartnerIds.isEmpty || groupProv.loading
//       //           ? null
//       //           : () async {
//       //         if (cookie == null || cookie.isEmpty) {
//       //           ScaffoldMessenger.of(context).showSnackBar(
//       //             const SnackBar(content: Text("Session expired")),
//       //           );
//       //           return;
//       //         }
//       //         final channelId = await context
//       //             .read<SearchProvider>()
//       //             .service
//       //             .createOrGetThread(
//       //           cookie: auth.sessionCookie!,
//       //           partnerId:  selectedPartnerIds,
//       //         );
//       //         final success = await context
//       //             .read<GroupMemberProvider>()
//       //             .addMembersToGroup(
//       //           cookie: cookie,
//       //           channelId: channelId ,
//       //           partnerIds: selectedPartnerIds,
//       //         );
//       //
//       //
//       //         if (!mounted) return;
//       //
//       //         if (success) {
//       //         //  Navigator.pop(context, selectedPartners);
//       //           Navigator.push(
//       //             context,
//       //             MaterialPageRoute(
//       //               builder: (_) => ChatPage(
//       //
//       //                 partnerId: selectedPartnerIds,
//       //                 title: prov.partners.firstWhere(
//       //                       (p) => selectedPartnerIds.contains(p.id),
//       //                 ).name                                               ,
//       //                 image: prov.partners.firstWhere(
//       //                       (p) => selectedPartnerIds.contains(p.id),
//       //                 ).imageUrl,
//       //                 email: prov.partners.firstWhere(
//       //                       (p) => selectedPartnerIds.contains(p.id),
//       //
//       //                 ).email,
//       //                 phone: prov.partners.firstWhere(
//       //                       (p) => selectedPartnerIds.contains(p.id),
//       //
//       //                 ).phone,
//       //                 cookie: auth.sessionCookie,
//       //                 channelId: channelId,
//       //               ),
//       //             ),
//       //           );
//       //         } else {
//       //           ScaffoldMessenger.of(context).showSnackBar(
//       //             SnackBar(
//       //               content: Text(
//       //                 context.read<GroupMemberProvider>().error ??
//       //                     "Failed to add people",
//       //               ),
//       //             ),
//       //           );
//       //         }
//       //       },
//       //       child: Text(
//       //         groupProv.loading
//       //             ? "Adding..."
//       //             : selectedPartners.isEmpty
//       //             ? "Select people"
//       //             : "Add ${selectedPartners.length} People",
//       //       ),
//       //     ),
//       //   ),
//       // )
//       //     : null,
//       bottomNavigationBar: fromChatPage && selectedPartnerIds.isNotEmpty
//           ? AddPeopleButton(
//         selectedPartnerIds: selectedPartnerIds,
//         cookie: auth.sessionCookie ?? "",
//         isLoading: groupProv.loading,
//
//         name: selectedPartners.isNotEmpty ? selectedPartners.first['name'] : "Group",
//         image: selectedPartners.isNotEmpty ? selectedPartners.first['image'] : "",
//         email: selectedPartners.isNotEmpty ? selectedPartners.first['email'] : "",
//         phone: selectedPartners.isNotEmpty ? selectedPartners.first['phone'] : "",
//         addMembers: (List<int> partnerIds) async {
//
//           final threadId = await context.read<SearchProvider>().service.createOrGetThread(
//             cookie: auth.sessionCookie!,
//           memberId: partnerIds,
//             partnerId: auth.partnerId!,
//           );
//
//
//           final success = await context.read<GroupMemberProvider>().addMembersToGroup(
//             cookie: auth.sessionCookie!,
//             channelId: threadId,
//             partnerIds: partnerIds,
//           );
//
//           if (success && context.mounted) {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => ChatPage(
//                   // memberId:partnerIds,
//                   partnerId: partnerIds,
//                   title: selectedPartners.first['name'],
//                   image: selectedPartners.first['image'],
//                   email: selectedPartners.first['email'],
//                   phone: selectedPartners.first['phone'],
//                   cookie: auth.sessionCookie,
//                   channelId: threadId,
//                 ),
//               ),
//             );
//           }
//           return success;
//         },
//       )
//           : null,
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(12),
//             child: TextField(
//               decoration: const InputDecoration(
//                 hintText: "Search users...",
//                 border: OutlineInputBorder(),
//                 prefixIcon: Icon(Icons.search),
//               ),
//               onChanged: (txt) {
//                 final cookie = context.read<AuthProvider>().sessionCookie;
//
//                 if (cookie == null || cookie.isEmpty) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                       content: Text("Session expired. Please login again."),
//                     ),
//                   );
//                   return;
//                 }
//
//                 context.read<SearchProvider>().search(txt, cookie);
//               },
//             ),
//           ),
//
//           if (prov.loading) const LinearProgressIndicator(),
//
//           if (prov.error != null)
//             Padding(
//               padding: const EdgeInsets.all(12),
//               child: Text(
//                 prov.error!,
//                 style: const TextStyle(color: Colors.red),
//               ),
//             ),
//
//           Expanded(
//             child:
//             // ListView.builder(
//             //   itemCount: prov.partners.length,
//             //   itemBuilder: (_, i) {
//             //     final p = prov.partners[i];
//             //     //final List<int> effectivePartnerId = p.partnerId ?? p.id;
//             //     final int PartnerId = p.partnerId ?? p.id;
//             //     final List<int> effectivePartnerId = p.partnerId != null
//             //         ? [p.partnerId!]
//             //         : [p.id];
//             //     final String? url = p.imageUrl;
//             //     final String? cookie = auth.sessionCookie;
//             //
//             //     final bool isSelected =
//             //     selectedPartnerIds.contains(effectivePartnerId);
//             //
//             //     return ListTile(
//             //       leading: Row(
//             //         mainAxisSize: MainAxisSize.min,
//             //         children: [
//             //           if (fromChatPage)
//             //             Icon(
//             //               isSelected
//             //                   ? Icons.check_circle
//             //                   : Icons.radio_button_unchecked,
//             //               color: isSelected ? Colors.blue : Colors.grey,
//             //             ),
//             //
//             //           if (fromChatPage)
//             //             AddPeopleButton(
//             //               selectedPartnerIds: selectedPartnerIds,
//             //               cookie: auth.sessionCookie!,
//             //               addMembers: (List<int> partnerIds) async {
//             //
//             //                 final success = await context
//             //                     .read<GroupMemberProvider>()
//             //                     .addMembersToGroup(
//             //                   cookie: cookie!,
//             //                   channelId: channelId,
//             //                   partnerIds: partnerIds,
//             //                 );
//             //                 return success;
//             //               },
//             //
//             //               name: p.name,
//             //               image: p.imageUrl,
//             //               email: p.email,
//             //               phone: p.phone,
//             //             ),
//             //
//             //
//             //           SizedBox(
//             //             width: 44,
//             //             height: 44,
//             //             child: ClipOval(
//             //               child: (url != null && url.isNotEmpty)
//             //                   ? CachedNetworkImage(
//             //                 imageUrl: url,
//             //                 httpHeaders: {
//             //                   if (cookie != null && cookie.isNotEmpty)
//             //                     'Cookie': cookie,
//             //                   'Accept': 'image/*',
//             //                   'User-Agent': 'Flutter',
//             //                 },
//             //                 fit: BoxFit.cover,
//             //                 placeholder: (_, __) => Container(
//             //                   color: Colors.grey.shade300,
//             //                   alignment: Alignment.center,
//             //                   child: const Icon(
//             //                     Icons.person,
//             //                     color: Colors.black54,
//             //                   ),
//             //                 ),
//             //                 errorWidget: (_, __, ___) => Container(
//             //                   color: Colors.grey.shade300,
//             //                   alignment: Alignment.center,
//             //                   child: const Icon(
//             //                     Icons.person,
//             //                     color: Colors.black54,
//             //                   ),
//             //                 ),
//             //               )
//             //                   : Container(
//             //                 color: Colors.grey.shade300,
//             //                 alignment: Alignment.center,
//             //                 child: const Icon(
//             //                   Icons.person,
//             //                   color: Colors.black54,
//             //                 ),
//             //               ),
//             //             ),
//             //           ),
//             //         ],
//             //       ),
//             //
//             //       title: Text(p.name),
//             //       subtitle: Text("ID: $effectivePartnerId"),
//             //
//             //       onTap: () async {
//             //         if (fromChatPage) {
//             //           toggleSelectPartner(p, PartnerId);
//             //           return;
//             //         }
//             //
//             //         final channelId = await context
//             //             .read<SearchProvider>()
//             //             .service
//             //             .createOrGetThread(
//             //           cookie: auth.sessionCookie!,
//             //           partnerId:auth.partnerId!,
//             //           memberId: effectivePartnerId
//             //         );
//             //
//             //         print("channel id from search,$channelId");
//             //
//             //         Navigator.push(
//             //           context,
//             //           MaterialPageRoute(
//             //             builder: (_) => ChatPage(
//             //              // memberId: effectivePartnerId,
//             //               partnerId: effectivePartnerId,
//             //               title: p.name,
//             //               image: p.imageUrl,
//             //               email: p.email,
//             //               phone: p.phone,
//             //               cookie: auth.sessionCookie,
//             //               channelId: channelId,
//             //             ),
//             //           ),
//             //         );
//             //       },
//             //     );
//             //   },
//             // ),
//             ListView.builder(
//               itemCount: prov.partners.length,
//               itemBuilder: (_, i) {
//                 final p = prov.partners[i];
//                 final int partnerId = p.partnerId ?? p.id;
//                 final List<int> effectivePartnerId = [partnerId];
//
//                 final String? url = p.imageUrl;
//                 final String? sessionCookie = auth.sessionCookie;
//
//                 final bool isSelected = selectedPartnerIds.contains(effectivePartnerId);
//
//                 return
//                 //   ListTile(
//                 //
//                 //   leading: Row(
//                 //     mainAxisSize: MainAxisSize.min,
//                 //     children: [
//                 //       if (fromChatPage)
//                 //         Icon(
//                 //           isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
//                 //           color: isSelected ? Colors.blue : Colors.grey,
//                 //         ),
//                 //       if (!fromChatPage)
//                 //         AddPeopleButton(
//                 //           selectedPartnerIds: selectedPartnerIds,
//                 //           cookie: sessionCookie ?? '',
//                 //           addMembers: (List<int> partnerIds) async {
//                 //             if (sessionCookie == null) return false;
//                 //             return await context.read<GroupMemberProvider>().addMembersToGroup(
//                 //               cookie: sessionCookie,
//                 //               channelId: channelId,
//                 //               partnerIds: partnerIds,
//                 //             );
//                 //           },
//                 //           name: p.name,
//                 //           image: p.imageUrl,
//                 //           email: p.email,
//                 //           phone: p.phone,
//                 //         ),
//                 //       SizedBox(width: 8),
//                 //     ],
//                 //   ),
//                 //   title: Text(p.name),
//                 //   subtitle: Text("ID: $partnerId"),
//                 //   onTap: () async {
//                 //     if (fromChatPage) {
//                 //       toggleSelectPartner(p, partnerId);
//                 //       return;
//                 //     }
//                 //
//                 //     final myPartnerId = auth.partnerId;
//                 //     if (sessionCookie == null || myPartnerId == null) return;
//                 //
//                 //     final threadId = await context.read<SearchProvider>().service.createOrGetThread(
//                 //       cookie: sessionCookie,
//                 //       partnerId: myPartnerId,
//                 //       memberId: effectivePartnerId,
//                 //     );
//                 //
//                 //     if (!context.mounted) return;
//                 //
//                 //     Navigator.push(
//                 //       context,
//                 //       MaterialPageRoute(
//                 //         builder: (_) => ChatPage(
//                 //           partnerId: effectivePartnerId,
//                 //           title: p.name,
//                 //           image: p.imageUrl,
//                 //           email: p.email,
//                 //           phone: p.phone,
//                 //           cookie: sessionCookie,
//                 //           channelId: threadId,
//                 //         ),
//                 //       ),
//                 //     );
//                 //   },
//                 // );
//
//                   ListTile(
//                     leading: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//
//                         if (fromChatPage)
//                           Icon(
//                             isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
//                             color: isSelected ? Colors.blue : Colors.grey,
//                           ),
//
//                        //
//                        // if (fromChatPage)
//                        //    AddPeopleButton(
//                        //      selectedPartnerIds: selectedPartnerIds,
//                        //      cookie: sessionCookie ?? '',
//                        //      addMembers: (List<int> partnerIds) async {
//                        //        if (sessionCookie == null) return false;
//                        //        return await context.read<GroupMemberProvider>().addMembersToGroup(
//                        //          cookie: sessionCookie,
//                        //          channelId: channelId,
//                        //          partnerIds: partnerIds,
//                        //        );
//                        //      },
//                        //      name: p.name,
//                        //      image: p.imageUrl,
//                        //      email: p.email,
//                        //      phone: p.phone,
//                        //    ),
//
//
//                         SizedBox(width: 8),
//                       ],
//                     ),
//
//                     title: Text(p.name),
//                     subtitle: Text("ID: $partnerId"),
//                     onTap: () async {
//                       if (fromChatPage) {
//                         toggleSelectPartner(p, partnerId);
//                         return;
//                       }
//
//                       final myPartnerId = auth.partnerId;
//                       if (sessionCookie == null || myPartnerId == null) return;
//
//                       final threadId = await context.read<SearchProvider>().service.createOrGetThread(
//                         cookie: sessionCookie,
//                         partnerId: myPartnerId,
//                         memberId: effectivePartnerId,
//                       );
//
//                       if (!context.mounted) return;
//
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => ChatPage(
//                             partnerId: effectivePartnerId,
//                             title: p.name,
//                             image: p.imageUrl,
//                             email: p.email,
//                             phone: p.phone,
//                             cookie: sessionCookie,
//                             channelId: threadId,
//                           ),
//                         ),
//                       );
//                     },
//                   );
//               },
//             )
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class SelectCircle extends StatelessWidget {
//   final bool isSelected;
//
//   const SelectCircle({super.key, required this.isSelected});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 28,
//       height: 28,
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         border: Border.all(
//           color: isSelected ? Colors.blue : Colors.grey,
//           width: 2,
//         ),
//         color: isSelected ? Colors.blue : Colors.transparent,
//       ),
//       child: isSelected
//           ? const Icon(
//         Icons.check,
//         size: 18,
//         color: Colors.white,
//       )
//           : null,
//     );
//   }
// }
//
// class AddPeopleButton extends StatelessWidget {
//   final List<int> selectedPartnerIds;
//   final String cookie;
//   final String name;
//   final String? image;
//   final String? email;
//   final String? phone;
//   final bool isLoading;
//   final Future<bool> Function(List<int> ids) addMembers;
//
//   const AddPeopleButton({
//     super.key,
//     required this.selectedPartnerIds,
//     required this.cookie,
//     required this.addMembers,
//     required this.name,
//     required this.image,
//     required this.email,
//     required this.phone,
//     this.isLoading = false,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Container(
//         padding: const EdgeInsets.all(12),
//         // Ensuring it fits the bottom bar height with proper padding
//         child: ElevatedButton(
//           style: ElevatedButton.styleFrom(
//             minimumSize: const Size(double.infinity, 48), // Full width button
//           ),
//           onPressed: selectedPartnerIds.isEmpty || isLoading
//               ? null
//               : () async {
//             if (cookie.isEmpty) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text("Session expired")),
//               );
//               return;
//             }
//
//             // Execute the callback passed from the parent
//             final success = await addMembers(selectedPartnerIds);
//
//             if (success && context.mounted) {
//               // Add any success handling, like navigating or updating UI
//               // You can keep navigation logic here or move it to the callback
//             }
//           },
//           child: Text(
//             isLoading
//                 ? "Adding..."
//                 : selectedPartnerIds.isEmpty
//                 ? "Select people"
//                 : "Add ${selectedPartnerIds.length} ${selectedPartnerIds.length == 1 ? 'Person' : 'People'}",
//           ),
//         ),
//       ),
//     );
//   }
// }

class _SearchPageState extends State<SearchPage> {
  final List<int> selectedPartnerIds = [];
  final List<Map<String, dynamic>> selectedPartners = [];

  void toggleSelectPartner(dynamic p, int partnerId) {
    setState(() {
      if (selectedPartnerIds.contains(partnerId)) {
        selectedPartnerIds.remove(partnerId);
        selectedPartners.removeWhere((item) => item['partnerId'] == partnerId);
      } else {
        selectedPartnerIds.add(partnerId);
        selectedPartners.add({
          'partnerId': partnerId,
          'name': p.name ?? "User",
          'image': p.imageUrl ?? "",
          'email': p.email ?? "",
          'phone': p.phone ?? "",
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<SearchProvider>();
    final auth = context.watch<AuthProvider>();
    final groupProv = context.watch<GroupMemberProvider>();

    final bool fromChatPage = widget.source == SearchSource.chat;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xff714B67),
        foregroundColor: Colors.white,
        title: Text(
          fromChatPage ? "Add People" : "Search Users",
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      bottomNavigationBar: fromChatPage && selectedPartnerIds.isNotEmpty
          ? AddPeopleButton(
        selectedPartnerIds: selectedPartnerIds,
        cookie: auth.sessionCookie ?? "",
        isLoading: groupProv.loading,
        name: selectedPartners.isNotEmpty
            ? selectedPartners.first['name']
            : "Group",
        image: selectedPartners.isNotEmpty
            ? selectedPartners.first['image']
            : "",
        email: selectedPartners.isNotEmpty
            ? selectedPartners.first['email']
            : "",
        phone: selectedPartners.isNotEmpty
            ? selectedPartners.first['phone']
            : "",
        addMembers: (List<int> partnerIds) async {
          final threadId = await context
              .read<SearchProvider>()
              .service
              .createOrGetThread(
            cookie: auth.sessionCookie!,
            memberId: partnerIds,
            partnerId: auth.partnerId!,
          );

          final success = await context
              .read<GroupMemberProvider>()
              .addMembersToGroup(
            cookie: auth.sessionCookie!,
            channelId: threadId,
            partnerIds: partnerIds,
          );

          if (success && context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatPage(
                  partnerId: partnerIds,
                  title: selectedPartners.first['name'],
                  image: selectedPartners.first['image'],
                  email: selectedPartners.first['email'],
                  phone: selectedPartners.first['phone'],
                  cookie: auth.sessionCookie,
                  channelId: threadId,
                ),
              ),
            );
          }

          return success;
        },
      )
          : null,
      body: Column(
        children: [
          Container(
            color: const Color(0xff714B67),
            padding: const EdgeInsets.fromLTRB(14, 4, 14, 16),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search users...",
                hintStyle: TextStyle(color: Colors.grey.shade500),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Color(0xff714B67),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (txt) {
                final cookie = context.read<AuthProvider>().sessionCookie;

                if (cookie == null || cookie.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Session expired. Please login again."),
                    ),
                  );
                  return;
                }

                context.read<SearchProvider>().search(txt, cookie);
              },
            ),
          ),

          if (selectedPartnerIds.isNotEmpty && fromChatPage)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              color: const Color(0xffF7F2F7),
              child: Text(
                "${selectedPartnerIds.length} selected",
                style: const TextStyle(
                  color: Color(0xff714B67),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

          if (prov.loading)
            const LinearProgressIndicator(
              color: Color(0xff714B67),
              minHeight: 2,
            ),

          if (prov.error != null)
            Padding(
              padding: const EdgeInsets.all(14),
              child: Text(
                prov.error!,
                style: const TextStyle(color: Colors.red),
              ),
            ),

          Expanded(
            child: prov.partners.isEmpty
                ? _emptySearchState(fromChatPage)
                : ListView.separated(
              itemCount: prov.partners.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                thickness: 0.7,
                indent: 76,
                color: Colors.grey.shade200,
              ),
              itemBuilder: (_, i) {
                final p = prov.partners[i];

                final int partnerId = p.partnerId ?? p.id;
                final List<int> effectivePartnerId = [partnerId];
                final String? sessionCookie = auth.sessionCookie;

                final bool isSelected =
                selectedPartnerIds.contains(partnerId);

                return _searchUserTile(
                  name: p.name ?? "User",
                  email: p.email,
                  phone: p.phone,
                  imageUrl: p.imageUrl,
                  sessionCookie: sessionCookie,
                  isSelected: isSelected,
                  showSelection: fromChatPage,
                  partnerId: partnerId,
                  onTap: () async {
                    if (fromChatPage) {
                      toggleSelectPartner(p, partnerId);
                      return;
                    }

                    final myPartnerId = auth.partnerId;

                    if (sessionCookie == null || myPartnerId == null) {
                      return;
                    }

                    final threadId = await context
                        .read<SearchProvider>()
                        .service
                        .createOrGetThread(
                      cookie: sessionCookie,
                      partnerId: myPartnerId,
                      memberId: effectivePartnerId,
                    );

                    if (!context.mounted) return;

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatPage(
                          partnerId: effectivePartnerId,
                          title: p.name,
                          image: p.imageUrl,
                          email: p.email,
                          phone: p.phone,
                          cookie: sessionCookie,
                          channelId: threadId,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchUserTile({
    required String name,
    required String? email,
    required String? phone,
    required String? imageUrl,
    required String? sessionCookie,
    required bool isSelected,
    required bool showSelection,
    required int partnerId,
    required VoidCallback onTap,
  }) {
    final String firstLetter =
    name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : "?";

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            if (showSelection) ...[
              SelectCircle(isSelected: isSelected),
              const SizedBox(width: 12),
            ],
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xffF3EEF5),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  firstLetter,
                  style: const TextStyle(
                    color: Color(0xff714B67),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15.8,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff1F2937),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    email != null && email.isNotEmpty
                        ? email
                        : phone != null && phone.isNotEmpty
                        ? phone
                        : "Partner ID: $partnerId",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (!showSelection)
              Icon(
                Icons.chevron_right,
                color: Colors.grey.shade400,
              ),
          ],
        ),
      ),
    );
  }

  Widget _emptySearchState(bool fromChatPage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.person_search_outlined,
            size: 72,
            color: Color(0xff714B67),
          ),
          const SizedBox(height: 14),
          Text(
            fromChatPage ? "Search people to add" : "Search users",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Type a name, email, or phone number.",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

class SelectCircle extends StatelessWidget {
  final bool isSelected;

  const SelectCircle({super.key, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? const Color(0xff714B67) : Colors.grey.shade400,
          width: 2,
        ),
        color: isSelected ? const Color(0xff714B67) : Colors.transparent,
      ),
      child: isSelected
          ? const Icon(
        Icons.check,
        size: 17,
        color: Colors.white,
      )
          : null,
    );
  }
}

class AddPeopleButton extends StatelessWidget {
  final List<int> selectedPartnerIds;
  final String cookie;
  final String name;
  final String? image;
  final String? email;
  final String? phone;
  final bool isLoading;
  final Future<bool> Function(List<int> ids) addMembers;

  const AddPeopleButton({
    super.key,
    required this.selectedPartnerIds,
    required this.cookie,
    required this.addMembers,
    required this.name,
    required this.image,
    required this.email,
    required this.phone,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 14,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff714B67),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: selectedPartnerIds.isEmpty || isLoading
              ? null
              : () async {
            if (cookie.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Session expired")),
              );
              return;
            }

            await addMembers(selectedPartnerIds);
          },
          child: Text(
            isLoading
                ? "Adding..."
                : "Add ${selectedPartnerIds.length} ${selectedPartnerIds.length == 1 ? 'Person' : 'People'}",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}