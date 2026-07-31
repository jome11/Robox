# Implementation Plan - Finance Sub-Categories

Enhance the Finance screen by adding a "Classes" income category and implementing nested sub-category dropdowns for "3D Machine Sale", "Filament", and "Classes".

## User Review Required

> [!IMPORTANT]
> - I will add a new `subCategory` field to the `TransactionModel`.
> - The second dropdown will automatically appear when a category with defined sub-options is selected.
> - If "Classes" is selected, it will show a single sub-option: "Solidworks and 3D printing".

## Proposed Changes

### Data Layer
#### [MODIFY] [transaction_model.dart](file:///C:/Users/PAVILION/Desktop/Robox/lib/data/models/transaction_model.dart)
- Add `classes` to `IncomeCategory` enum.
- Add `final String? subCategory;` to `TransactionModel`.
- Update `categoryLabel` to include the sub-category if present (e.g., "Filament · PLA").

### Core Widgets
#### [MODIFY] [income_category_dropdown.dart](file:///C:/Users/PAVILION/Desktop/Robox/lib/core/widgets/income_category_dropdown.dart)
- Update to accept `subCategory` and `onSubCategoryChanged`.
- Add internal logic/maps for sub-categories:
    - **3D Machine Sale**: ENDER 3 V3 KE, ENDER 3 V3 PLUS, ENDER-5 MAX, K2 PLUS.
    - **Filament**: PLA FILAMENT, ABS FILAMENT, PETG FILAMENT, TPU FILAMENT.
    - **Classes**: Solidworks and 3D printing.
- Display a second dropdown below the primary one when these categories are selected.

### Feature Screens
#### [MODIFY] [financial_management_screen.dart](file:///C:/Users/PAVILION/Desktop/Robox/lib/features/admin/financial_management/view/financial_management_screen.dart)
#### [MODIFY] [worker_finance_screen.dart](file:///C:/Users/PAVILION/Desktop/Robox/lib/features/worker/finance/view/worker_finance_screen.dart)
- Manage `_subCategory` state.
- Reset `_subCategory` whenever the primary `_category` changes.
- Update `_logEntry` to pass the `subCategory` to the model.

## Verification Plan

### Manual Verification
- **Admin/Worker App**:
    - Navigate to **Finance**.
    - Select **Income** type.
    - Choose **3D Machine Sale** -> Verify the second dropdown appears with the 4 printer models.
    - Choose **Filament** -> Verify the 4 filament types appear.
    - Choose **Classes** -> Verify "Solidworks and 3D printing" appears as the only sub-option.
    - Log an entry and verify the "Category · Sub-Category" label appears correctly in the recent transactions list.
