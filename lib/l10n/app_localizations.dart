import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en')
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get appTitle;

  /// No description provided for @addNoteScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Add New Note'**
  String get addNoteScreenTitle;

  /// No description provided for @saveNoteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Save Note'**
  String get saveNoteTooltip;

  /// No description provided for @cannotSaveNoteWithoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Cannot save a note without a title.'**
  String get cannotSaveNoteWithoutTitle;

  /// No description provided for @discardChangesDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get discardChangesDialogTitle;

  /// No description provided for @discardChangesDialogContent.
  ///
  /// In en, this message translates to:
  /// **'If you go back now, your changes will be lost.'**
  String get discardChangesDialogContent;

  /// No description provided for @cancelButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButtonLabel;

  /// No description provided for @discardButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discardButtonLabel;

  /// No description provided for @quillPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Start writing your notes...'**
  String get quillPlaceholder;

  /// No description provided for @titleHint.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get titleHint;

  /// No description provided for @untitledNote.
  ///
  /// In en, this message translates to:
  /// **'Untitled Note'**
  String get untitledNote;

  /// No description provided for @editNoteScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Note'**
  String get editNoteScreenTitle;

  /// No description provided for @errorCouldNotLoadNoteData.
  ///
  /// In en, this message translates to:
  /// **'Error: Could not load note data.'**
  String get errorCouldNotLoadNoteData;

  /// Error message shown when saving a note fails.
  ///
  /// In en, this message translates to:
  /// **'Error saving note: {errorDetails}'**
  String errorSavingNote(String errorDetails);

  /// No description provided for @errorAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorAppBarTitle;

  /// No description provided for @failedToLoadNote.
  ///
  /// In en, this message translates to:
  /// **'Failed to load note.'**
  String get failedToLoadNote;

  /// No description provided for @saveChangesTooltip.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChangesTooltip;

  /// No description provided for @deleteNoteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete Note'**
  String get deleteNoteTooltip;

  /// No description provided for @deleteNoteDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Note?'**
  String get deleteNoteDialogTitle;

  /// Confirmation message for deleting a note.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{noteTitle}\"? This action cannot be undone.'**
  String deleteNoteDialogContent(String noteTitle);

  /// No description provided for @deleteButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteButtonLabel;

  /// Snackbar message after a note is deleted.
  ///
  /// In en, this message translates to:
  /// **'Note \"{noteTitle}\" deleted.'**
  String noteDeletedSnackbar(String noteTitle);

  /// No description provided for @sortPropertyDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get sortPropertyDate;

  /// No description provided for @sortPropertyTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get sortPropertyTitle;

  /// No description provided for @sortPropertyLastModified.
  ///
  /// In en, this message translates to:
  /// **'Last Modified'**
  String get sortPropertyLastModified;

  /// No description provided for @sortPropertyCreatedAt.
  ///
  /// In en, this message translates to:
  /// **'Created At'**
  String get sortPropertyCreatedAt;

  /// No description provided for @searchNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Search notes...'**
  String get searchNotesHint;

  /// No description provided for @clearSearchTooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear Search'**
  String get clearSearchTooltip;

  /// No description provided for @sortByLabel.
  ///
  /// In en, this message translates to:
  /// **'Sort by: '**
  String get sortByLabel;

  /// No description provided for @sortAscendingTooltip.
  ///
  /// In en, this message translates to:
  /// **'Ascending (A-Z, Oldest first)'**
  String get sortAscendingTooltip;

  /// No description provided for @sortDescendingTooltip.
  ///
  /// In en, this message translates to:
  /// **'Descending (Z-A, Newest first)'**
  String get sortDescendingTooltip;

  /// No description provided for @emptyNotesMessage.
  ///
  /// In en, this message translates to:
  /// **'No notes yet.\nTap the + button to add one!'**
  String get emptyNotesMessage;

  /// No description provided for @noNotesFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'No notes found matching your search.'**
  String get noNotesFoundMessage;

  /// Error message shown when loading notes fails.
  ///
  /// In en, this message translates to:
  /// **'Error loading notes:\n{errorDetails}'**
  String errorLoadingNotes(String errorDetails);

  /// No description provided for @addNoteFabTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add Note'**
  String get addNoteFabTooltip;

  /// No description provided for @homeNavigationLabel.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeNavigationLabel;

  /// No description provided for @settingsNavigationLabel.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsNavigationLabel;

  /// No description provided for @settingsScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsScreenTitle;

  /// No description provided for @appVersionLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get appVersionLoading;

  /// Application version display string.
  ///
  /// In en, this message translates to:
  /// **'Version {version} ({buildNumber})'**
  String appVersion(String version, String buildNumber);

  /// No description provided for @errorLoadingVersion.
  ///
  /// In en, this message translates to:
  /// **'Error loading version'**
  String get errorLoadingVersion;

  /// No description provided for @backupSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Backup successful!'**
  String get backupSuccessful;

  /// No description provided for @backupFailed.
  ///
  /// In en, this message translates to:
  /// **'Backup failed or cancelled (no notes added?).'**
  String get backupFailed;

  /// No description provided for @restoreSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Restore successful!'**
  String get restoreSuccessful;

  /// No description provided for @restoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Restore failed or cancelled (invalid file format?)'**
  String get restoreFailed;

  /// No description provided for @appearanceSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceSectionTitle;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @dataManagementSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get dataManagementSectionTitle;

  /// No description provided for @backupNotesTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup Notes'**
  String get backupNotesTitle;

  /// No description provided for @backupNotesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save notes to a file'**
  String get backupNotesSubtitle;

  /// No description provided for @restoreNotesTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore Notes'**
  String get restoreNotesTitle;

  /// No description provided for @restoreNotesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Load notes from a backup file'**
  String get restoreNotesSubtitle;

  /// No description provided for @applicationSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Application'**
  String get applicationSectionTitle;

  /// No description provided for @checkForUpdatesTitle.
  ///
  /// In en, this message translates to:
  /// **'Check for Updates'**
  String get checkForUpdatesTitle;

  /// No description provided for @updateScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'App Update'**
  String get updateScreenTitle;

  /// No description provided for @updateStatusChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking for updates...'**
  String get updateStatusChecking;

  /// No description provided for @updateStatusAvailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Update Available!'**
  String get updateStatusAvailableTitle;

  /// No description provided for @updateStatusCurrentVersion.
  ///
  /// In en, this message translates to:
  /// **'Current version: {version}'**
  String updateStatusCurrentVersion(String version);

  /// No description provided for @updateStatusNewVersion.
  ///
  /// In en, this message translates to:
  /// **'New version: {version}'**
  String updateStatusNewVersion(String version);

  /// No description provided for @updateDownloadInstallButton.
  ///
  /// In en, this message translates to:
  /// **'Download & Install'**
  String get updateDownloadInstallButton;

  /// No description provided for @updateStatusDownloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading update ({version})...'**
  String updateStatusDownloading(String version);

  /// No description provided for @updateProgressPercent.
  ///
  /// In en, this message translates to:
  /// **'{progress}%'**
  String updateProgressPercent(String progress);

  /// No description provided for @updateStatusStartingInstall.
  ///
  /// In en, this message translates to:
  /// **'Starting install...'**
  String get updateStatusStartingInstall;

  /// No description provided for @updateStatusFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Update Failed'**
  String get updateStatusFailedTitle;

  /// No description provided for @updateTryAgainButton.
  ///
  /// In en, this message translates to:
  /// **'Retry Check'**
  String get updateTryAgainButton;

  /// No description provided for @updateStatusUpToDateTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re up to date!'**
  String get updateStatusUpToDateTitle;

  /// No description provided for @updateStatusLatestAvailable.
  ///
  /// In en, this message translates to:
  /// **'(Latest available: {version})'**
  String updateStatusLatestAvailable(String version);

  /// No description provided for @updateCheckAgainButton.
  ///
  /// In en, this message translates to:
  /// **'Check Again'**
  String get updateCheckAgainButton;

  /// No description provided for @updateStatusInstalled.
  ///
  /// In en, this message translates to:
  /// **'Install dialog shown'**
  String get updateStatusInstalled;

  /// No description provided for @updateErrorNoNewUpdate.
  ///
  /// In en, this message translates to:
  /// **'No new update available.'**
  String get updateErrorNoNewUpdate;

  /// No description provided for @updateErrorUnexpected.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred during check.'**
  String get updateErrorUnexpected;

  /// No description provided for @updateErrorIncompleteInfo.
  ///
  /// In en, this message translates to:
  /// **'Update information is incomplete.'**
  String get updateErrorIncompleteInfo;

  /// No description provided for @updateErrorCouldNotStartInstall.
  ///
  /// In en, this message translates to:
  /// **'Could not start installation. Check permissions.'**
  String get updateErrorCouldNotStartInstall;

  /// No description provided for @updateErrorDownloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Download failed. Check connection and permissions.'**
  String get updateErrorDownloadFailed;

  /// No description provided for @versionNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get versionNotAvailable;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
