# Implementation Plan - Excel Upload for Finance

Add functionality to upload Excel files on the Finance screen to support bulk transaction logging.

## User Review Required

> [!IMPORTANT]
> - I will add the `file_picker` dependency to `pubspec.yaml`.
> - The actual parsing of the Excel file requires the `excel` library. For this iteration, I will implement the UI button and the file selection flow. Full parsing logic can be added once the Excel format/schema is defined.
> - I will place the "UPLOAD EXCEL" button on the **Admin Finance** screen as a primary bulk-action tool.

## Proposed Changes

### Dependencies
#### [MODIFY] [pubspec.yaml](file:///C:/Users/PAVILION/Desktop/Robox/pubspec.yaml)
- Add `file_picker: ^8.0.0` to the dependencies.

### Admin Feature
#### [MODIFY] [financial_management_screen.dart](file:///C:/Users/PAVILION/Desktop/Robox/lib/features/admin/financial_management/view/financial_management_screen.dart)
- Add a secondary button "UPLOAD EXCEL" next to (or below) the "Log Transaction" button.
- Implement `_pickExcelFile()` using `FilePicker`.
- Show a `SnackBar` confirming the file name after selection.

### Worker Feature
#### [MODIFY] [worker_finance_screen.dart](file:///C:/Users/PAVILION/Desktop/Robox/lib/features/worker/finance/view/worker_finance_screen.dart)
- Add a smaller "Upload Receipt/Statement" icon or button if workers also need bulk upload capability (optional, but requested for "finance screen"). I will add it to both for consistency unless otherwise specified.

## Verification Plan

### Manual Verification
- **Admin App**:
    - Navigate to **Finance**.
    - Click "UPLOAD EXCEL".
    - Select a file from the device storage.
    - Verify that a SnackBar appears showing the selected file's name.
