/* Here is project of Data Cleaning in SQL using a Housing dataset from Kaggle.com */

Select *
from PortfolioProject.dbo.NashvilleHousing

-- Standarize Date Format


Select SaleDate,cast(SaleDate as Date)
from PortfolioProject.dbo.NashvilleHousing
Update NashvilleHousing
Set SaleDate = CONVERT(Date,SaleDate)

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = CONVERT(Date,SaleDate)

Select SaleDateConverted
from PortfolioProject.dbo.NashvilleHousing

----------------------------------------------------------------------------

--- Populate Property Address data

Select *
from PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is NULL
order by ParcelID

-- Here we are going to fill in the Property Address that is null using information from the Parcel ID

Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(b.PropertyAddress,a.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
And a.[UniqueID ]<> b.[UniqueID ]
Where b.PropertyAddress is null

UpDate b
Set PropertyAddress = ISNULL(b.PropertyAddress,a.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
And a.[UniqueID ]<> b.[UniqueID ]
Where b.PropertyAddress is null

--- We can now see that there is no nulls in Property Address
Select PropertyAddress
from NashvilleHousing
Where PropertyAddress is null

----------------------------------------------------------------------

-- Breaking out Address Into Indivudual Columns (Address,City,State)

Select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing

Select SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1) as Address,
		SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as City

from PortfolioProject.dbo.NashvilleHousing

Alter Table NashvilleHousing
Add Address Varchar(50);

Update NashvilleHousing
Set Address = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1)

Alter Table NashvilleHousing
Add City Varchar(50);

Update NashvilleHousing
Set City = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) 

-- Here we can se that the property address is spilt

Select *
from PortfolioProject.dbo.NashvilleHousing

-- We are going to do the same for the owner address but using PARSENAME

Select OwnerAddress
from PortfolioProject.dbo.NashvilleHousing

Select PARSENAME(Replace(OwnerAddress,',','.'),3) as Owner_Address
		,PARSENAME(Replace(OwnerAddress,',','.'),2) as City
		,PARSENAME(Replace(OwnerAddress,',','.'),1) as State

from PortfolioProject.dbo.NashvilleHousing

Alter Table NashvilleHousing
Add Owner_Address Varchar(50);

Update NashvilleHousing
Set Owner_Address = PARSENAME(Replace(OwnerAddress,',','.'),3)

Alter Table NashvilleHousing
Add Owner_City Varchar(50);

Update NashvilleHousing
Set Owner_City = PARSENAME(Replace(OwnerAddress,',','.'),2) 

Alter Table NashvilleHousing
Add State Varchar(20);

Update NashvilleHousing
Set State = PARSENAME(Replace(OwnerAddress,',','.'),1) 

--------------------------------------------------------------------------

-- Chamge Y and N to Yes and No in "Sold as Vacant" field

Select distinct(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing

Select SoldAsVacant, case
						When SoldAsVacant = 'Y' Then 'Yes'
						When SoldAsVacant = 'N' Then 'No'
						Else SoldAsVacant
						End
from PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant= case
						When SoldAsVacant = 'Y' Then 'Yes'
						When SoldAsVacant = 'N' Then 'No'
						Else SoldAsVacant
						End

------------------------------------------------------------------


-- Remove Duplicates using a CTE

With RowNumCTE as (
Select *,
ROW_NUMBER() over(
partition by ParcelID,
			PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
			Order by
			UniqueID
			) row_num
from PortfolioProject.dbo.NashvilleHousing
)

Select *
from RowNumCTE
where row_num >1

-------------------------------------------
-- Finally i´ll delete Unused Columns


Select *
from PortfolioProject.dbo.NashvilleHousing

Alter Table PortfolioProject.dbo.NashvilleHousing
Drop column SaleDate