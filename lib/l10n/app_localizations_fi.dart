// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Finnish (`fi`).
class AppLocalizationsFi extends AppLocalizations {
  AppLocalizationsFi([String locale = 'fi']) : super(locale);

  @override
  String get appTitle => 'Muistiinpanot';

  @override
  String get addNoteScreenTitle => 'Lisää uusi muistiinpano';

  @override
  String get saveNoteTooltip => 'Tallenna muistiinpano';

  @override
  String get cannotSaveNoteWithoutTitle => 'Muistiinpanoa ei voi tallentaa ilman otsikkoa.';

  @override
  String get discardChangesDialogTitle => 'Hylätäänkö muutokset?';

  @override
  String get discardChangesDialogContent => 'Jos palaat nyt, muutoksesi katoavat.';

  @override
  String get cancelButtonLabel => 'Peruuta';

  @override
  String get discardButtonLabel => 'Hylkää';

  @override
  String get quillPlaceholder => 'Aloita muistiinpanon kirjoittaminen...';

  @override
  String get titleHint => 'Otsikko';

  @override
  String get untitledNote => 'Nimetön muistiinpano';

  @override
  String get editNoteScreenTitle => 'Muokkaa muistiinpanoa';

  @override
  String get errorCouldNotLoadNoteData => 'Virhe: Muistiinpanon tietoja ei voitu ladata.';

  @override
  String errorSavingNote(String errorDetails) {
    return 'Virhe tallennettaessa muistiinpanoa: $errorDetails';
  }

  @override
  String get errorAppBarTitle => 'Virhe';

  @override
  String get failedToLoadNote => 'Muistiinpanon lataaminen epäonnistui.';

  @override
  String get saveChangesTooltip => 'Tallenna muutokset';

  @override
  String get deleteNoteTooltip => 'Poista muistiinpano';

  @override
  String get deleteNoteDialogTitle => 'Poistetaanko muistiinpano?';

  @override
  String deleteNoteDialogContent(String noteTitle) {
    return 'Haluatko varmasti poistaa \"$noteTitle\"? Toimintoa ei voi peruuttaa.';
  }

  @override
  String get deleteButtonLabel => 'Poista';

  @override
  String noteDeletedSnackbar(String noteTitle) {
    return 'Muistiinpano \"$noteTitle\" poistettu.';
  }

  @override
  String get sortPropertyDate => 'Päivämäärä';

  @override
  String get sortPropertyTitle => 'Otsikko';

  @override
  String get sortPropertyLastModified => 'Viimeksi muokattu';

  @override
  String get sortPropertyCreatedAt => 'Luontiaika';

  @override
  String get searchNotesHint => 'Etsi muistiinpanoja...';

  @override
  String get clearSearchTooltip => 'Tyhjennä haku';

  @override
  String get sortByLabel => 'Järjestä: ';

  @override
  String get sortAscendingTooltip => 'Nouseva (A-Ö, Vanhin ensin)';

  @override
  String get sortDescendingTooltip => 'Laskeva (Ö-A, Uusin ensin)';

  @override
  String get emptyNotesMessage => 'Ei muistiinpanoja vielä.\nPaina + lisätäksesi!';

  @override
  String get noNotesFoundMessage => 'Hakutuloksia ei löytynyt.';

  @override
  String errorLoadingNotes(String errorDetails) {
    return 'Virhe ladattaessa muistiinpanoja:\n$errorDetails';
  }

  @override
  String get addNoteFabTooltip => 'Lisää muistiinpano';

  @override
  String get homeNavigationLabel => 'Koti';

  @override
  String get settingsNavigationLabel => 'Asetukset';

  @override
  String get settingsScreenTitle => 'Asetukset';

  @override
  String get appVersionLoading => 'Ladataan...';

  @override
  String appVersion(String version, String buildNumber) {
    return 'Versio $version ($buildNumber)';
  }

  @override
  String get errorLoadingVersion => 'Virhe ladattaessa versiota';

  @override
  String get backupSuccessful => 'Varmuuskopiointi onnistui!';

  @override
  String get backupFailed => 'Varmuuskopiointi epäonnistui.';

  @override
  String get restoreSuccessful => 'Palautus onnistui!';

  @override
  String get restoreFailed => 'Palautus epäonnistui.';

  @override
  String get languageSectionTitle => 'Kieli';

  @override
  String get languageSystemDefault => 'Järjestelmän oletus';

  @override
  String get appearanceSectionTitle => 'Ulkoasu';

  @override
  String get themeLight => 'Vaalea';

  @override
  String get themeDark => 'Tumma';

  @override
  String get themeSystem => 'Järjestelmä';

  @override
  String get dataManagementSectionTitle => 'Datan hallinta';

  @override
  String get backupNotesTitle => 'Varmuuskopioi muistiinpanot';

  @override
  String get backupNotesSubtitle => 'Tallenna muistiinpanot tiedostoon';

  @override
  String get restoreNotesTitle => 'Palauta muistiinpanot';

  @override
  String get restoreNotesSubtitle => 'Lataa muistiinpanot tiedostosta';

  @override
  String get applicationSectionTitle => 'Sovellus';

  @override
  String get checkForUpdatesTitle => 'Tarkista päivitykset';

  @override
  String get updateScreenTitle => 'Sovelluksen päivitys';

  @override
  String get updateStatusChecking => 'Tarkistetaan päivityksiä...';

  @override
  String get updateStatusAvailableTitle => 'Päivitys saatavilla!';

  @override
  String updateStatusCurrentVersion(String version) {
    return 'Nykyinen versio: $version';
  }

  @override
  String updateStatusNewVersion(String version) {
    return 'Uusi versio: $version';
  }

  @override
  String get updateDownloadInstallButton => 'Lataa ja asenna';

  @override
  String updateStatusDownloading(String version) {
    return 'Ladataan päivitystä ($version)...';
  }

  @override
  String updateProgressPercent(String progress) {
    return '$progress%';
  }

  @override
  String get updateStatusStartingInstall => 'Aloitetaan asennus...';

  @override
  String get updateStatusFailedTitle => 'Päivitys epäonnistui';

  @override
  String get updateTryAgainButton => 'Yritä uudelleen';

  @override
  String get updateStatusUpToDateTitle => 'Sinulla on uusin versio!';

  @override
  String updateStatusLatestAvailable(String version) {
    return '(Viimeisin saatavilla: $version)';
  }

  @override
  String get updateCheckAgainButton => 'Tarkista uudelleen';

  @override
  String get updateStatusInstalled => 'Asennus aloitettu';

  @override
  String get updateErrorNoNewUpdate => 'Ei uusia päivityksiä.';

  @override
  String get updateErrorUnexpected => 'Odottamaton virhe tarkistuksessa.';

  @override
  String get updateErrorIncompleteInfo => 'Päivitystiedot puutteellisia.';

  @override
  String get updateErrorCouldNotStartInstall => 'Asennuksen aloitus epäonnistui. Tarkista oikeudet.';

  @override
  String get updateErrorDownloadFailed => 'Lataus epäonnistui. Tarkista yhteys.';

  @override
  String get versionNotAvailable => 'Ei saatavilla';
}
