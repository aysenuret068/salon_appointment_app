import 'package:flutter/material.dart';
import '../widgets/main_menu_button.dart';
import '../models/business_model.dart';
import '../models/employee_model.dart';
import '../models/service_model.dart';
import '../models/slot_model.dart';
import '../services/api_service.dart';
import 'customer_info_screen.dart';

class SlotSelectScreen extends StatefulWidget {
  final BusinessModel business;
  final ServiceModel service;
  final EmployeeModel employee;
  final DateTime selectedDate;

  const SlotSelectScreen({
    super.key,
    required this.business,
    required this.service,
    required this.employee,
    required this.selectedDate,
  });

  @override
  State<SlotSelectScreen> createState() => _SlotSelectScreenState();
}

class _SlotSelectScreenState extends State<SlotSelectScreen> {
  final ApiService apiService = ApiService();

  late Future<List<SlotModel>> slotsFuture;

  @override
  void initState() {
    super.initState();
    loadSlots();
  }

  void loadSlots() {
  slotsFuture = _getFutureSlots();
}

Future<List<SlotModel>> _getFutureSlots() async {
  final slots = await apiService.getAvailableSlots(
    businessId: widget.business.id,
    employeeId: widget.employee.id,
    serviceId: widget.service.id,
    date: widget.selectedDate,
  );

  final now = DateTime.now();

  return slots
      .where((slot) => slot.startTime.isAfter(now))
      .toList();
}

  Future<void> refreshSlots() async {
    setState(() {
      loadSlots();
    });

    await slotsFuture;
  }

  String formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  String formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day.$month.$year';
  }

  String dayName(DateTime date) {
    switch (date.weekday) {
      case DateTime.monday:
        return 'Pazartesi';
      case DateTime.tuesday:
        return 'Salı';
      case DateTime.wednesday:
        return 'Çarşamba';
      case DateTime.thursday:
        return 'Perşembe';
      case DateTime.friday:
        return 'Cuma';
      case DateTime.saturday:
        return 'Cumartesi';
      case DateTime.sunday:
        return 'Pazar';
      default:
        return '';
    }
  }

  Future<void> goToCustomerInfo(SlotModel slot) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CustomerInfoScreen(
          business: widget.business,
          service: widget.service,
          employee: widget.employee,
          slot: slot,
        ),
      ),
    );

    if (mounted) {
      refreshSlots();
    }
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
              Icons.access_time,
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
                  'Saat Seç',
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
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_month,
                      color: Colors.white70,
                      size: 16,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${formatDate(widget.selectedDate)} • ${dayName(widget.selectedDate)}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: refreshSlots,
            icon: const Icon(
              Icons.refresh,
              color: Colors.white,
            ),
            tooltip: 'Saatleri Yenile',
          ),
        ],
      ),
    );
  }

  Widget buildSelectedInfoCard() {
    final totalMinutes =
        widget.service.durationMinutes + widget.service.bufferMinutes;

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
        child: Column(
          children: [
            buildInfoRow(
              icon: Icons.design_services_outlined,
              title: 'Hizmet',
              value: widget.service.name,
            ),
            const SizedBox(height: 12),
            buildInfoRow(
              icon: Icons.badge_outlined,
              title: 'Çalışan',
              value: widget.employee.fullName,
            ),
            const SizedBox(height: 12),
            buildInfoRow(
              icon: Icons.timer_outlined,
              title: 'Toplam Süre',
              value: '$totalMinutes dakika',
            ),
            const SizedBox(height: 12),
            buildInfoRow(
              icon: Icons.payments_outlined,
              title: 'Fiyat',
              value: '${widget.service.price} TL',
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFEDE9FE),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF7C3AED),
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildSectionTitle(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Uygun Saatler',
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
              '$count saat',
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

  Widget buildSlotCard(SlotModel slot) {
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
            Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDE9FE),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.schedule,
                    color: Color(0xFF7C3AED),
                    size: 31,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Randevu Saati',
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${formatTime(slot.startTime)} - ${formatTime(slot.endTime)}',
                        style: const TextStyle(
                          color: Color(0xFF1F2937),
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      buildMiniChip(
                        icon: Icons.timer_outlined,
                        text: '${slot.totalMinutes} dakika',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => goToCustomerInfo(slot),
                icon: const Icon(Icons.event_available),
                label: const Text(
                  'Bu Saate Randevu Al',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
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
              'Saat seçtikten sonra randevu bilgilerini kontrol edip kapora ile randevunu onaylayacaksın.',
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

  Widget buildEmptySlots() {
    return RefreshIndicator(
      onRefresh: refreshSlots,
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
                  buildSelectedInfoCard(),
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
                          'Uygun saat bulunamadı',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF1F2937),
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Bu tarihte uygun randevu saati yok. Önceki ekrandan farklı bir tarih seçebilirsin.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 18),
                        OutlinedButton.icon(
                          onPressed: refreshSlots,
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
                'Saatler alınamadı',
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
                onPressed: refreshSlots,
                icon: const Icon(Icons.refresh),
                label: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSlotsList(List<SlotModel> slots) {
    return RefreshIndicator(
      onRefresh: refreshSlots,
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
                  buildSelectedInfoCard(),
                  buildSectionTitle(slots.length),
                  ...slots.map(buildSlotCard),
                  buildInfoCard(),
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
        title: const Text('Uygun Randevu Saatleri'),
        actions: const [
    MainMenuButton(),
  ],
      ),
      body: SafeArea(
        child: FutureBuilder<List<SlotModel>>(
          future: slotsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return buildErrorState(snapshot.error!);
            }

            final slots = snapshot.data ?? [];

            if (slots.isEmpty) {
              return buildEmptySlots();
            }

            return buildSlotsList(slots);
          },
        ),
      ),
    );
  }
}