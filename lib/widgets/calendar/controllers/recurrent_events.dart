//  The function createRRule takes in the frequency, interval, endType, endDate, count, and untilDate as input and returns the RRule string. The RRule string is created based on the user input.
//  The frequency is the frequency of the event, such as daily, weekly, monthly, or yearly. The interval is the interval between the events, such as every 2 days, every 3 weeks, every 4 months, or every 5 years. The endType is the type of end condition for the recurrent events, such as count or date. The endDate is the end date of the recurrent events. The count is the number of occurrences of the recurrent events. The untilDate is the date until which the recurrent events will occur.
//  The function creates the RRule string based on the user input and returns it.
String createRRule(String frequency, String interval, String endType,
    String endDate, String count, String untilDate) {
  String rrule = 'FREQ=$frequency';
  if (interval != null) {
    rrule += ';INTERVAL=$interval';
  }
  if (endType == 'count') {
    rrule += ';COUNT=$count';
  } else if (endType == 'date') {
    rrule += ';UNTIL=$untilDate';
  }
  return rrule;
}

//  Create a function to parse RRule. The next step is to create a function that parses the RRule string and returns the frequency, interval, endType, endDate, count, and untilDate. The function should take the RRule string as input and return the frequency, interval, endType, endDate, count, and untilDate.
//  The function should split the RRule string into its components and extract the frequency, interval, endType, endDate, count, and untilDate.
//  The function should return the frequency, interval, endType, endDate, count, and untilDate as a list of strings.
List<String> parseRRule(String rrule) {
  List<String> rruleList = rrule.split(';');
  String frequency = rruleList[0].split('=')[1];
  String interval = '';
  String endType = '';
  String endDate = '';
  String count = '';
  String untilDate = '';
  for (int i = 1; i < rruleList.length; i++) {
    if (rruleList[i].contains('INTERVAL')) {
      interval = rruleList[i].split('=')[1];
    } else if (rruleList[i].contains('COUNT')) {
      endType = 'count';
      count = rruleList[i].split('=')[1];
    } else if (rruleList[i].contains('UNTIL')) {
      endType = 'date';
      untilDate = rruleList[i].split('=')[1];
    }
  }
  return [frequency, interval, endType, endDate, count, untilDate];
}
