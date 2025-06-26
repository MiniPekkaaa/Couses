@JS('Telegram.WebApp')
library telegram_webapp;

import 'package:js/js.dart';

@JS()
class TelegramWebAppUser {
  external int get id;
}

@JS('initDataUnsafe')
external TelegramInitData get initDataUnsafe;

@JS('Telegram.WebApp')
external TelegramWebApp get webApp;

@JS()
@anonymous
class TelegramWebApp {
  external TelegramInitData get initDataUnsafe;
  external String get initData;
}

@JS()
@anonymous
class TelegramInitData {
  external TelegramWebAppUser? get user;
} 