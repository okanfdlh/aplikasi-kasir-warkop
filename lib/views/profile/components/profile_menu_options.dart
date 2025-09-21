import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../core/constants/constants.dart';
// import '../../../core/routes/app_routes.dart';
import 'profile_list_tile.dart';

class ProfileMenuOptions extends StatelessWidget {
  const ProfileMenuOptions({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppDefaults.padding),
      padding: const EdgeInsets.all(AppDefaults.padding),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: AppDefaults.boxShadow,
        borderRadius: AppDefaults.borderRadius,
      ),
      child: Column(
        children: [
          ProfileListTile(
            title: 'Profil Warung',
            // icon: AppIcons.profilePerson,
            onTap: () => Get.toNamed('/my_profile'),
          ),
          const Divider(thickness: 0.1),
          ProfileListTile(
            title: 'Pendapatan',
            // icon: AppIcons.profilePendapatan,
            onTap: () => Get.toNamed('/laporan_pendapatan'),
          ),
          const Divider(thickness: 0.1),
          ProfileListTile(
            title: 'Pesanan',
            // icon: AppIcons.profileNotification,
            onTap: () => Get.toNamed('/order'),
          ),
          const Divider(thickness: 0.1),
          ProfileListTile(
            title: 'Notifikasi',
            // icon: AppIcons.profileNotification,
            onTap: () =>
                Navigator.of(context).pushReplacementNamed('/dashboard'),
          ),
          const Divider(thickness: 0.1),
          ProfileListTile(
            title: 'Pengaturan',
            // icon: AppIcons.profileSetting,
            onTap: () =>
                Navigator.of(context).pushReplacementNamed('/dashboard'),
          ),
          const Divider(thickness: 0.1),
          const ProfileListTile(
            title: 'Logout',
            // icon: AppIcons.profileLogout,
            onTap: _showLogoutDialogModern,
          ),
        ],
      ),
    );
  }
}

// void _showLogoutDialog() {
//   Get.dialog(
//     AlertDialog(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(20),
//       ),
//       elevation: 8,
//       backgroundColor: Colors.white,
//       contentPadding: const EdgeInsets.all(24),
//       titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
//       actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
//       title: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: Colors.red.shade50,
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Icon(
//               Icons.logout_rounded,
//               color: Colors.red.shade600,
//               size: 24,
//             ),
//           ),
//           const SizedBox(width: 12),
//           const Expanded(
//             child: Text(
//               "Konfirmasi Logout",
//               style: TextStyle(
//                 fontWeight: FontWeight.w600,
//                 fontSize: 18,
//                 color: Color(0xFF1A1A1A),
//               ),
//             ),
//           ),
//         ],
//       ),
//       content: const Text(
//         "Apakah Anda yakin ingin keluar dari aplikasi? Anda perlu login kembali untuk mengakses akun.",
//         style: TextStyle(
//           fontSize: 14,
//           color: Color(0xFF666666),
//           height: 1.5,
//         ),
//       ),
//       actions: [
//         Row(
//           children: [
//             Expanded(
//               child: TextButton(
//                 style: TextButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 12),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     side: BorderSide(
//                       color: Colors.grey.shade300,
//                       width: 1,
//                     ),
//                   ),
//                 ),
//                 onPressed: () => Get.back(),
//                 child: const Text(
//                   "Batal",
//                   style: TextStyle(
//                     color: Color(0xFF666666),
//                     fontWeight: FontWeight.w500,
//                     fontSize: 14,
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.red.shade600,
//                   foregroundColor: Colors.white,
//                   elevation: 0,
//                   padding: const EdgeInsets.symmetric(vertical: 12),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 onPressed: () {
//                   Get.back();
//                   _logout();
//                 },
//                 child: const Text(
//                   "Ya, Logout",
//                   style: TextStyle(
//                     fontWeight: FontWeight.w600,
//                     fontSize: 14,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ],
//     ),
//     barrierDismissible: false,
//     barrierColor: Colors.black54,
//   );
// }

// Alternatif dengan animasi dan desain yang lebih modern
void _showLogoutDialogModern() {
  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      elevation: 16,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon dengan animasi
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red.shade400, Colors.red.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(32),
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            const Text(
              "Konfirmasi Logout",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 12),

            // Description
            const Text(
              "Anda akan keluar dari akun dan perlu login kembali untuk mengakses aplikasi.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      side: BorderSide(
                        color: Colors.grey.shade300,
                        width: 1.5,
                      ),
                    ),
                    onPressed: () => Get.back(),
                    child: const Text(
                      "Batal",
                      style: TextStyle(
                        color: Color(0xFF666666),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      Get.back();
                      _logout();
                    },
                    child: const Text(
                      "Ya, Logout",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.5),
  );
}

void _logout() {
  // 🔹 Panggil controller logout (misalnya AuthController)
  // final authController = Get.find<AuthController>();
  // authController.logout();

  // Untuk demo aku langsung redirect ke login page
  Get.offAllNamed('/login');
}
