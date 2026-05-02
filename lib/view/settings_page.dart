// lib/view/settings_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/settings_service.dart';
import '../utils/theme_helper.dart';

  void _confirmReset(BuildContext context, SettingsService settings) {
    final c = context.colors;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: c.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),

        title: Text(
          'Reset Pengaturan?',
          style: TextStyle(
              color: c.onSurface,
              fontWeight: FontWeight.bold),
        ),

        content: Text(
          'Semua pengaturan akan dikembalikan ke awal, termasuk notifikasi shalat.',
          style: TextStyle(color: c.textSecondary),
        ),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal',
                style: TextStyle(color: c.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              settings.resetAll();
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pengaturan berhasil direset'),
                  backgroundColor: kTeal,
                ),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
  
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c        = context.colors;
    final settings = context.watch<SettingsService>();

    return Scaffold(
      backgroundColor: c.background,   // ← ubah ini
      appBar: AppBar(
        title: const Text('Pengaturan'),
        backgroundColor: kTealDark,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [

          // ── NOTIFIKASI SHALAT ─────────────────────────
          _SectionHeader('Notifikasi Shalat', c),
          const SizedBox(height: 8),

          _SettingsCard(
            c: c,
            children: [
              _waktuTile(context, settings, 'imsak',
                  Icons.alarm, const Color(0xFF00695C), 'Imsak',
                  'Pengingat sebelum sahur berakhir'),
              _divider(c),
              _waktuTile(context, settings, 'subuh',
                  Icons.wb_twilight_rounded, const Color(0xFF1565C0), 'Subuh',
                  'Awal waktu shalat Subuh'),
              _divider(c),
              _waktuTile(context, settings, 'terbit',
                  Icons.wb_sunny, const Color(0xFFF57F17), 'Terbit',
                  'Matahari terbit — batas akhir Subuh'),
              _divider(c),
              _waktuTile(context, settings, 'dhuha',
                  Icons.wb_sunny_outlined, const Color(0xFFFFB300), 'Dhuha',
                  '± 20 menit setelah matahari terbit'),
              _divider(c),
              _waktuTile(context, settings, 'dzuhur',
                  Icons.wb_sunny_rounded, const Color(0xFFE8650A), 'Dzuhur',
                  'Tengah hari'),
              _divider(c),
              _waktuTile(context, settings, 'ashar',
                  Icons.cloud_rounded, const Color(0xFF6D4C41), 'Ashar',
                  'Sore hari'),
              _divider(c),
              _waktuTile(context, settings, 'maghrib',
                  Icons.nights_stay_rounded, const Color(0xFF7B1FA2), 'Maghrib',
                  'Saat matahari terbenam'),
              _divider(c),
              _waktuTile(context, settings, 'isya',
                  Icons.nightlight_round, const Color(0xFF0D47A1), 'Isya',
                  'Malam hari'),
            ],
          ),

          const SizedBox(height: 20),

          // ── TAMPILAN ─────────────────────────
          _SectionHeader('Tampilan', c),
          const SizedBox(height: 8),

          _SettingsCard(
            c: c,
            children: [
              _SwitchTile(
                icon: Icons.dark_mode_rounded,
                iconColor: const Color(0xFF5C6BC0),
                title: 'Mode Gelap',
                subtitle: 'Tampilan gelap untuk kenyamanan mata',
                value: settings.darkMode,
                onChanged: (v) => settings.setDarkMode(v),
                c: c,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── FONT QURAN ─────────────────────────
          _SettingsCard(
            c: c,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: kTeal.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.text_fields_rounded,
                          color: kTeal, size: 20),
                    ),
                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Ukuran Font Al-Qur\'an',
                              style: TextStyle(
                                  color: c.onSurface,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14)),
                          Text('Ukuran teks Arab',
                              style: TextStyle(
                                  color: c.textSecondary,
                                  fontSize: 12)),
                        ],
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: kTeal.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${settings.quranFontSize.round()}px',
                        style: const TextStyle(
                          color: kTeal,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Slider(
                value: settings.quranFontSize,
                min: 18,
                max: 42,
                divisions: 8,
                activeColor: kTeal,
                onChanged: (v) => settings.setQuranFontSize(v),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: c.isDark
                        ? c.surfaceVariant
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'بِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحِيْمِ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: settings.quranFontSize,
                      color: c.onSurface,
                      fontFamily: 'Amiri',
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── BAHASA ─────────────────────────
          _SectionHeader('Bahasa', c),
          const SizedBox(height: 8),

          _SettingsCard(
            c: c,
            children: [
              _LangTile(
                  lang: 'id',
                  label: '🇮🇩 Indonesia',
                  settings: settings,
                  c: c),
              _divider(c),
              _LangTile(
                  lang: 'en',
                  label: '🇬🇧 English',
                  settings: settings,
                  c: c),
            ],
          ),

          const SizedBox(height: 40),

          const SizedBox(height: 20),

        // ── RESET ─────────────────────────
        _SectionHeader('Lainnya', c),
        const SizedBox(height: 8),

        _SettingsCard(
          c: c,
          children: [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),

              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.refresh_rounded,
                    color: Colors.red, size: 20),
              ),

              title: Text(
                'Reset Semua Pengaturan',
                style: TextStyle(
                  color: c.onSurface,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),

              subtitle: Text(
                'Kembalikan ke pengaturan awal',
                style: TextStyle(
                  color: c.textSecondary,
                  fontSize: 12,
                ),
              ),

              trailing: Icon(
                Icons.chevron_right_rounded,
                color: c.textHint,
              ),

              onTap: () => _confirmReset(context, settings),
            ),
          ],
        ),
                ],
              ),
            );
          }

  Widget _divider(AppColors c) => Divider(
        height: 1,
        color: c.isDark
            ? Colors.grey.shade800
            : Colors.grey.shade200,
        indent: 60,
      );

  Widget _waktuTile(
    BuildContext context,
    SettingsService settings,
    String waktu,
    IconData icon,
    Color iconColor,
    String title,
    String subtitle,
  ) {
    final c = context.colors;

    final bool value = switch (waktu) {
      'imsak'   => settings.notifImsak,
      'subuh'   => settings.notifSubuh,
      'terbit'  => settings.notifTerbit,
      'dhuha'   => settings.notifDhuha,
      'dzuhur'  => settings.notifDzuhur,
      'ashar'   => settings.notifAshar,
      'maghrib' => settings.notifMaghrib,
      'isya'    => settings.notifIsya,
      _         => false,
    };

    return _SwitchTile(
      icon: icon,
      iconColor: iconColor,
      title: title,
      subtitle: subtitle,
      value: value,
      onChanged: (v) => settings.setNotifWaktu(waktu, v),
      c: c,
    );
  }
}

