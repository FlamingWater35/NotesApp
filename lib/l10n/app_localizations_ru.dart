// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Заметки';

  @override
  String get addNoteScreenTitle => 'Добавить новую заметку';

  @override
  String get saveNoteTooltip => 'Сохранить заметку';

  @override
  String get cannotSaveNoteWithoutTitle =>
      'Нельзя сохранить заметку без заголовка.';

  @override
  String get discardChangesDialogTitle => 'Отменить изменения?';

  @override
  String get discardChangesDialogContent =>
      'Если вы вернетесь сейчас, ваши изменения будут потеряны.';

  @override
  String get cancelButtonLabel => 'Отмена';

  @override
  String get discardButtonLabel => 'Отменить';

  @override
  String get quillPlaceholder => 'Начните писать заметки...';

  @override
  String get titleHint => 'Заголовок';

  @override
  String get untitledNote => 'Без названия';

  @override
  String get editNoteScreenTitle => 'Редактировать заметку';

  @override
  String get errorCouldNotLoadNoteData =>
      'Ошибка: Не удалось загрузить данные заметки.';

  @override
  String errorSavingNote(String errorDetails) {
    return 'Ошибка сохранения заметки: $errorDetails';
  }

  @override
  String get errorAppBarTitle => 'Ошибка';

  @override
  String get failedToLoadNote => 'Не удалось загрузить заметку.';

  @override
  String get saveChangesTooltip => 'Сохранить изменения';

  @override
  String get deleteNoteTooltip => 'Удалить заметку';

  @override
  String get deleteNoteDialogTitle => 'Удалить заметку?';

  @override
  String deleteNoteDialogContent(String noteTitle) {
    return 'Вы уверены, что хотите удалить \"$noteTitle\"? Это действие нельзя отменить.';
  }

  @override
  String get deleteButtonLabel => 'Удалить';

  @override
  String noteDeletedSnackbar(String noteTitle) {
    return 'Заметка \"$noteTitle\" удалена.';
  }

  @override
  String get sortPropertyDate => 'Дата';

  @override
  String get sortPropertyTitle => 'Заголовок';

  @override
  String get sortPropertyLastModified => 'Последнее изменение';

  @override
  String get sortPropertyCreatedAt => 'Дата создания';

  @override
  String get searchNotesHint => 'Поиск заметок...';

  @override
  String get clearSearchTooltip => 'Очистить поиск';

  @override
  String get sortByLabel => 'Сортировать по: ';

  @override
  String get sortAscendingTooltip => 'По возрастанию (А-Я, Старые сначала)';

  @override
  String get sortDescendingTooltip => 'По убыванию (Я-А, Новые сначала)';

  @override
  String get emptyNotesMessage =>
      'Пока нет заметок.\nНажмите +, чтобы добавить!';

  @override
  String get noNotesFoundMessage => 'Заметки не найдены.';

  @override
  String errorLoadingNotes(String errorDetails) {
    return 'Ошибка загрузки заметок:\n$errorDetails';
  }

  @override
  String get addNoteFabTooltip => 'Добавить заметку';

  @override
  String get homeNavigationLabel => 'Главная';

  @override
  String get settingsNavigationLabel => 'Настройки';

  @override
  String get settingsScreenTitle => 'Настройки';

  @override
  String get appVersionLoading => 'Загрузка...';

  @override
  String appVersion(String version, String buildNumber) {
    return 'Версия $version ($buildNumber)';
  }

  @override
  String get errorLoadingVersion => 'Ошибка загрузки версии';

  @override
  String get backupSuccessful => 'Резервная копия создана!';

  @override
  String get backupFailed => 'Ошибка создания резервной копии.';

  @override
  String get restoreSuccessful => 'Восстановление завершено!';

  @override
  String get restoreFailed => 'Ошибка восстановления.';

  @override
  String get languageSectionTitle => 'Язык';

  @override
  String get languageSystemDefault => 'Системный по умолчанию';

  @override
  String get appearanceSectionTitle => 'Внешний вид';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Темная';

  @override
  String get themeSystem => 'Системная';

  @override
  String get dataManagementSectionTitle => 'Управление данными';

  @override
  String get backupNotesTitle => 'Резервная копия заметок';

  @override
  String get backupNotesSubtitle => 'Сохранить заметки в файл';

  @override
  String get restoreNotesTitle => 'Восстановить заметки';

  @override
  String get restoreNotesSubtitle => 'Загрузить заметки из файла';

  @override
  String get applicationSectionTitle => 'Приложение';

  @override
  String get checkForUpdatesTitle => 'Проверить обновления';

  @override
  String get updateScreenTitle => 'Обновление приложения';

  @override
  String get updateStatusChecking => 'Проверка обновлений...';

  @override
  String get updateStatusAvailableTitle => 'Доступно обновление!';

  @override
  String updateStatusCurrentVersion(String version) {
    return 'Текущая версия: $version';
  }

  @override
  String updateStatusNewVersion(String version) {
    return 'Новая версия: $version';
  }

  @override
  String get updateDownloadInstallButton => 'Скачать и установить';

  @override
  String updateStatusDownloading(String version) {
    return 'Загрузка обновления ($version)...';
  }

  @override
  String updateProgressPercent(String progress) {
    return '$progress%';
  }

  @override
  String get updateStatusStartingInstall => 'Начало установки...';

  @override
  String get updateStatusFailedTitle => 'Ошибка обновления';

  @override
  String get updateTryAgainButton => 'Повторить проверку';

  @override
  String get updateStatusUpToDateTitle => 'У вас последняя версия!';

  @override
  String updateStatusLatestAvailable(String version) {
    return '(Последняя доступная: $version)';
  }

  @override
  String get updateCheckAgainButton => 'Проверить снова';

  @override
  String get updateStatusInstalled => 'Запрос на установку отправлен';

  @override
  String get updateErrorNoNewUpdate => 'Нет доступных обновлений.';

  @override
  String get updateErrorUnexpected => 'Произошла непредвиденная ошибка.';

  @override
  String get updateErrorIncompleteInfo => 'Неполная информация об обновлении.';

  @override
  String get updateErrorCouldNotStartInstall =>
      'Не удалось начать установку. Проверьте разрешения.';

  @override
  String get updateErrorDownloadFailed =>
      'Ошибка загрузки. Проверьте соединение.';

  @override
  String get versionNotAvailable => 'Н/Д';

  @override
  String get toolbarFontSize => 'Размер шрифта';

  @override
  String get toolbarFontFamily => 'Семейство шрифтов';

  @override
  String get toolbarSearchHint => 'Поиск...';

  @override
  String get toolbarCaseSensitive => 'Учитывать регистр';

  @override
  String get toolbarNoResults => 'Нет результатов';

  @override
  String toolbarSearchMatchOf(String current, String total) {
    return '$current из $total';
  }

  @override
  String get toolbarPreviousMatch => 'Предыдущее совпадение';

  @override
  String get toolbarNextMatch => 'Следующее совпадение';

  @override
  String get toolbarCloseSearchTooltip => 'Закрыть Поиск';

  @override
  String get toolbarCaseSensitiveTooltip => 'Переключить Учет Регистра';

  @override
  String get toolbarHeaderStyle => 'Стиль заголовка';

  @override
  String get enterFullscreenTooltip => 'Во весь экран';

  @override
  String get exitFullscreenTooltip => 'Выйти из полноэкранного режима';

  @override
  String get toolbarShowReplaceTooltip => 'Показать/Скрыть Параметры Замены';

  @override
  String get toolbarReplaceWithHint => 'Заменить на...';

  @override
  String get toolbarReplaceButton => 'Заменить';

  @override
  String get toolbarReplaceAllButton => 'Заменить Все';
}
