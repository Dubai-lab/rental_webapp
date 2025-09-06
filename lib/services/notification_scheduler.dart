import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'notification_service.dart';
import 'request_service.dart';
import 'payment_service.dart';
import 'shop_service.dart';

class NotificationScheduler {
  final NotificationService _notificationService;
  final RentalRequestService _requestService;
  final RentalPaymentService _paymentService;
  final ShopService _shopService;
  
  Timer? _timer;
  bool _isRunning = false;

  NotificationScheduler(
    this._notificationService,
    this._requestService,
    this._paymentService,
    this._shopService,
  );

  /// Start the notification scheduler
  void start() {
    if (_isRunning) return;
    
    _isRunning = true;
    
    // Run immediately on start
    _checkRentDueNotifications();
    
    // Then run every 6 hours
    _timer = Timer.periodic(const Duration(hours: 6), (timer) {
      _checkRentDueNotifications();
    });
    
    print('Notification scheduler started');
  }

  /// Stop the notification scheduler
  void stop() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    print('Notification scheduler stopped');
  }

  /// Check for rent due notifications
  Future<void> _checkRentDueNotifications() async {
    try {
      print('Checking for rent due notifications...');
      
      await _notificationService.checkAndCreateRentDueNotifications(
        _requestService,
        _paymentService,
        _shopService,
      );
      
      // Also cleanup old notifications
      await _notificationService.cleanupOldNotifications();
      
      print('Rent due notifications check completed');
    } catch (e) {
      print('Error checking rent due notifications: $e');
    }
  }

  /// Manual trigger for checking notifications (useful for testing)
  Future<void> checkNow() async {
    await _checkRentDueNotifications();
  }

  bool get isRunning => _isRunning;
}

/// Riverpod provider for the notification scheduler
final notificationSchedulerProvider = Provider<NotificationScheduler>((ref) {
  return NotificationScheduler(
    ref.read(notificationServiceProvider),
    ref.read(rentalRequestServiceProvider),
    ref.read(rentalPaymentServiceProvider),
    ref.read(shopServiceProvider),
  );
});

/// Provider to manage scheduler lifecycle
final schedulerManagerProvider = Provider<SchedulerManager>((ref) {
  return SchedulerManager(ref.read(notificationSchedulerProvider));
});

class SchedulerManager {
  final NotificationScheduler _scheduler;
  
  SchedulerManager(this._scheduler);
  
  void startScheduler() {
    _scheduler.start();
  }
  
  void stopScheduler() {
    _scheduler.stop();
  }
  
  Future<void> checkNow() async {
    await _scheduler.checkNow();
  }
  
  bool get isRunning => _scheduler.isRunning;
}