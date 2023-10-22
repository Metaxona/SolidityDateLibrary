// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {Date} from "../src/Date.sol";

contract DateTest is Test {

    uint8 month;
    uint8 day;
    uint16 year;
    uint8 hour;
    uint8 minute;
    uint8 second;
    uint8 dayOfTheWeek;
    string dayOfTheWeekName;
    uint256 timestamp;
    
    uint16[250] leapYears = [1972, 1976, 1980, 1984, 1988, 1992, 1996, 2000, 2004, 2008, 2012, 2016, 2020, 2024, 2028, 2032, 2036, 2040, 2044, 2048, 2052, 2056, 2060, 2064, 2068, 2072, 2076, 2080, 2084, 2088, 2092, 2096, 2104, 2108, 2112, 2116, 2120, 2124, 2128, 2132, 2136, 2140, 2144, 2148, 2152, 2156, 2160, 2164, 2168, 2172, 2176, 2180, 2184, 2188, 2192, 2196, 2204, 2208, 2212, 2216, 2220, 2224, 2228, 2232, 2236, 2240, 2244, 2248, 2252, 2256, 2260, 2264, 2268, 2272, 2276, 2280, 2284, 2288, 2292, 2296, 2304, 2308, 2312, 2316, 2320, 2324, 2328, 2332, 2336, 2340, 2344, 2348, 2352, 2356, 2360, 2364, 2368, 2372, 2376, 2380, 2384, 2388, 2392, 2396, 2400, 2404, 2408, 2412, 2416, 2420, 2424, 2428, 2432, 2436, 2440, 2444, 2448, 2452, 2456, 2460, 2464, 2468, 2472, 2476, 2480, 2484, 2488, 2492, 2496, 2504, 2508, 2512, 2516, 2520, 2524, 2528, 2532, 2536, 2540, 2544, 2548, 2552, 2556, 2560, 2564, 2568, 2572, 2576, 2580, 2584, 2588, 2592, 2596, 2604, 2608, 2612, 2616, 2620, 2624, 2628, 2632, 2636, 2640, 2644, 2648, 2652, 2656, 2660, 2664, 2668, 2672, 2676, 2680, 2684, 2688, 2692, 2696, 2704, 2708, 2712, 2716, 2720, 2724, 2728, 2732, 2736, 2740, 2744, 2748, 2752, 2756, 2760, 2764, 2768, 2772, 2776, 2780, 2784, 2788, 2792, 2796, 2800, 2804, 2808, 2812, 2816, 2820, 2824, 2828, 2832, 2836, 2840, 2844, 2848, 2852, 2856, 2860, 2864, 2868, 2872, 2876, 2880, 2884, 2888, 2892, 2896, 2904, 2908, 2912, 2916, 2920, 2924, 2928, 2932, 2936, 2940, 2944, 2948, 2952, 2956, 2960, 2964, 2968, 2972, 2976, 2980, 2984, 2988, 2992, 2996];

    uint16[8] _yearsArray = [1970, 1971, 1972, 2000, 2200, 2500, 2800, 3000];
    uint256[8] _leaps = [0, 0, 1, 8, 56, 129, 202, 250];
    uint256[8] _nyears = [0, 1, 2, 30, 230, 530, 830, 1030];
    uint8[12] monthAsNum = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
    uint8[12] daysInAMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

    function setUp() public {
        changeTimeStamp(1696661648, 10, 7, 2023, 6, 54, 8, 6, "Saturday");
    }

    function changeTimeStamp(uint256 _timestamp, uint8 _month, uint8 _day, uint16 _year, uint8 _hour, uint8 _minute, 
        uint8 _second, uint8 _dayOfTheWeek, string memory _dayOfTheWeekName) internal {
        timestamp = _timestamp;
        vm.warp(timestamp); // Sat Oct 07 2023 06:54:08 GMT+0000
        month = _month;
        day = _day;
        year = _year;
        hour = _hour;
        minute = _minute;
        second = _second;
        dayOfTheWeek = _dayOfTheWeek;
        dayOfTheWeekName = _dayOfTheWeekName;
    }

    function test_getDay() public {
        uint256 blockTimestamp = block.timestamp;
        uint8 currentDay = Date.getDay(blockTimestamp);

        assertEqUint(currentDay, day);
    }

    function test_getMonth() public {
        uint256 blockTimestamp = block.timestamp;
        uint8 currentMonth = Date.getMonth(blockTimestamp);

        assertEqUint(currentMonth, month);
    }

    function test_getYear() public {
        uint256 blockTimestamp = block.timestamp;
        uint16 currentYear = Date.getYear(blockTimestamp);

        assertEqUint(currentYear, year);
    }

    function test_getDate() public {
        uint256 blockTimestamp = block.timestamp;
        (uint8 _month, uint8 _day, uint16 _year) = Date.getDate(blockTimestamp);

        assertEqUint(_month, month);
        assertEqUint(_day, day);
        assertEqUint(_year, year);
    }

    function test_getTime() public {
        uint256 blockTimestamp = block.timestamp;
        (uint8 _hour, uint8 _minute, uint8 _second ) = Date.getTime(blockTimestamp);

        assertEqUint(_hour, hour);
        assertEqUint(_minute, minute);
        assertEqUint(_second, second);
    }

    function test_getDateFull() public {
        uint256 blockTimestamp = block.timestamp;

        (uint8 _month, uint8 _day, uint16 _year, uint8 _hour, uint8 _minute, uint8 _second) = Date.getDateFull(blockTimestamp);

        assertEqUint(_month, month);
        assertEqUint(_day, day);
        assertEqUint(_year, year);
        assertEqUint(_hour, hour);
        assertEqUint(_minute, minute);
        assertEqUint(_second, second);
    }

    function test_isLeapYear(uint16 _year) public {

        vm.assume(_year >= 1970 && _year <= 3000);
        
        uint256 leapYearsLength = leapYears.length;

        bool leap2;
        
        for(uint256 i = 0; i < leapYearsLength; i++){
            if(_year == leapYears[i]){
                leap2 = true;
                break;
            }
            else{
                leap2 = false;
            }
        }

        bool leap = Date.isLeapYear(_year);

        assertEq(leap, leap2);
    }

    function test_getNumberOfLeapYearsSinceEpoch() public {
        uint256 yearsLength = _yearsArray.length;

        for(uint i = 0 ; i < yearsLength ; i++){
            uint256 leaps = Date.getNumberOfLeapYearsSinceEpoch(_yearsArray[i]);
            assertEqUint(leaps, _leaps[i]);
        }
    }

    function test_getNumberOfYearsSinceEpoch() public {
        uint256 yearsLength = _yearsArray.length;

        for(uint i = 0 ; i < yearsLength ; i++){
            uint256 nyears = Date.getNumberOfYearsSinceEpoch(_yearsArray[i]);
            assertEqUint(nyears, _nyears[i]);
        }

    }

    function test_getNumberOfNonLeapYearsSinceEpoch() public {
        uint256 yearsLength = _yearsArray.length;

        for(uint i = 0 ; i < yearsLength ; i++){
            uint256 leaps = Date.getNumberOfLeapYearsSinceEpoch(_yearsArray[i]);
            uint256 _nleaps = _yearsArray[i] - 1970 - leaps;
            uint256 nonleaps = Date.getNumberOfNonLeapYearsSinceEpoch(_yearsArray[i]);
            assertEqUint(nonleaps, _nleaps);
            assertEqUint(Date.getNumberOfYearsSinceEpoch(_yearsArray[i]), (nonleaps + leaps));
        }

    }

    function test_getHours() public {
        uint256 _hour = Date.getHours(block.timestamp);

        assertEqUint(_hour, hour);
    }

    function test_getMinutes() public {
        uint256 _minute = Date.getMinutes(block.timestamp);

        assertEqUint(_minute, minute);
    }

    function test_getSeconds() public {
        uint256 _second = Date.getSeconds(block.timestamp);

        assertEqUint(_second, second);
    }

    function test_getNumberOfDaysInAMonth() public {

        uint256 blockTimestamp = block.timestamp;

        uint256 monthsLength = monthAsNum.length;
        uint256 yearsLength = _yearsArray.length;

        for(uint i = 0 ; i < monthsLength ; i++){
            assertEqUint(Date.getNumberOfDaysInAMonth(blockTimestamp ,monthAsNum[i]), daysInAMonth[i]);
        }

        uint8[13] memory _months = [1, 2, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
        uint8[13] memory _daysInAMonth = [31, 28, 29, 31 ,30, 31, 30, 31, 31, 30, 31, 30, 31];
        uint16[13] memory  _years = [uint16(2023), 2023, 2020, 2023, 2023, 2023, 2023, 2023, 2023, 2023, 2023, 2023, 2023];

        for(uint i = 0 ; i < yearsLength ; i++){
            assertEqUint(Date.getNumberOfDaysInAMonth(_months[i], _years[i]), _daysInAMonth[i]);
        }
    }

    function test_getNumberOfDaysSinceEpoch() public {
        uint256 daysPassed = Date.getNumberOfDaysSinceEpoch(month, day, year);

        assertEqUint(daysPassed, (block.timestamp / 1 days));
    }

    function test_getNumberOfDaysPassedInYear() public {
        uint256 blockTimestamp = block.timestamp;

        uint256 daysInYear = Date.getNumberOfDaysPassedInYear(uint256(blockTimestamp), uint8(month));
        assertEqUint(daysInYear, 273);

        uint256 daysInYear1 = Date.getNumberOfDaysPassedInYear(uint256(blockTimestamp), uint8(month), uint8(day));
        assertEqUint(daysInYear1, 279);

        uint256 daysInYear2 = Date.getNumberOfDaysPassedInYear(uint8(month), uint8(day), uint16(year));
        assertEqUint(daysInYear2, 279);
    }

    function test_getTimestamp() public {
        assertEqUint(Date.getTimestamp(uint8(month), uint8(day), uint16(year), uint8(hour), uint8(minute), uint8(second)), timestamp);
    }

    function test_getDayOfTheWeek() public  {
        // 0 - Saturday 1 - Sunday ... 6 - Friday
        (uint8 dayOfWeek, string memory daysOfWeek) = Date.getDayOfTheWeek(uint8(month), uint8(day), uint16(year));
        assertEqUint(dayOfWeek, dayOfTheWeek);
        assertEq0(abi.encodePacked(daysOfWeek), abi.encodePacked(dayOfTheWeekName));

        (uint8 dayOfWeek1, string memory daysOfWeek1) = Date.getDayOfTheWeek(block.timestamp);
        
        assertEqUint(dayOfWeek1, dayOfTheWeek);
        assertEq0(abi.encodePacked(daysOfWeek1), abi.encodePacked(dayOfTheWeekName));
    }

    function test_isDayOfTheWeek() public {
        
        uint256 blockTimestamp = block.timestamp;
        bool _is = Date.isDayOfTheWeek(blockTimestamp, dayOfTheWeek);

        assertEq(_is, true);

        bool _isToo = Date.isDayOfTheWeek(uint8(month), uint8(day + 1), uint16(year), (dayOfTheWeek + 1));

        assertEq(_isToo, true);

    }

    function test_getNextDayOfTheWeek() public {
        
        uint256 blockTimestamp = block.timestamp;

        uint256 nextTimestamp = Date.getNextDayOfTheWeek(uint8(dayOfTheWeek), blockTimestamp);
        uint256 nextOccurrence = Date.getTimestamp(uint8(month), uint8(day + 7), uint16(year), uint8(hour), uint8(minute), uint8(second));
        
        assertEqUint(nextTimestamp, nextOccurrence);

        uint256 nextTimestamp1 = Date.getNextDayOfTheWeek(uint8(dayOfTheWeek), uint8(month), uint8(day), uint16(year), uint8(hour), uint8(minute), uint8(second));
        uint256 nextOccurrence1 = Date.getTimestamp(uint8(month), uint8(day + 7), uint16(year), uint8(hour), uint8(minute), uint8(second));

        assertEqUint(nextTimestamp1, nextOccurrence1);

    }

}
