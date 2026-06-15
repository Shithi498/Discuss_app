class SearchUser {
  final int id;
  final int? partnerId;
  final String name;
  final String? email;
  final String? phone;
  final String? imageUrl;

  SearchUser({
    required this.id,
    required this.partnerId,
    required this.name,
    required this.email,
    required this.phone,
    required this.imageUrl,
  });

  factory SearchUser.fromJson(Map<String, dynamic> json, String baseUrl) {
    int? partnerId;

    if (json['partner_id'] is List && (json['partner_id'] as List).isNotEmpty) {
      partnerId = json['partner_id'][0] as int;
    }

    return SearchUser(
      id: json['id'] as int,
      partnerId: partnerId,
      name: (json['name'] ?? '').toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      imageUrl: partnerId != null
          ? '$baseUrl/web/image?model=res.partner&id=$partnerId&field=image_128'
          : null,
    );
  }
}
