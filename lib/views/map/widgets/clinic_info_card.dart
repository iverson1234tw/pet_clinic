import 'package:flutter/material.dart';

class ClinicInfoCard extends StatelessWidget {
  final String name;
  final String address;
  final String phone;
  final VoidCallback onNavigate;
  final VoidCallback onCall;

  /// ✅ 可選：愛心按下行為（你可傳 null 或加收藏邏輯）
  final VoidCallback? onFavorite;
  final bool isFavorited;

  const ClinicInfoCard({
    super.key,
    required this.name,
    required this.address,
    required this.phone,
    required this.onNavigate,
    required this.onCall,
    this.onFavorite,
    this.isFavorited = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ✅ 第一行：標題 + 愛心按鈕
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ✅ 標題
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // ✅ 愛心按鈕
                GestureDetector(
                  onTap: onFavorite,
                  child: Icon(
                    isFavorited ? Icons.favorite : Icons.favorite_border,
                    color: isFavorited ? Colors.red : Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // ✅ 地址
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                address,
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ),
            const SizedBox(height: 4),

            // ✅ 電話
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '電話：$phone',
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 12),

            // ✅ 導航與通話按鈕
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: onNavigate,
                  icon: const Icon(Icons.navigation),
                  label: const Text('導航'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: onCall,
                  icon: const Icon(Icons.phone),
                  label: const Text('通話'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
