@JS('Telegram.WebApp')
library telegram_webapp;

import 'package:js/js.dart';

@JS()
class TelegramWebAppUser {
  external int get id;
  external String get first_name;
  external String get last_name;
  external String get username;
}

@JS('initDataUnsafe')
external TelegramInitData get initDataUnsafe;

@JS()
@anonymous
class TelegramInitData {
  external TelegramWebAppUser? get user;
} 