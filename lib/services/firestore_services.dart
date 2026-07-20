import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/records.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;


  static Future<DocumentReference<Map<String, dynamic>>> addTechnologyTransfer(
      Map<String, dynamic> data, {String? docId}) async {
    final ref = docId != null
        ? _db.collection('Technology Transfer').doc(docId)
        : _db.collection('Technology Transfer').doc();
    await ref.set(data);
    return ref;
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> streamTechnologyTransfers() {
    return _db
        .collection('Technology Transfer')
        .snapshots();
  }

  static Future<void> updateTechnologyTransfer(String docId, Map<String, dynamic> data) {

    return _db.collection('Technology Transfer').doc(docId).set(data, SetOptions(merge: true));
  }


  static Future<void> deleteTechnologyTransfer(String docId) {
    return _db.collection('Technology Transfer').doc(docId).delete();
  }



  static Future<DocumentReference<Map<String, dynamic>>> addProgram(
      Map<String, dynamic> data, {String? docId}) async {
    final ref = docId != null
        ? _db.collection('Programs').doc(docId)
        : _db.collection('Programs').doc();
    await ref.set(data);
    return ref;
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> streamPrograms() {
    return _db
        .collection('Programs')
        .snapshots();
  }

  static Future<void> updateProgram(String docId, Map<String, dynamic> data) {

    return _db.collection('Programs').doc(docId).set(data, SetOptions(merge: true));
  }

  static Future<void> deleteProgram(String docId) {
    return _db.collection('Programs').doc(docId).delete();
  }


  static Future<DocumentReference<Map<String, dynamic>>> addProject(
      Map<String, dynamic> data, {String? docId}) async {
    final ref = docId != null
        ? _db.collection('Projects').doc(docId)
        : _db.collection('Projects').doc();
    await ref.set(data);
    return ref;
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> streamProjects() {
    return _db
        .collection('Projects')
        .snapshots();
  }

  static Future<void> updateProject(String docId, Map<String, dynamic> data) {
    return _db.collection('Projects').doc(docId).set(data, SetOptions(merge: true));
  }

  static Future<void> deleteProject(String docId) {
    return _db.collection('Projects').doc(docId).delete();
  }



  static Future<DocumentReference<Map<String, dynamic>>> addActivity(
      Map<String, dynamic> data, {String? docId}) async {
    final ref = docId != null
        ? _db.collection('Activities').doc(docId)
        : _db.collection('Activities').doc();
    await ref.set(data);
    return ref;
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> streamActivities() {
    return _db
        .collection('Activities')
        .snapshots();
  }

  static Future<void> updateActivity(String docId, Map<String, dynamic> data) {
    return _db.collection('Activities').doc(docId).set(data, SetOptions(merge: true));
  }

  static Future<void> deleteActivity(String docId) {
    return _db.collection('Activities').doc(docId).delete();
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

    final techSnap = await _db.collection('Technology Transfer').get();
    for (final doc in _sortedByCreatedAt(techSnap.docs)) {
      final data = Map<String, dynamic>.from(doc.data());
      final id = (data['Technology Transfer ID'] as String?) ?? doc.id;
      RecordStorage.ensureCountersAtLeast(techTransferId: id);
      RecordStorage.techTransfers.add(TechTransferRecord(data, id: id, docId: doc.id));
    }

    final programSnap = await _db.collection('Programs').get();
    for (final doc in _sortedByCreatedAt(programSnap.docs)) {
      final data = Map<String, dynamic>.from(doc.data());
      final id = (data['Program ID'] as String?) ?? doc.id;
      RecordStorage.ensureCountersAtLeast(programId: id);
      RecordStorage.programs.add(ProgramRecord(data, id: id, docId: doc.id));
    }


    final projectSnap = await _db.collection('Projects').get();
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

    final activitySnap = await _db.collection('Activities').get();
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