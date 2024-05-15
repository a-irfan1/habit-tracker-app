import 'package:flutter/material.dart';
import 'package:flutter_isar_habit_tracker/components/habit_tile.dart';
import 'package:flutter_isar_habit_tracker/components/heat_map_for_habits.dart';
import 'package:flutter_isar_habit_tracker/components/menu_drawer.dart';
import 'package:flutter_isar_habit_tracker/database/habit_database.dart';
import 'package:flutter_isar_habit_tracker/utils/habit_util.dart';
import 'package:provider/provider.dart';

import '../models/habit.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController textController = TextEditingController();

  void createNewHabit() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            hintText: "Create a new habit",
          ),
        ),
        actions: [
          MaterialButton(
            onPressed: () {
              String newHabitName = textController.text;
              context.read<HabitDatabase>().addHabit(newHabitName);
              Navigator.pop(context);
              textController.clear();
            },
            child: const Text('Save'),
          ),
          MaterialButton(
            onPressed: () {
              Navigator.pop(context);
              textController.clear();
            },
            child: const Text('Cancel'),
          )
        ],
      ),
    );
  }

  void editHabitDialog(Habit habit) {
    textController.text = habit.name;
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: TextField(
                controller: textController,
              ),
              actions: [
                MaterialButton(
                  onPressed: () {
                    String newHabitName = textController.text;
                    context
                        .read<HabitDatabase>()
                        .updateHabitName(habit.id, newHabitName);
                    Navigator.pop(context);
                    textController.clear();
                  },
                  child: const Text('Save'),
                ),
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                    textController.clear();
                  },
                  child: const Text('Cancel'),
                )
              ],
            ));
  }

  void deleteHabitDialog(Habit habit) {
    textController.text = habit.name;
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Are you sure you want to delete this habit?'),
              actions: [
                MaterialButton(
                  onPressed: () {
                    context.read<HabitDatabase>().deleteHabit(
                          habit.id,
                        );
                    Navigator.pop(context);
                  },
                  child: const Text('Delete'),
                ),
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                )
              ],
            ));
  }

  @override
  void initState() {
    Provider.of<HabitDatabase>(context, listen: false).readHabits();

    super.initState();
  }

  void checkHabitDoneCheckbox(bool? value, Habit habit) {
    if (value != null) {
      context.read<HabitDatabase>().updateDone(habit.id, value);
    }
  }

  Widget buildHabitList() {
    final habitDatabase = context.watch<HabitDatabase>();
    List<Habit> currentHabits = habitDatabase.currentHabits;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: currentHabits.length,
      itemBuilder: (context, index) {
        final habit = currentHabits[index];
        bool isDoneToday = isHabitDoneToday(habit.doneDays);
        return HabitTile(
          isDone: isDoneToday,
          text: habit.name,
          onChanged: (value) => checkHabitDoneCheckbox(value, habit),
          editHabit: (context) => editHabitDialog(habit),
          deleteHabit: (context) => deleteHabitDialog(habit),
        );
      },
    );
  }

  Widget buildHeatMap() {
    final habitDatabase = context.watch<HabitDatabase>();
    List<Habit> currentHabits = HabitDatabase().currentHabits;

    return FutureBuilder<DateTime?>(
      future: habitDatabase.getFirstDate(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return HabitHeatMap(
            startDate: snapshot.data!,
            datasets: prepareHeatMapDataset(currentHabits),
          );
        } else {
          return Container();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: const MenuDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          createNewHabit();
        },
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        child: const Icon(Icons.add),
      ),
      body: ListView(
        children: [buildHeatMap(), buildHabitList()],
      ),
    );
  }
}
