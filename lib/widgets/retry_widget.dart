import 'package:flutter/material.dart';

class RetryWidget extends StatelessWidget {
  final dynamic error;
  final VoidCallback onRetry;
  final String? customTitle;
  final IconData? customIcon;

  const RetryWidget({
    Key? key,
    required this.error,
    required this.onRetry,
    this.customTitle,
    this.customIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Определяем иконку в зависимости от ошибки
    IconData icon = customIcon ?? _getErrorIcon(error);

    // Определяем сообщение в зависимости от ошибки
    String message = _getFriendlyErrorMessage(error);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Иконка
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: Colors.orange.shade700,
              ),
            ),
            SizedBox(height: 24),

            // Заголовок
            Text(
              customTitle ?? 'Что-то пошло не так',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: 12),

            // Сообщение об ошибке
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),

            // Подсказка
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.wifi_off,
                  size: 16,
                  color: Colors.grey.shade500,
                ),
                SizedBox(width: 8),
                Text(
                  'Проверьте подключение к интернету',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 32),

            // Кнопка повторной попытки
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: Icon(Icons.refresh),
              label: Text('Повторить'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),

            // Если есть детальная информация об ошибке (только для отладки)
            if (error != null && error.toString().isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: 24),
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Детали ошибки:',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        error.toString(),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                          fontFamily: 'monospace',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Определяет иконку по типу ошибки
  IconData _getErrorIcon(dynamic error) {
    final errorStr = error.toString().toLowerCase();

    if (errorStr.contains('internet') ||
        errorStr.contains('network') ||
        errorStr.contains('socket') ||
        errorStr.contains('connection')) {
      return Icons.wifi_off;
    }

    if (errorStr.contains('timeout')) {
      return Icons.timer_off;
    }

    if (errorStr.contains('server') || errorStr.contains('500')) {
      return Icons.sync_problem;
    }

    if (errorStr.contains('auth') || errorStr.contains('401')) {
      return Icons.lock_outline;
    }

    return Icons.error_outline;
  }

  /// Возвращает понятное сообщение об ошибке
  String _getFriendlyErrorMessage(dynamic error) {
    if (error == null) return 'Произошла неизвестная ошибка';

    final errorStr = error.toString().toLowerCase();

    if (errorStr.contains('internet') ||
        errorStr.contains('network') ||
        errorStr.contains('socket') ||
        errorStr.contains('connection')) {
      return 'Ошибка подключения к интернету. Проверьте сеть.';
    }

    if (errorStr.contains('timeout')) {
      return 'Превышено время ожидания. Сервер не отвечает.';
    }

    if (errorStr.contains('500') || errorStr.contains('server error')) {
      return 'Временные проблемы на сервере. Попробуйте позже.';
    }

    if (errorStr.contains('401') || errorStr.contains('unauthorized')) {
      return 'Ошибка авторизации. Пожалуйста, войдите заново.';
    }

    if (errorStr.contains('404') || errorStr.contains('not found')) {
      return 'Данные не найдены.';
    }

    return 'Произошла ошибка. Пожалуйста, попробуйте снова.';
  }
}

/// Компактная версия для встраивания в другие виджеты
class CompactRetryWidget extends StatelessWidget {
  final VoidCallback onRetry;
  final String? message;

  const CompactRetryWidget({
    Key? key,
    required this.onRetry,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red.shade300,
          ),
          SizedBox(height: 12),
          Text(
            message ?? 'Не удалось загрузить данные',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: Icon(Icons.refresh, size: 16),
            label: Text('Повторить'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blue,
              side: BorderSide(color: Colors.blue.shade200),
            ),
          ),
        ],
      ),
    );
  }
}
