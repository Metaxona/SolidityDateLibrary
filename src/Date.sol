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

    uint256 constant SECONDS_PER_DAY = 24 * 60 * 60;
    uint256 constant SECONDS_PER_HOUR = 60 * 60;
    uint256 constant SECONDS_PER_MINUTE = 60;
    int256 constant OFFSET19700101 = 2440588;

    uint256 constant DOW_MON = 1;
    uint256 constant DOW_TUE = 2;
    uint256 constant DOW_WED = 3;
    uint256 constant DOW_THU = 4;
    uint256 constant DOW_FRI = 5;
    uint256 constant DOW_SAT = 6;
    uint256 constant DOW_SUN = 7;

    /**
    * custom:function-name daysFromDate
    * @dev modified code snippet from RollaProject solidity-datetime
    * for more info go to the link below 
    * https://github.com/RollaProject/solidity-datetime/blob/master/contracts/DateTime.sol
    */
    function daysFromDate(uint8 month, uint8 day, uint16 year) private pure returns (uint256 _days) {
        if(year < ORIGIN_YEAR) revert InvalidYear();
        int256 _year = int256(uint256(year));
        int256 _month = int256(uint256(month));
        int256 _day = int256(uint256(day));

        int256 __days = _day - 32075 + (1461 * (_year + 4800 + (_month - 14) / 12)) / 4
            + (367 * (_month - 2 - ((_month - 14) / 12) * 12)) / 12
            - (3 * ((_year + 4900 + (_month - 14) / 12) / 100)) / 4 - OFFSET19700101;

        _days = uint256(__days);
    }

    /**
    * custom:function-name daysToDate
    * @dev modified code snippet from RollaProject solidity-datetime
    * for more info go to the link below 
    * https://github.com/RollaProject/solidity-datetime/blob/master/contracts/DateTime.sol
    */
    function daysToDate(uint256 _days) private pure returns (uint8 month, uint8 day, uint16 year) {
        unchecked {
            int256 __days = int256(_days);

            int256 L = __days + 68569 + OFFSET19700101;
            int256 N = (4 * L) / 146097;
            L = L - (146097 * N + 3) / 4;
            int256 _year = (4000 * (L + 1)) / 1461001;
            L = L - (1461 * _year) / 4 + 31;
            int256 _month = (80 * L) / 2447;
            int256 _day = L - (2447 * _month) / 80;
            L = _month / 11;
            _month = _month + 2 - 12 * L;
            _year = 100 * (N - 49) + _year + L;

            month = uint8(uint256(_month));
            day = uint8(uint256(_day));
            year = uint16(uint256(_year));
        }
    }

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
     * custom:function-name getYear
     * @param blockTimestamp the timestamp retrieved from block.timestamp or any timestamp 
     * @return year returns a uint16 value representing the year from a given timestamp
     * 
     * @dev this is a function that retrieves the year from a given timestamp    
     */
    function getYear(uint256 blockTimestamp) internal pure returns(uint16) {
        uint256 _days = uint256(blockTimestamp / SECONDS_PER_DAY);

        (,,uint16 year) = daysToDate(_days);

        return year;
    }


    /**
     * custom:function-name getMonth
     * @param blockTimestamp the timestamp retrieved from block.timestamp or any timestamp 
     * @return month returns a uint8 value representing the month from a given timestamp
     * 
     * @dev this is a function that retrieves the month from a given timestamp    
     */
    function getMonth(uint256 blockTimestamp) internal pure returns(uint8){

        uint256 _days = uint256(blockTimestamp / SECONDS_PER_DAY);

        (uint8 month,,) = daysToDate(_days);

        return month;
    }


    /**
     * custom:function-name getDay
     * @param blockTimestamp the timestamp retrieved from block.timestamp or any timestamp 
     * @return day returns a uint8 value representing the day from a given timestamp
     * 
     * @dev this is a function that retrieves the day from a given timestamp    
     */
    function getDay(uint256 blockTimestamp) internal pure returns(uint8){
        uint256 _days = uint256(blockTimestamp / SECONDS_PER_DAY);

        (,uint8 day,) = daysToDate(_days);

        return day;
    }

    /**
     * custom:function-name getHours
     * @param blockTimestamp the timestamp retrieved from block.timestamp or any timestamp 
     * @return hours returns a uint8 value representing the hours from a given timestamp
     * 
     * @dev this is a function that retrieves the hour from a given timestamp 
     */
    function getHours(uint256 blockTimestamp) internal pure returns(uint8){

        uint256 hoursPassed = blockTimestamp / SECONDS_PER_HOUR;

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

        uint256 minutesPassed = blockTimestamp / SECONDS_PER_MINUTE;

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
        
        return uint8(blockTimestamp % SECONDS_PER_MINUTE);
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
        uint256 _days = uint256(blockTimestamp / SECONDS_PER_DAY);

        (month, day, year) = daysToDate(_days);

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
        
        return daysFromDate(_month, _day, _year);
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

        bool isLeap = isLeapYear(_year); 

        if(_month == 2 && isLeap){
            return 29;
        }
        else if(_month == 2 && !isLeap){
            return 28;
        }
        else if(_month == 1 || _month == 3 || _month == 5 || _month == 7 || _month == 8 || _month == 10 ||_month == 12){
            return 31;
        }
        else{
            return 30;
        }
         
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
    function getTimestamp(uint8 _month, uint8 _day, uint16 _year, uint8 _hours, uint8 _minutes, uint8 _seconds) internal pure returns(uint256 timestamp){
        if(_month < 1 || _month > 12) revert InvalidMonth();
        if(_day < 1 || _day > 31) revert InvalidDay();
        if(_year < ORIGIN_YEAR) revert InvalidYear();
        if(_hours < 0 || _hours > 23 ) revert InvalidHours();
        if(_minutes < 0 || _minutes > 59 ) revert InvalidMinutes();
        if(_seconds < 0 || _seconds > 59 ) revert InvalidSeconds();
        
        timestamp = daysFromDate(_month, _day, _year) * SECONDS_PER_DAY + _hours * SECONDS_PER_HOUR + _minutes * SECONDS_PER_MINUTE + _seconds;
    
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