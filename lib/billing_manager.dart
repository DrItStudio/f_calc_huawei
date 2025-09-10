import 'dart:async';
import 'package:flutter/material.dart';
import 'huawei_iap.dart'; // Dart-обертка для работы с HMS IAP

class BillingManager {
  // Конфигурация биллинга
  static const bool PURCHASES_ENABLED =
      true; // Включаем интерфейс покупок для монетизации
  static const bool TEST_MODE = false; // Используем реальный биллинг

  // ID продуктов (используем константы из HuaweiIap)
  static final String monthlyProductId = HuaweiIap.monthlySubscriptionId;
  static final String yearlyProductId = HuaweiIap.yearlySubscriptionId;

  // Состояние менеджера
  static bool _isInitialized = false;
  static bool _hasActiveSubscription = false;
  static List<Subscription>? _activeSubscriptions;
  static Map<String, Product> _products = {};
  static VoidCallback? onSubscriptionChanged;

  /// Инициализация менеджера биллинга
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Проверяем статус подписок при инициализации
      await checkSubscriptionStatus();

      // Получаем информацию о доступных продуктах
      await _loadProductsInfo();

      _isInitialized = true;
      debugPrint('BillingManager initialized successfully');
    } catch (e) {
      debugPrint('Error initializing BillingManager: $e');
      _isInitialized = false;
    }
  }

  /// Загружает информацию о продуктах
  static Future<void> _loadProductsInfo() async {
    try {
      final productsList =
          await HuaweiIap.getProductsInfo([monthlyProductId, yearlyProductId]);

      _products.clear();
      for (var product in productsList) {
        _products[product.productId] = product;
      }

      debugPrint(
          'Loaded ${_products.length} products: ${_products.keys.join(", ")}');
    } catch (e) {
      debugPrint('Error loading products: $e');
    }
  }

  /// Проверка статуса подписок
  static Future<bool> checkSubscriptionStatus() async {
    if (!PURCHASES_ENABLED) {
      debugPrint('Purchases disabled for this version, returning false');
      return false;
    }

    if (TEST_MODE) {
      debugPrint('Test mode active, returning false for subscription status');
      return false;
    }

    try {
      // Получаем список активных подписок
      _activeSubscriptions = await HuaweiIap.checkSubscriptionStatus();
      _hasActiveSubscription = _activeSubscriptions != null &&
          _activeSubscriptions!.any((sub) => sub.active);

      debugPrint(
          'Subscription status: $_hasActiveSubscription (found ${_activeSubscriptions?.length ?? 0} subscriptions)');
      return _hasActiveSubscription;
    } catch (e) {
      debugPrint('Error checking subscription status: $e');
      return false;
    }
  }

  /// Покупка подписки
  static Future<void> buySubscription(String productId) async {
    if (!PURCHASES_ENABLED) {
      debugPrint(
          'Purchases disabled for this version, purchase attempt ignored');
      throw Exception(
          'Subscriptions are not available in this version. Please check for updates later.');
    }

    if (TEST_MODE) {
      debugPrint('Test mode active, simulating purchase flow');
      throw Exception(
          'Payment system is being prepared. This feature will be available in the next update.');
    }

    if (!_isInitialized) {
      await initialize();
      if (!_isInitialized)
        throw Exception('BillingManager could not be initialized');
    }

    try {
      // Выполняем покупку
      final purchaseInfo = await HuaweiIap.buySubscription(productId);
      debugPrint('Purchase successful: ${purchaseInfo['productId']}');

      // Обновляем статус подписки после успешной покупки
      await checkSubscriptionStatus();

      // Оповещаем слушателей об изменении статуса подписки
      if (onSubscriptionChanged != null) onSubscriptionChanged!();
    } on PurchaseException catch (e) {
      debugPrint('Purchase exception: ${e.code} - ${e.message}');

      // Обрабатываем различные типы ошибок покупки
      switch (e.code) {
        case PurchaseErrorCode.alreadyOwned:
          // Пользователь уже владеет этой подпиской
          await checkSubscriptionStatus(); // обновляем статус
          if (onSubscriptionChanged != null) onSubscriptionChanged!();
          break;
        case PurchaseErrorCode.canceled:
          // Пользователь отменил покупку
          break;
        default:
          // Другие ошибки
          rethrow;
      }
      rethrow;
    } catch (e) {
      debugPrint('Error buying subscription: $e');
      rethrow;
    }
  }

  /// Восстановление покупок
  static Future<void> restorePurchases() async {
    debugPrint('Restoring purchases...');
    await checkSubscriptionStatus();
    return;
  }

  /// Получение цены продукта из информации HMS IAP
  static String getProductPrice(String productId) {
    // Проверяем, есть ли информация о продукте в кэше
    if (_products.containsKey(productId)) {
      return _products[productId]!.formattedPrice;
    }

    // Если нет информации, возвращаем заглушку и асинхронно загружаем актуальную информацию
    _loadProductsInfo();

    // Временная заглушка для цены
    if (productId == monthlyProductId) {
      return 'Loading...'; // Будет заменено на реальную цену после загрузки
    } else {
      return 'Loading...';
    }
  }

  /// Получение названия продукта
  static String getProductTitle(String productId) {
    if (_products.containsKey(productId)) {
      final product = _products[productId]!;
      final period = product.periodText;
      return '$period Subscription';
    }

    // Если нет информации, возвращаем заглушку
    return productId == monthlyProductId
        ? 'Monthly Subscription'
        : 'Yearly Subscription';
  }

  /// Получение описания продукта
  static String getProductDescription(String productId) {
    if (_products.containsKey(productId)) {
      return _products[productId]!.productDesc;
    }

    // Если нет информации, возвращаем заглушку
    return 'Premium subscription with all features unlocked';
  }

  /// Проверка инициализации менеджера
  static bool get isInitialized => _isInitialized;

  /// Проверка наличия активной подписки
  static bool get hasActiveSubscription => _hasActiveSubscription;

  /// Получение списка активных подписок
  static List<Subscription>? get activeSubscriptions => _activeSubscriptions;

  /// Обновляет информацию о продуктах
  static Future<void> refreshProductsInfo() async {
    await _loadProductsInfo();
  }

  /// Возвращает список всех доступных продуктов с ценами
  static List<Product> getAvailableProducts() {
    return _products.values.toList();
  }

  /// Очистка ресурсов
  static void dispose() {
    _isInitialized = false;
    _hasActiveSubscription = false;
    _activeSubscriptions = null;
    _products.clear();
    onSubscriptionChanged = null;
    debugPrint('BillingManager disposed');
  }
}
