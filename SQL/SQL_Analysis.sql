-- ============================================================
-- INVESTIGATION 1
-- Supplier Dependency Analysis
-- ============================================================

SELECT
 s.Supplier_Name,
 SUM(o.Demand_Qty) AS Total_Demand
FROM Orders o
JOIN Supplier_Product_Map spm
 ON o.SKU_ID = spm.SKU_ID
JOIN Supplier s
 ON spm.Supplier_ID = s.Supplier_ID
GROUP BY s.Supplier_Name
ORDER BY Total_Demand DESC
LIMIT 3;

-- ============================================================
-- INVESTIGATION 1A
-- Supplier Performance Risk Analysis
-- ============================================================

SELECT
 s.Supplier_Name,
 SUM(o.Demand_Qty) AS Total_Demand,
 s.OTD_Pct,
 s.Lead_Time_Days,
 s.Defect_Rate
FROM Orders o
JOIN Supplier_Product_Map spm
 ON o.SKU_ID = spm.SKU_ID
JOIN Supplier s
 ON spm.Supplier_ID = s.Supplier_ID
GROUP BY
 s.Supplier_Name,
 s.OTD_Pct,
 s.Lead_Time_Days,
 s.Defect_Rate
ORDER BY Total_Demand DESC
LIMIT 3;

-- ============================================================
-- INVESTIGATION 2
-- Inventory Risk Analysis
-- ============================================================

SELECT
 o.SKU_ID,
 o.Total_Demand,
 i.Total_Current_Stock,
 i.Total_Safety_Stock,
 (i.Total_Current_Stock - i.Total_Safety_Stock) AS Inventory_Gap
FROM
 (
 SELECT
 SKU_ID,
 SUM(Demand_Qty) AS Total_Demand
 FROM Orders
 GROUP BY SKU_ID
 ) o
LEFT JOIN
 (
 SELECT
 SKU_ID,
 SUM(Current_Stock) AS Total_Current_Stock,
 SUM(Safety_Stock) AS Total_Safety_Stock
 FROM Inventory
 GROUP BY SKU_ID
 ) i
ON o.SKU_ID = i.SKU_ID
WHERE i.Total_Current_Stock < i.Total_Safety_Stock
ORDER BY o.Total_Demand DESC;

-- ============================================================
-- INVESTIGATION 3
-- Forecast Accuracy Analysis
-- ============================================================

SELECT
 SKU_ID,
 SUM(Forecast_Qty) AS Total_Forecast,
 SUM(Actual_Demand) AS Total_Actual_Demand,
 SUM(Actual_Demand) - SUM(Forecast_Qty) AS Forecast_Error,
 ABS(SUM(Actual_Demand) - SUM(Forecast_Qty)) AS Absolute_Forecast_Error
FROM Forecast
GROUP BY SKU_ID
ORDER BY Absolute_Forecast_Error DESC
LIMIT 5;

-- ============================================================
-- INVESTIGATION 4
-- Warehouse Inventory Risk Concentration Analysis
-- ============================================================

SELECT
 o.Warehouse_ID,
 o.Total_Demand,
 COALESCE(i.Risk_SKU_Count, 0) AS Risk_SKU_Count
FROM
 (
 SELECT
 Warehouse_ID,
 SUM(Demand_Qty) AS Total_Demand
 FROM Orders
 GROUP BY Warehouse_ID
 ) o
LEFT JOIN
 (
 SELECT
 Warehouse_ID,
 COUNT(SKU_ID) AS Risk_SKU_Count
 FROM Inventory
 WHERE Current_Stock < Safety_Stock
 GROUP BY Warehouse_ID
 ) i
ON o.Warehouse_ID = i.Warehouse_ID
ORDER BY
 o.Total_Demand DESC;

-- ============================================================
-- INVESTIGATION 5
-- Order Fulfillment Performance Analysis
-- ============================================================

SELECT
 COUNT(Order_ID) AS Total_Orders,
 SUM(
 CASE
 WHEN Delivered_Qty >= Demand_Qty THEN 1
 ELSE 0
 END
 ) AS In_Full_Orders,
 ROUND(
 100.0 *
 SUM(
 CASE
 WHEN Delivered_Qty >= Demand_Qty THEN 1
 ELSE 0
 END
 )
 / COUNT(Order_ID),
 2
 ) AS In_Full_Rate_Pct
FROM Orders;

-- ============================================================
-- INVESTIGATION 6
-- Transportation Carrier Performance Analysis
-- ============================================================

-- Analysis 1: Overall Carrier Performance

SELECT
 Carrier,
 COUNT(Shipment_ID) AS Total_Shipments,
 ROUND(AVG(Delivery_Days), 2) AS Avg_Delivery_Days,
 ROUND(AVG(Freight_Cost), 2) AS Avg_Freight_Cost,
 ROUND(SUM(Freight_Cost), 2) AS Total_Freight_Cost
FROM Transportation
GROUP BY Carrier
ORDER BY Avg_Delivery_Days ASC;

-- Analysis 2: Transportation Lane Performance

SELECT
 Origin,
 Destination,
 Carrier,
 COUNT(Shipment_ID) AS Total_Shipments,
 ROUND(AVG(Delivery_Days), 2) AS Avg_Delivery_Days,
 ROUND(AVG(Freight_Cost), 2) AS Avg_Freight_Cost
FROM Transportation
GROUP BY
 Origin,
 Destination,
 Carrier
ORDER BY
 Origin,
 Destination,
 Avg_Delivery_Days ASC;
