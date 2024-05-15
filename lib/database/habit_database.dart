import 'package:flutter/cupertino.dart';
import 'package:flutter_isar_habit_tracker/models/app_settings.dart';
import 'package:flutter_isar_habit_tracker/models/habit.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class HabitDatabase extends ChangeNotifier {
  static late Isar isar;

  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar =
        await Isar.open([HabitSchema, AppSettingsSchema], directory: dir.path);
  }

  Future<void> saveFirstDate() async {
    final existingSettings = await isar.appSettings.where().findFirst();
    if (existingSettings == null) {
      final settings = AppSettings()..firstDate = DateTime.now();
      await isar.writeTxn(() => isar.appSettings.put(settings));
    }
  }

  Future<DateTime?> getFirstDate() async {
    final settings = await isar.appSettings.where().findFirst();
    return settings?.firstDate;
  }

  final List<Habit> currentHabits = [];

  Future<void> addHabit(String habitName) async {
    final newHabit = Habit()..name = habitName;

    await isar.writeTxn(() => isar.habits.put(newHabit));
    readHabits();
  }

  Future<void> readHabits() async {
    List<Habit> fetchedHabits = await isar.habits.where().findAll();
    currentHabits.clear();
    currentHabits.addAll(fetchedHabits);
    notifyListeners();
  }

  Future<void> updateDone(int id, bool isDone) async {
    final habit = await isar.habits.get(id);
    if (habit != null) {
      await isar.writeTxn(
        () async {
          if (isDone && !habit.doneDays.contains((DateTime.now()))) {
            final today = DateTime.now();
            habit.doneDays.add(
              DateTime(
                today.year,
                today.month,
                today.day,
              ),
            );
          } else {
            habit.doneDays.removeWhere(
              (date) =>
                  date.year == DateTime.now().year &&
                  date.month == DateTime.now().month &&
                  date.day == DateTime.now().day,
            );
          }
          await isar.habits.put(habit);
        },
      );
    }
    readHabits();
  }

  Future<void> updateHabitName(int id, String newName) async {
    final habit = await isar.habits.get(id);
    if (habit != null) {
      await isar.writeTxn(
        () async {
          habit.name = newName;
          await isar.habits.put(habit);
        },
      );
    }
    readHabits();
  }

  Future<void> deleteHabit(int id) async {
    await isar.writeTxn(
      () async {
        await isar.habits.delete(id);
      },
    );
    readHabits();
  }
}