// ─── UI COMPONENTS ─────────────────────────

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  final AppColors c;

  const _SettingsCard({required this.children, required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: c.isDark
              ? Colors.transparent
              : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: c.isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final AppColors c;

  const _SwitchTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.c,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),

      secondary: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),

      title: Text(title,
          style: TextStyle(
              color: c.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 14)),

      subtitle: subtitle.isEmpty
          ? null
          : Text(subtitle,
              style:
                  TextStyle(color: c.textSecondary, fontSize: 12)),

      value: value,

      activeColor: Colors.white,
      activeTrackColor: kTeal,
      inactiveThumbColor: Colors.white,
      inactiveTrackColor: Colors.grey.shade300,

      onChanged: onChanged,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final AppColors c;

  const _SectionHeader(this.title, this.c);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: kTeal,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

class _LangTile extends StatelessWidget {
  final String lang;
  final String label;
  final SettingsService settings;
  final AppColors c;

  const _LangTile({
    required this.lang,
    required this.label,
    required this.settings,
    required this.c,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = settings.language == lang;

    return ListTile(
      title: Text(label,
          style: TextStyle(
            color: isSelected ? kTeal : c.onSurface,
            fontWeight:
                isSelected ? FontWeight.bold : FontWeight.normal,
          )),
      trailing: isSelected
          ? const Icon(Icons.check_circle_rounded, color: kTeal)
          : Icon(Icons.radio_button_unchecked, color: c.textHint),
      onTap: () => settings.setLanguage(lang),
    );
  }
}

