class UserProfileModel {
  final String id;
  final String username;
  final String avatarUrl;
  final String Role;
  final DateTime createdAt;

  UserProfileModel({
    required this.id,
    required this.Role,
    required this.username,
    required this.avatarUrl,
    required this.createdAt,
  });

  // Ánh xạ dữ liệu bản ghi từ Supabase (Map) sang đối tượng trong Flutter
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String,
      username: json['username'] as String? ?? 'Người dùng Musify',
      avatarUrl: json['avatar_url'] as String? ?? 'https://bwcygbzraxmilppnwxhg.supabase.co/storage/v1/object/public/music_assets/user-default.jpg',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'].toString()) : DateTime.now(),
      Role: json['role']?.toString() ?? json['Role']?.toString() ?? 'User'
    );
  }
}