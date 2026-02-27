import 'package:flutter/material.dart';

class UserModel {
  final int id;
  final String username;
  final String? email;
  final String? name;
  final DateTime? lastLogin;
  final List<ChildModel> children;

  UserModel({
    required this.id,
    required this.username,
    this.email,
    this.name,
    this.lastLogin,
    required this.children,
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

    // Парсим детей
    List<ChildModel> childrenList = [];
    if (json['children'] != null && json['children'] is List) {
      childrenList = (json['children'] as List)
          .map((c) => ChildModel.fromJson(c))
          .toList();
    }

    return UserModel(
      id: userId,
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString(),
      name: json['name']?.toString(),
      lastLogin: json['last_login'] != null
          ? DateTime.tryParse(json['last_login'])
          : null,
      children: childrenList,
    );
  }
}

class ChildModel {
  final int id;
  final String name;
  final String? birthDate;
  final String? relation;

  ChildModel({
    required this.id,
    required this.name,
    this.birthDate,
    this.relation,
  });

  factory ChildModel.fromJson(Map<String, dynamic> json) {
    return ChildModel(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      birthDate: json['birth_date']?.toString(),
      relation: json['relation']?.toString(),
    );
  }

  // Форматированная дата рождения
  String get formattedBirthDate {
    if (birthDate == null) return 'Не указана';
    try {
      final date = DateTime.parse(birthDate!);
      return '${date.day}.${date.month}.${date.year}';
    } catch (e) {
      return birthDate!;
    }
  }

  // Отношения на русском
  String get relationText {
    switch (relation?.toLowerCase()) {
      case 'mother':
        return 'Мать';
      case 'father':
        return 'Отец';
      case 'grandmother':
        return 'Бабушка';
      case 'grandfather':
        return 'Дедушка';
      case 'guardian':
        return 'Опекун';
      default:
        return relation ?? 'Родственник';
    }
  }

  // Возраст
  int? get age {
    if (birthDate == null) return null;
    try {
      final birth = DateTime.parse(birthDate!);
      final today = DateTime.now();
      int age = today.year - birth.year;
      if (today.month < birth.month ||
          (today.month == birth.month && today.day < birth.day)) {
        age--;
      }
      return age;
    } catch (e) {
      return null;
    }
  }
}