import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app/api_mode.dart';
import 'app/app.dart';
import 'app/flavor.dart';

void main() {
  runApp(
    TripMateApp(
      flavor: AppFlavor.fromName(appFlavor),
      apiMode: ApiMode.current,
    ),
  );
}
