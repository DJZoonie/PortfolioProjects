-- Select All
select * from portfolioproject.nashville_housing_data_for_data_cleaning






-- Standardize Date Format (Remember to adjust str_to_date format correctly)

select SaleDate, str_to_date (SaleDate , '%M %e, %Y') as SaleDateConverted
from portfolioproject.nashville_housing_data_for_data_cleaning

alter table nashville_housing_data_for_data_cleaning 
add SaleDateConverted nvarchar(255)

update nashville_housing_data_for_data_cleaning 
set SaleDateConverted = str_to_date (SaleDate , '%M %e, %Y')





-- Populate Property Address Data

-- Since ParcelID corresponds to the same property address
-- if a sale with parcelid has an address and another with the same parcelid 
-- doesn't, that field will be populated

select *
from portfolioproject.nashville_housing_data_for_data_cleaning
where PropertyAddress is null

-- This Query checks if there are any null values at Property address
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ifnull(a.PropertyAddress, b.PropertyAddress) 
from portfolioproject.nashville_housing_data_for_data_cleaning a
join portfolioproject.nashville_housing_data_for_data_cleaning b
on a.ParcelId = b.ParcelID and a.UniqueID <> b.UniqueID 
where a.PropertyAddress is null

update nashville_housing_data_for_data_cleaning a 
inner join nashville_housing_data_for_data_cleaning b
on a.ParcelId = b.ParcelID and a.UniqueID <> b.UniqueID 
set a.PropertyAddress = ifnull(a.PropertyAddress, b.PropertyAddress)
where a.PropertyAddress is null






-- Breaking out address into individual columns (Civil #, Street, City), Notice that city is delimited by a ','
select PropertyAddress 
from portfolioproject.nashville_housing_data_for_data_cleaning


-- This selects the substring to  the left of the comma
select substring_index(PropertyAddress, ',', 1) as Address
from portfolioproject.nashville_housing_data_for_data_cleaning


-- This selects to city to the right of the comma
select substring_index(PropertyAddress, ',', -1) as City
from portfolioproject.nashville_housing_data_for_data_cleaning


-- Separate the values by creating 2 columns
alter table nashville_housing_data_for_data_cleaning 
add PropertySplitAddress nvarchar(255)

update nashville_housing_data_for_data_cleaning 
set PropertySplitAddress = substring_index(PropertyAddress, ',', 1)


alter table nashville_housing_data_for_data_cleaning 
add PropertySplitCity nvarchar(255)

update nashville_housing_data_for_data_cleaning 
set PropertySplitCity = substring_index(PropertyAddress, ',', -1)


select PropertySplitCity
from portfolioproject.nashville_housing_data_for_data_cleaning








-- Check Owner Address
select OwnerAddress, 
substring_index(OwnerAddress, ',', 1), 
substring_index(substring_index(OwnerAddress, ',', 2), ',', -1), -- We select the substring of a substring since the city is between 2 commas
substring_index(OwnerAddress, ',', -1)
from portfolioproject.nashville_housing_data_for_data_cleaning

-- Now we can create the columns and update the values

alter table nashville_housing_data_for_data_cleaning 
add OwnerSplitAddress nvarchar(255)

update nashville_housing_data_for_data_cleaning 
set OwnerSplitAddress = substring_index(OwnerAddress, ',', 1)


alter table nashville_housing_data_for_data_cleaning 
add OwnerSplitCity nvarchar(255)

update nashville_housing_data_for_data_cleaning 
set OwnerSplitCity = substring_index(substring_index(OwnerAddress, ',', 2), ',', -1)

drop column

alter table nashville_housing_data_for_data_cleaning
add OwnerSplitState nvarchar(255)

update nashville_housing_data_for_data_cleaning 
set OwnerSplitState = substring_index(OwnerAddress, ',', -1)







-- Notice that some SoldAsVacant are Yes/No and others are Y/N, these queries will make them all Yes/No

select SoldAsVacant, 
case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	End
from portfolioproject.nashville_housing_data_for_data_cleaning  
 
update nashville_housing_data_for_data_cleaning 
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	End


-- Remove Duplicates
	
-- Used a Common Table Expression so I can create a temp table with the row representing duplicates then used that table to isolate the duplicates
with RowNumberCTE as (
select *,
row_number () Over(
partition by ParcelID,
			PropertyAddress ,
			SalePrice,
			SaleDate,
			LegalReference
			order by UniqueID 
			) row_num

from portfolioproject.nashville_housing_data_for_data_cleaning
order by ParcelID
)
select * 
from RowNumberCTE
where row_num > 1

-- Use Delete Function to remove duplicates
with RowNumberCTE as (
select *,
row_number () Over(
partition by ParcelID,
			PropertyAddress ,
			SalePrice,
			SaleDate,
			LegalReference
			order by UniqueID 
			) row_num

from portfolioproject.nashville_housing_data_for_data_cleaning
)
delete from nashville_housing_data_for_data_cleaning 
using nashville_housing_data_for_data_cleaning 
join RowNumberCTE on nashville_housing_data_for_data_cleaning.UniqueID = RowNumberCTE.UniqueID
where row_num > 1


-- Delete Unused Columns
-- Since we split the property address and owner address, we no longer need the nonsplit rows, We can also delete the Tax district since it is irrelevant

alter table portfolioproject.nashville_housing_data_for_data_cleaning 
drop column OwnerAddress, 
drop column PropertyAddress, 
drop column TaxDistrict,

alter table portfolioproject.nashville_housing_data_for_data_cleaning 
drop column SaleDate
