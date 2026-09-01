import 'package:flutter/material.dart';
import '../widgets/main_menu_button.dart';
import 'customer_home_screen.dart';
import 'add_review_screen.dart';

import '../models/appointment_model.dart';
import '../services/api_service.dart';
import '../services/user_session.dart';

class CustomerAppointmentsScreen extends StatefulWidget {
  const CustomerAppointmentsScreen({super.key});

  @override
  State<CustomerAppointmentsScreen> createState() =>
      _CustomerAppointmentsScreenState();
}

class _CustomerAppointmentsScreenState extends State<CustomerAppointmentsScreen> {
  final ApiService apiService = ApiService();

  late Future<CustomerAppointmentScreenData> screenFuture;

  @override
  void initState() {
    super.initState();
    loadAppointments();
  }

  void loadAppointments() {
    screenFuture = getScreenData();
  }

  Future<CustomerAppointmentScreenData> getScreenData() async {
    final user = UserSession.currentUser;

    if (user == null) {
      return CustomerAppointmentScreenData(
        appointments: const [],
        businessNames: const {},
        serviceNames: const {},
        employeeNames: const {},
      );
    }

    final appointments = await apiService.getCustomerAppointments(user.userId);

    appointments.sort(
      (a, b) => b.startTime.compareTo(a.startTime),
    );

    final businessNames = <int, String>{};
    final serviceNames = <int, String>{};
    final employeeNames = <int, String>{};

    final businessIds = appointments.map((x) => x.businessId).toSet();

    try {
      final businesses = await apiService.getBusinesses();

      for (final business in businesses) {
        businessNames[business.id] = business.name;
      }
    } catch (_) {}

    for (final businessId in businessIds) {
      try {
        final services = await apiService.getServicesByBusiness(businessId);

        for (final service in services) {
          serviceNames[service.id] = service.name;
        }
      } catch (_) {}

      try {
        final employees = await apiService.getEmployeesByBusiness(businessId);

        for (final employee in employees) {
          employeeNames[employee.id] = employee.fullName;
        }
      } catch (_) {}
    }

    return CustomerAppointmentScreenData(
      appointments: appointments,
      businessNames: businessNames,
      serviceNames: serviceNames,
      employeeNames: employeeNames,
    );
  }

  Future<void> refreshAppointments() async {
    setState(() {
      loadAppointments();
    });

    await screenFuture;
  }

  void goToCustomerHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const CustomerHomeScreen(),
      ),
      (route) => false,
    );
  }

  Future<void> goToAddReview(AppointmentModel appointment) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddReviewScreen(
          appointmentId: appointment.id,
        ),
      ),
    );

    if (result == true) {
      refreshAppointments();
    }
  }

  String formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day.$month.$year';
  }

  String formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  String statusText(String status) {
    switch (status) {
      case 'Confirmed':
        return 'Onaylandı';
      case 'CancelledRefunded':
        return 'İptal edildi - Kapora iade';
      case 'CancelledLate':
        return 'Geç iptal - Kapora iade yok';
      case 'Completed':
        return 'Tamamlandı';
      case 'NoShow':
        return 'Gelmedi';
      default:
        return status;
    }
  }

  Color statusColor(String status) {
    switch (status) {
      case 'Confirmed':
        return const Color(0xFF2563EB);
      case 'Completed':
        return const Color(0xFF16A34A);
      case 'NoShow':
        return const Color(0xFFDC2626);
      case 'CancelledRefunded':
      case 'CancelledLate':
        return const Color(0xFFEA580C);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Color statusBackgroundColor(String status) {
    switch (status) {
      case 'Confirmed':
        return const Color(0xFFDBEAFE);
      case 'Completed':
        return const Color(0xFFDCFCE7);
      case 'NoShow':
        return const Color(0xFFFEE2E2);
      case 'CancelledRefunded':
      case 'CancelledLate':
        return const Color(0xFFFFEDD5);
      default:
        return const Color(0xFFF3F4F6);
    }
  }

  bool canCancel(AppointmentModel appointment) {
    return appointment.status == 'Confirmed';
  }

  bool canReview(AppointmentModel appointment) {
    return appointment.status == 'Completed';
  }

  Future<void> cancelAppointment(AppointmentModel appointment) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Randevuyu İptal Et'),
          content: const Text(
            'Randevunu iptal etmek istediğine emin misin? İptal kuralına göre kapora iadesi değişebilir.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Vazgeç'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'İptal Et',
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
      await apiService.cancelAppointment(
        appointmentId: appointment.id,
        reason: 'Müşteri tarafından iptal edildi.',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Randevu iptal edildi.'),
        ),
      );

      refreshAppointments();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  Widget buildHeader(List<AppointmentModel> appointments) {
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
              Icons.calendar_month,
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
                  'Randevularım',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Aktif ve geçmiş randevularını buradan takip et.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: refreshAppointments,
            icon: const Icon(
              Icons.refresh,
              color: Colors.white,
            ),
            tooltip: 'Yenile',
          ),
        ],
      ),
    );
  }

  Widget buildSummaryCard(List<AppointmentModel> appointments) {
    final total = appointments.length;
    final confirmed = appointments.where((x) => x.status == 'Confirmed').length;
    final completed = appointments.where((x) => x.status == 'Completed').length;
    final cancelled = appointments
        .where(
          (x) =>
              x.status == 'CancelledRefunded' ||
              x.status == 'CancelledLate',
        )
        .length;

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
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Expanded(
              child: summaryItem(
                icon: Icons.format_list_numbered,
                title: 'Toplam',
                value: total.toString(),
              ),
            ),
            buildDivider(),
            Expanded(
              child: summaryItem(
                icon: Icons.event_available,
                title: 'Aktif',
                value: confirmed.toString(),
              ),
            ),
            buildDivider(),
            Expanded(
              child: summaryItem(
                icon: Icons.check_circle_outline,
                title: 'Biten',
                value: completed.toString(),
              ),
            ),
            buildDivider(),
            Expanded(
              child: summaryItem(
                icon: Icons.cancel_outlined,
                title: 'İptal',
                value: cancelled.toString(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDivider() {
    return Container(
      width: 1,
      height: 48,
      color: Colors.grey.shade200,
    );
  }

  Widget summaryItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: const Color(0xFF7C3AED),
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 19,
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

  Widget buildAppointmentCard(
    AppointmentModel appointment,
    CustomerAppointmentScreenData data,
  ) {
    final businessName = data.businessNames[appointment.businessId] ??
        'İşletme #${appointment.businessId}';

    final serviceName = data.serviceNames[appointment.serviceId] ??
        'İşlem #${appointment.serviceId}';

    final employeeName = data.employeeNames[appointment.employeeId] ??
        'Çalışan #${appointment.employeeId}';

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
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildAppointmentTopRow(appointment),
            const SizedBox(height: 16),
            buildInfoBox(
              icon: Icons.storefront,
              title: 'İşletme',
              value: businessName,
            ),
            const SizedBox(height: 10),
            buildInfoBox(
              icon: Icons.design_services_outlined,
              title: 'İşlem',
              value: serviceName,
            ),
            const SizedBox(height: 10),
            buildInfoBox(
              icon: Icons.badge_outlined,
              title: 'Yapacak Çalışan',
              value: employeeName,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: buildSmallInfoBox(
                    icon: Icons.calendar_month,
                    title: 'Tarih',
                    value: formatDate(appointment.startTime),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: buildSmallInfoBox(
                    icon: Icons.access_time,
                    title: 'Saat',
                    value:
                        '${formatTime(appointment.startTime)} - ${formatTime(appointment.endTime)}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            buildPaymentInfo(appointment),

            if (canCancel(appointment)) ...[
              const SizedBox(height: 16),
              SizedBox(
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () => cancelAppointment(appointment),
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text(
                    'Randevuyu İptal Et',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],

            if (canReview(appointment)) ...[
              const SizedBox(height: 16),
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () => goToAddReview(appointment),
                  icon: const Icon(Icons.star_rounded),
                  label: const Text(
                    'Yorum Yap',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget buildAppointmentTopRow(AppointmentModel appointment) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: const Color(0xFFEDE9FE),
            borderRadius: BorderRadius.circular(19),
          ),
          child: const Icon(
            Icons.event_available,
            color: Color(0xFF7C3AED),
            size: 30,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Randevu',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${formatDate(appointment.startTime)} • ${formatTime(appointment.startTime)}',
                style: const TextStyle(
                  color: Color(0xFF1F2937),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        buildStatusChip(appointment.status),
      ],
    );
  }

  Widget buildStatusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: statusBackgroundColor(status),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        statusText(status),
        style: TextStyle(
          color: statusColor(status),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget buildInfoBox({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF7C3AED),
            size: 21,
          ),
          const SizedBox(width: 10),
          Text(
            '$title: ',
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF1F2937),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSmallInfoBox({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F5FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFEDE9FE),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: const Color(0xFF7C3AED),
            size: 21,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF1F2937),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPaymentInfo(AppointmentModel appointment) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEDE9FE),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          buildPaymentRow(
            title: 'Toplam',
            value: '${appointment.totalPrice} TL',
          ),
          const SizedBox(height: 8),
          buildPaymentRow(
            title: 'Kapora',
            value: '${appointment.depositAmount} TL',
          ),
          const SizedBox(height: 8),
          buildPaymentRow(
            title: 'Kalan',
            value: '${appointment.remainingAmount} TL',
          ),
        ],
      ),
    );
  }

  Widget buildPaymentRow({
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF4C1D95),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF4C1D95),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget buildEmptyState() {
    return RefreshIndicator(
      onRefresh: refreshAppointments,
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
                  buildHeader(const []),
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
                            Icons.event_busy_outlined,
                            color: Color(0xFF7C3AED),
                            size: 42,
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'Henüz randevun yok',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF1F2937),
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Randevu oluşturduğunda burada listelenecek.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 15,
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
                'Randevular alınamadı',
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
                onPressed: refreshAppointments,
                icon: const Icon(Icons.refresh),
                label: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildAppointmentsList(CustomerAppointmentScreenData data) {
    final appointments = data.appointments;

    return RefreshIndicator(
      onRefresh: refreshAppointments,
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
                  buildHeader(appointments),
                  buildSummaryCard(appointments),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(4, 4, 4, 8),
                    child: Text(
                      'Tüm Randevularım',
                      style: TextStyle(
                        color: Color(0xFF1F2937),
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...appointments.map(
                    (appointment) => buildAppointmentCard(
                      appointment,
                      data,
                    ),
                  ),
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
        title: const Text('Randevularım'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: goToCustomerHome,
        ),
         actions: const [
        MainMenuButton(),
      ],
      ),
      body: SafeArea(
        child: FutureBuilder<CustomerAppointmentScreenData>(
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

            if (data == null || data.appointments.isEmpty) {
              return buildEmptyState();
            }

            return buildAppointmentsList(data);
          },
        ),
      ),
    );
  }
}

class CustomerAppointmentScreenData {
  final List<AppointmentModel> appointments;
  final Map<int, String> businessNames;
  final Map<int, String> serviceNames;
  final Map<int, String> employeeNames;

  CustomerAppointmentScreenData({
    required this.appointments,
    required this.businessNames,
    required this.serviceNames,
    required this.employeeNames,
  });
}
