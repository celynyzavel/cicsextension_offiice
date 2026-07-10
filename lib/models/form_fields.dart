import 'package:flutter/material.dart';

// ============================================================
// FORM FIELD DEFINITIONS — describes the shape of each form
// (Program / Project / Activity) as data, so RecordForm can stay
// generic and render whichever field list it's given.
// ============================================================

enum FieldType { text, number, multiline, date, dropdown }

class FieldSpec {
  final String label;
  final IconData icon;
  final FieldType type;
  final int maxLines;
  final bool optional;
  final List<String> options;
  const FieldSpec(
    this.label,
    this.icon, {
    this.type = FieldType.text,
    this.maxLines = 1,
    this.optional = false,
    this.options = const [],
  });

  bool get numeric => type == FieldType.number;
}

enum RecordType { program, project, activity }

// ============================================================
// PROGRAM fields — mirrors "Add Program" / "Edit Program" in the
// CICS Extension System (top-level umbrella with projects & activities).
// ============================================================
const programFields = [
  FieldSpec('Program Title', Icons.event_note_outlined),
  FieldSpec('Start Date', Icons.calendar_today_outlined, type: FieldType.date),
  FieldSpec('Location / Community / Barangay', Icons.location_on_outlined),
  FieldSpec('Status', Icons.flag_outlined,
      type: FieldType.dropdown, options: ['Running', 'Completed', 'Pending']),
  FieldSpec('Partner / Beneficiaries', Icons.groups_outlined, optional: true),
  FieldSpec('Objectives', Icons.track_changes_outlined, type: FieldType.multiline, maxLines: 3, optional: true),
  FieldSpec('Program Description', Icons.description_outlined, type: FieldType.multiline, maxLines: 3),
];

// ============================================================
// PROJECT fields — mirrors the CICS Extension System's full
// "Add Project" / "Edit Project" feature set, including standalone
// projects (optional parent program), budget, funding source,
// target output, and lead implementer.
// ============================================================
const projectFields = [
  FieldSpec('Project Title', Icons.volunteer_activism_outlined),
  FieldSpec('Parent Program (leave blank for standalone project)', Icons.folder_open_outlined, optional: true),
  FieldSpec('Start Date', Icons.calendar_today_outlined, type: FieldType.date),
  FieldSpec('End Date', Icons.event_available_outlined, type: FieldType.date),
  FieldSpec('Status', Icons.flag_outlined,
      type: FieldType.dropdown, options: ['Running', 'Completed', 'Pending']),
  FieldSpec('Beneficiaries', Icons.groups_outlined),
  FieldSpec('Budget Allocated (PHP)', Icons.payments_outlined, type: FieldType.number),
  FieldSpec('Lead Implementer', Icons.person_outline, optional: true),
  FieldSpec('Objectives', Icons.track_changes_outlined, type: FieldType.multiline, maxLines: 3, optional: true),
  FieldSpec('Description / Remarks', Icons.notes_outlined, type: FieldType.multiline, maxLines: 3, optional: true),
];

// ============================================================
// ACTIVITY fields — mirrors the CICS Extension System's
// "Add Activity" modal: optional parent project, core details,
// faculty involvement, and Google Forms-based pre/post-test and
// satisfaction evaluation.
// ============================================================
const activityFields = [
  FieldSpec('Parent Project (leave blank for standalone activity)', Icons.folder_open_outlined, optional: true),
  FieldSpec('Activity Title', Icons.bolt_outlined),
  FieldSpec('Date', Icons.calendar_today_outlined, type: FieldType.date, optional: true),
  FieldSpec('Location', Icons.location_on_outlined, optional: true),
  FieldSpec('Participants', Icons.groups_outlined, type: FieldType.number, optional: true),
  FieldSpec('Status', Icons.flag_outlined,
      type: FieldType.dropdown, options: ['Completed', 'Ongoing', 'Planned']),
  FieldSpec('Faculty Involved (names & roles)', Icons.people_alt_outlined, type: FieldType.multiline, maxLines: 3, optional: true),
  FieldSpec('Pre-Test Google Form URL', Icons.link_outlined, optional: true),
  FieldSpec('Post-Test Google Form URL', Icons.link_outlined, optional: true),
  FieldSpec('Avg Pre-Test Score (%)', Icons.percent_outlined, type: FieldType.number, optional: true),
  FieldSpec('Avg Post-Test Score (%)', Icons.percent_outlined, type: FieldType.number, optional: true),
  FieldSpec('Number of Pre-Test Takers', Icons.groups_2_outlined, type: FieldType.number, optional: true),
  FieldSpec('Number of Post-Test Takers', Icons.groups_2_outlined, type: FieldType.number, optional: true),
  FieldSpec('Evaluation Form URL', Icons.link_outlined, optional: true),
  FieldSpec('Satisfaction Rate Target (%)', Icons.thumb_up_outlined, type: FieldType.number, optional: true),
  FieldSpec('Actual Satisfaction Rate (%)', Icons.thumb_up_alt_outlined, type: FieldType.number, optional: true),
];

// ============================================================
// TECHNOLOGY TRANSFER fields — mirrors the "Add Technology
// Transfer" form: what system was transferred, where it was
// deployed, and how it's being used.
// ============================================================
const technologyTransferFields = [
  FieldSpec('System Name', Icons.devices_other_outlined),
  FieldSpec('Major/Programs', Icons.school_outlined),
  FieldSpec('Deployment Date', Icons.calendar_today_outlined, type: FieldType.date),
  FieldSpec('Usage Status', Icons.flag_outlined,
      type: FieldType.dropdown, options: ['Active', 'Inactive', 'Pilot Testing', 'Decommissioned']),
  FieldSpec('Type', Icons.category_outlined,
      type: FieldType.dropdown, options: ['Software', 'Hardware', 'System/Platform', 'Web Application', 'Mobile Application', 'Other']),
  FieldSpec('Partner Institution', Icons.handshake_outlined),
  FieldSpec('Users Trained', Icons.groups_outlined, type: FieldType.number),
  FieldSpec('Description/Notes', Icons.notes_outlined, type: FieldType.multiline, maxLines: 3),
];
