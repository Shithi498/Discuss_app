import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/employee_model.dart';
import '../provider/auth_provider.dart';
import '../provider/employee_provider.dart';

class EmployeeProfilePage extends StatefulWidget {
  const EmployeeProfilePage({super.key});

  @override
  State<EmployeeProfilePage> createState() => _EmployeeProfilePageState();
}

class _EmployeeProfilePageState extends State<EmployeeProfilePage> {


  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<EmployeeProvider>(context, listen: false).loadProfile());
  }

  @override
  void dispose() {
    super.dispose();
  }
  String displayValue(dynamic value) {
    if (value == null) return '—';
    if (value is List) {
      if (value.length > 1) return value[1].toString();
      if (value.isNotEmpty) return value[0].toString();
      return '—';
    }
    return value.toString();
  }
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EmployeeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My profile'),
        centerTitle: true,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
          ? Center(
          child: Text(provider.error!,
              style: const TextStyle(color: Colors.redAccent)))
          : provider.profile == null
          ? const Center(child: Text('No data'))
          : _buildProfile(context, provider),
    );
  }

  // Widget _buildProfile(BuildContext context, EmployeeProvider provider) {
  //   // We can safely access provider.profile! here because of the checks in build()
  //   final emp = provider.profile!.employee;
  //   // Assuming AuthProvider is available
  //   final sessionCookie = Provider.of<AuthProvider>(context, listen: false).sessionCookie ?? '';
  //   final w = MediaQuery.of(context).size.width;
  //
  //
  //   return SingleChildScrollView(
  //     child: Column(
  //       children: [
  //         // --- Profile Header Section ---
  //         Stack(
  //           alignment: Alignment.topCenter,
  //           children: [
  //             // 2. Profile Content (Name, Title, Location, Profile Pic, Contact Info)
  //             Padding(
  //               padding: const EdgeInsets.only(top: 20), // Adjust to overlap with the header
  //               child: Column(
  //                 children: [
  //                   // Profile Picture
  //                   Stack(
  //                     alignment: Alignment.center,
  //                     children: [
  //                       Container(
  //                         width: 110,
  //                         height: 110,
  //                         decoration: BoxDecoration(
  //                           shape: BoxShape.circle,
  //                           border: Border.all(color: Colors.white, width: 3),
  //                           boxShadow: [
  //                             BoxShadow(
  //                               color: Colors.black.withOpacity(0.1),
  //                               blurRadius: 10,
  //                             ),
  //                           ],
  //                         ),
  //                         child: ClipOval(
  //                           child: Image.network(
  //                             'https://demo.kendroo.com${emp.imageUrl}',
  //                             headers: {'Cookie': sessionCookie},
  //                             fit: BoxFit.cover,
  //                             width: 110,
  //                             height: 110,
  //                             errorBuilder: (context, error, stackTrace) =>
  //                             const Icon(Icons.person, size: 60, color: Colors.grey),
  //                           ),
  //                         ),
  //                       ),
  //                       // Edit Icon on the profile picture
  //                       Positioned(
  //                         right: 0,
  //                         bottom: 0,
  //                         child: Container(
  //                           padding: const EdgeInsets.all(4),
  //                           decoration: const BoxDecoration(
  //                             color: Colors.white,
  //                             shape: BoxShape.circle,
  //                           ),
  //                           child: const Icon(Icons.camera_alt_outlined, size: 18, color: Colors.grey),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                   const SizedBox(height: 16),
  //                   // Row(
  //                   //   mainAxisAlignment: MainAxisAlignment.center,
  //                   //   children: [
  //                   //     Text(emp.name,
  //                   //         style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
  //                   //     const SizedBox(width: 8),
  //                   //     // Edit icon next to the name
  //                   //     const Icon(Icons.edit, size: 18, color: Colors.grey),
  //                   //   ],
  //                   // ),
  //
  //                   Row(
  //                     mainAxisAlignment: MainAxisAlignment.center,
  //                     children: [
  //                       Flexible(
  //                         child: Text(
  //                           emp.name,
  //                           maxLines: 1,
  //                           overflow: TextOverflow.ellipsis,
  //                           style: TextStyle(
  //                             fontSize: (MediaQuery.of(context).size.width * 0.055)
  //                                 .clamp(16.0, 24.0),
  //                             fontWeight: FontWeight.bold,
  //                           ),
  //                         ),
  //                       ),
  //
  //                       SizedBox(
  //                         width: (MediaQuery.of(context).size.width * 0.02)
  //                             .clamp(4.0, 10.0),
  //                       ),
  //
  //                       Icon(
  //                         Icons.edit,
  //                         size: (MediaQuery.of(context).size.width * 0.045)
  //                             .clamp(14.0, 20.0),
  //                         color: Colors.grey,
  //                       ),
  //                     ],
  //                   ),
  //
  //                   // Text(emp.jobTitle,
  //                   //     style: const TextStyle(color: Colors.black54, fontSize: 16)),
  //
  //                   Text(
  //                     emp.jobTitle,
  //                     maxLines: 1,
  //                     overflow: TextOverflow.ellipsis,
  //                     style: TextStyle(
  //                       color: Colors.black54,
  //                       fontSize: (MediaQuery.of(context).size.width * 0.04)
  //                           .clamp(13.0, 18.0), // responsive font size
  //                     ),
  //                   ),
  //
  //
  //                   const SizedBox(height: 16),
  //                   // Contact Info Section with Profile Completion
  //                   Padding(
  //                     padding: const EdgeInsets.symmetric(horizontal: 20.0),
  //                     child: Row(
  //                       mainAxisAlignment: MainAxisAlignment.spaceAround,
  //                       children: [
  //                         _contactInfoTile(Icons.phone, emp.workPhone.replaceAll(' ', ''),),
  //                         _contactInfoTile(Icons.email, emp.workEmail, ),
  //
  //                       ],
  //                     ),
  //                   ),
  //                   const SizedBox(height: 16),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //
  //         // --- Personal Information Section (Main Content) ---
  //         const Divider(height: 1, thickness: 1),
  //         _buildPersonalTab(emp,),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildProfile(BuildContext context, EmployeeProvider provider) {
    final profile = provider.profile;
    final width = MediaQuery.of(context).size.width;

    final String name = provider.userName;
    final String email = provider.email;
    final String joinedYear = provider.joinedYear;

    final String phone = profile?['phone']?.toString() ??
        profile?['mobile']?.toString() ??
        '—';

    return SingleChildScrollView(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.topCenter,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                              ),
                            ],
                            color: Colors.grey.shade200,
                          ),
                          child: ClipOval(
                            child: Center(
                              child: Text(
                                name.isNotEmpty ? name[0].toUpperCase() : 'U',
                                style: const TextStyle(
                                  fontSize: 42,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt_outlined,
                              size: 18,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: (width * 0.055).clamp(16.0, 24.0),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: (width * 0.02).clamp(4.0, 10.0),
                        ),
                        Icon(
                          Icons.edit,
                          size: (width * 0.045).clamp(14.0, 20.0),
                          color: Colors.grey,
                        ),
                      ],
                    ),

                    Text(
                      email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: (width * 0.04).clamp(13.0, 18.0),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _contactInfoTile(
                            Icons.phone,
                            phone.replaceAll(' ', ''),
                          ),
                          _contactInfoTile(
                            Icons.email,
                            email,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'Joined: $joinedYear',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),

          const Divider(height: 1, thickness: 1),

          _buildPersonalTab(profile),
        ],
      ),
    );
  }






  Widget _contactInfoTile(IconData icon, String text) {

    String displayString = text.contains('@')
        ? text.substring(0, text.indexOf('@'))
        : text;


    if (displayString.length > 15) {
      displayString = '${displayString.substring(0, 12)}...';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.grey.shade600, size: 14),
            const SizedBox(width: 2),
            Text(displayString, style: const TextStyle(fontSize: 12, color: Colors.black87)),
          ],
        ),
        Text(
          text.contains('@') ? text.substring(text.indexOf('@')) : '',
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
      ],
    );
  }





  // Widget _buildPersonalTab(Employee emp,) {
  //
  //   return Padding(
  //     padding: const EdgeInsets.all(16),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             const Text('Personal Information',
  //                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
  //
  //           ],
  //         ),
  //         const Divider(),
  //         _personalInfoRow('Name', emp.name),
  //
  //         _personalInfoRow('Manager', emp.manager),
  //         _personalInfoRow('Department', emp.department),
  //         _personalInfoRow('Company', emp.company),
  //
  //       ],
  //     ),
  //   );
  // }

  Widget _buildPersonalTab(Map<String, dynamic>? profile) {
    final w = MediaQuery.of(context).size.width;


    final titleSize = (w * 0.048).clamp(16.0, 20.0);

    final horizontalPad = (w * 0.04).clamp(12.0, 22.0);

    return Padding(
      padding: EdgeInsets.all(horizontalPad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personal Information',
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(),

          _personalInfoRow('Name', profile?['name']?.toString() ?? '—'),
          _personalInfoRow('Manager', profile?['email']?.toString() ?? profile?['login']?.toString() ?? '—'),
    //      _personalInfoRow('Department', displayValue(profile?['partner_id'])),
          _personalInfoRow('Joined at', profile?['create_date']?.toString() ?? '—'),
        ],
      ),
    );
  }


  // Helper widget for Personal Information rows
  // Widget _personalInfoRow(String label, String value) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 6.0),
  //     child: Row(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         SizedBox(
  //           width: 130, // Aligning the labels, increased width for safety
  //           child: Text(
  //             label,
  //             style: const TextStyle(color: Colors.black54, fontSize: 15),
  //           ),
  //         ),
  //         const Text('', style: TextStyle(color: Colors.grey, fontSize: 15)), // Removed colon for cleaner alignment
  //         Expanded(
  //           child: Text(
  //             value,
  //             style: const TextStyle(
  //                 color: Colors.black, fontSize: 15, fontWeight: FontWeight.w600),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _personalInfoRow(String label, String value) {
    final w = MediaQuery.of(context).size.width;


    final labelWidth = (w * 0.32).clamp(90.0, 150.0);
    final labelFont = (w * 0.036).clamp(12.0, 15.0);
    final valueFont = (w * 0.038).clamp(13.0, 16.0);
    final rowSpacing = (w * 0.018).clamp(4.0, 10.0);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: rowSpacing),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: labelWidth,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.black54,
                fontSize: labelFont,
              ),
            ),
          ),


          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.black,
                fontSize: valueFont,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

