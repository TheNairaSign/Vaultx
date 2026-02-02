# VaultX Session & Lock/Unlock Logic

## Overview
This document explains how the session management and lock/unlock logic works in VaultX.

## Architecture Components

### 1. SessionManager (`vault_session_manager.dart`)
**Purpose**: Manages the vault session state and master key lifecycle.

**Key Features**:
- Stores the master key in memory when unlocked
- Tracks session state: `locked` or `unlocked`
- Auto-locks after 2 minutes of inactivity
- Refreshes the auto-lock timer on each master key access
- Cleans up sensitive memory when locking

**Key Methods**:
- `unlock(SecretKey masterKey)` - Unlocks the vault and starts auto-lock timer
- `lock()` - Locks the vault and destroys sensitive memory
- `requireMasterKey()` - Safely accesses the master key (throws if locked)

### 2. SessionLifecycleObserver (`session_lifecycle_observer.dart`)
**Purpose**: Monitors app lifecycle and locks the vault when the app goes to background.

**Behavior**:
- Automatically locks when app is paused or detached
- Ensures security when user switches apps or locks device

### 3. Main App (`main.dart`)
**Purpose**: Orchestrates the UI flow based on session state.

**Key State Variables**:
- `_hasUnlockedOnce` - Tracks if user has ever unlocked the vault in this session
- `_isModalShowing` - Prevents multiple unlock modals from appearing

**Flow Logic**:

#### Initial State
```dart
home: !_hasUnlockedOnce && sessionState == VaultSessionState.locked
    ? const UnlockPage() 
    : const VaultFoldersPage()
```
- If user has never unlocked AND vault is locked → Show `UnlockPage`
- Otherwise → Show `VaultFoldersPage`

#### Session State Listener
```dart
ref.listen<VaultSessionState>(
  sessionManagerProvider.select((s) => s.state),
  (previous, next) => _handleSessionStateChange(previous, next),
)
```

**State Change Handler**:
1. **On Unlock**: Sets `_hasUnlockedOnce = true`
2. **On Lock (after being unlocked)**: Shows unlock modal

### 4. UnlockPage (`unlock_page.dart`)
**Purpose**: Full-screen unlock UI shown on first launch or when vault has never been unlocked.

**Features**:
- Beautiful lock icon with glow effects
- "Unlock Vault" button (simulates biometric)
- "Use Master Password" fallback
- BlocListener that responds to unlock success/failure

**Flow**:
1. User enters password
2. Triggers `UnlockVaultRequested` event
3. VaultBloc processes unlock
4. On success: Session state changes to `unlocked`
5. Main.dart detects state change and navigates to VaultFoldersPage

### 5. UnlockModal (`unlock_modal.dart`)
**Purpose**: Modal shown when vault auto-locks during active session.

**Features**:
- Bottom sheet modal (non-dismissible)
- Pulsing biometric animation
- Password fallback option
- BlocListener that auto-closes on successful unlock

**Flow**:
1. Vault locks (timeout or app background)
2. Main.dart shows modal via `showUnlockModal()`
3. User enters password
4. On success: BlocListener closes modal automatically
5. User continues where they left off

## Unlock Flow Diagram

```
App Start
    ↓
[Check Session State]
    ↓
    ├─→ Never Unlocked + Locked → UnlockPage
    └─→ Has Unlocked Before → VaultFoldersPage
                                    ↓
                            [User interacts]
                                    ↓
                            [Auto-lock timer expires]
                            OR [App goes to background]
                                    ↓
                            [Session locks]
                                    ↓
                            [UnlockModal appears]
                                    ↓
                            [User unlocks]
                                    ↓
                            [Modal closes automatically]
                                    ↓
                            [User continues]
```

## Key Implementation Details

### 1. Riverpod Integration
- `sessionManagerProvider` is a `ChangeNotifierProvider`
- Uses `ref.listen()` to react to session state changes
- Avoids using `ref.read()` in `initState()` (moved to `didChangeDependencies()`)

### 2. Modal Management
- Uses `_isModalShowing` flag to prevent duplicate modals
- Modal is non-dismissible (`isDismissible: false`)
- Automatically closes via BlocListener when unlock succeeds

### 3. Navigation Strategy
- Main.dart controls the root page based on session state
- UnlockPage doesn't navigate directly (main.dart handles it)
- UnlockModal closes itself on success

### 4. Error Handling
- UnlockPage shows SnackBar on error
- UnlockModal shows SnackBar on error
- Both allow retry without dismissing

### 5. Memory Safety
- Master key is cleared from memory on lock
- Auto-lock timer is cancelled on lock
- Lifecycle observer ensures lock on app background

## Security Features

1. **Auto-lock**: 2-minute inactivity timeout
2. **Background lock**: Immediate lock when app goes to background
3. **Memory cleanup**: Master key destroyed on lock
4. **Activity refresh**: Timer resets on each vault operation
5. **Non-dismissible modal**: User must unlock to continue

## Testing Scenarios

### Scenario 1: First Launch
1. App starts → UnlockPage shown
2. User enters password
3. Vault unlocks → VaultFoldersPage shown
4. `_hasUnlockedOnce = true`

### Scenario 2: Auto-lock Timeout
1. User is on VaultFoldersPage
2. 2 minutes of inactivity
3. Session locks
4. UnlockModal appears
5. User unlocks → Modal closes
6. User continues on VaultFoldersPage

### Scenario 3: Background Lock
1. User switches to another app
2. SessionLifecycleObserver detects pause
3. Session locks immediately
4. User returns to app
5. UnlockModal appears
6. User unlocks → Modal closes

### Scenario 4: App Restart After Unlock
1. User unlocks vault
2. User closes app
3. User reopens app
4. Session is locked (memory cleared)
5. But `_hasUnlockedOnce = false` (new session)
6. UnlockPage shown (full screen)

## Code Quality Notes

- ✅ Proper Riverpod patterns (no ref.read in initState)
- ✅ Lifecycle observer properly registered/unregistered
- ✅ Modal state managed to prevent duplicates
- ✅ BlocListener handles async unlock completion
- ✅ Error states handled with user feedback
- ✅ Memory safety with proper cleanup
- ✅ Mounted checks before setState
- ✅ PostFrameCallback for modal display
