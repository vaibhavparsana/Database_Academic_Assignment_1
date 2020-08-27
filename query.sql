
--Question: 1) Print the total amount, the average dollar value of service visits 
--          (parts and labour costs) and the number of those visits for 
--          Acura, Mercedes and Jaguar car makes that are sold between 
--          September 2015 and December 2018 inclusive.
SELECT
    saledate
    , carmake
    , COUNT(carserial) AS number_of_visits
    , SUM(partscost) + SUM(laborcost) AS total
    , ( SUM(partscost) + SUM(laborcost) ) / 2.0 AS average
FROM
    (
        SELECT DISTINCT
            servinv.servinvno
            , car.carserial
            , car.carmake
            , saleinv.saledate
            , servinv.partscost
            , servinv.laborcost
        FROM
            si.car
            INNER JOIN si.saleinv ON car.carserial = saleinv.carserial
            INNER JOIN si.servinv ON car.carserial = servinv.carserial
        WHERE
            car.carmake IN (
                'JAGUAR', 'ACURA'
                , 'MERCEDES'
            )
    )
WHERE
    saledate BETWEEN '2015-09-01' AND '2019-12-31'
GROUP BY
    carserial
    , saledate
    , carmake
ORDER BY
    saledate;




--Question: 2) SI schema contains customers that have bought one or more vehicles. 
--          They can be classified using the following criteria:
--              1) Customers that have bought only one car (one-time buyer)
--              2) Customer that have bought two cars (two-time buyer)
--              3) Customers that have bought more than two cars (frequent buyer)
--          Using a SINGLE SELECT statement, display a list of customers with 
--          their names and what type of buyer they are for all those customers 
--          that have bought Mercedes car makes. 

SELECT
    car.custname
    , CASE
        WHEN COUNT(car.custname) < 2
        THEN
            'ONE-TIME BUYER'
        WHEN COUNT(car.custname) < 3
        THEN
            'SECOND-TIME BUYER'
        ELSE
            'FREQUENT BUYER'
    END buyer
FROM
    si.car
WHERE
    car.carmake = 'MERCEDES'
GROUP BY
    car.custname
ORDER BY
    car.custname;


--Question: 3) Using SET operations, display a list of customers that are interested 
--          in a car (prospect table) of the same make and model 
--          which they already own.

SELECT
    car.custname
    , car.carmake
    , car.carmodel
FROM
    si.car
INTERSECT
SELECT
    prospect.custname
    , prospect.carmake
    , prospect.carmodel
FROM
    si.prospect;


--Question: 4) Show a list of total amount of money spend on the labour cost of servicing 
--          Toyota cars. Show the subtotals for each model.

SELECT
    car.carmake
    , car.carmodel
    , SUM(servinv.laborcost) AS subtotal
FROM
    si.car
    INNER JOIN si.servinv ON car.carserial = servinv.carserial
WHERE
    car.carmake = 'TOYOTA'
GROUP BY
    ROLLUP(car.carmake
    , car.carmodel)
ORDER BY
    car.carmodel;






--Question: 5) Write a query using analytic functions that will show the serial number, 
--          the price of each JAGUAR car as well as the cumulative sale price totals.

SELECT
    car.carserial
    , saleinv.carsaleprice
    , SUM(saleinv.carsaleprice) OVER(
        PARTITION BY car.carmake
        ORDER BY
            car.carserial
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_sale_price
FROM
    si.car
    INNER JOIN si.saleinv ON car.carserial = saleinv.carserial
WHERE
    car.carmake = 'JAGUAR';





