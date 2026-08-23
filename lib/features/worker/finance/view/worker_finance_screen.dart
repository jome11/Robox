import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/robox_button.dart';
import '../../../../core/widgets/category_checklist.dart';
import '../../../../core/widgets/payment_method_picker.dart';
import '../../../../data/models/transaction_model.dart';
import '../../../../data/repositories/finance_repository.dart';

/// Worker's personal earnings/expenses log.
class WorkerFinanceScreen extends StatefulWidget {
  const WorkerFinanceScreen({super.key});

  @override
  State<WorkerFinanceScreen> createState() => _WorkerFinanceScreenState();
}

class _WorkerFinanceScreenState extends State<WorkerFinanceScreen> {
  final FinanceRepository _financeRepository = FinanceRepositoryImpl();

  TransactionType _type = TransactionType.income;
  Set<IncomeCategory> _categories = {};
  PaymentMethod? _paymentMethod;
  Set<String> _subCategories = {};
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
      final transactions = await _financeRepository.getMyTransactions();
      setState(() {
        _transactions = transactions;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _error = 'Could not load your transactions. Check your connection.';
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
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount.')),
      );
      return;
    }
    if (_type == TransactionType.income && _categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one category.')),
      );
      return;
    }
    if (_paymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a payment method.')),
      );
      return;
    }

    final quantity = int.tryParse(_quantityController.text);
    final categoryList = _categories.toList();

    setState(() => _isSubmitting = true);

    try {
      await _financeRepository.createTransaction(
        title: _type == TransactionType.income
            ? (categoryList.isNotEmpty ? categoryList.map((c) => c.label).join(', ') : 'Income')
            : 'Expense',
        amount: amount,
        type: _type,
        paymentMethod: _paymentMethod!,
        categories: _type == TransactionType.income ? categoryList : const [],
        subCategories: _subCategories.toList(),
        customCategory: _categories.contains(IncomeCategory.other) ? _customCategoryController.text : null,
        quantity: quantity,
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
      );

      _amountController.clear();
      _quantityController.clear();
      _descriptionController.clear();
      _customCategoryController.clear();
      setState(() {
        _categories = {};
        _subCategories = {};
        _paymentMethod = null;
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
            categories: t.categories,
            subCategories: t.subCategories,
            customCategory: t.customCategory,
            paymentMethod: t.paymentMethod,
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
    final isIncome = transaction.type == TransactionType.income;
    final titleController = TextEditingController(text: transaction.title);
    final amountController = TextEditingController(text: transaction.amount.toStringAsFixed(2));
    final descriptionController = TextEditingController(text: transaction.description);
    bool isEditing = false;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => DraggableScrollableSheet(
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
                      '${transaction.date.year}-${transaction.date.month.toString().padLeft(2, '0')}-${transaction.date.day.toString().padLeft(2, '0')}',
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
                            child: Text(transaction.title, style: AppTextStyles.headline),
                          ),
                          if (transaction.edited)
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
                      '${isIncome ? '+' : '-'}ETB ${transaction.amount.toStringAsFixed(2)}',
                      style: AppTextStyles.headline.copyWith(
                        color: isIncome ? AppColors.primary : AppColors.error,
                      ),
                    ),
                  ],
                ),
                if (transaction.categoryLabel != null) ...[
                  const SizedBox(height: 4),
                  Text('Classification: ${transaction.categoryLabel}', style: AppTextStyles.label),
                ],
                const SizedBox(height: 12),
                Text('LOGGED BY: ${transaction.addedBy ?? 'System'}',
                    style: AppTextStyles.label.copyWith(color: AppColors.primary)),
                const Divider(height: 32, color: AppColors.border),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('DETAILS', style: AppTextStyles.label),
                    if (!isEditing)
                      GestureDetector(
                        onTap: () => setModalState(() => isEditing = true),
                        child: Text('EDIT',
                            style: AppTextStyles.label.copyWith(color: AppColors.primary)),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                if (isEditing)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('TITLE', style: AppTextStyles.label),
                      const SizedBox(height: 4),
                      TextField(
                        controller: titleController,
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
                        controller: amountController,
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
                        controller: descriptionController,
                        style: AppTextStyles.body,
                        maxLines: 4,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.surface,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 16),
                      RoboxButton(
                        label: 'SAVE CHANGES',
                        onPressed: () {
                          final amount = double.tryParse(amountController.text) ?? transaction.amount;
                          _updateTransaction(transaction.id, title: titleController.text, amount: amount, description: descriptionController.text);
                          setModalState(() => isEditing = false);
                        },
                      ),
                    ],
                  )
                else
                  Text(
                    transaction.description ?? 'No detailed information provided for this log entry.',
                    style: AppTextStyles.body,
                  ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalIncome = _transactions
        .where((t) => t.type == TransactionType.income)
        .fold<double>(0, (sum, t) => sum + t.amount);
    final totalExpense = _transactions
        .where((t) => t.type == TransactionType.expense)
        .fold<double>(0, (sum, t) => sum + t.amount);

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
              const SizedBox(height: 20),
              if (!_isLoading && _error == null) ...[
                Row(
                  children: [
                    Expanded(
                      child: _TotalSummaryCard(
                        label: 'TOTAL INCOME',
                        amount: totalIncome,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _TotalSummaryCard(
                        label: 'TOTAL EXPENSE',
                        amount: totalExpense,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
              Row(
                children: [
                  Expanded(child: _TypeToggleButton(
                    label: 'Income',
                    selected: _type == TransactionType.income,
                    onTap: () => setState(() => _type = TransactionType.income),
                  )),
                  const SizedBox(width: 8),
                  Expanded(child: _TypeToggleButton(
                    label: 'Expense',
                    selected: _type == TransactionType.expense,
                    onTap: () => setState(() => _type = TransactionType.expense),
                  )),
                ],
              ),
              const SizedBox(height: 16),

              if (_type == TransactionType.income) ...[
                CategoryChecklist(
                  selected: _categories,
                  selectedSubs: _subCategories,
                  customController: _customCategoryController,
                  onChanged: (c) => setState(() {
                    _categories = c;
                  }),
                  onSubsChanged: (s) => setState(() => _subCategories = s),
                ),
                const SizedBox(height: 16),
                if (_categories.contains(IncomeCategory.threeDMachineSale) ||
                    _categories.contains(IncomeCategory.filament)) ...[
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

              PaymentMethodPicker(
                selected: _paymentMethod,
                onChanged: (m) => setState(() => _paymentMethod = m),
              ),
              const SizedBox(height: 16),

              Text('AMOUNT (ETB)', style: AppTextStyles.label),
              const SizedBox(height: 8),
              _StyledField(controller: _amountController, hint: '0.00', keyboardType: TextInputType.number),
              const SizedBox(height: 16),

              Text('DESCRIPTION', style: AppTextStyles.label),
              const SizedBox(height: 8),
              _StyledField(controller: _descriptionController, hint: 'Enter transaction details...', maxLines: 3),
              const SizedBox(height: 16),

              RoboxButton(
                label: _isSubmitting ? 'Logging...' : 'Log Transaction',
                onPressed: _isSubmitting ? () {} : _logEntry,
              ),
              const SizedBox(height: 24),

              Text('MY TRANSACTIONS', style: AppTextStyles.label),
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

class _TotalSummaryCard extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;

  const _TotalSummaryCard({required this.label, required this.amount, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.label.copyWith(color: AppColors.textMuted)),
          const SizedBox(height: 4),
          Text(
            'ETB ${amount.toStringAsFixed(2)}',
            style: AppTextStyles.body.copyWith(color: color, fontWeight: FontWeight.w700),
          ),
        ],
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
          style: AppTextStyles.label.copyWith(color: selected ? AppColors.onPrimary : AppColors.textMuted),
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

  const _StyledField({required this.controller, required this.hint, this.maxLines = 1, this.keyboardType});

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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
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