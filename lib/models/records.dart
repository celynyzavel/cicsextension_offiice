class RecordStorage {
  static List<ProgramRecord> programs = [];
  static List<TechTransferRecord> techTransfers = [];

  static int _programCounter = 0;
  static int _projectCounter = 0;
  static int _activityCounter = 0;
  static int _techTransferCounter = 0;

  static String nextProgramId() =>
      'PRG-${(++_programCounter).toString().padLeft(3, '0')}';
  static String nextProjectId() =>
      'PRJ-${(++_projectCounter).toString().padLeft(3, '0')}';
  static String nextActivityId() =>
      'ACT-${(++_activityCounter).toString().padLeft(3, '0')}';
  static String nextTechTransferId() =>
      'TT-${(++_techTransferCounter).toString().padLeft(3, '0')}';

  static int _numericSuffix(String? id) {
    if (id == null) return 0;
    final match = RegExp(r'(\d+)$').firstMatch(id);
    if (match == null) return 0;
    return int.tryParse(match.group(1)!) ?? 0;
  }

  static void ensureCountersAtLeast({
    String? programId,
    String? projectId,
    String? activityId,
    String? techTransferId,
  }) {
    final p = _numericSuffix(programId);
    final pr = _numericSuffix(projectId);
    final a = _numericSuffix(activityId);
    final t = _numericSuffix(techTransferId);
    if (p > _programCounter) _programCounter = p;
    if (pr > _projectCounter) _projectCounter = pr;
    if (a > _activityCounter) _activityCounter = a;
    if (t > _techTransferCounter) _techTransferCounter = t;
  }

  static void clearAll() {
    programs.clear();
    techTransfers.clear();
  }
}

class ActivityRecord {
  final String id;
  Map<String, dynamic> data;

  String? docId;

  ActivityRecord(this.data, {String? id, this.docId})
      : id = id ?? RecordStorage.nextActivityId() {
    data['Activity ID'] = this.id;
  }

  double? get avgPreTestScore =>
      double.tryParse((data['Avg Pre-Test Score (%)'] ?? '').toString());

  double? get avgPostTestScore =>
      double.tryParse((data['Avg Post-Test Score (%)'] ?? '').toString());

  double? get knowledgeGain {
    final pre = avgPreTestScore;
    final post = avgPostTestScore;
    if (pre == null || post == null) return null;
    return post - pre;
  }
}

class ProjectRecord {

  final String id;
  Map<String, dynamic> data;
  List<ActivityRecord> activities = [];

  String? docId;

  ProjectRecord(this.data, {String? id, this.docId})
      : id = id ?? RecordStorage.nextProjectId() {
    data['Project ID'] = this.id;
  }
}

class ProgramRecord {

  final String id;
  Map<String, dynamic> data;
  List<ProjectRecord> projects = [];


  String? docId;

  ProgramRecord(this.data, {String? id, this.docId})
      : id = id ?? RecordStorage.nextProgramId() {
    data['Program ID'] = this.id;
  }
}

class TechTransferRecord {
  final String id;
  Map<String, dynamic> data;
  String? docId;

  TechTransferRecord(this.data, {String? id, this.docId})
      : id = id ?? RecordStorage.nextTechTransferId() {
    data['Technology Transfer ID'] = this.id;
  }
}
