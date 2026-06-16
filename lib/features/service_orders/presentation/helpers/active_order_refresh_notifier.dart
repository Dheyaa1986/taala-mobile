import 'package:flutter/foundation.dart';

class ActiveOrderRefreshNotifier extends ChangeNotifier {
  void notifyChanged() {
    notifyListeners();
  }
}
