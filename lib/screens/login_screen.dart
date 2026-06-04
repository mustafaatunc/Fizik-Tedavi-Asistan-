import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'main_container.dart'; // Kendi dosya yoluna göre düzenleyebilirsin

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _adController = TextEditingController();

  String _seciliOdak = 'Genel Fitness';
  String _seciliSeviye = 'Yeni Başlayan';
  String _seciliHedef = 'Formda Kalmak';

  final List<String> _odakAlanlari = [
    'Kol & Omuz',
    'Bacak & Kalça',
    'Karın (Core)',
    'Genel Fitness',
  ];
  final List<String> _seviyeler = [
    'Yeni Başlayan',
    'Orta Seviye',
    'İleri Düzey',
  ];
  final List<String> _hedefler = [
    'Yağ Yakmak',
    'Kas Geliştirmek',
    'Formda Kalmak',
    'Dayanıklılık Artırmak',
  ];

  void _basla() {
    if (_adController.text.trim().isNotEmpty) {
      var box = Hive.box('userProfile');
      box.put('ad', _adController.text.trim());
      box.put('ana_odak', _seciliOdak);
      box.put('seviye', _seciliSeviye);
      box.put('hedef', _seciliHedef);
      box.put('isLoggedIn', true);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainContainer()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Yapay zeka analiz için ismine ihtiyaç duyuyor!',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildAIAttributeDropdown(
    String label,
    String value,
    List<String> items,
    Function(String?) onChanged,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: DropdownButtonFormField<String>(
        value: value,
        dropdownColor: const Color(0xFF1E293B),
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: Color(0xFF00E5FF),
        ),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Colors.white54,
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: Icon(icon, color: const Color(0xFF00E5FF)),
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
        ),
        items: items
            .map((String val) => DropdownMenuItem(value: val, child: Text(val)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E5FF).withOpacity(0.1),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00E5FF).withOpacity(0.2),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.psychology_rounded,
                    size: 70,
                    color: Color(0xFF00E5FF),
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  "Başlarken",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Lütfen bu bilgileri doldur.",
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                TextField(
                  controller: _adController,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    labelText: "İsmin (Kullanıcı Adı)",
                    labelStyle: const TextStyle(
                      color: Colors.white54,
                      fontWeight: FontWeight.w600,
                    ),
                    prefixIcon: const Icon(
                      Icons.person_rounded,
                      color: Color(0xFF00E5FF),
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                _buildAIAttributeDropdown(
                  "Ana Odak Noktan",
                  _seciliOdak,
                  _odakAlanlari,
                  (val) => setState(() => _seciliOdak = val!),
                  Icons.filter_center_focus_rounded,
                ),
                _buildAIAttributeDropdown(
                  "Mevcut Fitness Seviyen",
                  _seciliSeviye,
                  _seviyeler,
                  (val) => setState(() => _seciliSeviye = val!),
                  Icons.battery_charging_full_rounded,
                ),
                _buildAIAttributeDropdown(
                  "Birincil Hedefin",
                  _seciliHedef,
                  _hedefler,
                  (val) => setState(() => _seciliHedef = val!),
                  Icons.flag_rounded,
                ),

                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E5FF),
                      elevation: 10,
                      shadowColor: const Color(0xFF00E5FF).withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: _basla,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Başla",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(width: 10),
                        Icon(Icons.arrow_forward_rounded, color: Colors.black),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
