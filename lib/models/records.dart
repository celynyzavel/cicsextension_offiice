class ActivityRecord {
  Map<String, dynamic> data;

  ActivityRecord(this.data);

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