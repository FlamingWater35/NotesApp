// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Notas';

  @override
  String get addNoteScreenTitle => 'Añadir Nueva Nota';

  @override
  String get saveNoteTooltip => 'Guardar Nota';

  @override
  String get cannotSaveNoteWithoutTitle =>
      'No se puede guardar una nota sin título.';

  @override
  String get discardChangesDialogTitle => '¿Descartar cambios?';

  @override
  String get discardChangesDialogContent =>
      'Si retrocedes ahora, tus cambios se perderán.';

  @override
  String get cancelButtonLabel => 'Cancelar';

  @override
  String get discardButtonLabel => 'Descartar';

  @override
  String get quillPlaceholder => 'Comienza a escribir tus notas...';

  @override
  String get titleHint => 'Título';

  @override
  String get untitledNote => 'Nota sin Título';

  @override
  String get editNoteScreenTitle => 'Editar Nota';

  @override
  String get errorCouldNotLoadNoteData =>
      'Error: No se pudieron cargar los datos de la nota.';

  @override
  String errorSavingNote(String errorDetails) {
    return 'Error al guardar la nota: $errorDetails';
  }

  @override
  String get errorAppBarTitle => 'Error';

  @override
  String get failedToLoadNote => 'Error al cargar la nota.';

  @override
  String get saveChangesTooltip => 'Guardar Cambios';

  @override
  String get deleteNoteTooltip => 'Eliminar Nota';

  @override
  String get deleteNoteDialogTitle => '¿Eliminar Nota?';

  @override
  String deleteNoteDialogContent(String noteTitle) {
    return '¿Estás seguro de que quieres eliminar \"$noteTitle\"? Esta acción no se puede deshacer.';
  }

  @override
  String get deleteButtonLabel => 'Eliminar';

  @override
  String noteDeletedSnackbar(String noteTitle) {
    return 'Nota \"$noteTitle\" eliminada.';
  }

  @override
  String get sortPropertyDate => 'Fecha';

  @override
  String get sortPropertyTitle => 'Título';

  @override
  String get sortPropertyLastModified => 'Última Modificación';

  @override
  String get sortPropertyCreatedAt => 'Fecha de Creación';

  @override
  String get searchNotesHint => 'Buscar notas...';

  @override
  String get clearSearchTooltip => 'Limpiar Búsqueda';

  @override
  String get sortByLabel => 'Ordenar por: ';

  @override
  String get sortAscendingTooltip => 'Ascendente (A-Z, Más antiguas primero)';

  @override
  String get sortDescendingTooltip => 'Descendente (Z-A, Más nuevas primero)';

  @override
  String get emptyNotesMessage =>
      'Aún no hay notas.\n¡Toca el botón + para añadir una!';

  @override
  String get noNotesFoundMessage =>
      'No se encontraron notas que coincidan con tu búsqueda.';

  @override
  String errorLoadingNotes(String errorDetails) {
    return 'Error al cargar las notas:\n$errorDetails';
  }

  @override
  String get addNoteFabTooltip => 'Añadir Nota';

  @override
  String get homeNavigationLabel => 'Inicio';

  @override
  String get settingsNavigationLabel => 'Ajustes';

  @override
  String get settingsScreenTitle => 'Ajustes';

  @override
  String get appVersionLoading => 'Cargando...';

  @override
  String appVersion(String version, String buildNumber) {
    return 'Versión $version ($buildNumber)';
  }

  @override
  String get errorLoadingVersion => 'Error al cargar la versión';

  @override
  String get backupSuccessful => '¡Copia de seguridad exitosa!';

  @override
  String get backupFailed => 'Copia de seguridad fallida o cancelada.';

  @override
  String get restoreSuccessful => '¡Restauración exitosa!';

  @override
  String get restoreFailed => 'Restauración fallida o cancelada.';

  @override
  String get languageSectionTitle => 'Idioma';

  @override
  String get languageSystemDefault => 'Predeterminado del Sistema';

  @override
  String get appearanceSectionTitle => 'Apariencia';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get dataManagementSectionTitle => 'Gestión de Datos';

  @override
  String get backupNotesTitle => 'Copia de Seguridad de Notas';

  @override
  String get backupNotesSubtitle => 'Guardar notas en un archivo';

  @override
  String get restoreNotesTitle => 'Restaurar Notas';

  @override
  String get restoreNotesSubtitle =>
      'Cargar notas desde un archivo de copia de seguridad';

  @override
  String get applicationSectionTitle => 'Aplicación';

  @override
  String get checkForUpdatesTitle => 'Buscar Actualizaciones';

  @override
  String get updateScreenTitle => 'Actualización de la Aplicación';

  @override
  String get updateStatusChecking => 'Buscando actualizaciones...';

  @override
  String get updateStatusAvailableTitle => '¡Actualización Disponible!';

  @override
  String updateStatusCurrentVersion(String version) {
    return 'Versión actual: $version';
  }

  @override
  String updateStatusNewVersion(String version) {
    return 'Nueva versión: $version';
  }

  @override
  String get updateDownloadInstallButton => 'Descargar e Instalar';

  @override
  String updateStatusDownloading(String version) {
    return 'Descargando actualización ($version)...';
  }

  @override
  String updateProgressPercent(String progress) {
    return '$progress%';
  }

  @override
  String get updateStatusStartingInstall => 'Iniciando instalación...';

  @override
  String get updateStatusFailedTitle => 'Actualización Fallida';

  @override
  String get updateTryAgainButton => 'Reintentar Búsqueda';

  @override
  String get updateStatusUpToDateTitle => '¡Estás al día!';

  @override
  String updateStatusLatestAvailable(String version) {
    return '(Última disponible: $version)';
  }

  @override
  String get updateCheckAgainButton => 'Buscar de Nuevo';

  @override
  String get updateStatusInstalled => 'Diálogo de instalación mostrado';

  @override
  String get updateErrorNoNewUpdate =>
      'No hay nuevas actualizaciones disponibles.';

  @override
  String get updateErrorUnexpected =>
      'Ocurrió un error inesperado durante la búsqueda.';

  @override
  String get updateErrorIncompleteInfo =>
      'La información de la actualización está incompleta.';

  @override
  String get updateErrorCouldNotStartInstall =>
      'No se pudo iniciar la instalación. Verifica los permisos.';

  @override
  String get updateErrorDownloadFailed =>
      'Descarga fallida. Verifica la conexión y los permisos.';

  @override
  String get versionNotAvailable => 'N/D';

  @override
  String get toolbarFontSize => 'Tamaño de Fuente';

  @override
  String get toolbarFontFamily => 'Familia de Fuentes';

  @override
  String get toolbarSearchInNote => 'Buscar en la Nota';

  @override
  String get toolbarSearchHint => 'Buscar...';

  @override
  String get toolbarCaseSensitive => 'Distinguir mayúsculas y minúsculas';

  @override
  String get toolbarNoResults => 'No hay resultados';

  @override
  String get toolbarCloseButtonLabel => 'Cerrar';

  @override
  String toolbarSearchMatchOf(String current, String total) {
    return '$current de $total';
  }

  @override
  String get toolbarPreviousMatch => 'Coincidencia anterior';

  @override
  String get toolbarNextMatch => 'Siguiente coincidencia';
}
