# Development Notes

## Current Target Platform
- **Primary Target**: Web build for development and testing
- **Command**: `flutter build web`
- **Note**: Android build has Gradle plugin issues that need to be resolved later

## Recent Fixes Applied

### Calendar Model Fix (Latest)
- **Issue**: Calendar.fromGoogleJson() was failing to parse backend response structure
- **Fix**: Simplified parsing logic to directly map backend fields (id, summary, description, primary, timeZone)
- **Result**: Removed complex debugging/minified object handling that was causing "method not found: 'summary'" errors
- **Files Changed**: lib/models/calendars.dart
- **Commit**: bf6902a

### Google Integration Flow
- **Issue**: Frontend making redundant API calls to /google/calendars/list
- **Fix**: Updated to use unified backend response from first /google call
- **Status**: Flow optimized, backend sends calendars in initial response

### Account Settings Authentication
- **Issue**: Missing authentication tokens in API calls
- **Fix**: Added token: authToken to all CalendarsService methods
- **Status**: Resolved

## Known Issues
- Google auth service tests have web dependency conflicts (js_interop issues)
- Some unused imports and warnings in codebase
- Android build needs Gradle plugin migration

## Architecture Notes
- Backend-first approach recommended for API standardization
- Unified Google integration flow implemented
- Calendar parsing simplified to match backend structure