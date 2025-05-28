// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'メモ';

  @override
  String get addNoteScreenTitle => '新規メモ作成';

  @override
  String get saveNoteTooltip => 'メモを保存';

  @override
  String get cannotSaveNoteWithoutTitle => 'タイトルなしでは保存できません。';

  @override
  String get discardChangesDialogTitle => '変更を破棄しますか？';

  @override
  String get discardChangesDialogContent => '戻ると変更内容が失われます。';

  @override
  String get cancelButtonLabel => 'キャンセル';

  @override
  String get discardButtonLabel => '破棄';

  @override
  String get quillPlaceholder => 'メモを書き始める...';

  @override
  String get titleHint => 'タイトル';

  @override
  String get untitledNote => '無題のメモ';

  @override
  String get editNoteScreenTitle => 'メモを編集';

  @override
  String get errorCouldNotLoadNoteData => 'エラー：メモデータを読み込めませんでした。';

  @override
  String errorSavingNote(String errorDetails) {
    return 'メモ保存エラー: $errorDetails';
  }

  @override
  String get errorAppBarTitle => 'エラー';

  @override
  String get failedToLoadNote => 'メモの読み込みに失敗しました。';

  @override
  String get saveChangesTooltip => '変更を保存';

  @override
  String get deleteNoteTooltip => 'メモを削除';

  @override
  String get deleteNoteDialogTitle => 'メモを削除しますか？';

  @override
  String deleteNoteDialogContent(String noteTitle) {
    return '\"$noteTitle\"を削除しますか？この操作は元に戻せません。';
  }

  @override
  String get deleteButtonLabel => '削除';

  @override
  String noteDeletedSnackbar(String noteTitle) {
    return 'メモ\"$noteTitle\"を削除しました。';
  }

  @override
  String get sortPropertyDate => '日付';

  @override
  String get sortPropertyTitle => 'タイトル';

  @override
  String get sortPropertyLastModified => '最終更新';

  @override
  String get sortPropertyCreatedAt => '作成日';

  @override
  String get searchNotesHint => 'メモを検索...';

  @override
  String get clearSearchTooltip => '検索をクリア';

  @override
  String get sortByLabel => '並べ替え: ';

  @override
  String get sortAscendingTooltip => '昇順 (A-Z, 古い順)';

  @override
  String get sortDescendingTooltip => '降順 (Z-A, 新しい順)';

  @override
  String get emptyNotesMessage => 'メモがありません。\n+ボタンで追加！';

  @override
  String get noNotesFoundMessage => '該当するメモが見つかりません。';

  @override
  String errorLoadingNotes(String errorDetails) {
    return 'メモ読み込みエラー:\n$errorDetails';
  }

  @override
  String get addNoteFabTooltip => 'メモを追加';

  @override
  String get homeNavigationLabel => 'ホーム';

  @override
  String get settingsNavigationLabel => '設定';

  @override
  String get settingsScreenTitle => '設定';

  @override
  String get appVersionLoading => '読み込み中...';

  @override
  String appVersion(String version, String buildNumber) {
    return 'バージョン $version ($buildNumber)';
  }

  @override
  String get errorLoadingVersion => 'バージョン読み込みエラー';

  @override
  String get backupSuccessful => 'バックアップ成功！';

  @override
  String get backupFailed => 'バックアップ失敗（メモがありません？）';

  @override
  String get restoreSuccessful => '復元成功！';

  @override
  String get restoreFailed => '復元失敗（無効なファイル形式？）';

  @override
  String get languageSectionTitle => '言語';

  @override
  String get languageSystemDefault => 'システムデフォルト';

  @override
  String get appearanceSectionTitle => '外観';

  @override
  String get themeLight => 'ライト';

  @override
  String get themeDark => 'ダーク';

  @override
  String get themeSystem => 'システム';

  @override
  String get dataManagementSectionTitle => 'データ管理';

  @override
  String get backupNotesTitle => 'メモをバックアップ';

  @override
  String get backupNotesSubtitle => 'メモをファイルに保存';

  @override
  String get restoreNotesTitle => 'メモを復元';

  @override
  String get restoreNotesSubtitle => 'バックアップからメモを読み込み';

  @override
  String get applicationSectionTitle => 'アプリケーション';

  @override
  String get checkForUpdatesTitle => 'アップデートを確認';

  @override
  String get updateScreenTitle => 'アプリ更新';

  @override
  String get updateStatusChecking => 'アップデートを確認中...';

  @override
  String get updateStatusAvailableTitle => 'アップデートがあります！';

  @override
  String updateStatusCurrentVersion(String version) {
    return '現在のバージョン: $version';
  }

  @override
  String updateStatusNewVersion(String version) {
    return '新しいバージョン: $version';
  }

  @override
  String get updateDownloadInstallButton => 'ダウンロードしてインストール';

  @override
  String updateStatusDownloading(String version) {
    return 'アップデートをダウンロード中 ($version)...';
  }

  @override
  String updateProgressPercent(String progress) {
    return '$progress%';
  }

  @override
  String get updateStatusStartingInstall => 'インストールを開始しています...';

  @override
  String get updateStatusFailedTitle => 'アップデート失敗';

  @override
  String get updateTryAgainButton => '再試行';

  @override
  String get updateStatusUpToDateTitle => '最新版です！';

  @override
  String updateStatusLatestAvailable(String version) {
    return '(最新バージョン: $version)';
  }

  @override
  String get updateCheckAgainButton => '再確認';

  @override
  String get updateStatusInstalled => 'インストールダイアログを表示';

  @override
  String get updateErrorNoNewUpdate => '新しいアップデートはありません。';

  @override
  String get updateErrorUnexpected => '予期せぬエラーが発生しました。';

  @override
  String get updateErrorIncompleteInfo => 'アップデート情報が不完全です。';

  @override
  String get updateErrorCouldNotStartInstall => 'インストールを開始できませんでした。権限を確認してください。';

  @override
  String get updateErrorDownloadFailed => 'ダウンロードに失敗しました。接続を確認してください。';

  @override
  String get versionNotAvailable => 'N/A';
}
