import 'package:flutter/material.dart';
import '../services/admin_api_service.dart';
import '../services/admin_session.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});
  @override
  State<AdminDashboardScreen> createState() => _State();
}

class _State extends State<AdminDashboardScreen> {
  static const sections = <({String title, String path, IconData icon})>[
    (title: 'Dashboard', path: 'dashboard', icon: Icons.dashboard_outlined),
    (title: 'Users', path: 'users', icon: Icons.people_outline),
    (title: 'Businesses', path: 'businesses', icon: Icons.store_outlined),
    (title: 'Employees', path: 'employees', icon: Icons.badge_outlined),
    (title: 'Services', path: 'services', icon: Icons.design_services_outlined),
    (title: 'Employee services', path: 'employee-services', icon: Icons.link),
    (
      title: 'Appointments',
      path: 'appointments',
      icon: Icons.calendar_month_outlined,
    ),
    (title: 'Reviews', path: 'reviews', icon: Icons.reviews_outlined),
    (title: 'CMS', path: 'content', icon: Icons.article_outlined),
    (
      title: 'Announcements',
      path: 'announcements',
      icon: Icons.campaign_outlined,
    ),
    (title: 'FAQ', path: 'faq', icon: Icons.help_outline),
    (title: 'Media library', path: 'media', icon: Icons.perm_media_outlined),
    (title: 'Settings', path: 'settings', icon: Icons.settings_outlined),
    (title: 'Audit logs', path: 'audit-logs', icon: Icons.history),
    (title: 'Reports', path: 'reports', icon: Icons.analytics_outlined),
    (
      title: 'System status',
      path: 'system-status',
      icon: Icons.monitor_heart_outlined,
    ),
  ];
  final api = AdminApiService();
  int selected = 0, page = 1;
  bool loading = true;
  String? error;
  dynamic data;
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final v = await api.get(
        sections[selected].path,
        query: {
          if (selected > 0 && selected < 14) 'page': page,
          if (selected > 0 && selected < 14) 'pageSize': 25,
        },
      );
      if (mounted) setState(() => data = v);
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void select(int v) {
    setState(() {
      selected = v;
      page = 1;
    });
    load();
  }

  Future<void> logout() async {
    await AdminSession.clear();
    if (mounted)
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/admin-panel/login',
        (_) => false,
      );
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 900;
    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      drawer: compact ? Drawer(child: nav()) : null,
      appBar: AppBar(
        backgroundColor: const Color(0xFF111827),
        foregroundColor: Colors.white,
        title: Text(sections[selected].title),
        actions: [
          IconButton(onPressed: load, icon: const Icon(Icons.refresh)),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: Text(AdminSession.current!.fullName)),
          ),
        ],
      ),
      body: Row(
        children: [
          if (!compact) SizedBox(width: 270, child: nav()),
          Expanded(child: content()),
        ],
      ),
    );
  }

  Widget nav() => Material(
    color: const Color(0xFF080D18),
    child: SafeArea(
      child: Column(
        children: [
          const ListTile(
            tileColor: Colors.transparent,
            leading: Icon(Icons.content_cut, color: Color(0xFFF97316)),
            title: Text(
              'SALON ADMIN',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: sections.length,
              itemBuilder: (c, i) => ListTile(
                tileColor: Colors.transparent,
                selectedTileColor: const Color(0x22F97316),
                selected: i == selected,
                leading: Icon(
                  sections[i].icon,
                  color: i == selected
                      ? const Color(0xFFF97316)
                      : const Color(0xFF94A3B8),
                ),
                title: Text(
                  sections[i].title,
                  style: TextStyle(
                    color: i == selected
                        ? Colors.white
                        : const Color(0xFFCBD5E1),
                  ),
                ),
                onTap: () {
                  if (Scaffold.of(c).isDrawerOpen) Navigator.pop(c);
                  select(i);
                },
              ),
            ),
          ),
          ListTile(
            tileColor: Colors.transparent,
            leading: const Icon(Icons.logout, color: Color(0xFFF97316)),
            title: const Text('Logout', style: TextStyle(color: Colors.white)),
            onTap: logout,
          ),
        ],
      ),
    ),
  );
  Widget content() {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (error != null) return Center(child: msg(error!));
    final map = data is Map
        ? Map<String, dynamic>.from(data as Map)
        : <String, dynamic>{};
    if (selected == 0) return cards(map);
    final raw = map['items'];
    final items = raw is List
        ? raw.whereType<Map>().map((x) => Map<String, dynamic>.from(x)).toList()
        : [map];
    return table(items, map);
  }

  Widget cards(Map<String, dynamic> v) {
    const m = {
      'totalUsers': 'Users',
      'totalBusinesses': 'Businesses',
      'totalEmployees': 'Employees',
      'totalServices': 'Services',
      'todayAppointments': 'Today',
      'upcomingAppointments': 'Upcoming',
      'completedAppointments': 'Completed',
      'cancelledAppointments': 'Cancelled',
      'totalReviews': 'Reviews',
      'averageRating': 'Average rating',
    };
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        children: m.entries
            .map(
              (e) => SizedBox(
                width: 220,
                child: Card(
                  color: const Color(0xFF111827),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e.value,
                          style: const TextStyle(color: Color(0xFF94A3B8)),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${v[e.key] ?? 0}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget table(List<Map<String, dynamic>> items, Map<String, dynamic> meta) {
    if (items.isEmpty) return Center(child: msg('No records found.'));
    final cols = items.expand((x) => x.keys).toSet().take(9).toList();
    return Column(
      children: [
        Expanded(
          child: Scrollbar(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(
                    const Color(0xFF1E293B),
                  ),
                  columns: cols
                      .map(
                        (x) => DataColumn(
                          label: Text(
                            x,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      )
                      .toList(),
                  rows: items
                      .map(
                        (r) => DataRow(
                          cells: cols
                              .map(
                                (k) => DataCell(
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 260,
                                    ),
                                    child: Text(
                                      '${r[k] ?? '-'}',
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Color(0xFFCBD5E1),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ),
        ),
        if (meta['totalPages'] is num && (meta['totalPages'] as num) > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: page > 1
                    ? () {
                        page--;
                        load();
                      }
                    : null,
                icon: const Icon(Icons.chevron_left),
              ),
              Text(
                '$page / ${meta['totalPages']}',
                style: const TextStyle(color: Colors.white),
              ),
              IconButton(
                onPressed: page < (meta['totalPages'] as num)
                    ? () {
                        page++;
                        load();
                      }
                    : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
      ],
    );
  }

  Widget msg(String text) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(text, style: const TextStyle(color: Color(0xFFCBD5E1))),
      TextButton(onPressed: load, child: const Text('Try again')),
    ],
  );
}
