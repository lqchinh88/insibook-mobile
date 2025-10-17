import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

class DeleteAccountDialog extends StatefulWidget {
  final VoidCallback onConfirm;
  final bool isLoading;

  const DeleteAccountDialog({
    super.key,
    required this.onConfirm,
    this.isLoading = false,
  });

  @override
  State<DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<DeleteAccountDialog> {
  final _deleteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _deleteController.addListener(() {
      setState(() {}); // Rebuild when text changes
    });
  }

  @override
  void dispose() {
    _deleteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        final l10n = languageProvider.l10n;

        return AlertDialog(
          title: Text(
            l10n['deleteAccount'],
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n['deleteAccountWarning']),
              const SizedBox(height: 16),
              Text(
                l10n['deleteAccountConfirmation'],
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Text(
                  'delete',
                  style: TextStyle(
                    color: Colors.red[700],
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _deleteController,
                decoration: InputDecoration(
                  labelText: l10n['typeDelete'],
                  border: const OutlineInputBorder(),
                  hintText: 'delete',
                ),
                enabled: !widget.isLoading,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: widget.isLoading ? null : () => Navigator.of(context).pop(),
              child: Text(l10n['cancel']),
            ),
            ElevatedButton(
              onPressed: widget.isLoading || _deleteController.text.toLowerCase() != 'delete'
                  ? null
                  : () {
                      widget.onConfirm();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: widget.isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(l10n['delete']),
            ),
          ],
        );
      }
    );
  }
}