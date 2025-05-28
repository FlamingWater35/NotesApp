import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fi.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_id.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

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
    Locale('en'),
    Locale('es'),
    Locale('fi'),
    Locale('fr'),
    Locale('id'),
    Locale('ja'),
    Locale('pt'),
    Locale('ru'),
    Locale('zh')
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get appTitle;

  /// Title for the screen where users add a new note.
  ///
  /// In en, this message translates to:
  /// **'Add New Note'**
  String get addNoteScreenTitle;

  /// Tooltip for the button that saves a new note.
  ///
  /// In en, this message translates to:
  /// **'Save Note'**
  String get saveNoteTooltip;

  /// Error message shown when a user tries to save a note without providing a title.
  ///
  /// In en, this message translates to:
  /// **'Cannot save a note without a title.'**
  String get cannotSaveNoteWithoutTitle;

  /// Title for the dialog asking the user if they want to discard unsaved changes.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get discardChangesDialogTitle;

  /// Content/body of the dialog asking the user if they want to discard unsaved changes.
  ///
  /// In en, this message translates to:
  /// **'If you go back now, your changes will be lost.'**
  String get discardChangesDialogContent;

  /// Label for a button that cancels an action or dismisses a dialog.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButtonLabel;

  /// Label for a button that discards changes.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discardButtonLabel;

  /// Placeholder text for the rich text editor where users write their note content.
  ///
  /// In en, this message translates to:
  /// **'Start writing your notes...'**
  String get quillPlaceholder;

  /// Hint text for the text field where users enter the note title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get titleHint;

  /// Default title for a note if the user doesn't provide one, or for display purposes when a title is missing.
  ///
  /// In en, this message translates to:
  /// **'Untitled Note'**
  String get untitledNote;

  /// Title for the screen where users edit an existing note.
  ///
  /// In en, this message translates to:
  /// **'Edit Note'**
  String get editNoteScreenTitle;

  /// Error message shown when the application fails to load the data for a note to be edited.
  ///
  /// In en, this message translates to:
  /// **'Error: Could not load note data.'**
  String get errorCouldNotLoadNoteData;

  /// Error message shown when saving a note fails.
  ///
  /// In en, this message translates to:
  /// **'Error saving note: {errorDetails}'**
  String errorSavingNote(String errorDetails);

  /// Generic title for an app bar on a screen displaying an error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorAppBarTitle;

  /// Message indicating that the application failed to load a specific note.
  ///
  /// In en, this message translates to:
  /// **'Failed to load note.'**
  String get failedToLoadNote;

  /// Tooltip for the button that saves changes to an existing note.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChangesTooltip;

  /// Tooltip for the button that deletes a note.
  ///
  /// In en, this message translates to:
  /// **'Delete Note'**
  String get deleteNoteTooltip;

  /// Title for the confirmation dialog when deleting a note.
  ///
  /// In en, this message translates to:
  /// **'Delete Note?'**
  String get deleteNoteDialogTitle;

  /// Confirmation message for deleting a note.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{noteTitle}\"? This action cannot be undone.'**
  String deleteNoteDialogContent(String noteTitle);

  /// Label for a button that confirms deletion.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteButtonLabel;

  /// Snackbar message shown after a note is successfully deleted.
  ///
  /// In en, this message translates to:
  /// **'Note \"{noteTitle}\" deleted.'**
  String noteDeletedSnackbar(String noteTitle);

  /// Label for sorting notes by their custom date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get sortPropertyDate;

  /// Label for sorting notes by their title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get sortPropertyTitle;

  /// Label for sorting notes by their last modified timestamp.
  ///
  /// In en, this message translates to:
  /// **'Last Modified'**
  String get sortPropertyLastModified;

  /// Label for sorting notes by their creation timestamp.
  ///
  /// In en, this message translates to:
  /// **'Created At'**
  String get sortPropertyCreatedAt;

  /// Hint text for the search bar used to find notes.
  ///
  /// In en, this message translates to:
  /// **'Search notes...'**
  String get searchNotesHint;

  /// Tooltip for the button that clears the search query.
  ///
  /// In en, this message translates to:
  /// **'Clear Search'**
  String get clearSearchTooltip;

  /// Label preceding the current sort criteria display.
  ///
  /// In en, this message translates to:
  /// **'Sort by: '**
  String get sortByLabel;

  /// Tooltip explaining the ascending sort order.
  ///
  /// In en, this message translates to:
  /// **'Ascending (A-Z, Oldest first)'**
  String get sortAscendingTooltip;

  /// Tooltip explaining the descending sort order.
  ///
  /// In en, this message translates to:
  /// **'Descending (Z-A, Newest first)'**
  String get sortDescendingTooltip;

  /// Message displayed on the home screen when there are no notes and no search query.
  ///
  /// In en, this message translates to:
  /// **'No notes yet.\nTap the + button to add one!'**
  String get emptyNotesMessage;

  /// Message displayed on the home screen when a search yields no results.
  ///
  /// In en, this message translates to:
  /// **'No notes found matching your search.'**
  String get noNotesFoundMessage;

  /// Error message shown when loading the list of notes fails.
  ///
  /// In en, this message translates to:
  /// **'Error loading notes:\n{errorDetails}'**
  String errorLoadingNotes(String errorDetails);

  /// Tooltip for the floating action button used to add a new note.
  ///
  /// In en, this message translates to:
  /// **'Add Note'**
  String get addNoteFabTooltip;

  /// Label for the 'Home' tab in the bottom navigation bar.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeNavigationLabel;

  /// Label for the 'Settings' tab in the bottom navigation bar.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsNavigationLabel;

  /// Title for the settings screen.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsScreenTitle;

  /// Text displayed while the application version is being fetched.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get appVersionLoading;

  /// Application version display string.
  ///
  /// In en, this message translates to:
  /// **'Version {version} ({buildNumber})'**
  String appVersion(String version, String buildNumber);

  /// Error message displayed if fetching the app version fails.
  ///
  /// In en, this message translates to:
  /// **'Error loading version'**
  String get errorLoadingVersion;

  /// Snackbar message indicating that the notes backup was successful.
  ///
  /// In en, this message translates to:
  /// **'Backup successful!'**
  String get backupSuccessful;

  /// Snackbar message indicating that the notes backup failed or was cancelled.
  ///
  /// In en, this message translates to:
  /// **'Backup failed or cancelled (no notes added?).'**
  String get backupFailed;

  /// Snackbar message indicating that restoring notes from a backup was successful.
  ///
  /// In en, this message translates to:
  /// **'Restore successful!'**
  String get restoreSuccessful;

  /// Snackbar message indicating that restoring notes failed or was cancelled.
  ///
  /// In en, this message translates to:
  /// **'Restore failed or cancelled (invalid file format?)'**
  String get restoreFailed;

  /// Section title for language settings.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSectionTitle;

  /// Label for the option to use the system's default language.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get languageSystemDefault;

  /// Section title for appearance settings (e.g., theme).
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceSectionTitle;

  /// Label for the light theme option.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// Label for the dark theme option.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// Label for the system theme option (follow OS settings).
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// Section title for data management settings (e.g., backup, restore).
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get dataManagementSectionTitle;

  /// Title for the 'Backup Notes' list tile in settings.
  ///
  /// In en, this message translates to:
  /// **'Backup Notes'**
  String get backupNotesTitle;

  /// Subtitle/description for the 'Backup Notes' list tile.
  ///
  /// In en, this message translates to:
  /// **'Save notes to a file'**
  String get backupNotesSubtitle;

  /// Title for the 'Restore Notes' list tile in settings.
  ///
  /// In en, this message translates to:
  /// **'Restore Notes'**
  String get restoreNotesTitle;

  /// Subtitle/description for the 'Restore Notes' list tile.
  ///
  /// In en, this message translates to:
  /// **'Load notes from a backup file'**
  String get restoreNotesSubtitle;

  /// Section title for application-related settings (e.g., updates).
  ///
  /// In en, this message translates to:
  /// **'Application'**
  String get applicationSectionTitle;

  /// Title for the 'Check for Updates' list tile in settings.
  ///
  /// In en, this message translates to:
  /// **'Check for Updates'**
  String get checkForUpdatesTitle;

  /// Title for the application update screen.
  ///
  /// In en, this message translates to:
  /// **'App Update'**
  String get updateScreenTitle;

  /// Status message indicating that the app is currently checking for updates.
  ///
  /// In en, this message translates to:
  /// **'Checking for updates...'**
  String get updateStatusChecking;

  /// Title indicating that a new update is available.
  ///
  /// In en, this message translates to:
  /// **'Update Available!'**
  String get updateStatusAvailableTitle;

  /// Displays the current installed version of the application.
  ///
  /// In en, this message translates to:
  /// **'Current version: {version}'**
  String updateStatusCurrentVersion(String version);

  /// Displays the version number of the available update.
  ///
  /// In en, this message translates to:
  /// **'New version: {version}'**
  String updateStatusNewVersion(String version);

  /// Label for the button to download and install an available update.
  ///
  /// In en, this message translates to:
  /// **'Download & Install'**
  String get updateDownloadInstallButton;

  /// Status message indicating that an update is being downloaded.
  ///
  /// In en, this message translates to:
  /// **'Downloading update ({version})...'**
  String updateStatusDownloading(String version);

  /// Displays the download progress as a percentage.
  ///
  /// In en, this message translates to:
  /// **'{progress}%'**
  String updateProgressPercent(String progress);

  /// Status message indicating that the installation process is about to begin.
  ///
  /// In en, this message translates to:
  /// **'Starting install...'**
  String get updateStatusStartingInstall;

  /// Title indicating that the update process has failed.
  ///
  /// In en, this message translates to:
  /// **'Update Failed'**
  String get updateStatusFailedTitle;

  /// Label for a button to retry checking for updates after a failure.
  ///
  /// In en, this message translates to:
  /// **'Retry Check'**
  String get updateTryAgainButton;

  /// Message indicating that the application is currently up to date.
  ///
  /// In en, this message translates to:
  /// **'You\'re up to date!'**
  String get updateStatusUpToDateTitle;

  /// Additional information showing the latest version known, even if it's the current one.
  ///
  /// In en, this message translates to:
  /// **'(Latest available: {version})'**
  String updateStatusLatestAvailable(String version);

  /// Label for a button to manually check for updates again.
  ///
  /// In en, this message translates to:
  /// **'Check Again'**
  String get updateCheckAgainButton;

  /// Status message indicating that the OS installation prompt for the update has been shown (app likely to restart).
  ///
  /// In en, this message translates to:
  /// **'Install dialog shown'**
  String get updateStatusInstalled;

  /// Message shown when check completes and no new update is found.
  ///
  /// In en, this message translates to:
  /// **'No new update available.'**
  String get updateErrorNoNewUpdate;

  /// Generic error message for unexpected issues during the update check.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred during check.'**
  String get updateErrorUnexpected;

  /// Error message if essential update information (URL, filename) is missing.
  ///
  /// In en, this message translates to:
  /// **'Update information is incomplete.'**
  String get updateErrorIncompleteInfo;

  /// Error message if the app fails to initiate the OS installation prompt.
  ///
  /// In en, this message translates to:
  /// **'Could not start installation. Check permissions.'**
  String get updateErrorCouldNotStartInstall;

  /// Error message if the update download fails.
  ///
  /// In en, this message translates to:
  /// **'Download failed. Check connection and permissions.'**
  String get updateErrorDownloadFailed;

  /// Placeholder for when a version number is not available or applicable.
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
  bool isSupported(Locale locale) => <String>['en', 'es', 'fi', 'fr', 'id', 'ja', 'pt', 'ru', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'fi': return AppLocalizationsFi();
    case 'fr': return AppLocalizationsFr();
    case 'id': return AppLocalizationsId();
    case 'ja': return AppLocalizationsJa();
    case 'pt': return AppLocalizationsPt();
    case 'ru': return AppLocalizationsRu();
    case 'zh': return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
