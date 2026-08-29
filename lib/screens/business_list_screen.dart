import 'package:flutter/material.dart';
import '../widgets/main_menu_button.dart';
import '../models/business_model.dart';
import '../services/api_service.dart';
import 'service_select_screen.dart';

class BusinessListScreen extends StatefulWidget {
  const BusinessListScreen({super.key});

  @override
  State<BusinessListScreen> createState() => _BusinessListScreenState();
}

class _BusinessListScreenState extends State<BusinessListScreen> {
  final ApiService apiService = ApiService();

  late Future<List<BusinessModel>> businessesFuture;

  @override
  void initState() {
    super.initState();
    loadBusinesses();
  }

  void loadBusinesses() {
    businessesFuture = apiService.getBusinesses();
  }

  Future<void> refreshBusinesses() async {
    setState(() {
      loadBusinesses();
    });

    await businessesFuture;
  }

  void openServiceSelect(BusinessModel business) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ServiceSelectScreen(
          business: business,
        ),
      ),
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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'İşletme Seç',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Randevu almak istediğin işletmeyi seç.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSectionTitle(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 18, 4, 8),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Uygun İşletmeler',
              style: TextStyle(
                color: Color(0xFF1F2937),
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFEDE9FE),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '$count işletme',
              style: const TextStyle(
                color: Color(0xFF4C1D95),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
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
        onTap: () => openServiceSelect(business),
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
                  size: 31,
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
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 5),
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
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 16,
                          color: Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '$openTime - $closeTime',
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                    if (business.phone != null &&
                        business.phone!.trim().isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.phone_outlined,
                            size: 16,
                            color: Color(0xFF6B7280),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            business.phone!,
                            style: const TextStyle(
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ],
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

  Widget buildEmptyState() {
    return RefreshIndicator(
      onRefresh: refreshBusinesses,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 720,
              ),
              child: Column(
                children: [
                  buildHeader(),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(26),
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
                            Icons.store_mall_directory_outlined,
                            color: Color(0xFF7C3AED),
                            size: 42,
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'Henüz işletme bulunamadı',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF1F2937),
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'İşletmeler eklendiğinde burada listelenecek.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 18),
                        OutlinedButton.icon(
                          onPressed: refreshBusinesses,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Yenile'),
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
            borderRadius: BorderRadius.circular(22),
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

  Widget buildBusinessesList(List<BusinessModel> businesses) {
    return RefreshIndicator(
      onRefresh: refreshBusinesses,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 720,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  buildHeader(),
                  buildSectionTitle(businesses.length),
                  ...businesses.map(buildBusinessCard),
                  const SizedBox(height: 30),
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
      appBar: AppBar(
        title: const Text('İşletme Seç'),
        actions: const [
    MainMenuButton(),
  ],
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

            if (businesses.isEmpty) {
              return buildEmptyState();
            }

            return buildBusinessesList(businesses);
          },
        ),
      ),
    );
  }
}