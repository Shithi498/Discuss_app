import 'dart:async';

import 'package:discuss/view/search_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/thread_model.dart';
import '../provider/auth_provider.dart';

import '../provider/chat_provider.dart';

import '../provider/inbox_provider.dart';
import '../services/odoo_discuss_service.dart';
import 'agora_call_page.dart';

import 'chat_page.dart';
import 'incoming_call_listener.dart';


// class ChannelsScreen extends StatefulWidget {
//   const ChannelsScreen({super.key});
//
//   @override
//   State<ChannelsScreen> createState() => _ChannelsScreenState();
// }
//
// class _ChannelsScreenState extends State<ChannelsScreen> {
//   late final authProvider = context.read<AuthProvider>();
//
//   @override
//   void initState() {
//     super.initState();
//
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       await _loadChannels();
//     });
//   }
//
//   Future<void> _loadChannels() async {
//     final cookie = authProvider.sessionCookie;
//
//     if (cookie == null || cookie.isEmpty) return;
//
//     await context.read<InboxProvider>().loadChannels(cookie);
//   }
//
//   int _asInt(dynamic value) {
//     if (value == null) return 0;
//     if (value is int) return value;
//     return int.tryParse(value.toString()) ?? 0;
//   }
//
//   String _asString(dynamic value) {
//     if (value == null || value == false) return '';
//     return value.toString();
//   }
//
//   String _formatDiscussTime(dynamic rawDate) {
//     final raw = _asString(rawDate);
//
//     if (raw.isEmpty) return '';
//
//     final date = DateTime.tryParse(raw);
//
//     if (date == null) {
//       return raw.length > 16 ? raw.substring(11, 16) : raw;
//     }
//
//     final now = DateTime.now();
//
//     final isToday =
//         date.year == now.year && date.month == now.month && date.day == now.day;
//
//     final yesterday = now.subtract(const Duration(days: 1));
//
//     final isYesterday =
//         date.year == yesterday.year &&
//             date.month == yesterday.month &&
//             date.day == yesterday.day;
//
//     if (isToday) {
//       final hour = date.hour.toString().padLeft(2, '0');
//       final minute = date.minute.toString().padLeft(2, '0');
//       return '$hour:$minute';
//     }
//
//     if (isYesterday) return 'Yesterday';
//
//     return '${date.day}/${date.month}/${date.year}';
//   }
//
//   Future<String> _loadLastChannelMessage({
//     required String cookie,
//     required int channelId,
//   }) async {
//     try {
//       final result = await OdooDiscussService(
//         baseUrl: "https://demo.kendroo.com",
//       ).loadChannels(cookie: cookie);
//
//       if (result.isEmpty) return 'No message preview';
//
//       final msg = result.first;
//       final body = msg['body']?.toString() ?? '';
//
//       return _cleanDiscussPreview(body);
//     } catch (_) {
//       return 'No message preview';
//     }
//   }
//
//   String _cleanDiscussPreview(String body) {
//     final clean = body
//         .replaceAll(RegExp(r'<[^>]*>'), '')
//         .replaceAll('&quot;', '"')
//         .replaceAll('&#34;', '"')
//         .replaceAll('&amp;', '&')
//         .replaceAll('&nbsp;', ' ')
//         .trim();
//
//     if (clean.contains('AGORA_CALL::')) {
//       if (clean.contains('"call_type":"audio"')) return 'Audio call';
//       if (clean.contains('"call_type":"video"')) return 'Video call';
//       return 'Call';
//     }
//
//     return clean.isEmpty ? 'No message preview' : clean;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final cookie = authProvider.sessionCookie;
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: const Color(0xff714B67),
//         foregroundColor: Colors.white,
//         title: const Text(
//           'Channels',
//           style: TextStyle(fontWeight: FontWeight.w600),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.add_comment_outlined),
//             onPressed: () {
//               // Text controller to capture what the user types
//               final TextEditingController nameController = TextEditingController();
//
//               showDialog(
//                 context: context,
//                 builder: (BuildContext dialogContext) {
//                   return AlertDialog(
//                     title: const Text('Create New Channel'),
//                     content: TextField(
//                       controller: nameController,
//                       autofocus: true,
//                       decoration: const InputDecoration(
//                         hintText: "Enter channel name...",
//                         labelText: "Channel Name",
//                         border: OutlineInputBorder(),
//                       ),
//                     ),
//                     actions: [
//                       TextButton(
//                         onPressed: () => Navigator.pop(dialogContext), // Close without doing anything
//                         child: const Text('Cancel'),
//                       ),
//                       ElevatedButton(
//                         onPressed: () async {
//                           final String channelName = nameController.text.trim();
//
//                           if (channelName.isEmpty) {
//                             // Don't submit an empty name
//                             return;
//                           }
//
//                           // Close the dialog immediately
//                           Navigator.pop(dialogContext);
//
//                           // Call the provider method
//                           final provider = Provider.of<InboxProvider>(context, listen: false);
//
//                           bool success = await provider.createChannel(
//                             cookie: authProvider.sessionCookie!, // Replace with your actual stored session/cookie
//                             name: channelName,
//                             description: "Created from Flutter Mobile App", // Default description
//                             partnerIds: [], // Leave empty, or inject member IDs if needed
//                           );
//
//                           // Quick UI feedback toast/snackbar
//                           if (context.mounted) {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(
//                                 content: Text(success
//                                     ? 'Channel "$channelName" created!'
//                                     : (provider.errorMessage ?? 'Failed to create channel.')
//                                 ),
//                               ),
//                             );
//                           }
//                         },
//                         child: const Text('Create'),
//                       ),
//                     ],
//                   );
//                 },
//               );
//             },
//           ),
//         ],
//       ),
//       body: Consumer<InboxProvider>(
//         builder: (context, provider, child) {
//           if (provider.channelErrorMessage.isNotEmpty) {
//             return Center(child: Text(provider.channelErrorMessage));
//           }
//
//           if (provider.channels.isEmpty) {
//             return _emptyChannelState();
//           }
//
//           final channels = [...provider.channels];
//
//           channels.sort((a, b) {
//             final dateA =
//                 DateTime.tryParse(_asString(a?['last_interest_dt'])) ??
//                     DateTime(1900);
//             final dateB =
//                 DateTime.tryParse(_asString(b['last_interest_dt'])) ??
//                     DateTime(1900);
//
//             return dateB.compareTo(dateA);
//           });
//
//           return RefreshIndicator(
//             onRefresh: _loadChannels,
//             child: ListView.separated(
//               padding: EdgeInsets.zero,
//               itemCount: channels.length,
//               separatorBuilder: (_, __) => Divider(
//                 height: 1,
//                 thickness: 0.7,
//                 indent: 76,
//                 color: Colors.grey.shade200,
//               ),
//               itemBuilder: (context, index) {
//                 final channel = channels[index];
//
//                 final int channelId = _asInt(channel['id']);
//                 final String title = _asString(channel['name']).isEmpty
//                     ? 'Unnamed Channel'
//                     : _asString(channel['name']);
//
//                 final int unreadCount =
//                 _asInt(channel['message_unread_counter']);
//
//                 final String time =
//                 _formatDiscussTime(channel['last_interest_dt']);
//
//                 return FutureBuilder<String>(
//                   future: cookie == null || cookie.isEmpty
//                       ? Future.value('No message preview')
//                       : _loadLastChannelMessage(
//                     cookie: cookie,
//                     channelId: channelId,
//                   ),
//                   builder: (context, snapshot) {
//                     final subtitle = snapshot.data ?? 'Loading...';
//
//                     return _channelTile(
//                       title: title,
//                       subtitle: subtitle,
//                       time: time,
//                       unreadCount: unreadCount,
//                       onTap: () {
//                        Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (_) => ChatPage(
//                               channelId: channelId,
//                               title: title,
//                               cookie: cookie,
//                               partnerId: [],
//                               source: ChatSource.channel,
//                             ),
//                           ),
//                         ).then((_) => _loadChannels()
//
//                         );
//                       },
//                     );
//                   },
//                 );
//               },
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _channelTile({
//     required String title,
//     required String subtitle,
//     required String time,
//     required int unreadCount,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//         child: Row(
//           children: [
//             Container(
//               width: 48,
//               height: 48,
//               decoration: BoxDecoration(
//                 color: const Color(0xffF3EEF5),
//                 borderRadius: BorderRadius.circular(14),
//               ),
//               child: const Center(
//                 child: Icon(
//                   Icons.tag,
//                   color: Color(0xff714B67),
//                   size: 27,
//                 ),
//               ),
//             ),
//             const SizedBox(width: 14),
//
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Text(
//                           title,
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                           style: const TextStyle(
//                             fontSize: 15.8,
//                             fontWeight: FontWeight.w600,
//                             color: Color(0xff1F2937),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       Text(
//                         time,
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Colors.grey.shade500,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 5),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Text(
//                           subtitle,
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                           style: TextStyle(
//                             fontSize: 13.5,
//                             color: Colors.grey.shade600,
//                           ),
//                         ),
//                       ),
//                       if (unreadCount > 0) ...[
//                         const SizedBox(width: 8),
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 8,
//                             vertical: 4,
//                           ),
//                           decoration: BoxDecoration(
//                             color: const Color(0xff714B67),
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                           child: Text(
//                             unreadCount.toString(),
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 11,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _emptyChannelState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(Icons.tag, size: 72, color: Color(0xff714B67)),
//           const SizedBox(height: 14),
//           const Text(
//             'No channels found',
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//           ),
//           const SizedBox(height: 6),
//           Text(
//             'Create or join a channel to start discussion.',
//             style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
//           ),
//         ],
//       ),
//     );
//   }
// }

class ChannelsScreen extends StatefulWidget {
  const ChannelsScreen({super.key});

  @override
  State<ChannelsScreen> createState() => _ChannelsScreenState();
}

class _ChannelsScreenState extends State<ChannelsScreen> with WidgetsBindingObserver{
  late final authProvider = context.read<AuthProvider>();
  Timer? _channelRefreshTimer;
  bool _refreshInProgress = false;

  static const Duration _hiddenReloadInterval = Duration(seconds: 10);
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadChannels();
      _startHiddenAutoReload();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadChannels(silent: true);
    }
  }

  void _startHiddenAutoReload() {
    _channelRefreshTimer?.cancel();

    _channelRefreshTimer = Timer.periodic(_hiddenReloadInterval, (_) {
      if (!mounted) return;

      final route = ModalRoute.of(context);
      if (route != null && !route.isCurrent) return;

      _loadChannels(silent: true);
    });
  }


  // Future<void> _loadChannels() async {
  //   final cookie = authProvider.sessionCookie;
  //
  //   if (cookie == null || cookie.isEmpty) return;
  //
  //   await context.read<InboxProvider>().loadChannels(cookie,authProvider.partnerId!);
  // }

  Future<void> _loadChannels({bool silent = false}) async {
    if (_refreshInProgress) return;

    final cookie = authProvider.sessionCookie;
    final partnerId = authProvider.partnerId;

    if (cookie == null || cookie.isEmpty || partnerId == null) return;

    _refreshInProgress = true;

    try {
      await context.read<InboxProvider>().loadChannels(
        cookie,
        partnerId,
        silent: silent,
      );
    } finally {
      _refreshInProgress = false;
    }
  }


  int _asInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  String _asString(dynamic value) {
    if (value == null || value == false) return '';
    return value.toString();
  }

  String _formatDiscussTime(dynamic rawDate) {
    final raw = _asString(rawDate);

    if (raw.isEmpty) return '';

    final date = DateTime.tryParse(raw);

    if (date == null) {
      return raw.length > 16 ? raw.substring(11, 16) : raw;
    }

    final now = DateTime.now();

    final isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;

    final yesterday = now.subtract(const Duration(days: 1));

    final isYesterday =
        date.year == yesterday.year &&
            date.month == yesterday.month &&
            date.day == yesterday.day;

    if (isToday) {
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }

    if (isYesterday) return 'Yesterday';

    return '${date.day}/${date.month}/${date.year}';
  }

  Future<String> _loadLastChannelMessage({
    required String cookie,
    required int channelId,
  }) async {
    try {
      final messages = await OdooDiscussService(
         baseUrl: "https://demo.kendroo.com",
       // baseUrl: "http://localhost:8017",
      ).loadMessages(cookie: cookie, channelId: channelId);

      if (messages.isEmpty) return 'No message preview';

      final msg = messages.last;
      final body = msg['body']?.toString() ?? '';

      return _cleanDiscussPreview(body);
    } catch (_) {
      return 'No message preview';
    }
  }

  String _cleanDiscussPreview(String body) {
    final clean = body
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&quot;', '"')
        .replaceAll('&#34;', '"')
        .replaceAll('&amp;', '&')
        .replaceAll('&nbsp;', ' ')
        .trim();

    if (clean.contains('AGORA_CALL::')) {
      if (clean.contains('"call_type":"audio"')) return 'Audio call';
      if (clean.contains('"call_type":"video"')) return 'Video call';
      return 'Call';
    }

    return clean.isEmpty ? 'No message preview' : clean;
  }

  String _channelImageUrl(int channelId) {
    return 'https://demo.kendroo.com/web/image?model=discuss.channel&id=$channelId&field=image_128';
    // return 'http://localhost:8017/web/image?model=discuss.channel&id=$channelId&field=image_128';
  }

  @override
  Widget build(BuildContext context) {
    final cookie = authProvider.sessionCookie;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xff714B67),
        foregroundColor: Colors.white,
        title: const Text(
          'Channels',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment_outlined),
            onPressed: () {
              final TextEditingController nameController = TextEditingController();

              showDialog(
                context: context,
                builder: (BuildContext dialogContext) {
                  return AlertDialog(
                    title: const Text('Create New Channel'),
                    content: TextField(
                      controller: nameController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: "Enter channel name...",
                        labelText: "Channel Name",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final String channelName = nameController.text.trim();

                          if (channelName.isEmpty) {
                            return;
                          }


                          Navigator.pop(dialogContext);


                          final provider = Provider.of<InboxProvider>(context, listen: false);

                          bool success = await provider.createChannel(
                            cookie: authProvider.sessionCookie!,
                            name: channelName,
                            description: "Created from Flutter Mobile App",
                            partnerIds: [],
                          );

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(success
                                    ? 'Channel "$channelName" created!'
                                    : (provider.errorMessage ?? 'Failed to create channel.')
                                ),
                              ),
                            );
                          }
                        },
                        child: const Text('Create'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<InboxProvider>(
        builder: (context, provider, child) {
          if (provider.channelErrorMessage.isNotEmpty) {
            return Center(child: Text(provider.channelErrorMessage));
          }

          if (provider.channels.isEmpty) {
            return _emptyChannelState();
          }

          final channels = [...provider.channels];

          channels.sort((a, b) {
            final dateA =
                DateTime.tryParse(_asString(a?['last_interest_dt'])) ??
                    DateTime(1900);
            final dateB =
                DateTime.tryParse(_asString(b['last_interest_dt'])) ??
                    DateTime(1900);

            return dateB.compareTo(dateA);
          });

          return RefreshIndicator(
            onRefresh: _loadChannels,
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: channels.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                thickness: 0.7,
                indent: 76,
                color: Colors.grey.shade200,
              ),
              itemBuilder: (context, index) {
                final channel = channels[index];

                final int channelId = _asInt(channel['id']);
                // final String title = _asString(channel['name']).isEmpty
                //     ? 'Unnamed Channel'
                //     : _asString(channel['name']);
                final String rawTitle = [
                  channel['name'],
                  channel['display_name'],
                  channel['record_name'],
                  channel['custom_channel_name'],
                ]
                    .map(_asString)
                    .firstWhere((value) => value.isNotEmpty, orElse: () => '');
                final String title = rawTitle.isEmpty ? 'Unnamed Channel' : rawTitle;
                final int unreadCount =
                _asInt(channel['message_unread_counter']);

                final String time =
                _formatDiscussTime(channel['last_interest_dt']);
                final String imageUrl = _channelImageUrl(channelId);

                // return FutureBuilder<String>(
                //   future: cookie == null || cookie.isEmpty
                //       ? Future.value('No message preview')
                //       : _loadLastChannelMessage(
                //     cookie: cookie,
                //     channelId: channelId,
                //   ),
                //   builder: (context, snapshot) {
                //     final subtitle = snapshot.data ?? 'Loading...';
                //
                //     return _channelTile(
                //       title: title,
                //       subtitle: subtitle,
                //       time: time,
                //       unreadCount: unreadCount,
                //       imageUrl: imageUrl,
                //       sessionCookie: context.read<AuthProvider>().sessionCookie,
                //       onTap: () {
                //         Navigator.push(
                //           context,
                //           MaterialPageRoute(
                //             builder: (_) => ChatPage(
                //               channelId: channelId,
                //               title: title,
                //               cookie: cookie,
                //               partnerId: [],
                //               source: ChatSource.channel,
                //               image: imageUrl,
                //
                //             ),
                //           ),
                //         )
                //         //    .then((_) => _loadChannels()
                //         //
                //         //
                //         // );
                //             .then((_) {
                //           context.read<InboxProvider>().loadChannels(
                //             cookie!,
                //             authProvider.partnerId!,
                //             silent: true,
                //           );
                //         });
                //       },
                //     );
                //   },
                // );
                final String subtitle = _asString(channel['last_message']).isEmpty
                    ? 'No message preview'
                    : _asString(channel['last_message']);

                return _channelTile(
                  title: title,
                  subtitle: subtitle,
                  time: time,
                  unreadCount: unreadCount,
                  imageUrl: imageUrl,
                  sessionCookie: context.read<AuthProvider>().sessionCookie,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatPage(
                          channelId: channelId,
                          title: title,
                          cookie: cookie,
                          partnerId: [],
                          source: ChatSource.channel,
                          image: imageUrl,
                        ),
                      ),
                    ).then((_) => _loadChannels(silent: true));
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _channelTile({
    required String title,
    required String subtitle,
    required String time,
    required int unreadCount,
    required VoidCallback onTap,
    required String? imageUrl,
    required String? sessionCookie,
  }) {
    Widget fallbackAvatar() {
      return Center(
        child: const Icon(
          Icons.groups_2_outlined,
          color: Color(0xff714B67),
          size: 25,
        )

      );
    }
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
          Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xffF3EEF5),
            borderRadius: BorderRadius.circular(14),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: imageUrl == null || imageUrl.isEmpty
                ? fallbackAvatar()
                : Image.network(
              imageUrl,
              headers: sessionCookie == null || sessionCookie.isEmpty
                  ? null
                  : {'Cookie': sessionCookie},
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => fallbackAvatar(),
            ),
          ),
        ),
            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [

                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15.8,
                            fontWeight: FontWeight.w600,
                            color: Color(0xff1F2937),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.5,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      if (unreadCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xff714B67),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyChannelState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.tag, size: 72, color: Color(0xff714B67)),
          const SizedBox(height: 14),
          const Text(
            'No channels found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            'Create or join a channel to start discussion.',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}



