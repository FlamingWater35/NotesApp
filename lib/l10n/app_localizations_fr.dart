// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Notes';

  @override
  String get addNoteScreenTitle => 'Ajouter une Nouvelle Note';

  @override
  String get saveNoteTooltip => 'Enregistrer la Note';

  @override
  String get cannotSaveNoteWithoutTitle =>
      'Impossible d\'enregistrer une note sans titre.';

  @override
  String get discardChangesDialogTitle => 'Annuler les modifications ?';

  @override
  String get discardChangesDialogContent =>
      'Si vous revenez en arrière maintenant, vos modifications seront perdues.';

  @override
  String get cancelButtonLabel => 'Annuler';

  @override
  String get discardButtonLabel => 'Ignorer';

  @override
  String get quillPlaceholder => 'Commencez à écrire vos notes...';

  @override
  String get titleHint => 'Titre';

  @override
  String get untitledNote => 'Note Sans Titre';

  @override
  String get editNoteScreenTitle => 'Modifier la Note';

  @override
  String get errorCouldNotLoadNoteData =>
      'Erreur : Impossible de charger les données de la note.';

  @override
  String errorSavingNote(String errorDetails) {
    return 'Erreur lors de l\'enregistrement de la note : $errorDetails';
  }

  @override
  String get errorAppBarTitle => 'Erreur';

  @override
  String get failedToLoadNote => 'Échec du chargement de la note.';

  @override
  String get saveChangesTooltip => 'Enregistrer les Modifications';

  @override
  String get deleteNoteTooltip => 'Supprimer la Note';

  @override
  String get deleteNoteDialogTitle => 'Supprimer la Note ?';

  @override
  String deleteNoteDialogContent(String noteTitle) {
    return 'Êtes-vous sûr de vouloir supprimer \"$noteTitle\" ? Cette action est irréversible.';
  }

  @override
  String get deleteButtonLabel => 'Supprimer';

  @override
  String noteDeletedSnackbar(String noteTitle) {
    return 'Note \"$noteTitle\" supprimée.';
  }

  @override
  String get sortPropertyDate => 'Date';

  @override
  String get sortPropertyTitle => 'Titre';

  @override
  String get sortPropertyLastModified => 'Dernière Modification';

  @override
  String get sortPropertyCreatedAt => 'Date de Création';

  @override
  String get searchNotesHint => 'Rechercher des notes...';

  @override
  String get clearSearchTooltip => 'Effacer la Recherche';

  @override
  String get sortByLabel => 'Trier par : ';

  @override
  String get sortAscendingTooltip => 'Croissant (A-Z, Plus anciennes d\'abord)';

  @override
  String get sortDescendingTooltip =>
      'Décroissant (Z-A, Plus récentes d\'abord)';

  @override
  String get emptyNotesMessage =>
      'Aucune note pour l\'instant.\nAppuyez sur le bouton + pour en ajouter une !';

  @override
  String get noNotesFoundMessage =>
      'Aucune note trouvée correspondant à votre recherche.';

  @override
  String errorLoadingNotes(String errorDetails) {
    return 'Erreur lors du chargement des notes :\n$errorDetails';
  }

  @override
  String get addNoteFabTooltip => 'Ajouter une Note';

  @override
  String get homeNavigationLabel => 'Accueil';

  @override
  String get settingsNavigationLabel => 'Paramètres';

  @override
  String get settingsScreenTitle => 'Paramètres';

  @override
  String get appVersionLoading => 'Chargement...';

  @override
  String appVersion(String version, String buildNumber) {
    return 'Version $version ($buildNumber)';
  }

  @override
  String get errorLoadingVersion => 'Erreur de chargement de la version';

  @override
  String get backupSuccessful => 'Sauvegarde réussie !';

  @override
  String get backupFailed => 'Échec de la sauvegarde ou annulée.';

  @override
  String get restoreSuccessful => 'Restauration réussie !';

  @override
  String get restoreFailed => 'Échec de la restauration ou annulée.';

  @override
  String get languageSectionTitle => 'Langue';

  @override
  String get languageSystemDefault => 'Système par Défaut';

  @override
  String get appearanceSectionTitle => 'Apparence';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get themeSystem => 'Système';

  @override
  String get dataManagementSectionTitle => 'Gestion des Données';

  @override
  String get backupNotesTitle => 'Sauvegarder les Notes';

  @override
  String get backupNotesSubtitle => 'Enregistrer les notes dans un fichier';

  @override
  String get restoreNotesTitle => 'Restaurer les Notes';

  @override
  String get restoreNotesSubtitle =>
      'Charger les notes depuis un fichier de sauvegarde';

  @override
  String get applicationSectionTitle => 'Application';

  @override
  String get checkForUpdatesTitle => 'Vérifier les Mises à Jour';

  @override
  String get updateScreenTitle => 'Mise à Jour de l\'Application';

  @override
  String get updateStatusChecking => 'Vérification des mises à jour...';

  @override
  String get updateStatusAvailableTitle => 'Mise à Jour Disponible !';

  @override
  String updateStatusCurrentVersion(String version) {
    return 'Version actuelle : $version';
  }

  @override
  String updateStatusNewVersion(String version) {
    return 'Nouvelle version : $version';
  }

  @override
  String get updateDownloadInstallButton => 'Télécharger et Installer';

  @override
  String updateStatusDownloading(String version) {
    return 'Téléchargement de la mise à jour ($version)...';
  }

  @override
  String updateProgressPercent(String progress) {
    return '$progress%';
  }

  @override
  String get updateStatusStartingInstall => 'Démarrage de l\'installation...';

  @override
  String get updateStatusFailedTitle => 'Échec de la Mise à Jour';

  @override
  String get updateTryAgainButton => 'Réessayer la Vérification';

  @override
  String get updateStatusUpToDateTitle => 'Vous êtes à jour !';

  @override
  String updateStatusLatestAvailable(String version) {
    return '(Dernière disponible : $version)';
  }

  @override
  String get updateCheckAgainButton => 'Vérifier à Nouveau';

  @override
  String get updateStatusInstalled => 'Dialogue d\'installation affiché';

  @override
  String get updateErrorNoNewUpdate =>
      'Aucune nouvelle mise à jour disponible.';

  @override
  String get updateErrorUnexpected =>
      'Une erreur inattendue s\'est produite lors de la vérification.';

  @override
  String get updateErrorIncompleteInfo =>
      'Les informations de mise à jour sont incomplètes.';

  @override
  String get updateErrorCouldNotStartInstall =>
      'Impossible de démarrer l\'installation. Vérifiez les autorisations.';

  @override
  String get updateErrorDownloadFailed =>
      'Échec du téléchargement. Vérifiez la connexion et les autorisations.';

  @override
  String get versionNotAvailable => 'N/D';

  @override
  String get toolbarFontSize => 'Taille de la Police';

  @override
  String get toolbarFontFamily => 'Famille de Police';

  @override
  String get toolbarSearchHint => 'Rechercher...';

  @override
  String get toolbarCaseSensitive => 'Sensible à la casse';

  @override
  String get toolbarNoResults => 'Aucun résultat';

  @override
  String toolbarSearchMatchOf(String current, String total) {
    return '$current sur $total';
  }

  @override
  String get toolbarPreviousMatch => 'Correspondance précédente';

  @override
  String get toolbarNextMatch => 'Correspondance suivante';

  @override
  String get toolbarCloseSearchTooltip => 'Fermer la Recherche';

  @override
  String get toolbarCaseSensitiveTooltip =>
      'Basculer la Sensibilité à la Casse';

  @override
  String get toolbarHeaderStyle => 'Style d\'En-tête';

  @override
  String get enterFullscreenTooltip => 'Passer en plein écran';

  @override
  String get exitFullscreenTooltip => 'Quitter le mode plein écran';

  @override
  String get toolbarShowReplaceTooltip =>
      'Afficher/Masquer les Options de Remplacement';

  @override
  String get toolbarReplaceWithHint => 'Remplacer par...';

  @override
  String get toolbarReplaceButton => 'Remplacer';

  @override
  String get toolbarReplaceAllButton => 'Tout Remplacer';

  @override
  String toolbarTooManyMatchesShort(int count) {
    return '+ de $count résultats';
  }
}
