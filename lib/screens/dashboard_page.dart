import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/records.dart';
import '../services/firestore_services.dart';
import '../services/session.dart';
import '../widgets/dashboard_charts.dart';
import '../widgets/common_widgets.dart';
import 'login_page.dart';

enum _DashboardTab { training, techTransfer }

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  _DashboardTab _tab = _DashboardTab.training;
  String? _type;
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();

    _refresh(showSnackOnSuccess: false);
  }

  Future<void> _refresh({bool showSnackOnSuccess = true}) async {
    if (_refreshing) return;
    setState(() => _refreshing = true);
    try {
      await FirestoreService.loadAllRecordsIntoStorage();
      if (mounted) {
        setState(() {});
        if (showSnackOnSuccess) {
          showSnack(context, "Dashboard refreshed.", success: true);
        }
      }
    } catch (e) {
      if (mounted) {
        showSnack(context, "Failed to refresh dashboard: $e", success: false);
      }
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: kTextSecondary)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: kDanger, foregroundColor: kWhite),
            onPressed: () {
              Navigator.pop(dialogContext);
              Session.clear();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  List<ProjectRecord> _allProjects() {
    final list = <ProjectRecord>[];
    for (final p in RecordStorage.programs) {
      list.addAll(p.projects);
    }
    return list;
  }

  List<ActivityRecord> _allActivities() {
    final list = <ActivityRecord>[];
    for (final p in RecordStorage.programs) {
      for (final proj in p.projects) {
        list.addAll(proj.activities);
      }
    }
    return list;
  }

  int? _extractYear(String date) {
    final parts = date.split('/');
    if (parts.length == 3) {
      return int.tryParse(parts[2]);
    }
    return null;
  }

 Widget _tabButton(String label, _DashboardTab tab) {
  final selected = _tab == tab;

  return InkWell(
    onTap: () => setState(() => _tab = tab),
    borderRadius: BorderRadius.circular(11),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: 60, 
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? kCard : Colors.transparent,
        borderRadius: BorderRadius.circular(11),
        boxShadow: selected ? kCardShadow : null,
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: selected ? kPrimary : kTextSecondary,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
          fontSize: 13,
        ),
      ),
    ),
  );
}

  Widget _metricCard(String label, String value, {IconData icon = Icons.insights, Color color = kPrimary}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kCardBorder),
        boxShadow: kCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: kTextSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              IconBadge(icon: icon, color: color, size: 30),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(
              color: kTextPrimary,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kCardBorder),
        boxShadow: kCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel(title, padding: EdgeInsets.zero),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildTrainingTab() {
    final activities = _allActivities();
    final projects = _allProjects();
    final programs = RecordStorage.programs;

    int totalParticipants = 0;
    final knowledgeGains = <double>[];
    final satisfactionRates = <double>[];
    final participantsByYear = <int, int>{};

    for (final a in activities) {
      final participants = int.tryParse((a.data['Participants'] ?? '').toString());
      if (participants != null) {
        totalParticipants += participants;

        final year = _extractYear((a.data['Date'] ?? '').toString());
        if (year != null) {
          participantsByYear[year] = (participantsByYear[year] ?? 0) + participants;
        }
      }

      final gain = a.knowledgeGain;
      if (gain != null) {
        knowledgeGains.add(gain);
      }

      final satisfaction = double.tryParse((a.data['Satisfaction Rate (1-5)'] ?? '').toString());
      if (satisfaction != null) {
        satisfactionRates.add(satisfaction);
      }
    }

    final avgGain = knowledgeGains.isEmpty
        ? 0.0
        : knowledgeGains.reduce((a, b) => a + b) / knowledgeGains.length;

    final avgSatisfaction = satisfactionRates.isEmpty
        ? 0.0
        : satisfactionRates.reduce((a, b) => a + b) / satisfactionRates.length;

    final statusCounts = <String, int>{};
    for (final p in programs) {
      final status = (p.data['Status'] ?? '').toString();
      if (status.isEmpty) continue;
      statusCounts[status] = (statusCounts[status] ?? 0) + 1;
    }

    final years = participantsByYear.keys.toList()..sort();
    final growthData = <String, int>{
      for (final y in years) y.toString(): participantsByYear[y]!,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [

            Expanded(child: _metricCard('TOTAL PROJECTS', '${projects.length}', icon: Icons.folder_outlined, color: kGold)),
            const SizedBox(width: 12),
            Expanded(child: _metricCard('TOTAL PARTICIPANTS', '$totalParticipants', icon: Icons.groups_outlined, color: kPrimary)),
           
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _metricCard('TOTAL PROGRAMS', '${programs.length}', icon: Icons.event_note_outlined, color: kSidebar)),
            const SizedBox(width: 12),
             Expanded(child: _metricCard('AVG. KNOWLEDGE GAIN', '${avgGain.toStringAsFixed(1)}%', icon: Icons.trending_up, color: kSuccess)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _metricCard('TOTAL ACTIVITIES', '${activities.length}', icon: Icons.bolt_outlined, color: kPrimary)),
             const SizedBox(width: 12),
            Expanded(child: _metricCard('AVG. SATISFACTION RATE', '${avgSatisfaction.toStringAsFixed(1)}/5', icon: Icons.thumb_up_alt_outlined, color: kGold)),
          ],
        ),
        const SizedBox(height: 20),
        _sectionCard(
          title: 'PARTICIPANT GROWTH PER YEAR',
          child: SimpleBarChart(data: growthData),
        ),
        _sectionCard(
          title: 'SECTOR DISTRIBUTION',
          child: SimplePieChart(data: statusCounts),
        ),
      ],
    );
  }

  Map<String, List<String>> _quarterlyFacultyInvolvement() {
    final map = <String, List<String>>{};
    for (final p in _allProjects()) {
      final lead = (p.data['Lead Implementer'] ?? '').toString().trim();
      if (lead.isEmpty) continue;

      final parts = (p.data['Start Date'] ?? '').toString().split('/');
      if (parts.length != 3) continue;
      final month = int.tryParse(parts[0]);
      final year = int.tryParse(parts[2]);
      if (month == null || year == null || month < 1 || month > 12) continue;

      final quarter = ((month - 1) ~/ 3) + 1;
      final key = 'Q$quarter $year';
      final names = map.putIfAbsent(key, () => []);
      if (!names.contains(lead)) names.add(lead);
    }
    return map;
  }

  Widget _buildQuarterlyFacultyInvolvement() {
    final data = _quarterlyFacultyInvolvement();
    if (data.isEmpty) {
      return const EmptyChartState(message: 'No quarterly data yet.');
    }

    final keys = data.keys.toList()
      ..sort((a, b) {
        final pa = a.split(' ');
        final pb = b.split(' ');
        final yearCompare = int.parse(pa[1]).compareTo(int.parse(pb[1]));
        if (yearCompare != 0) return yearCompare;
        return int.parse(pa[0].substring(1)).compareTo(int.parse(pb[0].substring(1)));
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final key in keys)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  key,
                  style: const TextStyle(
                    color: kTextPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data[key]!.join(', '),
                  style: const TextStyle(color: kTextSecondary, fontSize: 12.5),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildTechTransferTab() {
    final transfers = RecordStorage.techTransfers;

    int totalTrained = 0;
    final usageCounts = <String, int>{};

    for (final t in transfers) {
      final trained = int.tryParse((t.data['Users Trained'] ?? '').toString());
      if (trained != null) totalTrained += trained;

      final status = (t.data['Usage Status'] ?? '').toString();
      if (status.isNotEmpty) {
        usageCounts[status] = (usageCounts[status] ?? 0) + 1;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: _metricCard('TOTAL TECH TRANSFER', '${transfers.length}', icon: Icons.sync_alt_outlined, color: kGold)),
            const SizedBox(width: 12),
            Expanded(child: _metricCard('TOTAL TRAINED USER', '$totalTrained', icon: Icons.school_outlined, color: kPrimary)),
          ],
        ),
        const SizedBox(height: 20),
        _sectionCard(
          title: 'USAGE STATUS BREAKDOWN',
          child: SimpleBarChart(data: usageCounts, barColor: kGold),
        ),
        _sectionCard(
          title: 'QUARTERLY FACULTY INVOLVEMENT',
          child: _buildQuarterlyFacultyInvolvement(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = _type ?? 'Dashboard';

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        backgroundColor: kSidebar,
        foregroundColor: kWhite,
        leading: _type != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _type = null),
              )
            : null,
        actions: [
          IconButton(
            tooltip: "Refresh",
            onPressed: _refreshing ? null : () => _refresh(),
            icon: _refreshing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: kWhite),
                  )
                : const Icon(Icons.refresh),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: kSurfaceAlt,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: _tabButton('Training Impact Metrics', _DashboardTab.training)),
                        const SizedBox(width: 4),
                        Expanded(child: _tabButton('Technology Transfer', _DashboardTab.techTransfer)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_tab == _DashboardTab.training)
                    _buildTrainingTab()
                  else
                    _buildTechTransferTab(),
                ],
              ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}