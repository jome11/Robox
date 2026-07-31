# Implementation Plan - Fix Navigation and UI Overflow

## Proposed Changes

### 1. Fix Dashboard Navigation
#### [MODIFY] [admin_dashboard_screen.dart](file:///C:/Users/PAVILION/Desktop/Robox/lib/features/admin/dashboard/view/admin_dashboard_screen.dart)
- Change `context.push('/admin/tasks')` to `context.go('/admin/tasks')`.
- This ensures `go_router` switches the active branch/tab in the `StatefulShellRoute` correctly, which makes the "Dashboard" button in the bottom nav responsive again (as it will correctly detect it's on a different branch).

### 2. Fix Financial Log Render Overflow
#### [MODIFY] [financial_management_screen.dart](file:///C:/Users/PAVILION/Desktop/Robox/lib/features/admin/financial_management/view/financial_management_screen.dart)
- In `_TransactionTile`, the subtitle `Row` (at line 449) is overflowing.
- I will wrap the entire subtitle `Row` in a `LayoutBuilder` or simply use a more constrained approach.
- Actually, the best way to handle this is to use `Expanded` for the text areas and `TextOverflow.ellipsis`. I will also check the outer `Row` constraints.

#### [MODIFY] [worker_finance_screen.dart](file:///C:/Users/PAVILION/Desktop/Robox/lib/features/worker/finance/view/worker_finance_screen.dart)
- Apply the same layout fixes to the worker's finance tile.

## Verification Plan

### Manual Verification
- **Navigation**: Click "Allocate New Task" on Dashboard, verify it takes you to the Tasks tab, then click "Dashboard" tab to return.
- **UI**: View the Finance screen on a narrow device emulator and verify no overflow bars appear on transaction tiles.
