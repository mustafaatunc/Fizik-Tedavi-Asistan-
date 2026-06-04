import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // YENİ: Titreşim hissi için eklendi
import 'dart:ui';
import 'home_screen.dart';
import 'catalog_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';

class MainContainer extends StatefulWidget {
  const MainContainer({Key? key}) : super(key: key);

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  int _seciliSekme = 0;

  final List<Widget> _sekmeSayfalari = [
    const HomeScreen(),
    const CatalogScreen(),
    const HistoryScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // YENİ: Geri Tuşu Güvenliği (PopScope)
    return PopScope(
      canPop: _seciliSekme == 0,
      onPopInvoked: (didPop) {
        if (didPop) return;

        // Eğer ana ekranda (0) değilsek, geri tuşu bizi ana ekrana atsın. Uygulama kapanmasın!
        if (_seciliSekme != 0) {
          setState(() {
            _seciliSekme = 0;
          });
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6FA),
        extendBody:
            true, // Arka planın menünün altına uzamasını sağlar (Premium Hissiyat)
        body: IndexedStack(index: _seciliSekme, children: _sekmeSayfalari),
        bottomNavigationBar: _buildFloatingBottomNav(),
      ),
    );
  }

  Widget _buildFloatingBottomNav() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 24,
        right: 24,
        bottom: 30,
      ), // Havada süzülme boşluğu
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 20,
            sigmaY: 20,
          ), // Cam efekti bulanıklığı
          child: Container(
            height: 75,
            decoration: BoxDecoration(
              color: const Color(
                0xFF1E2022,
              ).withOpacity(0.85), // Koyu premium arka plan
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(Icons.dashboard_rounded, "Panorama", 0),
                _buildNavItem(Icons.fitness_center_rounded, "Katalog", 1),
                _buildNavItem(Icons.trending_up_rounded, "İlerleme", 2),
                _buildNavItem(Icons.person_rounded, "Profil", 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isSelected = _seciliSekme == index;

    return GestureDetector(
      onTap: () {
        if (_seciliSekme != index) {
          // YENİ: Sekmeler arası geçişte Apple/Premium hisli ufak "Tık" titreşimi
          HapticFeedback.selectionClick();
          setState(() => _seciliSekme = index);
        }
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutQuint,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF4A00E0).withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.2 : 1.0, // Seçilince ikon büyür
              duration: const Duration(milliseconds: 300),
              child: Icon(
                icon,
                color: isSelected
                    ? const Color(0xFF00C9FF)
                    : Colors.grey.shade500,
                size: 26,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(height: 5),
              Container(
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  color: Color(0xFF00C9FF),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Color(0xFF00C9FF), blurRadius: 5),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
