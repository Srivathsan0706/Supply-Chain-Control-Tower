-- ============================================================
-- PAGE 1
-- Executive Dashboard
-- ============================================================

-- KPI 1
-- Total Orders

SELECT
 COUNT(DISTINCT Order_ID) AS Total_Orders
FROM Orders;

-- KPI 2
-- Fill Rate %

SELECT
 ROUND(
 SUM(Delivered_Qty) * 100.0 /
 SUM(Demand_Qty), 2
 ) AS Fill_Rate
FROM Orders;

-- KPI 3
-- Delayed Orders

SELECT
 COUNT(*) AS Delayed_Orders
FROM Orders
WHERE Order_Status = 'DELAYED';

-- KPI 4
-- At Risk SKUs

SELECT
 COUNT(DISTINCT SKU_ID) AS At_Risk_SKUs
FROM Inventory
WHERE Current_Stock < Safety_Stock;

-- KPI 5
-- Total Freight Cost

SELECT
 SUM(Freight_Cost) AS Total_Freight_Cost
FROM Transportation;

-- KPI 6
-- Total Suppliers

SELECT
 COUNT(DISTINCT Supplier_ID) AS Total_Suppliers
FROM Supplier;

-- KPI 7
-- Average Delivery Days

SELECT
 ROUND(AVG(Delivery_Days), 2) AS Avg_Delivery_Days
FROM Transportation;

---------------------------------------------------------

-- Visual 1
-- Order Status Distribution

SELECT
 Order_Status,
 COUNT(DISTINCT Order_ID) AS Orders
FROM Orders
GROUP BY Order_Status;

-- Visual 2
-- Inventory Risk by Warehouse

SELECT
 Warehouse_ID,
 COUNT(DISTINCT SKU_ID) AS At_Risk_SKUs
FROM Inventory
WHERE Current_Stock < Safety_Stock
GROUP BY Warehouse_ID
ORDER BY At_Risk_SKUs DESC;

-- Visual 3
-- Freight Cost by Carrier

SELECT
 Carrier,
 SUM(Freight_Cost) AS Freight_Cost
FROM Transportation
GROUP BY Carrier
ORDER BY Freight_Cost DESC;

-- ============================================================
-- PAGE 2
-- Inventory Dashboard
-- ============================================================

-- KPI 1
-- Total Current Stock

SELECT
 SUM(Current_Stock) AS Total_Current_Stock
FROM Inventory;

-- KPI 2
-- Total Safety Stock

SELECT
 SUM(Safety_Stock) AS Total_Safety_Stock
FROM Inventory;

-- KPI 3
-- Total Inventory Value

SELECT
 SUM(Inventory_Value) AS Total_Inventory_Value
FROM Inventory;

-- KPI 4
-- At Risk SKUs

SELECT
 COUNT(DISTINCT SKU_ID) AS At_Risk_SKUs
FROM Inventory
WHERE Current_Stock < Safety_Stock;

-- KPI 5
-- Healthy SKUs

SELECT
 COUNT(*) AS Healthy_SKUs
FROM Inventory
WHERE Current_Stock >= Safety_Stock;

-- KPI 6
-- Average Lead Time

SELECT
 ROUND(AVG(Lead_Time_Days), 2) AS Avg_Lead_Time
FROM Supplier;

---------------------------------------------------------

-- Visual 1
-- Inventory Status Distribution

SELECT
 CASE
 WHEN Current_Stock < Safety_Stock THEN 'At Risk'
 ELSE 'Healthy'
 END AS Inventory_Status,
 COUNT(*) AS SKU_Count
FROM Inventory
GROUP BY Inventory_Status;

-- Visual 2
-- Stock Availability by Warehouse

SELECT
 Warehouse_ID,
 SUM(Current_Stock) AS Current_Stock,
 SUM(Safety_Stock) AS Safety_Stock
FROM Inventory
GROUP BY Warehouse_ID
ORDER BY Current_Stock DESC;

-- Visual 3
-- Inventory Value by Warehouse

SELECT
 Warehouse_ID,
 SUM(Inventory_Value) AS Inventory_Value
