---------------------------------------------------------------------------------------------------------------------------
--Database: PortfolioProject
USE PortfolioProject;

---------------------------------------------------------------------------------------------------------------------------
--Main Data Table:
SELECT *
FROM PortfolioProject..Housing

---------------------------------------------------------------------------------------------------------------------------
--Formating SaleDate:
--Here Convert(date,SaleDate) is selected to see what the formating we want for the Date.
SELECT SaleDateFormatted,
	CONVERT(DATE, Saledate)
FROM PortfolioProject..Housing;

--New column for formatted Date Column
ALTER TABLE Housing ADD SaleDateFormatted DATE;

--Adding Values to New Column "SaleDateFormatted":
UPDATE Housing
SET SaleDateFormatted = CONVERT(DATE, SaleDate);

---------------------------------------------------------------------------------------------------------------------------
--Populating the PropertyAddress.
SELECT *
FROM PortfolioProject..Housing
WHERE PropertyAddress IS NULL;

--ISNULL(CHECK FOR NULL, VALUES IF NULL)
SELECT a.ParcelID,
	a.PropertyAddress,
	b.ParcelID,
	b.PropertyAddress,
	ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..Housing a
INNER JOIN PortfolioProject..Housing b
	ON a.ParcelID = b.ParcelID
		AND a.[UniqueID ] <> b.[UniqueID ] --"<>" means not equal to (logical)
WHERE a.PropertyAddress IS NULL;

--Adding values to the null (or empty) places in PropertAddress column.
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..Housing a
INNER JOIN PortfolioProject..Housing b
	ON a.ParcelID = b.ParcelID --ParcelID is same means house is same for delivery 
		AND a.[UniqueID ] <> b.[UniqueID ] --UniqueId different means different users.
WHERE a.PropertyAddress IS NULL;

---------------------------------------------------------------------------------------------------------------------------
--Address Breakdown
SELECT PropertyAddress
FROM PortfolioProject..Housing

--Substring will get the portion we want i.e  from 1st letter till the comma.
--the "-1" in CHARINDEX will get String before the comma (',') {ADDRESS}, the "+1" and LEN() will get everything AFTER the comma.
SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS STATE
FROM PortfolioProject..Housing;

--Creating a new column for 1st line of PropertyAddress.
ALTER TABLE Housing ADD PropertyFirstLine NVARCHAR(255);

--Adding values to AddressFirstLine
UPDATE Housing
SET PropertyFirstLine = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1);

--Creating a new column for the City name from PropertyAddress.
ALTER TABLE Housing ADD PropertyCity NVARCHAR(255);

--Adding values to AddressState
UPDATE Housing
SET PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));

--Owner Address Breakdown using PARSENAME function.
SELECT PARSENAME(replace(OwnerAddress, ',', '.'), 3),
	PARSENAME(replace(OwnerAddress, ',', '.'), 2),
	PARSENAME(replace(OwnerAddress, ',', '.'), 1)
FROM Housing

--Creating a new column for 1st line of OwnerAddress.
ALTER TABLE Housing ADD OwnerAddressFirstLine NVARCHAR(255);

--Adding values to OwnerAddressFirstLine
UPDATE Housing
SET OwnerAddressFirstLine = PARSENAME(replace(OwnerAddress, ',', '.'), 3);

--Creating a new column for City of OwnerAddress.
ALTER TABLE Housing ADD OwnerAddressCity NVARCHAR(255);

--Adding values to OwnerAddressCity
UPDATE Housing
SET OwnerAddressCity = PARSENAME(replace(OwnerAddress, ',', '.'), 2);

--Creating a new column for State of OwnerAddress.
ALTER TABLE Housing ADD OwnerAddressState NVARCHAR(255);

--Adding values to OwnerAddressState
UPDATE Housing
SET OwnerAddressState = PARSENAME(replace(OwnerAddress, ',', '.'), 1);

---------------------------------------------------------------------------------------------------------------------------
--Changing Y, N to Yes, No in SoldAsVacant field
--SELECT DISTINCT (SoldAsVacant),
--	COUNT(SoldAsVacant)
--FROM Housing
--GROUP BY SoldAsVacant
--ORDER BY 2;
--SELECT SoldAsVacant,
--	CASE 
--		WHEN SoldAsVacant = 'N'
--			THEN 'No'
--		WHEN SoldAsVacant = 'Y'
--			THEN 'Yes'
--		ELSE SoldAsVacant
--		END
--FROM Housing
--WHERE SoldAsVacant = 'N'
--	OR SoldAsVacant = 'Y'
--GROUP BY SoldAsVacant
--Changing the formatting of SoldAsVacant using the CASE statement.
UPDATE Housing
SET SoldAsVacant = CASE 
		WHEN SoldAsVacant = 'N'
			THEN 'No'
		WHEN SoldAsVacant = 'Y'
			THEN 'Yes'
		ELSE SoldAsVacant
		END;

---------------------------------------------------------------------------------------------------------------------------
--Removing Duplicate Records. Row_Number(), Partition By, Delete were used for the same.
WITH CTE_RowNumber
AS (
	SELECT *,
		ROW_NUMBER() OVER (
			PARTITION BY ParcelID,
			PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference ORDER BY UniqueID
			) RowNum
	FROM PortfolioProject..Housing
	)
DELETE
FROM CTE_RowNumber
WHERE RowNum > 1

---------------------------------------------------------------------------------------------------------------------------
--Removing unwanted Columns.
SELECT *
FROM PortfolioProject..Housing

ALTER TABLE PortfolioProject..Housing

DROP COLUMN OwnerAddress,
	TaxDistrict,
	PropertyAddress;

ALTER TABLE PortfolioProject..Housing

DROP COLUMN SaleDate

