import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/records.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ---------------- Technology Transfer ----------------

  static Future<DocumentReference<Map<String, dynamic>>> addTechnologyTransfer(
      Map<String, dynamic> data) {
    return _db.collection('technology_transfers').add(data);
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> streamTechnologyTransfers() {
    return _db
        .collection('technology_transfers')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  static Future<void> updateTechnologyTransfer(String docId, Map<String, dynamic> data) {
    return _db.collection('technology_transfers').doc(docId).update(data);
  }

  static Future<void> deleteTechnologyTransfer(String docId) {
    return _db.collection('technology_transfers').doc(docId).delete();
  }

  // ---------------- Programs ----------------

  static Future<DocumentReference<Map<String, dynamic>>> addProgram(
      Map<String, dynamic> data) {
    return _db.collection('programs').add(data);
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> streamPrograms() {
    return _db
        .collection('programs')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  static Future<void> updateProgram(String docId, Map<String, dynamic> data) {
    return _db.collection('programs').doc(docId).update(data);
  }

  static Future<void> deleteProgram(String docId) {
    return _db.collection('programs').doc(docId).delete();
  }

  // ---------------- Projects ----------------

  static Future<DocumentReference<Map<String, dynamic>>> addProject(
      Map<String, dynamic> data) {
    return _db.collection('projects').add(data);
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> streamProjects() {
    return _db
        .collection('projects')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  static Future<void> updateProject(String docId, Map<String, dynamic> data) {
    return _db.collection('projects').doc(docId).update(data);
  }

  static Future<void> deleteProject(String docId) {
    return _db.collection('projects').doc(docId).delete();
  }

  // ---------------- Activities ----------------

  static Future<DocumentReference<Map<String, dynamic>>> addActivity(
      Map<String, dynamic> data) {
    return _db.collection('activities').add(data);
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> streamActivities() {
    return _db
        .collection('activities')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  static Future<void> updateActivity(String docId, Map<String, dynamic> data) {
    return _db.collection('activities').doc(docId).update(data);
  }

  static Future<void> deleteActivity(String docId) {
    return _db.collection('activities').doc(docId).delete();
  }

  static List<QueryDocumentSnapshot<Map<String, dynamic>>> _sortedByCreatedAt(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    docs.sort((a, b) {
      final ta = a.data()['createdAt'];
      final tb = b.data()['createdAt'];
      if (ta is Timestamp && tb is Timestamp) return tb.compareTo(ta);
      if (ta is Timestamp) return -1;
      if (tb is Timestamp) return 1;
      return 0;
    });
    return docs;
  }

  static Future<void> loadAllRecordsIntoStorage() async {
    RecordStorage.clearAll();

    // ---- Technology Transfers ----
    final techSnap = await _db.collection('technology_transfers').get();
    for (final doc in _sortedByCreatedAt(techSnap.docs)) {
      final data = Map<String, dynamic>.from(doc.data());
      RecordStorage.techTransfers.add(TechTransferRecord(data, docId: doc.id));
    }

    // ---- Programs ----
    final programSnap = await _db.collection('programs').get();
    for (final doc in _sortedByCreatedAt(programSnap.docs)) {
      final data = Map<String, dynamic>.from(doc.data());
      final id = (data['Program ID'] as String?) ?? doc.id;
      RecordStorage.ensureCountersAtLeast(programId: id);
      RecordStorage.programs.add(ProgramRecord(data, id: id, docId: doc.id));
    }


    final projectSnap = await _db.collection('projects').get();
    final orphanProjects = <ProjectRecord>[];
    for (final doc in _sortedByCreatedAt(projectSnap.docs)) {
      final data = Map<String, dynamic>.from(doc.data());
      final id = (data['Project ID'] as String?) ?? doc.id;
      RecordStorage.ensureCountersAtLeast(projectId: id);
      final project = ProjectRecord(data, id: id, docId: doc.id);

      final parentId = (data['Parent Program ID'] ?? '').toString();
      ProgramRecord? parent;
      for (final program in RecordStorage.programs) {
        if (program.id == parentId) {
          parent = program;
          break;
        }
      }
      if (parent != null) {
        parent.projects.add(project);
      } else {
        orphanProjects.add(project);
      }
    }
    if (orphanProjects.isNotEmpty) {
      final standalone = ProgramRecord({
        "Program Title": "Standalone Projects",
        "type": "Program",
      });
      standalone.projects.addAll(orphanProjects);
      RecordStorage.programs.add(standalone);
    }

    // ---- Activities (re-attach to their parent project by stored ID) ----
    final activitySnap = await _db.collection('activities').get();
    final orphanActivities = <ActivityRecord>[];
    for (final doc in _sortedByCreatedAt(activitySnap.docs)) {
      final data = Map<String, dynamic>.from(doc.data());
      final id = (data['Activity ID'] as String?) ?? doc.id;
      RecordStorage.ensureCountersAtLeast(activityId: id);
      final activity = ActivityRecord(data, id: id, docId: doc.id);

      final parentId = (data['Parent Project ID'] ?? '').toString();
      ProjectRecord? parent;
      outer:
      for (final program in RecordStorage.programs) {
        for (final project in program.projects) {
          if (project.id == parentId) {
            parent = project;
            break outer;
          }
        }
      }
      if (parent != null) {
        parent.activities.add(activity);
      } else {
        orphanActivities.add(activity);
      }
    }
    if (orphanActivities.isNotEmpty) {
      final standaloneProgram = ProgramRecord({
        "Program Title": "Standalone Activities",
        "type": "Program",
      });
      final standaloneProject = ProjectRecord({
        "Project Title": "General Activities",
        "type": "Project",
      });
      standaloneProject.activities.addAll(orphanActivities);
      standaloneProgram.projects.add(standaloneProject);
      RecordStorage.programs.add(standaloneProgram);
    }
  }
}

