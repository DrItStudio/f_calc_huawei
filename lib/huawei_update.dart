import 'package:flutter/services.dart';

/// Класс для работы с функцией проверки обновлений из Huawei AppGallery
///
/// Этот класс предоставляет простую интеграцию для проверки обновлений,
/// что является обязательным требованием для публикации приложения
/// в Huawei AppGallery.
class HuaweiUpdate {
  static const MethodChannel _channel = MethodChannel('huawei_update');
  static const String _tag = 'HuaweiAppGalleryUpdate';

  /// Проверяет наличие HMS Core и готовность к получению обновлений
  ///
  /// Этот метод является реализацией checkUpdate API, требуемого AppGallery.
  /// Метод проверяет доступность HMS Core и интеграцию с системой обновлений.
  ///
  /// Возвращает строку с результатом проверки:
  /// - "UPDATE_API_AVAILABLE" - API обновлений доступен
  /// - "HMS_CORE_MISSING" - HMS Core отсутствует
  /// - "HMS_CORE_UPDATE_REQUIRED" - требуется обновление HMS Core
  /// - "HMS_CORE_DISABLED" - HMS Core отключен
  /// - "HMS_CORE_NOT_SUPPORTED" - устройство не поддерживает HMS Core
  static Future<String> checkForUpdates() async {
    try {
      print('$_tag: ========================================');
      print('$_tag: CALLING APPGALLERY UPDATE CHECK API');
      print('$_tag: ========================================');

      final String? result = await _channel.invokeMethod('checkForUpdate');

      print('$_tag: checkUpdate API result: $result');

      if (result != null) {
        switch (result) {
          case 'UPDATE_API_AVAILABLE':
            print('$_tag: ✅ AppGallery Update API is fully functional');
            break;
          case 'HMS_CORE_MISSING':
            print('$_tag: ⚠️ HMS Core is missing on this device');
            break;
          case 'HMS_CORE_UPDATE_REQUIRED':
            print('$_tag: ⚠️ HMS Core needs to be updated');
            break;
          case 'HMS_CORE_DISABLED':
            print('$_tag: ⚠️ HMS Core is disabled');
            break;
          case 'HMS_CORE_NOT_SUPPORTED':
            print('$_tag: ⚠️ This device does not support HMS Core');
            break;
          default:
            print('$_tag: ℹ️ checkUpdate API returned: $result');
        }
      }

      print('$_tag: ========================================');

      return result ?? 'NO_RESULT';
    } catch (e) {
      final errorMsg = 'Error in checkUpdate API: $e';
      print('$_tag: ❌ $errorMsg');
      return 'ERROR: $e';
    }
  }

  /// Вызывает проверку обновлений и возвращает успешность операции
  /// Для обратной совместимости
  static Future<bool> checkForUpdatesSimple() async {
    final result = await checkForUpdates();
    return result == 'UPDATE_API_AVAILABLE';
  }
}
