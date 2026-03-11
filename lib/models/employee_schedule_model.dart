import 'package:flutter/material.dart';

/// Модель для расписания специалиста
class EmployeeScheduleModel {
  final String employeeGuid;
  final String employeeName;
  final List<ScheduleDay> days;
  final EmployeeStats? stats;

  EmployeeScheduleModel({
    required this.employeeGuid,
    required this.employeeName,
    required this.days,
    this.stats,
  });

  factory EmployeeScheduleModel.fromJson(Map<String, dynamic> json) {
    print('📦 EmployeeScheduleModel.fromJson');

    final data = json['data'] as List? ?? [];
    final stats =
        json['stats'] != null ? EmployeeStats.fromJson(json['stats']) : null;

    return EmployeeScheduleModel(
      employeeGuid: _safeString(json['employee']?['guid']),
      employeeName:
          _safeString(json['employee']?['name'], defaultValue: 'Специалист'),
      days: data.map((day) => ScheduleDay.fromJson(day)).toList(),
      stats: stats,
    );
  }

  // ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ (теперь не статические, а обычные)
  static String _safeString(dynamic value, {String defaultValue = ''}) {
    if (value == null) return defaultValue;
    if (value is String) return value;
    return value.toString();
  }

  static int _safeInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return defaultValue;
      try {
        return int.parse(trimmed);
      } catch (e) {
        try {
          return double.parse(trimmed).toInt();
        } catch (e) {
          print('⚠️ Не удалось преобразовать "$value" в int');
          return defaultValue;
        }
      }
    }
    return defaultValue;
  }

  static double _safeDouble(dynamic value, {double defaultValue = 0.0}) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        return defaultValue;
      }
    }
    return defaultValue;
  }
}

/// Модель для одного дня расписания
class ScheduleDay {
  final String date;
  final String formattedDate;
  final String dayOfWeek;
  final List<Activity> activities;

  ScheduleDay({
    required this.date,
    required this.formattedDate,
    required this.dayOfWeek,
    required this.activities,
  });

  factory ScheduleDay.fromJson(Map<String, dynamic> json) {
    return ScheduleDay(
      date: EmployeeScheduleModel._safeString(json['date']),
      formattedDate: EmployeeScheduleModel._safeString(json['formatted_date']),
      dayOfWeek: EmployeeScheduleModel._safeString(json['day_of_week']),
      activities: (json['activities'] as List? ?? [])
          .map((a) => Activity.fromJson(a))
          .toList(),
    );
  }
}

/// Модель для активности (процедуры)
class Activity {
  final int id;
  final String role; // 'main' или 'assistant'
  final String time;
  final String timeRange;
  final String cabinet;
  final String patient;
  final String service;
  final int duration;
  final Colleague? colleague;

  Activity({
    required this.id,
    required this.role,
    required this.time,
    required this.timeRange,
    required this.cabinet,
    required this.patient,
    required this.service,
    required this.duration,
    this.colleague,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    print('📦 Activity.fromJson: $json');

    return Activity(
      id: EmployeeScheduleModel._safeInt(json['id']),
      role:
          EmployeeScheduleModel._safeString(json['role'], defaultValue: 'main'),
      time: EmployeeScheduleModel._safeString(json['time']),
      timeRange: EmployeeScheduleModel._safeString(json['time_range']),
      cabinet: EmployeeScheduleModel._safeString(json['cabinet']),
      patient:
          _cleanPatientName(EmployeeScheduleModel._safeString(json['patient'])),
      service: EmployeeScheduleModel._safeString(json['service']),
      duration: EmployeeScheduleModel._safeInt(json['duration']),
      colleague: json['colleague'] != null
          ? Colleague.fromJson(json['colleague'])
          : null,
    );
  }

  static String _cleanPatientName(String fullName) {
    // Убираем дату рождения из имени пациента
    return fullName.replaceAll(RegExp(r'\s*\(.*?\)\s*'), '');
  }

  /// Цвет роли
  Color get roleColor => role == 'main' ? Colors.blue : Colors.green;

  /// Текст роли
  String get roleText => role == 'main' ? 'Основной' : 'Ассистент';
}

/// Модель для коллеги (с кем работает специалист)
class Colleague {
  final String name;
  final String role;

  Colleague({
    required this.name,
    required this.role,
  });

  factory Colleague.fromJson(Map<String, dynamic> json) {
    return Colleague(
      name: EmployeeScheduleModel._safeString(json['name']),
      role: EmployeeScheduleModel._safeString(json['role']),
    );
  }

  /// Текст коллеги
  String get displayText => '$name ($role)';
}

/// Модель для статистики специалиста
class EmployeeStats {
  final Last30DaysStats last30Days;
  final AllTimeStats allTime;
  final List<ColleagueStat> topColleagues;

  EmployeeStats({
    required this.last30Days,
    required this.allTime,
    required this.topColleagues,
  });

  factory EmployeeStats.fromJson(Map<String, dynamic> json) {
    return EmployeeStats(
      last30Days: Last30DaysStats.fromJson(json['last_30_days'] ?? {}),
      allTime: AllTimeStats.fromJson(json['all_time'] ?? {}),
      topColleagues: (json['top_colleagues'] as List? ?? [])
          .map((c) => ColleagueStat.fromJson(c))
          .toList(),
    );
  }
}

/// Статистика за последние 30 дней
class Last30DaysStats {
  final int total;
  final int asMain;
  final int asAssistant;
  final int uniquePatients;
  final int uniqueCabinets;
  final double totalHours;

  Last30DaysStats({
    required this.total,
    required this.asMain,
    required this.asAssistant,
    required this.uniquePatients,
    required this.uniqueCabinets,
    required this.totalHours,
  });

  factory Last30DaysStats.fromJson(Map<String, dynamic> json) {
    return Last30DaysStats(
      total: EmployeeScheduleModel._safeInt(json['total']),
      asMain: EmployeeScheduleModel._safeInt(json['as_main']),
      asAssistant: EmployeeScheduleModel._safeInt(json['as_assistant']),
      uniquePatients: EmployeeScheduleModel._safeInt(json['unique_patients']),
      uniqueCabinets: EmployeeScheduleModel._safeInt(json['unique_cabinets']),
      totalHours: EmployeeScheduleModel._safeDouble(json['total_hours']),
    );
  }
}

/// Статистика за все время
class AllTimeStats {
  final int total;
  final int asMain;
  final int asAssistant;

  AllTimeStats({
    required this.total,
    required this.asMain,
    required this.asAssistant,
  });

  factory AllTimeStats.fromJson(Map<String, dynamic> json) {
    return AllTimeStats(
      total: EmployeeScheduleModel._safeInt(json['total']),
      asMain: EmployeeScheduleModel._safeInt(json['as_main']),
      asAssistant: EmployeeScheduleModel._safeInt(json['as_assistant']),
    );
  }
}

/// Статистика по коллегам
class ColleagueStat {
  final String name;
  final int timesTogether;

  ColleagueStat({
    required this.name,
    required this.timesTogether,
  });

  factory ColleagueStat.fromJson(Map<String, dynamic> json) {
    return ColleagueStat(
      name: EmployeeScheduleModel._safeString(json['colleague_name']),
      timesTogether: EmployeeScheduleModel._safeInt(json['times_together']),
    );
  }
}
