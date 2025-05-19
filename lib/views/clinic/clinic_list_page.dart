// lib/views/clinic/clinic_list_page.dart

import 'package:flutter/material.dart';
import 'package:pet_clinic_app/views/clinic/clinic_list_view_model.dart';
import 'package:pet_clinic_app/views/clinic/widgets/clinic_list_item.dart';
import 'package:provider/provider.dart';

class ClinicListPage extends StatelessWidget {
  const ClinicListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ClinicListViewModel>(
      create: (_) => ClinicListViewModel()..initialize(),
      child: Consumer<ClinicListViewModel>(
        builder: (context, vm, _) {
          return Column(
            children: [
              // ✅ 搜尋框
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: '搜尋診所名稱或地址',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onChanged: vm.search,
                ),
              ),

              // ✅ 清單內容
              Expanded(
                child: vm.isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.orange))
                    : ListView.builder(
                        itemCount: vm.filteredClinics.length,
                        itemBuilder: (context, index) {
                          final clinic = vm.filteredClinics[index];
                          return ClinicListItem(
                            clinic: clinic,
                            onCall: () => vm.callClinic(clinic.phone),
                            onNavigate: () => vm.navigateToClinic(clinic),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
