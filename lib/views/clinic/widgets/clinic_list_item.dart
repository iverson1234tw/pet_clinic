// lib/views/clinic/widgets/clinic_list_item.dart

import 'package:flutter/material.dart';
import 'package:pet_clinic_app/models/clinic_model.dart';

/// 單筆診所清單 UI 元件
class ClinicListItem extends StatelessWidget {
  final Clinic clinic;
  final VoidCallback onCall;
  final VoidCallback onNavigate;

  const ClinicListItem({
    super.key,
    required this.clinic,
    required this.onCall,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final bool isOpen = true;
    final Color statusColor = isOpen ? Colors.green : Colors.red;
    final String statusText = isOpen ? '營業中' : '已打烊';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          title: Text(
            clinic.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(clinic.address),
              const SizedBox(height: 4),
              Text('電話：${clinic.phone}'),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  border: Border.all(color: statusColor, width: 1.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: onNavigate,
                icon: const Icon(Icons.navigation, color: Colors.orange),
              ),
              IconButton(
                onPressed: onCall,
                icon: const Icon(Icons.phone, color: Colors.orange),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
