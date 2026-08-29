import 'package:flutter/material.dart';
import '../widgets/main_menu_button.dart';
import '../models/business_model.dart';
import '../services/api_service.dart';

class EditBusinessScreen extends StatefulWidget {
  final BusinessModel business;

  const EditBusinessScreen({
    super.key,
    required this.business,
  });

  @override
  State<EditBusinessScreen> createState() => _EditBusinessScreenState();
}

class _EditBusinessScreenState extends State<EditBusinessScreen> {
  final ApiService apiService = ApiService();

  late TextEditingController nameController;
  late TextEditingController addressController;
  late TextEditingController phoneController;
  late TextEditingController openTimeController;
  late TextEditingController closeTimeController;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(
      text: widget.business.name,
    );

    addressController = TextEditingController(
      text: widget.business.address ?? '',
    );

    phoneController = TextEditingController(
      text: widget.business.phone ?? '',
    );

    openTimeController = TextEditingController(
      text: widget.business.openTime ?? '09:00:00',
    );

    closeTimeController = TextEditingController(
      text: widget.business.closeTime ?? '18:00:00',
    );
  }

  Future<void> updateBusiness() async {
    final name = nameController.text.trim();
    final address = addressController.text.trim();
    final phone = phoneController.text.trim();
    final openTime = openTimeController.text.trim();
    final closeTime = closeTimeController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('İşletme adı zorunludur.'),
        ),
      );
      return;
    }

    if (openTime.isEmpty || closeTime.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Açılış ve kapanış saatini gir.'),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await apiService.updateBusiness(
        businessId: widget.business.id,
        name: name,
        address: address,
        phone: phone,
        openTime: openTime,
        closeTime: closeTime,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('İşletme bilgileri güncellendi.'),
        ),
      );

      Navigator.pop(context, true);
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

  Future<void> pickTime({
    required TextEditingController controller,
    required TimeOfDay initialTime,
  }) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (pickedTime == null) return;

    final hour = pickedTime.hour.toString().padLeft(2, '0');
    final minute = pickedTime.minute.toString().padLeft(2, '0');

    controller.text = '$hour:$minute:00';
  }

  TimeOfDay parseTime(String value, TimeOfDay fallback) {
    try {
      final parts = value.split(':');

      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      return TimeOfDay(
        hour: hour,
        minute: minute,
      );
    } catch (_) {
      return fallback;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    phoneController.dispose();
    openTimeController.dispose();
    closeTimeController.dispose();
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
            Icons.edit_location_alt_outlined,
            size: 42,
            color: Color(0xFF7C3AED),
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'İşletme Bilgilerini Düzenle',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'İşletmenin görünen bilgilerini ve çalışma saatlerini güncelle.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget buildEditCard() {
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
              'İşletme Bilgileri',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Müşterilerin göreceği bilgileri buradan düzenleyebilirsin.',
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
                labelText: 'İşletme Adı',
                hintText: 'Örn: Kral Berber',
                prefixIcon: Icon(Icons.store_outlined),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: addressController,
              minLines: 1,
              maxLines: 3,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Adres',
                hintText: 'Mahalle, cadde, sokak bilgisi',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Telefon',
                hintText: '05555555555',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: openTimeController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Açılış Saati',
                      hintText: '09:00:00',
                      prefixIcon: Icon(Icons.access_time),
                    ),
                    onTap: isLoading
                        ? null
                        : () {
                            pickTime(
                              controller: openTimeController,
                              initialTime: parseTime(
                                openTimeController.text,
                                const TimeOfDay(hour: 9, minute: 0),
                              ),
                            );
                          },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: closeTimeController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Kapanış Saati',
                      hintText: '18:00:00',
                      prefixIcon: Icon(Icons.schedule),
                    ),
                    onTap: isLoading
                        ? null
                        : () {
                            pickTime(
                              controller: closeTimeController,
                              initialTime: parseTime(
                                closeTimeController.text,
                                const TimeOfDay(hour: 18, minute: 0),
                              ),
                            );
                          },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : updateBusiness,
                icon: isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(
                  isLoading ? 'Güncelleniyor...' : 'Bilgileri Güncelle',
                  style: const TextStyle(
                    fontSize: 16,
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

  Widget buildInfoCard() {
    return Container(
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
              'Güncel işletme bilgileri müşteri tarafındaki işletme listesinde görüntülenir.',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5FF),
      appBar: AppBar(
        title: const Text('İşletmeyi Düzenle'),
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
                maxWidth: 560,
              ),
              child: Column(
                children: [
                  buildHeader(),
                  const SizedBox(height: 28),
                  buildEditCard(),
                  const SizedBox(height: 16),
                  buildInfoCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}