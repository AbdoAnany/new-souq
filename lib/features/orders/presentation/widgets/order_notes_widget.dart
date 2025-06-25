import 'package:flutter/material.dart';
import '../../../../utils/responsive_util.dart';
import '../../domain/entities/order_entity.dart';

class OrderNotesWidget extends StatefulWidget {
  final OrderEntity order;
  final Function(String)? onNoteAdded;
  final bool isEditable;

  const OrderNotesWidget({
    Key? key,
    required this.order,
    this.onNoteAdded,
    this.isEditable = false,
  }) : super(key: key);

  @override
  State<OrderNotesWidget> createState() => _OrderNotesWidgetState();
}

class _OrderNotesWidgetState extends State<OrderNotesWidget> {
  final TextEditingController _noteController = TextEditingController();
  bool _isAddingNote = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUtil.spacing(
          mobile: 16,
          tablet: 20,
          desktop: 24,
        )),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order Notes',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (widget.isEditable && !_isAddingNote)
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _isAddingNote = true;
                      });
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Note'),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Existing notes
            if (widget.order.notes?.isNotEmpty == true)
              _buildExistingNotes(context)
            else
              _buildEmptyState(context),

            // Add note section
            if (_isAddingNote) ...[
              const SizedBox(height: 16),
              _buildAddNoteSection(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExistingNotes(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.note,
                size: 16,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
              const SizedBox(width: 8),
              Text(
                'Customer Notes',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.order.notes!,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.dividerColor,
          style: BorderStyle.solid,
        ),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.note_add,
              size: 48,
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.3),
            ),
            const SizedBox(height: 8),
            Text(
              'No notes for this order',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
            if (widget.isEditable) ...[
              const SizedBox(height: 8),
              Text(
                'Add a note to provide additional information',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAddNoteSection(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add a note to this order',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noteController,
            maxLines: 3,
            maxLength: 500,
            decoration: InputDecoration(
              hintText: 'Enter your note here...',
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: theme.colorScheme.background,
              counterText: '${_noteController.text.length}/500',
            ),
            onChanged: (value) {
              setState(() {}); // Update counter
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _isAddingNote = false;
                      _noteController.clear();
                    });
                  },
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _noteController.text.trim().isNotEmpty
                      ? _submitNote
                      : null,
                  child: const Text('Add Note'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _submitNote() {
    final note = _noteController.text.trim();
    if (note.isNotEmpty && widget.onNoteAdded != null) {
      widget.onNoteAdded!(note);
      setState(() {
        _isAddingNote = false;
        _noteController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Note added successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
