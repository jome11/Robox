import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/robox_button.dart';
import '../../../../core/widgets/income_category_dropdown.dart';
import '../../../../data/models/transaction_model.dart';
import '../../../auth/bloc/auth_bloc.dart';

/// Worker's personal earnings/expenses log.
class WorkerFinanceScreen extends StatefulWidget {
  const WorkerFinanceScreen({super.key});

  @override
  State<WorkerFinanceScreen> createState() => _WorkerFinanceScreenState();
}

class _WorkerFinanceScreenState extends State<WorkerFinanceScreen> {
  TransactionType _type = TransactionType.income;
  IncomeCategory? _category;
  final _customCategoryController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  final List<TransactionModel> _transactions = [
    TransactionModel(
      id: '1',
      title: 'Print job payout',
      amount: 320.00,
      type: TransactionType.income,
      date: DateTime.now().subtract(const Duration(hours: 5)),
      category: IncomeCategory.threeDPrint,
      description: 'Payout for the successful completion of the Node 7 maintenance print job.',
      addedBy: 'Worker Operator',
    ),
  ];

  @override
  void dispose() {
    _customCategoryController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _logEntry() {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) return;
    if (_type == TransactionType.income && _category == null) return;

    final authState = context.read<AuthBloc>().state;
    final userName = authState is AuthAuthenticated ? authState.user.name : 'Unknown Operator';

    setState(() {
      _transactions.insert(
        0,
        TransactionModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: _type == TransactionType.income 
              ? (_category?.label ?? 'Income') 
              : 'Expense',
          amount: amount,
          type: _type,
          date: DateTime.now(),
          category: _type == TransactionType.income ? _category : null,
          customCategory: _category == IncomeCategory.other ? _customCategoryController.text : null,
          description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
          addedBy: userName,
        ),
      );
      _amountController.clear();
      _descriptionController.clear();
      _customCategoryController.clear();
      _category = null;
    });
  }

  void _showTransactionDetails(TransactionModel transaction) {
    final isIncome = transaction.type == TransactionType.income;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
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
                    child: Text(transaction.title, style: AppTextStyles.headline),
                  ),
                  Text(
                    '${isIncome ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}',
                    style: AppTextStyles.headline.copyWith(
                      color: isIncome ? AppColors.primary : AppColors.error,
                    ),
                  ),
                ],
              ),
              if (transaction.categoryLabel != null) ...[
                const SizedBox(height: 4),
                Text('Category: ${transaction.categoryLabel}', style: AppTextStyles.label),
              ],
              const SizedBox(height: 12),
              Text('LOGGED BY: ${transaction.addedBy ?? 'System'}', 
                  style: AppTextStyles.label.copyWith(color: AppColors.primary)),
              const Divider(height: 32, color: AppColors.border),
              Text('DETAILS', style: AppTextStyles.label),
              const SizedBox(height: 8),
              Text(
                transaction.description ?? 'No detailed information provided for this log entry.',
                style: AppTextStyles.body,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Finance', style: AppTextStyles.headline),
            const SizedBox(height: 20),
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
              IncomeCategoryDropdown(
                selected: _category,
                customController: _customCategoryController,
                onChanged: (c) => setState(() => _category = c),
              ),
              const SizedBox(height: 16),
            ],

            Text('AMOUNT (USD)', style: AppTextStyles.label),
            const SizedBox(height: 8),
            _StyledField(controller: _amountController, hint: '0.00', keyboardType: TextInputType.number),
            const SizedBox(height: 16),

            Text('DESCRIPTION', style: AppTextStyles.label),
            const SizedBox(height: 8),
            _StyledField(controller: _descriptionController, hint: 'Enter transaction details...', maxLines: 3),
            const SizedBox(height: 16),

            RoboxButton(label: 'Log Transaction', onPressed: _logEntry),
            const SizedBox(height: 24),

            Text('MY TRANSACTIONS', style: AppTextStyles.label),
            const SizedBox(height: 12),
            ..._transactions.map((t) => GestureDetector(
                  onTap: () => _showTransactionDetails(t),
                  child: _TransactionTile(transaction: t),
                )),
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
                Text(transaction.title, style: AppTextStyles.body),
                Row(
                  children: [
                    if (transaction.categoryLabel != null)
                      Text(transaction.categoryLabel!, style: AppTextStyles.label),
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
            '${isIncome ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}',
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
