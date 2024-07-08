import 'package:flutter/material.dart';

class FilterProvider with ChangeNotifier {
  RangeValues _ageRange = RangeValues(0, 100);

  RangeValues get ageRange => _ageRange;

  set ageRange(RangeValues range) {
    _ageRange = range;
    notifyListeners();
  }

  void setAgeRange(RangeValues range) {
    _ageRange = range;
    notifyListeners();
  }
}
