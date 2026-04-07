import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/settings_service.dart';
import '../services/local_database_service.dart';
import '../services/dzikir_local_service.dart';

const _kTeal      = Color(0xFF00A086);
const _kTealDark  = Color(0xFF007A68);
// ignore: unused_element
const _kTealLight = Color(0xFF00C4A7);
const _kGold      = Color(0xFFE8A020);
const _kBg        = Color(0xFFF2F4F7);

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return ChangeNotifierProvider.value(
      value: SettingsService(),
      child: Scaffold(
        backgroundColor: _kBg,
        body: Consumer<SettingsService>(
          builder: (context, settings, _) {
            return CustomScrollView(
              slivers: [
                // ── APP BAR ──────────────────────────────────
                SliverAppBar(
                  pinned: true,
                  backgroundColor: _kTealDark,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_rounded,
                        color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  title: Text('Pengaturan',
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18)),
                  centerTitle: true,
                ),

                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                      16, 20, 16, 24 + bottomPadding),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([

                      // ── TAMPILAN ───────────────────────────
                      _SectionHeader(title: 'Tampilan'),
                      const SizedBox(height: 8),
                      _SettingsCard(children: [
                        _SwitchTile(
                          icon: Icons.dark_mode_rounded,
                          iconColor: const Color(0xFF1565C0),
                          title: 'Tema Gelap',
                          subtitle: 'Aktifkan mode gelap (dark mode)',
                          value: settings.darkMode,
                          onChanged: (v) => settings.setDarkMode(v),
                        ),
                      ]),

                      const SizedBox(height: 20),

                      // ── AL-QUR'AN ──────────────────────────
                      _SectionHeader(title: 'Al-Qur\'an'),
                      const SizedBox(height: 8),
                      _SettingsCard(children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _kTeal.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                    Icons.text_fields_rounded,
                                    color: _kTeal, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text('Ukuran Font Arab',
                                        style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500)),
                                    Text(
                                        '${settings.quranFontSize.toInt()}px',
                                        style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: Colors.grey[500])),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Preview font Arab
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              color: _kTeal.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: _kTeal.withOpacity(0.15)),
                            ),
                            child: Text(
                              'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: settings.quranFontSize,
                                fontFamily: 'serif',
                                color: _kTealDark,
                                height: 2.0,
                              ),
                            ),
                          ),
                        ),
                        // Slider
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                          child: Row(
                            children: [
                              const Text('A',
                                  style: TextStyle(fontSize: 14)),
                              Expanded(
                                child: Slider(
                                  value: settings.quranFontSize,
                                  min: 18, max: 42,
                                  divisions: 12,
                                  activeColor: _kTeal,
                                  onChanged: (v) =>
                                      settings.setQuranFontSize(v),
                                ),
                              ),
                              const Text('A',
                                  style: TextStyle(fontSize: 24)),
                            ],
                          ),
                        ),
                      ]),

                      const SizedBox(height: 20),

                      // ── NOTIFIKASI ─────────────────────────
                      _SectionHeader(title: 'Notifikasi Waktu Shalat'),
                      const SizedBox(height: 8),
                      _SettingsCard(children: [
                        _SwitchTile(
                          icon: Icons.notifications_rounded,
                          iconColor: _kGold,
                          title: 'Notifikasi Shalat',
                          subtitle: 'Aktifkan semua notifikasi waktu shalat',
                          value: settings.notifShalat,
                          onChanged: (v) => settings.setNotifShalat(v),
                        ),
                        if (settings.notifShalat) ...[
                          const Divider(height: 1, indent: 56),
                          _SwitchTile(
                            icon: Icons.wb_twilight_rounded,
                            iconColor: const Color(0xFF1565C0),
                            title: 'Subuh',
                            subtitle: '',
                            value: settings.notifSubuh,
                            isSubItem: true,
                            onChanged: (v) =>
                                settings.setNotifWaktu('subuh', v),
                          ),
                          const Divider(height: 1, indent: 56),
                          _SwitchTile(
                            icon: Icons.wb_sunny_rounded,
                            iconColor: const Color(0xFFE8650A),
                            title: 'Dzuhur',
                            subtitle: '',
                            value: settings.notifDzuhur,
                            isSubItem: true,
                            onChanged: (v) =>
                                settings.setNotifWaktu('dzuhur', v),
                          ),
                          const Divider(height: 1, indent: 56),
                          _SwitchTile(
                            icon: Icons.cloud_rounded,
                            iconColor: _kGold,
                            title: 'Ashar',
                            subtitle: '',
                            value: settings.notifAshar,
                            isSubItem: true,
                            onChanged: (v) =>
                                settings.setNotifWaktu('ashar', v),
                          ),
                          const Divider(height: 1, indent: 56),
                          _SwitchTile(
                            icon: Icons.nights_stay_rounded,
                            iconColor: const Color(0xFF7B1FA2),
                            title: 'Maghrib',
                            subtitle: '',
                            value: settings.notifMaghrib,
                            isSubItem: true,
                            onChanged: (v) =>
                                settings.setNotifWaktu('maghrib', v),
                          ),
                          const Divider(height: 1, indent: 56),
                          _SwitchTile(
                            icon: Icons.nightlight_round,
                            iconColor: const Color(0xFF0D47A1),
                            title: 'Isya',
                            subtitle: '',
                            value: settings.notifIsya,
                            isSubItem: true,
                            onChanged: (v) =>
                                settings.setNotifWaktu('isya', v),
                          ),
                        ],
                      ]),

                      const SizedBox(height: 20),

                      // ── BAHASA ─────────────────────────────
                      _SectionHeader(title: 'Bahasa'),
                      const SizedBox(height: 8),
                      _SettingsCard(children: [
                        _RadioTile(
                          icon: Icons.language_rounded,
                          iconColor: const Color(0xFF388E3C),
                          title: 'Bahasa Indonesia',
                          value: 'id',
                          groupValue: settings.language,
                          onChanged: (v) => settings.setLanguage(v!),
                        ),
                        const Divider(height: 1, indent: 56),
                        _RadioTile(
                          icon: Icons.language_rounded,
                          iconColor: const Color(0xFF1565C0),
                          title: 'English',
                          value: 'en',
                          groupValue: settings.language,
                          onChanged: (v) => settings.setLanguage(v!),
                        ),
                      ]),

                      const SizedBox(height: 20),

                      // ── INFORMASI APP ──────────────────────
                      _SectionHeader(title: 'Informasi'),
                      const SizedBox(height: 8),
                      _SettingsCard(children: [
                        _InfoTile(
                          icon: Icons.info_outline_rounded,
                          iconColor: _kTeal,
                          title: 'Versi Aplikasi',
                          value: '1.0.0',
                        ),
                        const Divider(height: 1, indent: 56),
                        _InfoTile(
                          icon: Icons.storage_rounded,
                          iconColor: const Color(0xFF546E7A),
                          title: 'Database',
                          value: 'SQLite + SharedPreferences',
                        ),
                        const Divider(height: 1, indent: 56),
                        _InfoTile(
                          icon: Icons.code_rounded,
                          iconColor: const Color(0xFF1565C0),
                          title: 'Framework',
                          value: 'Flutter',
                        ),
                      ]),

                      const SizedBox(height: 20),

                      // ── RESET DATA ─────────────────────────
                      _SectionHeader(title: 'Reset Data'),
                      const SizedBox(height: 8),
                      _SettingsCard(children: [
                        _ActionTile(
                          icon: Icons.refresh_rounded,
                          iconColor: _kGold,
                          title: 'Reset Dzikir Harian',
                          subtitle: 'Hapus progress dzikir hari ini',
                          onTap: () => _confirmAction(
                            context,
                            title: 'Reset Dzikir?',
                            message:
                                'Progress dzikir hari ini akan dihapus.',
                            onConfirm: () async {
                              await DzikirLocalService().resetAll('pagi');
                              await DzikirLocalService().resetAll('petang');
                              await DzikirLocalService().resetAll('shalat');
                              _showSnack(context, 'Dzikir direset');
                            },
                          ),
                        ),
                        const Divider(height: 1, indent: 56),
                        _ActionTile(
                          icon: Icons.delete_outline_rounded,
                          iconColor: const Color(0xFFC62828),
                          title: 'Hapus Data Ramadhan',
                          subtitle: 'Hapus semua catatan Ramadhan',
                          isDestructive: true,
                          onTap: () => _confirmAction(
                            context,
                            title: 'Hapus Data Ramadhan?',
                            message:
                                'Semua catatan Ramadhan akan dihapus permanen.',
                            isDestructive: true,
                            onConfirm: () async {
                              await LocalDatabaseService()
                                  .clearAllRamadhanEntries();
                              _showSnack(
                                  context, 'Data Ramadhan dihapus');
                            },
                          ),
                        ),
                        const Divider(height: 1, indent: 56),
                        _ActionTile(
                          icon: Icons.warning_amber_rounded,
                          iconColor: const Color(0xFFD32F2F),
                          title: 'Reset Semua Data',
                          subtitle:
                              'Hapus semua data dan kembalikan ke pengaturan awal',
                          isDestructive: true,
                          onTap: () => _confirmAction(
                            context,
                            title: 'Reset Semua Data?',
                            message:
                                'SEMUA data akan dihapus termasuk bookmark, '
                                'catatan Ramadhan, dan pengaturan. '
                                'Tindakan ini tidak dapat dibatalkan.',
                            isDestructive: true,
                            onConfirm: () async {
                              await settings.resetAll();
                              await LocalDatabaseService()
                                  .clearAllRamadhanEntries();
                              await DzikirLocalService().cleanupOldData();
                              _showSnack(
                                  context, 'Semua data telah direset');
                            },
                          ),
                        ),
                      ]),
                    ]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ─── HELPERS ──────────────────────────────────────────────────────────────
  void _confirmAction(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onConfirm,
    bool isDestructive = false,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Text(title,
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text(message,
            style: GoogleFonts.poppins(
                fontSize: 13, color: Colors.grey[700])),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal',
                style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isDestructive ? const Color(0xFFD32F2F) : _kTeal,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(isDestructive ? 'Hapus' : 'Lanjutkan',
                style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.poppins()),
      backgroundColor: _kTeal,
      behavior: SnackBarBehavior.floating,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      duration: const Duration(seconds: 2),
    ));
  }
}

