class TimeHelper {
  static int getHours(int durationSeconds) {
    return durationSeconds ~/ 3600;
  }

  static int getRemainingMinutes(int durationSeconds) {
    return (durationSeconds % 3600) ~/ 60;
  }

  static int getRemainingSeconds(int durationSeconds) {
    return durationSeconds % 60;
  }
}
