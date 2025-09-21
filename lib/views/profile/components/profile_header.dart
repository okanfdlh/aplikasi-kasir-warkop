import 'package:flutter/material.dart';

import '../../../core/constants/constants.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        /// Background diganti warna + border radius bawah cembung
        Container(
          height: 250, // tinggi background, bisa disesuaikan
          width: double.infinity,
          decoration: const BoxDecoration(
            color: const Color(0xff024924), // ganti warna sesuai tema lo
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(80), // makin besar makin cembung
              bottomRight: Radius.circular(80),
            ),
          ),
        ),

        /// Content
        Column(
          children: [
            AppBar(
              // title: const Text('Profile'),
              elevation: 0,
              backgroundColor: Colors.transparent,
              titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const _UserData(),
            // const ProfileHeaderOptions()
          ],
        ),
      ],
    );
  }
}

class _UserData extends StatelessWidget {
  const _UserData();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDefaults.padding),
      child: Row(
        children: [
          const SizedBox(width: AppDefaults.padding),
          SizedBox(
            width: 100,
            height: 100,
            child: ClipOval(
              child: AspectRatio(
                aspectRatio: 1 / 1,
                child: Image.asset(
                  'assets/icon/app_icon.png', // ganti dengan gambar lo
                  height: 40,
                  width: 40,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppDefaults.padding),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rumah Seduh',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                'Sungailiat, Bangka Belitung',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: Colors.white),
              ),
            ],
          )
        ],
      ),
    );
  }
}
