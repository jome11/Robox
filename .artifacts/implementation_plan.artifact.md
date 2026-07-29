# Implementation Plan - Admin User Management & Password Visibility

Enhance Admin capabilities on the Ranking screen to view user passwords and assign them during account creation.

## User Review Required

> [!WARNING]
> Displaying passwords in plain text is a security risk and is only being implemented here for mock/demonstration purposes as requested.

## Proposed Changes

### Data Model
#### [MODIFY] [leaderboard_entry_model.dart](file:///C:/Users/PAVILION/Desktop/Robox/lib/data/models/leaderboard_entry_model.dart)
- Add `final String password;` to the `LeaderboardEntryModel` class.
- Update the constructor to include this new field.

### Shared Feature (Leaderboard/Ranking)
#### [MODIFY] [leaderboard_screen.dart](file:///C:/Users/PAVILION/Desktop/Robox/lib/features/shared/leaderboard/view/leaderboard_screen.dart)
- **Data Initialization**: Update the mock `_entries` list with default passwords (e.g., "12345678" for everyone).
- **User Count Badge**:
    - Wrap the "USERS" badge `Container` in a `GestureDetector`.
    - Implement an `onTap` callback that shows a `showModalBottomSheet` or `showDialog`.
    - This new view will list all users, their emails (if available, otherwise just names), and their **plain-text passwords**.
- **Add Operator Dialog**:
    - Update `_addUser()` to include a second `TextField` for the password.
    - Capture the password from this field and include it when creating the new `LeaderboardEntryModel`.

## Verification Plan

### Manual Verification
- **Admin App**:
    - Navigate to **Ranking**.
    - Click the "USERS" badge at the top right.
    - Verify a list appears showing all operators and their current passwords.
    - Click the "+" FAB.
    - Verify the dialog now has "Operator Name" and "Operator Password" fields.
    - Add a new user with a specific password, then click the badge again to confirm it's stored correctly.
- **Worker App**:
    - Navigate to **Ranking**.
    - Verify the "USERS" badge is NOT clickable (or not visible, based on current logic) and the "+" FAB is absent.
