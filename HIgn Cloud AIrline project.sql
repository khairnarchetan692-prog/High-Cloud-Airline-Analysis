use airline;

-- 1.Date Field
SELECT
    STR_TO_DATE(
        CONCAT(Year, '-', LPAD(month, 2, '0'), '-', LPAD(Day, 2, '0')),
        '%Y-%m-%d'
    ) AS Flight_Date
FROM MainData_Final;

-- 2.Year 
select distinct Year as Years
from maindata_final;

-- 3. Month Number
select distinct month as Month_number 
from maindata_final
order by month_number asc;

-- 4. MonthFullName
select 
CASE Month
    WHEN 1  THEN 'January'
    WHEN 2  THEN 'February'
    WHEN 3  THEN 'March'
    WHEN 4  THEN 'April'
    WHEN 5  THEN 'May'
    WHEN 6  THEN 'June'
    WHEN 7  THEN 'July'
    WHEN 8  THEN 'August'
    WHEN 9  THEN 'September'
    WHEN 10 THEN 'October'
    WHEN 11 THEN 'November'
    WHEN 12 THEN 'December'
END AS MonthFullName
from maindata_final;


-- 5. Quarter
select year, month,
      case 
      when month between 1 and 3  then 'Q1'
       when month between 4 and 6  then 'Q2'
        when month between 7 and 9  then 'Q3'
         when month between 10 and 12  then 'Q4'
	   end as Quater 
from maindata_final;

-- 6.year month
select
CONCAT(
    Year, '-',
    CASE Month
        WHEN 1  THEN 'Jan'
        WHEN 2  THEN 'Feb'
        WHEN 3  THEN 'Mar'
        WHEN 4  THEN 'Apr'
        WHEN 5  THEN 'May'
        WHEN 6  THEN 'Jun'
        WHEN 7  THEN 'Jul'
        WHEN 8  THEN 'Aug'
        WHEN 9  THEN 'Sep'
        WHEN 10 THEN 'Oct'
        WHEN 11 THEN 'Nov'
        WHEN 12 THEN 'Dec'
    END) AS YearMonth
from maindata_final;

-- 7and8. WeekdayNO and  weekdayname 
select concat(year,'-',month,'-',day) ,
WEEKDAY(
    STR_TO_DATE(
        CONCAT(Year, '-', LPAD(Month, 2, '0'), '-', LPAD(Day, 2, '0')),
        '%Y-%m-%d'
    )
) + 1 AS Weekday,
DAYNAME(
    STR_TO_DATE(
        CONCAT(Year, '-', LPAD(Month,2,'0'), '-', LPAD(Day,2,'0')),
        '%Y-%m-%d'
    )
) AS WeekdayNAMe
from maindata_final ;

-- 9.financialMonth
select concat(year,'-',month), 
      case when 
      month >=4 then month - 3
      else month +9
      end as financialmonth
from maindata_final;

-- 10. Financial Quater 
select concat(year,'-',month),
      case when month between 4 and 6 then 'FQ1'
      when month between 7 and 9 then 'FQ2'
      when month between 10 and 12 then 'FQ3'
      else 'FQ4'
      end as FInancial_Quater 
from maindata_final;

-- 11. 2. Find the load Factor percentage on a yearly , Quarterly , Monthly basis ( Transported passengers / Available seats)
-- Yearly Load Factor 
select year,
       round( sum(transportedpassengers) * 100 / nullif(sum(availableseats),0),2) as yearly_load_factor_percentage
from maindata_final
group by year
order by year;

-- monthly load factor
select month, 
		round(sum(transportedpassengers)*100 / nullif(sum(availableseats),0),2) as monthly_load_factor_percentage
from maindata_final
group by month
order by month;

-- Quaterly load factor 
select year,
        case when month between 1 and 3 then 'Q1'
        when month between 4 and 6 then 'Q2'
        when month between 7 and 9 then 'Q3'
        when month between 10 and 12 then 'Q4'
        end as Quater,
	round(sum(transportedpassengers)*100/nullif(sum(availableseats),0),2) as Quaterly_load_factor_percentage
from maindata_final
group by year, CASE
        WHEN month BETWEEN 1 AND 3  THEN 'Q1'
        WHEN month BETWEEN 4 AND 6  THEN 'Q2'
        WHEN month BETWEEN 7 AND 9  THEN 'Q3'
        WHEN month BETWEEN 10 AND 12 THEN 'Q4'
    END
order by year, quater;

-- 12 . 3. Find the load Factor percentage on a Carrier Name basis ( Transported passengers / Available seats)
select
    a.Airline as Carrier_Name,

    round(
        sum(f.transportedpassengers) * 100 / NULLIF(SUM(f.availableseats), 0),
        2
    ) AS Load_Factor_Percentage
From maindata_final f
Join Airlines a
    on f.AirlineID = a.Airline_ID
group by a.Airline
order by Load_Factor_Percentage DESC;

-- 13 4. Identify Top 10 Carrier Names based passengers preference 
select a.airline as TOP_TEN_CarrierNames,
      sum(f.transportedpassengers) as Total_passengers
from maindata_final f
join airlines a
on f.AirlineID = a.Airline_ID
group by a.airline
order by Total_Passengers desc
limit 10;

-- 14. 5. Display top Routes ( from-to City) based on Number of Flights 
select
    o.Origin_Market,
    d.Destination_Market,
    count(AirlineID) as Total_Flights
from MainData_Final f
join Origin_Markets o
    on f.OriginAirportMarketID = o.Origin_Airport_MarketID
join Destination_Markets d
    on f.DestinationAirportMarketID = d.Destination_Airport_Market_ID
group BY o.Origin_Market, d.Destination_Market
order by Total_Flights desc ;
-- limit 10;

-- 15.6. Identify the how much load factor is occupied on Weekend vs Weekdays.
select
    case when DAYOFWEEK(STR_TO_DATE(CONCAT(Year, '-', LPAD(Month, 2, '0'), '-', LPAD(Day, 2, '0')),'%Y-%m-%d')) IN (1, 7)
        THEN 'Weekend'
        ELSE 'Weekday'
    END AS Day_Type,
    ROUND(SUM(transportedpassengers) * 100 / NULLIF(SUM(AvailableSeats), 0),2) as Load_Factor_Percentage
FROM Maindata_final
GROUP BY
    CASE WHEN DAYOFWEEK(STR_TO_DATE(CONCAT(Year, '-', LPAD(Month, 2, '0'), '-', LPAD(Day, 2, '0')),'%Y-%m-%d')) IN (1, 7)
        THEN 'Weekend'
        ELSE 'Weekday'
End;

-- 16 7. Identify number of flights based on Distance group
SELECT
    dg.Distance_Interval,
    COUNT(*) AS Total_Flights
FROM MainData_Final f
JOIN Distance_Groups dg
    ON f.DistanceGroupID = dg.Distance_Group_ID
GROUP BY dg.Distance_Interval
ORDER BY Total_Flights DESC;


