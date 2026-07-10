import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/records.dart';

class ViewRecordsPage extends StatefulWidget {
  const ViewRecordsPage({super.key});

  @override
  State<ViewRecordsPage> createState() => _ViewRecordsPageState();
}

class _ViewRecordsPageState extends State<ViewRecordsPage> {
  @override
  Widget build(BuildContext context) {
    final hasPrograms = RecordStorage.programs.isNotEmpty;
    final hasTechTransfers = RecordStorage.techTransfers.isNotEmpty;

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: const Text("View Records"),
        centerTitle: true,
        backgroundColor: kSidebar,
      ),

      body: (!hasPrograms && !hasTechTransfers)
          ? const Center(
              child: Text(
                "No Records Available",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (hasTechTransfers) ...[
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text(
                      "Technology Transfer",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  ...RecordStorage.techTransfers.map(
                    (techTransfer) => Card(
                      color: kCard,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ExpansionTile(
                        initiallyExpanded: false,
                        collapsedIconColor: Colors.white,
                        iconColor: Colors.white,
                        leading: const Icon(
                          Icons.sync_alt,
                          color: Colors.orangeAccent,
                        ),
                        title: Text(
                          techTransfer.data["System Name"] ?? "Technology Transfer",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Text(
                          techTransfer.data["Usage Status"] ?? "",
                          style: const TextStyle(
                            color: Colors.white70,
                          ),
                        ),
                        children: techTransfer.data.entries
                            .map(
                              (entry) => ListTile(
                                title: Text(
                                  entry.key,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  entry.value.toString(),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                  if (hasPrograms) const Divider(color: Colors.white54),
                ],

                ...RecordStorage.programs.map((program) {

                return Card(
                  color: kCard,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ExpansionTile(
                    initiallyExpanded: false,
                    collapsedIconColor: Colors.white,
                    iconColor: Colors.white,

                    leading: const Icon(
                      Icons.folder,
                      color: Colors.amber,
                    ),

                    title: Text(
                      program.data["Program Title"] ?? "Program",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),

                    subtitle: Text(
                      program.data["Status"] ?? "",
                      style: const TextStyle(
                        color: Colors.white70,
                      ),
                    ),

                    children: [

                      // ---------------- PROGRAM DETAILS ----------------

                      ...program.data.entries.map(
                        (entry) => ListTile(
                          title: Text(
                            entry.key,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            entry.value.toString(),
                            style: const TextStyle(
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ),

                      if (program.projects.isNotEmpty)
                        const Divider(color: Colors.white54),

                      // ---------------- PROJECTS ----------------

                      ...program.projects.map(
                        (project) => ExpansionTile(
                          collapsedIconColor: Colors.white,
                          iconColor: Colors.white,

                          leading: const Icon(
                            Icons.folder_open,
                            color: Colors.lightBlueAccent,
                          ),

                          title: Text(
                            project.data["Project Title"] ?? "Project",
                            style: const TextStyle(
                              color: Colors.lightBlueAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          subtitle: Text(
                            project.data["Status"] ?? "",
                            style: const TextStyle(
                              color: Colors.white70,
                            ),
                          ),

                          children: [

                            // PROJECT DETAILS

                            ...project.data.entries.map(
                              (entry) => ListTile(
                                title: Text(
                                  entry.key,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  entry.value.toString(),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                            ),

                            if (project.activities.isNotEmpty)
                              const Divider(color: Colors.white54),

                            // ---------------- ACTIVITIES ----------------

                            ...project.activities.map(
                              (activity) => ExpansionTile(
                                collapsedIconColor: Colors.white,
                                iconColor: Colors.white,

                                leading: const Icon(
                                  Icons.event,
                                  color: Colors.greenAccent,
                                ),

                                title: Text(
                                  activity.data["Activity Title"] ??
                                      "Activity",
                                  style: const TextStyle(
                                    color: Colors.greenAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                subtitle: Text(
                                  activity.data["Status"] ?? "",
                                  style: const TextStyle(
                                    color: Colors.white70,
                                  ),
                                ),

                                children: activity.data.entries
                                    .map(
                                      (entry) => ListTile(
                                        title: Text(
                                          entry.key,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Text(
                                          entry.value.toString(),
                                          style: const TextStyle(
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
                }).toList(),
              ],
            ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: kGold,
        child: const Icon(
          Icons.delete_forever,
          color: Colors.black,
        ),
        onPressed: () {
          if (RecordStorage.programs.isEmpty && RecordStorage.techTransfers.isEmpty) return;

          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("Clear Records"),
              content: const Text(
                "Are you sure you want to delete all saved records?",
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      RecordStorage.programs.clear();
                      RecordStorage.techTransfers.clear();
                    });

                    Navigator.pop(context);
                  },
                  child: const Text("Delete"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}