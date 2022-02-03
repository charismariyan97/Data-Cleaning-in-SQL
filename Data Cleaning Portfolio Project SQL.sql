/*

Cleaning Data Using SQL Queries

*/



--Checking through the dataset

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

----------------------------------------------------------------------------------------------

-- STANDARDIZE DATE FORMAT

SELECT SaleDate
FROM PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing


------------------------------------------------------------------------------------------------------

-- POPULATE PROPERTY ADDRESS DATA

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null  --(to check if there is null values in the dataset)
order by ParcelID --(parcelID = propertyAddress, check duplicates in the dataset)

select a.ParcelID, a.PropertyAddress, a.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

UPDATE a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress) --replacing null values with PropertyAddress
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


-- Breaking out Address into Individual Columns (Address, City, State)

--Checking/Showing Property address column:
select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing 

--Separating PropertyAddress into 2 columns
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as Address
From PortfolioProject.dbo.NashvilleHousing

--Adding new column/table
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

--Updating the new splitted data
UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

--Adding new column/table
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add PropertySplitCity Nvarchar(255);

--Updating the new splitted data
UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))

-- Showing the new dataset
Select *
from PortfolioProject.dbo.NashvilleHousing


--------------------------------------------------------------------------------------------------------------------

-- POPULATE OWNER ADDRESS DATA

SELECT OwnerAddress
from PortfolioProject.dbo.NashvilleHousing

--Separating OwnerAddress into 3 columns
SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
from PortfolioProject.dbo.NashvilleHousing


--Adding new column/table
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

--Updating the new splitted data
UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


--Adding new column/table
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

--Updating the new splitted data
UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


--Adding new column/table
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255);

--Updating the new splitted data
UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


-- Showing the new dataset
SELECT *
from PortfolioProject.dbo.NashvilleHousing


-----------------------------------------------------------------------------------------------------

-- CHANGE Y AND N TO YES AND NO IN "Sold As Vacant" FIELD

--Checking unique characters in SoldAsVacant Column:
Select DISTINCT(SoldAsVacant), Count(SoldAsVacant)  --Output: N, Yes, Y, No.
from PortfolioProject.dbo.NashvilleHousing 
Group by SoldAsVacant
Order by 2

--Replacing Y and N into Yes and No
Select SoldAsVacant,
CASE When SoldAsVacant = 'Y' then 'Yes'
	When SoldAsVacant='N' then 'No'
	else SoldAsVacant
	end
from PortfolioProject.dbo.NashvilleHousing

Update PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' then 'Yes'
	When SoldAsVacant='N' then 'No'
	else SoldAsVacant
	end

--Checking the updated SoldAsVacant Count:
Select DISTINCT(SoldAsVacant), Count(SoldAsVacant)  --Output: N, Yes, Y, No.
from PortfolioProject.dbo.NashvilleHousing 
Group by SoldAsVacant
Order by 2


-----------------------------------------------------------------------------------------------------

--REMOVE DUPLICATES (on unique datas)

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

-- to check if data in the 'partition columns' are the same,
-- then it is an unusual data (might be the same/duplicate data)
WITH RowNumCTE as (
Select *,
	ROW_NUMBER() OVER(
		Partition by ParcelID,
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 order by 
						UniqueID
				) row_num		--row_num new column to see if there are duplicates (2 means the data have duplicates)
FROM PortfolioProject.dbo.NashvilleHousing
)
--show the duplicates data (row_num = 2)
Select *
from RowNumCTE
where row_num >1
order by PropertyAddress

--Deleting duplicates (where row_num=2)
WITH RowNumCTE as (
Select *,
	ROW_NUMBER() OVER(
		Partition by ParcelID,
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 order by 
						UniqueID
				) row_num		--row_num new column to see if there are duplicates (2 means the data have duplicates)
FROM PortfolioProject.dbo.NashvilleHousing
)
DELETE
from RowNumCTE
where row_num > 1


-----------------------------------------------------------------------------------------------------

--DELETE UNUSED COLUMNS

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

--Drop some unimportant columns 
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate

