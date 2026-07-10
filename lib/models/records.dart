// ============================================================
// RECORD MODELS — plain data classes with no Flutter/UI
// dependency. These describe *what a record is*, not how it's
// displayed. Keeping them UI-free means they can be unit tested
// without needing a widget test harness.
// ============================================================

class ActivityRecord {
  Map<String, dynamic> data;

  ActivityRecord(this.data);
}

class ProjectRecord {
  Map<String, dynamic> data;
  List<ActivityRecord> activities = [];

  ProjectRecord(this.data);
}

class ProgramRecord {
  Map<String, dynamic> data;
  List<ProjectRecord> projects = [];

  ProgramRecord(this.data);
}

// ============================================================
// TECHNOLOGY TRANSFER RECORD — standalone record type, separate
// from the Program/Project/Activity hierarchy above.
// ============================================================
class TechTransferRecord {
  Map<String, dynamic> data;

  TechTransferRecord(this.data);
}

class RecordStorage {
  static List<ProgramRecord> programs = [];
  static List<TechTransferRecord> techTransfers = [];
}
