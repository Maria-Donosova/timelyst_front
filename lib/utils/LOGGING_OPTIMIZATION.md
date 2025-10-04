# Logging Optimization Guide

## Problem
The app was experiencing performance issues due to excessive console logging, particularly in:
- Calendar widget (`calendar.dart`) - logged on every build (causing 65ms+ frame times)
- Event data source creation - logged on every data refresh
- RRULE processing - logged for every recurring event
- EventProvider operations - 51+ print statements

## Solution
Implemented centralized logging control via `AppLogger` class with performance optimization flags.

## How to Control Logging

### Performance Optimization Flags
In `lib/utils/logger.dart`:

```dart
// Performance optimization flags
static const bool enableDebugLogs = false; // Set to false to disable debug logs
static const bool enableVerboseLogs = false; // Set to false to disable verbose logs  
static const bool enablePerformanceLogs = false; // Set to false to disable performance logs
```

### Log Levels Implemented

1. **Performance Logs** (`AppLogger.performance`) - **DISABLED by default**
   - Most performance-critical logs (widget builds, data source creation)
   - These were causing the most UI blocking

2. **Debug Logs** (`AppLogger.debug`) - **DISABLED by default**
   - General debugging information
   - Drag-and-drop operations, RRULE processing

3. **Verbose Logs** (`AppLogger.verbose`) - **DISABLED by default**
   - Most detailed/chatty logs
   - Individual event details, exception dates

4. **Info/Warning/Error Logs** - **ALWAYS ENABLED**
   - Critical information that should always be shown
   - Use `AppLogger.i()`, `AppLogger.w()`, `AppLogger.e()`

## Files Updated

### Calendar Performance Critical
- `lib/widgets/calendar/controllers/calendar.dart`
  - Replaced `print('Building calendar with ${appointments.length} events')` with `AppLogger.performance()`
  - Converted all EventDataSource logging to conditional debug/verbose levels
  - Fixed RRULE processing logs that ran for every recurring event

### Logger Enhancement  
- `lib/utils/logger.dart`
  - Added performance optimization flags
  - Added conditional logging methods

## Performance Impact

**Before**: 
- Calendar widget logged on every build (every frame)
- EventDataSource logged on every data refresh
- 65ms+ frame times reported

**After**:
- All performance-critical logs disabled by default
- Only essential info/warning/error logs remain active
- Significant reduction in console output and improved frame times

## How to Re-enable Logging for Debugging

1. **For specific debugging sessions**, temporarily set flags to `true`:
   ```dart
   static const bool enableDebugLogs = true; // Enable for debugging
   ```

2. **For production**, keep all flags as `false`

3. **For development with selective logging**:
   - Enable only `enableDebugLogs = true` for general debugging
   - Enable `enableVerboseLogs = true` for detailed tracing
   - Keep `enablePerformanceLogs = false` unless investigating performance issues

## Next Steps

Consider applying the same pattern to:
- `lib/providers/eventProvider.dart` (51+ print statements)
- Other service files with extensive logging
- Any widgets that log on build/render cycles

## Migration Guide

To convert existing `print()` statements:

```dart
// Old
print('🔍 [Tag] Debug message');

// New  
AppLogger.debug('Debug message', 'Tag');

// For performance-critical code
AppLogger.performance('Build info', 'Widget');

// For detailed tracing
AppLogger.verbose('Detailed info', 'Component');
```