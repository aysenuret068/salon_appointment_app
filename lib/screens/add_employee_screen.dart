import 'package:flutter/material.dart';
import '../widgets/main_menu_button.dart';
import '../models/business_model.dart';
import '../services/api_service.dart';

class AddEmployeeScreen extends StatefulWidget {
  final BusinessModel business;

  const AddEmployeeScreen({
    super.key,
    required this.business,
  });

  @override
  State<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  final ApiService apiService = ApiService();

  final TextEditingController fullNameController = TextEditingController();

  bool isLoading = false;

  Future<void> saveEmployee() async {
    final fullName = fullNameController.text.trim();

    if (fullName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Çalışan adı zorunludur.'),
        ),
      );
      return;
    }

    if (fullName.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Çalışan adı en az 3 karakter olmalı.'),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await apiService.createEmployee(
        businessId: widget.business.id,
        fullName: fullName,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Çalışan başarıyla eklendi.'),
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

  @override
  void dispose() {
    fullNameController.dispose();
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
            Icons.person_add_alt_1,
            size: 42,
            color: Color(0xFF7C3AED),
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Çalışan Ekle',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${widget.business.name} işletmesine yeni çalışan ekle.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget buildEmployeeCard() {
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
              'Çalışan Bilgileri',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Randevularda görünecek çalışan adını gir.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F5FF),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFFEDE9FE),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.storefront,
                    color: Color(0xFF7C3AED),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.business.name,
                      style: const TextStyle(
                        color: Color(0xFF4C1D95),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: fullNameController,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) {
                if (!isLoading) {
                  saveEmployee();
                }
              },
              decoration: const InputDecoration(
                labelText: 'Çalışan Adı Soyadı',
                hintText: 'Örn: Ahmet Yılmaz',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : saveEmployee,
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
                  isLoading ? 'Kaydediliyor...' : 'Çalışanı Kaydet',
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
              'Çalışanı ekledikten sonra ona hizmet atayarak hangi işlemleri yapacağını belirleyebilirsin.',
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
        title: const Text('Çalışan Ekle'),
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
                maxWidth: 520,
              ),
              child: Column(
                children: [
                  buildHeader(),
                  const SizedBox(height: 28),
                  buildEmployeeCard(),
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