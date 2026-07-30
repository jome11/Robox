# Implementation Plan - Self-Registration with Admin Approval

Implement a worker registration flow that requires administrator approval before access is granted.

## User Review Required

> [!IMPORTANT]
> - The authentication logic in `AuthBloc` will be updated to handle a specific "Account Pending" state.
> - `AuthRepository` and `AdminRepository` will use mock/stub implementations until the Dart Frog backend is integrated.
> - Rejecting a request will trigger a standard Flutter `showDialog` for confirmation.

## Proposed Changes

### Data Layer
#### [NEW] [pending_request_model.dart](file:///C:/Users/PAVILION/Desktop/Robox/lib/data/models/pending_request_model.dart)
- Model for administrator review: `id`, `name`, `email`, `requestedDate`.

#### [MODIFY] [auth_repository.dart](file:///C:/Users/PAVILION/Desktop/Robox/lib/data/repositories/auth_repository.dart)
- Add `signup(name, email, password)` method.
- Update `login` to return specific error types (success, pending, invalid).

#### [NEW] [admin_repository.dart](file:///C:/Users/PAVILION/Desktop/Robox/lib/data/repositories/admin_repository.dart)
- Interface for admin actions: `getPendingRequests()`, `approveRequest(id)`, `rejectRequest(id)`.

### BLoC Layer
#### [NEW] [signup_bloc.dart](file:///C:/Users/PAVILION/Desktop/Robox/lib/features/auth/bloc/signup_bloc.dart)
- Events: `SignupSubmitted`.
- States: `SignupInitial`, `SignupLoading`, `SignupSuccess`, `SignupError` (mapped to specific repository errors).

#### [NEW] [pending_requests_bloc.dart](file:///C:/Users/PAVILION/Desktop/Robox/lib/features/admin/pending_requests/bloc/pending_requests_bloc.dart)
- Events: `FetchPendingRequests`, `ApproveRequest`, `RejectRequest`.
- States: `PendingRequestsLoading`, `PendingRequestsLoaded`, `PendingRequestsError`.

### UI Layer (Auth)
#### [NEW] [signup_screen.dart](file:///C:/Users/PAVILION/Desktop/Robox/lib/features/auth/view/signup_screen.dart)
- Form with validation: Name, Email (Regex), Password (min 8 chars), Confirm Password (Match).
- Loading indicator on `RoboxButton`.

#### [NEW] [pending_approval_screen.dart](file:///C:/Users/PAVILION/Desktop/Robox/lib/features/auth/view/pending_approval_screen.dart)
- Informational screen after signup success.

#### [MODIFY] [login_screen.dart](file:///C:/Users/PAVILION/Desktop/Robox/lib/features/auth/view/login_screen.dart)
- Update error logic to show "Account pending admin approval" message.
- Add "Create Account" link/button.

### UI Layer (Admin)
#### [NEW] [pending_requests_screen.dart](file:///C:/Users/PAVILION/Desktop/Robox/lib/features/admin/pending_requests/view/pending_requests_screen.dart)
- List view of pending request cards.
- Confirmation dialog for Rejections.

#### [MODIFY] [admin_dashboard_screen.dart](file:///C:/Users/PAVILION/Desktop/Robox/lib/features/admin/dashboard/view/admin_dashboard_screen.dart)
- Add a counter badge (e.g., a small red circle with a number) near the header or navigation section if pending requests exist.

### Core
#### [MODIFY] [app_router.dart](file:///C:/Users/PAVILION/Desktop/Robox/lib/core/routes/app_router.dart)
- Add routes: `/signup`, `/pending-approval`, `/admin/pending-requests`.

## Verification Plan

### Automated Tests
- N/A (Manual verification prioritized for UI/UX flow).

### Manual Verification
1. **Signup Flow**:
   - Register a new worker.
   - Verify validation errors (e.g., mismatched passwords).
   - Submit and verify redirect to "Pending Approval" screen.
   - Try to log in with pending email -> Verify "Account Pending" message.
2. **Admin Approval**:
   - Log in as Admin.
   - Verify badge count on Dashboard.
   - Navigate to "Pending Requests".
   - Reject a request -> Verify confirmation dialog and item removal.
   - Approve a request -> Verify item removal and success snackbar.
