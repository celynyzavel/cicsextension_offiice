
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


class TechTransferRecord {
  Map<String, dynamic> data;

  TechTransferRecord(this.data);
}

class RecordStorage {
  static List<ProgramRecord> programs = [];
  static List<TechTransferRecord> techTransfers = [];
}
