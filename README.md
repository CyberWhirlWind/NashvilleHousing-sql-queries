# Nashville Housing Data Cleaning Project

## Overview
This project provides a set of **SQL queries** for cleaning and transforming the **Nashville Housing** dataset. The queries address common data quality issues such as standardizing formats, handling missing values, creating new calculated fields, and removing duplicates. The end result is a clean and structured dataset ready for analysis.


## Steps Performed

### 1. **Standardize Date Format**
- Created a new column `SaleDateConverted` to store the `SaleDate` in a consistent `YYYY-MM-DD` format.

### 2. **Populate Missing Property Addresses**
- Populated missing `PropertyAddress` values by referencing records with the same `ParcelID` using a self-join.

### 3. **Break Out Address into Individual Columns**
- Split `PropertyAddress` into:
  - `PropertySplitAddress` - Street Address
  - `PropertySplitCity` - City  
- Split `OwnerAddress` into:
  - `OwnerSplitAddress` - Street Address
  - `OwnerSplitCity` - City
  - `OwnerSplitState` - State  

### 4. **Standardize 'Sold as Vacant' Field**
- Updated `SoldAsVacant` column values:
  - `Y` → `Yes`
  - `N` → `No`.

### 5. **Calculate Property Age**
- Added a `PropertyAge` column to calculate the age of the property based on the `YearBuilt` column.

### 6. **Add a Flag for Vacant Properties**
- Created a binary flag `IsVacant`:
  - `1` for properties marked as `SoldAsVacant = Yes`.
  - `0` otherwise.

### 7. **Calculate Total Property Value**
- Created a `TotalValue` column as the sum of `LandValue` and `BuildingValue`.

### 8. **Add Price per Acre Column**
- Created a `PricePerAcre` column by dividing `SalePrice` by `Acreage`.

### 9. **Add a Luxury Property Flag**
- Added a flag `IsLuxury` to identify properties where `SalePrice > 1,000,000`.

### 10. **Remove Duplicates**
- Removed duplicate rows using `ROW_NUMBER()` and a CTE, based on key columns like `ParcelID`, `PropertyAddress`, `SalePrice`, `SaleDate`, and `LegalReference`.

### 11. **Delete Unused Columns**
- Dropped unnecessary columns:
  - `OwnerAddress`, `TaxDistrict`, `PropertyAddress`, and `SaleDate`.


## Final Output
The cleaned dataset includes:
- Standardized date formats.
- Populated missing addresses.
- Split address columns.
- Calculated fields such as `PropertyAge`, `TotalValue`, and `PricePerAcre`.
- Flags for vacant and luxury properties.
- Removal of duplicate rows and unused columns.



## How to Use
1. Import the Nashville Housing dataset into your SQL Server database.
2. Run the provided SQL script sequentially or as a single script.
3. Verify the cleaned dataset with the final query:
   ```sql
   SELECT TOP 1000 * 
   FROM PortfolioProject.dbo.NashvilleHousing;


## Prerequisites
- **SQL Server Management Studio (SSMS)** or any SQL-compatible environment.
- The Nashville Housing dataset loaded into a table named `NashvilleHousing`.


## Author
**CyberWhirlWind**  
For questions or suggestions, feel free to reach out or contribute!

---

## License
This project is licensed under the **MIT License**.

