class OdooUser {
  final int uid;
  final String name;
  final String username;
  final String db;
  final String timezone;
  final String companyName;

  OdooUser({
    required this.uid,
    required this.name,
    required this.username,
    required this.db,
    required this.timezone,
    required this.companyName,
  });

  factory OdooUser.fromJson(Map<String, dynamic> result) {

    final userCompanies =
        result['user_companies'] as Map<String, dynamic>? ?? {};
    final allowedCompanies =
        userCompanies['allowed_companies'] as Map<String, dynamic>? ?? {};
    final currentCompanyId = userCompanies['current_company'];

    // keys in allowed_companies are strings: "1", "2", ...
    final currentCompany =
        allowedCompanies['$currentCompanyId'] as Map<String, dynamic>? ?? {};

    final userContext =
        result['user_context'] as Map<String, dynamic>? ?? {};

    return OdooUser(
      uid: (result['uid'] as num?)?.toInt() ?? 0,
      name: result['name'] as String? ?? '',
      username: result['username'] as String? ?? '',
      db: result['db'] as String? ?? '',
      timezone: userContext['tz'] as String? ?? '',
      companyName: currentCompany['name'] as String? ?? '',
    );
  }
}