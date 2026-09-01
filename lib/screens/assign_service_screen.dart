import 'package:flutter/material.dart';
import '../widgets/main_menu_button.dart';
import '../models/business_model.dart';
import '../models/employee_model.dart';
import '../models/service_model.dart';
import '../services/api_service.dart';

class AssignServiceScreen extends StatefulWidget {
  final BusinessModel business;

  const AssignServiceScreen({
    super.key,
    required this.business,
  });

  @override
  State<AssignServiceScreen> createState() => _AssignServiceScreenState();
}

class _AssignServiceScreenState extends State<AssignServiceScreen> {
  final ApiService apiService = ApiService();

  List<EmployeeModel> employees = [];
  List<ServiceModel> services = [];

  int? selectedEmployeeId;
  int? selectedServiceId;

  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final loadedEmployees =
          await apiService.getEmployeesByBusiness(widget.business.id);

      final loadedServices =
          await apiService.getServicesByBusiness(widget.business.id);

      if (!mounted) return;

      setState(() {
        employees = loadedEmployees;
        services = loadedServices;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  Future<void> assignService() async {
    if (employees.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Önce çalışan eklemelisin.'),
        ),
      );
      return;
    }

    if (services.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Önce hizmet eklemelisin.'),
        ),
      );
      return;
    }

    if (selectedEmployeeId == null || selectedServiceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Çalışan ve hizmet seçmelisin.'),
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      await apiService.assignServiceToEmployee(
        employeeId: selectedEmployeeId!,
        serviceId: selectedServiceId!,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hizmet çalışana başarıyla atandı.'),
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
          isSaving = false;
        });
      }
    }
  }

  EmployeeModel? get selectedEmployee {
    try {
      return employees.firstWhere((x) => x.id == selectedEmployeeId);
    } catch (_) {
      return null;
    }
  }

  ServiceModel? get selectedService {
    try {
      return services.firstWhere((x) => x.id == selectedServiceId);
    } catch (_) {
      return null;
    }
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
            Icons.link,
            size: 42,
            color: Color(0xFF7C3AED),
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Çalışana Hizmet Ata',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${widget.business.name} işletmesinde hangi çalışan hangi hizmeti yapıyor belirle.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget buildBusinessInfoBox() {
    return Container(
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
    );
  }

  Widget buildEmptyWarning() {
    if (employees.isEmpty && services.isEmpty) {
      return buildWarningBox(
        'Önce bu işletmeye çalışan ve hizmet eklemelisin.',
      );
    }

    if (employees.isEmpty) {
      return buildWarningBox(
        'Bu işletmede çalışan yok. Önce çalışan eklemelisin.',
      );
    }

    if (services.isEmpty) {
      return buildWarningBox(
        'Bu işletmede hizmet yok. Önce hizmet eklemelisin.',
      );
    }

    return const SizedBox.shrink();
  }

  Widget buildWarningBox(String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFFED7AA),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFEA580C),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFF9A3412),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildAssignCard() {
    final canSave = employees.isNotEmpty && services.isNotEmpty && !isSaving;

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
              'Atama Bilgileri',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Bir çalışan seç ve ona yapabileceği hizmeti ata.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 22),
            buildBusinessInfoBox(),
            const SizedBox(height: 18),
            buildEmptyWarning(),
            DropdownButtonFormField<int>(
              initialValue: selectedEmployeeId,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Çalışan Seç',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
              items: employees.map((employee) {
                return DropdownMenuItem<int>(
                  value: employee.id,
                  child: Text(
                    employee.fullName,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: canSave
                  ? (value) {
                      setState(() {
                        selectedEmployeeId = value;
                      });
                    }
                  : null,
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<int>(
              initialValue: selectedServiceId,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Hizmet Seç',
                prefixIcon: Icon(Icons.design_services_outlined),
              ),
              items: services.map((service) {
                final totalMinutes =
                    service.durationMinutes + service.bufferMinutes;

                return DropdownMenuItem<int>(
                  value: service.id,
                  child: Text(
                    '${service.name} • $totalMinutes dk • ${service.price} TL',
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: canSave
                  ? (value) {
                      setState(() {
                        selectedServiceId = value;
                      });
                    }
                  : null,
            ),
            const SizedBox(height: 18),
            buildSelectedPreview(),
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: canSave ? assignService : null,
                icon: isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_circle_outline),
                label: Text(
                  isSaving ? 'Atanıyor...' : 'Hizmeti Ata',
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

  Widget buildSelectedPreview() {
    final employee = selectedEmployee;
    final service = selectedService;

    if (employee == null && service == null) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFE5E7EB),
          ),
        ),
        child: const Row(
          children: [
            Icon(
              Icons.touch_app_outlined,
              color: Color(0xFF6B7280),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Seçim yaptığında atama özeti burada görünecek.',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEDE9FE),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Atama Özeti',
            style: TextStyle(
              color: Color(0xFF4C1D95),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.person_outline,
                size: 18,
                color: Color(0xFF7C3AED),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  employee?.fullName ?? 'Çalışan seçilmedi',
                  style: const TextStyle(
                    color: Color(0xFF4C1D95),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.spa_outlined,
                size: 18,
                color: Color(0xFF7C3AED),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  service?.name ?? 'Hizmet seçilmedi',
                  style: const TextStyle(
                    color: Color(0xFF4C1D95),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
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
              'Müşteri randevu alırken sadece seçtiği hizmeti yapabilen çalışanları görecek.',
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

  Widget buildLoadingScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5FF),
      appBar: AppBar(
        title: const Text('Çalışana Hizmet Ata'),
        actions: const [
    MainMenuButton(),
  ],
      ),
      body: const SafeArea(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return buildLoadingScreen();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5FF),
      appBar: AppBar(
        title: const Text('Çalışana Hizmet Ata'),
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
                  buildAssignCard(),
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
