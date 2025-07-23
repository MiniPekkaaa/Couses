@JS('Telegram.WebApp')
library telegram_webapp;

import 'package:js/js.dart';

@JS()
class TelegramWebAppUser {
  external int get id;
}

@JS('initDataUnsafe')
external TelegramInitData get initDataUnsafe;

@JS()
@anonymous
class TelegramInitData {
  external TelegramWebAppUser? get user;
  external String? get start_param;
} 
