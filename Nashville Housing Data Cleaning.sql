-- CLEANING NASHVILLE HOUSING DATA 

select * from [Portfolio Project].dbo.[Nashville Housing]

1. -- Standardize date format

select SaleDateConverted, convert (Date, SaleDate)
from [Portfolio Project].dbo.[Nashville Housing]

update [Nashville Housing]
set SaleDate = convert(Date, SaleDate)

Alter table [Nashville Housing]
add SaleDateConverted Date

update [Nashville Housing]
set SaleDateConverted = convert(Date, SaleDate)

2. --Populate property address data

select *
from [Portfolio Project].dbo.[Nashville Housing]
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress) as NewPropertyAddress
from [Portfolio Project].dbo.[Nashville Housing] a
join [Portfolio Project].dbo.[Nashville Housing] b
on a.ParcelID=b.ParcelID
AND a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

update a
set a.PropertyAddress=b.PropertyAddress
from [Portfolio Project].dbo.[Nashville Housing] a
join [Portfolio Project].dbo.[Nashville Housing] b
on a.ParcelID=b.ParcelID
AND a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null


3. -- Breaking out Address into Individual columns (Address, city, state)

select PropertyAddress
from [Portfolio Project].dbo.[Nashville Housing]
--where PropertyAddress is null
--order by ParcelID

4. --Removing the comma from the address

select
SUBSTRING(PropertyAddress,1,charindex(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,charindex(',', PropertyAddress)+1,len(PropertyAddress)) as Address
from [Portfolio Project].dbo.[Nashville Housing] 


-- Separating the Address and City into different columns
Alter table [Nashville Housing]
add PropertySplitAddress nvarchar(255)

update [Nashville Housing]
set PropertySplitAddress = SUBSTRING(PropertyAddress,1,charindex(',', PropertyAddress)-1)

Alter table [Nashville Housing]
add PropertySplitCity nvarchar(255)

update [Nashville Housing]
set PropertySplitCity = SUBSTRING(PropertyAddress,charindex(',', PropertyAddress)+1,len(PropertyAddress))

select * 
from [Portfolio Project].dbo.[Nashville Housing] 


5. -- Splitting owner address using parsename

select OwnerAddress
from [Portfolio Project].dbo.[Nashville Housing]

select
PARSENAME(Replace(OwnerAddress,',','.'), 3),
PARSENAME(Replace(OwnerAddress,',','.'), 2),
PARSENAME(Replace(OwnerAddress,',','.'), 1)
from [Portfolio Project].dbo.[Nashville Housing]

Alter table [Nashville Housing]
add OwnerSplitAddress nvarchar(255)

update [Nashville Housing]
set OwnerSplitAddress =PARSENAME(Replace(OwnerAddress,',','.'), 3)

Alter table [Nashville Housing]
add OwnerSplitCity nvarchar(255)

update [Nashville Housing]
set OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.'), 2)

Alter table [Nashville Housing]
add OwnerSplitState nvarchar(255)

update [Nashville Housing]
set OwnerSplitState = PARSENAME(Replace(OwnerAddress,',','.'), 1)

select * 
from [Portfolio Project].dbo.[Nashville Housing] 


6. --	Changing Y and N to YES and NO in the 'Sold as vacant' field

select distinct(SoldAsVacant), count (SoldAsVacant) as Soldunits
from [Portfolio Project].dbo.[Nashville Housing] 
group by SoldAsVacant
order by 2

select SoldAsVacant,
case when SoldAsVacant ='Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end
from [Portfolio Project].dbo.[Nashville Housing] 

update [Nashville Housing]
set SoldAsVacant = case when SoldAsVacant ='Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end
 

 7. --Removing duplicates from the table
 with RownumCTE as (
 select *,
 ROW_NUMBER() over (
 PARTITION by ParcelID,
			PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
		ORDER by 
			UniqueID
			) row_num
 from [Portfolio Project].dbo.[Nashville Housing] 
 --order by ParcelID
 )
 --select * 
 delete
 from RownumCTE
 where row_num >1



 8. --Deleting unused columns

 select * 
from [Portfolio Project].dbo.[Nashville Housing]

alter table [Portfolio Project].dbo.[Nashville Housing]
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate