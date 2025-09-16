// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Notes';

  @override
  String get addNoteScreenTitle => 'Add New Note';

  @override
  String get saveNoteTooltip => 'Save Note';

  @override
  String get cannotSaveNoteWithoutTitle =>
      'Cannot save a note without a title.';

  @override
  String get discardChangesDialogTitle => 'Discard changes?';

  @override
  String get discardChangesDialogContent =>
      'If you go back now, your changes will be lost.';

  @override
  String get cancelButtonLabel => 'Cancel';

  @override
  String get discardButtonLabel => 'Discard';

  @override
  String get quillPlaceholder => 'Start writing your notes...';

  @override
  String get titleHint => 'Title';

  @override
  String get untitledNote => 'Untitled Note';

  @override
  String get editNoteScreenTitle => 'Edit Note';

  @override
  String get errorCouldNotLoadNoteData => 'Error: Could not load note data.';

  @override
  String errorSavingNote(String errorDetails) {
    return 'Error saving note: $errorDetails';
  }

  @override
  String get errorAppBarTitle => 'Error';

  @override
  String get failedToLoadNote => 'Failed to load note.';

  @override
  String get saveChangesTooltip => 'Save Changes';

  @override
  String get deleteNoteTooltip => 'Delete Note';

  @override
  String get deleteNoteDialogTitle => 'Delete Note?';

  @override
  String deleteNoteDialogContent(String noteTitle) {
    return 'Are you sure you want to delete \"$noteTitle\"? This action cannot be undone.';
  }

  @override
  String get deleteButtonLabel => 'Delete';

  @override
  String noteDeletedSnackbar(String noteTitle) {
    return 'Note \"$noteTitle\" deleted.';
  }

  @override
  String get sortPropertyDate => 'Date';

  @override
  String get sortPropertyTitle => 'Title';

  @override
  String get sortPropertyLastModified => 'Last Modified';

  @override
  String get sortPropertyCreatedAt => 'Created At';

  @override
  String get searchNotesHint => 'Search notes...';

  @override
  String get clearSearchTooltip => 'Clear Search';

  @override
  String get sortByLabel => 'Sort by: ';

  @override
  String get sortAscendingTooltip => 'Ascending (A-Z, Oldest first)';

  @override
  String get sortDescendingTooltip => 'Descending (Z-A, Newest first)';

  @override
  String get emptyNotesMessage => 'No notes yet.\nTap the + button to add one!';

  @override
  String get noNotesFoundMessage => 'No notes found matching your search.';

  @override
  String errorLoadingNotes(String errorDetails) {
    return 'Error loading notes:\n$errorDetails';
  }

  @override
  String get addNoteFabTooltip => 'Add Note';

  @override
  String get homeNavigationLabel => 'Home';

  @override
  String get settingsNavigationLabel => 'Settings';

  @override
  String get settingsScreenTitle => 'Settings';

  @override
  String get appVersionLoading => 'Loading...';

  @override
  String appVersion(String version, String buildNumber) {
    return 'Version $version ($buildNumber)';
  }

  @override
  String get errorLoadingVersion => 'Error loading version';

  @override
  String get backupSuccessful => 'Backup successful!';

  @override
  String get backupFailed => 'Backup failed or cancelled.';

  @override
  String get restoreSuccessful => 'Restore successful!';

  @override
  String get restoreFailed => 'Restore failed or cancelled.';

  @override
  String get languageSectionTitle => 'Language';

  @override
  String get languageSystemDefault => 'System Default';

  @override
  String get appearanceSectionTitle => 'Appearance';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get dataManagementSectionTitle => 'Data Management';

  @override
  String get backupNotesTitle => 'Backup Notes';

  @override
  String get backupNotesSubtitle => 'Save notes to a file';

  @override
  String get restoreNotesTitle => 'Restore Notes';

  @override
  String get restoreNotesSubtitle => 'Load notes from a backup file';

  @override
  String get applicationSectionTitle => 'Application';

  @override
  String get checkForUpdatesTitle => 'Check for Updates';

  @override
  String get updateScreenTitle => 'App Update';

  @override
  String get updateStatusChecking => 'Checking for updates...';

  @override
  String get updateStatusAvailableTitle => 'Update Available!';

  @override
  String updateStatusCurrentVersion(String version) {
    return 'Current version: $version';
  }

  @override
  String updateStatusNewVersion(String version) {
    return 'New version: $version';
  }

  @override
  String get updateDownloadInstallButton => 'Download & Install';

  @override
  String updateStatusDownloading(String version) {
    return 'Downloading update ($version)...';
  }

  @override
  String updateProgressPercent(String progress) {
    return '$progress%';
  }

  @override
  String get updateStatusStartingInstall => 'Starting install...';

  @override
  String get updateStatusFailedTitle => 'Update Failed';

  @override
  String get updateTryAgainButton => 'Retry Check';

  @override
  String get updateStatusUpToDateTitle => 'You\'re up to date!';

  @override
  String updateStatusLatestAvailable(String version) {
    return '(Latest available: $version)';
  }

  @override
  String get updateCheckAgainButton => 'Check Again';

  @override
  String get updateStatusInstalled => 'Install dialog shown';

  @override
  String get updateErrorNoNewUpdate => 'No new update available.';

  @override
  String get updateErrorUnexpected =>
      'An unexpected error occurred during check.';

  @override
  String get updateErrorIncompleteInfo => 'Update information is incomplete.';

  @override
  String get updateErrorCouldNotStartInstall =>
      'Could not start installation. Check permissions.';

  @override
  String get updateErrorDownloadFailed =>
      'Download failed. Check connection and permissions.';

  @override
  String get versionNotAvailable => 'N/A';

  @override
  String get toolbarFontSize => 'Font Size';

  @override
  String get toolbarFontFamily => 'Font Family';

  @override
  String get toolbarSearchHint => 'Search...';

  @override
  String get toolbarCaseSensitive => 'Case sensitive';

  @override
  String get toolbarNoResults => 'No results';

  @override
  String toolbarSearchMatchOf(String current, String total) {
    return '$current of $total';
  }

  @override
  String get toolbarPreviousMatch => 'Previous match';

  @override
  String get toolbarNextMatch => 'Next match';

  @override
  String get toolbarCloseSearchTooltip => 'Close Search';

  @override
  String get toolbarCaseSensitiveTooltip => 'Toggle Case Sensitive';

  @override
  String get toolbarHeaderStyle => 'Header Style';
}
