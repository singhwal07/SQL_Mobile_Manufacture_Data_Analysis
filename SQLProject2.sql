/*************************************************************************************
Project Questions
**************************************************************************************/

/*Q1 List all the states in which we have customers 
     who have bought cellphones from 2005 till today.*/

Select Distinct(DL.[State]) as List_Of_State from DIM_Location as DL inner join FACT_TRANSACTIONS as FT
on DL.IDLocation = FT.IDLocation
Where FT.[Date] > '1/1/2005'

/*Q2 What state in the US is buying the most ‘Samsung’ cell phones?*/

Select Top 1 DL.[State], DMF.Manufacturer_Name ,
sum(FT.Quantity) as TotalQty
from DIM_Location as DL inner join
FACT_TRANSACTIONS as FT 
on DL.IDLocation = FT.IDLocation
Inner join DIM_MODEL as DM
on FT.IDModel = DM.IDModel
Inner Join DIM_MANUFACTURER as DMF
on DM.IDManufacturer = DMF.IDManufacturer
Where DL.Country = 'US' and DMF.Manufacturer_Name = 'Samsung'
Group by DL.[State], DMF.Manufacturer_Name

/*Q3. Show the number of transactions for each model per zip code per state.*/

Select DIM_MODEL.Model_Name,DIM_LOCATION.ZipCode,DIM_Location.[State], count(FACT_TRANSACTIONS.IDCustomer) as TotalTransactions
from DIM_LOCATION inner join FACT_TRANSACTIONS
on DIM_LOCATION.IDLocation = FACT_TRANSACTIONS.IDLocation
inner join DIM_MODEL 
on FACT_TRANSACTIONS.IDModel = DIM_MODEL.IDModel
Group by  DIM_MODEL.Model_Name, DIM_LOCATION.ZipCode,DIM_Location.[State]
order by DIM_Location.[State]

/*Q4. Show the cheapest cellphone (Output should contains the price also).*/

Select Top 1 MNF.Manufacturer_Name, MD.Model_Name , MD.Unit_Price from DIM_MANUFACTURER as MNF 
inner join DIM_MODEL as MD
on MNF.IDManufacturer = MD.IDManufacturer
Order By Unit_Price


/*Q5. Find out the average price of each model in the top 5 manufacturers in the terms of 
sales quantity and order by average price.*/

Select DIM_MANUFACTURER.Manufacturer_Name,DIM_MODEL.Model_Name, Avg(DIM_MODEL.Unit_Price) as AvgPrice 
from DIM_MANUFACTURER inner join DIM_MODEL
on DIM_MANUFACTURER.IDManufacturer = DIM_MODEL.IDManufacturer
where DIM_MANUFACTURER.IDManufacturer in (
Select Top 5 DIM_MANUFACTURER.IDManufacturer 
from FACT_TRANSACTIONS Inner join DIM_MODEL
on FACT_TRANSACTIONS.IDModel = DIM_MODEL.IDModel
inner join DIM_MANUFACTURER
on DIM_MODEL.IDManufacturer = DIM_MANUFACTURER.IDManufacturer
group by DIM_MANUFACTURER.IDManufacturer
order by sum(FACT_TRANSACTIONS.Quantity) Desc)
group by DIM_MANUFACTURER.Manufacturer_Name,DIM_MODEL.Model_Name
order by Avg(DIM_MODEL.Unit_Price) Desc

/*Q6 List the names of the customers and the average amount
spent in 2009, where the average is higher than 500.*/

Select  DIM_CUSTOMER.Customer_Name,
avg(FACT_TRANSACTIONS.TotalPrice * FACT_TRANSACTIONS.Quantity) as TotalSales_Avg
from DIM_CUSTOMER inner join FACT_TRANSACTIONS
on DIM_CUSTOMER.IDCustomer = FACT_TRANSACTIONS.IDCustomer
where Year(FACT_TRANSACTIONS.[Date]) = '2009'
group by  DIM_CUSTOMER.Customer_Name
having avg(FACT_TRANSACTIONS.TotalPrice * FACT_TRANSACTIONS.Quantity) > 500

/*7.	List if there is any model that was in the
top 5 in term of quantity, simultaneously in 2008,2009 and 2010.*/

Select * from (Select Top 5 DIM_MODEL.Model_Name from
DIM_MODEL inner join FACT_TRANSACTIONS
on DIM_MODEL.IDModel = FACT_TRANSACTIONS.IDModel
Where Year(FACT_TRANSACTIONS.[Date]) = '2008'
Group by DIM_MODEL.Model_Name
Order by Sum(FACT_TRANSACTIONS.Quantity) Desc
)as tbl_2008
INTERSECT
Select *  from (Select Top 5 DIM_MODEL.Model_Name from
DIM_MODEL inner join FACT_TRANSACTIONS
on DIM_MODEL.IDModel = FACT_TRANSACTIONS.IDModel
Where Year(FACT_TRANSACTIONS.[Date]) = '2009'
Group by DIM_MODEL.Model_Name
Order by Sum(FACT_TRANSACTIONS.Quantity) Desc
)as tbl_2009
Intersect
Select * from (Select Top 5 DIM_MODEL.Model_Name from
DIM_MODEL inner join FACT_TRANSACTIONS
on DIM_MODEL.IDModel = FACT_TRANSACTIONS.IDModel
Where Year(FACT_TRANSACTIONS.[Date]) = '2010'
Group by DIM_MODEL.Model_Name
Order by Sum(FACT_TRANSACTIONS.Quantity) Desc
)as tbl_2010

