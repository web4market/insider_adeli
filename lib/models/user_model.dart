class UserModel {
  final int id;
  final String username;
  final String? email;
  final String? name;
  final DateTime? lastLogin;

  UserModel({
    required this.id,
    required this.username,
    this.email,
    this.name,
    this.lastLogin,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    print('📦 UserModel.fromJson: $json');

    // Проверяем структуру - данные могут быть в корне или в 'data'
    Map<String, dynamic> data;
    if (json.containsKey('data') && json['data'] is Map) {
      data = json['data'];
    } else {
      data = json;
    }

    // Безопасное преобразование id
    int userId = 0;
    if (json['id'] != null) {
      if (json['id'] is int) {
        userId = json['id'];
      } else if (json['id'] is String) {
        userId = int.tryParse(json['id']) ?? 0;
      }
    }

    return UserModel(
      id: userId,
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString(),
      name: json['name']?.toString(),
      lastLogin: json['last_login'] != null
          ? DateTime.tryParse(json['last_login'])
          : null,
    );
  }
}
