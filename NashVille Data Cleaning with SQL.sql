
-- Cleaning Data in SQL Queries

Select *
From PortfolioProject1..NashvilleHousing
Order by 2

-- Standardize Date Format

Select SaleDateConverted, CONVERT(Date,SaleDate)
From PortfolioProject1.dbo.NashvilleHousing

Update PortfolioProject1.dbo.NashvilleHousing
Set    SaleDate = CONVERT(Date,SaleDate) 

Alter Table PortfolioProject1.dbo.NashvilleHousing
Add SaleDateConverted Date;

Update PortfolioProject1.dbo.NashvilleHousing
Set    SaleDateConverted = CONVERT(Date,SaleDate) 

---------------------------------------------------------------------------------------------

-- Populate Property Address data

Select*
From PortfolioProject1.dbo.NashvilleHousing
-- Where PropertyAddress is null
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL (a.PropertyAddress,b.PropertyAddress)
From PortfolioProject1.dbo.NashvilleHousing a
Join PortfolioProject1.dbo.NashvilleHousing b
     on a.ParcelID = b.ParcelID
	 And a.[UniqueID] <> b.[UniqueID]
     Where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL (a.PropertyAddress,b.PropertyAddress)
From PortfolioProject1.dbo.NashvilleHousing a
Join PortfolioProject1.dbo.NashvilleHousing b
     on a.ParcelID = b.ParcelID
	 And a.[UniqueID] <> b.[UniqueID]

----------------------------------------------------------------------------

-- Breaking out address into individual Columms (Address, City, State)

Select PropertyAddress
From PortfolioProject1.dbo.NashvilleHousing
-- Where PropertyAddress is null
-- Order by ParcelID


SELECT
SUBSTRING (PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING (PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as Address

From PortfolioProject1.dbo.NashvilleHousing

Alter Table PortfolioProject1.dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar(255)

Update PortfolioProject1.dbo.NashvilleHousing
Set    PropertySplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

Alter Table PortfolioProject1.dbo.NashvilleHousing
Add PropertySplitCity Nvarchar(255)

Update PortfolioProject1.dbo.NashvilleHousing
Set   PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))



Select*
From PortfolioProject1.dbo.NashvilleHousing



Select OwnerAddress
From PortfolioProject1.dbo.NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From PortfolioProject1.dbo.NashvilleHousing



Alter Table PortfolioProject1.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255)

Update PortfolioProject1.dbo.NashvilleHousing
Set    OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

Alter Table PortfolioProject1.dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255)

Update PortfolioProject1.dbo.NashvilleHousing
Set   OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

Alter Table PortfolioProject1.dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255)

Update PortfolioProject1.dbo.NashvilleHousing
Set   OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


Select*
From PortfolioProject1.dbo.NashvilleHousing

----------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold and Vacant" Field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject1.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2


Select SoldAsVacant,
CASE  When SoldAsVacant = 'Y' Then 'Yes'
      WHen SoldAsVacant = 'N' Then 'No'
	  Else SoldAsVacant
	  END

From PortfolioProject1.dbo.NashvilleHousing

Update PortfolioProject1.dbo.NashvilleHousing
SET SoldAsVacant = CASE  When SoldAsVacant = 'Y' Then 'Yes'
      WHen SoldAsVacant = 'N' Then 'No'
	  Else SoldAsVacant
	  END


---------------------------------------------------------------------------------

-- Remove Duplicate Rolls and getrid of unused Columms 
-- Not always recomemded to do the On SQL . You can do this in Excel

Select *,
      ROW_NUMBER() Over (
	  PARTITION BY ParcelID,
	               PropertyAddress,
				   SalePrice,
				   SaleDate,
				   LegalReference
		Order By   UniqueID) Row_Num

From PortfolioProject1.dbo.NashvilleHousing
Order by ParcelID

-- Now because of the Multi Row_Num. Roll greater Than one, We need to Use CTE
-- CTE to pull all the Duplicate roll up
 
WITH RowNumCTE AS(
Select *,
      ROW_NUMBER() Over (
	  PARTITION BY ParcelID,
	               PropertyAddress,
				   SalePrice,
				   SaleDate,
				   LegalReference
		Order By   UniqueID) Row_Num

From PortfolioProject1.dbo.NashvilleHousing
--Order by ParcelID
)
--DELETE
SELECT*
From RowNumCTE
Where Row_Num > 1
Order by PropertyAddress


-------------------------------------------------------------------------------------------

-- Delete Unused Columms


Select*
From PortfolioProject1.dbo.NashvilleHousing


Alter Table PortfolioProject1.dbo.NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress,SaleDate


----------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO




