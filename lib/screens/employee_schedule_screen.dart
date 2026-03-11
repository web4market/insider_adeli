import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/employee_schedule_model.dart';
import '../widgets/retry_widget.dart';

class EmployeeScheduleScreen extends StatefulWidget {
  @override
  _EmployeeScheduleScreenState createState() => _EmployeeScheduleScreenState();
}

class _EmployeeScheduleScreenState extends State<EmployeeScheduleScreen> {
  final ApiService _apiService = ApiService();

  EmployeeScheduleModel? _schedule;
  List<ScheduleDay> _allDays = [];
  bool _isLoading = true;
  String? _error;

  // Навигация по дням
  int _currentDayIndex = 0;
  final List<String> _viewModes = ['today', 'next', 'all'];
  String _currentViewMode = 'today';

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _currentDayIndex = 0;
    });

    try {
      print('🔄 Загрузка расписания специалиста...');

      final response = await _apiService.getEmployeeSchedule(period: 'all');

      print('📦 Ответ: $response');

      if (response['success'] == true) {
        setState(() {
          _schedule = EmployeeScheduleModel.fromJson(response);
          _allDays = _schedule?.days ?? [];
          _isLoading = false;
        });
        print('✅ Загружено дней: ${_allDays.length}');
      } else {
        setState(() {
          _error = response['message'] ?? 'Ошибка загрузки';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Ошибка: $e');
      setState(() {
        _error = 'Ошибка соединения';
        _isLoading = false;
      });
    }
  }

  // Получить отображаемые дни в зависимости от режима
  // Получить отображаемые дни в зависимости от режима
  List<ScheduleDay> get _displayDays {
    if (_allDays.isEmpty) return [];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Сортируем дни по дате (на всякий случай)
    final sortedDays = List<ScheduleDay>.from(_allDays)
      ..sort((a, b) => a.date.compareTo(b.date));

    switch (_currentViewMode) {
      case 'today':
        // Показываем только сегодняшний день
        return sortedDays.where((day) {
          try {
            final dayDate = DateTime.parse(day.date);
            return dayDate.year == today.year &&
                dayDate.month == today.month &&
                dayDate.day == today.day;
          } catch (e) {
            return false;
          }
        }).toList();

      case 'next':
        // Находим первый день, который больше сегодняшнего
        final futureDays = sortedDays.where((day) {
          try {
            final dayDate = DateTime.parse(day.date);
            return dayDate.isAfter(today);
          } catch (e) {
            return false;
          }
        }).toList();

        if (futureDays.isEmpty) return [];

        // Берем самый ближайший будущий день
        return [futureDays.first];

      case 'all':
      default:
        // Показываем все дни
        return sortedDays;
    }
  }

  // Переключение режима просмотра
  void _changeViewMode(String mode) {
    setState(() {
      _currentViewMode = mode;
      _currentDayIndex = 0;
    });
  }

  // Навигация по дням (для режима 'all')
  void _nextDay() {
    if (_currentDayIndex < _displayDays.length - 1) {
      setState(() {
        _currentDayIndex++;
      });
    }
  }

  void _previousDay() {
    if (_currentDayIndex > 0) {
      setState(() {
        _currentDayIndex--;
      });
    }
  }

  String _getViewModeTitle() {
    switch (_currentViewMode) {
      case 'today':
        return 'Сегодня';
      case 'next':
        return 'Ближайший день';
      case 'all':
        return 'Все дни';
      default:
        return 'Расписание';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Моё расписание'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Container(
            color: Colors.blue.shade700,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildViewModeButton('today', 'Сегодня'),
                _buildViewModeButton('next', 'Следующий'),
                _buildViewModeButton('all', 'Все дни'),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadSchedule,
            tooltip: 'Обновить',
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error != null
              ? RetryWidget(
                  error: _error!,
                  onRetry: _loadSchedule,
                  customTitle: 'Не удалось загрузить расписание',
                )
              : _schedule == null || _allDays.isEmpty
                  ? _buildEmptyWidget()
                  : _buildScheduleWidget(),
    );
  }

  Widget _buildViewModeButton(String mode, String label) {
    final isSelected = _currentViewMode == mode;

    return Expanded(
      child: GestureDetector(
        onTap: () => _changeViewMode(mode),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleWidget() {
    final displayDays = _displayDays;

    if (displayDays.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 64, color: Colors.grey.shade400),
            SizedBox(height: 16),
            Text(
              _currentViewMode == 'today'
                  ? 'На сегодня записей нет'
                  : _currentViewMode == 'next'
                      ? 'Ближайших записей нет'
                      : 'Записей не найдено',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _changeViewMode('all'),
              icon: Icon(Icons.calendar_month),
              label: Text('Посмотреть все дни'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Статистика специалиста
        if (_schedule!.stats != null && _currentViewMode == 'all')
          _buildStatsWidget(),

        // Навигация по дням (для режима 'all')
        if (_currentViewMode == 'all' && displayDays.length > 1)
          _buildDayNavigator(displayDays),

        // Текущий день
        Expanded(
          child: _buildDayCard(displayDays[_currentDayIndex]),
        ),
      ],
    );
  }

  Widget _buildDayNavigator(List<ScheduleDay> days) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey.shade100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left),
            onPressed: _currentDayIndex > 0 ? _previousDay : null,
            color: _currentDayIndex > 0 ? Colors.blue : Colors.grey,
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'День ${_currentDayIndex + 1} из ${days.length}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  days[_currentDayIndex].formattedDate,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right),
            onPressed: _currentDayIndex < days.length - 1 ? _nextDay : null,
            color:
                _currentDayIndex < days.length - 1 ? Colors.blue : Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsWidget() {
    final stats = _schedule!.stats!;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.33,
      ),
      margin: EdgeInsets.all(12),
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.analytics, color: Colors.blue.shade700),
                  SizedBox(width: 8),
                  Text(
                    'Моя статистика',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),

              // Статистика за 30 дней
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildStatRow(
                      'За последние дни расписания',
                      Icons.calendar_today,
                      Colors.blue,
                    ),
                    SizedBox(height: 8),
                    _buildStatItem('Всего процедур', stats.last30Days.total),
                    _buildStatItem('Как основной', stats.last30Days.asMain),
                    _buildStatItem(
                        'Как ассистент', stats.last30Days.asAssistant),
                    _buildStatItem('Уникальных пациентов',
                        stats.last30Days.uniquePatients),
                    // ИСПРАВЛЕНИЕ: totalHours может быть double
                    _buildStatItemDouble(
                        'Часов работы', stats.last30Days.totalHours,
                        suffix: ' ч'),
                  ],
                ),
              ),

              SizedBox(height: 8),

              // Топ коллеги
              if (stats.topColleagues.isNotEmpty) ...[
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatRow(
                        'Часто работаю с',
                        Icons.people,
                        Colors.green,
                      ),
                      SizedBox(height: 8),
                      ...stats.topColleagues.map((colleague) => Padding(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Icon(Icons.person,
                                    size: 16, color: Colors.grey.shade600),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    colleague.name,
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${colleague.timesTogether} раз',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.green.shade700,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

// новый метод для отображения double значений
  Widget _buildStatItemDouble(String label, double value,
      {String suffix = ''}) {
    // Форматируем double: если число целое, показываем без десятичной части
    String displayValue;
    if (value == value.roundToDouble()) {
      displayValue = value.round().toString();
    } else {
      displayValue = value.toStringAsFixed(1);
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
          ),
          Text(
            '$displayValue$suffix',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, int value, {String suffix = ''}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
          ),
          Text(
            '$value$suffix',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCard(ScheduleDay day) {
    return ListView(
      padding: EdgeInsets.all(12),
      children: [
        // Заголовок дня
        Container(
          padding: EdgeInsets.all(16),
          margin: EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  day.date.split('-').last,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      day.formattedDate,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      day.dayOfWeek,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${day.activities.length}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Список активностей
        ...day.activities.map((activity) => _buildActivityCard(activity)),
      ],
    );
  }

  Widget _buildActivityCard(Activity activity) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showActivityDetail(activity),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Маркер роли
              Container(
                width: 4,
                height: 60,
                decoration: BoxDecoration(
                  color: activity.roleColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(width: 12),

              // Время
              Container(
                width: 65,
                child: Column(
                  children: [
                    Text(
                      activity.time,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: activity.roleColor,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 4),
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: activity.roleColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        activity.roleText,
                        style: TextStyle(
                          fontSize: 10,
                          color: activity.roleColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12),

              // Основная информация
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.patient,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      activity.service,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.meeting_room,
                            size: 14, color: Colors.grey.shade500),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            activity.cabinet,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (activity.colleague != null) ...[
                      SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.people,
                              size: 14, color: Colors.grey.shade500),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'с ${activity.colleague!.name}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Длительность
              Column(
                children: [
                  Icon(Icons.timer, size: 16, color: Colors.grey.shade400),
                  SizedBox(height: 4),
                  Text(
                    '${activity.duration}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showActivityDetail(Activity activity) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.6,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: activity.roleColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        activity.roleText,
                        style: TextStyle(
                          color: activity.roleColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 6),
                    Text(
                      activity.timeRange,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                _buildDetailRow(Icons.person, 'Пациент', activity.patient),
                _buildDetailRow(
                    Icons.medical_services, 'Услуга', activity.service),
                _buildDetailRow(
                    Icons.meeting_room, 'Кабинет', activity.cabinet),
                _buildDetailRow(
                    Icons.timer, 'Длительность', '${activity.duration} мин'),
                if (activity.colleague != null) ...[
                  SizedBox(height: 6),
                  Text(
                    'Совместная работа',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.people, color: Colors.green.shade700),
                        SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Коллега',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.green.shade700,
                                ),
                              ),
                              Text(
                                activity.colleague!.displayText,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                SizedBox(height: 6),
                Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Закрыть'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 40),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_month, size: 80, color: Colors.grey.shade400),
          SizedBox(height: 16),
          Text(
            'Нет записей в расписании',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Расписание обновляется автоматически',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadSchedule,
            icon: Icon(Icons.refresh),
            label: Text('Обновить'),
          ),
        ],
      ),
    );
  }
}
