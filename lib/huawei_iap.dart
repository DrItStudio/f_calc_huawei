import 'package:flutter/services.dart';

/// Класс для работы с покупками Huawei In-App Purchases
class HuaweiIap {
  static const MethodChannel _channel = MethodChannel('huawei_iap');

  /// Идентификаторы продуктов для подписок
  static const String monthlySubscriptionId = 'monthly_subscription';
  static const String yearlySubscriptionId = 'yearly_subscription';

  /// Кэш информации о продуктах
  static final Map<String, Product> _productsCache = {};

  /// Покупка подписки
  ///
  /// [productId] - идентификатор продукта (подписки)
  /// Возвращает информацию о покупке в случае успеха или выбрасывает исключение при ошибке
  static Future<Map<String, dynamic>> buySubscription(String productId) async {
    try {
      final result = await _channel
          .invokeMethod('buySubscription', {'productId': productId});
      if (result is Map) {
        return Map<String, dynamic>.from(result);
      } else {
        throw PlatformException(
          code: 'UNEXPECTED_RESULT',
          message: 'Unexpected result format from native code',
        );
      }
    } on PlatformException catch (e) {
      // Обработка специфических ошибок
      if (e.code == 'PRODUCT_ALREADY_OWNED') {
        // Пользователь уже владеет этим продуктом
        throw PurchaseException(
            code: PurchaseErrorCode.alreadyOwned,
            message: 'You already own this subscription');
      } else if (e.code == 'PURCHASE_CANCELED') {
        // Пользователь отменил покупку
        throw PurchaseException(
            code: PurchaseErrorCode.canceled, message: 'Purchase was canceled');
      } else {
        // Другие ошибки
        throw PurchaseException(
            code: PurchaseErrorCode.failed,
            message: e.message ?? 'Purchase failed');
      }
    }
  }

  /// Проверка статуса подписок
  ///
  /// Возвращает список активных подписок
  static Future<List<Subscription>> checkSubscriptionStatus() async {
    try {
      final result = await _channel.invokeMethod('checkSubscriptionStatus');
      if (result is List) {
        // Преобразуем результат в список подписок
        return result
            .map(
                (item) => Subscription.fromMap(Map<String, dynamic>.from(item)))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error checking subscription status: $e');
      return [];
    }
  }

  /// Проверяет, активна ли какая-либо подписка
  static Future<bool> hasActiveSubscription() async {
    final subscriptions = await checkSubscriptionStatus();
    return subscriptions.any((subscription) => subscription.active);
  }

  /// Получает информацию о продуктах из HMS IAP
  ///
  /// [productIds] - список идентификаторов продуктов
  /// Возвращает список объектов [Product] с информацией о продуктах
  static Future<List<Product>> getProductsInfo(List<String> productIds) async {
    try {
      // Если в кэше уже есть все запрошенные продукты, возвращаем их
      if (productIds.every((id) => _productsCache.containsKey(id))) {
        return productIds.map((id) => _productsCache[id]!).toList();
      }

      final result = await _channel.invokeMethod('getProductsInfo', {
        'productIds': productIds,
      });

      if (result is List) {
        final products = result
            .map((item) => Product.fromMap(Map<String, dynamic>.from(item)))
            .toList();

        // Обновляем кэш
        for (var product in products) {
          _productsCache[product.productId] = product;
        }

        return products;
      } else {
        return [];
      }
    } catch (e) {
      print('Error getting products info: $e');
      return [];
    }
  }

  /// Получает информацию о конкретном продукте
  ///
  /// [productId] - идентификатор продукта
  /// Возвращает объект [Product] с информацией о продукте или null, если продукт не найден
  static Future<Product?> getProductInfo(String productId) async {
    final products = await getProductsInfo([productId]);
    return products.isNotEmpty ? products.first : null;
  }
}

/// Класс для представления информации о подписке
class Subscription {
  final String productId;
  final String purchaseToken;
  final int purchaseTime;
  final int expirationDate;
  final bool active;

  Subscription({
    required this.productId,
    required this.purchaseToken,
    required this.purchaseTime,
    required this.expirationDate,
    required this.active,
  });

  factory Subscription.fromMap(Map<String, dynamic> map) {
    return Subscription(
      productId: map['productId'] ?? '',
      purchaseToken: map['purchaseToken'] ?? '',
      purchaseTime: map['purchaseTime'] ?? 0,
      expirationDate: map['expirationDate'] ?? 0,
      active: map['active'] ?? false,
    );
  }
}

/// Коды ошибок для покупок
enum PurchaseErrorCode {
  failed,
  canceled,
  alreadyOwned,
}

/// Исключение для ошибок покупки
class PurchaseException implements Exception {
  final PurchaseErrorCode code;
  final String message;

  PurchaseException({
    required this.code,
    required this.message,
  });

  @override
  String toString() => 'PurchaseException: $message (code: $code)';
}

/// Класс для представления информации о продукте
class Product {
  final String productId;
  final int priceType;
  final String price;
  final int microsPrice;
  final String currency;
  final String productName;
  final String productDesc;
  final SubscriptionInfo subscriptionInfo;

  Product({
    required this.productId,
    required this.priceType,
    required this.price,
    required this.microsPrice,
    required this.currency,
    required this.productName,
    required this.productDesc,
    required this.subscriptionInfo,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    var subInfo = map['subscriptionInfo'] as Map<String, dynamic>? ?? {};

    return Product(
      productId: map['productId'] ?? '',
      priceType: map['priceType'] ?? 0,
      price: map['price'] ?? '',
      microsPrice: map['microsPrice'] ?? 0,
      currency: map['currency'] ?? '',
      productName: map['productName'] ?? '',
      productDesc: map['productDesc'] ?? '',
      subscriptionInfo: SubscriptionInfo.fromMap(subInfo),
    );
  }

  String get formattedPrice => price;

  /// Возвращает строку с описанием периода подписки (например, "Monthly" или "Yearly")
  String get periodText {
    if (productId.contains('monthly')) return 'Monthly';
    if (productId.contains('yearly')) return 'Yearly';
    return subscriptionInfo.subscriptionPeriod;
  }
}

/// Информация о подписке
class SubscriptionInfo {
  final String subscriptionPeriod;
  final String introductoryPrice;
  final String introductoryPricePeriod;
  final int introductoryPriceCycles;

  SubscriptionInfo({
    required this.subscriptionPeriod,
    required this.introductoryPrice,
    required this.introductoryPricePeriod,
    required this.introductoryPriceCycles,
  });

  factory SubscriptionInfo.fromMap(Map<String, dynamic> map) {
    return SubscriptionInfo(
      subscriptionPeriod: map['subscriptionPeriod'] ?? '',
      introductoryPrice: map['introductoryPrice'] ?? '',
      introductoryPricePeriod: map['introductoryPricePeriod'] ?? '',
      introductoryPriceCycles: map['introductoryPriceCycles'] ?? 0,
    );
  }
}
