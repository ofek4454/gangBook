class TimeLeft {
  String timeLeft(DateTime date) {
    String retVal = '';
    Duration _timeUntil = date.difference(DateTime.now());

    int _daysUntil = _timeUntil.inDays;
    int _hoursUntil = _timeUntil.inHours - (_daysUntil * 24);
    int _minUntil =
        _timeUntil.inMinutes - (_daysUntil * 24 * 60) - (_hoursUntil * 60);

    if (_daysUntil > 0) {
      retVal = _daysUntil.toString() +
          " days, " +
          _hoursUntil.toString() +
          " hours, " +
          _minUntil.toString() +
          " mins";
    } else if (_hoursUntil > 0) {
      retVal =
          _hoursUntil.toString() + " hours " + _minUntil.toString() + " mins";
    } else if (_minUntil > 0) {
      retVal = _minUntil.toString() + " mins";
    } else if (_minUntil == 0) {
      retVal = "almost there ";
    } else {
      retVal = "error";
    }

    return retVal;
  }
}
