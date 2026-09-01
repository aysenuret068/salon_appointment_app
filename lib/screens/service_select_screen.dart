import 'package:flutter/material.dart';
import '../widgets/main_menu_button.dart';
import '../models/business_model.dart';
import '../models/review_model.dart';
import '../models/service_model.dart';
import '../services/api_service.dart';
import 'employee_select_screen.dart';

class ServiceSelectScreen extends StatefulWidget {
  final BusinessModel business;

  const ServiceSelectScreen({
    super.key,
    required this.business,
  });

  @override
  State<ServiceSelectScreen> createState() => _ServiceSelectScreenState();
}

class _ServiceSelectScreenState extends State<ServiceSelectScreen> {
  final ApiService apiService = ApiService();

  late Future<ServiceSelectScreenData> screenFuture;

  @override
  void initState() {
    super.initState();
    loadScreen();
  }

  void loadScreen() {
    screenFuture = getScreenData();
  }

  Future<ServiceSelectScreenData> getScreenData() async {
    final services =
        await apiService.getServicesByBusiness(widget.business.id);

    List<ReviewModel> reviews = [];

    try {
      reviews = await apiService.getBusinessReviews(widget.business.id);
    } catch (_) {
      // Yorumlar alınamazsa hizmet ekranı yine açılmaya devam eder.
      reviews = [];
    }

    return ServiceSelectScreenData(
      services: services,
      reviews: reviews,
    );
  }

  Future<void> refreshScreen() async {
    setState(() {
      loadScreen();
    });

    await screenFuture;
  }

  void goToEmployees(ServiceModel service) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EmployeeSelectScreen(
          business: widget.business,
          service: service,
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

  String formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day.$month.$year';
  }

  double calculateAverageRating(List<ReviewModel> reviews) {
    if (reviews.isEmpty) return 0;

    final total = reviews.fold<int>(
      0,
      (sum, review) => sum + review.rating,
    );

    return total / reviews.length;
  }

  Widget buildHeader(List<ReviewModel> reviews) {
    final openTime = cleanTime(widget.business.openTime);
    final closeTime = cleanTime(widget.business.closeTime);
    final averageRating = calculateAverageRating(reviews);

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
              Icons.design_services,
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
                  'Hizmet Seç',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  widget.business.name,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 14,
                  runSpacing: 8,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.access_time,
                          color: Colors.white70,
                          size: 16,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '$openTime - $closeTime',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                          size: 18,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          reviews.isEmpty
                              ? 'Henüz puan yok'
                              : '${averageRating.toStringAsFixed(1)} (${reviews.length} yorum)',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
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
              'Hizmetler',
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
              '$count hizmet',
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

  Widget buildServiceCard(ServiceModel service) {
    final totalMinutes = service.durationMinutes + service.bufferMinutes;

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
        onTap: () => goToEmployees(service),
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
                  Icons.spa_outlined,
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
                      service.name,
                      style: const TextStyle(
                        color: Color(0xFF1F2937),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        buildMiniChip(
                          icon: Icons.timer_outlined,
                          text: '$totalMinutes dk',
                        ),
                        buildMiniChip(
                          icon: Icons.payments_outlined,
                          text: '${service.price} TL',
                        ),
                        buildMiniChip(
                          icon: Icons.cleaning_services_outlined,
                          text: '${service.bufferMinutes} dk ara',
                        ),
                      ],
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

  Widget buildMiniChip({
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F5FF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: const Color(0xFFEDE9FE),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: const Color(0xFF7C3AED),
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF4C1D95),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInfoCard() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
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
              'Hizmeti seçtikten sonra bu hizmeti yapabilen çalışanları göreceksin.',
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

  Widget buildEmptyServicesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      margin: const EdgeInsets.only(top: 8),
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
              Icons.design_services_outlined,
              color: Color(0xFF7C3AED),
              size: 42,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Bu işletmede hizmet yok',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF1F2937),
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'İşletme sahibi hizmet eklediğinde burada görünecek.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: refreshScreen,
            icon: const Icon(Icons.refresh),
            label: const Text('Yenile'),
          ),
        ],
      ),
    );
  }

  Widget buildReviewsSection(List<ReviewModel> reviews) {
    final averageRating = calculateAverageRating(reviews);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Müşteri Yorumları',
                style: TextStyle(
                  color: Color(0xFF1F2937),
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (reviews.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7D6),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Colors.amber,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      averageRating.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Color(0xFF92400E),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        if (reviews.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: Colors.grey.shade200,
              ),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.rate_review_outlined,
                  color: Color(0xFF7C3AED),
                  size: 38,
                ),
                SizedBox(height: 10),
                Text(
                  'Henüz yorum yapılmamış',
                  style: TextStyle(
                    color: Color(0xFF1F2937),
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Tamamlanan randevulardan sonra yapılan yorumlar burada görünecek.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          )
        else
          ...reviews.map(buildReviewCard),
      ],
    );
  }

  Widget buildReviewCard(ReviewModel review) {
    final comment = review.comment?.trim();
    final customerName = review.customerName?.trim();
    final employeeName = review.employeeName?.trim();

    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 7),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 23,
                  backgroundColor: const Color(0xFFEDE9FE),
                  child: Text(
                    customerName == null || customerName.isEmpty
                        ? 'M'
                        : customerName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF7C3AED),
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customerName == null || customerName.isEmpty
                            ? 'Müşteri'
                            : customerName,
                        style: const TextStyle(
                          color: Color(0xFF1F2937),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: List.generate(
                          5,
                          (index) => Icon(
                            index < review.rating
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: Colors.amber,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  formatDate(review.createdAt),
                  style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            if (comment != null && comment.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                comment,
                style: const TextStyle(
                  color: Color(0xFF374151),
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
            ],
            if (employeeName != null && employeeName.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F5FF),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.badge_outlined,
                      color: Color(0xFF7C3AED),
                      size: 16,
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        'Çalışan: $employeeName',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF4C1D95),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
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
                'İşletme bilgileri alınamadı',
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
                onPressed: refreshScreen,
                icon: const Icon(Icons.refresh),
                label: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildScreenContent(ServiceSelectScreenData data) {
    return RefreshIndicator(
      onRefresh: refreshScreen,
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
                  buildHeader(data.reviews),
                  buildSectionTitle(data.services.length),
                  if (data.services.isEmpty)
                    buildEmptyServicesCard()
                  else ...[
                    ...data.services.map(buildServiceCard),
                    buildInfoCard(),
                  ],
                  buildReviewsSection(data.reviews),
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
        title: Text('${widget.business.name} - Hizmet Seç'),
        actions: const [
        MainMenuButton(),
      ],
      ),
      body: SafeArea(
        child: FutureBuilder<ServiceSelectScreenData>(
          future: screenFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return buildErrorState(snapshot.error!);
            }

            final data = snapshot.data;

            if (data == null) {
              return buildErrorState(
                Exception('Ekran verileri alınamadı.'),
              );
            }

            return buildScreenContent(data);
          },
        ),
      ),
    );
  }
}

class ServiceSelectScreenData {
  final List<ServiceModel> services;
  final List<ReviewModel> reviews;

  const ServiceSelectScreenData({
    required this.services,
    required this.reviews,
  });
}
