// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

struct DateTimeType {
    uint8 month;
    uint8 day;
    uint16 year;
    uint8 hour;
    uint8 minute;
    uint8 second;
}

struct DateType {
    uint8 month;
    uint8 day;
    uint16 year;
}

struct TimeType {
    uint8 hour;
    uint8 minute;
    uint8 second;
}

enum DayOfWeek {DONOTUSETHIS, MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY, SATURDAY, SUNDAY}

/**
 * @title Date Library
 * @author Metaxona
 * @custom:version 0.0.1
 * 
 * @dev This is a Solidity library for proccessing Dates in the form of: timestamps, month, 
 * day, year, hours, minutes, seconds, and day of the week to a value you can work with
 * 
 * uses UTC 0 for the input and result
 */
library Date {

    uint16 constant ORIGIN_YEAR = 1970; 

    error InvalidYear();
    error InvalidMonth();
    error InvalidDay();
    error InvalidHours();
    error InvalidMinutes();
    error InvalidSeconds();
    error DayOnThisMonthDoesNotExist();
    error InvalidDayOfTheWeek();

    /**
     * custom:function-name isLeapYear  
     * @param _year a year between ORIGIN_YEAR and 3000
     * @return bool returns if the _year is a leap year
     * 
     * @dev this is a function that checks if a year is a leap year or not   
     */
    function isLeapYear(uint16 _year) internal pure returns(bool) {

        if(_year < ORIGIN_YEAR) revert InvalidYear();

        if ((_year % 4 == 0 && _year % 100 != 0) || (_year % 100 == 0 && _year % 400 == 0)){
            return true;
        }
        else{
            return false;
        }

    }

    /**
     * custom:function-name getNumberOfLeapYearsSinceEpoch  
     * @param _year a year between ORIGIN_YEAR and 3000
     * @return years returns a uint256 value representing the number of leap years 
     * between ORIGIN_YEAR and _year
     * 
     * @dev this is a function that counts the number of leap years that has passed 
     * from ORIGIN_YEAR until the stated year    
     */
    function getNumberOfLeapYearsSinceEpoch(uint16 _year) internal pure returns(uint256){

        if(_year < ORIGIN_YEAR) revert InvalidYear();
        
        uint256 leapYears;

        uint256 upToEnd = ((uint256(_year) / 4) - (uint256(_year) / 100) + (uint256(_year) / 400)) + 1; 

        uint256 upToStart = 477 + 1;
        
        leapYears = (upToEnd - upToStart);

        return leapYears;
    }

    /**
     * custom:function-name getNumberOfNonLeapYearsSinceEpoch  
     * @param _year a year between ORIGIN_YEAR and 3000
     * @return years returns a uint256 value representing the number of non leap years 
     * between ORIGIN_YEAR and _year
     * 
     * @dev this is a function that counts the number of years that are not leap years 
     * that has passed from ORIGIN_YEAR until the stated year    
     */
    function getNumberOfNonLeapYearsSinceEpoch(uint16 _year) internal pure returns(uint256){

        if(_year < ORIGIN_YEAR) revert InvalidYear();
        
        uint256 nonLeapYears;

        nonLeapYears = _year - ORIGIN_YEAR - getNumberOfLeapYearsSinceEpoch(uint16(_year));

        return nonLeapYears;
    }

    /**
     * custom:function-name getNumberOfYearsSinceEpoch  
     * @param _year a year between ORIGIN_YEAR and 3000
     * @return years returns a uint256 value representing the number of years that 
     * has passed from ORIGIN_YEAR until the present
     * 
     * @dev this is a function that counts the number of years that has passed from 
     * ORIGIN_YEAR until the stated year    
     */
    function getNumberOfYearsSinceEpoch(uint16 _year) internal pure returns(uint256){
        if(_year < ORIGIN_YEAR) revert InvalidYear();

        return _year - ORIGIN_YEAR;
    }

    /**
     * custom:function-name getNumberOfDaysSinceEpoch
     * @param _month a number representation of month from 1 - 12
     * @param _day a number representation of day from 1 - 31
     * @param _year a year between ORIGIN_YEAR and 3000
     * @return days returns a uint256 value representing the number of days that has 
     * passed from ORIGIN_YEAR until the set _month, _day, and _year
     * 
     * @dev this is a function that counts the number of days that has passed from 
     * ORIGIN_YEAR until the stated year    
     */
    function getNumberOfDaysSinceEpoch(uint8 _month, uint8 _day, uint16 _year) internal pure returns (uint256){
        if(_month < 1 || _month > 12) revert InvalidMonth();
        if(_day < 1 || _day > 31) revert InvalidDay();
        if(_year < ORIGIN_YEAR) revert InvalidYear();
        
        return ( (getNumberOfLeapYearsSinceEpoch(uint16(_year)) * 366) + (getNumberOfNonLeapYearsSinceEpoch(uint16(_year)) * 365) + getNumberOfDaysPassedInYear(uint8(_month), uint8(_day), uint16(_year)) );
    }

    /**
     * custom:function-name getYear
     * @param blockTimestamp the timestamp retrieved from block.timestamp or any timestamp 
     * @return year returns a uint16 value representing the year from a given timestamp
     * 
     * @dev this is a function that retrieves the year from a given timestamp    
     */
    function getYear(uint256 blockTimestamp) internal pure returns(uint16) {
        uint256 secondsInNonLeapYear = 365 * 1 days;
        uint256 secondsInLeapYear = 366 * 1 days;

        uint256 currentTimestamp = blockTimestamp;

        uint256 yearsSinceORIGIN_YEAR = currentTimestamp / secondsInLeapYear;
        uint256 leapYears = (yearsSinceORIGIN_YEAR + 1) / 4;
        uint256 nonLeapYears = yearsSinceORIGIN_YEAR - leapYears;
        uint256 remainingSeconds = currentTimestamp % secondsInNonLeapYear;

        uint256 currentYear = ORIGIN_YEAR + leapYears + nonLeapYears;

        if(isLeapYear(uint16(currentYear))){
            if (remainingSeconds >= secondsInLeapYear){
                ++currentYear;
            }
        }

        return uint16(currentYear);
    }

    /**
     * custom:function-name getMonth
     * @param blockTimestamp the timestamp retrieved from block.timestamp or any timestamp 
     * @return month returns a uint8 value representing the month from a given timestamp
     * 
     * @dev this is a function that retrieves the month from a given timestamp    
     */
    function getMonth(uint256 blockTimestamp) internal pure returns(uint8){
        uint256 secondsInMonth = 1 days * 30.44;
        uint256 currentTimestamp = blockTimestamp;

        uint256 monthsPassed = (currentTimestamp / secondsInMonth) + 1;

        uint256 currentMonth = monthsPassed % 12;
        
        if(currentMonth == 0){
            currentMonth = 12;
        }

        return uint8(currentMonth);
    }

    /**
     * custom:function-name getDay
     * @param blockTimestamp the timestamp retrieved from block.timestamp or any timestamp 
     * @return day returns a uint8 value representing the day from a given timestamp
     * 
     * @dev this is a function that retrieves the day from a given timestamp    
     */
    function getDay(uint256 blockTimestamp) internal pure returns(uint8){
        uint256 secondsInDay = 1 days;
        uint256 currentTimestamp = blockTimestamp;

        uint256 yearsSinceORIGIN_YEAR = currentTimestamp / (1 days * 366);
        uint256 leapYears = (yearsSinceORIGIN_YEAR + 1) / 4;
        uint256 nonLeapYears = yearsSinceORIGIN_YEAR - leapYears;

        uint256 totalDays = (nonLeapYears * 365) + (leapYears * 366);

        uint256 currentday = (currentTimestamp / secondsInDay) - totalDays;

        uint8 currentMonth = getMonth(blockTimestamp); 
        
        return uint8((currentday - (getNumberOfDaysPassedInYear(blockTimestamp, uint8(currentMonth)))) + 1) ;
    }

    /**
     * custom:function-name getHours
     * @param blockTimestamp the timestamp retrieved from block.timestamp or any timestamp 
     * @return hours returns a uint8 value representing the hours from a given timestamp
     * 
     * @dev this is a function that retrieves the hour from a given timestamp 
     */
    function getHours(uint256 blockTimestamp) internal pure returns(uint8){
        uint256 secondsInHour = 1 hours;

        uint256 hoursPassed = blockTimestamp / secondsInHour;

        return uint8(hoursPassed % 24);
    }

    /**
     * custom:function-name getMinutes
     * @param blockTimestamp the timestamp retrieved from block.timestamp or any timestamp 
     * @return minutes returns a uint8 value representing the minutes from a given timestamp
     * 
     * @dev this is a function that retrieves the minute from a given timestamp
     */
    function getMinutes(uint256 blockTimestamp) internal pure returns(uint8){
        uint256 secondsInMinute = 1 minutes;

        uint256 minutesPassed = blockTimestamp / secondsInMinute;

        return uint8(minutesPassed % 60);
    }

    /**
     * custom:function-name getSeconds
     * @param blockTimestamp the timestamp retrieved from block.timestamp or any timestamp 
     * @return seconds returns a uint8 value representing the seconds from a given timestamp
     * 
     * @dev this is a function that retrieves the second from a given timestamp 
     */
    function getSeconds(uint256 blockTimestamp) internal pure returns(uint8){
        
        return uint8(blockTimestamp % 60);
    }

    /**
     * custom:function-name getDate
     * @param blockTimestamp the timestamp retrieved from block.timestamp or any timestamp 
     * @return month returns a uint8 value representing the month from a given timestamp
     * @return day returns a uint8 value representing the day from a given timestamp
     * @return year returns a uint16 value representing the year from a given timestamp
     * 
     * @dev this is a function that retrieves the month, day, and year from a given timestamp
     */
    function getDate(uint256 blockTimestamp) internal pure returns(uint8 month, uint8 day, uint16 year){
        month = getMonth(blockTimestamp);
        day = getDay(blockTimestamp);
        year = getYear(blockTimestamp);
    }

    /**
     * custom:function-name getTime
     * @param blockTimestamp the timestamp retrieved from block.timestamp or any timestamp 
     * @return hour returns a uint8 value representing the hour from a given timestamp
     * @return minute returns a uint8 value representing the minute from a given timestamp
     * @return second returns a uint16 value representing the second from a given timestamp
     * 
     * @dev this is a function that retrieves the hour, minute, and second from a given timestamp
     */
    function getTime(uint256 blockTimestamp) internal pure returns(uint8 hour, uint8 minute, uint8 second){
        hour = getHours(blockTimestamp);
        minute = getMinutes(blockTimestamp);
        second = getSeconds(blockTimestamp);
    }

    /**
     * custom:function-name getDateFull
     * @param blockTimestamp the timestamp retrieved from block.timestamp or any timestamp 
     * @return month returns a uint8 value representing the month from a given timestamp
     * @return day returns a uint8 value representing the day from a given timestamp
     * @return year returns a uint16 value representing the year from a given timestamp
     * @return hour returns a uint8 value representing the hour from a given timestamp
     * @return minute returns a uint8 value representing the minute from a given timestamp
     * @return second returns a uint8 value representing the second from a given timestamp
     * 
     * @dev this is a function that retrieves the month, day, year, hour, minute, and 
     * second from a given timestamp
     */
    function getDateFull(uint256 blockTimestamp) internal pure returns(uint8 month, uint8 day, uint16 year, uint8 hour, uint8 minute, uint8 second){
        
        month = getMonth(blockTimestamp);
        day = getDay(blockTimestamp);
        year = getYear(blockTimestamp);
        hour = getHours(blockTimestamp);
        minute = getMinutes(blockTimestamp);
        second = getSeconds(blockTimestamp);

    }

    /**
     * custom:function-name getNumberOfDaysInAMonth
     * @param blockTimestamp the timestamp retrieved from block.timestamp or any timestamp 
     * @param _month a number representation of month from 1 - 12
     * @return days returns a uint256 value representing the number of days in a given month
     * 
     * @dev this is a function that retrieves the number of days in a given month and a given 
     * timestamp to check if there will be changes die to a leap year
     */
    function getNumberOfDaysInAMonth(uint256 blockTimestamp, uint8 _month) internal pure returns(uint256){
       
        if(_month < 1 || _month > 12) revert InvalidMonth();

        uint8[12] memory daysInAMonthNonLeapYear = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
        uint8[12] memory daysInAMonthLeapYear = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
        
        uint256 currentYear = getYear(blockTimestamp);
        
        uint8[12] memory daysInAMonth = (isLeapYear(uint16(currentYear))) ? daysInAMonthLeapYear : daysInAMonthNonLeapYear;


        return daysInAMonth[uint256(_month - 1)];
    }

    /**
     * custom:function-name getNumberOfDaysInAMonth
     * @param _month a number representation of month from 1 - 12
     * @param _year a year between ORIGIN_YEAR and 3000
     * @return days returns a uint256 value representing the number of days in a given month 
     * and year
     * 
     * @dev this is a function that retrieves the number of days in a given month and a given 
     * timestamp to check if there will be changes die to a leap year  
     */
    function getNumberOfDaysInAMonth(uint8 _month, uint16 _year) internal pure returns(uint256){

        if(_month < 1 || _month > 12) revert InvalidMonth();
        if(_year < ORIGIN_YEAR) revert InvalidYear();

         uint8[12] memory daysInAMonthNonLeapYear = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
         uint8[12] memory daysInAMonthLeapYear = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
         uint8[12] memory daysInAMonth = (isLeapYear(_year)) ? daysInAMonthLeapYear : daysInAMonthNonLeapYear;

        return daysInAMonth[uint256(_month - 1)];
         
    }

    /**
     * custom:function-name getNumberOfDaysPassedInYear
     * @param blockTimestamp the timestamp retrieved from block.timestamp or any timestamp 
     * @param _month a number representation of month from 1 - 12
     * @return days returns a uint256 value representing the number of days passed since the 
     * start of the year in a given month and a timestamp
     * 
     * @dev this is a function that retrieves the number of days that has passed since the start 
     * of the year from the given timestamp until the given month of the same year
     */
    function getNumberOfDaysPassedInYear(uint256 blockTimestamp, uint8 _month) internal pure returns(uint256){
        if(_month < 1 || _month > 12) revert InvalidMonth();
        
        uint8[12] memory daysInAMonthNonLeapYear = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
        uint8[12] memory daysInAMonthLeapYear = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
        
        uint256 currentYear = getYear(blockTimestamp);
        
        uint8[12] memory daysInAMonth = (isLeapYear(uint16(currentYear))) ? daysInAMonthLeapYear : daysInAMonthNonLeapYear;

        uint256 numberOfDays;
        for(uint256 i = 0; i < uint256(_month - 1) ; i++){
            numberOfDays += daysInAMonth[i];
        }

        return numberOfDays;
    }

    /**
     * custom:function-name getNumberOfDaysPassedInYear
     * @param blockTimestamp the timestamp retrieved from block.timestamp or any timestamp 
     * @param _month a number representation of month from 1 - 12
     * @param _day a number representation of day from 1 - 31
     * @return days returns a uint256 value representing the number of days passed since the start 
     * of the year in a given month, day and a timestamp
     * 
     * @dev this is a function that retrieves the number of days that has passed since the start 
     * of the year from the given timestamp until the given month and day of the same year
     */
    function getNumberOfDaysPassedInYear(uint256 blockTimestamp, uint8 _month, uint8 _day) internal pure returns(uint256){
        if(_month < 1 || _month > 12) revert InvalidMonth();
        if(_day < 1 || _day > 31) revert InvalidDay();

        uint8[12] memory daysInAMonthNonLeapYear = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
        uint8[12] memory daysInAMonthLeapYear = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
        
        uint256 currentYear = getYear(blockTimestamp);
        
        uint8[12] memory daysInAMonth = (isLeapYear(uint16(currentYear))) ? daysInAMonthLeapYear : daysInAMonthNonLeapYear;

        if(_day > daysInAMonth[uint256(_month - 1)]) revert DayOnThisMonthDoesNotExist();

        uint256 numberOfDays;
        for(uint256 i = 0; i < uint256(_month - 1) ; i++){
            numberOfDays += daysInAMonth[i];
        }

        return numberOfDays + _day - 1;
    }

    /**
     * custom:function-name getNumberOfDaysPassedInYear
     * @param _month a number representation of month from 1 - 12
     * @param _day a number representation of day from 1 - 31
     * @param _year a year between ORIGIN_YEAR and 3000
     * @return days returns a uint256 value representing the number of days passed since the start 
     * of the year in a given month, day and year
     * 
     * @dev this is a function that retrieves the number of days that has passed since the start 
     * of the year from the given month, day, and year    
     */
    function getNumberOfDaysPassedInYear(uint8 _month, uint8 _day, uint16 _year) internal pure returns(uint256){
        if(_month < 1 || _month > 12) revert InvalidMonth();
        if(_day < 1 || _day > 31) revert InvalidDay();

        uint8[12] memory daysInAMonthNonLeapYear = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
        uint8[12] memory daysInAMonthLeapYear = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
        
        uint256 currentYear = _year;
        
        uint8[12] memory daysInAMonth = (isLeapYear(uint16(currentYear))) ? daysInAMonthLeapYear : daysInAMonthNonLeapYear;

        if(_day > daysInAMonth[uint256(_month - 1)]) revert DayOnThisMonthDoesNotExist();

        uint256 numberOfDays;
        
        for(uint256 i = 0; i < uint256(_month - 1) ; i++){
            numberOfDays += daysInAMonth[i];
        }

        return numberOfDays + uint256(_day) - 1;
    }

    /**
     * custom:function-name getTimestamp
     * @param _month a number representation of month from 1 - 12
     * @param _day a number representation of day from 1 - 31
     * @param _year a year between ORIGIN_YEAR and 3000
     * @param _hours a number representation of hour from 1 - 23
     * @param _minutes a number representation of minute from 1 - 59
     * @param _seconds a number representation of second from 1 - 59
     * @return timestamp returns a uint256 value representing the timestamp equivalent of a 
     * given month, day, year, hour, minute, and second
     * 
     * @dev this is a function that converts a given month, day, year, hour, minute, and second 
     * into a timestamp
     */    
    function getTimestamp(uint8 _month, uint8 _day, uint16 _year, uint8 _hours, uint8 _minutes, uint8 _seconds) internal pure returns(uint256){
        if(_month < 1 || _month > 12) revert InvalidMonth();
        if(_day < 1 || _day > 31) revert InvalidDay();
        if(_year < ORIGIN_YEAR) revert InvalidYear();
        if(_hours < 0 || _hours > 23 ) revert InvalidHours();
        if(_minutes < 0 || _minutes > 59 ) revert InvalidMinutes();
        if(_seconds < 0 || _seconds > 59 ) revert InvalidSeconds();
        
        uint256 leaps = getNumberOfLeapYearsSinceEpoch(_year);
        uint256 nonleaps = getNumberOfNonLeapYearsSinceEpoch(_year);
        uint256 daysPassed = getNumberOfDaysPassedInYear(_month, _day, _year);

        uint256 timestamp; 
 
        unchecked{
           timestamp = (nonleaps * 365 days) + (leaps * 366 days) + (daysPassed * 1 days) + (uint256(_hours) * 1 hours) + (uint256(_minutes) * 1 minutes) + (uint256(_seconds));
        }
    
        return timestamp;
    }

    /**
     * custom:function-name getTimestamp
     * @param _month a number representation of month from 1 - 12
     * @param _day a number representation of day from 1 - 31
     * @param _year a year between ORIGIN_YEAR and 3000
     * @param _hours a number representation of hour from 1 - 23
     * @param _minutes a number representation of minute from 1 - 59
     * @return timestamp returns a uint256 value representing the timestamp equivalent of a 
     * given month, day, year, hour, and minute
     * 
     * @dev this is a function that converts a given month, day, year, hour, and minute 
     * into a timestamp
     */    
    function getTimestamp(uint8 _month, uint8 _day, uint16 _year, uint8 _hours, uint8 _minutes) internal pure returns(uint256){
        if(_month < 1 || _month > 12) revert InvalidMonth();
        if(_day < 1 || _day > 31) revert InvalidDay();
        if(_year < ORIGIN_YEAR) revert InvalidYear();
        if(_hours < 0 || _hours > 23 ) revert InvalidHours();
        if(_minutes < 0 || _minutes > 59 ) revert InvalidMinutes();
        
        uint256 leaps = getNumberOfLeapYearsSinceEpoch(_year);
        uint256 nonleaps = getNumberOfNonLeapYearsSinceEpoch(_year);
        uint256 daysPassed = getNumberOfDaysPassedInYear(_month, _day, _year);

        uint256 timestamp; 
 
        unchecked{
           timestamp = (nonleaps * 365 days) + (leaps * 366 days) + (daysPassed * 1 days) + (uint256(_hours) * 1 hours) + (uint256(_minutes) * 1 minutes) + (uint256(0));
        }
    
        return timestamp;
    }

    /**
     * custom:function-name getTimestamp
     * @param _month a number representation of month from 1 - 12
     * @param _day a number representation of day from 1 - 31
     * @param _year a year between ORIGIN_YEAR and 3000
     * @param _hours a number representation of hour from 1 - 23
     * @return timestamp returns a uint256 value representing the timestamp equivalent of a 
     * given month, day, year, and hour
     * 
     * @dev this is a function that converts a given month, day, year, and hour 
     * into a timestamp
     */    
    function getTimestamp(uint8 _month, uint8 _day, uint16 _year, uint8 _hours) internal pure returns(uint256){
        if(_month < 1 || _month > 12) revert InvalidMonth();
        if(_day < 1 || _day > 31) revert InvalidDay();
        if(_year < ORIGIN_YEAR) revert InvalidYear();
        if(_hours < 0 || _hours > 23 ) revert InvalidHours();
        
        uint256 leaps = getNumberOfLeapYearsSinceEpoch(_year);
        uint256 nonleaps = getNumberOfNonLeapYearsSinceEpoch(_year);
        uint256 daysPassed = getNumberOfDaysPassedInYear(_month, _day, _year);

        uint256 timestamp; 
 
        unchecked{
           timestamp = (nonleaps * 365 days) + (leaps * 366 days) + (daysPassed * 1 days) + (uint256(_hours) * 1 hours) + (uint256(0) * 1 minutes) + (uint256(0));
        }
    
        return timestamp;
    }

    /**
     * custom:function-name getTimestamp
     * @param _month a number representation of month from 1 - 12
     * @param _day a number representation of day from 1 - 31
     * @param _year a year between ORIGIN_YEAR and 3000
     * @return timestamp returns a uint256 value representing the timestamp equivalent of a 
     * given month, day, and year
     * 
     * @dev this is a function that converts a given month, day, and year
     * into a timestamp
     */    
    function getTimestamp(uint8 _month, uint8 _day, uint16 _year) internal pure returns(uint256){
        if(_month < 1 || _month > 12) revert InvalidMonth();
        if(_day < 1 || _day > 31) revert InvalidDay();
        if(_year < ORIGIN_YEAR) revert InvalidYear();
        
        uint256 leaps = getNumberOfLeapYearsSinceEpoch(_year);
        uint256 nonleaps = getNumberOfNonLeapYearsSinceEpoch(_year);
        uint256 daysPassed = getNumberOfDaysPassedInYear(_month, _day, _year);

        uint256 timestamp; 
 
        unchecked{
           timestamp = (nonleaps * 365 days) + (leaps * 366 days) + (daysPassed * 1 days) + (uint256(0) * 1 hours) + (uint256(0) * 1 minutes) + (uint256(0));
        }
    
        return timestamp;
    }

    /**
     * custom:function-name getDayOfTheWeek
     * @param blockTimestamp the timestamp retrieved from block.timestamp or any timestamp 
     * @return day returns a uint8 value representing the day of the week from 1 - 7 from a 
     * given timestamp
     * @return name returns a string represention of the day of the week from a given timestamp
     * 
     * @dev this is a function that retrieves the day of the week from a given timestamp
     */
    function getDayOfTheWeek(uint256 blockTimestamp) internal pure returns(uint8 day, string memory name){

        (uint8 m, uint8 d, uint16 y )= getDate(blockTimestamp);

        string[7] memory daysOfWeek = ["Saturday", "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday"];
        uint8[7] memory daysOfWeekValue = [6, 7, 1, 2, 3, 4, 5];

        if (m <= 2) {
            m += 12;
        }

        uint256 dayOfWeek;

        unchecked {
            uint256 k = y % 100;
            uint256 j = y / 100;

            dayOfWeek = ( d + ( (13 * (m + 1)) / 5) + k + (k / 4) + ( j / 4 ) - (2 * j) ) % 7;
        }

        day = daysOfWeekValue[dayOfWeek];
        name = daysOfWeek[dayOfWeek];
    }

    /**
     * custom:function-name getDayOfTheWeek
     * @param _month a number representation of month from 1 - 12
     * @param _day a number representation of day from 1 - 31
     * @param _year a year between ORIGIN_YEAR and 3000
     * @return day returns a uint8 value representing the day of the week from 1 - 7 from a given 
     * month, day, and year
     * @return name returns a string represention of the day of the week from a given month, day, 
     * and year
     * 
     * @dev this is a function that retrieves the day of the week from a given month, day, and year
     */
    function getDayOfTheWeek(uint8 _month, uint8 _day, uint16 _year) internal pure returns(uint8 day, string memory name){
        require(_year >= 1753, "Year must be 1753 or later!");

        uint256 m = _month;
        uint256 d = _day;
        uint256 y = _year;

        string[7] memory daysOfWeek = ["Saturday", "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday"];
        uint8[7] memory daysOfWeekValue = [6, 7, 1, 2, 3, 4, 5];

        if (m <= 2) {
            m += 12;
        }

        uint256 dayOfWeek;

        unchecked {
            uint256 k = y % 100;
            uint256 j = y / 100;

            dayOfWeek = ( d + ( (13 * (m + 1)) / 5) + k + (k / 4) + ( j / 4 ) - (2 * j) ) % 7;
        }

        day = daysOfWeekValue[dayOfWeek];
        name = daysOfWeek[dayOfWeek];
    }

    /**
     * custom:function-name isDayOfTheWeek
     * @param blockTimestamp the timestamp retrieved from block.timestamp or any timestamp 
     * @param _dow the day of the week represented by a uint8 value starting from Monday - 1 to 
     * Sunday - 7 
     * @return bool returns if the given timestamp is of the same day of the week as _dow
     * 
     * @dev this is a function that checks if the day of the week of a given timestamp is the 
     * same as the given day of the week
     */
    function isDayOfTheWeek(uint256 blockTimestamp, uint8 _dow) internal pure returns(bool){
        if(_dow > 7 || _dow < 1) revert InvalidDayOfTheWeek();
        
        (uint8 dow, ) = getDayOfTheWeek(blockTimestamp);
        if(dow == _dow) return true;
        return false;
    }

    /**
     * custom:function-name isDayOfTheWeek
     * @param _month a number representation of month from 1 - 12
     * @param _day a number representation of day from 1 - 31
     * @param _year a year between ORIGIN_YEAR and 3000
     * @param _dow the day of the week represented by a uint8 value starting from Monday - 1 to 
     * Sunday - 7 
     * @return bool returns if the given month, day, and year is of the same day of the week as 
     * _dow
     * 
     * @dev this is a function that checks if the day of the week of a given month, day, and year 
     * is the same as the given day of the week   
     */
    function isDayOfTheWeek(uint8 _month, uint8 _day, uint16 _year, uint8 _dow) internal pure returns(bool){
        if(_month < 1 || _month > 12) revert InvalidMonth();
        if(_day < 1 || _day > 31) revert InvalidDay();
        if(_year < ORIGIN_YEAR) revert InvalidYear();
        if(_dow > 7 || _dow < 1) revert InvalidDayOfTheWeek();
        
        (uint8 dow, ) = getDayOfTheWeek(uint8(_month), uint8(_day), uint16(_year));
        if(dow == _dow) return true;
        return false;
    }

    /**
     * custom:function-name getNextDayOfTheWeek
     * @param _dow the day of the week represented by a uint8 value starting from Monday - 1 to 
     * Sunday - 7 
     * @param blockTimestamp the timestamp retrieved from block.timestamp or any timestamp 
     * @return timestamp returns the timestamp for the next occurrence of the day of the week
     * 
     * @dev this is a function that generates a timestamp for the next occurrence of the day of 
     * the week from the given timestamp   
     */
    function getNextDayOfTheWeek(uint8 _dow, uint256 blockTimestamp) internal pure returns(uint256) {
        
        if(_dow > 7 || _dow < 1) revert InvalidDayOfTheWeek();

        (uint8 _month, uint8 _day, uint16 _year, uint8 _hours, uint8 _minutes, uint8 _seconds) = getDateFull(blockTimestamp); 
        (uint8 dow, ) = getDayOfTheWeek(blockTimestamp);

        uint8 addToNextOccurrence;

        if (dow >= _dow) {
            addToNextOccurrence = ( uint8(7) - uint8(dow) ) + uint8(_dow);
        }
        else if (dow < _dow) {
            addToNextOccurrence = uint8(_dow) - uint8(dow);
        }

        uint8 newDay = _day + addToNextOccurrence;

        return getTimestamp(uint8(_month), uint8(newDay), uint16(_year), uint8(_hours), uint8(_minutes), uint8(_seconds));

    }

    /**
     * custom:function-name getNextDayOfTheWeek
     * @param _dow the day of the week represented by a uint8 value starting from Monday - 1 to 
     * Sunday - 7 
     * @param _month a number representation of month from 1 - 12
     * @param _day a number representation of day from 1 - 31
     * @param _year a year between ORIGIN_YEAR and 3000
     * @param _hours a number representation of hour from 1 - 23
     * @param _minutes a number representation of minute from 1 - 59
     * @param _seconds a number representation of second from 1 - 59
     * @return timestamp returns the timestamp for the next occurrence of the day of the week
     * 
     * @dev this is a function that generates a timestamp for the next occurrence of the day of 
     * the week from the given month, day, year, hours, minutes, and seconds  
     */
    function getNextDayOfTheWeek(uint8 _dow, uint8 _month, uint8 _day, uint16 _year, uint8 _hours, uint8 _minutes, uint8 _seconds) internal pure returns(uint256) {
        
        if(_dow > 7 || _dow < 1) revert InvalidDayOfTheWeek();
        if(_month < 1 || _month > 12) revert InvalidMonth();
        if(_day < 1 || _day > 31) revert InvalidDay();
        if(_year < ORIGIN_YEAR) revert InvalidYear();
        if(_hours < 0 || _hours > 23 ) revert InvalidHours();
        if(_minutes < 0 || _minutes > 59 ) revert InvalidMinutes();
        if(_seconds < 0 || _seconds > 59 ) revert InvalidSeconds();

        (uint8 dow, ) = getDayOfTheWeek(_month, _day, _year);

        uint8 addToNextOccurrence;

        if (dow >= _dow) {
            addToNextOccurrence = ( uint8(7) - uint8(dow) ) + uint8(_dow);
        }
        else if (dow < _dow) {
            addToNextOccurrence = uint8(_dow) - uint8(dow);
        }

        uint8 newDay = _day + addToNextOccurrence;

        return getTimestamp(uint8(_month), uint8(newDay), uint16(_year), uint8(_hours), uint8(_minutes), uint8(_seconds));

    }

}