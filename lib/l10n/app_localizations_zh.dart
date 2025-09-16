// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '笔记';

  @override
  String get addNoteScreenTitle => '添加新笔记';

  @override
  String get saveNoteTooltip => '保存笔记';

  @override
  String get cannotSaveNoteWithoutTitle => '无法保存无标题笔记。';

  @override
  String get discardChangesDialogTitle => '放弃更改？';

  @override
  String get discardChangesDialogContent => '如果现在返回，您的更改将丢失。';

  @override
  String get cancelButtonLabel => '取消';

  @override
  String get discardButtonLabel => '放弃';

  @override
  String get quillPlaceholder => '开始写笔记...';

  @override
  String get titleHint => '标题';

  @override
  String get untitledNote => '无标题笔记';

  @override
  String get editNoteScreenTitle => '编辑笔记';

  @override
  String get errorCouldNotLoadNoteData => '错误：无法加载笔记数据。';

  @override
  String errorSavingNote(String errorDetails) {
    return '保存笔记时出错：$errorDetails';
  }

  @override
  String get errorAppBarTitle => '错误';

  @override
  String get failedToLoadNote => '加载笔记失败。';

  @override
  String get saveChangesTooltip => '保存更改';

  @override
  String get deleteNoteTooltip => '删除笔记';

  @override
  String get deleteNoteDialogTitle => '删除笔记？';

  @override
  String deleteNoteDialogContent(String noteTitle) {
    return '您确定要删除“$noteTitle”吗？此操作无法撤销。';
  }

  @override
  String get deleteButtonLabel => '删除';

  @override
  String noteDeletedSnackbar(String noteTitle) {
    return '笔记“$noteTitle”已删除。';
  }

  @override
  String get sortPropertyDate => '日期';

  @override
  String get sortPropertyTitle => '标题';

  @override
  String get sortPropertyLastModified => '最后修改';

  @override
  String get sortPropertyCreatedAt => '创建时间';

  @override
  String get searchNotesHint => '搜索笔记...';

  @override
  String get clearSearchTooltip => '清除搜索';

  @override
  String get sortByLabel => '排序：';

  @override
  String get sortAscendingTooltip => '升序 (A-Z, 最旧的在前)';

  @override
  String get sortDescendingTooltip => '降序 (Z-A, 最新的在前)';

  @override
  String get emptyNotesMessage => '还没有笔记。\n点击 + 按钮添加一个！';

  @override
  String get noNotesFoundMessage => '未找到与您的搜索匹配的笔记。';

  @override
  String errorLoadingNotes(String errorDetails) {
    return '加载笔记时出错：\n$errorDetails';
  }

  @override
  String get addNoteFabTooltip => '添加笔记';

  @override
  String get homeNavigationLabel => '主页';

  @override
  String get settingsNavigationLabel => '设置';

  @override
  String get settingsScreenTitle => '设置';

  @override
  String get appVersionLoading => '加载中...';

  @override
  String appVersion(String version, String buildNumber) {
    return '版本 $version ($buildNumber)';
  }

  @override
  String get errorLoadingVersion => '加载版本信息失败';

  @override
  String get backupSuccessful => '备份成功！';

  @override
  String get backupFailed => '备份失败或已取消。';

  @override
  String get restoreSuccessful => '恢复成功！';

  @override
  String get restoreFailed => '恢复失败或已取消。';

  @override
  String get languageSectionTitle => '语言';

  @override
  String get languageSystemDefault => '系统默认';

  @override
  String get appearanceSectionTitle => '外观';

  @override
  String get themeLight => '浅色';

  @override
  String get themeDark => '深色';

  @override
  String get themeSystem => '系统';

  @override
  String get dataManagementSectionTitle => '数据管理';

  @override
  String get backupNotesTitle => '备份笔记';

  @override
  String get backupNotesSubtitle => '将笔记保存到文件';

  @override
  String get restoreNotesTitle => '恢复笔记';

  @override
  String get restoreNotesSubtitle => '从备份文件加载笔记';

  @override
  String get applicationSectionTitle => '应用程序';

  @override
  String get checkForUpdatesTitle => '检查更新';

  @override
  String get updateScreenTitle => '应用更新';

  @override
  String get updateStatusChecking => '正在检查更新...';

  @override
  String get updateStatusAvailableTitle => '有可用更新！';

  @override
  String updateStatusCurrentVersion(String version) {
    return '当前版本：$version';
  }

  @override
  String updateStatusNewVersion(String version) {
    return '新版本：$version';
  }

  @override
  String get updateDownloadInstallButton => '下载并安装';

  @override
  String updateStatusDownloading(String version) {
    return '正在下载更新 ($version)...';
  }

  @override
  String updateProgressPercent(String progress) {
    return '$progress%';
  }

  @override
  String get updateStatusStartingInstall => '正在开始安装...';

  @override
  String get updateStatusFailedTitle => '更新失败';

  @override
  String get updateTryAgainButton => '重试检查';

  @override
  String get updateStatusUpToDateTitle => '您已是最新版本！';

  @override
  String updateStatusLatestAvailable(String version) {
    return '(最新可用：$version)';
  }

  @override
  String get updateCheckAgainButton => '再次检查';

  @override
  String get updateStatusInstalled => '已显示安装对话框';

  @override
  String get updateErrorNoNewUpdate => '没有可用的新更新。';

  @override
  String get updateErrorUnexpected => '检查过程中发生意外错误。';

  @override
  String get updateErrorIncompleteInfo => '更新信息不完整。';

  @override
  String get updateErrorCouldNotStartInstall => '无法开始安装。请检查权限。';

  @override
  String get updateErrorDownloadFailed => '下载失败。请检查网络连接和权限。';

  @override
  String get versionNotAvailable => '不可用';

  @override
  String get toolbarFontSize => '字体大小';

  @override
  String get toolbarFontFamily => '字体系列';

  @override
  String get toolbarSearchHint => '搜索...';

  @override
  String get toolbarCaseSensitive => '区分大小写';

  @override
  String get toolbarNoResults => '无结果';

  @override
  String toolbarSearchMatchOf(String current, String total) {
    return '$current/$total';
  }

  @override
  String get toolbarPreviousMatch => '上一个匹配项';

  @override
  String get toolbarNextMatch => '下一个匹配项';

  @override
  String get toolbarCloseSearchTooltip => '关闭搜索';

  @override
  String get toolbarCaseSensitiveTooltip => '切换大小写敏感';

  @override
  String get toolbarHeaderStyle => '标题样式';

  @override
  String get enterFullscreenTooltip => '进入全屏';

  @override
  String get exitFullscreenTooltip => '退出全屏';

  @override
  String get toolbarShowReplaceTooltip => '显示/隐藏替换选项';

  @override
  String get toolbarReplaceWithHint => '替换为...';

  @override
  String get toolbarReplaceButton => '替换';

  @override
  String get toolbarReplaceAllButton => '全部替换';
}
