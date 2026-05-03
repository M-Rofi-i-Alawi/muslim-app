// lib/l10n/app_localizations.dart
import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const delegate = _AppLocalizationsDelegate();

  bool get isEn => locale.languageCode == 'en';

  // ── MENU ──────────────────────────────────────────────────────────────────
  String get appName => isEn ? 'Islamic App' : 'Aplikasi Islam';
  String get jadwalShalat => isEn ? 'Prayer Schedule' : 'Jadwal Shalat';
  String get wiridDoa => isEn ? 'Wirid & Dua' : 'Wirid & Doa';
  String get alQuran => isEn ? "Al-Qur'an" : "Al-Qur'an";
  String get arahKiblat => isEn ? 'Qibla Direction' : 'Arah Kiblat';
  String get tasbihDigital => isEn ? 'Digital Tasbih' : 'Tasbih Digital';
  String get dzikirHarian => isEn ? 'Daily Dhikr' : 'Dzikir Harian';
  String get panduanIbadah => isEn ? 'Worship Guide' : 'Panduan Ibadah';
  String get hadist => isEn ? 'Hadith' : 'Hadist';
  String get asmaulHusna => isEn ? 'Asmaul Husna' : 'Asmaul Husna';
  String get zakat => isEn ? 'Zakat' : 'Zakat';
  String get kalenderHijri => isEn ? 'Hijri Calendar' : 'Kalender Hijri';
  String get tanyaIslam => isEn ? 'Ask ISLAM' : 'Tanya ISLAM';
  String get ramadhan => isEn ? 'Ramadan' : 'Ramadhan';
  String get tentang => isEn ? 'About' : 'Tentang';
  String get pengaturan => isEn ? 'Settings' : 'Pengaturan';

  // ── SETTINGS ──────────────────────────────────────────────────────────────
  String get notifikasiShalat =>
      isEn ? 'Prayer Notifications' : 'Notifikasi Shalat';
  String get tampilan => isEn ? 'Display' : 'Tampilan';
  String get modeGelap => isEn ? 'Dark Mode' : 'Mode Gelap';
  String get modeGelapSubtitle => isEn
      ? 'Dark display for eye comfort'
      : 'Tampilan gelap untuk kenyamanan mata';
  String get ukuranFontQuran =>
      isEn ? "Qur'an Font Size" : "Ukuran Font Al-Qur'an";
  String get ukuranTeksArab => isEn ? 'Arabic text size' : 'Ukuran teks Arab';
  String get bahasa => isEn ? 'Language' : 'Bahasa';
  String get lainnya => isEn ? 'Others' : 'Lainnya';
  String get resetSemuaPengaturan =>
      isEn ? 'Reset All Settings' : 'Reset Semua Pengaturan';
  String get resetSubtitle =>
      isEn ? 'Restore to default settings' : 'Kembalikan ke pengaturan awal';
  String get resetPengaturan => isEn ? 'Reset Settings?' : 'Reset Pengaturan?';
  String get resetKonfirmasi => isEn
      ? 'All settings will be restored to default, including prayer notifications.'
      : 'Semua pengaturan akan dikembalikan ke awal, termasuk notifikasi shalat.';
  String get batal => isEn ? 'Cancel' : 'Batal';
  String get reset => isEn ? 'Reset' : 'Reset';
  String get resetBerhasil =>
      isEn ? 'Settings successfully reset' : 'Pengaturan berhasil direset';

  // ── WAKTU SHALAT ──────────────────────────────────────────────────────────
  String get imsak => 'Imsak';
  String get imsakSubtitle =>
      isEn ? 'Reminder before suhoor ends' : 'Pengingat sebelum sahur berakhir';
  String get subuh => isEn ? 'Fajr' : 'Subuh';
  String get subuhSubtitle =>
      isEn ? 'Beginning of Fajr prayer time' : 'Awal waktu shalat Subuh';
  String get terbit => isEn ? 'Sunrise' : 'Terbit';
  String get terbitSubtitle => isEn
      ? 'Sunrise — end of Fajr time'
      : 'Matahari terbit — batas akhir Subuh';
  String get dhuha => 'Dhuha';
  String get dhuhaSubtitle => isEn
      ? '± 20 minutes after sunrise'
      : '± 20 menit setelah matahari terbit';
  String get dzuhur => isEn ? 'Dhuhr' : 'Dzuhur';
  String get dzuhurSubtitle => isEn ? 'Midday' : 'Tengah hari';
  String get ashar => isEn ? 'Asr' : 'Ashar';
  String get asharSubtitle => isEn ? 'Afternoon' : 'Sore hari';
  String get maghrib => 'Maghrib';
  String get maghribSubtitle => isEn ? 'At sunset' : 'Saat matahari terbenam';
  String get isya => isEn ? 'Isha' : 'Isya';
  String get isyaSubtitle => isEn ? 'Nighttime' : 'Malam hari';

  // ── SHALAT PAGE ───────────────────────────────────────────────────────────
  String get gagalMemuat =>
      isEn ? 'Failed to load schedule' : 'Gagal memuat jadwal';
  String get cobaLagi => isEn ? 'Try Again' : 'Coba Lagi';
  String get memuat => isEn ? 'Loading...' : 'Memuat...';
  String get shalatBerikutnya => isEn ? 'Next Prayer' : 'Shalat Berikutnya';
  String get lagi => isEn ? 'left' : 'lagi';
  String get sudahLewat => isEn ? 'Passed' : 'Sudah lewat';
  String get belumTiba => isEn ? 'Not yet' : 'Belum tiba';
  String get pilihLokasi => isEn ? 'Choose Location' : 'Pilih Lokasi';
  String get cariKota => isEn ? 'Search city...' : 'Cari kota...';
  String get autoGps => isEn ? 'Auto GPS' : 'Auto GPS';
  String get autoGpsSubtitle => isEn
      ? 'Auto-detect from your location'
      : 'Deteksi otomatis dari lokasi Anda';
  String get mendeteksi => isEn ? 'Detecting...' : 'Mendeteksi...';
  String get jamMenit =>
      isEn ? 'hr min' : 'jam menit'; // unused, pakai _formatCountdown

  // ── DZIKIR PAGE ───────────────────────────────────────────────────────────
  String get dzikirWirid => isEn ? 'Dhikr & Wirid' : 'Dzikir & Wirid';
  String get dzikirSubtitle => isEn
      ? 'Morning, evening, and after prayer dhikr'
      : 'Dzikir pagi, petang, dan setelah shalat';
  String get progressHariIni => isEn ? "Today's Progress" : 'Progress Hari Ini';
  String get dzikirSelesai =>
      isEn ? 'of ${''}dhikr done' : 'dzikir selesai'; // pakai helper
  String get resetSemua => isEn ? 'Reset All' : 'Reset Semua';
  String get selesai => isEn ? 'Done' : 'Selesai';
  String get belumAdaDzikir => isEn ? 'No dhikr available' : 'Belum ada dzikir';
  String get transliterasi => isEn ? 'Transliteration' : 'Transliterasi';
  String get artinya => isEn ? 'Meaning' : 'Artinya';
  String get keutamaan => isEn ? 'Virtue' : 'Keutamaan';
  String get counter => 'Counter';
  String get selesaiAlhamdulillah =>
      isEn ? 'Done! Alhamdulillah' : 'Selesai! Alhamdulillah';
  String get resetCounter => isEn ? 'Reset Counter' : 'Reset Counter';
  String get salin => isEn ? 'Copy' : 'Salin';
  String get tutup => isEn ? 'Close' : 'Tutup';
  String get disalin => isEn ? 'Dhikr copied!' : 'Dzikir disalin!';
  String get pagi => isEn ? 'Morning' : 'Pagi';
  String get petang => isEn ? 'Evening' : 'Petang';
  String get shalatLabel => isEn ? 'Prayer' : 'Shalat';

  // ── HADIST PAGE ───────────────────────────────────────────────────────────
  String get hadistArbain =>
      isEn ? 'Hadith Arbain Nawawi' : 'Hadist Arbain Nawawi';
  String get hadistSubtitle => isEn
      ? '40 selected hadiths for daily life'
      : '40 Hadist pilihan untuk kehidupan sehari-hari';
  String get hadistHariIni => isEn ? 'Hadith of the Day' : 'Hadist Hari Ini';
  String get semuaHadist => isEn ? 'All Hadith' : 'Semua Hadist';
  String get favorit => isEn ? 'Favorites' : 'Favorit';
  String get cariHadist => isEn ? 'Search hadith...' : 'Cari hadist...';
  String get tidakAdaHadist =>
      isEn ? 'No hadith found' : 'Tidak ada hadist ditemukan';
  String get belumAdaFavorit =>
      isEn ? 'No favorite hadith yet' : 'Belum ada hadist favorit';
  String get hadistDisalin => isEn ? 'Hadith copied!' : 'Hadist disalin!';
  String get teksArab => isEn ? 'Arabic Text' : 'Teks Arab';
  String get transliterasiLatin =>
      isEn ? 'Latin Transliteration' : 'Transliterasi Latin';
  String get terjemahan => isEn ? 'Translation' : 'Terjemahan';
  String get penjelasan => isEn ? 'Explanation' : 'Penjelasan';
  String get rawi => isEn ? 'Narrator' : 'Rawi';

  // ── ZAKAT PAGE ────────────────────────────────────────────────────────────
  String get kalkulatorZakat => isEn ? 'Zakat Calculator' : 'Kalkulator Zakat';
  String get kalkulatorSubtitle => isEn
      ? 'Calculate maal, income, fitrah & more'
      : 'Hitung zakat maal, penghasilan, fitrah & lainnya';
  String get wajibZakat => isEn ? 'Zakat Required' : 'Wajib Zakat';
  String get belumWajibZakat =>
      isEn ? 'Zakat Not Required Yet' : 'Belum Wajib Zakat';
  String get hitungZakat => isEn ? 'Calculate Zakat' : 'Hitung Zakat';
  String get totalHarta => isEn ? 'Total Assets' : 'Total Harta';
  String get nisab => 'Nisab';
  String get jumlahZakat => isEn ? 'Zakat Amount:' : 'Jumlah Zakat:';

  // ── DOA PAGE ──────────────────────────────────────────────────────────────
  String get doaHarian => isEn ? 'Daily Prayers' : 'Doa Harian';
  String get cariDoa => isEn ? 'Search prayer...' : 'Cari doa...';

  // ── SURAT / QURAN PAGE ────────────────────────────────────────────────────
  String get cariSurat => isEn
      ? 'Search surah, number, or meaning...'
      : 'Cari surat, nomor, atau arti...';
  String get belumAdaBookmark =>
      isEn ? 'No bookmarks yet' : 'Belum ada bookmark';
  String get tandaiAyat => isEn
      ? 'Bookmark your favorite verses while reading'
      : 'Tandai ayat favoritmu saat membaca';
  String get lanjutkanMembaca =>
      isEn ? 'Continue reading' : 'Lanjutkan membaca';
  String get suratLengkap => isEn ? 'Surahs · Complete' : 'Surat · Lengkap';

  // ── KIBLAT PAGE ───────────────────────────────────────────────────────────
  String get arahKiblatTitle => isEn ? 'Qibla Direction' : 'Arah Kiblat';
  String get mendapatkanLokasi =>
      isEn ? 'Getting your location...' : 'Mendapatkan lokasi Anda...';
  String get gagalLokasi =>
      isEn ? 'Failed to get location' : 'Gagal mendapatkan lokasi';
  String get dataKiblatTidakAda =>
      isEn ? 'Qibla data not available' : 'Data kiblat tidak tersedia';
  String get dariUtara => isEn ? 'from North' : 'dari Utara';
  String get kompasKompass =>
      isEn ? 'Compass not available' : 'Kompas tidak tersedia';
  String get aktifkanKompas => isEn
      ? 'Enable device compass sensor'
      : 'Aktifkan sensor kompas perangkat';
  String get caraMenggunakan => isEn ? 'How to Use' : 'Cara Menggunakan';
  String get kaabah => "Ka'bah";

  // ── TASBIH PAGE ───────────────────────────────────────────────────────────
  String get alhamdulillah => 'Alhamdulillah!';
  String get targetTercapai => isEn ? 'Target reached!' : 'Target tercapai!';
  String get lanjutDzikir => isEn ? 'Continue Dhikr' : 'Lanjut Dzikir';
  String get tasbihDigitalTitle => isEn ? 'DIGITAL TASBIH' : 'TASBIH DIGITAL';
  String get dari => isEn ? 'OF' : 'DARI';
  String get riwayat => isEn ? 'History' : 'Riwayat';
  String get target => isEn ? 'Target' : 'Target';
  String get ketukUntukHitung => isEn
      ? 'Tap the circle to count dhikr'
      : 'Ketuk lingkaran besar untuk menghitung dzikir';
  String get pilihTarget => isEn ? 'Choose Target' : 'Pilih Target';
  String get customTarget => isEn ? 'Custom Target' : 'Custom Target';
  String get kali => isEn ? 'times' : 'kali';
  String get jumlahTarget => isEn ? 'Target Amount' : 'Jumlah Target';
  String get misal500 => isEn ? 'e.g. 500' : 'Misal: 500';
  String get simpan => isEn ? 'Save' : 'Simpan';
  String get riwayatDzikir => isEn ? 'Dhikr History' : 'Riwayat Dzikir';
  String get hapus => isEn ? 'Delete' : 'Hapus';

  // ── ASMAUL HUSNA PAGE ─────────────────────────────────────────────────────
  String get asmaulHusnaTitle => isEn ? 'Asmaul Husna' : 'Asmaul Husna';
  String get asmaulHusnaSubtitle =>
      isEn ? "99 Names of Allah the Almighty" : '99 Nama Allah Yang Maha Agung';
  String get progressHafalan =>
      isEn ? 'Memorization Progress' : 'Progress Hafalan';
  String get cariNamaAllah =>
      isEn ? 'Search name of Allah...' : 'Cari nama Allah...';
  String get tidakAdaHasil => isEn ? 'No results' : 'Tidak ada hasil';
  String get berhasilDisalin =>
      isEn ? 'Copied successfully!' : 'Berhasil disalin!';
  String get pelajaran => isEn ? 'Explanation' : 'Penjelasan';

  // ── RAMADHAN PAGE ─────────────────────────────────────────────────────────
  String get catatanRamadhan => isEn ? 'Ramadan Notes' : 'Catatan Ramadhan';
  String get dataBerhasilDisimpan =>
      isEn ? '✅ Data saved successfully' : '✅ Data berhasil disimpan';
  String get jurnalHarian => isEn ? 'DAILY JOURNAL' : 'JURNAL HARIAN';
  String get catatanIbadah =>
      isEn ? 'Ramadan Worship Journal' : 'Catatan Ibadah Ramadhan';
  String get belumAdaCatatan => isEn ? 'No notes yet' : 'Belum ada catatan';
  String get tapTambah => isEn ? 'Tap + to start' : 'Tap tombol + untuk mulai';
  String get progressRamadhan =>
      isEn ? 'Ramadan Progress' : 'Progress Ramadhan';
  String get hari => isEn ? 'Days' : 'Hari';
  String get editCatatan => isEn ? 'Edit Notes' : 'Edit Catatan';
  String get tidakAdaData => isEn ? 'No data' : 'Tidak ada data';
  String get doaTerkabul => isEn ? 'Answered Prayers' : 'Doa yang Terkabul';
  String get doaHint =>
      isEn ? 'Prayers answered today...' : 'Doa yang dikabulkan hari ini...';
  String get momenSpesial => isEn ? 'Special Moment' : 'Momen Spesial';
  String get momenHint =>
      isEn ? 'A memorable moment today...' : 'Momen berkesan hari ini...';
  String get refleksi =>
      isEn ? 'Reflection & Self-evaluation' : 'Refleksi & Muhasabah';

  // ── PANDUAN IBADAH PAGE ───────────────────────────────────────────────────
  String get panduanIbadahTitle => isEn ? 'Worship Guide' : 'Panduan Ibadah';
  String get panduanIbadahSubtitle => isEn
      ? 'Complete guide to daily worship'
      : 'Pedoman lengkap ibadah sehari-hari';
  String get referensi => isEn ? 'References' : 'Referensi';

  // ── CHAT PAGE ─────────────────────────────────────────────────────────────
  String get tanyaIslam2 => isEn ? 'Ask ISLAM' : 'Tanya ISLAM';
  String get onlineSiap =>
      isEn ? 'Online · ready to answer' : 'Online · siap menjawab';
  String get tanyaSeputarIslam =>
      isEn ? 'Ask About Islam' : 'Tanya Seputar Islam';
  String get cobaTanya => isEn ? 'Try asking:' : 'Coba tanya:';
  String get chatHint =>
      isEn ? 'Ask something about Islam...' : 'Tanya sesuatu tentang Islam...';
  String get hapusPercakapan =>
      isEn ? 'Clear Conversation?' : 'Hapus Percakapan?';
  String get semuaPesanDihapus =>
      isEn ? 'All messages will be deleted.' : 'Semua pesan akan dihapus.';
  String get hapus2 => isEn ? 'Delete' : 'Hapus';
  String get sumber => isEn ? 'Sources:' : 'Sumber:';
  String get linkDisalin => isEn ? 'Link copied' : 'Link disalin';

  // ── ABOUT PAGE ────────────────────────────────────────────────────────────
  String get tentangAplikasi => isEn ? 'About App' : 'Tentang Aplikasi';
  String get fiturUtama => isEn ? 'Main Features' : 'Fitur Utama';
  String get teknologi => isEn ? 'Technology' : 'Teknologi';
  String get apiSumberData => isEn ? 'API & Data Sources' : 'API & Sumber Data';
  String get updateTerbaru =>
      isEn ? 'Latest Update (v3.0)' : 'Update Terbaru (v3.0)';
  String get dikembangkanDengan => isEn
      ? 'Developed with ❤️ for the Muslim Community'
      : 'Dikembangkan dengan ❤️ untuk Umat Muslim';
  String get copyright => isEn
      ? '© 2026 Muslim App • Teal Edition'
      : '© 2026 Muslim App • Teal Edition';
  String get builtWithFlutter =>
      isEn ? 'Built with Flutter' : 'Built with Flutter';

  // ── UMUM ──────────────────────────────────────────────────────────────────
  String get ganti => isEn ? 'Change' : 'Ganti';
  String get memuatJadwal =>
      isEn ? 'Loading prayer schedule...' : 'Memuat jadwal shalat...';
  String get mendeteksiLokasi =>
      isEn ? 'Detecting location...' : 'Mendeteksi lokasi...';
  String get ok => 'OK';
  String get ya => isEn ? 'Yes' : 'Ya';
  String get tidak => isEn ? 'No' : 'Tidak';
  String get dari2 => isEn ? 'from' : 'dari';
  String get nama => isEn ? 'Name' : 'Nama';
}

// ─── DELEGATE ─────────────────────────────────────────────────────────────────
class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['id', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
