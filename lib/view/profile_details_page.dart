import 'package:flutter/material.dart';
import 'package:provider/provider.dart';




class ProfileDetailsScreen extends StatefulWidget {
  final String name;
  final int threadId;
final String? image;
final String? email;
final String? phone;
  const ProfileDetailsScreen({
    super.key,
    required this.name,
    required this.threadId, this.image, this.email, this.phone,
  });

  @override
  State<ProfileDetailsScreen> createState() => _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends State<ProfileDetailsScreen> {
  bool _showMembersPanel = false;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    final bool smallPhone = w < 360;
    final bool bigPhone = w >= 420;
    final double pagePadding = smallPhone ? 12 : (bigPhone ? 20 : 16);
    final double avatarRadius = smallPhone ? 36 : (bigPhone ? 52 : 44);
    final double titleSize = smallPhone ? 18 : (bigPhone ? 24 : 22);
    final double subTitleSize = smallPhone ? 12 : 13;
    final double maxContentWidth = bigPhone ? 520 : 9999;

    final membersProv = context.watch<ChannelParticipantsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
      ),
      body: SafeArea(
        child: Row(
          children: [

            Container(
              width: 165,
              decoration: const BoxDecoration(
                border: Border(
                  right: BorderSide(color: Color(0xFF2A2A2A), width: 1),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  _sideItem(Icons.info_outline, "Overview", selected: true, onTap: () {}),
                  _sideItem(Icons.perm_media_outlined, "Media", onTap: () {}),
                  _sideItem(Icons.insert_drive_file_outlined, "Files", onTap: () {}),
                  _sideItem(Icons.link_outlined, "Links", onTap: () {}),


                  _sideItem(
                    Icons.groups_outlined,
                    "Group members",
                    selected: _showMembersPanel,
                    onTap: () async {
                      setState(() => _showMembersPanel = !_showMembersPanel);


                      if (_showMembersPanel) {
                        await context
                            .read<ChannelParticipantsProvider>()
                            .loadParticipants(threadId: widget.threadId);
                      }
                    },
                  ),


                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 200),
                    crossFadeState: _showMembersPanel
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    firstChild: const SizedBox.shrink(),
                    secondChild: Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10, top: 6),
                      child: Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF2A2A2A)),
                            color: Colors.white,
                          ),
                          padding: const EdgeInsets.all(8),
                          child: SizedBox(
                            height: 220,
                            child: Builder(
                              builder: (_) {
                                if (membersProv.loading) {
                                  return const Center(
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  );
                                }

                                if (membersProv.error != null) {
                                  return Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Text(
                                      membersProv.error!,
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                  );
                                }

                                final list = membersProv.participants;
                                if (list.isEmpty) {
                                  return const Center(child: Text("No members found"));
                                }

                                return ListView.separated(
                                  itemCount: list.length,
                                  separatorBuilder: (_, __) => const Divider(height: 10),
                                  itemBuilder: (_, i) {
                                    final m = list[i];
                                    return Row(
                                      children: [
                                        const CircleAvatar(
                                          radius: 14,
                                          child: Icon(Icons.person, size: 16),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            m.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),
                ],
              ),
            ),


            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxContentWidth),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(pagePadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            const Spacer(),
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.edit_outlined),
                              color: Colors.white70,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Column(
                          children: [
                            CircleAvatar(
                              radius: avatarRadius,
                            //  backgroundColor: const Color(0xFF2D2D2D),

                                child:  CircleAvatar(
                                  backgroundImage:
                                  (widget.image != null && widget.image!.isNotEmpty)
                                      ? NetworkImage(widget.image!)
                                      : const AssetImage("assets/assets/images/user_placeholder.jpg"),
                                ),

                            ),
                            const SizedBox(height: 14),
                            Text(
                              widget.name,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: titleSize,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFF2A2A2A)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _sectionTitle("Phone number", subTitleSize),
                              const SizedBox(height: 6),
                              Text(
                                widget.phone ?? '',
                                style: const TextStyle(color: Colors.black, fontSize: 14),
                              ),


                              const SizedBox(height: 16),
                              _sectionTitle("Email", subTitleSize),
                              const SizedBox(height: 6),
                               Text(widget.email ?? '',
                                  style: TextStyle(color: Colors.black, fontSize: 14)),
                              const SizedBox(height: 16),
                              _sectionTitle("Address", subTitleSize),
                              const SizedBox(height: 6),
                              const Text("Dhaka",
                                  style: TextStyle(color: Colors.black, fontSize: 14)),
                              const SizedBox(height: 16),
                              _sectionTitle("Disappearing messages", subTitleSize),
                              const SizedBox(height: 6),
                              const Text("Off",
                                  style: TextStyle(color: Colors.black, fontSize: 14)),
                              const SizedBox(height: 16),
                              const Divider(color: Color(0xFF2A2A2A)),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sideItem(
      IconData icon,
      String title, {
        bool selected = false,
        VoidCallback? onTap,
      }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: selected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: selected ? Border.all(color: const Color(0xFF2A2A2A)) : null,
      ),
      child: ListTile(
        dense: true,
        leading: Icon(icon, color: selected ? Colors.black : Colors.black54),
        title: Text(
          title,
          style: TextStyle(
            color: selected ? Colors.black54 : Colors.black,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _sectionTitle(String text, double size) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.black54,
        fontSize: size,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}


