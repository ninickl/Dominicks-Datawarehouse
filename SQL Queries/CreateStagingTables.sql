/*Creating Staging Weekly Table from Source Weekly Decode Table*/
SELECT [Week #] as [Week_Number],[Start] as [StartDate],[End] as [EndDate],[Special Events]
INTO [dbo].[Staging_Weekly_Decode]
FROM [dbo].[Source_Weekly_Decode];

/*Replacing Nulls with blanks in Staging Weekly decode table*/
UPDATE [Staging_Weekly_Decode] SET [Special Events]='' WHERE [Special Events] IS NULL

/*Creating Staging Store Demographics Table from Source Store Demographics Table*/
SELECT [STORE] as [Store_Number],[NAME] as [Store_Name],[CITY] as [City],[ZONE] as [Zone], [ZIP] as [Zipcode],[MMID],
[AGE60] as [Percent over 60 years], [PRICLOW], [PRICMED], [PRICHIGH]
INTO [dbo].[Staging_Store_Demographics]
FROM [dbo].[Source_Store_Demographics];

alter table [Staging_Store_Demographics] add [Price_tier] varchar(25)

update [Staging_Store_Demographics] set
        [Price_tier] = case 
                        when [PRICLOW] = 1 and [PRICMED] = 0 and [PRICHIGH] = 0 then 'Low'
						when [PRICLOW] = 0 and [PRICMED] = 1 and [PRICHIGH] = 0 then 'Medium'
						when [PRICLOW] = 0 and [PRICMED] = 0 and [PRICHIGH] = 1 then 'High'
                    end

/*Creating Staging UPC Tables from Source Source UPC Table*/
SELECT [COM_Code] as [CommodityCode],[UPC],[DESCRIP] as [Product_Name]
INTO [dbo].[Staging_UPCANA]
FROM [dbo].[Source_UPCANA];

/*Adding Type of the Product*/
Alter table [Staging_UPCANA] add [Type] varchar(25)
update  [Staging_UPCANA] set [Type] = 'Analgesics'

SELECT [COM_Code] as [CommodityCode],[UPC],[DESCRIP] as [Product_Name]
INTO [dbo].[Staging_UPCSDR]
FROM [dbo].[Source_UPCSDR];

Alter table [Staging_UPCSDR] add [Type] varchar(25)
update  [Staging_UPCSDR] set [Type] = 'Soft Drinks'

SELECT [COM_Code] as [CommodityCode],[UPC],[DESCRIP] as [Product_Name]
INTO [dbo].[Staging_UPCCER]
FROM [dbo].[Source_UPCCER];

Alter table [Staging_UPCCER] add [Type] varchar(25)
update  [Staging_UPCCER] set [Type] = 'Cereals'

/*Adding Type of the Product*/
Alter table [Staging_WANA] add [Type] varchar(25)
update  [Staging_WANA] set [Type] = 'Analgesics'
UPDATE [Staging_WANA] SET [Sale]='' WHERE [Sale] IS NULL

Alter table [Staging_WSDR] add [Type] varchar(25)
update  [Staging_WSDR] set [Type] = 'Soft Drinks'
UPDATE [Staging_WSDR] SET [Sale]='' WHERE [Sale] IS NULL

Alter table [Staging_WCER] add [Type] varchar(25)
update  [Staging_WCER] set [Type] = 'Cereals'
UPDATE [Staging_WCER] SET [Sale]='' WHERE [Sale] IS NULL

/*Creating Staging CCount Table from Source CCount Table*/

SELECT [STORE], [DATE], [WEEK], [FISH],[MEAT], [CAMERA], [WINE], [PHARMACY]
INTO [dbo].[Staging_CCOUNT]
FROM [dbo].[Source_CCOUNT];

/*Cleaning Staging CCount*/

DELETE FROM [Staging_CCOUNT] WHERE ([WEEK] = '.')
alter table [Staging_CCOUNT] alter column [WEEK] int;
DELETE FROM [Staging_CCOUNT] WHERE ([WEEK] < 1)
DELETE FROM [Staging_CCOUNT] WHERE ([STORE] NOT IN (SELECT Store_number FROM dimStore))

/*Creating Staging table for Product*/
CREATE TABLE [dbo].[ProductStaging](
[Store] [int] NULL,
[UPC_number] [bigint] NULL,
[WEEK] [float] NULL,
[Unit_price] [float] NULL,
[Quantity] [int] NULL,
[Number_of_units_sold] [int] NULL,
[Profit_per_dollar] [float] NULL,
[Sale_code] [nvarchar](255) NULL,
[Type] [nvarchar](25) NULL,
[Product_sales] [float] NULL
)

Insert into [dbo].[ProductStaging] ([Store],[UPC_number],[WEEK], [Unit_price],[Quantity],[Number_of_units_sold],
[Profit_per_dollar], [Sale_code], [Type],  [Product_sales]) 
select [STORE],[UPC], [WEEK],[PRICE], [QTY], [MOVE], [PROFIT], [SALE], [Type],([PRICE]*[MOVE])/[QTY]  from [dbo].[Staging_WANA] where [OK]= 1
union
select [STORE],[UPC],[WEEK], [PRICE], [QTY], [MOVE], [PROFIT], [SALE], [Type],([PRICE]*[MOVE])/[QTY] from [dbo].[Staging_WSDR] where [OK]= 1
union
select [STORE],[UPC],[WEEK], [PRICE], [QTY], [MOVE], [PROFIT], [SALE], [Type], ([PRICE]*[MOVE])/[QTY] from [dbo].[Staging_WCER] where [OK]= 1
