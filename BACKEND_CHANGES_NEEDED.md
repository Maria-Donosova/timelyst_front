# Backend Changes Needed for Dynamic Event Fetching

## Overview
The frontend has been updated to support dynamic date range fetching based on calendar views (day/week/month). The backend needs to be optimized to handle these more targeted requests efficiently.

## Current Frontend Implementation

### New EventService API
The frontend now passes optional date ranges to the backend:

```dart
// Day view: fetch only current day
EventService.fetchDayEvents(userId, authToken, 
  startDate: DateTime(2025, 10, 12), 
  endDate: DateTime(2025, 10, 13)
);

// Week view: fetch only current week  
EventService.fetchTimeEvents(userId, authToken,
  startDate: DateTime(2025, 10, 6),  // Monday
  endDate: DateTime(2025, 10, 13)    // Next Monday
);

// Month view: fetch only current month
EventService.fetchDayEvents(userId, authToken,
  startDate: DateTime(2025, 10, 1),   // First of month
  endDate: DateTime(2025, 11, 1)     // First of next month
);
```

### Caching Strategy
- Frontend now caches results for 5 minutes per date range
- Cache keys based on start/end dates: "2025-10-12_2025-10-13"
- Reduces redundant API calls when switching between views

## Required Backend Optimizations

### 1. **Database Query Optimization**

**Current Issue**: Backend likely fetches broad date ranges regardless of request
**Needed**: Optimize queries to use the exact startDate/endDate parameters

```graphql
# Make sure these queries are optimized for narrow date ranges
query DayEvents($startDate: String, $endDate: String) {
  dayEvents(startDate: $startDate, endDate: $endDate) {
    # ... existing fields
  }
}

query TimeEvents($startDate: String, $endDate: String) {
  timeEvents(startDate: $startDate, endDate: $endDate) {
    # ... existing fields  
  }
}
```

**Database Optimizations Needed**:
- Ensure proper indexes on `start` and `end` date fields
- Optimize queries to filter by date range efficiently
- Consider using database-specific date range functions

### 2. **Calendar Integration Efficiency**

**Google Calendar Integration**:
- Use incremental sync tokens when possible
- Cache Google Calendar API responses on backend
- Only sync specific date ranges when requested
- Implement proper rate limiting for Google API calls

**Microsoft/Apple Calendar Integration**:
- Similar incremental sync strategies
- Date-range specific fetching from external APIs
- Backend caching of external calendar data

### 3. **API Response Optimization**

**Current Frontend Expectations**:
```json
{
  "data": {
    "dayEvents": {
      "dayEvents": [
        {
          "id": "...",
          "start": "2025-10-12T00:00:00Z",
          "end": "2025-10-12T23:59:59Z",
          "event_title": "...",
          // ... other fields
        }
      ]
    }
  }
}
```

**Optimizations Needed**:
- Return only events within the requested date range
- Add metadata about the query (e.g., total count, has_more)
- Consider pagination for large date ranges
- Include cache headers for frontend optimization

### 4. **Performance Monitoring**

**Add Logging for**:
- Query execution times by date range size
- External API call frequency and timing
- Cache hit/miss rates
- Most common date range patterns

**Metrics to Track**:
- Average response time by view type (day/week/month)
- Database query performance
- External API rate limit usage
- Cache effectiveness

### 5. **Backward Compatibility**

**Ensure Compatibility**:
- If startDate/endDate not provided, use sensible defaults
- Current defaults: 90 days before to 120 days after current date
- Don't break existing API consumers

```javascript
// Backend pseudocode
function getDateRange(startDate, endDate) {
  const start = startDate || new Date(Date.now() - 90 * 24 * 60 * 60 * 1000);
  const end = endDate || new Date(Date.now() + 120 * 24 * 60 * 60 * 1000);
  return { start, end };
}
```

## Expected Performance Improvements

### Before (Current):
- Day view: Fetches 7 months of data (~210 days)
- Week view: Fetches 7 months of data (~210 days)  
- Month view: Fetches 7 months of data (~210 days)

### After (Optimized):
- Day view: Fetches 1 day of data (99.5% reduction)
- Week view: Fetches 7 days of data (97% reduction)
- Month view: Fetches ~30 days of data (86% reduction)

### Benefits:
- **Faster initial loads**: Especially for day view users
- **Reduced server load**: Fewer database queries and external API calls
- **Better user experience**: Apple Calendar delays should be minimized
- **Reduced API costs**: Less usage of Google/Microsoft calendar APIs
- **Improved caching**: More targeted cache entries

## Implementation Priority

1. **High Priority**: Database query optimization
2. **High Priority**: Date range parameter handling
3. **Medium Priority**: External API optimization
4. **Medium Priority**: Backend caching implementation
5. **Low Priority**: Performance monitoring and metrics

## Testing Recommendations

1. **Load test** with different date range sizes
2. **Verify** that narrow date ranges return correct results
3. **Test** external calendar integration with limited date ranges
4. **Monitor** database performance with new query patterns
5. **Validate** backward compatibility with existing clients

## Critical Issue: Missing Microsoft and Apple Events

### **URGENT: Microsoft/Apple Events Not Appearing**

**Problem**: Only Google events are displaying, Microsoft and Apple events are missing entirely.

**Observed Behavior**:
- Google events appear quickly and correctly
- Microsoft and Apple events don't show up at all
- All events show empty `source: []` and `userCalendars: []` fields

**Root Cause Investigation Needed**:

**1. Event Import Verification**
Check if Microsoft and Apple events are being imported into the database:
```sql
-- Verify events exist in database
SELECT COUNT(*), calendar_source 
FROM events 
WHERE user_id = 'USER_ID' 
GROUP BY calendar_source;

-- Check if events have proper source tagging
SELECT id, event_title, calendar_source, created_at 
FROM events 
WHERE user_id = 'USER_ID' 
AND created_at > NOW() - INTERVAL '7 days'
ORDER BY calendar_source;
```

**2. Calendar Integration Status**
Verify Microsoft and Apple calendar integrations are working:
- Are OAuth tokens valid and not expired?
- Are calendar sync jobs running successfully?
- Are there any errors in calendar import logs?

**3. GraphQL Query Issues**
Check if events are being filtered out in the GraphQL resolvers:
- Verify dayEvents/timeEvents queries return ALL calendar sources
- Check for any source-based filtering that might exclude Microsoft/Apple
- Ensure no authentication issues preventing access to specific calendar types

**Required Investigation Steps**:
1. **Database Check**: Verify Microsoft/Apple events exist in the database
2. **Integration Health**: Check OAuth token status and sync job logs
3. **API Testing**: Test GraphQL queries directly for Microsoft/Apple events
4. **Error Logs**: Review backend logs for calendar import failures

**Priority**: **CRITICAL** - Core calendar functionality broken for non-Google calendars

## Notes

- Frontend is backward compatible - will work with current backend
- Performance improvements will be immediately visible once backend is optimized
- Consider implementing backend caching to complement frontend caching
- Monitor external API rate limits more closely with frequent smaller requests
- **Calendar source tagging must be fixed for Microsoft/Apple events to display**