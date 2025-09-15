import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../l10n/app_localizations.dart';

const kDefaultFontFamily = 'Sans Serif';

const Map<String, String> kFontFamilies = {
  'Sans Serif': 'sans-serif',
  'Arial': 'arial',
  'Helvetica': 'helvetica',
  'Verdana': 'verdana',
  'Trebuchet MS': 'trebuchet ms',
  'Serif': 'serif',
  'Georgia': 'georgia',
  'Times New Roman': 'times new roman',
  'Monospace': 'monospace',
  'Courier New': 'courier new',
  'Lucida Console': 'lucida console',
  'Cursive': 'cursive',
  'Fantasy': 'fantasy',
};

const Map<String, String?> kFontSizes = {
  'Small': 'small',
  'Normal': null,
  'Large': 'large',
  'Huge': 'huge',
};

class CustomQuillToolbarFontSizeButton extends StatelessWidget {
  const CustomQuillToolbarFontSizeButton({
    required this.controller,
    required this.options,
    super.key,
  });

  final QuillController controller;
  final QuillToolbarFontSizeButtonOptions options;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultTextStyle =
        options.style ?? theme.textTheme.bodyMedium ?? const TextStyle();
    final l10n = AppLocalizations.of(context);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final attribute =
            controller.getSelectionStyle().attributes[Attribute.size.key];
        final String currentSize =
            kFontSizes.entries
                .firstWhere(
                  (entry) => entry.value == attribute?.value,
                  orElse: () => const MapEntry('Normal', null),
                )
                .key;

        return TextButton(
          onPressed: () => _showFontSizeSheet(context, controller, l10n),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                currentSize,
                style: defaultTextStyle.copyWith(
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_drop_down,
                size: 20,
                color: theme.iconTheme.color,
              ),
            ],
          ),
        );
      },
    );
  }
}

class CustomQuillToolbarFontFamilyButton extends StatelessWidget {
  const CustomQuillToolbarFontFamilyButton({
    required this.controller,
    required this.options,
    super.key,
  });

  final QuillController controller;
  final QuillToolbarFontFamilyButtonOptions options;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultTextStyle =
        options.style ?? theme.textTheme.bodyMedium ?? const TextStyle();
    final l10n = AppLocalizations.of(context);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final String? currentFamily =
            controller
                .getSelectionStyle()
                .attributes[Attribute.font.key]
                ?.value;
        final String displayFamily =
            kFontFamilies.entries
                .firstWhere(
                  (entry) => entry.value == currentFamily,
                  orElse:
                      () => const MapEntry(kDefaultFontFamily, 'sans-serif'),
                )
                .key;

        return TextButton(
          onPressed: () => _showFontFamilySheet(context, controller, l10n),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                displayFamily,
                style: defaultTextStyle.copyWith(
                  fontFamily: currentFamily,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_drop_down,
                size: 20,
                color: theme.iconTheme.color,
              ),
            ],
          ),
        );
      },
    );
  }
}

void _showFontSizeSheet(
  BuildContext context,
  QuillController controller,
  AppLocalizations l10n,
) {
  final theme = Theme.of(context);
  final attribute =
      controller.getSelectionStyle().attributes[Attribute.size.key];
  final String? currentSizeValue = attribute?.value;

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height * 0.32,
    ),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
    ),
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Text(
                  l10n.toolbarFontSize,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Material(
                    color: Colors.transparent,
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: kFontSizes.length,
                      itemBuilder: (context, index) {
                        final entry = kFontSizes.entries.elementAt(index);
                        final isSelected = currentSizeValue == entry.value;

                        return ListTile(
                          title: Text(entry.key),
                          trailing: isSelected ? const Icon(Icons.check) : null,
                          selected: isSelected,
                          visualDensity: VisualDensity.compact,
                          selectedTileColor: theme.colorScheme.primary
                              .withAlpha(30),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          onTap: () {
                            controller.formatSelection(
                              Attribute.fromKeyValue(
                                Attribute.size.key,
                                entry.value,
                              ),
                            );
                            Navigator.of(context).pop();
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

void _showFontFamilySheet(
  BuildContext context,
  QuillController controller,
  AppLocalizations l10n,
) {
  final theme = Theme.of(context);
  final String? currentFamilyValue =
      controller.getSelectionStyle().attributes[Attribute.font.key]?.value;

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height * 0.5,
    ),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
    ),
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Text(
                  l10n.toolbarFontFamily,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Material(
                    color: Colors.transparent,
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: kFontFamilies.length,
                      itemBuilder: (context, index) {
                        final entry = kFontFamilies.entries.elementAt(index);

                        final bool isSelected;
                        if (currentFamilyValue == null) {
                          isSelected = entry.key == kDefaultFontFamily;
                        } else {
                          isSelected = currentFamilyValue == entry.value;
                        }

                        return ListTile(
                          title: Text(
                            entry.key,
                            style: TextStyle(fontFamily: entry.value),
                          ),
                          trailing: isSelected ? const Icon(Icons.check) : null,
                          selected: isSelected,
                          visualDensity: VisualDensity.compact,
                          selectedTileColor: theme.colorScheme.primary
                              .withAlpha(30),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          onTap: () {
                            controller.formatSelection(
                              Attribute.fromKeyValue(
                                Attribute.font.key,
                                entry.value,
                              ),
                            );
                            Navigator.of(context).pop();
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
