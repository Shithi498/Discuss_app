class ChatUser {

  final int uid;
  final String name;
  final String username;
  final String email;
  final int partnerId;
  final String db;
  final String lang;
  final String timezone;
  final String webBaseUrl;
  final bool isSystem;
  final bool isAdmin;
  final bool isPublic;
  final bool isInternalUser;
  final String? sessionCookie;

  ChatUser({
    required this.uid,
    required this.name,
    required this.username,
    required this.email,
    required this.partnerId,
    required this.db,
    required this.lang,
    required this.timezone,
    required this.webBaseUrl,
    required this.isSystem,
    required this.isAdmin,
    required this.isPublic,
    required this.isInternalUser,
    this.sessionCookie,
  });


  factory ChatUser.fromOdooSession(
      Map<String, dynamic> json, {
        String? sessionCookie,
      }) {
    final ctx = (json['user_context'] ?? {}) as Map<String, dynamic>;

    return ChatUser(
      uid: (json['uid'] ?? 0) as int,
      name: (json['name'] ?? json['partner_display_name'] ?? '') as String,
      username: (json['username'] ?? '') as String,
      email: (json['username'] ?? '') as String,
      partnerId: (json['partner_id'] ?? 0) as int,
      db: (json['db'] ?? '') as String,
      lang: (ctx['lang'] ?? 'en_US') as String,
      timezone: (ctx['tz'] ?? 'UTC') as String,
      webBaseUrl: (json['web.base.url'] ?? '') as String,
      isSystem: (json['is_system'] ?? false) as bool,
      isAdmin: (json['is_admin'] ?? false) as bool,
      isPublic: (json['is_public'] ?? false) as bool,
      isInternalUser: (json['is_internal_user'] ?? false) as bool,
      sessionCookie: sessionCookie,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'username': username,
      'email': email,
      'partnerId': partnerId,
      'db': db,
      'lang': lang,
      'timezone': timezone,
      'webBaseUrl': webBaseUrl,
      'isSystem': isSystem,
      'isAdmin': isAdmin,
      'isPublic': isPublic,
      'isInternalUser': isInternalUser,
      'sessionCookie': sessionCookie,
    };
  }

  factory ChatUser.fromJson(Map<String, dynamic> map) {
    return ChatUser(
      uid: map['uid'] as int,
      name: map['name'] as String,
      username: map['username'] as String,
      email: map['email'] as String,
      partnerId: map['partnerId'] as int,
      db: map['db'] as String,
      lang: map['lang'] as String,
      timezone: map['timezone'] as String,
      webBaseUrl: map['webBaseUrl'] as String,
      isSystem: map['isSystem'] as bool,
      isAdmin: map['isAdmin'] as bool,
      isPublic: map['isPublic'] as bool,
      isInternalUser: map['isInternalUser'] as bool,
      sessionCookie: map['sessionCookie'] as String?,
    );
  }
}