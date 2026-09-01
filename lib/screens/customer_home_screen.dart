import 'package:flutter/material.dart';

import '../services/user_session.dart';
import 'business_list_screen.dart';
import 'customer_appointments_screen.dart';
import 'login_screen.dart';

class CustomerHomeScreen extends StatelessWidget {
  const CustomerHomeScreen({super.key});

  Future<void> logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Çıkış Yap'),
          content: const Text(
            'Hesabından çıkış yapmak istediğine emin misin?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Vazgeç'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Çıkış Yap',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    UserSession.logout();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  void openBusinesses(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const BusinessListScreen(),
      ),
    );
  }

  void openAppointments(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CustomerAppointmentsScreen(),
      ),
    );
  }

  Widget buildHeader(BuildContext context) {
    final user = UserSession.currentUser;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF7C3AED),
            Color(0xFFA78BFA),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.person_outline,
              color: Colors.white,
              size: 34,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Müşteri Paneli',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  user?.fullName ?? 'Müşteri',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => logout(context),
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
            tooltip: 'Çıkış Yap',
          ),
        ],
      ),
    );
  }

  Widget buildWelcomeCard() {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: const Color(0xFFEDE9FE),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.event_available,
                color: Color(0xFF7C3AED),
                size: 30,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Randevunu kolayca oluştur',
                    style: TextStyle(
                      color: Color(0xFF1F2937),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'İşletme seç, hizmet seç, saat seç ve randevunu onayla.',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE9FE),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF7C3AED),
                  size: 31,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF1F2937),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      buttonText,
                      style: const TextStyle(
                        color: Color(0xFF7C3AED),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFF9CA3AF),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInfoCard() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEDE9FE),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Color(0xFF7C3AED),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Randevularım ekranından aktif randevularını görüntüleyebilir ve iptal işlemi yapabilirsin.',
              style: TextStyle(
                color: Color(0xFF4C1D95),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBody(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 720,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buildHeader(context),
              buildWelcomeCard(),
              const Padding(
                padding: EdgeInsets.fromLTRB(4, 8, 4, 8),
                child: Text(
                  'Ne yapmak istiyorsun?',
                  style: TextStyle(
                    color: Color(0xFF1F2937),
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              buildActionCard(
                icon: Icons.storefront,
                title: 'İşletmeler',
                subtitle: 'Randevu almak için işletme seç.',
                buttonText: 'İşletmeleri Gör',
                onTap: () => openBusinesses(context),
              ),
              buildActionCard(
                icon: Icons.calendar_month,
                title: 'Randevularım',
                subtitle: 'Randevularını görüntüle ve iptal et.',
                buttonText: 'Randevularımı Aç',
                onTap: () => openAppointments(context),
              ),
              buildInfoCard(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5FF),
      body: SafeArea(
        child: buildBody(context),
      ),
    );
  }
}
