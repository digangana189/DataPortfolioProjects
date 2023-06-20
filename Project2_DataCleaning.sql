
--Viewing all data from the table to check for successful import

Select *
From PortfolioProject2.dbo.NashvilleHousing

-- Standardize Date Format(remove timestamp and view just the date)

Select SaleDate,CONVERT(Date,SaleDate)
From PortfolioProject2.dbo.NashvilleHousing

--Updating SaleDate column in the Table

ALTER TABLE NashvilleHousing
Add SaleDateFixed Date;

Update NashvilleHousing
SET SaleDateFixed = CONVERT(Date,SaleDate)

Select SaleDateFixed From PortfolioProject2.dbo.NashvilleHousing


-- Populate Property Address data where the address is null
Select *
From PortfolioProject2.dbo.NashvilleHousing
Where PropertyAddress is null

--Doing a self join to equate parcel ids with repective addresses

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject2.dbo.NashvilleHousing a
JOIN PortfolioProject2.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
--parcelids can be duplicate but not unique ids, so checking for same parcel ids but diff unique ids
Where a.PropertyAddress is null

--Updating the table accordingly, to fill up null vales in property address(after update abv query should return no rows)
Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject2.dbo.NashvilleHousing a
JOIN PortfolioProject2.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
Where a.PropertyAddress is null

-- Breaking out Property Address into Individual Columns (Address, City, State), considering ',' is the delimiter that seperates each field
-- using +1/-1 in charindex to avoid the comma itself and get just the string

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Street,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as City
From PortfolioProject2.dbo.NashvilleHousing

--Updating the table accordingly

ALTER TABLE NashvilleHousing
Add [PropertyStreet] Nvarchar(255),
    [PropertyCity] Nvarchar(255);

Update NashvilleHousing
SET PropertyStreet = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

Update NashvilleHousing
SET PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


-- Breaking out Owner Address into Individual Columns (Address, City, State), considering ',' is the delimiter that seperates each field

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProject2.dbo.NashvilleHousing

--Updating table into individual columns

ALTER TABLE NashvilleHousing
Add OwnerStreet Nvarchar(255),
    OwnerCity Nvarchar(255),
	OwnerState Nvarchar(255);

Update NashvilleHousing
SET OwnerStreet = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

Update NashvilleHousing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

Update NashvilleHousing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)	

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject2.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2

Select SoldAsVacant,
CASE When SoldAsVacant = 'Y' THEN 'Yes'
	 When SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
From PortfolioProject2.dbo.NashvilleHousing

--Updating table accordinlgy, y to yes, n to no

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


--Removing duplicate data
--Finding duplicates to store them in a cte, then deleting them off
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject2.dbo.NashvilleHousing
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress


-- Delete Unused Columns like Address/Date Columns altered before 


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate



