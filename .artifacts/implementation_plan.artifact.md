# Implementation Plan - Fix Top Bar Overlap

The `RoboxTopBar` currently overlaps with the system status bar because it doesn't account for device-specific top insets. I will wrap the top bar content in a `SafeArea` to ensure it is rendered below the status bar.

## User Review Required

> [!NOTE]
> I will wrap the `RoboxTopBar` content in a `SafeArea`. This will push the content down on devices with status bars (like iPhones with notches or Android phones with hole-punch cameras).

## Proposed Changes

### Core Widgets
#### [MODIFY] [robox_top_bar.dart](file:///C:/Users/PAVILION/Desktop/Robox/lib/core/widgets/robox_top_bar.dart)
- Wrap the `Container` in a `SafeArea` to respect system insets.
- Adjust `preferredSize` if necessary to ensure the `Scaffold` allocates enough space for both the `SafeArea` and the 56px content height. Actually, a better way is to use `SafeArea(child: Container(...))` but that might not work well with `PreferredSizeWidget` directly if the parent doesn't handle the height increase.
- The standard approach for a custom `AppBar` that respects `SafeArea` is:
    ```dart
    @override
    Size get preferredSize => const Size.fromHeight(kToolbarHeight); // or 56

    @override
    Widget build(BuildContext context) {
      return SafeArea(
        child: Container(
          height: 56,
          // ...
        ),
      );
    }
    ```
    However, if the `Scaffold`'s `appBar` slot is used, it often expects the `PreferredSizeWidget` to provide the *full* height including the top padding if it's not a standard `AppBar`.
    Actually, `Scaffold` wraps the `appBar` in a `MediaQuery.removePadding(removeTop: true)` if it's a `PreferredSizeWidget`? No.

    A more robust way is to just use a `SafeArea` inside the `build` method.

## Verification Plan

### Manual Verification
- Check the app on a device or emulator with a status bar.
- Verify that the "Robox" logo and "Sign out" button are fully visible and not covered by clock/battery icons.
