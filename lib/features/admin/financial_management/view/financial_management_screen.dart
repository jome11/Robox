import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart' as excel_pkg;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/robox_button.dart';
import '../../../../core/widgets/income_category_dropdown.dart';
import '../../../../data/models/transaction_model.dart';
import '../../../../data/repositories/finance_repository.dart';
import '../../../../data/repositories/stock_repository.dart';
import '../../../../core/utils/stock_refresh_notifier.dart';

class FinancialManagementScreen extends StatefulWidget {
  const FinancialManagementScreen({super.key});

  @override
  State<FinancialManagementScreen> createState() => _FinancialManagementScreenState();
}

class _FinancialManagementScreenState extends State<FinancialManagementScreen> {
  final FinanceRepository _financeRepository = FinanceRepositoryImpl();
  final StockRepository _stockRepository = StockRepositoryImpl();

  TransactionType _type = TransactionType.income;
  IncomeCategory? _category;
  String? _subCategory;
  final _customCategoryController = TextEditingController();
  final _amountController = TextEditingController();
  final _quantityController = TextEditingController();
  final _descriptionController = TextEditingController();

  List<TransactionModel> _transactions = [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final transactions = await _financeRepository.getAllTransactions();
      setState(() {
        _transactions = transactions;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _error = 'Could not load transactions. Check your connection.';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _customCategoryController.dispose();
    _amountController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _logEntry() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) return;
    if (_type == TransactionType.income && _category == null) return;

    final quantity = int.tryParse(_quantityController.text);

    setState(() => _isSubmitting = true);

    try {
      await _financeRepository.createTransaction(
        title: _type == TransactionType.income ? (_category?.label ?? 'Income') : 'Expense',
        amount: amount,
        type: _type,
        category: _type == TransactionType.income ? _category : null,
        subCategory: _subCategory,
        customCategory: _category == IncomeCategory.other ? _customCategoryController.text : null,
        quantity: quantity,
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
      );

      _amountController.clear();
      _quantityController.clear();
      _descriptionController.clear();
      _customCategoryController.clear();
      setState(() {
        _category = null;
        _subCategory = null;
      });

      await _loadTransactions();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to log transaction. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _pickExcelFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
      withData: true,
    );

    if (result != null) {
      final fileBytes = result.files.single.bytes;
      if (fileBytes == null) return;

      setState(() => _isSubmitting = true);
      try {
        final excel = excel_pkg.Excel.decodeBytes(fileBytes);
        final List<Map<String, dynamic>> items = [];

        // Simple parsing: Assuming sheet 1, headers NO, ITEM, QTY, PRICE
        for (var table in excel.tables.keys) {
          final sheet = excel.tables[table]!;
          // Skip header row
          for (int i = 1; i < sheet.maxRows; i++) {
            final row = sheet.rows[i];
            if (row.length < 4) continue;
            
            final name = row[1]?.value?.toString();
            final qty = int.tryParse(row[2]?.value?.toString() ?? '');
            final price = double.tryParse(row[3]?.value?.toString() ?? '');

            if (name != null && qty != null && price != null) {
              items.add({
                'itemName': name,
                'quantity': qty,
                'price': price,
              });
            }
          }
        }

        if (items.isNotEmpty) {
          await _stockRepository.restock(items);
          StockRefreshNotifier.instance.notifyRestocked();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Inventory restocked successfully')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to parse Excel: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _updateTransaction(String id, {String? title, double? amount, String? description}) async {
    try {
      await _financeRepository.updateTransaction(id, title: title, amount: amount, description: description);
      setState(() {
        final index = _transactions.indexWhere((t) => t.id == id);
        if (index != -1) {
          final t = _transactions[index];
          _transactions[index] = TransactionModel(
            id: t.id,
            title: title ?? t.title,
            amount: amount ?? t.amount,
            type: t.type,
            date: t.date,
            category: t.category,
            subCategory: t.subCategory,
            customCategory: t.customCategory,
            quantity: t.quantity,
            edited: true,
            description: description ?? t.description,
            addedBy: t.addedBy,
          );
        }
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save changes. Please try again.')),
      );
    }
  }

  void _showTransactionDetails(TransactionModel transaction) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _TransactionDetailModal(
        transaction: transaction,
        onUpdate: (title, amount, desc) => _updateTransaction(transaction.id, title: title, amount: amount, description: desc),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadTransactions,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Finance', style: AppTextStyles.headline),
              const SizedBox(height: 4),
              Text('Industrial resource allocation and transaction monitoring.',
                  style: AppTextStyles.body.copyWith(color: AppColors.textMuted)),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                      child: _TypeToggleButton(
                        label: 'Income',
                        selected: _type == TransactionType.income,
                        onTap: () => setState(() => _type = TransactionType.income),
                      )),
                  const SizedBox(width: 8),
                  Expanded(
                      child: _TypeToggleButton(
                        label: 'Expense',
                        selected: _type == TransactionType.expense,
                        onTap: () => setState(() => _type = TransactionType.expense),
                      )),
                ],
              ),
              const SizedBox(height: 16),
              if (_type == TransactionType.income) ...[
                IncomeCategoryDropdown(
                  selected: _category,
                  selectedSub: _subCategory,
                  customController: _customCategoryController,
                  onChanged: (c) => setState(() {
                    _category = c;
                    _subCategory = null;
                  }),
                  onSubChanged: (s) => setState(() => _subCategory = s),
                ),
                const SizedBox(height: 16),
                if (_category == IncomeCategory.threeDMachineSale || _category == IncomeCategory.filament) ...[
                  Text('QUANTITY SOLD', style: AppTextStyles.label),
                  const SizedBox(height: 8),
                  _StyledField(
                    controller: _quantityController,
                    hint: '0',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                ],
              ],
              Text('AMOUNT (ETB)', style: AppTextStyles.label),
              const SizedBox(height: 8),
              _StyledField(
                  controller: _amountController,
                  hint: '0.00',
                  keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              Text('DESCRIPTION', style: AppTextStyles.label),
              const SizedBox(height: 8),
              _StyledField(
                  controller: _descriptionController,
                  hint: 'Enter transaction details...',
                  maxLines: 3),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: RoboxButton(
                      label: _isSubmitting ? 'Logging...' : 'Log Transaction',
                      onPressed: _isSubmitting ? () {} : _logEntry,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RoboxButton(
                      label: 'UPLOAD EXCEL',
                      onPressed: _pickExcelFile,
                      isSecondary: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text('RECENT TRANSACTIONS', style: AppTextStyles.label),
              const SizedBox(height: 12),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_error!, style: AppTextStyles.body.copyWith(color: Colors.red)),
                      const SizedBox(height: 8),
                      TextButton(onPressed: _loadTransactions, child: const Text('Retry')),
                    ],
                  ),
                )
              else if (_transactions.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text('No transactions logged yet.',
                        style: AppTextStyles.body.copyWith(color: AppColors.textMuted)),
                  )
                else
                  ..._transactions.map((t) => GestureDetector(
                    onTap: () => _showTransactionDetails(t),
                    child: _TransactionTile(transaction: t),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _TransactionDetailModal extends StatefulWidget {
  final TransactionModel transaction;
  final Function(String title, double amount, String description) onUpdate;

  const _TransactionDetailModal({
    required this.transaction,
    required this.onUpdate,
  });

  @override
  State<_TransactionDetailModal> createState() => _TransactionDetailModalState();
}

class _TransactionDetailModalState extends State<_TransactionDetailModal> {
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.transaction.title);
    _amountController = TextEditingController(text: widget.transaction.amount.toStringAsFixed(2));
    _descriptionController = TextEditingController(text: widget.transaction.description);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = widget.transaction.type == TransactionType.income;
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.8,
      expand: false,
      builder: (context, scrollController) => SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isIncome ? 'INCOME' : 'EXPENSE',
                  style: AppTextStyles.label.copyWith(
                    color: isIncome ? AppColors.primary : AppColors.error,
                  ),
                ),
                Text(
                  '${widget.transaction.date.year}-${widget.transaction.date.month.toString().padLeft(2, '0')}-${widget.transaction.date.day.toString().padLeft(2, '0')}',
                  style: AppTextStyles.label,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(widget.transaction.title, style: AppTextStyles.headline),
                      ),
                      if (widget.transaction.edited)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceHigh,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('EDITED', style: AppTextStyles.label.copyWith(fontSize: 9)),
                        ),
                    ],
                  ),
                ),
                Text(
                  '${isIncome ? '+' : '-'}ETB ${widget.transaction.amount.toStringAsFixed(2)}',
                  style: AppTextStyles.headline.copyWith(
                    color: isIncome ? AppColors.primary : AppColors.error,
                  ),
                ),
              ],
            ),
            if (widget.transaction.categoryLabel != null) ...[
              const SizedBox(height: 4),
              Text('Classification: ${widget.transaction.categoryLabel}',
                  style: AppTextStyles.label),
            ],
            const SizedBox(height: 12),
            Text('LOGGED BY: ${widget.transaction.addedBy ?? 'System'}',
                style: AppTextStyles.label.copyWith(color: AppColors.primary)),
            const Divider(height: 32, color: AppColors.border),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('DETAILS', style: AppTextStyles.label),
                if (!_isEditing)
                  GestureDetector(
                    onTap: () => setState(() => _isEditing = true),
                    child: Text('EDIT',
                        style: AppTextStyles.label.copyWith(color: AppColors.primary)),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (_isEditing)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('TITLE', style: AppTextStyles.label),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _titleController,
                    style: AppTextStyles.body,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('AMOUNT (ETB)', style: AppTextStyles.label),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _amountController,
                    style: AppTextStyles.body,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('DESCRIPTION', style: AppTextStyles.label),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _descriptionController,
                    style: AppTextStyles.body,
                    maxLines: 4,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 16),
                  RoboxButton(
                    label: 'SAVE CHANGES',
                    onPressed: () {
                      final amount = double.tryParse(_amountController.text) ?? widget.transaction.amount;
                      widget.onUpdate(_titleController.text, amount, _descriptionController.text);
                      setState(() => _isEditing = false);
                    },
                  ),
                ],
              )
            else
              Text(
                widget.transaction.description ??
                    'No detailed information provided for this log entry.',
                style: AppTextStyles.body,
              ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _TypeToggleButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TypeToggleButton({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          label,
          style: AppTextStyles.label
              .copyWith(color: selected ? AppColors.onPrimary : AppColors.textMuted),
        ),
      ),
    );
  }
}

class _StyledField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;

  const _StyledField(
      {required this.controller, required this.hint, this.maxLines = 1, this.keyboardType});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: AppTextStyles.body,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.body.copyWith(color: AppColors.textMuted),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final TransactionModel transaction;

  const _TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(transaction.title, style: AppTextStyles.body),
                    if (transaction.edited)
                      Container(
                        margin: const EdgeInsets.only(left: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceHigh,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('EDITED', style: AppTextStyles.label.copyWith(fontSize: 9)),
                      ),
                  ],
                ),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (transaction.categoryLabel != null)
                      Text(
                        transaction.categoryLabel!,
                        style: AppTextStyles.label,
                      ),
                    if (transaction.categoryLabel != null)
                      Text(' · ', style: AppTextStyles.label),
                    Opacity(
                      opacity: 0.7,
                      child: Text(
                        'by ${transaction.addedBy ?? 'System'}',
                        style: AppTextStyles.label.copyWith(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : '-'}ETB ${transaction.amount.toStringAsFixed(2)}',
            style: AppTextStyles.body.copyWith(
              color: isIncome ? AppColors.primary : AppColors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
