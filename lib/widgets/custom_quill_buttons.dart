import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

const kDefaultFontFamily = 'Sans Serif';

const Map<String, String> kFontFamilies = {
  'Sans Serif': 'sans-serif',
  'Serif': 'serif',
  'Monospace': 'monospace',
  'Cursive': 'cursive',
  'Fantasy': 'fantasy',
};

const Map<String, String?> kFontSizes = {
  'Small': 'small',
  'Normal': 'Normal',
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

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final attribute =
            controller.getSelectionStyle().attributes[Attribute.size.key];
        final String currentSize =
            kFontSizes.entries
                .firstWhere(
                  (entry) => entry.value == attribute?.value,
                  orElse: () => const MapEntry('Normal', 'Normal'),
                )
                .key;

        return TextButton(
          onPressed: () => _showFontSizeSheet(context, controller),
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
                  orElse: () => const MapEntry(kDefaultFontFamily, ''),
                )
                .key;

        return TextButton(
          onPressed: () => _showFontFamilySheet(context, controller),
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

void _showFontSizeSheet(BuildContext context, QuillController controller) {
  final theme = Theme.of(context);
  final attribute =
      controller.getSelectionStyle().attributes[Attribute.size.key];
  final String? currentSizeValue = attribute?.value;

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height * 0.4,
    ),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
    ),
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Font Size', style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: kFontSizes.length,
                  itemBuilder: (context, index) {
                    final entry = kFontSizes.entries.elementAt(index);
                    final isSelected = currentSizeValue == entry.value;

                    return ListTile(
                      title: Text(entry.key),
                      trailing: isSelected ? const Icon(Icons.check) : null,
                      selected: isSelected,
                      selectedTileColor: theme.colorScheme.primary.withOpacity(
                        0.1,
                      ),
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
            ],
          ),
        ),
      );
    },
  );
}

void _showFontFamilySheet(BuildContext context, QuillController controller) {
  final theme = Theme.of(context);
  final String? currentFamily =
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Font Family', style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: kFontFamilies.length,
                  itemBuilder: (context, index) {
                    final entry = kFontFamilies.entries.elementAt(index);
                    final isSelected = currentFamily == entry.value;

                    return ListTile(
                      title: Text(
                        entry.key,
                        style: TextStyle(fontFamily: entry.value),
                      ),
                      trailing: isSelected ? const Icon(Icons.check) : null,
                      selected: isSelected,
                      selectedTileColor: theme.colorScheme.primary.withOpacity(
                        0.1,
                      ),
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
            ],
          ),
        ),
      );
    },
  );
}
