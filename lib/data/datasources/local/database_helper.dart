import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const String _databaseName = 'sentence_completion.db';
  static const int _databaseVersion = 9;

  static Database? _database;

  static Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        parent_id TEXT,
        emoji TEXT NOT NULL,
        sort_order INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE stems (
        id TEXT PRIMARY KEY,
        text TEXT NOT NULL,
        category_id TEXT NOT NULL,
        keywords TEXT NOT NULL,
        difficulty_level INTEGER NOT NULL,
        is_foundational INTEGER NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE entries (
        id TEXT PRIMARY KEY,
        stem_id TEXT NOT NULL,
        stem_text TEXT NOT NULL,
        completion TEXT NOT NULL,
        created_at TEXT NOT NULL,
        category_id TEXT NOT NULL,
        parent_entry_id TEXT,
        resurface_month INTEGER,
        suggested_stems TEXT,
        pre_mood INTEGER,
        post_mood INTEGER,
        is_favorite INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (stem_id) REFERENCES stems (id),
        FOREIGN KEY (category_id) REFERENCES categories (id),
        FOREIGN KEY (parent_entry_id) REFERENCES entries (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE resurfacing_schedule (
        id TEXT PRIMARY KEY,
        entry_id TEXT NOT NULL,
        scheduled_date TEXT NOT NULL,
        completed INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (entry_id) REFERENCES entries (id)
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_entries_created_at ON entries (created_at)
    ''');

    await db.execute('''
      CREATE INDEX idx_entries_category_id ON entries (category_id)
    ''');

    await db.execute('''
      CREATE INDEX idx_resurfacing_scheduled_date ON resurfacing_schedule (scheduled_date)
    ''');

    await db.execute('''
      CREATE TABLE saved_stems (
        id TEXT PRIMARY KEY,
        stem_id TEXT NOT NULL,
        stem_text TEXT NOT NULL,
        category_id TEXT NOT NULL,
        saved_at TEXT NOT NULL,
        source_entry_id TEXT
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_saved_stems_saved_at ON saved_stems (saved_at)
    ''');

    await db.execute('''
      CREATE TABLE stem_ratings (
        id TEXT PRIMARY KEY,
        stem_id TEXT NOT NULL,
        rating INTEGER NOT NULL,
        entry_id TEXT,
        rated_at TEXT NOT NULL,
        FOREIGN KEY (stem_id) REFERENCES stems (id),
        FOREIGN KEY (entry_id) REFERENCES entries (id)
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_stem_ratings_stem_id ON stem_ratings (stem_id)
    ''');

    await db.execute('''
      CREATE TABLE goals (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        target INTEGER NOT NULL,
        period TEXT NOT NULL,
        created_at TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE goal_progress (
        id TEXT PRIMARY KEY,
        goal_id TEXT NOT NULL,
        period_start TEXT NOT NULL,
        period_end TEXT NOT NULL,
        achieved INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (goal_id) REFERENCES goals (id)
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_goal_progress_goal_id ON goal_progress (goal_id)
    ''');

    await db.execute('''
      CREATE TABLE entry_reactions (
        id TEXT PRIMARY KEY,
        entry_id TEXT NOT NULL,
        reaction_type TEXT NOT NULL,
        note TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (entry_id) REFERENCES entries (id)
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_reactions_entry_id ON entry_reactions (entry_id)
    ''');

    await db.execute('''
      CREATE TABLE deleted_entries (
        id TEXT PRIMARY KEY,
        original_id TEXT NOT NULL,
        stem_id TEXT NOT NULL,
        stem_text TEXT NOT NULL,
        completion TEXT NOT NULL,
        created_at TEXT NOT NULL,
        deleted_at TEXT NOT NULL,
        category_id TEXT NOT NULL,
        parent_entry_id TEXT,
        resurface_month INTEGER,
        suggested_stems TEXT,
        pre_mood INTEGER,
        post_mood INTEGER,
        is_favorite INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_deleted_entries_deleted_at ON deleted_entries (deleted_at)
    ''');
  }

  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE saved_stems (
          id TEXT PRIMARY KEY,
          stem_id TEXT NOT NULL,
          stem_text TEXT NOT NULL,
          category_id TEXT NOT NULL,
          saved_at TEXT NOT NULL,
          source_entry_id TEXT
        )
      ''');

      await db.execute('''
        CREATE INDEX idx_saved_stems_saved_at ON saved_stems (saved_at)
      ''');
    }

    if (oldVersion < 3) {
      await db.execute('''
        ALTER TABLE entries ADD COLUMN suggested_stems TEXT
      ''');
    }

    if (oldVersion < 4) {
      await db.execute('ALTER TABLE entries ADD COLUMN pre_mood INTEGER');
      await db.execute('ALTER TABLE entries ADD COLUMN post_mood INTEGER');
    }

    if (oldVersion < 5) {
      await db.execute(
        'ALTER TABLE entries ADD COLUMN is_favorite INTEGER NOT NULL DEFAULT 0',
      );
      await db.execute(
        'CREATE INDEX idx_entries_favorite ON entries (is_favorite)',
      );
    }

    if (oldVersion < 6) {
      await db.execute('''
        CREATE TABLE stem_ratings (
          id TEXT PRIMARY KEY,
          stem_id TEXT NOT NULL,
          rating INTEGER NOT NULL,
          entry_id TEXT,
          rated_at TEXT NOT NULL,
          FOREIGN KEY (stem_id) REFERENCES stems (id),
          FOREIGN KEY (entry_id) REFERENCES entries (id)
        )
      ''');
      await db.execute(
        'CREATE INDEX idx_stem_ratings_stem_id ON stem_ratings (stem_id)',
      );
    }

    if (oldVersion < 7) {
      await db.execute('''
        CREATE TABLE goals (
          id TEXT PRIMARY KEY,
          type TEXT NOT NULL,
          target INTEGER NOT NULL,
          period TEXT NOT NULL,
          created_at TEXT NOT NULL,
          is_active INTEGER NOT NULL DEFAULT 1
        )
      ''');
      await db.execute('''
        CREATE TABLE goal_progress (
          id TEXT PRIMARY KEY,
          goal_id TEXT NOT NULL,
          period_start TEXT NOT NULL,
          period_end TEXT NOT NULL,
          achieved INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY (goal_id) REFERENCES goals (id)
        )
      ''');
      await db.execute(
        'CREATE INDEX idx_goal_progress_goal_id ON goal_progress (goal_id)',
      );
    }

    if (oldVersion < 8) {
      await db.execute('''
        CREATE TABLE entry_reactions (
          id TEXT PRIMARY KEY,
          entry_id TEXT NOT NULL,
          reaction_type TEXT NOT NULL,
          note TEXT,
          created_at TEXT NOT NULL,
          FOREIGN KEY (entry_id) REFERENCES entries (id)
        )
      ''');
      await db.execute(
        'CREATE INDEX idx_reactions_entry_id ON entry_reactions (entry_id)',
      );
    }

    if (oldVersion < 9) {
      await db.execute('''
        CREATE TABLE deleted_entries (
          id TEXT PRIMARY KEY,
          original_id TEXT NOT NULL,
          stem_id TEXT NOT NULL,
          stem_text TEXT NOT NULL,
          completion TEXT NOT NULL,
          created_at TEXT NOT NULL,
          deleted_at TEXT NOT NULL,
          category_id TEXT NOT NULL,
          parent_entry_id TEXT,
          resurface_month INTEGER,
          suggested_stems TEXT,
          pre_mood INTEGER,
          post_mood INTEGER,
          is_favorite INTEGER NOT NULL DEFAULT 0
        )
      ''');
      await db.execute(
        'CREATE INDEX idx_deleted_entries_deleted_at ON deleted_entries (deleted_at)',
      );
    }
  }

  static Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
