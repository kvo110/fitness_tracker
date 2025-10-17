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

    // Table name
    final String workoutsTable = 'workouts';
    final String caloriesTable = 'calories';

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
            version: 1,
            onCreate: _onCreate,
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
    }


    // INSERT FUNCTION: Inserts a new workout entry into the database
    Future<int>  insertWorkout(Map<String, dynamic> workoutData) async {
        final db = await database;
        return await db.insert(workoutsTable, workoutData);
    }

    // INSERT FUNCTION: Inserts a new calories entry into the database
    Future<int> insertCalories(Map<String, dynamic> calorieData) async {
        final db = await database;
        return await db.insert(caloriesTable, calorieData);
    }

    // RETRIEVE FUNCTION: Retrieves all the workout entries from the database
    Future<List<Map<String, dynamic>>> getAllWorkouts() async {
        final db = await database;
        return await db.query(workoutsTable, orderBy: 'date_time DESC');
    }

    // RETRIEVE FUNCTION: Retrieves all the calorie entries from the database
    Future<List<Map<String, dynamic>>> getAllCalories() async {
        final db = await database;
        return await db.query(caloriesTable, orderBy: 'date_time DESC');
    }
}