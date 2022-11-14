
-- Cleaning Data in SQL Queries

SELECT * 
FROM PortfolioProject..HouseData

-----------------------------------------------------------------
-- Change Date Format form 'YYYY-MM-DD HH:mm: ss' to 'YYYY-MM-DD'

ALTER TABLE HouseData
ADD Sale_Date DATE;

UPDATE HouseData
SET Sale_Date = CONVERT(DATE, SaleDate)


-----------------------------------------------------------------
-- Fill 'Property Address' field
SELECT *
FROM PortfolioProject..HouseData
WHERE PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..HouseData a
JOIN PortfolioProject..HouseData b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


-----------------------------------------------------------------
-- Creating two new address columns (Seperating address and city from PropertyAddress field)
SELECT PropertyAddress
FROM PortfolioProject..HouseData

ALTER TABLE HouseData
ADD Property_Address VARCHAR(150), 
	Property_CityAddress VARCHAR(150);

UPDATE HouseData
SET Property_Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1),
	Property_CityAddress = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+2, LEN(PropertyAddress))


-----------------------------------------------------------------
-- Creating three new columns by using PARSENAME
SELECT OwnerAddress
FROM PortfolioProject..HouseData
WHERE OwnerAddress IS NOT NULL

ALTER TABLE HouseData
ADD Owner_Address VARCHAR(150), 
	Owner_City VARCHAR(150),
	Owner_State VARCHAR(10);

UPDATE HouseData
SET Owner_Address = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
	Owner_City = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	Owner_State = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

	
-----------------------------------------------------------------
-- Change Y and N to Yes and No in SoldAsVacant field

SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM PortfolioProject..HouseData
GROUP BY SoldAsVacant

UPDATE HouseData
SET SoldAsVacant =
	CASE
		WHEN SoldAsVacant = 'N' THEN 'No'
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		ELSE SoldAsVacant
	END 

	
-----------------------------------------------------------------
-- Remove Duplicates
--CTE
WITH ROW# AS(
SELECT *,
  ROW_NUMBER() OVER(PARTITION BY ParcelID, PropertyAddress,
		SaleDate, SalePrice, LegalReference
	 ORDER BY UniqueID ASC) AS Row_num
FROM PortfolioProject..HouseData
)
--SELECT *
--FROM ROW#
--WHERE Row_num > 1

DELETE
FROM ROW#
WHERE Row_num > 1


-----------------------------------------------------------------
-- Delete Unused Columns
SELECT * 
FROM PortfolioProject..HouseData

ALTER TABLE PortfolioProject..HouseData
DROP COLUMN PropertyAddress, SaleDate, OwnerAddress, TaxDistrict
