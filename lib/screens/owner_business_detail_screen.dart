import 'package:flutter/material.dart';
import '../widgets/main_menu_button.dart';
import '../models/business_model.dart';
import '../models/employee_model.dart';
import '../models/review_model.dart';
import '../models/service_model.dart';
import '../services/api_service.dart';
import 'add_employee_screen.dart';
import 'add_service_screen.dart';
import 'assign_service_screen.dart';
import 'edit_business_screen.dart';
import 'owner_appointments_screen.dart';

class OwnerBusinessDetailScreen extends StatefulWidget {
  final BusinessModel business;

  const OwnerBusinessDetailScreen({
    super.key,
    required this.business,
  });

  @override
  State<OwnerBusinessDetailScreen> createState() =>
      _OwnerBusinessDetailScreenState();
}

class _OwnerBusinessDetailScreenState extends State<OwnerBusinessDetailScreen> {
  final ApiService apiService = ApiService();

  late BusinessModel business;
  late Future<List<EmployeeModel>> employeesFuture;
  late Future<List<ServiceModel>> servicesFuture;
  late Future<List<ReviewModel>> reviewsFuture;

  @override
  void initState() {
    super.initState();
    business = widget.business;
    loadData();
  }

  void loadData() {
    employeesFuture = apiService.getEmployeesByBusiness(business.id);
    servicesFuture = apiService.getServicesByBusiness(business.id);
    reviewsFuture = apiService.getBusinessReviews(business.id);
  }

  Future<void> refresh() async {
    setState(() {
      loadData();
    });

    await Future.wait([
      employeesFuture,
      servicesFuture,
      reviewsFuture,
    ]);
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

  Future<void> openEditBusiness() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditBusinessScreen(
          business: business,
        ),
      ),
    );

    if (result == true && mounted) {
      Navigator.pop(context, true);
    }
  }

  Future<void> openAddEmployee() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEmployeeScreen(
          business: business,
        ),
      ),
    );

    if (!mounted) return;
    await refresh();
  }

  Future<void> openAddService() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddServiceScreen(
          business: business,
        ),
      ),
    );

    if (!mounted) return;
    await refresh();
  }

  Future<void> openAssignService() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AssignServiceScreen(
          business: business,
        ),
      ),
    );

    if (!mounted) return;
    await refresh();
  }

  Future<void> openAppointments() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OwnerAppointmentsScreen(
          business: business,
        ),
      ),
    );

    if (!mounted) return;
    await refresh();
  }

  Future<void> deleteBusiness() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('İşletmeyi Sil'),
          content: Text(
            '${business.name} adlı işletmeyi silmek istediğine emin misin?\n\n'
            'Çalışanlar, hizmetler ve yorumlar da silinecektir.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Vazgeç'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'İşletmeyi Sil',
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

    try {
      await apiService.deleteBusiness(business.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('İşletme başarıyla silindi.'),
          backgroundColor: Color(0xFF16A34A),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      final message = e.toString().replaceFirst('Exception: ', '');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    }
  }

  Future<void> deleteEmployee(EmployeeModel employee) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Çalışanı Sil'),
          content: Text(
            '${employee.fullName} adlı çalışanı silmek istediğine emin misin?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Vazgeç'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Sil',
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

    try {
      await apiService.deleteEmployee(employee.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Çalışan başarıyla silindi.'),
        ),
      );

      await refresh();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  Widget buildHeaderCard() {
    final openTime = cleanTime(business.openTime);
    final closeTime = cleanTime(business.closeTime);

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
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
                child: Text(
                  business.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: openEditBusiness,
                icon: const Icon(
                  Icons.edit,
                  color: Colors.white,
                ),
                tooltip: 'İşletmeyi Düzenle',
              ),
              IconButton(
                onPressed: deleteBusiness,
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.white,
                ),
                tooltip: 'İşletmeyi Sil',
              ),
            ],
          ),
          const SizedBox(height: 20),
          buildHeaderInfoRow(
            icon: Icons.location_on_outlined,
            text: business.address ?? 'Adres girilmemiş',
          ),
          const SizedBox(height: 8),
          buildHeaderInfoRow(
            icon: Icons.phone_outlined,
            text: business.phone ?? 'Telefon girilmemiş',
          ),
          const SizedBox(height: 8),
          buildHeaderInfoRow(
            icon: Icons.access_time,
            text: '$openTime - $closeTime',
          ),
        ],
      ),
    );
  }

  Widget buildHeaderInfoRow({
    required IconData icon,
    required String text,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white.withValues(alpha: 0.9),
          size: 19,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildSectionTitle({
    required String title,
    String? actionText,
    VoidCallback? onAction,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 18, 4, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF1F2937),
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (actionText != null && onAction != null)
            TextButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add),
              label: Text(actionText),
            ),
        ],
      ),
    );
  }

  // =========================================================
  // HIZLI İŞLEMLER
  // =========================================================

  Widget buildQuickActionsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        return GridView.count(
          crossAxisCount: isMobile ? 1 : 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          mainAxisExtent: 96,
          children: [
            buildActionCard(
              icon: Icons.people_alt_outlined,
              title: 'Çalışan Ekle',
              subtitle: 'Yeni çalışan',
              onTap: openAddEmployee,
            ),
            buildActionCard(
              icon: Icons.design_services_outlined,
              title: 'Hizmet Ekle',
              subtitle: 'Süre ve fiyat',
              onTap: openAddService,
            ),
            buildActionCard(
              icon: Icons.link,
              title: 'Hizmet Ata',
              subtitle: 'Çalışana bağla',
              onTap: openAssignService,
            ),
            buildActionCard(
              icon: Icons.calendar_month_outlined,
              title: 'Randevular',
              subtitle: 'Tüm randevular',
              onTap: openAppointments,
            ),
          ],
        );
      },
    );
  }

  Widget buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.grey.shade200,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE9FE),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF7C3AED),
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF1F2937),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF9CA3AF),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildEmployeesSection() {
    return FutureBuilder<List<EmployeeModel>>(
      future: employeesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return buildLoadingCard();
        }

        if (snapshot.hasError) {
          return buildErrorCard(
            title: 'Çalışanlar alınamadı',
            error: snapshot.error.toString(),
          );
        }

        final employees = snapshot.data ?? [];

        if (employees.isEmpty) {
          return buildEmptyCard(
            icon: Icons.person_add_alt_1,
            title: 'Henüz çalışan yok',
            subtitle:
                'Çalışan ekleyerek randevu yönetimini başlatabilirsin.',
            buttonText: 'Çalışan Ekle',
            onPressed: openAddEmployee,
          );
        }

        return Column(
          children: employees.map(buildEmployeeCard).toList(),
        );
      },
    );
  }

  Widget buildEmployeeCard(EmployeeModel employee) {
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
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFEDE9FE),
            borderRadius: BorderRadius.circular(17),
          ),
          child: const Icon(
            Icons.badge_outlined,
            color: Color(0xFF7C3AED),
          ),
        ),
        title: Text(
          employee.fullName,
          style: const TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: const Text(
          'Çalışan',
          style: TextStyle(
            color: Color(0xFF6B7280),
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          color: Colors.red,
          tooltip: 'Çalışanı Sil',
          onPressed: () => deleteEmployee(employee),
        ),
      ),
    );
  }

  Widget buildServicesSection() {
    return FutureBuilder<List<ServiceModel>>(
      future: servicesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return buildLoadingCard();
        }

        if (snapshot.hasError) {
          return buildErrorCard(
            title: 'Hizmetler alınamadı',
            error: snapshot.error.toString(),
          );
        }

        final services = snapshot.data ?? [];

        if (services.isEmpty) {
          return buildEmptyCard(
            icon: Icons.design_services_outlined,
            title: 'Henüz hizmet yok',
            subtitle:
                'Müşterilerin randevu alabilmesi için hizmet eklemelisin.',
            buttonText: 'Hizmet Ekle',
            onPressed: openAddService,
          );
        }

        return Column(
          children: services.map(buildServiceCard).toList(),
        );
      },
    );
  }

  Widget buildServiceCard(ServiceModel service) {
    final totalMinutes =
        service.durationMinutes + service.bufferMinutes;

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
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFEDE9FE),
                borderRadius: BorderRadius.circular(17),
              ),
              child: const Icon(
                Icons.spa_outlined,
                color: Color(0xFF7C3AED),
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
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
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
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildReviewsSection() {
    return FutureBuilder<List<ReviewModel>>(
      future: reviewsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return buildLoadingCard();
        }

        if (snapshot.hasError) {
          return buildErrorCard(
            title: 'Yorumlar alınamadı',
            error: snapshot.error.toString(),
          );
        }

        final reviews = snapshot.data ?? [];

        if (reviews.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.grey.shade200,
              ),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.rate_review_outlined,
                  color: Color(0xFF7C3AED),
                  size: 42,
                ),
                SizedBox(height: 12),
                Text(
                  'Henüz müşteri yorumu yok',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF1F2937),
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 7),
                Text(
                  'Tamamlanan randevular için yapılan yorumlar burada görünecek.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          );
        }

        final averageRating = calculateAverageRating(reviews);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildReviewSummaryCard(
              averageRating: averageRating,
              reviewCount: reviews.length,
            ),
            const SizedBox(height: 10),
            ...reviews.map(buildReviewCard),
          ],
        );
      },
    );
  }

  Widget buildReviewSummaryCard({
    required double averageRating,
    required int reviewCount,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFFBEB),
            Color(0xFFFEF3C7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFFDE68A),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(19),
            ),
            child: const Icon(
              Icons.star_rounded,
              color: Colors.amber,
              size: 36,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  averageRating.toStringAsFixed(1),
                  style: const TextStyle(
                    color: Color(0xFF92400E),
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$reviewCount müşteri yorumu',
                  style: const TextStyle(
                    color: Color(0xFFB45309),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Wrap(
            spacing: 1,
            children: List.generate(
              5,
              (index) => Icon(
                index < averageRating.round()
                    ? Icons.star_rounded
                    : Icons.star_border_rounded,
                color: Colors.amber,
                size: 21,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildReviewCard(ReviewModel review) {
    final customerName = review.customerName?.trim();
    final employeeName = review.employeeName?.trim();
    final comment = review.comment?.trim();

    final visibleCustomerName =
        customerName == null || customerName.isEmpty
            ? 'Müşteri'
            : customerName;

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
                    visibleCustomerName
                        .substring(0, 1)
                        .toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF7C3AED),
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        visibleCustomerName,
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
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  comment,
                  style: const TextStyle(
                    color: Color(0xFF374151),
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
              ),
            ],
            if (employeeName != null &&
                employeeName.isNotEmpty) ...[
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
                        'Hizmeti yapan: $employeeName',
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

  Widget buildMiniChip({
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F5FF),
        borderRadius: BorderRadius.circular(999),
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

  Widget buildLoadingCard() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(22),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget buildErrorCard({
    required String title,
    required String error,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFFED7AA),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFEA580C),
            size: 36,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF9A3412),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF9A3412),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEmptyCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
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
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              color: const Color(0xFFEDE9FE),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF7C3AED),
              size: 34,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF1F2937),
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.add),
              label: Text(buttonText),
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
      title: Text(business.name),
      actions: [
        IconButton(
          onPressed: openEditBusiness,
          icon: const Icon(Icons.edit),
          tooltip: 'İşletmeyi Düzenle',
        ),
        const MainMenuButton(),
      ],
    ),
    body: SafeArea(
      child: RefreshIndicator(
        onRefresh: refresh,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 780,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    buildHeaderCard(),

                    buildSectionTitle(
                      title: 'Hızlı İşlemler',
                    ),

                    buildQuickActionsGrid(),

                    buildSectionTitle(
                      title: 'Çalışanlar',
                      actionText: 'Ekle',
                      onAction: openAddEmployee,
                    ),

                    buildEmployeesSection(),

                    buildSectionTitle(
                      title: 'Hizmetler',
                      actionText: 'Ekle',
                      onAction: openAddService,
                    ),

                    buildServicesSection(),

                    buildSectionTitle(
                      title: 'Müşteri Yorumları',
                    ),

                    buildReviewsSection(),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}
