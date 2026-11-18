import 'package:flutter/foundation.dart';

final profileUpdates = ValueNotifier<int>(0);

void notifyProfileUpdated() => profileUpdates.value++;
