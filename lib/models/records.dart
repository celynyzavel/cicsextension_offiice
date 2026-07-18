class RecordStorage {
  static List<ProgramRecord> programs = [];
  static List<TechTransferRecord> techTransfers = [];

  // Running counters — these only ever increase, so IDs stay unique
  // even if records are later removed from the lists.
  static int _programCounter = 0;
  static int _projectCounter = 0;
  static int _activityCounter = 0;

  static String nextProgramId() =>
      'PRG-${(++_programCounter).toString().padLeft(4, '0')}';
  static String nextProjectId() =>
      'PRJ-${(++_projectCounter).toString().padLeft(4, '0')}';
  static String nextActivityId() =>
      'ACT-${(++_activityCounter).toString().padLeft(4, '0')}';
}

class ActivityRecord {
  /// Auto-generated, e.g. ACT-0001. Never entered manually.
  final String id;
  Map<String, dynamic> data;

  ActivityRecord(this.data) : id = RecordStorage.nextActivityId() {
    data['Activity ID'] = id;
  }

  double? get avgPreTestScore =>
      double.tryParse((data['Avg Pre-Test Score (%)'] ?? '').toString());

  double? get avgPostTestScore =>
      double.tryParse((data['Avg Post-Test Score (%)'] ?? '').toString());

  /// Derived — never manually entered.
  double? get knowledgeGain {
    final pre = avgPreTestScore;
    final post = avgPostTestScore;
    if (pre == null || post == null) return null;
    return post - pre;
  }
}

class ProjectRecord {
  /// Auto-generated, e.g. PRJ-0001. Never entered manually.
  final String id;
  Map<String, dynamic> data;
  List<ActivityRecord> activities = [];

  ProjectRecord(this.data) : id = RecordStorage.nextProjectId() {
    data['Project ID'] = id;
  }
}

class ProgramRecord {
  /// Auto-generated, e.g. PRG-0001. Never entered manually.
  final String id;
  Map<String, dynamic> data;
  List<ProjectRecord> projects = [];

  ProgramRecord(this.data) : id = RecordStorage.nextProgramId() {
    data['Program ID'] = id;
  }
}

class TechTransferRecord {
  Map<String, dynamic> data;

  TechTransferRecord(this.data);
<<<<<<< HEAD
}
=======
}
>>>>>>> edd71766970dc99eb81d8f212e0a5fc0a2c72ce8
