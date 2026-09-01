import 'package:flutter/material.dart';
import '../services/admin_api_service.dart';
import '../services/admin_session.dart';
import '../utils/admin_labels.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key, this.initialPath = 'dashboard'});
  final String initialPath;
  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboardScreen> {
  static const orange = Color(0xFFF97316),
      panel = Color(0xFF111827),
      muted = Color(0xFF94A3B8);
  static const sections = <({String title, String path, IconData icon})>[
    (title: 'Genel Bakış', path: 'dashboard', icon: Icons.dashboard_outlined),
    (title: 'Kullanıcılar', path: 'users', icon: Icons.people_outline),
    (title: 'İşletmeler', path: 'businesses', icon: Icons.store_outlined),
    (title: 'Çalışanlar', path: 'employees', icon: Icons.badge_outlined),
    (
      title: 'Hizmetler',
      path: 'services',
      icon: Icons.design_services_outlined,
    ),
    (
      title: 'Çalışan-Hizmet Atamaları',
      path: 'employee-services',
      icon: Icons.link,
    ),
    (
      title: 'Randevular',
      path: 'appointments',
      icon: Icons.calendar_month_outlined,
    ),
    (title: 'Yorumlar', path: 'reviews', icon: Icons.reviews_outlined),
    (title: 'İşlem Kayıtları', path: 'audit-logs', icon: Icons.history),
    (title: 'Raporlar', path: 'reports', icon: Icons.analytics_outlined),
    (
      title: 'Sistem Durumu',
      path: 'system-status',
      icon: Icons.monitor_heart_outlined,
    ),
  ];
  final api = AdminApiService();
  final _tableHorizontalController = ScrollController();
  int selected = 0, page = 1;
  bool loading = true;
  String? error;
  dynamic data;
  String get path => sections[selected].path;
  @override
  void initState() {
    super.initState();
    selected = sections.indexWhere((x) => x.path == widget.initialPath);
    if (selected < 0) selected = 0;
    load();
  }

  @override
  void dispose() {
    _tableHorizontalController.dispose();
    super.dispose();
  }

  Future<void> load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final v = await api.get(
        path,
        query: {
          if (selected > 0 && selected < sections.length - 2) 'page': page,
          if (selected > 0 && selected < sections.length - 2) 'pageSize': 25,
        },
      );
      if (mounted) setState(() => data = v);
    } catch (e) {
      if (mounted && e is AdminApiException && e.statusCode == 401) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/admin-panel/login',
          (_) => false,
        );
      } else if (mounted) {
        setState(() => error = e.toString());
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void select(int index) {
    setState(() {
      selected = index;
      page = 1;
    });
    load();
  }

  Future<void> logout() async {
    await AdminSession.clear();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/admin-panel/login',
        (_) => false,
      );
    }
  }

  void notice(String text, {bool error = false}) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(text),
          backgroundColor: error ? Colors.red.shade800 : Colors.green.shade700,
        ),
      );
  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 900;
    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      drawer: compact ? Drawer(child: nav()) : null,
      appBar: AppBar(
        backgroundColor: panel,
        foregroundColor: Colors.white,
        title: Text(
          sections[selected].title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            onPressed: load,
            tooltip: 'Yenile',
            icon: const Icon(Icons.refresh, color: orange),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                AdminSession.current?.fullName ?? 'Admin',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          if (!compact) SizedBox(width: 280, child: nav()),
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
            leading: Icon(Icons.content_cut, color: orange),
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
                  color: i == selected ? orange : muted,
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
            leading: const Icon(Icons.logout, color: orange),
            title: const Text('Çıkış', style: TextStyle(color: Colors.white)),
            onTap: logout,
          ),
        ],
      ),
    ),
  );
  Widget content() {
    if (loading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: orange),
            SizedBox(height: 12),
            Text('Yükleniyor...', style: TextStyle(color: muted)),
          ],
        ),
      );
    }
    if (error != null) return Center(child: state(error!, true));
    final map = data is Map
        ? Map<String, dynamic>.from(data as Map)
        : <String, dynamic>{};
    if (selected == 0) return cards(map);
    final raw = map['items'];
    final items = raw is List
        ? raw.whereType<Map>().map((x) => Map<String, dynamic>.from(x)).toList()
        : map.isEmpty
        ? <Map<String, dynamic>>[]
        : [map];
    return table(items, map);
  }

  Widget state(String text, bool failed) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(
        failed ? Icons.error_outline : Icons.inbox_outlined,
        color: failed ? Colors.red.shade300 : muted,
        size: 44,
      ),
      const SizedBox(height: 12),
      Text(text, style: const TextStyle(color: Color(0xFFCBD5E1))),
      if (failed)
        TextButton(
          onPressed: load,
          child: const Text('Tekrar Dene', style: TextStyle(color: orange)),
        ),
    ],
  );
  Widget cards(Map<String, dynamic> v) {
    const metrics = {
      'totalUsers': 'Toplam Kullanıcı',
      'totalBusinesses': 'İşletme',
      'totalEmployees': 'Çalışan',
      'totalServices': 'Hizmet',
      'todayAppointments': 'Bugünkü Randevu',
      'upcomingAppointments': 'Yaklaşan',
      'completedAppointments': 'Tamamlanan',
      'cancelledAppointments': 'İptal',
      'totalReviews': 'Yorum',
      'averageRating': 'Ortalama Puan',
    };
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        children: metrics.entries
            .map(
              (e) => SizedBox(
                width: 220,
                child: Card(
                  color: panel,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.value, style: const TextStyle(color: muted)),
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

  bool get manageable =>
      !{'dashboard', 'audit-logs', 'reports', 'system-status'}.contains(path);
  bool get canCreate =>
      {'users', 'businesses', 'employees', 'services'}.contains(path);
  Widget table(List<Map<String, dynamic>> items, Map<String, dynamic> meta) {
    final cols = items
        .expand((x) => x.keys)
        .toSet()
        .where(
          (x) => !{
            'businessId',
            'employeeId',
            'serviceId',
            'ownerUserId',
            'customerId',
            'appointmentId',
          }.contains(x),
        )
        .take(9)
        .toList();
    return Column(
      children: [
        if (canCreate)
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: orange),
                onPressed: () => edit(null),
                icon: const Icon(Icons.add),
                label: Text(switch (path) {
                  'users' => 'Kullanıcı Ekle',
                  'businesses' => 'İşletme Ekle',
                  'employees' => 'Çalışan Ekle',
                  _ => 'Hizmet Ekle',
                }),
              ),
            ),
          ),
        Expanded(
          child: items.isEmpty
              ? Center(child: state('Kayıt bulunamadı.', false))
              : Scrollbar(
                  controller: _tableHorizontalController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: _tableHorizontalController,
                    padding: const EdgeInsets.all(20),
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(
                          const Color(0xFF1E293B),
                        ),
                        columns: [
                          ...cols.map(
                            (x) => DataColumn(
                              label: Text(
                                AdminLabels.field(x),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          if (manageable)
                            const DataColumn(
                              label: Text(
                                'İşlemler',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                        rows: items
                            .map(
                              (r) => DataRow(
                                cells: [
                                  ...cols.map((k) => DataCell(cell(k, r[k]))),
                                  if (manageable) DataCell(actions(r)),
                                ],
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ),
        ),
        if (meta['totalPages'] is num && (meta['totalPages'] as num) > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: page > 1
                      ? () {
                          page--;
                          load();
                        }
                      : null,
                  tooltip: 'Önceki',
                  icon: const Icon(Icons.chevron_left, color: Colors.white),
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
                  tooltip: 'Sonraki',
                  icon: const Icon(Icons.chevron_right, color: Colors.white),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget cell(String key, dynamic value) {
    if (value is bool) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: (value ? Colors.green : Colors.grey).withValues(alpha: .18),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          key == 'isPublished'
              ? (value ? 'Yayında' : 'Gizli')
              : (value ? 'Aktif' : 'Pasif'),
          style: TextStyle(
            color: value ? Colors.green.shade300 : Colors.grey.shade400,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 240),
      child: Text(
        AdminFormatters.value(key, value),
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Color(0xFFCBD5E1)),
      ),
    );
  }

  Widget actions(Map<String, dynamic> row) => PopupMenuButton<String>(
    tooltip: 'İşlemler',
    icon: const Icon(Icons.more_vert, color: orange),
    color: panel,
    onSelected: (v) => act(v, row),
    itemBuilder: (_) => menu(row)
        .map(
          (e) => PopupMenuItem(
            value: e.$1,
            child: Row(
              children: [
                Icon(
                  e.$2,
                  size: 18,
                  color: e.$1 == 'delete'
                      ? Colors.red.shade300
                      : Colors.white70,
                ),
                const SizedBox(width: 10),
                Text(
                  e.$3,
                  style: TextStyle(
                    color: e.$1 == 'delete'
                        ? Colors.red.shade300
                        : Colors.white,
                  ),
                ),
              ],
            ),
          ),
        )
        .toList(),
  );
  List<(String, IconData, String)> menu(Map<String, dynamic> r) {
    final out = <(String, IconData, String)>[
      ('view', Icons.visibility_outlined, 'Görüntüle'),
    ];
    if ({'users', 'businesses', 'employees', 'services'}.contains(path)) {
      out.add(('edit', Icons.edit_outlined, 'Düzenle'));
    }
    if ({'users', 'businesses', 'employees', 'services'}.contains(path)) {
      out.add((
        'status',
        r['isActive'] == true
            ? Icons.pause_circle_outline
            : Icons.play_circle_outline,
        r['isActive'] == true ? 'Pasifleştir' : 'Aktifleştir',
      ));
    }
    if (path == 'reviews') {
      out.add((
        'publication',
        r['isPublished'] == true
            ? Icons.visibility_off_outlined
            : Icons.publish,
        r['isPublished'] == true ? 'Gizle' : 'Yayınla',
      ));
    }
    if (path == 'appointments' && r['status'] == 'Confirmed') {
      out.addAll([
        ('complete', Icons.task_alt, 'Tamamlandı Yap'),
        ('no-show', Icons.person_off_outlined, 'Gelmedi İşaretle'),
        ('cancel', Icons.cancel_outlined, 'İptal Et'),
      ]);
    }
    if ({
      'users',
      'businesses',
      'employees',
      'services',
      'reviews',
    }.contains(path)) {
      out.add(('delete', Icons.delete_outline, 'Sil'));
    }
    return out;
  }

  Future<void> act(String action, Map<String, dynamic> row) async {
    try {
      if (action == 'view') {
        await view(row);
        return;
      }
      if (action == 'edit') {
        await edit(row);
        return;
      }
      if (action == 'status') {
        final active = row['isActive'] == true;
        if (!await confirm(
          active ? 'Pasifleştirme Onayı' : 'Aktifleştirme Onayı',
          active
              ? 'Bu kaydı pasifleştirmek istediğinize emin misiniz?'
              : 'Bu kaydı aktifleştirmek istediğinize emin misiniz?',
        )) {
          return;
        }
        await api.patch('$path/${row['id']}/status', {'isActive': !active});
        notice(active ? 'Kayıt pasifleştirildi.' : 'Kayıt aktifleştirildi.');
      } else if (action == 'publication') {
        await api.patch('reviews/${row['id']}/publication', {
          'isPublished': row['isPublished'] != true,
        });
        notice(
          row['isPublished'] == true ? 'Yorum gizlendi.' : 'Yorum yayınlandı.',
        );
      } else if ({'complete', 'no-show'}.contains(action)) {
        if (!await confirm(
          'Randevu İşlemi',
          'Bu randevu durumunu değiştirmek istediğinize emin misiniz?',
        )) {
          return;
        }
        await api.put('appointments/${row['id']}/$action');
        notice(
          action == 'complete'
              ? 'Randevu tamamlandı.'
              : 'Randevu gelmedi olarak işaretlendi.',
        );
      } else if (action == 'cancel') {
        if (!await confirm(
          'Randevu İptali',
          'Bu randevuyu iptal etmek istediğinize emin misiniz?',
        )) {
          return;
        }
        await api.put('appointments/${row['id']}/cancel', {
          'reason': 'Admin tarafından iptal edildi.',
        });
        notice('Randevu iptal edildi.');
      } else if (action == 'delete') {
        if (!await confirm(
          'Silme Onayı',
          'Bu kaydı silmek istediğinize emin misiniz? Tarihsel kayıtlar güvenli biçimde korunacaktır.',
        )) {
          return;
        }
        await api.delete('$path/${row['id']}');
        notice('Kayıt başarıyla silindi.');
      }
      await load();
    } catch (e) {
      notice(e.toString(), error: true);
    }
  }

  Future<void> view(Map<String, dynamic> row) => showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: panel,
      title: Text('Detaylar', style: const TextStyle(color: Colors.white)),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            children: row.entries
                .map(
                  (e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 170,
                          child: Text(
                            AdminLabels.field(e.key),
                            style: const TextStyle(
                              color: muted,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            AdminFormatters.value(e.key, e.value),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Kapat'),
        ),
      ],
    ),
  );
  Future<bool> confirm(String title, String message) async =>
      await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: panel,
          title: Text(title, style: const TextStyle(color: Colors.white)),
          content: Text(
            message,
            style: const TextStyle(color: Color(0xFFCBD5E1)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('İptal'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: orange),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Onayla'),
            ),
          ],
        ),
      ) ??
      false;
  Map<String, String> formFields() => switch (path) {
    'users' => {'fullName': 'Ad Soyad', 'email': 'E-posta', 'phone': 'Telefon'},
    'businesses' => {
      'name': 'Ad',
      'address': 'Adres',
      'phone': 'Telefon',
      'openTime': 'Açılış Saati',
      'closeTime': 'Kapanış Saati',
    },
    'employees' => {'fullName': 'Ad Soyad'},
    'services' => {
      'name': 'Ad',
      'price': 'Fiyat',
      'durationMinutes': 'Süre',
      'bufferMinutes': 'Ara Süre',
    },
    _ => {},
  };
  dynamic converted(String key, String value) {
    if ({
      'businessId',
      'employeeId',
      'serviceId',
      'ownerUserId',
      'durationMinutes',
      'bufferMinutes',
      'sortOrder',
    }.contains(key)) {
      return value.trim().isEmpty ? null : int.tryParse(value);
    }
    if ({'price'}.contains(key)) {
      return double.tryParse(value.replaceAll(',', '.'));
    }
    return value.trim().isEmpty &&
            {'imageUrl', 'startAt', 'endAt', 'ownerUserId'}.contains(key)
        ? null
        : value.trim();
  }

  Future<void> edit(Map<String, dynamic>? row) async {
    final fields = formFields();
    if (fields.isEmpty) return;
    final dialogFields = {
      ...fields,
      if (path == 'users' && row == null) 'password': 'Şifre',
      if (path == 'users' && row == null) 'passwordConfirm': 'Şifre Tekrarı',
    };
    var lookup = <Map<String, dynamic>>[];
    if (path == 'businesses' || path == 'employees' || path == 'services') {
      try {
        final result = await api.get(
          path == 'businesses'
              ? 'lookups/business-owners'
              : 'lookups/businesses',
        );
        lookup = (result as List)
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      } catch (e) {
        notice(e.toString(), error: true);
        return;
      }
      if (lookup.isEmpty) {
        notice(
          path == 'businesses'
              ? 'Aktif işletme sahibi bulunamadı.'
              : 'Aktif işletme bulunamadı.',
          error: true,
        );
        return;
      }
    }
    final c = {
      for (final e in dialogFields.entries)
        e.key: TextEditingController(text: '${row?[e.key] ?? ''}'),
    };
    var active = row?['isActive'] != false;
    var role = '${row?['role'] ?? 'Customer'}';
    var relationId =
        row?[path == 'businesses' ? 'ownerUserId' : 'businessId'] as int?;
    relationId ??= lookup.isEmpty ? null : lookup.first['id'] as int;
    if (!mounted) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          backgroundColor: panel,
          title: Text(
            row == null ? 'Yeni Kayıt' : 'Kaydı Düzenle',
            style: const TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (lookup.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: DropdownButtonFormField<int>(
                        initialValue: relationId,
                        dropdownColor: panel,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: path == 'businesses'
                              ? 'İşletme Sahibi'
                              : 'İşletme',
                        ),
                        items: lookup
                            .map(
                              (item) => DropdownMenuItem<int>(
                                value: item['id'] as int,
                                child: Text(
                                  '${item['fullName'] ?? item['name']}'
                                  '${item['email'] == null ? '' : ' — ${item['email']}'}',
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setLocal(() => relationId = value),
                      ),
                    ),
                  for (final e in dialogFields.entries)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TextField(
                        controller: c[e.key],
                        obscureText:
                            e.key == 'password' || e.key == 'passwordConfirm',
                        keyboardType:
                            {
                              'price',
                              'durationMinutes',
                              'bufferMinutes',
                            }.contains(e.key)
                            ? TextInputType.number
                            : e.key == 'email'
                            ? TextInputType.emailAddress
                            : null,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: e.value,
                          labelStyle: const TextStyle(color: muted),
                          filled: true,
                          fillColor: const Color(0xFF0B1220),
                        ),
                      ),
                    ),
                  if (path == 'users')
                    DropdownButtonFormField<String>(
                      initialValue: role,
                      dropdownColor: panel,
                      style: const TextStyle(color: Colors.white),
                      items: const ['Customer', 'BusinessOwner', 'Admin']
                          .map(
                            (x) => DropdownMenuItem(
                              value: x,
                              child: Text(AdminLabels.role(x)),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setLocal(() => role = v ?? role),
                      decoration: const InputDecoration(labelText: 'Rol'),
                    ),
                  if ({
                    'users',
                    'businesses',
                    'employees',
                    'services',
                  }.contains(path))
                    SwitchListTile(
                      value: active,
                      onChanged: (v) => setLocal(() => active = v),
                      activeThumbColor: orange,
                      title: const Text(
                        'Aktif',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('İptal'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: orange),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
    if (ok != true) {
      for (final x in c.values) {
        x.dispose();
      }
      return;
    }
    final requiredKeys = <String>{
      if (path == 'users') ...['fullName', 'email', 'phone'],
      if (path == 'users' && row == null) ...['password', 'passwordConfirm'],
      if (path == 'businesses' || path == 'services') 'name',
      if (path == 'employees') 'fullName',
    };
    if (requiredKeys.any((key) => c[key]!.text.trim().isEmpty)) {
      for (final x in c.values) {
        x.dispose();
      }
      notice('Zorunlu alanları doldurun.', error: true);
      return;
    }
    if (path == 'users' && row == null) {
      if (c['password']!.text.length < 8) {
        for (final x in c.values) {
          x.dispose();
        }
        notice('Şifre en az 8 karakter olmalıdır.', error: true);
        return;
      }
      if (c['password']!.text != c['passwordConfirm']!.text) {
        for (final x in c.values) {
          x.dispose();
        }
        notice('Şifreler eşleşmiyor.', error: true);
        return;
      }
    }
    if (path == 'services' &&
        (converted('price', c['price']!.text) == null ||
            converted('durationMinutes', c['durationMinutes']!.text) == null ||
            converted('bufferMinutes', c['bufferMinutes']!.text) == null)) {
      for (final x in c.values) {
        x.dispose();
      }
      notice('Fiyat ve süre alanlarına geçerli sayılar girin.', error: true);
      return;
    }
    final body = {
      for (final e in c.entries)
        if (e.key != 'passwordConfirm') e.key: converted(e.key, e.value.text),
      if (path == 'users') 'role': role,
      if (path == 'businesses') 'ownerUserId': relationId,
      if (path == 'employees' || path == 'services') 'businessId': relationId,
      if ({'users', 'businesses', 'employees', 'services'}.contains(path))
        'isActive': active,
    };
    for (final x in c.values) {
      x.dispose();
    }
    try {
      if (row == null) {
        await api.post(path, body);
      } else if (path == 'users') {
        await api.patch('users/${row['id']}', body);
      } else {
        await api.put('$path/${row['id']}', body);
      }
      notice(
        row != null
            ? 'Kayıt başarıyla güncellendi.'
            : switch (path) {
                'users' => 'Kullanıcı başarıyla oluşturuldu.',
                'businesses' => 'İşletme başarıyla oluşturuldu.',
                'employees' => 'Çalışan başarıyla oluşturuldu.',
                _ => 'Hizmet başarıyla oluşturuldu.',
              },
      );
      await load();
    } catch (e) {
      notice(e.toString(), error: true);
    }
  }
}
