import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app/api_mode.dart';
import 'app/app.dart';
import 'app/flavor.dart';
import 'core/api/api_client.dart';

void main() {
  final flavor = AppFlavor.fromName(appFlavor);
  checkApiConfig(flavor: flavor, mode: ApiMode.current);
  runApp(TripMateApp(flavor: flavor, apiMode: ApiMode.current));
}