FROM Inventory
GROUP BY Warehouse_ID
ORDER BY Inventory_Value DESC;

-- ============================================================
-- PAGE 3
-- Transportation Dashboard
-- ============================================================

-- KPI 1
-- Total Shipments

SELECT
 COUNT(*) AS Total_Shipments
FROM Transportation;

-- KPI 2
-- Total Freight Cost

SELECT
 SUM(Freight_Cost) AS Total_Freight_Cost
FROM Transportation;

-- KPI 3
-- Average Freight Cost

SELECT
 AVG(Freight_Cost) AS Avg_Freight_Cost
FROM Transportation;

-- KPI 4
-- Average Delivery Days

SELECT
 AVG(Delivery_Days) AS Avg_Delivery_Days
FROM Transportation;

-- KPI 5
-- Total Carriers

SELECT
 COUNT(DISTINCT Carrier) AS Total_Carriers
FROM Transportation;

-- KPI 6
-- Total Routes

SELECT
 COUNT(DISTINCT Origin || ' -> ' || Destination) AS Total_Routes
FROM Transportation;

---------------------------------------------------------

-- Visual 1
-- Freight Spend by Carrier

SELECT
 Carrier,
 SUM(Freight_Cost) AS Total_Freight_Cost
FROM Transportation
GROUP BY Carrier
ORDER BY Total_Freight_Cost DESC;

-- Visual 2
-- Shipment Count by Carrier

SELECT
 Carrier,
 COUNT(*) AS Shipment_Count
FROM Transportation
GROUP BY Carrier
ORDER BY Shipment_Count DESC;

-- Visual 3
-- Carrier Performance by Lane (Matrix)

SELECT
 Origin,
 Carrier,
 ROUND(AVG(Delivery_Days), 2) AS Avg_Delivery_Days
FROM Transportation
GROUP BY Origin, Carrier
ORDER BY Origin, Carrier;

-- ============================================================
-- PAGE 4
-- Supplier Dashboard
-- ============================================================

-- KPI 1
-- Total Suppliers

SELECT
 COUNT(DISTINCT Supplier_ID) AS Total_Suppliers
FROM Supplier;

-- KPI 2
-- Total Demand Qty

SELECT
 SUM(Demand_Qty) AS Total_Demand_Qty
FROM Orders;

-- KPI 3
-- Average OTD %

SELECT
 AVG(OTD_Pct) AS Avg_OTD_Percentage
FROM Supplier;

-- KPI 4
-- Average Lead Time

SELECT
 AVG(Lead_Time_Days) AS Avg_Lead_Time
FROM Supplier;

-- KPI 5
-- Average Defect Rate

SELECT
 AVG(Defect_Rate) AS Avg_Defect_Rate
FROM Supplier;

-- KPI 6
-- High Risk Suppliers

SELECT
 COUNT(DISTINCT Supplier_ID) AS High_Risk_Suppliers
FROM Supplier
WHERE
 OTD_Pct < 75
 OR Lead_Time_Days > 20
 OR Defect_Rate > 5;

---------------------------------------------------------

-- Visual 1
-- Top 10 Suppliers by Customer Demand

SELECT
 s.Supplier_Name,
 SUM(o.Demand_Qty) AS Total_Demand
FROM Orders o
JOIN Supplier_Product_Map sp
 ON o.SKU_ID = sp.SKU_ID
JOIN Supplier s
 ON sp.Supplier_ID = s.Supplier_ID
GROUP BY s.Supplier_Name
ORDER BY Total_Demand DESC
LIMIT 10;

-- Visual 2
-- Top 10 Suppliers by OTD %

SELECT
 Supplier_Name,
 OTD_Pct
FROM Supplier
ORDER BY OTD_Pct DESC
LIMIT 10;

-- Visual 3
-- Supplier Risk Matrix

SELECT
 Supplier_Name,
 Lead_Time_Days,
 Defect_Rate
FROM Supplier;

-- ============================================================
-- PAGE 5
-- Forecast Dashboard
-- ============================================================

-- KPI 1
-- Total Forecast Qty

