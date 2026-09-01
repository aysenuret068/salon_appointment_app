import 'package:flutter/material.dart';
import '../widgets/main_menu_button.dart';
import '../models/appointment_model.dart';
import '../models/business_model.dart';
import '../models/employee_model.dart';
import '../models/service_model.dart';
import '../services/api_service.dart';
import 'owner_home_screen.dart';

class OwnerAppointmentsScreen extends StatefulWidget {
  final BusinessModel business;

  const OwnerAppointmentsScreen({
    super.key,
    required this.business,
  });

  @override
  State<OwnerAppointmentsScreen> createState() =>
      _OwnerAppointmentsScreenState();
}

class _OwnerAppointmentsScreenState extends State<OwnerAppointmentsScreen> {
  final ApiService apiService = ApiService();

  late Future<OwnerAppointmentScreenData> screenFuture;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() {
    screenFuture = getScreenData();
  }

  Future<OwnerAppointmentScreenData> getScreenData() async {
    final results = await Future.wait<dynamic>([
      apiService.getAllBusinessAppointments(widget.business.id),
      apiService.getEmployeesByBusiness(widget.business.id),
      apiService.getServicesByBusiness(widget.business.id),
    ]);

    final appointments = results[0] as List<AppointmentModel>;
    final employees = results[1] as List<EmployeeModel>;
    final services = results[2] as List<ServiceModel>;

    appointments.sort((a, b) => b.startTime.compareTo(a.startTime));

    final employeeNames = <int, String>{};
    for (final employee in employees) {
      employeeNames[employee.id] = employee.fullName;
    }

    final serviceNames = <int, String>{};
    for (final service in services) {
      serviceNames[service.id] = service.name;
    }

    return OwnerAppointmentScreenData(
      appointments: appointments,
      employeeNames: employeeNames,
      serviceNames: serviceNames,
    );
  }

  Future<void> refresh() async {
    setState(() {
      loadData();
    });

    await screenFuture;
  }

  void goBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const OwnerHomeScreen(),
      ),
      (route) => false,
    );
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

  bool canManage(AppointmentModel appointment) {
    return appointment.status == 'Confirmed';
  }

  Future<bool> confirmAction({
    required String title,
    required String message,
    required String confirmText,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Vazgeç'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                confirmText,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    return result == true;
  }

  Future<void> completeAppointment(AppointmentModel appointment) async {
    final confirm = await confirmAction(
      title: 'Randevuyu Tamamla',
      message: '${appointment.customerName} adlı müşterinin randevusu tamamlandı olarak işaretlensin mi?',
      confirmText: 'Tamamla',
    );

    if (!confirm) return;

    try {
      await apiService.completeAppointment(appointment.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Randevu tamamlandı.'),
        ),
      );

      refresh();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  Future<void> markNoShow(AppointmentModel appointment) async {
    final confirm = await confirmAction(
      title: 'Müşteri Gelmedi',
      message: '${appointment.customerName} adlı müşteri gelmedi olarak işaretlensin mi?',
      confirmText: 'Gelmedi',
    );

    if (!confirm) return;

    try {
      await apiService.markNoShow(appointment.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Müşteri gelmedi olarak işaretlendi.'),
        ),
      );

      refresh();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  Widget buildHeader(OwnerAppointmentScreenData data) {
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Randevu Yönetimi',
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
              ],
            ),
          ),
          IconButton(
            onPressed: refresh,
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
    final noShow = appointments.where((x) => x.status == 'NoShow').length;

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
                icon: Icons.person_off_outlined,
                title: 'Gelmedi',
                value: noShow.toString(),
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
    OwnerAppointmentScreenData data,
  ) {
    final isManageable = canManage(appointment);

    final serviceName = data.serviceNames[appointment.serviceId] ??
        'Hizmet #${appointment.serviceId}';

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildAppointmentTopRow(appointment),
            const SizedBox(height: 16),
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
            const SizedBox(height: 10),
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
            if (isManageable) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => completeAppointment(appointment),
                      icon: const Icon(Icons.check),
                      label: const Text('Tamamlandı'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => markNoShow(appointment),
                      icon: const Icon(Icons.close),
                      label: const Text('Gelmedi'),
                    ),
                  ),
                ],
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
            Icons.person_outline,
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
                appointment.customerName,
                style: const TextStyle(
                  color: Color(0xFF1F2937),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.phone_outlined,
                    color: Color(0xFF6B7280),
                    size: 16,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      appointment.customerPhone,
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
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
      onRefresh: refresh,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 760,
              ),
              child: Column(
                children: [
                  buildHeader(
                    OwnerAppointmentScreenData(
                      appointments: const [],
                      employeeNames: const {},
                      serviceNames: const {},
                    ),
                  ),
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
                          'Henüz randevu yok',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF1F2937),
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Bu işletmeye ait randevular oluştuğunda burada listelenecek.',
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

  Widget buildAppointmentsList(OwnerAppointmentScreenData data) {
    final appointments = data.appointments;

    if (appointments.isEmpty) {
      return buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: refresh,
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
                  buildHeader(data),
                  buildSummaryCard(appointments),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(4, 4, 4, 8),
                    child: Text(
                      'Tüm Randevular',
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
                onPressed: refresh,
                icon: const Icon(Icons.refresh),
                label: const Text('Tekrar Dene'),
              ),
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
      appBar: AppBar(
        title: Text('${widget.business.name} Randevuları'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: goBack,
        ),
         actions: const [
        MainMenuButton(),
      ],
      ),
      body: SafeArea(
        child: FutureBuilder<OwnerAppointmentScreenData>(
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
              return const Center(
                child: Text('Randevu bilgileri alınamadı.'),
              );
            }

            return buildAppointmentsList(data);
          },
        ),
      ),
    );
  }
}

class OwnerAppointmentScreenData {
  final List<AppointmentModel> appointments;
  final Map<int, String> employeeNames;
  final Map<int, String> serviceNames;

  OwnerAppointmentScreenData({
    required this.appointments,
    required this.employeeNames,
    required this.serviceNames,
  });
}
