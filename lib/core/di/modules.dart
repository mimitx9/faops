import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

@module
abstract class AppModule {
  @preResolve
  @singleton
  Future<SharedPreferences> get sharedPreferences =>
      SharedPreferences.getInstance();

  @singleton
  Logger get logger => Logger(
        printer: PrettyPrinter(
          methodCount: 0,
          errorMethodCount: 8,
          lineLength: 120,
          colors: true,
          printEmojis: true,
        ),
      );
}

