// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Notas';

  @override
  String get addNoteScreenTitle => 'Adicionar Nova Nota';

  @override
  String get saveNoteTooltip => 'Salvar Nota';

  @override
  String get cannotSaveNoteWithoutTitle =>
      'Não é possível salvar uma nota sem título.';

  @override
  String get discardChangesDialogTitle => 'Descartar alterações?';

  @override
  String get discardChangesDialogContent =>
      'Se você voltar agora, suas alterações serão perdidas.';

  @override
  String get cancelButtonLabel => 'Cancelar';

  @override
  String get discardButtonLabel => 'Descartar';

  @override
  String get quillPlaceholder => 'Comece a escrever suas notas...';

  @override
  String get titleHint => 'Título';

  @override
  String get untitledNote => 'Nota Sem Título';

  @override
  String get editNoteScreenTitle => 'Editar Nota';

  @override
  String get errorCouldNotLoadNoteData =>
      'Erro: Não foi possível carregar os dados da nota.';

  @override
  String errorSavingNote(String errorDetails) {
    return 'Erro ao salvar nota: $errorDetails';
  }

  @override
  String get errorAppBarTitle => 'Erro';

  @override
  String get failedToLoadNote => 'Falha ao carregar nota.';

  @override
  String get saveChangesTooltip => 'Salvar Alterações';

  @override
  String get deleteNoteTooltip => 'Excluir Nota';

  @override
  String get deleteNoteDialogTitle => 'Excluir Nota?';

  @override
  String deleteNoteDialogContent(String noteTitle) {
    return 'Tem certeza que deseja excluir \"$noteTitle\"? Esta ação não pode ser desfeita.';
  }

  @override
  String get deleteButtonLabel => 'Excluir';

  @override
  String noteDeletedSnackbar(String noteTitle) {
    return 'Nota \"$noteTitle\" excluída.';
  }

  @override
  String get sortPropertyDate => 'Data';

  @override
  String get sortPropertyTitle => 'Título';

  @override
  String get sortPropertyLastModified => 'Última Modificação';

  @override
  String get sortPropertyCreatedAt => 'Criada Em';

  @override
  String get searchNotesHint => 'Pesquisar notas...';

  @override
  String get clearSearchTooltip => 'Limpar Pesquisa';

  @override
  String get sortByLabel => 'Ordenar por: ';

  @override
  String get sortAscendingTooltip => 'Ascendente (A-Z, Mais antigas primeiro)';

  @override
  String get sortDescendingTooltip => 'Descendente (Z-A, Mais novas primeiro)';

  @override
  String get emptyNotesMessage =>
      'Nenhuma nota ainda.\nToque no + para adicionar!';

  @override
  String get noNotesFoundMessage => 'Nenhuma nota encontrada.';

  @override
  String errorLoadingNotes(String errorDetails) {
    return 'Erro ao carregar notas:\n$errorDetails';
  }

  @override
  String get addNoteFabTooltip => 'Adicionar Nota';

  @override
  String get homeNavigationLabel => 'Início';

  @override
  String get settingsNavigationLabel => 'Configurações';

  @override
  String get settingsScreenTitle => 'Configurações';

  @override
  String get appVersionLoading => 'Carregando...';

  @override
  String appVersion(String version, String buildNumber) {
    return 'Versão $version ($buildNumber)';
  }

  @override
  String get errorLoadingVersion => 'Erro ao carregar versão';

  @override
  String get backupSuccessful => 'Backup realizado!';

  @override
  String get backupFailed => 'Falha no backup.';

  @override
  String get restoreSuccessful => 'Restauração concluída!';

  @override
  String get restoreFailed => 'Falha na restauração.';

  @override
  String get languageSectionTitle => 'Idioma';

  @override
  String get languageSystemDefault => 'Padrão do Sistema';

  @override
  String get appearanceSectionTitle => 'Aparência';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Escuro';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get dataManagementSectionTitle => 'Gerenciamento de Dados';

  @override
  String get backupNotesTitle => 'Fazer Backup';

  @override
  String get backupNotesSubtitle => 'Salvar notas em arquivo';

  @override
  String get restoreNotesTitle => 'Restaurar Notas';

  @override
  String get restoreNotesSubtitle => 'Carregar notas de arquivo';

  @override
  String get applicationSectionTitle => 'Aplicativo';

  @override
  String get checkForUpdatesTitle => 'Verificar Atualizações';

  @override
  String get updateScreenTitle => 'Atualização do App';

  @override
  String get updateStatusChecking => 'Verificando atualizações...';

  @override
  String get updateStatusAvailableTitle => 'Atualização Disponível!';

  @override
  String updateStatusCurrentVersion(String version) {
    return 'Versão atual: $version';
  }

  @override
  String updateStatusNewVersion(String version) {
    return 'Nova versão: $version';
  }

  @override
  String get updateDownloadInstallButton => 'Baixar e Instalar';

  @override
  String updateStatusDownloading(String version) {
    return 'Baixando atualização ($version)...';
  }

  @override
  String updateProgressPercent(String progress) {
    return '$progress%';
  }

  @override
  String get updateStatusStartingInstall => 'Iniciando instalação...';

  @override
  String get updateStatusFailedTitle => 'Falha na Atualização';

  @override
  String get updateTryAgainButton => 'Tentar Novamente';

  @override
  String get updateStatusUpToDateTitle => 'Você está atualizado!';

  @override
  String updateStatusLatestAvailable(String version) {
    return '(Última versão: $version)';
  }

  @override
  String get updateCheckAgainButton => 'Verificar Novamente';

  @override
  String get updateStatusInstalled => 'Instalação iniciada';

  @override
  String get updateErrorNoNewUpdate => 'Nenhuma atualização disponível.';

  @override
  String get updateErrorUnexpected => 'Erro inesperado.';

  @override
  String get updateErrorIncompleteInfo => 'Informações incompletas.';

  @override
  String get updateErrorCouldNotStartInstall =>
      'Não foi possível instalar. Verifique permissões.';

  @override
  String get updateErrorDownloadFailed =>
      'Falha no download. Verifique conexão.';

  @override
  String get versionNotAvailable => 'N/D';

  @override
  String get toolbarFontSize => 'Tamanho da Fonte';

  @override
  String get toolbarFontFamily => 'Família da Fonte';

  @override
  String get toolbarSearchHint => 'Pesquisar...';

  @override
  String get toolbarCaseSensitive => 'Diferenciar maiúsculas/minúsculas';

  @override
  String get toolbarNoResults => 'Sem resultados';

  @override
  String toolbarSearchMatchOf(String current, String total) {
    return '$current de $total';
  }

  @override
  String get toolbarPreviousMatch => 'Resultado anterior';

  @override
  String get toolbarNextMatch => 'Próximo resultado';

  @override
  String get toolbarCloseSearchTooltip => 'Fechar Pesquisa';

  @override
  String get toolbarCaseSensitiveTooltip =>
      'Alternar Sensibilidade a Maiúsculas';

  @override
  String get toolbarHeaderStyle => 'Estilo do Cabeçalho';

  @override
  String get enterFullscreenTooltip => 'Entrar em tela cheia';

  @override
  String get exitFullscreenTooltip => 'Sair da tela cheia';

  @override
  String get toolbarShowReplaceTooltip =>
      'Mostrar/Ocultar Opções de Substituição';

  @override
  String get toolbarReplaceWithHint => 'Substituir por...';

  @override
  String get toolbarReplaceButton => 'Substituir';

  @override
  String get toolbarReplaceAllButton => 'Substituir Tudo';

  @override
  String toolbarTooManyMatchesShort(int count) {
    return 'Mais de $count correspondências';
  }
}
