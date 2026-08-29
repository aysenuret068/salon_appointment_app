import 'package:flutter/material.dart';
import '../widgets/main_menu_button.dart';
import '../models/business_model.dart';
import '../models/employee_model.dart';
import '../models/service_model.dart';
import '../models/slot_model.dart';
import '../services/api_service.dart';
import '../services/user_session.dart';

class CustomerInfoScreen extends StatefulWidget {
  final BusinessModel business;
  final ServiceModel service;
  final EmployeeModel employee;
  final SlotModel slot;

  const CustomerInfoScreen({
    super.key,
    required this.business,
    required this.service,
    required this.employee,
    required this.slot,
  });

  @override
  State<CustomerInfoScreen> createState() => _CustomerInfoScreenState();
}

class _CustomerInfoScreenState extends State<CustomerInfoScreen> {
  final ApiService apiService = ApiService();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    final user = UserSession.currentUser;

    if (user != null) {
      nameController.text = user.fullName;
      phoneController.text = user.phone;
    }
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

  Future<void> createAppointment() async {
    final customerName = nameController.text.trim();
    final customerPhone = phoneController.text.trim();

    if (customerName.isEmpty || customerPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen ad soyad ve telefon gir.'),
        ),
      );
      return;
    }

    if (customerName.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ad soyad en az 3 karakter olmalı.'),
        ),
      );
      return;
    }

    if (customerPhone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Telefon numarasını doğru gir.'),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await apiService.createAppointment(
        businessId: widget.business.id,
        employeeId: widget.employee.id,
        serviceId: widget.service.id,
        customerUserId: UserSession.currentUser?.userId,
        customerName: customerName,
        customerPhone: customerPhone,
        startTime: widget.slot.startTime,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Randevu başarıyla oluşturuldu.'),
        ),
      );

      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Widget buildHeader() {
    return Column(
      children: [
        Container(
          width: 82,
          height: 82,
          decoration: BoxDecoration(
            color: const Color(0xFFEDE9FE),
            borderRadius: BorderRadius.circular(26),
          ),
          child: const Icon(
            Icons.event_available,
            size: 42,
            color: Color(0xFF7C3AED),
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Randevunu Onayla',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Randevu detaylarını kontrol et ve bilgilerini tamamla.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget infoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: const Color(0xFF7C3AED),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF1F2937),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildAppointmentSummaryCard() {
    final totalMinutes =
        widget.service.durationMinutes + widget.service.bufferMinutes;

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
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Randevu Özeti',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Seçtiğin randevu bilgileri aşağıdadır.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 22),
            infoRow(
              icon: Icons.storefront,
              title: 'İşletme',
              value: widget.business.name,
            ),
            infoRow(
              icon: Icons.design_services_outlined,
              title: 'İşlem',
              value: widget.service.name,
            ),
            infoRow(
              icon: Icons.badge_outlined,
              title: 'Yapacak Çalışan',
              value: widget.employee.fullName,
            ),
            infoRow(
              icon: Icons.calendar_month,
              title: 'Tarih',
              value: formatDate(widget.slot.startTime),
            ),
            infoRow(
              icon: Icons.access_time,
              title: 'Saat',
              value:
                  '${formatTime(widget.slot.startTime)} - ${formatTime(widget.slot.endTime)}',
            ),
            infoRow(
              icon: Icons.timer_outlined,
              title: 'Toplam Süre',
              value: '$totalMinutes dakika',
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPaymentCard() {
    final depositAmount = widget.service.price * 0.10;
    final remainingAmount = widget.service.price - depositAmount;

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
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Ödeme Bilgileri',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Randevunu onaylamak için kapora ödemesi alınır.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 22),
            buildPriceRow(
              title: 'Toplam Ücret',
              value: '${widget.service.price.toStringAsFixed(2)} TL',
              isBold: true,
            ),
            buildPriceRow(
              title: 'Şimdi Ödenecek Kapora',
              value: '${depositAmount.toStringAsFixed(2)} TL',
              isHighlighted: true,
            ),
            buildPriceRow(
              title: 'Randevuda Ödenecek Kalan',
              value: '${remainingAmount.toStringAsFixed(2)} TL',
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPriceRow({
    required String title,
    required String value,
    bool isBold = false,
    bool isHighlighted = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isHighlighted ? const Color(0xFFEDE9FE) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isHighlighted ? const Color(0xFFC4B5FD) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: isHighlighted
                    ? const Color(0xFF4C1D95)
                    : const Color(0xFF374151),
                fontWeight: isBold || isHighlighted
                    ? FontWeight.bold
                    : FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isHighlighted
                  ? const Color(0xFF4C1D95)
                  : const Color(0xFF111827),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCustomerFormCard() {
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
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Müşteri Bilgileri',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Randevu için ad soyad ve telefon bilgini kontrol et.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 22),
            TextField(
              controller: nameController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Ad Soyad',
                hintText: 'Adını ve soyadını gir',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) {
                if (!isLoading) {
                  createAppointment();
                }
              },
              decoration: const InputDecoration(
                labelText: 'Telefon',
                hintText: '05555555555',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : createAppointment,
                icon: isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.verified_outlined),
                label: Text(
                  isLoading
                      ? 'Randevu oluşturuluyor...'
                      : 'Kaporayı Öde ve Randevuyu Onayla',
                  style: const TextStyle(
                    fontSize: 15,
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

  Widget buildCancelRuleCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFFED7AA),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFEA580C),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'İptal Kuralı: Randevudan en az 24 saat önce iptal edilirse kapora iade edilir. Son 24 saat içinde iptal edilirse veya müşteri gelmezse kapora iade edilmez.',
              style: TextStyle(
                color: Color(0xFF9A3412),
                fontWeight: FontWeight.w600,
                height: 1.35,
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
        title: const Text('Randevu Bilgileri'),
         actions: const [
        MainMenuButton(),
      ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 620,
              ),
              child: Column(
                children: [
                  buildHeader(),
                  const SizedBox(height: 28),
                  buildAppointmentSummaryCard(),
                  const SizedBox(height: 14),
                  buildPaymentCard(),
                  const SizedBox(height: 14),
                  buildCancelRuleCard(),
                  const SizedBox(height: 14),
                  buildCustomerFormCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}