SELECT
 SUM(Forecast_Qty) AS Total_Forecast_Qty
FROM Forecast;

-- KPI 2
-- Total Actual Demand

SELECT
 SUM(Actual_Demand) AS Total_Actual_Demand
FROM Forecast;

-- KPI 3
-- Forecast Variance

SELECT
 SUM(Forecast_Qty) -
 SUM(Actual_Demand) AS Forecast_Variance
FROM Forecast;

-- KPI 4
-- Forecast Accuracy %

SELECT
 ROUND(
 (
 1 -
 (
 ABS(SUM(Forecast_Qty) - SUM(Actual_Demand))
 * 100.0
 / SUM(Actual_Demand)
 ) / 100
 ) * 100,
 2
 ) AS Forecast_Accuracy_Pct
FROM Forecast;

-- KPI 5
-- Forecast Error %

SELECT
 ABS(
 SUM(Forecast_Qty) - SUM(Actual_Demand)
 )
 / SUM(Actual_Demand)
 AS Forecast_Error
FROM Forecast;

-- KPI 6
-- Total Warehouses

SELECT
 COUNT(DISTINCT Warehouse_ID) AS Total_Warehouses
FROM Inventory;

---------------------------------------------------------

-- Visual 1
-- Forecast vs Actual Demand

SELECT
 Warehouse_ID,
 SUM(Forecast_Qty) AS Forecast_Qty,
 SUM(Actual_Demand) AS Actual_Demand
FROM Forecast
GROUP BY Warehouse_ID
ORDER BY Actual_Demand DESC;

-- Visual 2
-- Forecast Accuracy by Warehouse

SELECT
 Warehouse_ID,
 ROUND(
 CASE
 WHEN (
 1 -
 (
 ABS(SUM(Forecast_Qty) - SUM(Actual_Demand))
 * 1.0
/ SUM(Actual_Demand)
 )
 ) < 0
 THEN 0
 ELSE (
 1 -
 (
 ABS(SUM(Forecast_Qty) - SUM(Actual_Demand))
 * 1.0
/ SUM(Actual_Demand)
 )
 )
 END * 100,
 2
 ) AS Forecast_Accuracy_Pct
FROM Forecast
GROUP BY Warehouse_ID
ORDER BY Forecast_Accuracy_Pct DESC;

-- Visual 3
-- Monthly Forecast Variance

SELECT
 Month,
 SUM(Forecast_Qty) - SUM(Actual_Demand)
 AS Forecast_Variance
FROM Forecast
GROUP BY Month
ORDER BY
 CASE Month
 WHEN 'Jan' THEN 1
 WHEN 'Feb' THEN 2
 WHEN 'Mar' THEN 3
 WHEN 'Apr' THEN 4
 WHEN 'May' THEN 5
 WHEN 'Jun' THEN 6
 END;

-- ============================================================
-- PAGE 6
-- Order Fulfillment Dashboard
-- ============================================================

-- KPI 1
-- Total Orders

SELECT
 COUNT(DISTINCT Order_ID) AS Total_Orders
FROM Orders;

-- KPI 2
-- Total Demand Qty

SELECT
 SUM(Demand_Qty) AS Total_Demand_Qty
FROM Orders;

-- KPI 3
-- Total Delivered

SELECT
 SUM(Delivered_Qty) AS Total_Delivered
FROM Orders;

-- KPI 4
-- Fill Rate %

SELECT
 ROUND(
 SUM(Delivered_Qty) * 100.0 / SUM(Demand_Qty),
 2
 ) AS Fill_Rate_Pct
FROM Orders;

-- KPI 5
-- Delayed Order %

SELECT
 COUNT(CASE WHEN Order_Status = 'DELAYED' THEN 1 END) * 100.0 /
 COUNT(*) AS Delayed_Order_Percentage
FROM Orders;

-- KPI 6
-- Regions Served

SELECT
 COUNT(DISTINCT Customer_Region) AS Regions_Served
FROM Orders;

---------------------------------------------------------

-- Visual 1
-- Regional Demand vs Delivered Quantity

