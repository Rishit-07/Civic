import 'package:flutter_web_plugins/url_strategy.dart';

/// Configures HTML5 Path URL strategy on web to eliminate '#' hash-bang routing
void configureUrlStrategy() {
  usePathUrlStrategy();
}
