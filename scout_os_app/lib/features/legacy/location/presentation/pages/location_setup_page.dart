import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:scout_os_app/core/widgets/duo_button.dart';
import 'package:scout_os_app/features/auth/logic/auth_controller.dart';
import 'package:scout_os_app/features/location/data/location_repository.dart';
import 'package:scout_os_app/features/location/logic/location_controller.dart';
import 'package:scout_os_app/core/widgets/duo_main_scaffold.dart';

class LocationSetupPage extends StatefulWidget {
  const LocationSetupPage({super.key});

  @override
  State<LocationSetupPage> createState() => _LocationSetupPageState();
}

class _LocationSetupPageState extends State<LocationSetupPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationController>().fetchCountries();
    });
  }

  void _onFinish() async {
    final locCtrl = context.read<LocationController>();
    final success = await locCtrl.saveLocation();

    if (!mounted) return;

    if (success) {
      // Show success dialog or snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lokasi berhasil disimpan! Selamat datang!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // We must reload AuthController to get the new ApiUser with locationSet = true
      final authCtrl = context.read<AuthController>();
      await authCtrl.tryAutoLogin();

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DuoMainScaffold()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(locCtrl.errorMessage ?? 'Gagal menyimpan lokasi'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Consumer<LocationController>(
          builder: (context, controller, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Pilih Lokasimu! 📍',
                    style: GoogleFonts.nunito(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF2C3E50),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Kami perlu tahu lokasimu untuk menempatkanmu di Arena dan Grup Chat yang tepat.',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Country Dropdown (NEW — first in cascade)
                  _buildDropdown(
                    hint: 'Pilih Negara',
                    items: controller.countryList,
                    selectedItem: controller.selectedCountry,
                    onChanged: (val) {
                      if (val != null) controller.selectCountry(val);
                    },
                    isLoading: controller.isLoading && controller.countryList.isEmpty,
                  ),
                  const SizedBox(height: 16),

                  // Provinsi Dropdown
                  _buildDropdown(
                    key: ValueKey('prov_${controller.selectedCountry?.id ?? 'none'}_${controller.provinsiList.length}'),
                    hint: 'Pilih Provinsi',
                    items: controller.provinsiList,
                    selectedItem: controller.selectedProvinsi,
                    onChanged: (val) {
                      if (val != null) controller.selectProvinsi(val);
                    },
                    isLoading: controller.isLoading && controller.provinsiList.isEmpty,
                  ),
                  const SizedBox(height: 16),

                  // Kabupaten Dropdown
                  _buildDropdown(
                    key: ValueKey('kab_${controller.selectedProvinsi?.id ?? 'none'}_${controller.kabupatenList.length}'),
                    hint: 'Pilih Kabupaten/Kota',
                    items: controller.kabupatenList,
                    selectedItem: controller.selectedKabupaten,
                    onChanged: (val) {
                      if (val != null) controller.selectKabupaten(val);
                    },
                    enabled: controller.selectedProvinsi != null,
                    isLoading: controller.isLoading && controller.selectedProvinsi != null && controller.kabupatenList.isEmpty,
                  ),
                  const SizedBox(height: 16),

                  // Kecamatan Dropdown
                  _buildDropdown(
                    key: ValueKey('kec_${controller.selectedKabupaten?.id ?? 'none'}_${controller.kecamatanList.length}'),
                    hint: 'Pilih Kecamatan',
                    items: controller.kecamatanList,
                    selectedItem: controller.selectedKecamatan,
                    onChanged: (val) {
                      if (val != null) controller.selectKecamatan(val);
                    },
                    enabled: controller.selectedKabupaten != null,
                    isLoading: controller.isLoading && controller.selectedKabupaten != null && controller.kecamatanList.isEmpty,
                  ),
                   
                  const SizedBox(height: 32),
                  
                  if (controller.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        controller.errorMessage!,
                        style: GoogleFonts.nunito(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  DuoButton(
                    text: 'Lanjutkan',
                    onPressed: (controller.selectedKecamatan != null || (controller.selectedCountry != null && controller.provinsiList.isEmpty)) && !controller.isLoading
                        ? _onFinish
                        : null,
                    variant: DuoButtonVariant.green,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDropdown({
    Key? key,
    required String hint,
    required List<LocationOption> items,
    required LocationOption? selectedItem,
    required void Function(LocationOption?) onChanged,
    bool enabled = true,
    bool isLoading = false,
  }) {
    return Container(
      key: key,
      decoration: BoxDecoration(
        color: enabled ? Colors.white : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: enabled ? const Color(0xFFE5E5E5) : Colors.transparent,
          width: 2,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: isLoading
          ? const Padding(
              padding: EdgeInsets.all(12.0),
              child: Center(child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2))),
            )
          : DropdownButtonHideUnderline(
              child: DropdownButton<LocationOption>(
                isExpanded: true,
                hint: Text(
                  hint,
                  style: GoogleFonts.nunito(
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                value: selectedItem,
                items: items.map((e) {
                  return DropdownMenuItem<LocationOption>(
                    value: e,
                    child: Text(
                      e.name,
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF4B4B4B),
                      ),
                    ),
                  );
                }).toList(),
                onChanged: enabled ? onChanged : null,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
              ),
            ),
    );
  }
}
