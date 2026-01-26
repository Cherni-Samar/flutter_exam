import 'package:flutter/material.dart';
import '../models/notification.dart';
import '../services/database_service.dart';
import '../utils/constants.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final DatabaseService _databaseService = DatabaseService.instance;
  List<VehicleNotification> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final notifications = await _databaseService.getAllNotifications();
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _clearAllNotifications() async {
    await _databaseService.clearAllNotifications();
    await _loadNotifications();
  }

  IconData _getIconForNotificationType(String type) {
    switch (type) {
      case NotificationTypes.unlock:
        return Icons.lock_open;
      case NotificationTypes.lock:
        return Icons.lock;
      case NotificationTypes.lowAutonomy:
        return Icons.warning;
      case NotificationTypes.maintenance:
        return Icons.build;
      default:
        return Icons.notifications;
    }
  }

  Color _getColorForNotificationType(String type) {
    switch (type) {
      case NotificationTypes.unlock:
        return Colors.orange;
      case NotificationTypes.lock:
        return Colors.green;
      case NotificationTypes.lowAutonomy:
        return Colors.red;
      case NotificationTypes.maintenance:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inHours < 1) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inDays < 1) {
      return 'Il y a ${difference.inHours} h';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} j';
    } else {
      return DateFormat('dd/MM/yyyy HH:mm').format(timestamp);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (_notifications.isNotEmpty)
            TextButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Effacer les notifications'),
                    content: const Text('Voulez-vous vraiment effacer toutes les notifications ?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Annuler'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _clearAllNotifications();
                        },
                        child: const Text('Effacer'),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.delete, color: Colors.white),
              label: const Text(
                'Clear',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_off,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aucune notification',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final notification = _notifications[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getColorForNotificationType(notification.type),
                          child: Icon(
                            _getIconForNotificationType(notification.type),
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          notification.message,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            _formatTimestamp(notification.timestamp),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