// ─────────────────────────────────────────────
// REUSABLE WIDGETS
// ─────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 0),
      child: Text(title,
          style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _kTeal,
              letterSpacing: 0.5)),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final Color    iconColor;
  final String   title, subtitle;
  final bool     value, isSubItem;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.isSubItem = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
          horizontal: isSubItem ? 24 : 16, vertical: 2),
      leading: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
      title: Text(title,
          style: GoogleFonts.poppins(
              fontSize: isSubItem ? 13 : 14,
              fontWeight: FontWeight.w500)),
      subtitle: subtitle.isNotEmpty
          ? Text(subtitle,
              style: GoogleFonts.poppins(
                  fontSize: 11, color: Colors.grey[500]))
          : null,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: _kTeal,
        trackOutlineColor:
            WidgetStateProperty.all(Colors.transparent),
      ),
    );
  }
}

class _RadioTile extends StatelessWidget {
  final IconData icon;
  final Color    iconColor;
  final String   title, value, groupValue;
  final ValueChanged<String?> onChanged;

  const _RadioTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
      title: Text(title,
          style: GoogleFonts.poppins(
              fontSize: 14, fontWeight: FontWeight.w500)),
      trailing: Radio<String>(
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
        activeColor: _kTeal,
      ),
      onTap: () => onChanged(value),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final Color    iconColor;
  final String   title, value;

  const _InfoTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
      title: Text(title,
          style: GoogleFonts.poppins(
              fontSize: 14, fontWeight: FontWeight.w500)),
      trailing: Text(value,
          style: GoogleFonts.poppins(
              fontSize: 12, color: Colors.grey[500])),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color    iconColor;
  final String   title, subtitle;
  final bool     isDestructive;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
      title: Text(title,
          style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDestructive
                  ? const Color(0xFFD32F2F)
                  : const Color(0xFF1A1A2E))),
      subtitle: Text(subtitle,
          style: GoogleFonts.poppins(
              fontSize: 11, color: Colors.grey[500])),
      trailing: Icon(Icons.chevron_right_rounded,
          color: Colors.grey[400]),
      onTap: onTap,
    );
  }
}