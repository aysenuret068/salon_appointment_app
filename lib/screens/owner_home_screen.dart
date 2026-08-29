import 'package:flutter/material.dart';

import '../models/business_model.dart';
import '../services/api_service.dart';
import '../services/user_session.dart';
import 'add_business_screen.dart';
import 'login_screen.dart';
import 'owner_business_detail_screen.dart';

class OwnerHomeScreen extends StatefulWidget {
  const OwnerHomeScreen({super.key});

  @override
  State<OwnerHomeScreen> createState() => _OwnerHomeScreenState();
}

class _OwnerHomeScreenState extends State<OwnerHomeScreen> {
  final ApiService apiService = ApiService();

  late Future<List<BusinessModel>> businessesFuture;

  @override
  void initState() {
    super.initState();
    loadBusinesses();
  }

  void loadBusinesses() {
    final user = UserSession.currentUser;

    if (user == null) {
      businessesFuture = Future.value([]);
      return;
    }

    businessesFuture = apiService.getBusinessesByOwner(user.userId);
  }

  Future<void> refreshBusinesses() async {
    setState(() {
      loadBusinesses();
    });

    await businessesFuture;
  }

  Future<void> openAddBusiness() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddBusinessScreen(),
      ),
    );

    if (result == true && mounted) {
      setState(() {
        loadBusinesses();
      });
    }
  }

  Future<void> openBusinessDetail(BusinessModel business) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OwnerBusinessDetailScreen(
          business: business,
        ),
      ),
    );

    if (result == true && mounted) {
      setState(() {
        loadBusinesses();
      });
    }
  }

  Future<void> logout() async {
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

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  String cleanTime(String? time) {
    if (time == null || time.isEmpty) return '-';

    if (time.length >= 5) {
      return time.substring(0, 5);
    }

    return time;
  }

  Widget buildHeader() {
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
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.storefront,
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
                  'İşletme Paneli',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  user?.fullName ?? 'İşletme Sahibi',
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
            onPressed: logout,
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

  Widget buildSummaryCard(List<BusinessModel> businesses) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Expanded(
              child: buildSummaryItem(
                icon: Icons.store_outlined,
                title: 'İşletme',
                value: businesses.length.toString(),
              ),
            ),
            Container(
              width: 1,
              height: 48,
              color: Colors.grey.shade200,
            ),
            Expanded(
              child: buildSummaryItem(
                icon: Icons.manage_accounts_outlined,
                title: 'Yönetim',
                value: 'Aktif',
              ),
            ),
            Container(
              width: 1,
              height: 48,
              color: Colors.grey.shade200,
            ),
            Expanded(
              child: buildSummaryItem(
                icon: Icons.calendar_month_outlined,
                title: 'Randevu',
                value: 'Hazır',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSummaryItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: const Color(0xFF7C3AED),
          size: 26,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget buildSectionTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 10, 4, 6),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'İşletmelerim',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
          TextButton.icon(
            onPressed: openAddBusiness,
            icon: const Icon(Icons.add),
            label: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  Widget buildBusinessCard(BusinessModel business) {
    final openTime = cleanTime(business.openTime);
    final closeTime = cleanTime(business.closeTime);

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
        onTap: () => openBusinessDetail(business),
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
                child: const Icon(
                  Icons.storefront,
                  color: Color(0xFF7C3AED),
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      business.name,
                      style: const TextStyle(
                        color: Color(0xFF1F2937),
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            business.address ?? 'Adres girilmemiş',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 16,
                          color: Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$openTime - $closeTime',
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: Color(0xFF9CA3AF),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              color: const Color(0xFFEDE9FE),
              borderRadius: BorderRadius.circular(26),
            ),
            child: const Icon(
              Icons.add_business_outlined,
              color: Color(0xFF7C3AED),
              size: 42,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Henüz işletme eklemedin',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF1F2937),
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'İlk işletmeni ekleyerek çalışan, hizmet ve randevu yönetimine başlayabilirsin.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: openAddBusiness,
              icon: const Icon(Icons.add),
              label: const Text(
                'İlk İşletmeni Ekle',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildErrorState(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7ED),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFFED7AA),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFEA580C),
                size: 42,
              ),
              const SizedBox(height: 12),
              const Text(
                'İşletmeler alınamadı',
                style: TextStyle(
                  color: Color(0xFF9A3412),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF9A3412),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: refreshBusinesses,
                icon: const Icon(Icons.refresh),
                label: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildBodyContent(List<BusinessModel> businesses) {
    return RefreshIndicator(
      onRefresh: refreshBusinesses,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 760,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  buildHeader(),
                  const SizedBox(height: 16),
                  buildSummaryCard(businesses),
                  const SizedBox(height: 10),
                  buildSectionTitle(),
                  if (businesses.isEmpty)
                    buildEmptyState()
                  else
                    ...businesses.map(buildBusinessCard),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5FF),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: openAddBusiness,
        icon: const Icon(Icons.add),
        label: const Text('İşletme Ekle'),
      ),
      body: SafeArea(
        child: FutureBuilder<List<BusinessModel>>(
          future: businessesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return buildErrorState(snapshot.error!);
            }

            final businesses = snapshot.data ?? [];

            return buildBodyContent(businesses);
          },
        ),
      ),
    );
  }
}