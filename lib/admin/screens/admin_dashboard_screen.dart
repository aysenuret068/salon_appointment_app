import 'package:flutter/material.dart';
import '../services/admin_session.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await AdminSession.clear();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/admin-panel/login',
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final admin = AdminSession.current!;
    const items = [
      ('Dashboard', Icons.dashboard_outlined),
      ('Kullanıcılar', Icons.people_outline),
      ('İşletmeler', Icons.store_outlined),
      ('Randevular', Icons.calendar_month_outlined),
      ('Yorumlar', Icons.reviews_outlined),
      ('İçerik Yönetimi', Icons.article_outlined),
      ('Ayarlar', Icons.settings_outlined),
    ];
    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      body: Row(
        children: [
          Container(
            width: 250,
            color: const Color(0xFF080D18),
            child: SafeArea(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Row(
                      children: [
                        Icon(Icons.content_cut, color: Color(0xFFF97316)),
                        SizedBox(width: 12),
                        Text(
                          'SALON ADMIN',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Color(0xFF1E293B)),
                  Expanded(
                    child: ListView(
                      children: [
                        for (var i = 0; i < items.length; i++)
                          ListTile(
                            enabled: i == 0,
                            selected: i == 0,
                            selectedTileColor: const Color(0x22F97316),
                            leading: Icon(
                              items[i].$2,
                              color: i == 0
                                  ? const Color(0xFFF97316)
                                  : const Color(0xFF64748B),
                            ),
                            title: Text(
                              items[i].$1,
                              style: TextStyle(
                                color: i == 0
                                    ? Colors.white
                                    : const Color(0xFF64748B),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Color(0xFFF97316)),
                    title: const Text(
                      'Çıkış',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () => _logout(context),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 72,
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    decoration: const BoxDecoration(
                      color: Color(0xFF111827),
                      border: Border(
                        bottom: BorderSide(color: Color(0xFF1E293B)),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Text(
                          'Dashboard',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              admin.fullName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              admin.email,
                              style: const TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Yönetim Paneli',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${admin.role} olarak güvenli oturum açtınız.',
                            style: const TextStyle(color: Color(0xFF94A3B8)),
                          ),
                          const SizedBox(height: 32),
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: const Color(0xFF111827),
                              border: Border.all(
                                color: const Color(0xFF253047),
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Color(0xFFF97316),
                                ),
                                SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    'Dashboard istatistikleri gerçek yönetim API’leri bağlandığında burada gösterilecektir.',
                                    style: TextStyle(color: Color(0xFFCBD5E1)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
