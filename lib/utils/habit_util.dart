import '../models/habit.dart';

bool isHabitDoneToday(List<DateTime> doneDays) {
  final today = DateTime.now();
  return doneDays.any(
    (date) =>
        date.year == today.year &&
        date.month == today.month &&
        date.day == today.day,
  );
}

Map<DateTime, int> prepareHeatMapDataset(List<Habit> habits) {
  Map<DateTime, int> dataset = {};

  for (var habit in habits) {
    for (var date in habit.doneDays) {
      final normalisedDate = DateTime(date.year, date.month, date.day);

      if (dataset.containsKey(normalisedDate)) {
        dataset[normalisedDate] = (dataset[normalisedDate]! + 1);
      } else {
        dataset[normalisedDate] = 1;
      }
    }
  }
  return dataset;
}