/*Q8. Show the manufacturer with the 2nd top sales
in the year of 2009 and the manufacturer with the
2nd top sales in the year of 2010.*/

Select * from (Select DIM_MANUFACTURER.Manufacturer_Name,Year(FACT_TRANSACTIONS.[Date]) as Sales_Year ,
sum(FACT_TRANSACTIONS.TotalPrice * FACT_TRANSACTIONS.Quantity) as TotalSales ,
Row_Number() Over (Order by sum(FACT_TRANSACTIONS.TotalPrice * FACT_TRANSACTIONS.Quantity) desc) as TopN
from DIM_MANUFACTURER inner join DIM_MODEL
on DIM_MANUFACTURER.IDManufacturer = DIM_MODEL.IDManufacturer
Inner join FACT_TRANSACTIONS
On DIM_MODEL.IDModel = FACT_TRANSACTIONS.IDModel
Where Year(FACT_TRANSACTIONS.[Date]) = '2009' 
Group by DIM_MANUFACTURER.Manufacturer_Name,Year(FACT_TRANSACTIONS.[Date])) as TBL
Where TopN = 2
Union All
Select * from (Select DIM_MANUFACTURER.Manufacturer_Name,YEAR(FACT_TRANSACTIONS.[Date]) as Sales_Year,
sum(FACT_TRANSACTIONS.TotalPrice * FACT_TRANSACTIONS.Quantity) as TotalSales ,
Row_Number() Over (Order by sum(FACT_TRANSACTIONS.TotalPrice * FACT_TRANSACTIONS.Quantity) desc) as TopN
from DIM_MANUFACTURER inner join DIM_MODEL
on DIM_MANUFACTURER.IDManufacturer = DIM_MODEL.IDManufacturer
Inner join FACT_TRANSACTIONS
On DIM_MODEL.IDModel = FACT_TRANSACTIONS.IDModel
Where Year(FACT_TRANSACTIONS.[Date]) = '2010' 
Group by DIM_MANUFACTURER.Manufacturer_Name,YEAR(FACT_TRANSACTIONS.[Date]))
as Tbl2
Where TopN = 2

/*Q9. Show the manufacturer that sold cellphones in 2010 but did not in 2009.*/


Select DIM_MANUFACTURER.Manufacturer_Name
from DIM_MANUFACTURER inner join DIM_MODEL
on DIM_MANUFACTURER.IDManufacturer  = DIM_MODEL.IDManufacturer
inner join FACT_TRANSACTIONS
on DIM_MODEL.IDModel = FACT_TRANSACTIONS.IDModel
Where Year(Fact_Transactions.[Date]) = '2010'
Group by DIM_MANUFACTURER.Manufacturer_Name, Year(Fact_Transactions.[Date])
Except
Select DIM_MANUFACTURER.Manufacturer_Name
from DIM_MANUFACTURER inner join DIM_MODEL
on DIM_MANUFACTURER.IDManufacturer  = DIM_MODEL.IDManufacturer
inner join FACT_TRANSACTIONS
on DIM_MODEL.IDModel = FACT_TRANSACTIONS.IDModel
Where Year(Fact_Transactions.[Date]) = '2009'
Group by DIM_MANUFACTURER.Manufacturer_Name,Year(Fact_Transactions.[Date])

/* Q10. Find top 100 Customers and their average spend, average quantity 
by each year. Also the percentage of change in their spend.*/


Select Customer_Name, SalesYear, AvgSales,TotalSales,
convert(int,100 * (sum(TotalSales) - Lag(sum(TotalSales)) over (Partition by Customer_Name order by SalesYear)) /
Lag(sum(TotalSales)) over (Partition by Customer_Name order by SalesYear)) as Sales_Difference 
from (
Select DIM_CUSTOMER.Customer_Name,Year(FACT_TRANSACTIONS.[Date]) as SalesYear,
sum(FACT_TRANSACTIONS.Quantity * FACT_TRANSACTIONS.TotalPrice) as TotalSales,
avg(FACT_TRANSACTIONS.Quantity * FACT_TRANSACTIONS.TotalPrice) as AvgSales
from DIM_CUSTOMER inner join FACT_TRANSACTIONS
on DIM_CUSTOMER.IDCustomer = FACT_TRANSACTIONS.IDCustomer
Group by DIM_CUSTOMER.Customer_Name,Year(FACT_TRANSACTIONS.[Date])) as tbl
Group by Customer_Name, SalesYear, AvgSales,TotalSales
order by Customer_Name,SalesYear
