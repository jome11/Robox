# Implementation Plan - Interactive Details for Tasks and Finance

Enhance the ROBOX app by adding clickable details to Worker tasks and Admin financial logs.

## User Review Required

> [!IMPORTANT]
> - I will add `isGroupTask` to `TaskModel` to distinguish between individual and group tasks.
> - I will add a `description` field to `TransactionModel` to store and display detailed notes for financial logs.
> - Details will be displayed using a styled `showModalBottomSheet` for a modern mobile feel.

## Proposed Changes

### Data Models
#### [MODIFY] [task_model.dart](file:///C:/Users/PAVILION/Desktop/Robox/lib/data/models/task_model.dart)
- Add `final bool isGroupTask;` to `TaskModel`.
- Update constructor.

#### [MODIFY] [transaction_model.dart](file:///C:/Users/PAVILION/Desktop/Robox/lib/data/models/transaction_model.dart)
- Add `final String? description;` to `TransactionModel`.
- Update constructor.

### Worker Feature
#### [MODIFY] [my_tasks_screen.dart](file:///C:/Users/PAVILION/Desktop/Robox/lib/features/worker/my_tasks/view/my_tasks_screen.dart)
- Update mock data to include `isGroupTask`.
- Wrap `_TaskCard` in `InkWell`.
- Implement `_showTaskDetails` modal displaying:
    - Title, Priority Tag, Status.
    - Type: "Individual Task" or "Group Task".
    - Full Description.
    - Deadline.

### Admin Feature
#### [MODIFY] [financial_management_screen.dart](file:///C:/Users/PAVILION/Desktop/Robox/lib/features/admin/financial_management/view/financial_management_screen.dart)
- Update `logEntry` to pass both `title` (category/type summary) and `description` (user input).
- Update mock data to include descriptions.
- Wrap `_TransactionTile` in `InkWell`.
- Implement `_showTransactionDetails` modal displaying:
    - Title & Amount.
    - Category.
    - Date & Time.
    - Detailed Description/Notes.

## Verification Plan

### Manual Verification
- **Worker App**:
    - Navigate to "Tasks".
    - Click a task card.
    - Verify modal appears with correct "Individual/Group" type and description.
- **Admin App**:
    - Navigate to "Finance".
    - Log a new entry with a description.
    - Click the log entry in the list.
    - Verify modal appears with the correct description and transaction info.
