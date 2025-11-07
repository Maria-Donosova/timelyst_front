# Backend TODO for Calendar Selection Feature

## Overview
The frontend now has a Save button in the calendar selection widget that allows users to persist their calendar selections to the database. Currently, it updates calendars one by one, which can be inefficient when multiple calendars need to be updated.

## Current Implementation
- Frontend calls `setCalendarSelection` for each calendar that changed
- Each call updates a single calendar's `isSelected` field
- Uses the existing `updateCalendar` mutation

## Recommended Backend Enhancement

### Create Batch Update Mutation

**Purpose**: Allow updating multiple calendar selections in a single API call for better performance and atomicity.

**Suggested GraphQL Mutation**:

```graphql
mutation BatchUpdateCalendarSelections($selections: [CalendarSelectionInput!]!) {
  updateCalendarSelections(selections: $selections) {
    success
    updatedCount
    failedCount
    errors {
      calendarId
      message
    }
  }
}

input CalendarSelectionInput {
  calendarId: ID!
  isSelected: Boolean!
}
```

**Expected Response**:
```json
{
  "data": {
    "updateCalendarSelections": {
      "success": true,
      "updatedCount": 5,
      "failedCount": 0,
      "errors": []
    }
  }
}
```

### Benefits of Batch Update

1. **Performance**: Single network request instead of multiple sequential calls
2. **Atomicity**: All updates succeed or fail together (optional transaction support)
3. **Reduced Load**: Less overhead on both frontend and backend
4. **Better UX**: Faster response time for users

### Implementation Notes

1. **Authorization**: Ensure user owns all calendars being updated
2. **Validation**: Verify all calendar IDs exist and belong to the user
3. **Error Handling**: Return partial success information if some updates fail
4. **Transaction Support**: Consider wrapping updates in a database transaction
5. **Rate Limiting**: Apply appropriate rate limits to prevent abuse

### Alternative Approach (If Batch Update Not Feasible)

If implementing a batch update endpoint is not feasible, consider:

1. **Optimize Current Endpoint**: Ensure the existing `updateCalendar` mutation is optimized
2. **Parallel Processing**: Backend could process multiple individual requests in parallel
3. **Caching**: Implement caching to reduce database load

## Current Frontend Workaround

The frontend currently:
- Iterates through calendars with changed selection states
- Calls `setCalendarSelection` for each calendar
- Shows aggregate success/failure counts to the user
- Provides detailed error feedback if some updates fail

## Priority

**Medium Priority** - The current implementation works but could be more efficient. This enhancement would improve:
- User experience (faster saves)
- Server performance (fewer requests)
- Code maintainability (simpler frontend logic)

## Related Files

- Frontend: `lib/widgets/shared/calendarSelection.dart`
- Provider: `lib/providers/calendarProvider.dart`
- Service: `lib/services/calendarsService.dart`
- Model: `lib/models/calendars.dart`
