select * from Portfolio.dbo.Nashville


select top 1000 UniqueID from Nashville

---------------Standardize the Sale Date(Changing from date time to date)------------
select SaleDate from Portfolio.dbo.Nashville

select SaleDate,CONVERT(Date,SaleDate) from Nashville --converted to normal date 
 --to add the new column to the table itself

 update Nashville
 set SaleDate = CONVERT(Date,SaleDate) --this method didnt work,so had to add a new coloumn then update

 Alter Table Nashville
 Add SaleDateNew Date;

 Update Nashville
Set SaleDateNew = CONVERT(Date,SaleDate)

select SaleDate, SaleDateNew from Nashville

---------Populate the Property Address-----------
Select * from Nashville
---where PropertyAddress is null
order by ParcelID

---we are doing a self join to join the table together----
  select * from Nashville a
	join
  Nashville b
	on a.ParcelID = b.ParcelID
	and a.UniqueID <> b.UniqueID

	select a.ParcelID, a.PropertyAddress, b.ParcelID,b.PropertyAddress ,ISNUlL(b.PropertyAddress, a.PropertyAddress)
		from Nashville a
	join
  Nashville b
	on a.ParcelID = b.ParcelID
	and a.UniqueID <> b.UniqueID
	where b.PropertyAddress is null

	update b    ---(when upadating a join always use the alias.)
	set PropertyAddress =ISNUlL(b.PropertyAddress, a.PropertyAddress)
		from Nashville a
	join
  Nashville b
	on a.ParcelID = b.ParcelID
	and a.UniqueID <> b.UniqueID
	where b.PropertyAddress is null

	Select * from Nashville
	--where PropertyAddress is null


	-----BREAKING OUT ADDRESS INTO INDIVIDUAL COLOUMN---------(Addres, City,State)
	Select PropertyAddress 
		from Nashville
Select SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as Address
from Nashville
--CHARINDEX returns the position of the a particular word,letter( it gives the number position e.g 19)
---the -1 is to remove the , still showing
--the substring has 3 functions ( the string, starting and ending)

ALTER TABLE NASHVILLE
ADD PropertyAddressStreet nvarchar(255);

update Nashville
set PropertyAddressStreet  = SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NASHVILLE
ADD PropertyAddressCity nvarchar(255);

update Nashville
Set PropertyAddressCity   = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

select * from Nashville

---Seperating the Owners Address----
Select OwnerAddress from Nashville --we are using the function "PARSENAME" (but only works with (.) and not comma(,))

select 
PARSENAME(REPLACE(OwnerAddress, ',','.') ,3)  as OwnerAddressTown,  --we arranged it as (3,2,1 because of the arrangement)
PARSENAME(REPLACE(OwnerAddress, ',','.') ,2)  as OwnerAddressCity, --parsename kinda brings the rsult backwards
PARSENAME(REPLACE(OwnerAddress, ',','.') ,1)  as OwnerAddressStreet  ---hence the 3,2,1
 from Nashville


 Alter table Nashville
 add OwnerAddressTown nvarchar (255);

 update Nashville
 set OwnerAddressTown =PARSENAME(REPLACE(OwnerAddress, ',','.') ,3)  as OwnerAddressTown

 Alter table Nashville
 add OwnerAddressTown nvarchar (255);

 update Nashville
 set OwnerAddressTown =PARSENAME(REPLACE(OwnerAddress, ',','.') ,2)

 Alter table Nashville
 add OwnerAddressStreet Nvarchar (255);

 update Nashville
 set OwnerAddressStreet =PARSENAME(REPLACE(OwnerAddress, ',','.') ,1) 

 select * from Nashville


 -----Change Y and N to Yes and No in 'Sold as Vacant" Field

 select  distinct SoldasVacant,count(SoldasVacant)
 from Nashville
 group by SoldasVacant
 order by 2

  Select  SoldasVacant,
  case when SoldasVacant = 'Y' then 'Yes'
		 when SoldasVacant = 'N' then 'No'
			else SoldasVacant
			end
from Nashville 

 Alter table Nashville
 add SoldasVacantnew nvarchar(255);

 update nashville 
  set SoldasVacantnew = case when SoldasVacant = 'Y' then 'Yes'
		 when SoldasVacant = 'N' then 'No'
			else SoldasVacant
			end
	select * from Nashville

-----REMOVE DUPLICATES-----


With CTE AS       ----using a CTE here 
	(select *,
	ROW_NUMBER() over (
		Partition by ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate
					order by UniqueID) as row_num
	from Nashville)
	
	delete * FROM CTE ---using the delete statement
	WHERE row_num >1

  ------REMOVE UNUSED COLOUMN ------
 

  Alter table nashville
  drop column OwnerAddress,PropertyAddress,TaxDistrict