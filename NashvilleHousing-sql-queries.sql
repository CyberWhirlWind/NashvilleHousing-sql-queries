-- View Original Data
SELECT * 
FROM PortfolioProject.dbo.NashvilleHousing;

--------------------------------------------------------------------------------------------------------------------------
-- 1. Standardize Date Format
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_NAME = 'NashvilleHousing' AND COLUMN_NAME = 'SaleDateConverted')
BEGIN
    ALTER TABLE NashvilleHousing
    ADD SaleDateConverted DATE;
END;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(DATE, SaleDate);

--------------------------------------------------------------------------------------------------------------------------
-- 2. Populate Property Address Data
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
    ON a.ParcelID = b.ParcelID
    AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

--------------------------------------------------------------------------------------------------------------------------
-- 3. Break Out Address into Individual Columns
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_NAME = 'NashvilleHousing' AND COLUMN_NAME = 'PropertySplitAddress')
BEGIN
    ALTER TABLE NashvilleHousing
    ADD PropertySplitAddress NVARCHAR(255),
        PropertySplitCity NVARCHAR(255),
        OwnerSplitAddress NVARCHAR(255),
        OwnerSplitCity NVARCHAR(255),
        OwnerSplitState NVARCHAR(255);
END;

UPDATE NashvilleHousing
SET PropertySplitAddress = 
    CASE 
        WHEN CHARINDEX(',', PropertyAddress) > 0 THEN SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)
        ELSE NULL 
    END;

UPDATE NashvilleHousing
SET PropertySplitCity = 
    CASE 
        WHEN CHARINDEX(',', PropertyAddress) > 0 THEN LTRIM(SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)))
        ELSE NULL 
    END;

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
    OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
    OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

--------------------------------------------------------------------------------------------------------------------------
-- 4. Standardize 'Sold as Vacant' Field
UPDATE NashvilleHousing
SET SoldAsVacant = CASE 
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
END;

--------------------------------------------------------------------------------------------------------------------------
-- 5. Calculate Property Age
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_NAME = 'NashvilleHousing' AND COLUMN_NAME = 'PropertyAge')
BEGIN
    ALTER TABLE NashvilleHousing
    ADD PropertyAge INT;
END;

UPDATE NashvilleHousing
SET PropertyAge = YEAR(GETDATE()) - YearBuilt
WHERE YearBuilt IS NOT NULL;

--------------------------------------------------------------------------------------------------------------------------
-- 6. Add a Flag for Vacant Properties
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_NAME = 'NashvilleHousing' AND COLUMN_NAME = 'IsVacant')
BEGIN
    ALTER TABLE NashvilleHousing
    ADD IsVacant BIT;
END;

UPDATE NashvilleHousing
SET IsVacant = CASE 
    WHEN SoldAsVacant = 'Yes' THEN 1
    ELSE 0
END;

--------------------------------------------------------------------------------------------------------------------------
-- 7. Calculate Total Property Value
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_NAME = 'NashvilleHousing' AND COLUMN_NAME = 'TotalValue')
BEGIN
    ALTER TABLE NashvilleHousing
    ADD TotalValue FLOAT;
END;

UPDATE NashvilleHousing
SET TotalValue = COALESCE(LandValue, 0) + COALESCE(BuildingValue, 0);

--------------------------------------------------------------------------------------------------------------------------
-- 8. Add Price per Acre Column
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_NAME = 'NashvilleHousing' AND COLUMN_NAME = 'PricePerAcre')
BEGIN
    ALTER TABLE NashvilleHousing
    ADD PricePerAcre FLOAT;
END;

UPDATE NashvilleHousing
SET PricePerAcre = CASE 
    WHEN Acreage > 0 THEN SalePrice / Acreage
    ELSE 0
END;

--------------------------------------------------------------------------------------------------------------------------
-- 9. Add a Luxury Property Flag
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_NAME = 'NashvilleHousing' AND COLUMN_NAME = 'IsLuxury')
BEGIN
    ALTER TABLE NashvilleHousing
    ADD IsLuxury BIT;
END;

UPDATE NashvilleHousing
SET IsLuxury = CASE 
    WHEN SalePrice > 1000000 THEN 1
    ELSE 0
END;

--------------------------------------------------------------------------------------------------------------------------
-- 10. Remove Duplicates
WITH RowNumCTE AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
               ORDER BY UniqueID) AS row_num
    FROM PortfolioProject.dbo.NashvilleHousing
)
DELETE FROM PortfolioProject.dbo.NashvilleHousing
WHERE UniqueID IN (
    SELECT UniqueID
    FROM RowNumCTE
    WHERE row_num > 1
);

--------------------------------------------------------------------------------------------------------------------------
-- 11. Delete Unused Columns
IF EXISTS (SELECT 1 
           FROM INFORMATION_SCHEMA.COLUMNS 
           WHERE TABLE_NAME = 'NashvilleHousing' AND COLUMN_NAME IN ('OwnerAddress', 'TaxDistrict', 'PropertyAddress', 'SaleDate'))
BEGIN
    ALTER TABLE PortfolioProject.dbo.NashvilleHousing
    DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;
END;

--------------------------------------------------------------------------------------------------------------------------
-- Final Check of Cleaned Data
SELECT TOP 1000 *
FROM PortfolioProject.dbo.NashvilleHousing;
