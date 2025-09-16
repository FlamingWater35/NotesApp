// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Catatan';

  @override
  String get addNoteScreenTitle => 'Tambah Catatan Baru';

  @override
  String get saveNoteTooltip => 'Simpan Catatan';

  @override
  String get cannotSaveNoteWithoutTitle =>
      'Tidak dapat menyimpan catatan tanpa judul.';

  @override
  String get discardChangesDialogTitle => 'Buang perubahan?';

  @override
  String get discardChangesDialogContent =>
      'Jika Anda kembali sekarang, perubahan akan hilang.';

  @override
  String get cancelButtonLabel => 'Batal';

  @override
  String get discardButtonLabel => 'Buang';

  @override
  String get quillPlaceholder => 'Mulai menulis catatan...';

  @override
  String get titleHint => 'Judul';

  @override
  String get untitledNote => 'Catatan Tanpa Judul';

  @override
  String get editNoteScreenTitle => 'Edit Catatan';

  @override
  String get errorCouldNotLoadNoteData =>
      'Error: Tidak dapat memuat data catatan.';

  @override
  String errorSavingNote(String errorDetails) {
    return 'Error menyimpan catatan: $errorDetails';
  }

  @override
  String get errorAppBarTitle => 'Error';

  @override
  String get failedToLoadNote => 'Gagal memuat catatan.';

  @override
  String get saveChangesTooltip => 'Simpan Perubahan';

  @override
  String get deleteNoteTooltip => 'Hapus Catatan';

  @override
  String get deleteNoteDialogTitle => 'Hapus Catatan?';

  @override
  String deleteNoteDialogContent(String noteTitle) {
    return 'Apakah Anda yakin ingin menghapus \"$noteTitle\"? Tindakan ini tidak dapat dibatalkan.';
  }

  @override
  String get deleteButtonLabel => 'Hapus';

  @override
  String noteDeletedSnackbar(String noteTitle) {
    return 'Catatan \"$noteTitle\" telah dihapus.';
  }

  @override
  String get sortPropertyDate => 'Tanggal';

  @override
  String get sortPropertyTitle => 'Judul';

  @override
  String get sortPropertyLastModified => 'Terakhir Diubah';

  @override
  String get sortPropertyCreatedAt => 'Dibuat Pada';

  @override
  String get searchNotesHint => 'Cari catatan...';

  @override
  String get clearSearchTooltip => 'Hapus Pencarian';

  @override
  String get sortByLabel => 'Urutkan berdasarkan: ';

  @override
  String get sortAscendingTooltip => 'Naik (A-Z, Lama dulu)';

  @override
  String get sortDescendingTooltip => 'Turun (Z-A, Baru dulu)';

  @override
  String get emptyNotesMessage =>
      'Belum ada catatan.\nTekan + untuk menambahkan!';

  @override
  String get noNotesFoundMessage => 'Tidak ada catatan yang cocok.';

  @override
  String errorLoadingNotes(String errorDetails) {
    return 'Error memuat catatan:\n$errorDetails';
  }

  @override
  String get addNoteFabTooltip => 'Tambah Catatan';

  @override
  String get homeNavigationLabel => 'Beranda';

  @override
  String get settingsNavigationLabel => 'Pengaturan';

  @override
  String get settingsScreenTitle => 'Pengaturan';

  @override
  String get appVersionLoading => 'Memuat...';

  @override
  String appVersion(String version, String buildNumber) {
    return 'Versi $version ($buildNumber)';
  }

  @override
  String get errorLoadingVersion => 'Error memuat versi';

  @override
  String get backupSuccessful => 'Backup berhasil!';

  @override
  String get backupFailed => 'Backup gagal.';

  @override
  String get restoreSuccessful => 'Pemulihan berhasil!';

  @override
  String get restoreFailed => 'Pemulihan gagal.';

  @override
  String get languageSectionTitle => 'Bahasa';

  @override
  String get languageSystemDefault => 'Default Sistem';

  @override
  String get appearanceSectionTitle => 'Tampilan';

  @override
  String get themeLight => 'Terang';

  @override
  String get themeDark => 'Gelap';

  @override
  String get themeSystem => 'Sistem';

  @override
  String get dataManagementSectionTitle => 'Manajemen Data';

  @override
  String get backupNotesTitle => 'Backup Catatan';

  @override
  String get backupNotesSubtitle => 'Simpan catatan ke file';

  @override
  String get restoreNotesTitle => 'Pulihkan Catatan';

  @override
  String get restoreNotesSubtitle => 'Muat catatan dari file';

  @override
  String get applicationSectionTitle => 'Aplikasi';

  @override
  String get checkForUpdatesTitle => 'Cek Pembaruan';

  @override
  String get updateScreenTitle => 'Pembaruan Aplikasi';

  @override
  String get updateStatusChecking => 'Mengecek pembaruan...';

  @override
  String get updateStatusAvailableTitle => 'Pembaruan Tersedia!';

  @override
  String updateStatusCurrentVersion(String version) {
    return 'Versi saat ini: $version';
  }

  @override
  String updateStatusNewVersion(String version) {
    return 'Versi baru: $version';
  }

  @override
  String get updateDownloadInstallButton => 'Unduh & Pasang';

  @override
  String updateStatusDownloading(String version) {
    return 'Mengunduh pembaruan ($version)...';
  }

  @override
  String updateProgressPercent(String progress) {
    return '$progress%';
  }

  @override
  String get updateStatusStartingInstall => 'Memulai instalasi...';

  @override
  String get updateStatusFailedTitle => 'Pembaruan Gagal';

  @override
  String get updateTryAgainButton => 'Coba Lagi';

  @override
  String get updateStatusUpToDateTitle => 'Anda sudah yang terbaru!';

  @override
  String updateStatusLatestAvailable(String version) {
    return '(Terbaru: $version)';
  }

  @override
  String get updateCheckAgainButton => 'Cek Lagi';

  @override
  String get updateStatusInstalled => 'Dialog instalasi ditampilkan';

  @override
  String get updateErrorNoNewUpdate => 'Tidak ada pembaruan baru.';

  @override
  String get updateErrorUnexpected => 'Terjadi error tak terduga.';

  @override
  String get updateErrorIncompleteInfo => 'Informasi pembaruan tidak lengkap.';

  @override
  String get updateErrorCouldNotStartInstall =>
      'Tidak bisa mulai instalasi. Periksa izin.';

  @override
  String get updateErrorDownloadFailed => 'Unduhan gagal. Periksa koneksi.';

  @override
  String get versionNotAvailable => 'T/A';

  @override
  String get toolbarFontSize => 'Ukuran Font';

  @override
  String get toolbarFontFamily => 'Jenis Font';

  @override
  String get toolbarSearchHint => 'Cari...';

  @override
  String get toolbarCaseSensitive => 'Peka huruf besar/kecil';

  @override
  String get toolbarNoResults => 'Tidak ada hasil';

  @override
  String toolbarSearchMatchOf(String current, String total) {
    return '$current dari $total';
  }

  @override
  String get toolbarPreviousMatch => 'Kecocokan sebelumnya';

  @override
  String get toolbarNextMatch => 'Kecocokan berikutnya';

  @override
  String get toolbarCloseSearchTooltip => 'Tutup Pencarian';

  @override
  String get toolbarCaseSensitiveTooltip => 'Ganti Peka Huruf';

  @override
  String get toolbarHeaderStyle => 'Gaya Header';

  @override
  String get enterFullscreenTooltip => 'Masuk layar penuh';

  @override
  String get exitFullscreenTooltip => 'Keluar dari layar penuh';

  @override
  String get toolbarShowReplaceTooltip =>
      'Tampilkan/Sembunyikan Opsi Penggantian';

  @override
  String get toolbarReplaceWithHint => 'Ganti dengan...';

  @override
  String get toolbarReplaceButton => 'Ganti';

  @override
  String get toolbarReplaceAllButton => 'Ganti Semua';
}