SELECT
 Customer_Region,
 SUM(Demand_Qty) AS Total_Demand,
 SUM(Delivered_Qty) AS Total_Delivered
FROM Orders
GROUP BY Customer_Region
ORDER BY Total_Demand DESC;

-- Visual 2
-- Fill Rate % by Product Category

SELECT
 P.Category,
 ROUND(
 SUM(O.Delivered_Qty) * 100.0 /
 SUM(O.Demand_Qty),
 2
 ) AS Fill_Rate
FROM Orders O
JOIN Product P
 ON O.SKU_ID = P.SKU_ID
GROUP BY P.Category
ORDER BY Fill_Rate DESC;

-- Visual 3
-- Warehouse Fill Rate %

SELECT
 Warehouse_ID,
 ROUND(
 SUM(Delivered_Qty) * 100.0 /
 SUM(Demand_Qty),
 2
 ) AS Fill_Rate_Pct
FROM Orders
GROUP BY Warehouse_ID
ORDER BY Fill_Rate_Pct DESC;

-- Visual 4
-- Lowest Fill Rate Products

SELECT
 P.Product_Name,
 ROUND(
 SUM(O.Delivered_Qty) * 100.0 /
 SUM(O.Demand_Qty),
 2
 ) AS Fill_Rate_Pct
FROM Orders O
JOIN Product P
 ON O.SKU_ID = P.SKU_ID
GROUP BY P.Product_Name
ORDER BY Fill_Rate_Pct ASC
LIMIT 10;

-- ============================================================
-- PAGE 7
-- Warehouse Dashboard
-- ============================================================

-- KPI 1
-- Total Warehouses

SELECT
 COUNT(DISTINCT Warehouse_ID) AS Total_Warehouses
FROM Inventory;

-- KPI 2
-- Total Inventory

SELECT
 SUM(Current_Stock) AS Total_Inventory
FROM Inventory;

-- KPI 3
-- Avg Inventory / Warehouse

SELECT
 SUM(Current_Stock) * 1.0 /
 COUNT(DISTINCT Warehouse_ID) AS Avg_Inventory_Per_Warehouse
FROM Inventory;

-- KPI 4
-- Avg Reorder Point

SELECT
 AVG(Reorder_Point) AS Avg_Reorder_Point
FROM Inventory;

-- KPI 5
-- At Risk SKUs

SELECT
 COUNT(DISTINCT SKU_ID) AS At_Risk_SKUs
FROM Inventory
WHERE Current_Stock < Safety_Stock;

-- KPI 6
-- Total Inventory Value

SELECT
 SUM(Inventory_Value) AS Total_Inventory_Value
FROM Inventory;

---------------------------------------------------------

-- Visual 1
-- Inventory by Warehouse

SELECT
 Warehouse_ID,
 SUM(Current_Stock) AS Total_Inventory
FROM Inventory
GROUP BY Warehouse_ID
ORDER BY Total_Inventory DESC;

-- Visual 2
-- Inventory Health by Warehouse

SELECT
 Warehouse_ID,
 COUNT(DISTINCT CASE
 WHEN Current_Stock < Safety_Stock
 THEN SKU_ID
 END) AS At_Risk_SKUs,
 COUNT(DISTINCT CASE
 WHEN Current_Stock >= Safety_Stock
 THEN SKU_ID
 END) AS Healthy_SKUs
FROM Inventory
GROUP BY Warehouse_ID
ORDER BY Warehouse_ID;

-- Visual 3
-- Inventory Value by Category

SELECT
 P.Category,
 SUM(I.Inventory_Value) AS Inventory_Value
FROM Inventory I
JOIN Product P
 ON I.SKU_ID = P.SKU_ID
GROUP BY P.Category
ORDER BY Inventory_Value DESC;

-- Visual 4
-- Top 10 Inventory Value SKUs

SELECT
 P.Product_Name,
 SUM(I.Inventory_Value) AS Inventory_Value
FROM Inventory I
JOIN Product P
 ON I.SKU_ID = P.SKU_ID
GROUP BY
 P.Product_Name
ORDER BY
 Inventory_Value DESC
LIMIT 10;
