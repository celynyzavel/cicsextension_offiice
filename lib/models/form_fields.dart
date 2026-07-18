import 'package:flutter/material.dart';

enum FieldType { text, number, multiline, date, dropdown, facultyList, readonly }

class FieldSpec {
  final String label;
  final IconData icon;
  final FieldType type;
  final int maxLines;
  final bool optional;
  final List<String> options;
  final bool allowDecimal;
  final num? min;
  final num? max;
  const FieldSpec(
    this.label,
    this.icon, {
    this.type = FieldType.text,
    this.maxLines = 1,
    this.optional = false,
    this.options = const [],
    this.allowDecimal = false,
    this.min,
    this.max,
  });

  bool get numeric => type == FieldType.number;
}

enum RecordType { program, project, activity }


const programFields = [
  FieldSpec('Program Title', Icons.event_note_outlined),
  FieldSpec('Start Date', Icons.calendar_today_outlined, type: FieldType.date),
  FieldSpec('Location / Community / Barangay', Icons.location_on_outlined),
  FieldSpec('Status', Icons.flag_outlined,
      type: FieldType.dropdown, options: ['Running', 'Completed', 'Pending']),
  FieldSpec('Partner / Beneficiaries', Icons.groups_outlined),
];


const projectFields = [
  FieldSpec('Project Title', Icons.volunteer_activism_outlined),
  FieldSpec('Parent Program', Icons.folder_open_outlined, type: FieldType.dropdown),
  FieldSpec('Parent Program ID', Icons.tag_outlined, type: FieldType.readonly, optional: true),
  FieldSpec('Start Date', Icons.calendar_today_outlined, type: FieldType.date),
  FieldSpec('End Date', Icons.event_available_outlined, type: FieldType.date),
  FieldSpec('Status', Icons.flag_outlined,
      type: FieldType.dropdown, options: ['Running', 'Completed', 'Pending']),
  FieldSpec('Beneficiaries', Icons.groups_outlined),
  FieldSpec('Lead Implementer', Icons.person_outline),
];


const activityFields = [
  FieldSpec('Parent Project', Icons.folder_open_outlined, type: FieldType.dropdown),
  FieldSpec('Parent Project ID', Icons.tag_outlined, type: FieldType.readonly, optional: true),
  FieldSpec('Activity Title', Icons.bolt_outlined),
  FieldSpec('Date', Icons.calendar_today_outlined, type: FieldType.date),
  FieldSpec('Location', Icons.location_on_outlined),
  FieldSpec('Participants', Icons.groups_outlined, type: FieldType.number, min: 0),
  FieldSpec('Status', Icons.flag_outlined,
      type: FieldType.dropdown, options: ['Completed', 'Ongoing', 'Planned']),
  FieldSpec('Faculty Involved', Icons.people_alt_outlined, type: FieldType.facultyList),
  FieldSpec('Avg Pre-Test Score (%)', Icons.percent_outlined,
      type: FieldType.number, allowDecimal: true, min: 0, max: 100),
  FieldSpec('Avg Post-Test Score (%)', Icons.percent_outlined,
      type: FieldType.number, allowDecimal: true, min: 0, max: 100),
  FieldSpec('Number of Pre-Test Takers', Icons.groups_2_outlined,
      type: FieldType.number, min: 0),
  FieldSpec('Number of Post-Test Takers', Icons.groups_2_outlined,
      type: FieldType.number, min: 0),
  FieldSpec('Satisfaction Rate (1-5)', Icons.thumb_up_alt_outlined,
      type: FieldType.number, min: 1, max: 5),
];


const technologyTransferFields = [
  FieldSpec('System Name', Icons.devices_other_outlined),
  FieldSpec('Major/Programs', Icons.school_outlined),
  FieldSpec('Deployment Date', Icons.calendar_today_outlined, type: FieldType.date),
  FieldSpec('Usage Status', Icons.flag_outlined,
      type: FieldType.dropdown, options: ['Active', 'Partially Used', 'Not Used']),
  FieldSpec('Type', Icons.category_outlined,
      type: FieldType.dropdown, options: ['Software', 'Hardware', 'System/Platform', 'Web Application', 'Mobile Application', 'Other']),
  FieldSpec('Partner Institution', Icons.handshake_outlined),
  FieldSpec('Users Trained', Icons.groups_outlined, type: FieldType.number),
  FieldSpec('Description/Notes', Icons.notes_outlined, type: FieldType.multiline, maxLines: 3),
];