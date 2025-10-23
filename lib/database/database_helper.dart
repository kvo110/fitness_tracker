import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

// Handles the database operations; creating tables, inserting new entries, retrieving data
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  DatabaseHelper._internal();

  static Database? _database;

  // Table names
  final String workoutsTable = 'workouts';
  final String caloriesTable = 'calories';
  final String plansTable = 'plans';
  final String planWorkoutsTable = 'plan_workouts';

  // Initialize and open database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Sets up the database path and opens/creates the file
  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'fitness_app.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // Called only when a new database is created for the first time to define the tables
  Future<void> _onCreate(Database db, int version) async {
    // Workout table stores individual workout entries
    await db.execute(''' 
      CREATE TABLE $workoutsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        exercise TEXT NOT NULL,
        sets INTEGER NOT NULL,
        reps INTEGER NOT NULL,
        duration INTEGER NOT NULL,
        rpe TEXT,
        date_time TEXT NOT NULL
      )
    ''');

    // Calories table that stores the calorie check ins
    await db.execute(''' 
      CREATE TABLE $caloriesTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        calories INTEGER NOT NULL,
        date_time TEXT NOT NULL
      )
    ''');

    // Workout Plans table
    await db.execute(''' 
      CREATE TABLE $plansTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT
      )
    ''');

    // Selected Plan Workouts table
    await db.execute(''' 
      CREATE TABLE $planWorkoutsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        plan_id INTEGER NOT NULL,
        workout_name TEXT NOT NULL,
        sets INTEGER NOT NULL,
        reps INTEGER NOT NULL,
        FOREIGN KEY(plan_id) REFERENCES $plansTable(id) ON DELETE CASCADE
      )
    ''');
  }

  // Upgrades the database to add in new tables
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(''' 
        CREATE TABLE IF NOT EXISTS $plansTable (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          description TEXT
        )
      ''');

      await db.execute(''' 
        CREATE TABLE IF NOT EXISTS $planWorkoutsTable (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          plan_id INTEGER NOT NULL,
          workout_name TEXT NOT NULL,
          sets INTEGER NOT NULL,
          reps INTEGER NOT NULL,
          FOREIGN KEY(plan_id) REFERENCES $plansTable(id) ON DELETE CASCADE
        )
      ''');
    }
  }

  // Functions for workouts
  // INSERT FUNCTION: Inserts a new workout entry into the database
  Future<int> insertWorkout(Map<String, dynamic> workoutData) async {
    final db = await database;
    return await db.insert(workoutsTable, workoutData);
  }

  // RETRIEVE FUNCTION: Retrieves all the workout entries from the database
  Future<List<Map<String, dynamic>>> getAllWorkouts() async {
    final db = await database;
    return await db.query(workoutsTable, orderBy: 'date_time DESC');
  }

  // NEW FUNCTION: Retrieves workout count grouped by date
  Future<List<Map<String, dynamic>>> getWorkoutCountsByDay() async {
    final db = await database;
    // Group workouts by date (ignores time stamp)
    return await db.rawQuery('''
      SELECT
        Date(date_time) as day,
        COUNT(*) as count
      FROM $workoutsTable
      GROUP BY DATE(date_time)
      ORDER BY day ASC
    ''');
  }

  // NEW FUNCTION: Retrieves total workout duration 
  Future<List<Map<String, dynamic>>> getWorkoutDurationByDay() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT
        DATE(date_time) as day,
        SUM(duration) as total_duration
      FROM $workoutsTable
      GROUP BY DATE(date_time)
      ORDER BY day ASC
    ''');
  }

  // NEW FUNCTION: Retrieves avg workout RPE grouped
  Future<List<Map<String, dynamic>>> getAverageRPEByDay() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT
        DATE(date_time) as day,
        AVG(CAST(rpe AS INTEGER)) as avg_rpe
      FROM $workoutsTable
      WHERE rpe IS NOT NULL AND rpe != 'N/A'
      GROUP BY DATE(date_time)
      ORDER BY day ASC
    ''');
  }

  // NEW FUNCTION: Retrieves tracked calorie totals 
  Future<List<Map<String, dynamic>>> getCaloriesByDay() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT
        DATE(date_time) as day,
        SUM(calories) as total_calories
      FROM $caloriesTable
      GROUP BY DATE(date_time)
      ORDER BY day ASC
    ''');
  }

  // Functions for calories
  // INSERT FUNCTION: Inserts a new calories entry into the database
  Future<int> insertCalories(Map<String, dynamic> calorieData) async {
    final db = await database;
    return await db.insert(caloriesTable, calorieData);
  }

  // RETRIEVE FUNCTION: Retrieves all the calorie entries from the database
  Future<List<Map<String, dynamic>>> getAllCalories() async {
    final db = await database;
    return await db.query(caloriesTable, orderBy: 'date_time DESC');
  }


  // Functions for workout plans/selected workout
  // INSERT FUNCTION: Adds a new workout plan
  Future<int> insertPlan(Map<String, dynamic> planData) async {
    final db = await database;
    return await db.insert(plansTable, planData);
  }

  // RETRIEVE FUNCTION: Gets all workout plans
  Future<List<Map<String, dynamic>>> getAllPlans() async {
    final db = await database;
    return await db.query(plansTable, orderBy: 'id DESC');
  }

  // DELETE FUNCTION: Removes a workout plan and its workouts
  Future<int> deletePlan(int planId) async {
    final db = await database;
    await db.delete(planWorkoutsTable, where: 'plan_id = ?', whereArgs: [planId]);
    return await db.delete(plansTable, where: 'id = ?', whereArgs: [planId]);
  }

  // INSERT FUNCTION: Adds a workout to a plan
  Future<int> insertWorkoutToPlan(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(planWorkoutsTable, data);
  }

  // RETRIEVE FUNCTION: Gets all workouts to a specific plan
  Future<List<Map<String, dynamic>>> getWorkoutsForPlan(int planId) async {
    final db = await database;
    return await db.query(
      planWorkoutsTable,
      where: 'plan_id = ?',
      whereArgs: [planId],
      orderBy: 'id DESC',
    );
  }

  // DELETE FUNCTION: Removes a workout from a plan
  Future<int> deleteWorkoutFromPlan(int workoutId) async {
    final db = await database;
    return await db.delete(planWorkoutsTable, where: 'id = ?', whereArgs: [workoutId]);
  }

  // Clears only the workouts table. Used when the user wants a fresh start 
  // without losing calorie or plan data.
  Future<void> clearAllWorkouts() async {
    final db = await database;
    await db.delete(workoutsTable);
    // Helps shrink the database file after deletes
    await db.execute('VACUUM');
  }

  // Clears only the calories table. Keeps the workout logs intact.
  Future<void> clearAllCalories() async {
    final db = await database;
    await db.delete(caloriesTable);
    await db.execute('VACUUM');
  }

  // Clears only the workout plans and associated workouts. This is isolated 
  // from the main workout history so users can keep their logs if they want.
  Future<void> clearAllPlans() async {
    final db = await database;
    await db.delete(planWorkoutsTable);
    await db.delete(plansTable);
    await db.execute('VACUUM');
  }

  // Full reset: wipes everything in one go. Ideal for a total restart or 
  // when the user wants a clean slate.
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete(workoutsTable);
    await db.delete(caloriesTable);
    await db.delete(planWorkoutsTable);
    await db.delete(plansTable);
    await db.execute('VACUUM');
  }
}

