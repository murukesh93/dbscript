/****** Object:  Database [DevSurvey]    Script Date: 8/9/2019 7:40:03 PM ******/
CREATE DATABASE [DevSurvey]  (EDITION = 'Basic', SERVICE_OBJECTIVE = 'Basic', MAXSIZE = 2 GB) WITH CATALOG_COLLATION = SQL_Latin1_General_CP1_CI_AS;
GO
ALTER DATABASE [DevSurvey] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [DevSurvey] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [DevSurvey] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [DevSurvey] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [DevSurvey] SET ARITHABORT OFF 
GO
ALTER DATABASE [DevSurvey] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [DevSurvey] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [DevSurvey] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [DevSurvey] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [DevSurvey] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [DevSurvey] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [DevSurvey] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [DevSurvey] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [DevSurvey] SET ALLOW_SNAPSHOT_ISOLATION ON 
GO
ALTER DATABASE [DevSurvey] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [DevSurvey] SET READ_COMMITTED_SNAPSHOT ON 
GO
ALTER DATABASE [DevSurvey] SET  MULTI_USER 
GO
ALTER DATABASE [DevSurvey] SET ENCRYPTION ON
GO
ALTER DATABASE [DevSurvey] SET QUERY_STORE = ON
GO
ALTER DATABASE [DevSurvey] SET QUERY_STORE (OPERATION_MODE = READ_WRITE, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30), DATA_FLUSH_INTERVAL_SECONDS = 900, INTERVAL_LENGTH_MINUTES = 60, MAX_STORAGE_SIZE_MB = 100, QUERY_CAPTURE_MODE = AUTO, SIZE_BASED_CLEANUP_MODE = AUTO)
GO
/****** Object:  UserDefinedFunction [dbo].[fnSplitComma]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE FUNCTION [dbo].[fnSplitComma](
       -- Add the parameters for the function here
       @input NVARCHAR(max))
RETURNS @retBigint TABLE( [Value] [BIGINT] NOT NULL )
AS
BEGIN
DECLARE @bigint NVARCHAR(100);
DECLARE @pos [INT];
SET @input = LTRIM(RTRIM(@input)) + ','; -- TRIMMING THE BLANK SPACES
SET @pos = CHARINDEX(',', @input, 1); -- OBTAINING THE STARTING POSITION OF COMMA IN THE GIVEN STRING
IF REPLACE(@input, ',', '') <> '' -- CHECK IF THE STRING EXIST FOR US TO SPLIT
    BEGIN
     WHILE @pos > 0
      BEGIN
       SET @bigint = LTRIM(RTRIM(LEFT(@input, @pos - 1))); -- GET THE 1ST INT VALUE TO BE INSERTED
       IF @bigint <> ''
        BEGIN
            INSERT INTO @retBigint
             ( Value )
            VALUES( CAST(@bigint AS [BIGINT]));
        END;
       SET @input = RIGHT(@input, LEN(@input) - @pos); -- RESETTING THE INPUT STRING BY REMOVING THE INSERTED ONES
       SET @pos = CHARINDEX(',', @input, 1); -- OBTAINING THE STARTING POSITION OF COMMA IN THE RESETTED NEW STRING
      END;
    END;
       RETURN;
       END;


GO
/****** Object:  Table [dbo].[tblSurvey]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblSurvey](
	[SurveyId] [int] IDENTITY(1,1) NOT NULL,
	[SurveyTitle] [varchar](100) NULL,
	[Description] [varchar](max) NULL,
	[EmailTemplate] [varchar](max) NULL,
	[SurveyType] [varchar](25) NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedDate] [datetime] NULL,
	[CreatedBy] [int] NULL,
	[ModifiedBy] [int] NULL,
	[IsActive] [bit] NULL,
	[IsDeleted] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[SurveyId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblMatchdigitalUser]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblMatchdigitalUser](
	[UserId] [int] IDENTITY(1,1) NOT NULL,
	[FirstName] [varchar](50) NULL,
	[LastName] [varchar](50) NULL,
	[Address] [varchar](250) NULL,
	[ContactNumber] [varchar](25) NULL,
	[Email] [varchar](50) NULL,
	[Password] [varchar](50) NULL,
	[RoleId] [int] NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedDate] [datetime] NULL,
	[CreatedBy] [int] NULL,
	[ModifiedBy] [int] NULL,
	[PasswordUpdatedDate] [datetime] NULL,
	[IsActive] [bit] NULL,
	[IsDeleted] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[UserId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[vwGetSurvey]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


 
 CREATE view [dbo].[vwGetSurvey]
 as 
 -- get all survey records 
 select SurveyId, SurveyTitle,Description,EmailTemplate,SurveyType,su.CreatedBy CreatedBy,su.CreatedDate CreatedDate,
  su.ModifiedDate,su.ModifiedBy, su.IsActive IsActive,CONCAT( us.FirstName,' ',us.LastName) CreatedName,
  concat(us.FirstName,' ',us.LastName,'_',convert(varchar, su.CreatedDate, 23),'_',SurveyType,'_',SurveyTitle)Search from tblSurvey su
  left join tblMatchdigitalUser us on us.UserId=su.CreatedBy 
   where su.IsDeleted=0;
GO
/****** Object:  Table [dbo].[tblSuccessStory]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblSuccessStory](
	[SuccessStoryId] [int] IDENTITY(1,1) NOT NULL,
	[DigiPartnerProfileId] [int] NULL,
	[StoryContent] [varchar](max) NULL,
	[Title] [varchar](250) NULL,
	[SuccessStoryImage] [varchar](250) NULL,
	[Tag] [varchar](50) NULL,
	[Status] [varchar](25) NULL,
	[CreatedDate] [datetime] NULL,
	[IsDeleted] [bit] NULL,
	[SuccessStoryPDF] [varchar](250) NULL,
	[Email] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[SuccessStoryId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblCategory]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblCategory](
	[CategoryId] [int] IDENTITY(1,1) NOT NULL,
	[CategoryName] [varchar](250) NULL,
	[CategoryLevelQuestion] [nvarchar](max) NULL,
	[SortOrder] [int] NULL,
	[DisplayIcon] [varchar](100) NULL,
	[IsActive] [bit] NULL,
	[IsDeleted] [bit] NULL,
	[UID] [varchar](20) NULL,
	[CategoryType] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[CategoryId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblSubCategory]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblSubCategory](
	[SubCategoryId] [int] IDENTITY(1,1) NOT NULL,
	[CategoryId] [int] NULL,
	[SubCategoryName] [varchar](200) NULL,
	[ControlType] [varchar](25) NULL,
	[IsTextBoxEnabled] [bit] NULL,
	[ColorCode] [varchar](15) NULL,
	[UID] [varchar](20) NULL,
	[AliasName] [varchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[SubCategoryId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblSubCategoryChild]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblSubCategoryChild](
	[SubCategoryChildId] [int] IDENTITY(1,1) NOT NULL,
	[SubCategoryId] [int] NULL,
	[ChildName] [varchar](100) NULL,
	[IsActive] [bit] NULL,
	[IsDeleted] [bit] NULL,
	[UID] [varchar](20) NULL,
	[IsUserInput] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[SubCategoryChildId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblClassificationReferenceMaster]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblClassificationReferenceMaster](
	[ClassificationId] [int] IDENTITY(1,1) NOT NULL,
	[ClassificationRefId] [int] NULL,
	[ClassificationLevel] [varchar](50) NULL,
	[ModuleRefId] [int] NULL,
	[ModuleType] [varchar](50) NULL,
	[IsPrimary] [bit] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblDigiPartnerProfile]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblDigiPartnerProfile](
	[DigiPartnerProfileId] [int] IDENTITY(1,1) NOT NULL,
	[Email] [varchar](50) NULL,
	[Password] [varchar](50) NULL,
	[CompanyName] [varchar](100) NULL,
	[Logo] [varchar](500) NULL,
	[Slogan] [varchar](max) NULL,
	[CompanyProfile] [nvarchar](max) NULL,
	[ProductProfile] [nvarchar](max) NULL,
	[HouseNumber] [varchar](50) NULL,
	[PostalCode] [varchar](25) NULL,
	[Place] [varchar](50) NULL,
	[Country] [varchar](50) NULL,
	[EmployeeCount] [varchar](20) NULL,
	[YearOfFounding] [varchar](10) NULL,
	[PhoneNumber] [varchar](25) NULL,
	[ContactPersonFirstName] [varchar](25) NULL,
	[ContactPersonLastName] [varchar](25) NULL,
	[PositionInCompany] [varchar](50) NULL,
	[RoleId] [int] NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedDate] [datetime] NULL,
	[PasswordUpdatedDate] [datetime] NULL,
	[IsActive] [bit] NULL,
	[IsDeleted] [bit] NULL,
	[IsPublic] [bit] NULL,
	[Answers] [nvarchar](max) NULL,
	[Membership] [varchar](25) NULL,
PRIMARY KEY CLUSTERED 
(
	[DigiPartnerProfileId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  View [dbo].[vwGetSuccessStory]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  

 CREATE view [dbo].[vwGetSuccessStory]
as 
-- get all success story 
 select SuccessStoryId,CompanyName,StoryContent,Title,SuccessStoryImage,Tag,Status,st.CreatedDate,SuccessStoryPDF,st.Email,
 (case -- get success story classification level 
		  when ClassificationLevel='SubCategory' then su.SubCategoryName
		  when ClassificationLevel='Category' then ca.CategoryName 
		  when ClassificationLevel='SubCategoryChild' then ch.ChildName
		  end)  Classification,
 concat(CompanyName,'_',Title,'_',Tag,'_',Status,'_',convert(varchar, st.CreatedDate, 23),'_',st.Email,'_', 
  (case 
		  when ClassificationLevel='SubCategory' then su.SubCategoryName
		  when ClassificationLevel='Category' then ca.CategoryName 
		  when ClassificationLevel='SubCategoryChild' then ch.ChildName
		  end)) Search
 from  tblSuccessStory st 
 inner join tblDigiPartnerProfile dp on dp.DigiPartnerProfileId=st.DigiPartnerProfileId
 inner join tblClassificationReferenceMaster rfm on rfm.ModuleRefId=st.SuccessStoryId
 left join tblSubCategory su on su.SubCategoryId=rfm.ClassificationRefId
 left join tblCategory ca on ca.CategoryId=rfm.ClassificationRefId
 left join tblSubCategoryChild ch  on ch.SubCategoryChildId=rfm.ClassificationRefId
 where  st.IsDeleted=0 and   ModuleType='tblSuccessStory';
GO
/****** Object:  Table [dbo].[tblKMUUser]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblKMUUser](
	[KMUUserId] [int] IDENTITY(1,1) NOT NULL,
	[SurName] [varchar](50) NULL,
	[FirstName] [varchar](50) NULL,
	[Title] [varchar](100) NULL,
	[Salutation] [varchar](20) NULL,
	[Email] [varchar](50) NULL,
	[Password] [varchar](50) NULL,
	[PhoneNumber] [varchar](50) NULL,
	[Position] [varchar](50) NULL,
	[CompanyName] [varchar](100) NULL,
	[StreetAndHouseNo] [varchar](250) NULL,
	[PostalCode] [varchar](25) NULL,
	[Turnover] [varchar](50) NULL,
	[EmployeeCount] [varchar](20) NULL,
	[CreatedDate] [datetime] NULL,
	[UpdatedDate] [datetime] NULL,
	[PasswordUpdatedDate] [datetime] NULL,
	[IsDeleted] [bit] NULL,
	[Country] [varchar](50) NULL,
	[IsActive] [bit] NULL,
	[RoleId] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[KMUUserId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblUserSurvey]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblUserSurvey](
	[UserSurveyId] [int] IDENTITY(1,1) NOT NULL,
	[RespondentId] [int] NULL,
	[RespodentType] [int] NULL,
	[SurveyId] [int] NULL,
	[IsSurveyCompleted] [bit] NULL,
	[SurveyModifiedDate] [datetime] NULL,
	[SurveyReport] [nvarchar](max) NULL,
	[SurveyEmailResult] [nvarchar](max) NULL,
	[GraphValues] [nvarchar](max) NULL,
	[FollowUpMailContent] [nvarchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[UserSurveyId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  View [dbo].[vwGetUserSurveyList]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 CREATE view [dbo].[vwGetUserSurveyList]
as
-- Get user already taken survey list
select distinct us.SurveyId,su.SurveyTitle,IsSurveyCompleted,RespondentId,ku.SurName,ku.FirstName,ku.Email,ku.CompanyName,ku.Password,
concat(su.SurveyTitle,'_',ku.SurName,'_',ku.FirstName,'_',ku.Email,'_',ku.CompanyName,'_',ku.Password
)Search from tblUserSurvey us
inner join tblKMUUser ku on ku.KMUUserId=us.RespondentId 
inner join tblSurvey su on su.SurveyId=us.SurveyId;
GO
/****** Object:  Table [dbo].[tblBlog]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblBlog](
	[BlogId] [int] IDENTITY(1,1) NOT NULL,
	[Title] [varchar](200) NULL,
	[BlogContent] [varchar](max) NULL,
	[PublisherName] [varchar](100) NULL,
	[BlogPublishDate] [datetime] NULL,
	[PublisherType] [int] NULL,
	[PublisherId] [int] NULL,
	[ApprovalStatus] [int] NULL,
	[BlogStatus] [bit] NULL,
	[IsDeleted] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[BlogId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblKeywordsMaster]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblKeywordsMaster](
	[KeywordId] [int] IDENTITY(1,1) NOT NULL,
	[Keyword] [varchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[KeywordId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblBlogKeywords]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblBlogKeywords](
	[BlogKeywordId] [int] IDENTITY(1,1) NOT NULL,
	[BlogId] [int] NULL,
	[KeywordId] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[BlogKeywordId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[vwGetBlog]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 

 CREATE VIEW [dbo].[vwGetBlog]  
AS    
   -- select entire blog records
   SELECT  
 BL.BlogId, BL.Title,BlogPublishDate,  MU.FirstName + ' '+ MU.LastName PublisherName,
  KeyWord = STUFF((   -- select   blog keywords
   SELECT ',' + Keyword  
   FROM tblBlogKeywords bkey  
   INNER JOIN tblKeywordsMaster km  
    ON km.KeywordId=bkey.KeywordId  
      WHERE BL.BlogId=bkey.BlogId  
   FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, ''),  
  
   STUFF((SELECT ',' +(CASE   -- select   blog primary Classification
    WHEN  ClassificationLevel ='Category' THEN CategoryName  
    WHEN ClassificationLevel = 'SubCategory' THEN SubCategoryName  
    WHEN ClassificationLevel = 'SubCategoryChild' THEN ChildName  
 END)  FROM tblClassificationReferenceMaster crm  
   LEFT OUTER JOIN tblCategory c on c.CategoryId = crm.ClassificationRefId and crm.ClassificationLevel ='Category'  
   LEFT OUTER JOIN tblSubCategory sc on sc.SubCategoryId = crm.ClassificationRefId and crm.ClassificationLevel ='SubCategory'  
   LEFT OUTER JOIN tblSubCategoryChild scc on scc.SubCategoryChildId = crm.ClassificationRefId and crm.ClassificationLevel ='SubCategoryChild'  
   where crm.ModuleRefId = bl.BlogId and IsPrimary = 1  
   FOR XML PATH (''))  
          , 1, 1, '')  AS Classification,  
  
    STUFF((SELECT ',' +(CASE   -- select   blog secondary Classification
    WHEN  ClassificationLevel ='Category' THEN CategoryName  
    WHEN ClassificationLevel = 'SubCategory' THEN SubCategoryName  
 WHEN ClassificationLevel = 'SubCategoryChild' THEN ChildName  
 END)  FROM tblClassificationReferenceMaster crm  
   LEFT OUTER JOIN tblCategory c on c.CategoryId = crm.ClassificationRefId and crm.ClassificationLevel ='Category'  
   LEFT OUTER JOIN tblSubCategory sc on sc.SubCategoryId = crm.ClassificationRefId and crm.ClassificationLevel ='SubCategory'  
   LEFT OUTER JOIN tblSubCategoryChild scc on scc.SubCategoryChildId = crm.ClassificationRefId and crm.ClassificationLevel ='SubCategoryChild'  
   where crm.ModuleRefId = bl.BlogId and IsPrimary = 0  
   FOR XML PATH (''))  
          , 1, 1, '')  AS SecondaryClassification,  
  --  this column used to search the blog table  
    concat(BL.Title,'_',CONVERT(VARCHAR(10),BlogPublishDate, 103),'_',BL.PublisherName,'_',STUFF((  
   SELECT ',' + Keyword  
   FROM tblBlogKeywords bkey  
   INNER JOIN tblKeywordsMaster km  
    ON km.KeywordId=bkey.KeywordId  
      WHERE BL.BlogId=bkey.BlogId  
   FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, ''),'_',  
   STUFF((SELECT ',' +(CASE  
    WHEN  ClassificationLevel ='Category' THEN CategoryName  
    WHEN ClassificationLevel = 'SubCategory' THEN SubCategoryName  
 WHEN ClassificationLevel = 'SubCategoryChild' THEN ChildName  
 END)  FROM tblClassificationReferenceMaster crm  
   LEFT OUTER JOIN tblCategory c on c.CategoryId = crm.ClassificationRefId and crm.ClassificationLevel ='Category'  
   LEFT OUTER JOIN tblSubCategory sc on sc.SubCategoryId = crm.ClassificationRefId and crm.ClassificationLevel ='SubCategory'  
   LEFT OUTER JOIN tblSubCategoryChild scc on scc.SubCategoryChildId = crm.ClassificationRefId and crm.ClassificationLevel ='SubCategoryChild'  
   where crm.ModuleRefId = bl.BlogId and IsPrimary = 1  
   FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, ''),'_',  
  
    STUFF((SELECT ',' +(CASE  
    WHEN  ClassificationLevel ='Category' THEN CategoryName  
    WHEN ClassificationLevel = 'SubCategory' THEN SubCategoryName  
 WHEN ClassificationLevel = 'SubCategoryChild' THEN ChildName  
 END)  FROM tblClassificationReferenceMaster crm  
   LEFT OUTER JOIN tblCategory c on c.CategoryId = crm.ClassificationRefId and crm.ClassificationLevel ='Category'  
   LEFT OUTER JOIN tblSubCategory sc on sc.SubCategoryId = crm.ClassificationRefId and crm.ClassificationLevel ='SubCategory'  
   LEFT OUTER JOIN tblSubCategoryChild scc on scc.SubCategoryChildId = crm.ClassificationRefId and crm.ClassificationLevel ='SubCategoryChild'  
   where crm.ModuleRefId = bl.BlogId and IsPrimary = 0  
   FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, '')) Search  
     
 FROM tblBlog BL
 left join tblMatchdigitalUser mu on mu.UserId=bl.PublisherId
 where BL.IsDeleted =0;  
GO
/****** Object:  Table [dbo].[tblRole]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblRole](
	[RoleId] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](50) NULL,
	[Description] [varchar](250) NULL,
PRIMARY KEY CLUSTERED 
(
	[RoleId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[vwGetAllDigiMDUsers]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[vwGetAllDigiMDUsers]
as 
--  combine and select all type of users (Matchdigital,KMU and Digipartner user)
 select UserId, 'matchdigital' CompanyName,FirstName,LastName,ContactNumber,Email,Password,IsActive,rl.Name RoleName,rl.RoleId,
CreatedDate,'ADMIN_USER'RoleType,null IsPublic, concat('matchdigital','_',FirstName,'_',LastName,'_',ContactNumber,'_',Email,'_',Password,'_',IsActive,'_',
rl.Name,'_',convert(varchar, CreatedDate, 23))Search ,null Membership
from tblMatchdigitalUser mu inner join tblRole rl on rl.RoleId=mu.RoleId where IsDeleted=0
union all
select DigiPartnerProfileId UserId,CompanyName,ContactPersonFirstName FirstName,ContactPersonLastName LastName,PhoneNumber ContactNumber,
Email,Password,IsActive,rl.Name RoleName,rl.RoleId,CreatedDate,'DIGIPARTNER_USER'RoleType,IsPublic,concat(CompanyName,'_',ContactPersonFirstName,'_',
ContactPersonLastName,'_',PhoneNumber,'_',Email,'_',Password,'_',IsActive,'_',rl.Name,'_',convert(varchar, CreatedDate, 23),'_',Membership)Search ,Membership
from tblDigiPartnerProfile dp inner join tblRole rl on rl.RoleId=dp.RoleId where IsDeleted=0
union all
select KMUUserId UserId,CompanyName,FirstName,SurName LastName,PhoneNumber ContactNumber,Email,Password,IsActive,rl.Name RoleName,
 km.RoleId,CreatedDate,'KMU_USER'RoleType,null IsPublic,CONCAT(CompanyName,'_',FirstName,'_',SurName,'_',PhoneNumber,'_',Email,'_',Password,'_',IsActive,
'_',rl.Name,'_',convert(varchar, CreatedDate, 23))Search,null Membership from tblKMUUser km inner join tblRole rl on rl.RoleId=km.RoleId where IsDeleted=0;
 
GO
/****** Object:  Table [dbo].[tblSubCategoryAnswer]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblSubCategoryAnswer](
	[SubCategoryAnswerId] [int] IDENTITY(1,1) NOT NULL,
	[DigiPartnerProfileId] [int] NULL,
	[SubCategoryId] [int] NULL,
	[Answer] [nvarchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[SubCategoryAnswerId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblSubCategoryChildAnswer]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblSubCategoryChildAnswer](
	[ChildAnswerId] [int] IDENTITY(1,1) NOT NULL,
	[DigiPartnerProfileId] [int] NULL,
	[SubCategoryChildId] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[ChildAnswerId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[vwspGetDigipartners]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


 CREATE view [dbo].[vwspGetDigipartners]
  as   
-- get digipartner profile personal data and  answers in nested format(Category-->Subcategory-->SubcategoryChild).
 Select  dpp.DigiPartnerProfileId,Email,CompanyName,Logo,Slogan,CompanyProfile,ProductProfile,HouseNumber,PostalCode,Place,Country,
 EmployeeCount,YearOfFounding,PhoneNumber,ContactPersonFirstName,ContactPersonLastName,PositionInCompany,dpp.RoleId,rl.Name RoleName,CreatedDate,
 ModifiedDate,PasswordUpdatedDate,IsPublic, dpp.Answers Answers, Concat(dpp.CompanyName,'_',dpp.PostalCode,'_',
  (select stuff((select '_' + ChildName from tblSubCategoryChild ch   
inner join tblSubCategoryChildAnswer cha on cha.SubCategoryChildId=ch.SubCategoryChildId
where dpp.DigiPartnerProfileId = cha.DigiPartnerProfileId for xml path('')),1,1,'')))Search, Membership,
(select cat.CategoryId,CategoryName,CategoryType,    
(select su.SubCategoryId,SubCategoryName,sua.Answer, su.AliasName, 
(select chl.SubCategoryChildId,chl.ChildName,chl.UID UID  
  
from tblSubCategoryChild chl     
Inner Join tblSubCategoryChildAnswer chla on chl.SubCategoryChildId = chla.SubCategoryChildId  
where su.SubCategoryId=chl.SubCategoryId and chla.DigiPartnerProfileId = dpp.DigiPartnerProfileId  for json Path )as SubCategoryChild   
     
from tblSubCategory su   
left outer Join tblSubCategoryAnswer sua on su.SubCategoryId =sua.SubCategoryId and sua.DigiPartnerProfileId = dpp.DigiPartnerProfileId  
left join tblSubCategoryChild chl on chl.SubCategoryId = su.SubCategoryId  
full outer join tblSubCategoryChildAnswer chla on chla.SubCategoryChildId = chl.SubCategoryChildId and chla.DigiPartnerProfileId = dpp.DigiPartnerProfileId  
where su.CategoryId = cat.CategoryId and (sua.DigiPartnerProfileId = dpp.DigiPartnerProfileId or chla.DigiPartnerProfileId = dpp.DigiPartnerProfileId)  
group by su.SubCategoryId,su.SubCategoryName,sua.Answer,su.AliasName  FOR JSON PATH)as Subcategory  
  
  
from tblCategory cat for json Path)as  Category   
from tblDigiPartnerProfile dpp    inner join tblRole rl on rl.RoleId=dpp.RoleId where IsDeleted=0
GO
/****** Object:  Table [dbo].[tblMediaContent]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblMediaContent](
	[MediaContentId] [int] IDENTITY(1,1) NOT NULL,
	[DocumentURL] [varchar](500) NULL,
	[DocumentType] [int] NULL,
	[ContentType] [varchar](100) NULL,
	[BlogId] [int] NULL,
	[IsDeleted] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[MediaContentId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblHeaderBanner]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblHeaderBanner](
	[HeaderBannerId] [int] IDENTITY(1,1) NOT NULL,
	[SortOrder] [int] NULL,
	[HeaderBannerName] [varchar](200) NULL,
	[Type] [int] NULL,
	[PublisherId] [int] NULL,
	[PublisherType] [int] NULL,
	[PublishDate] [datetime] NULL,
	[IsDeleted] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[HeaderBannerId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblBannerDetail]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblBannerDetail](
	[BannerDetailId] [int] IDENTITY(1,1) NOT NULL,
	[BannerText] [varchar](200) NULL,
	[BannerImageURL] [varchar](200) NULL,
	[BannerLinkURL] [varchar](200) NULL,
	[HeaderBannerId] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[BannerDetailId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblBannerBlogDetail]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblBannerBlogDetail](
	[BannerBlogDetailId] [int] IDENTITY(1,1) NOT NULL,
	[BlogId] [int] NULL,
	[HeaderBannerId] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[BannerBlogDetailId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[vwGetBanner]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[vwGetBanner]
 as
 -- get all Banner details
 select hb.HeaderBannerId,SortOrder,HeaderBannerName,Type,hb.PublisherId,PublishDate,
(case when Type=0 then BannerText else bl.BlogContent  end)  BannerText,
-- get custom banner
(case when Type=0 then BannerImageURL else (select TOP 1 DocumentURL FROM tblMediaContent where BlogId=bbd.BlogId and DocumentType=1 and IsDeleted=0  )  end)  BannerImageURL,
 BannerLinkURL,bbd.BlogId,concat(HeaderBannerName,'_',(case when Type=0 then BannerText else bl.BlogContent  end),
 '_',(case when Type=0 then BannerImageURL else (select TOP 1 DocumentURL FROM tblMediaContent where BlogId=bbd.BlogId and DocumentType=1 and IsDeleted=0  )  end),'_',CONVERT(VARCHAR(10),PublishDate, 103))Search from tblHeaderBanner hb
 left join tblBannerDetail bd on bd.HeaderBannerId=hb.HeaderBannerId
 left join tblBannerBlogDetail bbd on bbd.HeaderBannerId=hb.HeaderBannerId
 left join tblBlog bl on bl.BlogId=bbd.BlogId where hb.IsDeleted=0; 
GO
/****** Object:  Table [dbo].[tblBlogComment]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblBlogComment](
	[CommentId] [int] IDENTITY(1,1) NOT NULL,
	[BlogId] [int] NULL,
	[Comment] [varchar](max) NULL,
	[CommentTime] [datetime] NULL,
	[ParentId] [int] NULL,
	[UserId] [int] NULL,
	[UserType] [int] NULL,
	[IsVisible] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[CommentId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  View [dbo].[vwGetComments]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 

CREATE view [dbo].[vwGetComments]
 as 
 -- get all comments
  select cm.[BlogId],bl.Title, [Comment], [CommentTime], [ParentId], [UserId], [UserType], [IsVisible],
 concat(bl.Title,'_',Comment,'_',convert(varchar, [CommentTime], 23))Search from tblBlogComment cm
  inner join tblBlog bl on cm.BlogId=bl.BlogId where bl.IsDeleted=0
GO
/****** Object:  View [dbo].[vwGetRecentBlogs]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


  CREATE view [dbo].[vwGetRecentBlogs] 
   as    
   -- Get all recent blogs with keywords and mediacontent 
 select b.BlogId, b.Title, b.BlogContent, MU.FirstName + ' '+ MU.LastName PublisherName,BlogPublishDate  , b.PublisherType, b.PublisherId, b.ApprovalStatus, b.BlogStatus, 
(select DocumentURL,DocumentType,ContentType from tblMediaContent mc where mc.BlogId = b.BlogId and IsDeleted=0 for json path) as MediaContent,   
(select stuff((select ',' + km.Keyword from tblKeywordsMaster km   
inner join tblBlogKeywords bk on bk.KeywordId = km.KeywordId where bk.BlogId = b.BlogId for xml path('')),1,1,'')) As keywords,
(select count(*) from tblBlogComment where BlogId=b.BlogId) CommentsCount,concat(b.Title,'_',MU.FirstName + ' '+ MU.LastName,'_',
(select stuff((select ',' + km.Keyword from tblKeywordsMaster km   
inner join tblBlogKeywords bk on bk.KeywordId = km.KeywordId where bk.BlogId = b.BlogId for xml path('')),1,1,'')),'_',
CONVERT(VARCHAR(10), b.BlogPublishDate, 103))Search
from tblBlog b
 left join tblMatchdigitalUser mu on mu.UserId=b.PublisherId
where b.IsDeleted=0
  
GO
/****** Object:  UserDefinedFunction [dbo].[fnSplitString]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fnSplitString]
(
    @String NVARCHAR(4000)
    
)

RETURNS TABLE
AS

RETURN
(

    WITH Split(stpos,endpos)
    AS(
        SELECT 0 AS stpos, CHARINDEX(',',@String) AS endpos
        UNION ALL
        SELECT endpos+1, CHARINDEX(',',@String,endpos+1)
            FROM Split
            WHERE endpos > 0
    )
    SELECT 'Id' = ROW_NUMBER() OVER (ORDER BY (SELECT 1)),
        'Value' = SUBSTRING(@String,stpos,COALESCE(NULLIF(endpos,0),LEN(@String)+1)-stpos)
    FROM Split
)
   
GO
/****** Object:  Table [dbo].[tblClassification]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblClassification](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](100) NULL,
	[Description] [varchar](250) NULL,
	[ParentClass] [varchar](100) NULL,
	[IsDeleted] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblFiles]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblFiles](
	[FileId] [int] IDENTITY(1,1) NOT NULL,
	[FilePath] [varchar](500) NULL,
	[FileTypeId] [int] NULL,
	[FileReferenceId] [int] NULL,
	[IsDeleted] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[FileId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblFileType]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblFileType](
	[FileTypeId] [int] IDENTITY(1,1) NOT NULL,
	[FileType] [varchar](50) NULL,
	[Description] [varchar](250) NULL,
PRIMARY KEY CLUSTERED 
(
	[FileTypeId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblPage]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblPage](
	[PageId] [int] IDENTITY(1,1) NOT NULL,
	[Title] [varchar](100) NULL,
	[PageLevelQuestion] [varchar](max) NULL,
	[SurveyId] [int] NULL,
	[SortOrder] [int] NULL,
	[IsActive] [bit] NULL,
	[IsDeleted] [bit] NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedDate] [datetime] NULL,
	[CreatedBy] [int] NULL,
	[ModifiedBy] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[PageId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblProjectOwner]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblProjectOwner](
	[ProjectOwnertId] [int] IDENTITY(1,1) NOT NULL,
	[ProjectId] [int] NULL,
	[UserId] [int] NULL,
	[KMUUserId] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[ProjectOwnertId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblProjects]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblProjects](
	[ProjectId] [int] IDENTITY(1,1) NOT NULL,
	[CompanyName] [varchar](100) NULL,
	[Street] [varchar](50) NULL,
	[HouseNumber] [varchar](50) NULL,
	[PostalCode] [int] NULL,
	[City] [varchar](50) NULL,
	[Branch] [varchar](50) NULL,
	[ContactPersonName] [varchar](50) NULL,
	[ContactPersonPosition] [varchar](50) NULL,
	[ContactPersonMail] [varchar](50) NULL,
	[ContactPersonTelephone] [varchar](50) NULL,
	[CompanySize] [int] NULL,
	[ProjectTitle] [varchar](100) NULL,
	[ProjectDescription] [varchar](max) NULL,
	[ProjectExpectations] [varchar](max) NULL,
	[DigitalisationStatus] [varchar](max) NULL,
	[SoftwareInfrastructure] [varchar](max) NULL,
	[SoftwareVolume] [varchar](50) NULL,
	[ImplementationStart] [date] NULL,
	[ImplementationEnd] [date] NULL,
	[VendorSearch] [varchar](50) NULL,
	[CreatedDate] [datetime] NULL,
	[IsDeleted] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[ProjectId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblQuestion]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblQuestion](
	[QuestionLabelId] [int] IDENTITY(1,1) NOT NULL,
	[QuestionText] [varchar](max) NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedDate] [datetime] NULL,
	[CreatedBy] [int] NULL,
	[ModifiedBy] [int] NULL,
	[IsActive] [bit] NULL,
	[IsDeleted] [bit] NULL,
	[IsAllowFilter] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[QuestionLabelId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblQuestionCondition]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblQuestionCondition](
	[QuestionConditionId] [int] IDENTITY(1,1) NOT NULL,
	[QuestionId] [int] NULL,
	[QuestionConditions] [nvarchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[QuestionConditionId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblQuestionControlType]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblQuestionControlType](
	[ControlTypeId] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[ControlTypeId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblRelatedBlogs]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblRelatedBlogs](
	[RelatedBlogId] [int] IDENTITY(1,1) NOT NULL,
	[BlogId] [int] NOT NULL,
	[RelatedBlogs] [int] NOT NULL,
 CONSTRAINT [PK_tblRelatedBlogs] PRIMARY KEY CLUSTERED 
(
	[RelatedBlogId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblSuccessStoryComments]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblSuccessStoryComments](
	[CommentId] [int] IDENTITY(1,1) NOT NULL,
	[CommentBy] [int] NULL,
	[SuccessStoryId] [int] NULL,
	[Description] [varchar](max) NULL,
	[AnswerDate] [datetime] NULL,
	[IsDeleted] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[CommentId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblSurveyQuestionConfig]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblSurveyQuestionConfig](
	[QuestionId] [int] IDENTITY(1,1) NOT NULL,
	[PageId] [int] NULL,
	[QuestionLabelId] [int] NULL,
	[QuestionSortOrder] [int] NULL,
	[IsMandatory] [bit] NULL,
	[HasRelevanceControl] [bit] NULL,
	[ControlTypeId] [int] NULL,
	[QuestionOptions] [nvarchar](max) NULL,
	[AddQuestionToGraph] [bit] NULL,
	[IsDeleted] [bit] NULL,
	[CreatedBy] [int] NULL,
	[MatrixRowOptions] [nvarchar](max) NULL,
	[MatrixColumnOptions] [nvarchar](max) NULL,
	[TextOptions] [nvarchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[QuestionId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblUserSurvey1]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblUserSurvey1](
	[UserSurveyId] [int] IDENTITY(1,1) NOT NULL,
	[RespondentId] [int] NULL,
	[RespodentType] [int] NULL,
	[SurveyId] [int] NULL,
	[IsSurveyCompleted] [bit] NULL,
	[SurveyModifiedDate] [datetime] NULL,
	[SurveyReport] [nvarchar](max) NULL,
	[SurveyEmailResult] [nvarchar](max) NULL,
	[GraphValues] [nvarchar](max) NULL,
	[FollowUpMailContent] [nvarchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[UserSurveyId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblUserSurveyPageAnswers]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblUserSurveyPageAnswers](
	[UserSurveyAnswerId] [int] IDENTITY(1,1) NOT NULL,
	[UserSurveyId] [int] NULL,
	[PageId] [int] NULL,
	[Answer] [nvarchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[UserSurveyAnswerId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblUserType]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblUserType](
	[UserTypeId] [int] IDENTITY(1,1) NOT NULL,
	[Type] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[UserTypeId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblKMUUser] ADD  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[tblSubCategoryChild] ADD  DEFAULT ((0)) FOR [IsUserInput]
GO
ALTER TABLE [dbo].[tblBannerBlogDetail]  WITH CHECK ADD FOREIGN KEY([BlogId])
REFERENCES [dbo].[tblBlog] ([BlogId])
GO
ALTER TABLE [dbo].[tblBannerBlogDetail]  WITH CHECK ADD FOREIGN KEY([HeaderBannerId])
REFERENCES [dbo].[tblHeaderBanner] ([HeaderBannerId])
GO
ALTER TABLE [dbo].[tblBannerDetail]  WITH CHECK ADD FOREIGN KEY([HeaderBannerId])
REFERENCES [dbo].[tblHeaderBanner] ([HeaderBannerId])
GO
ALTER TABLE [dbo].[tblBlogComment]  WITH CHECK ADD FOREIGN KEY([BlogId])
REFERENCES [dbo].[tblBlog] ([BlogId])
GO
ALTER TABLE [dbo].[tblBlogKeywords]  WITH CHECK ADD FOREIGN KEY([BlogId])
REFERENCES [dbo].[tblBlog] ([BlogId])
GO
ALTER TABLE [dbo].[tblBlogKeywords]  WITH CHECK ADD FOREIGN KEY([KeywordId])
REFERENCES [dbo].[tblKeywordsMaster] ([KeywordId])
GO
ALTER TABLE [dbo].[tblDigiPartnerProfile]  WITH CHECK ADD FOREIGN KEY([RoleId])
REFERENCES [dbo].[tblRole] ([RoleId])
GO
ALTER TABLE [dbo].[tblFiles]  WITH CHECK ADD FOREIGN KEY([FileTypeId])
REFERENCES [dbo].[tblFileType] ([FileTypeId])
GO
ALTER TABLE [dbo].[tblKMUUser]  WITH CHECK ADD FOREIGN KEY([RoleId])
REFERENCES [dbo].[tblRole] ([RoleId])
GO
ALTER TABLE [dbo].[tblMatchdigitalUser]  WITH CHECK ADD FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[tblMatchdigitalUser] ([UserId])
GO
ALTER TABLE [dbo].[tblMatchdigitalUser]  WITH CHECK ADD FOREIGN KEY([ModifiedBy])
REFERENCES [dbo].[tblMatchdigitalUser] ([UserId])
GO
ALTER TABLE [dbo].[tblMatchdigitalUser]  WITH CHECK ADD FOREIGN KEY([RoleId])
REFERENCES [dbo].[tblRole] ([RoleId])
GO
ALTER TABLE [dbo].[tblMediaContent]  WITH CHECK ADD FOREIGN KEY([BlogId])
REFERENCES [dbo].[tblBlog] ([BlogId])
GO
ALTER TABLE [dbo].[tblPage]  WITH CHECK ADD FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[tblMatchdigitalUser] ([UserId])
GO
ALTER TABLE [dbo].[tblPage]  WITH CHECK ADD FOREIGN KEY([ModifiedBy])
REFERENCES [dbo].[tblMatchdigitalUser] ([UserId])
GO
ALTER TABLE [dbo].[tblPage]  WITH CHECK ADD FOREIGN KEY([SurveyId])
REFERENCES [dbo].[tblSurvey] ([SurveyId])
GO
ALTER TABLE [dbo].[tblProjectOwner]  WITH CHECK ADD FOREIGN KEY([KMUUserId])
REFERENCES [dbo].[tblKMUUser] ([KMUUserId])
GO
ALTER TABLE [dbo].[tblProjectOwner]  WITH CHECK ADD FOREIGN KEY([ProjectId])
REFERENCES [dbo].[tblProjects] ([ProjectId])
GO
ALTER TABLE [dbo].[tblProjectOwner]  WITH CHECK ADD FOREIGN KEY([UserId])
REFERENCES [dbo].[tblMatchdigitalUser] ([UserId])
GO
ALTER TABLE [dbo].[tblQuestion]  WITH CHECK ADD FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[tblMatchdigitalUser] ([UserId])
GO
ALTER TABLE [dbo].[tblQuestion]  WITH CHECK ADD FOREIGN KEY([ModifiedBy])
REFERENCES [dbo].[tblMatchdigitalUser] ([UserId])
GO
ALTER TABLE [dbo].[tblQuestionCondition]  WITH CHECK ADD FOREIGN KEY([QuestionId])
REFERENCES [dbo].[tblSurveyQuestionConfig] ([QuestionId])
GO
ALTER TABLE [dbo].[tblRelatedBlogs]  WITH CHECK ADD  CONSTRAINT [FK_tblRelatedBlogs_tblBlog] FOREIGN KEY([BlogId])
REFERENCES [dbo].[tblBlog] ([BlogId])
GO
ALTER TABLE [dbo].[tblRelatedBlogs] CHECK CONSTRAINT [FK_tblRelatedBlogs_tblBlog]
GO
ALTER TABLE [dbo].[tblRelatedBlogs]  WITH CHECK ADD  CONSTRAINT [FK_tblRelatedBlogs_tblBlog1] FOREIGN KEY([RelatedBlogs])
REFERENCES [dbo].[tblBlog] ([BlogId])
GO
ALTER TABLE [dbo].[tblRelatedBlogs] CHECK CONSTRAINT [FK_tblRelatedBlogs_tblBlog1]
GO
ALTER TABLE [dbo].[tblSubCategory]  WITH CHECK ADD FOREIGN KEY([CategoryId])
REFERENCES [dbo].[tblCategory] ([CategoryId])
GO
ALTER TABLE [dbo].[tblSubCategoryAnswer]  WITH CHECK ADD FOREIGN KEY([DigiPartnerProfileId])
REFERENCES [dbo].[tblDigiPartnerProfile] ([DigiPartnerProfileId])
GO
ALTER TABLE [dbo].[tblSubCategoryAnswer]  WITH CHECK ADD FOREIGN KEY([SubCategoryId])
REFERENCES [dbo].[tblSubCategory] ([SubCategoryId])
GO
ALTER TABLE [dbo].[tblSubCategoryChild]  WITH CHECK ADD FOREIGN KEY([SubCategoryId])
REFERENCES [dbo].[tblSubCategory] ([SubCategoryId])
GO
ALTER TABLE [dbo].[tblSubCategoryChildAnswer]  WITH CHECK ADD FOREIGN KEY([DigiPartnerProfileId])
REFERENCES [dbo].[tblDigiPartnerProfile] ([DigiPartnerProfileId])
GO
ALTER TABLE [dbo].[tblSubCategoryChildAnswer]  WITH CHECK ADD FOREIGN KEY([SubCategoryChildId])
REFERENCES [dbo].[tblSubCategoryChild] ([SubCategoryChildId])
GO
ALTER TABLE [dbo].[tblSuccessStory]  WITH CHECK ADD FOREIGN KEY([DigiPartnerProfileId])
REFERENCES [dbo].[tblDigiPartnerProfile] ([DigiPartnerProfileId])
GO
ALTER TABLE [dbo].[tblSuccessStoryComments]  WITH CHECK ADD FOREIGN KEY([CommentBy])
REFERENCES [dbo].[tblDigiPartnerProfile] ([DigiPartnerProfileId])
GO
ALTER TABLE [dbo].[tblSuccessStoryComments]  WITH CHECK ADD FOREIGN KEY([SuccessStoryId])
REFERENCES [dbo].[tblSuccessStory] ([SuccessStoryId])
GO
ALTER TABLE [dbo].[tblSurvey]  WITH CHECK ADD FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[tblMatchdigitalUser] ([UserId])
GO
ALTER TABLE [dbo].[tblSurvey]  WITH CHECK ADD FOREIGN KEY([ModifiedBy])
REFERENCES [dbo].[tblMatchdigitalUser] ([UserId])
GO
ALTER TABLE [dbo].[tblSurveyQuestionConfig]  WITH CHECK ADD FOREIGN KEY([ControlTypeId])
REFERENCES [dbo].[tblQuestionControlType] ([ControlTypeId])
GO
ALTER TABLE [dbo].[tblSurveyQuestionConfig]  WITH CHECK ADD FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[tblMatchdigitalUser] ([UserId])
GO
ALTER TABLE [dbo].[tblSurveyQuestionConfig]  WITH CHECK ADD FOREIGN KEY([PageId])
REFERENCES [dbo].[tblPage] ([PageId])
GO
ALTER TABLE [dbo].[tblSurveyQuestionConfig]  WITH CHECK ADD FOREIGN KEY([QuestionLabelId])
REFERENCES [dbo].[tblQuestion] ([QuestionLabelId])
GO
ALTER TABLE [dbo].[tblUserSurvey]  WITH CHECK ADD FOREIGN KEY([SurveyId])
REFERENCES [dbo].[tblSurvey] ([SurveyId])
GO
ALTER TABLE [dbo].[tblUserSurvey1]  WITH CHECK ADD FOREIGN KEY([SurveyId])
REFERENCES [dbo].[tblSurvey] ([SurveyId])
GO
ALTER TABLE [dbo].[tblUserSurveyPageAnswers]  WITH CHECK ADD FOREIGN KEY([PageId])
REFERENCES [dbo].[tblPage] ([PageId])
GO
ALTER TABLE [dbo].[tblUserSurveyPageAnswers]  WITH CHECK ADD FOREIGN KEY([UserSurveyId])
REFERENCES [dbo].[tblUserSurvey] ([UserSurveyId])
GO
/****** Object:  StoredProcedure [dbo].[spCreateBanner]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

   

CREATE procedure [dbo].[spCreateBanner](
@SortOrder int,
@HeaderBannerName varchar(200),
@Type int,
@PublisherId int,
@PublisherType int, 
@PublishDate  DateTime,
@BannerText varchar(200),
@BannerImageURL varchar(200),
@BannerLinkURL  varchar(200),
@BlogId int

)
as

BEGIN
 	
    BEGIN TRANSACTION; 
    BEGIN TRY
	declare @HeaderBannerId int; -- create header banner details
	insert into tblHeaderBanner (SortOrder,HeaderBannerName,Type,PublisherId,PublisherType,PublishDate,IsDeleted)
	values(@SortOrder,@HeaderBannerName,@Type,@PublisherId,@PublisherType,@PublishDate,0);
   	 set @HeaderBannerId=(select @@IDENTITY);
	 if(@BlogId > 0)  --  link banner and blog
	 begin
	 
	 insert into tblBannerBlogDetail(BlogId,HeaderBannerId)values(@BlogId,@HeaderBannerId);
	 end
	 else
	 begin  -- create header banner media content
	 insert into tblBannerDetail(BannerText,BannerImageURL,BannerLinkURL,HeaderBannerId)
	 values(@BannerText,@BannerImageURL,@BannerLinkURL,@HeaderBannerId);
	 end
   COMMIT TRANSACTION ;
		select 'Success' ErrorMessage; 
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION ;
			select ERROR_MESSAGE() AS ErrorMessage; 
        END
    END CATCH
END;
GO
/****** Object:  StoredProcedure [dbo].[spCreateBlog]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[spCreateBlog](      
@Title varchar(200),      
@BlogContent varchar(max),      
@PublisherName varchar(100),      
@BlogPublishDate datetime,      
@PublisherType int,      
@PublisherId int,      
@ApprovalStatus int,      
@BlogStatus bit,      
@MediaContent nvarchar(max),      
@Keyword nvarchar(max),      
@Classification varchar(max),      
@SecondaryClassification nvarchar(max),
@RelatedBlogs nvarchar(max)       
)      
AS      
 BEGIN      
   SET NOCOUNT ON
    SET XACT_ABORT ON
        
    BEGIN TRANSACTION;       
    BEGIN TRY      
       -- insert records in blog table
 INSERT INTO tblBlog (Title,BlogContent,PublisherName,BlogPublishDate,PublisherType,PublisherId,ApprovalStatus,BlogStatus,IsDeleted) VALUES       
      (@Title,@BlogContent,@PublisherName,@BlogPublishDate,@PublisherType,@PublisherId,@ApprovalStatus,@BlogStatus,0);      
  DECLARE @BLID INT;      
  SET @BLID = (select @@IDENTITY );   
  -- Create primary classification 
         if(@Classification != '')      
  BEGIN      
  INSERT INTO tblClassificationReferenceMaster(ClassificationRefId, ClassificationLevel, ModuleRefId, ModuleType, IsPrimary)      
  SELECT CategoryId,Level,@BLID,'tblBlog',1 FROM OPENJSON(@Classification)      
    WITH ([CategoryId] int,      
       [CategoryName]  nvarchar(100),      
       [Level] nvarchar(100),      
       [UID]  nvarchar(100))      
  END      
      -- Create secondary classification.It is may be multiple classification records.It is data should be json format  
       if(@SecondaryClassification != '')      
  BEGIN      
  INSERT INTO tblClassificationReferenceMaster(ClassificationRefId, ClassificationLevel, ModuleRefId, ModuleType, IsPrimary)      
  SELECT CategoryId,Level,@BLID,'tblBlog',0 FROM OPENJSON(@SecondaryClassification)      
    WITH ([CategoryId] int,      
       [CategoryName]  nvarchar(100),      
       [Level] nvarchar(100),      
       [UID]  nvarchar(100))      
  END      
      -- create mediacontent.It is may be multiple files.It is data should be json format
     if(@MediaContent != '')      
  BEGIN   
           INSERT INTO tblMediaContent (DocumentURL, DocumentType,ContentType,BlogId,IsDeleted)       
   SELECT DocumentURL,DocumentType,ContentType, @BLID, 0 FROM OPENJSON(@MediaContent)      
    WITH ([DocumentURL] varchar(500),      
       [DocumentType] int,      
       [ContentType] varchar(100),      
       [BlogId] int)      
    END
	 -- create Keywords
  if(@Keyword != '')  
  begin
  
 create table #tblKeywordsMaster ( Keyword varchar(100));      
 INSERT INTO #tblKeywordsMaster (Keyword) SELECT DISTINCT value FROM [dbo].[fnSplitString]( @Keyword );      
    -- if keyword not exist insert records in keyword master      
       
 INSERT tblKeywordsMaster(Keyword) SELECT DISTINCT Keyword FROM #tblKeywordsMaster cr       
 WHERE NOT EXISTS (SELECT Keyword FROM tblKeywordsMaster c      
 WHERE cr.Keyword = c.Keyword);       
      --   insert records in tblBlogKeywords  
 INSERT INTO tblBlogKeywords (BlogId, KeywordId) (SELECT @BLID,KeywordId FROM tblKeywordsMaster km INNER JOIN #tblKeywordsMaster tm      
   ON km.Keyword = tm.Keyword);   
   end;   
   -- create relatedblogs.It is may be more than one values separate with comma separator.
   if(@RelatedBlogs != '')      
  BEGIN   
  CREATE TABLE #tblRelatedBlogs (RelatedBlog nvarchar(max))  
  INSERT INTO #tblRelatedBlogs(RelatedBlog)  SELECT DISTINCT value FROM [dbo].[fnSplitString](@RelatedBlogs);   
  INSERT INTO tblRelatedBlogs(BlogId,RelatedBlogs) (SELECT @BLID,RelatedBlog FROM #tblRelatedBlogs);    
  END

   COMMIT TRANSACTION ;      
  select 'Success' ErrorMessage;       
    END TRY      
    BEGIN CATCH      
        IF @@TRANCOUNT > 0      
        BEGIN      
            ROLLBACK TRANSACTION ;      
   select ERROR_MESSAGE() AS ErrorMessage;       
        END      
    END CATCH      
END; 

GO
/****** Object:  StoredProcedure [dbo].[spCreateDigipartner]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE procedure [dbo].[spCreateDigipartner](
 @Email	varchar(50),
 @Password	varchar(50),
 @RoleId int
 ) 
  as  
    BEGIN
	Declare @DigiPartnerProfileId int;
	-- check email already exist in both tables tblKMUUser and tblDigiPartnerProfile.If Email not exist insert new record in tblDigiPartnerProfile 
 if ((select count(*) from  tblKMUUser where Email=@Email and IsDeleted=0)+ (select count(*) from  tblDigiPartnerProfile where Email=@Email and IsDeleted=0)) =0  
   begin
    insert into tblDigiPartnerProfile(Email,Password,CreatedDate,IsDeleted,IsActive,RoleId,Membership,IsPublic)
	values(@Email,@Password,getdate(),0,1,@RoleId,'BASE',0)
	set @DigiPartnerProfileId=(select @@IDENTITY)
	select DigiPartnerProfileId UserId,DigiPartnerProfileId,Email,rl.Name RoleName,rl.RoleId, 'DIGIPARTNER_USER' RoleType
	from tblDigiPartnerProfile pr inner join tblRole rl on rl.RoleId=pr.RoleId
	where DigiPartnerProfileId =@DigiPartnerProfileId; 
 
	end
	else
	begin
	 select 0 DigiPartnerProfileId;
	end
  END 
GO
/****** Object:  StoredProcedure [dbo].[spCreateKMUUser]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[spCreateKMUUser](  
 @Email varchar(50),  
 @Password varchar(50)  
 )   
  as    
    BEGIN  
   if ((select count(*) from  tblKMUUser where Email=@Email and IsDeleted=0)+ (select count(*) from  tblDigiPartnerProfile where Email=@Email and IsDeleted=0)) =0  
   begin  
    insert into tblKMUUser(Email,Password,CreatedDate,IsDeleted,RoleId)  
 values(@Email,@Password,getdate(),0,4)  
 select KMUUserId UserId,KMUUserId RespondentId,SurName,FirstName,Title,Salutation,Email,PhoneNumber,Position,CompanyName,StreetAndHouseNo,  
 PostalCode,Turnover,EmployeeCount,CreatedDate,UpdatedDate,'KMU_USER' RoleType,rl.Name RoleName,km.RoleId from tblKMUUser km
 inner join tblRole rl on rl.RoleId=km.RoleId where KMUUserId =(select @@IDENTITY)    
 end  
 else  
 begin  
  select 0 RespondentId;  
 end  
  END   

GO
/****** Object:  StoredProcedure [dbo].[spCreateProject]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spCreateProject]
(@CompanyName varchar(100), 
@Street varchar(50), 
@HouseNumber varchar(50), 
@PostalCode int,  
@City varchar(50), 
@Branch varchar(50), 
@ContactPersonName varchar(50), 
@ContactPersonPosition varchar(50), 
@ContactPersonMail varchar(50), 
@ContactPersonTelephone varchar(50), 
@CompanySize int,  
@ProjectTitle varchar(100), 
@ProjectDescription varchar(max), 
@ProjectExpectations varchar(max), 
@DigitalisationStatus varchar(max), 
@SoftwareInfrastructure varchar(max), 
@SoftwareVolume varchar(50), 
@ImplementationStart Date, 
@ImplementationEnd Date, 
@VendorSearch varchar(50),
@UserId varchar(max),
@KMUUserId varchar(max)
)
AS
	BEGIN

	   BEGIN TRANSACTION; 
    BEGIN TRY
	-- insert project details 
      INSERT INTO tblProjects (CompanyName, Street, HouseNumber, PostalCode, City, Branch, ContactPersonName, ContactPersonPosition,
		ContactPersonMail, ContactPersonTelephone, CompanySize, ProjectTitle, ProjectDescription, ProjectExpectations, DigitalisationStatus, 
		SoftwareInfrastructure, SoftwareVolume, ImplementationStart, ImplementationEnd, VendorSearch, CreatedDate,IsDeleted)
		VALUES 
		(@CompanyName, @Street, @HouseNumber, @PostalCode, @City, @Branch, @ContactPersonName, @ContactPersonPosition,
			@ContactPersonMail, @ContactPersonTelephone, @CompanySize, @ProjectTitle, @ProjectDescription, @ProjectExpectations, @DigitalisationStatus, 
			@SoftwareInfrastructure, @SoftwareVolume, @ImplementationStart, @ImplementationEnd, @VendorSearch, getdate(),0);

		DECLARE @ProjectId INT;
		SET @ProjectId = (SELECT @@IDENTITY AS 'Identity');  
		-- insert  Project owners in tblProjectOwner.It is may be KMUUser or Matchdigital User 
		 INSERT INTO tblProjectOwner (ProjectId, KMUUserId)SELECT DISTINCT @ProjectId, Value  FROM dbo.fnSplitComma( @KMUUserId );
		 INSERT INTO tblProjectOwner (ProjectId, UserId)SELECT DISTINCT @ProjectId, Value  FROM dbo.fnSplitComma(@UserId );
		  
		select 'Success' ErrorMessage, convert(varchar, CreatedDate, 23)CreatedDate from tblProjects where ProjectId=@ProjectId;    
   COMMIT TRANSACTION ;
	END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION ;
			select ERROR_MESSAGE() AS ErrorMessage; 
        END
    END CATCH
	 
		
	END 
GO
/****** Object:  StoredProcedure [dbo].[spDeleteBanner]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[spDeleteBanner](@HeaderBannerId int)
as
update tblHeaderBanner set IsDeleted=1 where HeaderBannerId=@HeaderBannerId;
GO
/****** Object:  StoredProcedure [dbo].[spDeleteBlog]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spDeleteBlog](@BlogId INT)
AS 
BEGIN
  UPDATE tblBlog SET IsDeleted = 1 WHERE BlogId = @BlogId; 

END;

 
GO
/****** Object:  StoredProcedure [dbo].[spDeleteClassification]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

  create procedure [dbo].[spDeleteClassification](@Id int)
  as 
  update  tblClassification set IsDeleted=1  where Id=@Id ;
GO
/****** Object:  StoredProcedure [dbo].[spDeleteDigiAndMDUser]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[spDeleteDigiAndMDUser](@UserId int,@RoleType varchar(50))  
as  
-- delete users based on RoleType
if @RoleType='DIGIPARTNER_USER'  
begin  
update tblDigiPartnerProfile set IsDeleted=1  
where DigiPartnerProfileId=@UserId;  
end   
else if @RoleType='ADMIN_USER'  
begin  
update tblMatchdigitalUser  set IsDeleted=1 where UserId=@UserId;
end
else if @RoleType='KMU_USER'
begin
update tblKMUUser set  IsDeleted=1 where KMUUserId=@UserId;
end 
GO
/****** Object:  StoredProcedure [dbo].[spDeleteDigipartner]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[spDeleteDigipartner](@DigiPartnerProfileId int)
  as 
  update  tblDigiPartnerProfile set IsDeleted=1  where DigiPartnerProfileId=@DigiPartnerProfileId; 
GO
/****** Object:  StoredProcedure [dbo].[spDeleteFiles]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[spDeleteFiles](@FileId int)
as
 update tblFiles set IsDeleted=1 from tblFiles where FileId=@FileId;
GO
/****** Object:  StoredProcedure [dbo].[spDeleteMatchdigitalUser]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

  create procedure [dbo].[spDeleteMatchdigitalUser](@UserId int)
  as 
  update  tblMatchdigitalUser set IsDeleted=1  where UserId=@UserId;
GO
/****** Object:  StoredProcedure [dbo].[spDeletePage]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

  create procedure [dbo].[spDeletePage](@PageId int)
  as 
  update  tblPage set IsDeleted=1  where PageId=@PageId;
GO
/****** Object:  StoredProcedure [dbo].[spDeleteProject]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[spDeleteProject](@ProjectId int)
as
update tblProjects set IsDeleted=1 where ProjectId=@ProjectId
 
GO
/****** Object:  StoredProcedure [dbo].[spDeleteQuestionCondition]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[spDeleteQuestionCondition](
 @QuestionConditionId	int
 )
 as
 delete from tblQuestionCondition where QuestionConditionId=@QuestionConditionId;
GO
/****** Object:  StoredProcedure [dbo].[spDeleteQuestionLabel]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[spDeleteQuestionLabel](
 @QuestionLabelId int
 )
 as
 update tblQuestion set IsDeleted=1 where QuestionLabelId=@QuestionLabelId;
GO
/****** Object:  StoredProcedure [dbo].[spDeleteSuccessStory]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

  create procedure [dbo].[spDeleteSuccessStory](
 @SuccessStoryId int
 )
 as
update tblSuccessStory set IsDeleted=1 where SuccessStoryId=@SuccessStoryId
GO
/****** Object:  StoredProcedure [dbo].[spDeleteSuccessStoryComments]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 

create procedure [dbo].[spDeleteSuccessStoryComments](
 @CommentId int
 )
 as
update tblSuccessStoryComments set IsDeleted=1 where CommentId=@CommentId
GO
/****** Object:  StoredProcedure [dbo].[spDeleteSurvey]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

  create procedure [dbo].[spDeleteSurvey](@SurveyId int)
  as 
  update  tblSurvey set IsDeleted=1  where SurveyId=@SurveyId;
GO
/****** Object:  StoredProcedure [dbo].[spDeleteSurveyQuestionConfig]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[spDeleteSurveyQuestionConfig](
 @QuestionId int
 )
 as
 update tblSurveyQuestionConfig set IsDeleted=1 where QuestionId=@QuestionId;
GO
/****** Object:  StoredProcedure [dbo].[spDigiPartnerLogin]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[spDigiPartnerLogin](@Email varchar(50),@Password varchar(50))  
  as   
  select DigiPartnerProfileId UserId,Email,us.RoleId RoleId,rl.Name as RoleName,'DIGIPARTNER_USER' RoleType from tblDigiPartnerProfile us   
  inner join tblRole rl on rl.RoleId=us.RoleId    
  where IsDeleted=0 and Email=@Email and    convert(varbinary, Password) = convert(varbinary, @Password) and IsActive=1;   
GO
/****** Object:  StoredProcedure [dbo].[spGetAllDigiMDUsers]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE  procedure [dbo].[spGetAllDigiMDUsers](@Count int, @Offset int,@Search NVARCHAR(max))
 as
 -- get all user details with search and pagination options
 if @Search=''
  begin
 select * from vwGetAllDigiMDUsers   
order by CreatedDate Desc OFFSET  @Count * @Offset ROWS
FETCH NEXT @Count  ROWS ONLY;
end
else
select * from vwGetAllDigiMDUsers   where Search  like '%' + @Search + '%' 
order by CreatedDate Desc OFFSET  @Count * @Offset ROWS
FETCH NEXT @Count  ROWS ONLY;
  
GO
/****** Object:  StoredProcedure [dbo].[spGetAllProjects]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spGetAllProjects]

AS
	BEGIN
	-- get all project with project owners.Project owner is return json format
SELECT p.ProjectId,CompanyName,Street,HouseNumber,PostalCode,City,Branch,ContactPersonName,ContactPersonPosition,ContactPersonMail,ContactPersonTelephone,
CompanySize,ProjectTitle,ProjectDescription,ProjectExpectations,DigitalisationStatus,SoftwareInfrastructure,SoftwareVolume,ImplementationStart,
ImplementationEnd,VendorSearch,CreatedDate,(select ProjectOwnertId,own.ProjectId,own.KMUUserId,own.UserId,km.FirstName KMUUserFirstName,
km.SurName KMUUserSurName,km.Email KMUUserEmail,mu.FirstName AdminUserFirstName,mu.LastName AdminUserLastName,mu.Email AdminUserEmail from tblProjectOwner own left join 
tblMatchdigitalUser mu on mu.UserId=own.UserId left join tblKMUUser km on km.KMUUserId=own.KMUUserId where own.ProjectId=p.ProjectId
for json path)ProjectOwner
FROM tblProjects p  
END 
GO
/****** Object:  StoredProcedure [dbo].[spGetBanner]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[spGetBanner](@Search nvarchar(max), @Count int, @Offset int)  
  as  
  -- get all banners with filter and search option 
  if @Search=''
  begin
 select * from vwGetBanner   
order by PublishDate Desc OFFSET  @Count * @Offset ROWS
FETCH NEXT @Count  ROWS ONLY;
 end
else
select * from vwGetBanner   where Search  like '%' + @Search + '%' 
order by PublishDate Desc OFFSET  @Count * @Offset ROWS
FETCH NEXT @Count  ROWS ONLY;
GO
/****** Object:  StoredProcedure [dbo].[spGetBannerById]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  procedure [dbo].[spGetBannerById](@HeaderBannerId int)    
as    
-- get Banner details based on BannerId  
select hb.HeaderBannerId,SortOrder,HeaderBannerName,Type,hb.PublisherId,hb.PublisherType,PublishDate,  
(case when Type=0 then BannerText else bl.BlogContent  end)  BannerText,  
-- select custom banner  
(case when Type=0 then BannerImageURL else (select TOP 1 DocumentURL FROM tblMediaContent where BlogId=bbd.BlogId and DocumentType=1 and IsDeleted=0  )  end)  BannerImageURL,  
BannerLinkURL,bbd.BlogId from tblHeaderBanner hb left join tblBannerDetail bd on bd.HeaderBannerId=hb.HeaderBannerId    
left join tblBannerBlogDetail bbd on  bbd.HeaderBannerId=hb.HeaderBannerId  
 left join tblBlog bl on bl.BlogId=bbd.BlogId    
where hb.HeaderBannerId=@HeaderBannerId  

GO
/****** Object:  StoredProcedure [dbo].[spGetBlog]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 CREATE procedure [dbo].[spGetBlog] ( @Count int, @Offset int,@Search NVARCHAR(max))
as  
-- select all Blog data with filter and pagination option 
if @Search=''
	begin
		select * from vwGetBlog   
		order by BlogPublishDate Desc OFFSET  @Count * @Offset ROWS
		FETCH NEXT @Count  ROWS ONLY;
	end
else
	select * from vwGetBlog where Search  like '%' + @Search + '%' 
	order by BlogPublishDate Desc OFFSET  @Count * @Offset ROWS
	FETCH NEXT @Count  ROWS ONLY;
GO
/****** Object:  StoredProcedure [dbo].[spGetBlogByID]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[spGetBlogByID] (@BlogId int)  
AS  
 BEGIN  
 -- select Blog details 
 SELECT BlogId, Title,BlogContent,PublisherName,BlogPublishDate,PublisherType,PublisherId,ApprovalStatus,BlogStatus,  
  Keyword = STUFF((  -- select Blog keywords based on BlogId 
   SELECT ',' + Keyword  
   FROM tblBlogKeywords bkey  
   INNER JOIN tblKeywordsMaster km  
    ON km.KeywordId=bkey.KeywordId  
      WHERE BL.BlogId=bkey.BlogId  
   FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, ''),  
     
    STUFF((SELECT ',' +(CASE    -- select Blog Primary classification based on BlogId 
    WHEN  ClassificationLevel ='Category' THEN c.UID  
    WHEN ClassificationLevel = 'SubCategory' THEN sc.UID  
 WHEN ClassificationLevel = 'SubCategoryChild' THEN scc.UID  
 END)  FROM tblClassificationReferenceMaster crm  
   LEFT OUTER JOIN tblCategory c on c.CategoryId = crm.ClassificationRefId and crm.ClassificationLevel ='Category'  
   LEFT OUTER JOIN tblSubCategory sc on sc.SubCategoryId = crm.ClassificationRefId and crm.ClassificationLevel ='SubCategory'  
   LEFT OUTER JOIN tblSubCategoryChild scc on scc.SubCategoryChildId = crm.ClassificationRefId and crm.ClassificationLevel ='SubCategoryChild'  
   where crm.ModuleRefId = bl.BlogId and IsPrimary = 1  
   FOR XML PATH (''))  
          , 1, 1, '')  AS Classification,  
     STUFF((SELECT ',' +(CASE    -- select Blog secondary classification based on BlogId 
    WHEN  ClassificationLevel ='Category' THEN c.UID  
    WHEN ClassificationLevel = 'SubCategory' THEN sc.UID  
 WHEN ClassificationLevel = 'SubCategoryChild' THEN scc.UID  
 END)  FROM tblClassificationReferenceMaster crm  
   LEFT OUTER JOIN tblCategory c on c.CategoryId = crm.ClassificationRefId and crm.ClassificationLevel ='Category'  
   LEFT OUTER JOIN tblSubCategory sc on sc.SubCategoryId = crm.ClassificationRefId and crm.ClassificationLevel ='SubCategory'  
   LEFT OUTER JOIN tblSubCategoryChild scc on scc.SubCategoryChildId = crm.ClassificationRefId and crm.ClassificationLevel ='SubCategoryChild'  
   where crm.ModuleRefId = bl.BlogId and IsPrimary = 0  
   FOR XML PATH (''))  
          , 1, 1, '')  AS SecondaryClassification,  
    -- select Blog RelatedBlogs based on BlogId 
     STUFF((SELECT ',' + CAST(RelatedBlogs AS nvarchar(10)) FROM [dbo].[tblRelatedBlogs] rb  
   where rb.BlogId = bl.BlogId  
   FOR XML PATH (''))  
          , 1, 1, '')  AS RelatedBlogs  
  
      
    FROM tblBlog BL  where BL.BlogId= @BlogId;

   -- select Blog mediacontent based on BlogId 
  SELECT MediaContentId, DocumentURL,DocumentType,ContentType  
   FROM tblMediaContent WHERE BlogId=@BlogId and IsDeleted=0;  
 END  
    
GO
/****** Object:  StoredProcedure [dbo].[spGetBlogByKeywords]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[spGetBlogByKeywords] ( @Count int, @Offset int,@KeywordId int)  
as
-- get all blogs based on keywordId
 select b.Title, b.BlogContent, MU.FirstName + ' '+ MU.LastName PublisherName, BlogPublishDate, b.PublisherType, b.PublisherId, b.ApprovalStatus, b.BlogStatus, 
(select DocumentURL,DocumentType,ContentType from tblMediaContent mc where mc.BlogId = b.BlogId and IsDeleted=0 for json path) as MediaContent,   
Keyword,bk.KeywordId from tblBlog b inner join tblBlogKeywords bk on bk.BlogId=b.BlogId
inner join tblKeywordsMaster km on km.KeywordId=bk.KeywordId 
left join tblMatchdigitalUser mu on mu.UserId=b.PublisherId
where bk.KeywordId=@KeywordId and b.IsDeleted=0
order by BlogPublishDate Desc OFFSET  @Count * @Offset ROWS  
FETCH NEXT @Count  ROWS ONLY; 
GO
/****** Object:  StoredProcedure [dbo].[spGetBlogCategoryWise]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE  PROCEDURE [dbo].[spGetBlogCategoryWise] (@Count int,@Offset int,@ClassificationLevel VARCHAR(100),@ClassificationRefId int)AS  
 BEGIN   
 -- get all blogs based on Classification  
 SELECT B.BlogId, B.Title, B.BlogContent, (MU.FirstName + ' ' + MU.LastName)PublisherName, BlogPublishDate, B.PublisherType  
    ,Keyword = STUFF (( SELECT ',' + Keyword FROM tblKeywordsMaster km  -- get keywords  
     INNER JOIN tblBlogKeywords bkey ON km.KeywordId=bkey.KeywordId and bkey.BlogId = CM.ModuleRefId   
      FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, '')  
  
    ,(MU.FirstName + ' ' + MU.LastName) AS 'UserName'  
      
    ,(select MC.DocumentURL,MC.DocumentType,MC.ContentType from tblMediaContent MC INNER JOIN tblBlog B ON MC.BlogId= B.BlogId  
      where  MC.IsDeleted = 0 and MC.BlogId  =CM.ModuleRefId for json path ) as 'MediaContent' -- get Mediacontent   
  
    from tblBlog B inner join tblClassificationReferenceMaster CM on b.BlogId = CM.ModuleRefId      
    inner join tblMatchdigitalUser MU ON B.PublisherId = MU.UserId         
   where CM.ModuleType = 'tblBlog' and CM. ClassificationLevel =@ClassificationLevel and   
   ClassificationRefId=@ClassificationRefId and b.IsDeleted=0  
   order by B.BlogPublishDate Desc OFFSET  @Count * @Offset ROWS  
    FETCH NEXT @Count  ROWS ONLY;   
  
END  
GO
/****** Object:  StoredProcedure [dbo].[spGetBlogComments]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 

 CREATE  PROCEDURE [dbo].[spGetBlogComments] (@BlogId int)  
AS  
 BEGIN    
 -- get blog Primary and secondary classification,Keywords,Relatedblogs,Mediacontent and Blog comments based on BlogId  
   SELECT B.BlogId, B.Title, B.BlogContent, MU.FirstName + ' '+ MU.LastName PublisherName, BlogPublishDate, B.PublisherType,  
     STUFF((SELECT ',' +(CASE   -- select Primary classification   
    WHEN  ClassificationLevel ='Category' THEN CategoryName    
    WHEN ClassificationLevel = 'SubCategory' THEN SubCategoryName    
    WHEN ClassificationLevel = 'SubCategoryChild' THEN ChildName    
 END)  FROM tblClassificationReferenceMaster crm    
   LEFT OUTER JOIN tblCategory c on c.CategoryId = crm.ClassificationRefId and crm.ClassificationLevel ='Category'    
   LEFT OUTER JOIN tblSubCategory sc on sc.SubCategoryId = crm.ClassificationRefId and crm.ClassificationLevel ='SubCategory'    
   LEFT OUTER JOIN tblSubCategoryChild scc on scc.SubCategoryChildId = crm.ClassificationRefId and crm.ClassificationLevel ='SubCategoryChild'    
   where crm.ModuleRefId = B.BlogId and IsPrimary = 1    
   FOR XML PATH (''))    
          , 1, 1, '')  AS Classification,    
    
    STUFF((SELECT ',' +(CASE  -- select secondary classification   
    WHEN  ClassificationLevel ='Category' THEN CategoryName    
    WHEN ClassificationLevel = 'SubCategory' THEN SubCategoryName    
 WHEN ClassificationLevel = 'SubCategoryChild' THEN ChildName    
 END)  FROM tblClassificationReferenceMaster crm    
   LEFT OUTER JOIN tblCategory c on c.CategoryId = crm.ClassificationRefId and crm.ClassificationLevel ='Category'    
   LEFT OUTER JOIN tblSubCategory sc on sc.SubCategoryId = crm.ClassificationRefId and crm.ClassificationLevel ='SubCategory'    
   LEFT OUTER JOIN tblSubCategoryChild scc on scc.SubCategoryChildId = crm.ClassificationRefId and crm.ClassificationLevel ='SubCategoryChild'    
   where crm.ModuleRefId = B.BlogId and IsPrimary = 0    
   FOR XML PATH (''))    
          , 1, 1, '')  AS SecondaryClassification  
   
    ,Keyword = STUFF (( SELECT ',' + Keyword FROM tblKeywordsMaster km   -- select keywords  
     INNER JOIN tblBlogKeywords bkey ON km.KeywordId=bkey.KeywordId    
      FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, '')  
    ,(select MC.DocumentURL,MC.DocumentType,MC.ContentType from tblMediaContent MC INNER JOIN tblBlog B ON MC.BlogId= B.BlogId -- select MediaContent  
      where  MC.IsDeleted = 0 and MC.BlogId  =@BlogId for json path ) as 'MediaContent'      
     ,(select BC.CommentId, BC.Comment, BC.CommentTime, BC.ParentId  
     , (SELECT   
         (CASE WHEN tbc.UserType = 1 THEN MU.FirstName + ' '+ MU.LastName   
          WHEN tbc.UserType = 2 THEN KMU.FirstName + ' '+ KMU.SurName   
          WHEN tbc.UserType = 3 THEN DP.ContactPersonFirstName + ' '+ DP.ContactPersonLastName      
          WHEN tbc.UserType = 4 THEN 'Guest' END) FROM tblBlogComment tbc   
        left outer join tblKMUUser KMU ON KMU.KMUUserId = tbc.UserId and tbc.UserType = 2  
        left outer join tblDigiPartnerProfile DP ON DP.DigiPartnerProfileId = tbc.UserId and tbc.UserType = 3  
        left outer join tblMatchdigitalUser MU ON MU.UserId = tbc.UserId and tbc.UserType = 1  
        where tbc.BlogId =  @BlogId and tbc.CommentId = bc.CommentId)  as 'UserName'  
  
       from tblBlog B INNER JOIN tblBlogComment BC ON BC.BlogId= B.BlogId   
       where  BC.IsVisible = 1 and BC.BlogId =@BlogId for json path ) as 'Comments'  -- select comments   
  
    from tblBlog B       
    left join tblMatchdigitalUser MU ON B.PublisherId = MU.UserId         
   where BlogId = @BlogId;  
   
   -- get related blogs 
   select b.BlogId, b.Title, b.BlogContent, MU.FirstName + ' '+ MU.LastName PublisherName,BlogPublishDate, b.PublisherType, b.PublisherId, b.ApprovalStatus, b.BlogStatus,   
     (select DocumentURL,DocumentType,ContentType from tblMediaContent mc where mc.BlogId = b.BlogId and IsDeleted=0 for json path) as MediaContent,     
    (select stuff((select ',' + km.Keyword from tblKeywordsMaster km     
     inner join tblBlogKeywords bk on bk.KeywordId = km.KeywordId where bk.BlogId = b.BlogId for xml path('')),1,1,'')) As keywords,
	 (select count(*) from tblBlogComment where BlogId=b.BlogId) CommentsCount
     from tblBlog b  inner join tblRelatedBlogs rb on rb.RelatedBlogs=b.BlogId
	 left join tblMatchdigitalUser MU ON B.PublisherId = MU.UserId         
	 where rb.BlogId=@BlogId  
  
END  
GO
/****** Object:  StoredProcedure [dbo].[spGetCatClassification]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 

 CREATE procedure [dbo].[spGetCatClassification]
as
-- get all classification category and subcategory and SubCategoryChild
select CategoryId, CategoryName,'Category'Level,UID from tblCategory
union all 
select SubCategoryId CategoryId,SubCategoryName CategoryName,'SubCategory' Level,UID  from tblSubCategory
union all 
select SubCategoryChildId CategoryId,ChildName CategoryName,'SubCategoryChild' Level,UID from tblSubCategoryChild
GO
/****** Object:  StoredProcedure [dbo].[spGetCategoryList]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE procedure [dbo].[spGetCategoryList]
 as
  -- select classification object in nested format category-->subcategory-->subcategorychild 
Select (select cat.CategoryId,CategoryName,CategoryLevelQuestion,SortOrder,DisplayIcon,cat.UID UID,CategoryType,
(select su.SubCategoryId,SubCategoryName,ControlType,IsTextBoxEnabled,ColorCode,su.UID UID,AliasName,
(select SubCategoryChildId,ChildName,chl.UID UID from tblSubCategoryChild chl 
where su.SubCategoryId=chl.SubCategoryId for json Path )as SubCategoryChild
from tblSubCategory su
where su.CategoryId=cat.CategoryId FOR JSON PATH)as Subcategory
from tblCategory cat for json Path) Category 

GO
/****** Object:  StoredProcedure [dbo].[spGetCategoryWiseBlog]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spGetCategoryWiseBlog]
AS
	BEGIN		
	-- get all blog linked classification  
		select (case 
		  when ClassificationLevel='SubCategory' then su.SubCategoryName
		  when ClassificationLevel='Category' then ca.CategoryName 
		  when ClassificationLevel='SubCategoryChild' then ch.ChildName
		  end) AS 'CategoryName',ClassificationLevel,ClassificationRefId,
		  Count(*)
 AS 'BlockCount' from tblClassificationReferenceMaster cr
		  inner join tblBlog bl on bl.BlogId=cr.ModuleRefId
		  left join tblSubCategory su on su.SubCategoryId =cr.ClassificationRefId
		  left join tblCategory ca on ca.CategoryId =cr.ClassificationRefId
		  left join tblSubCategoryChild ch on ch.SubCategoryChildId =cr.ClassificationRefId where ModuleType='tblBlog' and bl.IsDeleted=0
		  group by SubCategoryName,ClassificationLevel,CategoryName,ChildName,ClassificationRefId ;

		  -- get all blog linked Keywords 
		  select distinct bk.KeywordId,Keyword from tblBlogKeywords bk inner join  
          tblKeywordsMaster km on km.KeywordId=bk.KeywordId
		   inner join tblBlog bl on bl.BlogId=bk.BlogId where bl.IsDeleted=0
		
	END;
GO
/****** Object:  StoredProcedure [dbo].[spGetClassification]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

  create procedure [dbo].[spGetClassification]
  as 
  select * from tblClassification where IsDeleted=0;
GO
/****** Object:  StoredProcedure [dbo].[spGetClassificationById]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

  create procedure [dbo].[spGetClassificationById](@Id int)
  as 
  select * from tblClassification where Id=@Id and IsDeleted=0;
GO
/****** Object:  StoredProcedure [dbo].[spGetComments]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 

 CREATE procedure [dbo].[spGetComments] ( @Count int, @Offset int,@Search NVARCHAR(max))
  as
  -- get all comments with search and filter option 
  if @Search=''
  begin
 select * from vwGetComments   
order by [CommentTime] Desc OFFSET  @Count * @Offset ROWS
FETCH NEXT @Count  ROWS ONLY;
end
else
select * from vwGetComments   where Search  like '%' + @Search + '%' 
order by [CommentTime] Desc OFFSET  @Count * @Offset ROWS
FETCH NEXT @Count  ROWS ONLY;
GO
/****** Object:  StoredProcedure [dbo].[spGetDigipartnerProfileById]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE procedure  [dbo].[spGetDigipartnerProfileById](  
@DigiPartnerProfileId int  
)  
as  

-- get digipartner profile personal data and  answers in nested format(Category-->Subcategory-->SubcategoryChild).
select * from vwspGetDigipartners where DigiPartnerProfileId=@DigiPartnerProfileId;

-- get company and product files
select FileId,FilePath,fs.FileTypeId,ft.FileType from tblFiles fs  
inner join tblDigiPartnerProfile pf on pf.DigiPartnerProfileId=fs.FileReferenceId  
inner join tblFileType ft on ft.FileTypeId=fs.FileTypeId  
where fs.IsDeleted=0 and pf.IsDeleted=0 and pf.RoleId=3 and pf.DigiPartnerProfileId=@DigiPartnerProfileId;  
  
-- get Success Story  
select SuccessStoryId,ss.DigiPartnerProfileId,StoryContent,Title,SuccessStoryImage,Tag,Status,ss.CreatedDate,  
SuccessStoryPDF,ss.Email, (case 
		  when ClassificationLevel='SubCategory' then su.SubCategoryName
		  when ClassificationLevel='Category' then ca.CategoryName 
		  when ClassificationLevel='SubCategoryChild' then ch.ChildName
		  end)  Classification from tblSuccessStory ss   
inner join tblDigiPartnerProfile pf on pf.DigiPartnerProfileId=ss.DigiPartnerProfileId  
 inner join tblClassificationReferenceMaster rfm on rfm.ModuleRefId=ss.SuccessStoryId
 left join tblSubCategory su on su.SubCategoryId=rfm.ClassificationRefId
 left join tblCategory ca on ca.CategoryId=rfm.ClassificationRefId
 left join tblSubCategoryChild ch  on ch.SubCategoryChildId=rfm.ClassificationRefId 
where ss.IsDeleted=0 and pf.IsDeleted=0  and pf.DigiPartnerProfileId=@DigiPartnerProfileId and   ModuleType='tblSuccessStory';  
GO
/****** Object:  StoredProcedure [dbo].[spGetDigipartners]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
 
 CREATE  procedure [dbo].[spGetDigipartners]( @Count int, @Offset int,@Search NVARCHAR(max))  
  as  
  -- select Digipartner list with pagination 
 if @Search=''  
  begin  
 select * from vwspGetDigipartners     
order by CreatedDate Desc OFFSET  @Count * @Offset ROWS  
FETCH NEXT @Count  ROWS ONLY;  
select Count(*)TotalCount from vwspGetDigipartners;     
  
 end  
else  
begin  
select * from vwspGetDigipartners   where Search  like '%' + @Search + '%'   
order by CreatedDate Desc OFFSET  @Count * @Offset ROWS  
FETCH NEXT @Count  ROWS ONLY;  
select Count(*)TotalCount from vwspGetDigipartners   where Search  like '%' + @Search + '%'   
end  
 select ChildName from tblSubCategoryChild ch inner join tblSubCategoryChildAnswer ans   
  on ch.SubCategoryChildId=ans.SubCategoryChildId   
  inner join tblDigiPartnerProfile p on p.DigiPartnerProfileId = ans.DigiPartnerProfileId  
  where p.IsDeleted = 0  
  group by ChildName;
  
GO
/****** Object:  StoredProcedure [dbo].[spGetKMUUserById]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
 CREATE procedure [dbo].[spGetKMUUserById](@KMUUserId int)
  as 
  select KMUUserId UserId,SurName,FirstName,Title,Salutation,Email,PhoneNumber,Position,CompanyName,StreetAndHouseNo,
  PostalCode,Turnover,EmployeeCount,CreatedDate,UpdatedDate,'KMU_USER' RoleType,rl.Name RoleName,km.RoleId,Country  from tblKMUUser km
  inner join tblRole rl on rl.RoleId=km.RoleId
  where KMUUserId=@KMUUserId and IsDeleted=0;

GO
/****** Object:  StoredProcedure [dbo].[spGetMatchdigitalUser]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

  CREATE procedure [dbo].[spGetMatchdigitalUser]
  as
  -- Procedure used to get all matchdigial users 
  select UserId,FirstName,LastName,Address,ContactNumber,Email,Password,us.RoleId RoleId,rl.Name as RoleName,CreatedBy,CreatedDate,
  ModifiedBy,ModifiedDate,PasswordUpdatedDate,IsActive from tblMatchdigitalUser us 
  inner join tblRole rl on rl.RoleId=us.RoleId  
  where IsDeleted=0 
GO
/****** Object:  StoredProcedure [dbo].[spGetMatchdigitalUserById]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

  create procedure [dbo].[spGetMatchdigitalUserById](@UserId int)
  as 
  select * from tblMatchdigitalUser where UserId=@UserId and IsDeleted=0;
GO
/****** Object:  StoredProcedure [dbo].[spGetPage]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

   
  CREATE procedure [dbo].[spGetPage] 
  as  
  -- Get all records from tblpage
  select PageId,Title,PageLevelQuestion,SurveyId,SortOrder,pg.CreatedDate,pg.ModifiedDate,pg.CreatedBy,pg.ModifiedBy, 
  pg.IsActive,CONCAT( us.FirstName,' ',us.LastName) CreatedName from tblPage pg left join tblMatchdigitalUser us
  on us.UserId=pg.CreatedBy 
  where pg.IsDeleted=0;
GO
/****** Object:  StoredProcedure [dbo].[spGetPageById]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


  create procedure [dbo].[spGetPageById](@PageId int)
  as 
  select * from tblPage where PageId=@PageId and IsDeleted=0;
GO
/****** Object:  StoredProcedure [dbo].[spGetPopularPost]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


 CREATE procedure [dbo].[spGetPopularPost] ( @Count int, @Offset int)    
	 as      
	 begin  
	 -- get all popular blogs based on blog comments
	 select b.BlogId, b.Title, b.BlogContent, MU.FirstName + ' '+ MU.LastName PublisherName, BlogPublishDate, b.PublisherType, b.PublisherId, b.ApprovalStatus, b.BlogStatus, 
	 (select DocumentURL,DocumentType,ContentType from tblMediaContent mc where mc.BlogId = b.BlogId and IsDeleted=0 for json path) as MediaContent,
	 (select stuff((select ',' + km.Keyword from tblKeywordsMaster km    inner join tblBlogKeywords bk on bk.KeywordId = km.KeywordId where bk.BlogId = b.BlogId for xml path('')),1,1,'')) As keywords, 
	 (select count(*) from tblBlogComment where BlogId=b.BlogId) CommentsCount from tblBlog b 
	 left join tblMatchdigitalUser mu on mu.UserId=b.PublisherId
	 where b.IsDeleted=0 
	 order by CommentsCount Desc OFFSET  @Count * @Offset ROWS   FETCH NEXT @Count  ROWS ONLY;     
end 
GO
/****** Object:  StoredProcedure [dbo].[spGetProfileDetailsbyId]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[spGetProfileDetailsbyId](@DigiPartnerProfileId int)
as
select * from vwspGetDigipartners where DigiPartnerProfileId=@DigiPartnerProfileId;

GO
/****** Object:  StoredProcedure [dbo].[spGetProjectById]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

  CREATE procedure [dbo].[spGetProjectById](@ProjectId INT)
 as 
 	-- get project with project owners based on ProjectId.
 select ProjectId,CompanyName,Street,HouseNumber,PostalCode,City,Branch,ContactPersonName,ContactPersonPosition,ContactPersonMail,ContactPersonTelephone,
CompanySize,ProjectTitle,ProjectDescription,ProjectExpectations,DigitalisationStatus,SoftwareInfrastructure,SoftwareVolume,ImplementationStart,
ImplementationEnd,VendorSearch,CreatedDate,
STUFF(( SELECT ',' + CAST(UserId AS nvarchar(10))  FROM tblProjectOwner own  INNER JOIN tblProjects pr  ON pr.ProjectId=own.ProjectId WHERE own.ProjectId=@ProjectId
 and UserId is not null  FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, '')UserId,
STUFF(( SELECT ',' + CAST(KMUUserId AS nvarchar(10))  FROM tblProjectOwner own  INNER JOIN tblProjects pr  ON pr.ProjectId=own.ProjectId WHERE own.ProjectId=@ProjectId
 and KMUUserId is not null  FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, '')KMUUserId
 from tblProjects  where ProjectId=@ProjectId

GO
/****** Object:  StoredProcedure [dbo].[spGetProjects]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
  

create PROCEDURE [dbo].[spGetProjects] (@ProjectId INT)

AS
	BEGIN
		SELECT  
			P.[ProjectId],
			P.[CompanyName],
			P.[Street],
			P.[HouseNumber],
			P.[PostalCode],
			P.[City],
			P.[Branch],
			P.[ContactPersonName],
			P.[ContactPersonPosition],
			P.[ContactPersonMail],
			P.[ContactPersonTelephone],
			P.[CompanySize],
			P.[ProjectTitle],
			P.[ProjectDescription],
			P.[ProjectExpectations],
			P.[DigitalisationStatus],
			P.[SoftwareInfrastructure],
			P.[SoftwareVolume],
			P.[ImplementationStart],
			P.[ImplementationEnd],
			P.[VendorSearch],
			P.[CreatedDate],
			O.[ProjectOwnertId]
			
			
	  FROM tblProjects P	   
	  INNER JOIN tblProjectOwner O ON P.ProjectId = O.ProjectId where p.ProjectId=@ProjectId;

	END


GO
/****** Object:  StoredProcedure [dbo].[spGetQuestionControlType]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 create procedure [dbo].[spGetQuestionControlType]
 as
 select * from tblQuestionControlType;
GO
/****** Object:  StoredProcedure [dbo].[spGetQuestionLabel]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[spGetQuestionLabel](@Search nvarchar(max))
 as
 -- select All questions label with search option 
 select qu.QuestionLabelId,QuestionText,qu.CreatedBy,qu.CreatedDate,
   CONCAT( mu.FirstName,' ',mu.LastName) CreatedName,qu.ModifiedBy,qu.ModifiedDate
   ,qu.IsActive  from tblQuestion qu inner join tblMatchdigitalUser mu  on qu.CreatedBy=mu.UserId
   where  qu.IsDeleted=0 and QuestionText  like '%' + @Search + '%' ;

GO
/****** Object:  StoredProcedure [dbo].[spGetQuestionLabelById]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 create procedure [dbo].[spGetQuestionLabelById](
 @QuestionLabelId int
 )
 as
   select  * from  tblQuestion
   where QuestionLabelId=@QuestionLabelId and IsDeleted=0;
GO
/****** Object:  StoredProcedure [dbo].[spGetRecentBlog]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[spGetRecentBlog] ( @Count int, @Offset int,@Search NVARCHAR(max))
as 
 -- Get all recent blogs with  filter and pagination 
if @Search=''
	begin
		select * from vwGetRecentBlogs   
		order by BlogPublishDate Desc OFFSET  @Count * @Offset ROWS
		FETCH NEXT @Count  ROWS ONLY;
	end
else
	select * from vwGetRecentBlogs where Search  like '%' + @Search + '%' 
	order by BlogPublishDate Desc OFFSET  @Count * @Offset ROWS
	FETCH NEXT @Count  ROWS ONLY;
GO
/****** Object:  StoredProcedure [dbo].[spGetRole]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

  -- Role
  create procedure [dbo].[spGetRole]
  as 
  select * from tblRole;
GO
/****** Object:  StoredProcedure [dbo].[spGetSuccessStory]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  procedure [dbo].[spGetSuccessStory](@Count int, @Offset int,@Search NVARCHAR(max))
 as
-- get all success story with filter and pagination 

 if @Search=''
  begin
 select * from vwGetSuccessStory   
order by CreatedDate Desc OFFSET  @Count * @Offset ROWS
FETCH NEXT @Count  ROWS ONLY;
end
else
select * from vwGetSuccessStory   where Search  like '%' + @Search + '%' 
order by CreatedDate Desc OFFSET  @Count * @Offset ROWS
FETCH NEXT @Count  ROWS ONLY;
  
GO
/****** Object:  StoredProcedure [dbo].[spGetSuccessStoryById]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

  
 CREATE procedure [dbo].[spGetSuccessStoryById](
 @SuccessStoryId int
 )
 as
   select SuccessStoryId,DigiPartnerProfileId,StoryContent,Title,SuccessStoryImage,Tag,Status,
   SuccessStoryPDF,Email,(case  -- get success story classification level 
		  when ClassificationLevel='SubCategory' then concat('cat_',ClassificationRefId)
		  when ClassificationLevel='Category' then concat('sub_',ClassificationRefId)
		  when ClassificationLevel='SubCategoryChild' then concat('chl_',ClassificationRefId)
		  end)  ClassificationId from  tblSuccessStory ss
 inner join tblClassificationReferenceMaster rfm on rfm.ModuleRefId=ss.SuccessStoryId
 left join tblSubCategory su on su.SubCategoryId=rfm.ClassificationRefId
 left join tblCategory ca on ca.CategoryId=rfm.ClassificationRefId
 left join tblSubCategoryChild ch  on ch.SubCategoryChildId=rfm.ClassificationRefId where ModuleType='tblSuccessStory'
and  SuccessStoryId=@SuccessStoryId;
GO
/****** Object:  StoredProcedure [dbo].[spGetSuccessStoryComments]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 

  CREATE procedure [dbo].[spGetSuccessStoryComments] 
 as
 -- get all success story comments 
  select st.SuccessStoryId, CommentBy,CompanyName,CommentId,StoryContent,Title,SuccessStoryImage,Tag,Status,AnswerDate,Description
 from  tblSuccessStory st inner join tblSuccessStoryComments sc on st.SuccessStoryId=sc.SuccessStoryId
 inner join tblDigiPartnerProfile dp on dp.DigiPartnerProfileId=sc.CommentBy  
 where sc.IsDeleted=0 and st.IsDeleted=0;
GO
/****** Object:  StoredProcedure [dbo].[spGetSuccessStoryCommentsById]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 create procedure [dbo].[spGetSuccessStoryCommentsById](
 @CommentId int
 )
 as
   select * from  tblSuccessStoryComments  where CommentId=@CommentId and IsDeleted=0;
GO
/****** Object:  StoredProcedure [dbo].[spGetSuccessStoryWithCommands]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
  CREATE procedure [dbo].[spGetSuccessStoryWithCommands] 
 as
 -- Get all SuccessStory
 select SuccessStoryId,CompanyName,StoryContent,Title,SuccessStoryImage,Tag,Status,st.CreatedDate,SuccessStoryPDF
 from  tblSuccessStory st 
 inner join tblDigiPartnerProfile dp on dp.DigiPartnerProfileId=st.DigiPartnerProfileId
 where  st.IsDeleted=0;

  -- Get all SuccessStory comments
 select sc.SuccessStoryId,CompanyName,CommentId,CommentBy,Description,AnswerDate
 from  tblSuccessStoryComments sc inner join tblSuccessStory ss on ss.SuccessStoryId=sc.SuccessStoryId
 inner join tblDigiPartnerProfile dp on dp.DigiPartnerProfileId=sc.CommentBy
 where  sc.IsDeleted=0 and ss.IsDeleted=0;

  
GO
/****** Object:  StoredProcedure [dbo].[spGetSuccessStoryWithCommandsById]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 CREATE procedure [dbo].[spGetSuccessStoryWithCommandsById](@SuccessStoryId int)
 as
 -- get success story based on SuccessStoryId
  select SuccessStoryId,CompanyName,StoryContent,Title,SuccessStoryImage,Tag,Status,st.CreatedDate,SuccessStoryPDF
 from  tblSuccessStory st 
 inner join tblDigiPartnerProfile dp on dp.DigiPartnerProfileId=st.DigiPartnerProfileId
 where  st.IsDeleted=0 and SuccessStoryId=@SuccessStoryId;

 -- get success story comments based on SuccessStoryId
  select sc.SuccessStoryId,CompanyName,CommentId,CommentBy,Description,AnswerDate
 from  tblSuccessStoryComments sc inner join tblSuccessStory ss on ss.SuccessStoryId=sc.SuccessStoryId
 inner join tblDigiPartnerProfile dp on dp.DigiPartnerProfileId=sc.CommentBy
 where  sc.IsDeleted=0 and ss.IsDeleted=0 and ss.SuccessStoryId=@SuccessStoryId;
GO
/****** Object:  StoredProcedure [dbo].[spGetSurvey]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 

  CREATE procedure [dbo].[spGetSurvey] ( @Count int, @Offset int,@Search NVARCHAR(max))
  as  
  -- get all survey records with search and pagination
  if @Search=''
  begin
 select * from vwGetSurvey   
order by CreatedDate Desc OFFSET  @Count * @Offset ROWS
FETCH NEXT @Count  ROWS ONLY;
end
else
select * from vwGetSurvey   where Search  like '%' + @Search + '%' 
order by CreatedDate Desc OFFSET  @Count * @Offset ROWS
FETCH NEXT @Count  ROWS ONLY;
GO
/****** Object:  StoredProcedure [dbo].[spGetSurveyAnswerBySurveyId]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

  CREATE procedure [dbo].[spGetSurveyAnswerBySurveyId](@SurveyId int ,@RespondentId int)      
 as      
 -- get KMUUser details and survey details   
 
 select UserSurveyId,RespondentId,SurveyId,IsSurveyCompleted,SurveyModifiedDate,SurveyReport,FollowUpMailContent, KMUUserId,SurName,FirstName,Title,Salutation,    
 Email,PhoneNumber,Position,CompanyName,StreetAndHouseNo,PostalCode,Turnover,EmployeeCount,CreatedDate,UpdatedDate ,GraphValues,Country  
 from tblUserSurvey us    
 inner join tblKMUUser km on km.KMUUserId=us.RespondentId    
 where RespondentId=@RespondentId and SurveyId=@SurveyId; 
 
 --select KMUUserId RespondentId,@SurveyId SurveyId, KMUUserId,SurName,FirstName,Title,Salutation,      
 --Email,PhoneNumber,Position,CompanyName,StreetAndHouseNo,PostalCode,Turnover,EmployeeCount,CreatedDate,UpdatedDate ,Country    
 --from tblKMUUser us  where KMUUserId=@RespondentId    
     
  -- get user page answers based on surveyId   
 select UserSurveyAnswerId,us.UserSurveyId,sp.PageId,Answer, p.SortOrder from tblUserSurveyPageAnswers sp       
 inner join tblUserSurvey us on us.UserSurveyId=sp.UserSurveyId      
 inner join tblPage p on p.PageId = sp.PageId    
 where us.RespondentId=@RespondentId and us.SurveyId=@SurveyId;     
     
  -- get Survey object  
 select SurveyId,SurveyTitle,Description,EmailTemplate,SurveyType,sv.CreatedDate,sv.CreatedBy,concat(mu.FirstName,' ',mu.LastName)CreatedName from tblSurvey sv      
 inner join tblMatchdigitalUser mu on mu.UserId=sv.CreatedBy where SurveyId=@SurveyId;      
      
 -- Get Page object based on surveyId     
    
select PageId,Title,PageLevelQuestion,pg.SurveyId,pg.SortOrder from tblPage pg       
inner join tblSurvey su on su.SurveyId=pg.SurveyId      
where pg.SurveyId=@SurveyId and pg.IsDeleted=0 and pg.IsActive=1 order by pg.SortOrder asc;      
      
-- survey Question with conditions based on surveyId       
      
select co.QuestionId, qu.QuestionLabelId,QuestionText,co.ControlTypeId,qt.Name QuestionType,isnull(QuestionOptions,'')QuestionOptions      
,pg.PageId,QuestionSortOrder,IsMandatory,HasRelevanceControl,AddQuestionToGraph,      
isnull(MatrixRowOptions,'')MatrixRowOptions,isnull(MatrixColumnOptions,'')MatrixColumnOptions,      
isnull(TextOptions,'{}')TextOptions from tblQuestion qu        
inner join tblPage pg on pg.SurveyId=@SurveyId       
inner join tblSurveyQuestionConfig co on co.QuestionLabelId=qu.QuestionLabelId and pg.PageId=co.PageId and co.IsDeleted=0      
inner join tblQuestionControlType qt on co.ControlTypeId=qt.ControlTypeId      
where  pg.IsActive=1 and pg.IsDeleted=0 and   co.IsDeleted=0 and pg.SurveyId=@SurveyId      
order by pg.SortOrder asc; 
GO
/****** Object:  StoredProcedure [dbo].[spGetSurveyById]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


  create procedure [dbo].[spGetSurveyById](@SurveyId int)
  as 
  select * from tblSurvey where SurveyId=@SurveyId and IsDeleted=0;
GO
/****** Object:  StoredProcedure [dbo].[spGetSurveyQuestionById]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
 CREATE  procedure [dbo].[spGetSurveyQuestionById](
 @SurveyId int
 )
 as
 -- get survey object based on surveyId
select SurveyTitle,Description,EmailTemplate,SurveyType,su.CreatedDate,CONCAT( us.FirstName,' ',us.LastName) CreatedName
from tblSurvey su 
inner join tblMatchdigitalUser us on us.UserId=su.CreatedBy
where su.SurveyId=@SurveyId and su.IsDeleted=0; 

-- get Page object based on surveyId

select PageId,Title,PageLevelQuestion,pg.SurveyId,pg.SortOrder from tblPage pg 
inner join tblSurvey su on su.SurveyId=pg.SurveyId
where pg.SurveyId=@SurveyId and pg.IsDeleted=0 and pg.IsActive=1 order by pg.SortOrder asc;

-- Get Questions with options based on surveyId 

select co.QuestionId, qu.QuestionLabelId,QuestionText,co.ControlTypeId,qt.Name QuestionType,isnull(QuestionOptions,'')QuestionOptions
,pg.PageId,QuestionSortOrder,IsMandatory,HasRelevanceControl,AddQuestionToGraph,
isnull(MatrixRowOptions,'')MatrixRowOptions,isnull(MatrixColumnOptions,'')MatrixColumnOptions,
isnull(TextOptions,'{}')TextOptions from tblQuestion qu  
inner join tblPage pg on pg.SurveyId=@SurveyId 
inner join tblSurveyQuestionConfig co on co.QuestionLabelId=qu.QuestionLabelId and pg.PageId=co.PageId and co.IsDeleted=0
inner join tblQuestionControlType qt on co.ControlTypeId=qt.ControlTypeId
where  pg.IsActive=1 and pg.IsDeleted=0 and   co.IsDeleted=0 and pg.SurveyId=@SurveyId
order by pg.SortOrder asc;

 -- Get Questions condition based on surveyId 

 select pg.SurveyId,pg.PageId, QuestionConditionId,qc.QuestionId,QuestionConditions from tblQuestionCondition qc 
 inner join tblSurveyQuestionConfig sc on sc.QuestionId=qc.QuestionId
 inner join tblPage pg on pg.SurveyId=@SurveyId and sc.PageId=pg.PageId
 where  pg.IsActive=1 and pg.IsDeleted=0 and   sc.IsDeleted=0 and pg.SurveyId=@SurveyId
 order by pg.SortOrder asc;
GO
/****** Object:  StoredProcedure [dbo].[spGetUserSelectedAnswerView]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  CREATE procedure [dbo].[spGetUserSelectedAnswerView]
  as 
--  select (select DigiPartnerProfileId,Email,PostalCode,Place,HouseNumber, CompanyName, YearOfFounding, PhoneNumber, PositionInCompany,CompanyProfile, ProductProfile,Slogan,
-- ContactPersonFirstName, ContactPersonLastName,
--(select cat.CategoryId,CategoryName,  
--(select su.SubCategoryId,SubCategoryName,sua.Answer,
--(select chl.SubCategoryChildId,chl.ChildName,chl.UID UID

--from tblSubCategoryChild chl   
--Inner Join tblSubCategoryChildAnswer chla on chl.SubCategoryChildId = chla.SubCategoryChildId
--where su.SubCategoryId=chl.SubCategoryId and chla.DigiPartnerProfileId = dpp.DigiPartnerProfileId  for json Path )as SubCategoryChild 
 
--from tblSubCategory su  
--Inner Join tblSubCategoryAnswer sua on su.SubCategoryId =sua.SubCategoryId
--where su.CategoryId=cat.CategoryId and sua.DigiPartnerProfileId = dpp.DigiPartnerProfileId FOR JSON PATH)as Subcategory  

--from tblCategory cat for json Path)as  Category 
--from tblDigiPartnerProfile dpp for json path , Root('User'))


 select DigiPartnerProfileId,Email,PostalCode,Place,HouseNumber, CompanyName, YearOfFounding, PhoneNumber, PositionInCompany,CompanyProfile, ProductProfile,Slogan,
 ContactPersonFirstName, ContactPersonLastName,
(select cat.CategoryId,CategoryName,  
(select su.SubCategoryId,SubCategoryName,sua.Answer,
(select chl.SubCategoryChildId,chl.ChildName,chl.UID UID

from tblSubCategoryChild chl   
Inner Join tblSubCategoryChildAnswer chla on chl.SubCategoryChildId = chla.SubCategoryChildId
where su.SubCategoryId=chl.SubCategoryId and chla.DigiPartnerProfileId = dpp.DigiPartnerProfileId  for json Path )as SubCategoryChild 
 
--from tblSubCategory su 
--inner join tblSubCategoryChild chl on chl.SubCategoryId = su.SubCategoryId
--inner join tblSubCategoryChildAnswer chla on chla.SubCategoryChildId = chl.SubCategoryChildId and chla.DigiPartnerProfileId = dpp.DigiPartnerProfileId
--left outer Join tblSubCategoryAnswer sua on su.SubCategoryId =sua.SubCategoryId and  sua.DigiPartnerProfileId = dpp.DigiPartnerProfileId
--where su.CategoryId = cat.CategoryId group by su.SubCategoryId,SubCategoryName,sua.Answer FOR JSON PATH)as Subcategory  

from tblSubCategory su 
left outer Join tblSubCategoryAnswer sua on su.SubCategoryId =sua.SubCategoryId and sua.DigiPartnerProfileId = dpp.DigiPartnerProfileId
left join tblSubCategoryChild chl on chl.SubCategoryId = su.SubCategoryId
full outer join tblSubCategoryChildAnswer chla on chla.SubCategoryChildId = chl.SubCategoryChildId and chla.DigiPartnerProfileId = dpp.DigiPartnerProfileId
where su.CategoryId = cat.CategoryId and (sua.DigiPartnerProfileId = dpp.DigiPartnerProfileId or chla.DigiPartnerProfileId = dpp.DigiPartnerProfileId)
group by su.SubCategoryId,su.SubCategoryName,sua.Answer  FOR JSON PATH)as Subcategory


from tblCategory cat for json Path)as  Category 
from tblDigiPartnerProfile dpp 
GO
/****** Object:  StoredProcedure [dbo].[spGetUserSurveyList]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[spGetUserSurveyList] (@Count int, @Offset int,@Search NVARCHAR(max))
  as  
  -- Get user already taken survey list with filter and pagination options 
 if @Search=''
  begin
 select * from vwGetUserSurveyList   
order by CompanyName Desc OFFSET  @Count * @Offset ROWS
FETCH NEXT @Count  ROWS ONLY;
 end
else
select * from vwGetUserSurveyList   where Search  like '%' + @Search + '%' 
order by CompanyName Desc OFFSET  @Count * @Offset ROWS
FETCH NEXT @Count  ROWS ONLY;

GO
/****** Object:  StoredProcedure [dbo].[spKMUUserLogin]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
   
  CREATE procedure [dbo].[spKMUUserLogin](@Email varchar(50),@Password varchar(50))
  as 
  -- check user is valid, based on email and password
  select KMUUserId UserId,SurName,FirstName,Title,Salutation,Email,PhoneNumber,Position,CompanyName,StreetAndHouseNo,
  PostalCode,Turnover,EmployeeCount,CreatedDate,UpdatedDate ,'KMU_USER' RoleType,rl.Name RoleName,km.RoleId,Country from tblKMUUser km
   inner join tblRole rl on rl.RoleId=km.RoleId
  where IsDeleted=0 and Email=@Email and convert(varbinary, Password) = convert(varbinary, @Password) 

GO
/****** Object:  StoredProcedure [dbo].[spMatchdigitalUserLogin]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[spMatchdigitalUserLogin](@Email varchar(50),@Password varchar(50))
  as 
  -- check given credential is valid user or not, based on email and password
  select UserId, FirstName,LastName,Address,ContactNumber,Email,Password,us.RoleId RoleId,rl.Name as RoleName,'ADMIN_USER'RoleType,CreatedBy,CreatedDate,
  ModifiedBy,ModifiedDate,PasswordUpdatedDate,IsActive from tblMatchdigitalUser us 
  inner join tblRole rl on rl.RoleId=us.RoleId  
  where IsDeleted=0 and Email=@Email and  convert(varbinary, Password) = convert(varbinary, @Password) and IsActive=1 --  varbinary help to password check with case sensitive

GO
/****** Object:  StoredProcedure [dbo].[spSaveBlogComment]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

  
CREATE PROCEDURE [dbo].[spSaveBlogComment](
@CommentId int,
@BlogId INT,
@Comment VARCHAR(MAX),
@ParentId INT,
@UserId INT,
@UserType INT,
@Action varchar(20),
@IsVisible bit
)
AS
 BEGIN
 	if @Action='Add'
	begin -- Create new comment
	INSERT INTO tblBlogComment ([BlogId], [Comment], [CommentTime], [ParentId], [UserId], [UserType], [IsVisible]) VALUES
	(@BlogId, @Comment, getdate(), @ParentId, @UserId, @UserType, 1)
	end;
	else
	begin  -- update existing comment
	update tblBlogComment set BlogId=@BlogId,Comment=@Comment,IsVisible=@IsVisible where CommentId=@CommentId;
	end 

END; 

GO
/****** Object:  StoredProcedure [dbo].[spSaveClassification]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 
 -- sp creation

  -- Classification  
  Create procedure [dbo].[spSaveClassification](@Id int, @Name varchar(100),@Description varchar(250),@ParentClass varchar(100),@Action varchar(50))
  as 
  
  IF @Action='Add'
   BEGIN
    insert into tblClassification(Name,Description,ParentClass,IsDeleted)values(@Name,@Description,@ParentClass,0)
  END
  ELSE
  BEGIN
   update tblClassification set Name=@Name,Description=@Description,ParentClass=@ParentClass where Id=@Id;
  END
GO
/****** Object:  StoredProcedure [dbo].[spSaveFiles]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[spSaveFiles](@FilePath varchar(500),
@FileTypeId	int,
@FileReferenceId	int)
as
 insert into tblFiles(FilePath,FileTypeId,FileReferenceId,IsDeleted)values(@FilePath,@FileTypeId,@FileReferenceId,0);

GO
/****** Object:  StoredProcedure [dbo].[spSaveMatchdigitalUser]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE procedure [dbo].[spSaveMatchdigitalUser](
 @UserId	int,
 @FirstName varchar(50),
 @LastName varchar(50),
 @Address varchar(250),
 @ContactNumber	varchar(25),
 @Email	varchar(50),
 @Password	varchar(50),
 @RoleId	int,
 @CreatedBy	int,
 @ModifiedBy	int,
 @IsActive	bit,
 @Action varchar(25)
 ) 
  as 
  declare @Status varchar(50);
  IF @Action='Add' -- @Action value is 'Add' insert records in tblMatchdigitalUser
   BEGIN
   if(select count(*) from  tblMatchdigitalUser where Email=@Email and IsDeleted=0)=0 -- check email already exist in tblMatchdigitalUser
   begin
    insert into tblMatchdigitalUser(FirstName,LastName,Address,ContactNumber,Email,Password,RoleId,CreatedBy,CreatedDate,IsActive,IsDeleted)
	values(@FirstName,@LastName,@Address,@ContactNumber,@Email,@Password,@RoleId,@CreatedBy,getdate(),@IsActive,0)
    set @Status='Success';
	end
	else
	begin
	set @Status='User already exist';
	end
  END
  ELSE
  BEGIN  -- @Action value is 'Edit' Update records in tblMatchdigitalUser 
   set @Status='Success';
   update tblMatchdigitalUser set FirstName=@FirstName,LastName=@LastName,Address=@Address,ContactNumber=@ContactNumber,Email=@Email,
   RoleId=@RoleId,ModifiedBy=@ModifiedBy,ModifiedDate=getdate(), IsActive=@IsActive where UserId=@UserId;
  END

  select @Status Status;

GO
/****** Object:  StoredProcedure [dbo].[spSavePage]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE procedure [dbo].[spSavePage](
 @PageId int ,
 @Title	varchar(100),
 @PageLevelQuestion	varchar(max),
 @SurveyId	int,
 @SortOrder	int,
 @CreatedBy	int,
 @ModifiedBy int, 
 @IsActive	bit,
 @Action varchar(25)
 ) 
  as 
    
   IF @Action='Add'  -- create new record from tblpage 
   BEGIN
   insert into tblPage(Title,PageLevelQuestion,SurveyId,SortOrder,CreatedBy,CreatedDate,IsActive,IsDeleted)
   values(@Title,@PageLevelQuestion,@SurveyId,@SortOrder,@CreatedBy,getdate(),@IsActive,0);
   SELECT @@IDENTITY AS PageId;
  END
  ELSE
  BEGIN  -- update record from tblpage 
   update tblPage set Title=@Title,PageLevelQuestion=@PageLevelQuestion,SurveyId=@SurveyId,SortOrder=@SortOrder,
   ModifiedBy=@ModifiedBy,ModifiedDate=getdate(),IsActive=@IsActive
   where PageId=@PageId;
  END
GO
/****** Object:  StoredProcedure [dbo].[spSaveProfileAnswer]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 


CREATE procedure [dbo].[spSaveProfileAnswer](@DigiPartnerProfileId int,@ChildAnswer nvarchar(max),@SubcategoryAnswer nvarchar(max),@Answers nvarchar(max), @ChildUserAnswers nvarchar(max))    
AS    
 BEGIN    
    BEGIN TRANSACTION;     
    BEGIN TRY    
    
-- save Child answer:    
    update tblDigiPartnerProfile set Answers=@Answers where DigiPartnerProfileId=@DigiPartnerProfileId;  
  -- move child answer record in temp table    
 create table #tblChildAnswer (ChildId int,ProfileId int);    
 INSERT INTO #tblChildAnswer (ChildId, ProfileId) SELECT DISTINCT  Value,@DigiPartnerProfileId  FROM [dbo].[fnSplitComma]( @ChildAnswer );    
    -- insert not exist child answer record    
 INSERT tblSubCategoryChildAnswer(DigiPartnerProfileId,SubCategoryChildId)SELECT DISTINCT ProfileId,ChildId FROM #tblChildAnswer cr     
 WHERE NOT EXISTS (SELECT DigiPartnerProfileId,SubCategoryChildId FROM tblSubCategoryChildAnswer c    
 WHERE cr.ChildId = c.SubCategoryChildId and cr.ProfileId=c.DigiPartnerProfileId);     
 -- delete remaining child answer record     
 DELETE FROM tblSubCategoryChildAnswer WHERE DigiPartnerProfileId=@DigiPartnerProfileId and SubCategoryChildId     
 NOT IN (SELECT f.ChildId FROM #tblChildAnswer f);    
    
--- End Child answer    
  
--Insert new classification records
if(@ChildUserAnswers !='')  
Begin  
  
 create table #tblSubCategoryUserAnswer (SubCategoryId int, Answer nvarchar(max));    
 INSERT INTO #tblSubCategoryUserAnswer (SubCategoryId, Answer) select SubCategoryId,Answer   from   OPENJSON(@ChildUserAnswers) WITH (SubCategoryId int, Answer nvarchar(max));     
-- insert not exist new classification  record  in question table  
 INSERT tblSubCategoryChild (SubCategoryId,ChildName,IsActive,IsDeleted, UID,IsUserInput)SELECT DISTINCT SubCategoryId,Answer,1,0,null,1 FROM #tblSubCategoryUserAnswer cr     
 WHERE NOT EXISTS (SELECT * FROM tblSubCategoryChild c    
 WHERE c.SubCategoryId = cr.SubCategoryId and cr.Answer=c.ChildName);     
  
  -- insert not exist new classification  record  in answer table  

 INSERT tblSubCategoryChildAnswer(DigiPartnerProfileId,SubCategoryChildId) SELECT DISTINCT @DigiPartnerProfileId,  
 SubCategoryChildId from  tblSubCategoryChild c where SubCategoryChildId  in (SELECT c.SubCategoryChildId FROM #tblSubCategoryUserAnswer u    
 WHERE c.SubCategoryId = u.SubCategoryId and u.Answer=c.ChildName)   
   -- Update UID in  new classification  record

Update tblSubCategoryChild set uid = concat('chl_', SubCategoryChildId)   
 WHERE UID is null  
  
 End  
 
  
   
    
--- Start Subcategory Answer    
        
 -- move subcategory textbox answer record in temp table    
 create table #tblSubCategoryAnswer (ChildId int,ProfileId int,Answer nvarchar(max));    
 INSERT INTO #tblSubCategoryAnswer (ChildId, ProfileId,Answer) SELECT SubCategoryId,@DigiPartnerProfileId,Answer FROM OPENJSON(@SubcategoryAnswer) WITH (SubCategoryId int,Answer nvarchar(max));    
    -- insert not exist subcategory textbox answer record    
 INSERT tblSubCategoryAnswer(DigiPartnerProfileId,SubCategoryId,Answer)SELECT DISTINCT ProfileId,ChildId,Answer FROM #tblSubCategoryAnswer cr     
 WHERE NOT EXISTS (SELECT DigiPartnerProfileId,SubCategoryId,Answer FROM tblSubCategoryAnswer c    
 WHERE cr.ChildId = c.SubCategoryId and cr.ProfileId=c.DigiPartnerProfileId);     
    -- update subcategory exist answer    
 UPDATE tblSubCategoryAnswer   SET tblSubCategoryAnswer.Answer = ans.Answer FROM tblSubCategoryAnswer subans    
   INNER JOIN #tblSubCategoryAnswer ans  ON subans.DigiPartnerProfileId=ans.ProfileId and subans.SubCategoryId=ans.ChildId    
   WHERE subans.DigiPartnerProfileId=@DigiPartnerProfileId;    
      
 -- delete remaining subcategory record     
 DELETE FROM tblSubCategoryAnswer WHERE DigiPartnerProfileId=@DigiPartnerProfileId and SubCategoryId     
 NOT IN (SELECT f.ChildId FROM #tblSubCategoryAnswer f);    
    
    
--- End Subcategory Answer    
        
   COMMIT TRANSACTION ;    
  select 'Success' ErrorMessage;     
    END TRY    
    BEGIN CATCH    
        IF @@TRANCOUNT > 0    
        BEGIN    
            ROLLBACK TRANSACTION ;    
   select ERROR_MESSAGE() AS ErrorMessage;     
        END    
    END CATCH    
END;  

GO
/****** Object:  StoredProcedure [dbo].[spSaveQuestionCondition]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


 CREATE procedure [dbo].[spSaveQuestionCondition](
 @QuestionConditionId	int,
 @QuestionId int,
 @QuestionConditions nvarchar(max),
 @Action varchar(25)
 ) 
  as  
   IF @Action='Add'  -- Insert new question condition 
   BEGIN
   insert into tblQuestionCondition(QuestionId,QuestionConditions)values(@QuestionId,@QuestionConditions);
  END
  ELSE
  BEGIN  -- Update question condition
   update tblQuestionCondition set QuestionConditions=@QuestionConditions  where QuestionConditionId=@QuestionConditionId;
  END
GO
/****** Object:  StoredProcedure [dbo].[spSaveQuestionLabel]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[spSaveQuestionLabel](
 @QuestionLabelId	int,
 @QuestionText varchar(max),
 @CreatedBy	int,
 @ModifiedBy int, 
 @IsActive	bit,
 @Action varchar(25)
 ) 
  as  
   IF @Action='Add'  -- Insert new record in tblQuestion
   BEGIN
   insert into tblQuestion(QuestionText,CreatedBy,CreatedDate,IsActive,IsDeleted,IsAllowFilter)
   values(@QuestionText,@CreatedBy,getdate(),@IsActive,0,1);
   SELECT @@IDENTITY AS QuestionId;
  END
  ELSE
  BEGIN  -- Update record in tblQuestion
   update tblQuestion set QuestionText=@QuestionText,ModifiedBy=@ModifiedBy,ModifiedDate=getdate(),IsActive=@IsActive
   where QuestionLabelId=@QuestionLabelId;
  END
GO
/****** Object:  StoredProcedure [dbo].[spSaveQuestionOption]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[spSaveQuestionOption](
@QuestionId	int,
@QuestionOptions nvarchar(max),
@MatrixRowOptions nvarchar(max),
@MatrixColumnOptions nvarchar(max),
@TextOptions nvarchar(max),
@Option nvarchar(50)
)
as
 -- Update question options based on @option value
if @Option ='row'
begin
 update tblSurveyQuestionConfig set MatrixRowOptions=@MatrixRowOptions where QuestionId=@QuestionId;
end;
if @Option ='column'
begin
  update tblSurveyQuestionConfig set MatrixColumnOptions=@MatrixColumnOptions where QuestionId=@QuestionId;
end;
if @Option ='option'
begin
  update tblSurveyQuestionConfig set QuestionOptions=@QuestionOptions where QuestionId=@QuestionId;
end;
if @Option ='text'
begin
  update tblSurveyQuestionConfig set TextOptions=@TextOptions where QuestionId=@QuestionId;
end;
  
GO
/****** Object:  StoredProcedure [dbo].[spSaveSuccessStory]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE procedure [dbo].[spSaveSuccessStory](
@SuccessStoryId	int,
@DigiPartnerProfileId int,
@StoryContent varchar(max),
@Title varchar(250),
@SuccessStoryImage varchar(250),
@SuccessStoryPDF varchar(250),
@Tag	varchar(50),
@Status	varchar(25),
@Email varchar(50),
@Action varchar(25),
@ClassificationId varchar(50)
 
)
  as 
    IF @Action='Add'  -- insert new record in tblSuccessStory
   BEGIN 
    insert into tblSuccessStory(DigiPartnerProfileId,StoryContent,Title,SuccessStoryImage,SuccessStoryPDF,Tag,Status,CreatedDate,IsDeleted,Email)values
	(@DigiPartnerProfileId,@StoryContent,@Title,@SuccessStoryImage,@SuccessStoryPDF,@Tag,@Status,getdate(),0,@Email);
	 declare @StId int;
	 set @StId=(select @@IDENTITY);  -- insert successtory classifcation 
	  declare @classificationRefId int = (SELECT RIGHT(@ClassificationId, LEN(@ClassificationId) - 4));
	 if CHARINDEX('cat_',@ClassificationId) > 0   
         begin  
         INSERT INTO tblClassificationReferenceMaster(ClassificationRefId,ClassificationLevel,ModuleRefId,ModuleType) 
		 VALUES (@classificationRefId,'Category',@StId,'tblSuccessStory');
         end  
		  else if CHARINDEX('sub_',@ClassificationId) > 0   
         begin  
         INSERT INTO tblClassificationReferenceMaster(ClassificationRefId,ClassificationLevel,ModuleRefId,ModuleType) 
		 VALUES (@classificationRefId,'SubCategory',@StId,'tblSuccessStory');
         end  
		  else if CHARINDEX('chl_',@ClassificationId) > 0   
         begin  
         INSERT INTO tblClassificationReferenceMaster(ClassificationRefId,ClassificationLevel,ModuleRefId,ModuleType) 
		 VALUES (@classificationRefId,'SubCategoryChild',@StId,'tblSuccessStory');
         end   

  END
  ELSE
  BEGIN -- update record in tblSuccessStory
   update tblSuccessStory set DigiPartnerProfileId=@DigiPartnerProfileId,StoryContent=@StoryContent,Title=@Title,
  SuccessStoryImage=@SuccessStoryImage,SuccessStoryPDF=@SuccessStoryPDF,Tag=@Tag,Status=@Status,Email=@Email where SuccessStoryId=@SuccessStoryId;
  -- Update successtory classifcation 
          set @classificationRefId   = (SELECT RIGHT(@ClassificationId, LEN(@ClassificationId) - 4));
	 if CHARINDEX('cat_',@ClassificationId) > 0   
         begin  
         update tblClassificationReferenceMaster set  ClassificationRefId=@classificationRefId,ClassificationLevel='Category' 
		 where ModuleRefId=@SuccessStoryId;
		 
         end  
		  else if CHARINDEX('sub_',@ClassificationId) > 0   
         begin  
		  update tblClassificationReferenceMaster set  ClassificationRefId=@classificationRefId,ClassificationLevel='SubCategory' 
		 where ModuleRefId=@SuccessStoryId; 
         end  
		  else if CHARINDEX('chl_',@ClassificationId) > 0   
         begin  
		  update tblClassificationReferenceMaster set  ClassificationRefId=@classificationRefId,ClassificationLevel='SubCategoryChild' 
		 where ModuleRefId=@SuccessStoryId;  
         end   
 END
GO
/****** Object:  StoredProcedure [dbo].[spSaveSuccessStoryComments]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

  
 CREATE procedure [dbo].[spSaveSuccessStoryComments](
@CommentId	int,
@CommentBy	int,
@SuccessStoryId int,
@Description	varchar(max),
@Action varchar(25) 
)
  as 
  
  IF @Action='Add' -- insert new records in tblSuccessStoryComments
   BEGIN  
    insert into tblSuccessStoryComments(CommentBy,SuccessStoryId,Description,AnswerDate,IsDeleted)values
	(@CommentBy,@SuccessStoryId,@Description,getdate(),0);
  END
  ELSE
  BEGIN   -- update records in tblSuccessStoryComments
   update tblSuccessStoryComments set CommentBy=@CommentBy,SuccessStoryId=@SuccessStoryId,Description=@Description
   where CommentId=@CommentId;
  END
GO
/****** Object:  StoredProcedure [dbo].[spSaveSurvey]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[spSaveSurvey](
 @SurveyId int ,
 @SurveyTitle varchar(100),
 @Description varchar(max),
 @EmailTemplate varchar(max),
 @SurveyType	varchar(25),
 @CreatedBy int,
 @ModifiedBy int,
 @IsActive bit,
 @Action varchar(25)
 ) 
  as 
    
   IF @Action='Add' -- Insert new record in tblSurvey 
   BEGIN
   insert into tblSurvey(SurveyTitle,Description,EmailTemplate,SurveyType,CreatedBy,CreatedDate,IsActive,IsDeleted)
   values(@SurveyTitle,@Description,@EmailTemplate,@SurveyType,@CreatedBy,getdate(),@IsActive,0)
   SELECT @@IDENTITY AS SurveyId;
  END
  ELSE
  BEGIN  -- Update existing record in tblSurvey 
   update tblSurvey set SurveyTitle=@SurveyTitle,Description=@Description,EmailTemplate=@EmailTemplate,SurveyType=@SurveyType,
   ModifiedBy=@ModifiedBy,ModifiedDate=getdate(),IsActive=@IsActive
   where SurveyId=@SurveyId;
  END
GO
/****** Object:  StoredProcedure [dbo].[spSaveSurveyAnswer]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[spSaveSurveyAnswer](  
@RespondentId int,  
@RespodentType int,  
@PageId int,  
@Answer nvarchar(max),  
@SurveyId int  
)  
as  
    declare @UserSurveyId int;  
      begin  -- check user is already take survey.If not take survey already, insert new record in tblUserSurvey.
     if (select Count(RespondentId) from tblUserSurvey where SurveyId=@SurveyId and RespondentId=@RespondentId)= 0   
 begin  
  insert into tblUserSurvey (RespondentId,RespodentType,SurveyId,IsSurveyCompleted,SurveyReport,SurveyModifiedDate)values  
 (@RespondentId,@RespodentType,@SurveyId,0,null,getdate());  
 set @UserSurveyId=(SELECT @@IDENTITY AS UserSurveyId);  
 end  
 else 
  -- check page answer is already exist.If answer is already exist update the page answer.Otherwise insert new record in tblUserSurveyPageAnswers 
 set @UserSurveyId=(select UserSurveyId from tblUserSurvey where SurveyId=@SurveyId and RespondentId=@RespondentId);  
 end;  
  begin  
   if (select Count(*) from tblUserSurveyPageAnswers where PageId=@PageId and UserSurveyId= @UserSurveyId)= 0   
 begin  
  insert into tblUserSurveyPageAnswers(UserSurveyId,PageId,Answer)values(@UserSurveyId,@PageId,@Answer);  
     update tblUserSurvey set SurveyModifiedDate=getdate() where UserSurveyId=@UserSurveyId;  
 end   
 else  
  update tblUserSurveyPageAnswers set Answer=@Answer where PageId=@PageId and UserSurveyId= @UserSurveyId;  
    update tblUserSurvey set SurveyModifiedDate=getdate() where UserSurveyId=@UserSurveyId;   
 end;      
GO
/****** Object:  StoredProcedure [dbo].[spSaveSurveyQuestionConfig]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
 
 CREATE procedure [dbo].[spSaveSurveyQuestionConfig](
 @QuestionId int,
 @PageId int,
 @QuestionSortOrder	int,
 @IsMandatory bit,
 @HasRelevanceControl bit,
 @Action varchar(25),
 @QuestionText nvarchar(max),
 @CreatedBy int,
 @ControlTypeId int,
 @AddQuestionToGraph bit
 ) 
  as 
   
  declare @QuestionLabelId int; 
     -- check question label already exist.If question label is not  exist, insert new record in tblQuestion table.
   set @QuestionLabelId=( SELECT CASE WHEN COUNT(1) > 0 THEN(select QuestionLabelId from  tblQuestion where QuestionText=@QuestionText)
   ELSE 0 END AS Value FROM tblQuestion S where QuestionText=@QuestionText);
   if @QuestionLabelId=0 
   begin
     insert into tblQuestion(QuestionText,CreatedBy,CreatedDate,IsActive,IsDeleted)
    values(@QuestionText,@CreatedBy,getdate(),1,0);
    set @QuestionLabelId= (SELECT @@IDENTITY AS QuestionLabelId);
   end
   IF @Action='Add' -- Insert new record in tblSurveyQuestionConfig
   BEGIN
   insert into tblSurveyQuestionConfig(PageId,QuestionLabelId,QuestionSortOrder,IsMandatory,HasRelevanceControl,CreatedBy,ControlTypeId,IsDeleted,AddQuestionToGraph)values
   (@PageId,@QuestionLabelId,@QuestionSortOrder,@IsMandatory,@HasRelevanceControl,@CreatedBy,@ControlTypeId,0,@AddQuestionToGraph);
  END
  ELSE
  BEGIN  -- update record in  tblSurveyQuestionConfig
   update tblSurveyQuestionConfig set PageId=@PageId,QuestionLabelId=@QuestionLabelId,QuestionSortOrder=@QuestionSortOrder,IsMandatory=@IsMandatory,
   HasRelevanceControl=@HasRelevanceControl,ControlTypeId=@ControlTypeId,AddQuestionToGraph=@AddQuestionToGraph where QuestionId=@QuestionId;
  END
GO
/****** Object:  StoredProcedure [dbo].[spSelectCommentById]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE PROCEDURE [dbo].[spSelectCommentById](
@CommentId INT
)
as
BEGIN
	select * from  tblBlogComment  WHERE [CommentId] = @CommentId;
END;
GO
/****** Object:  StoredProcedure [dbo].[spUpadteDigiAndMDUser]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE procedure [dbo].[spUpadteDigiAndMDUser](@UserId int,@FirstName varchar(50),@LastName varchar(50),@RoleId int,@RoleType varchar(50),@IsActive bit,@Membership varchar(25))  
as  
-- update user details based on RoleType
if @RoleType='DIGIPARTNER_USER'  
begin  
update tblDigiPartnerProfile set ContactPersonFirstName=@FirstName,ContactPersonLastName=@LastName,RoleId=@RoleId,IsActive=@IsActive ,  
Membership=@Membership where DigiPartnerProfileId=@UserId;  
end   
else if @RoleType='ADMIN_USER'  
begin  
update tblMatchdigitalUser set FirstName=@FirstName,LastName=@LastName,RoleId=@RoleId,IsActive=@IsActive where UserId=@UserId;
end
else if @RoleType='KMU_USER'
begin
update tblKMUUser set FirstName=@FirstName,SurName=@LastName,RoleId=@RoleId,IsActive=@IsActive where KMUUserId=@UserId;
end 
GO
/****** Object:  StoredProcedure [dbo].[spUpdateBanner]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[spUpdateBanner](
@HeaderBannerId int,
@SortOrder int,
@HeaderBannerName varchar(200),
@Type int,
@PublisherId int,
@PublisherType int, 
@PublishDate  DateTime,
@BannerText varchar(200),
@BannerImageURL varchar(200),
@BannerLinkURL  varchar(200),
@BlogId int

)
as

BEGIN
 	
    BEGIN TRANSACTION; 
    BEGIN TRY  
	-- update header banner details.
	update tblHeaderBanner set SortOrder=@SortOrder,HeaderBannerName=@HeaderBannerName,Type=@Type,PublishDate=@PublishDate
	where HeaderBannerId=@HeaderBannerId;
    if (@Type=1) --update blog Banner
	 begin
	 delete from tblBannerDetail where HeaderBannerId=@HeaderBannerId;
	 if (select count(*) from tblBannerBlogDetail where HeaderBannerId=@HeaderBannerId) >0
	 begin
	 update tblBannerBlogDetail set BlogId=@BlogId where HeaderBannerId=@HeaderBannerId
	 end
	 else
	 begin
	 insert into tblBannerBlogDetail(BlogId,HeaderBannerId)values(@BlogId,@HeaderBannerId);
	 end
	 end
	 else
	 begin   --update custom Banner 
	 delete from tblBannerBlogDetail where HeaderBannerId=@HeaderBannerId;
	  if (select count(*) from tblBannerDetail where HeaderBannerId=@HeaderBannerId) >0
	 begin
	 update tblBannerDetail set BannerText=@BannerText,BannerImageURL=@BannerImageURL,BannerLinkURL=@BannerLinkURL
	 where HeaderBannerId=@HeaderBannerId; 
	 end
	 else
	 begin
	  insert into tblBannerDetail(BannerText,BannerImageURL,BannerLinkURL,HeaderBannerId)
	 values(@BannerText,@BannerImageURL,@BannerLinkURL,@HeaderBannerId);
	 end 
	 end
   COMMIT TRANSACTION ;
		select 'Success' ErrorMessage; 
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION ;
			select ERROR_MESSAGE() AS ErrorMessage; 
        END
    END CATCH
END;
GO
/****** Object:  StoredProcedure [dbo].[spUpdateBlog]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 
 CREATE PROCEDURE [dbo].[spUpdateBlog](      
 @BlogId int,      
 @Title varchar(200),      
 @BlogContent varchar(max),      
 @PublisherName varchar(100),      
 @BlogPublishDate datetime,      
 @PublisherType int,      
 @PublisherId int,      
 @ApprovalStatus int,      
 @BlogStatus bit,      
 @MediaContent nvarchar(max),      
 @Keyword nvarchar(max),      
 @Classification varchar(max),      
 @SecondaryClassification nvarchar(max),      
 @RelatedBlogs nvarchar(max)      
)         
      
      
AS         
 BEGIN    
    BEGIN TRANSACTION;       
    BEGIN TRY      
      -- update blog content in  tblBlog
  UPDATE tblBlog SET Title = @Title, BlogContent = @BlogContent, PublisherName = @PublisherName, BlogPublishDate = @BlogPublishDate,      
  PublisherType = @PublisherType, PublisherId = @PublisherId, ApprovalStatus = @ApprovalStatus, BlogStatus = @BlogStatus, IsDeleted = 0 WHERE BlogId = @BlogId;      
      -- update mediacontent.It is may be multiple files.It is data should be json format
 create table #tblMediaContentPara (DocumentURL varchar(500),DocumentType int,ContentType varchar(100),BlogId int);      
 INSERT INTO #tblMediaContentPara (DocumentURL,DocumentType,ContentType,BlogId) SELECT DocumentURL,DocumentType,ContentType,@BlogId       
   FROM OPENJSON(@MediaContent) WITH (DocumentURL varchar(500),DocumentType int,ContentType varchar(100));      
 INSERT tblMediaContent(DocumentURL, DocumentType,ContentType,BlogId,IsDeleted)       
  SELECT DISTINCT DocumentURL, DocumentType,ContentType, @BlogId, 0 FROM #tblMediaContentPara cr       
  WHERE NOT EXISTS (SELECT DocumentURL, DocumentType,ContentType FROM tblMediaContent c      
  WHERE c.DocumentURL = cr.DocumentURL and c.BlogId = @BlogId);  
        
 UPDATE tblMediaContent SET DocumentURL = temp.DocumentURL, DocumentType = temp.DocumentType, ContentType = temp.ContentType,      
  IsDeleted = 0       
 FROM tblMediaContent MC INNER JOIN #tblMediaContentPara temp ON MC.DocumentURL = temp.DocumentURL       
    WHERE MC.BlogId = @BlogId;      
        
   UPDATE tblMediaContent SET DocumentURL = temp.DocumentURL FROM tblMediaContent MC      
   INNER JOIN #tblMediaContentPara temp  ON MC.DocumentURL=temp.DocumentURL and MC.DocumentType=temp.DocumentType      
   WHERE MC.BlogId=@BlogId;      
         
 UPDATE tblMediaContent SET IsDeleted = 1 WHERE BlogId=@BlogId and DocumentURL       
 NOT IN (SELECT M.DocumentURL FROM #tblMediaContentPara M);      
       -- update keywords.
 create table #tblKeywordsMaster ( Keyword varchar(100));      
 INSERT INTO #tblKeywordsMaster (Keyword) SELECT DISTINCT value FROM [dbo].[fnSplitString]( @Keyword );       
      -- if keyword not exist insert records in keyword master   
  INSERT INTO tblKeywordsMaster (Keyword) SELECT Keyword FROM #tblKeywordsMaster TK      
   WHERE NOT EXISTS (SELECT Keyword FROM tblKeywordsMaster c WHERE c.Keyword = TK.Keyword);       
      
   CREATE TABLE #TblTempKeywordid (KID INT, Keyword varchar(100));      
  INSERT INTO #TblTempKeywordid(KID, Keyword) SELECT KeywordId,Keyword FROM tblKeywordsMaster WHERE       
      Keyword IN (SELECT Keyword FROM #tblKeywordsMaster);      
   --   insert records in tblBlogKeywords  
 
      INSERT tblBlogKeywords(BlogId,KeywordId)SELECT DISTINCT @BlogId BlogId,KID FROM #TblTempKeywordid cr     
  WHERE NOT EXISTS (SELECT KeywordId FROM  tblBlogKeywords c   
  WHERE cr.KID= c.KeywordId and c.BlogId=@BlogId); 
   
  INSERT tblBlogKeywords(BlogId,KeywordId) SELECT DISTINCT @BlogId,KID FROM #TblTempKeywordid cr      
  WHERE NOT EXISTS (SELECT KeywordId FROM tblBlogKeywords c WHERE c.KeywordId = cr.KID AND BlogId = @BlogId );      
      
	  --   delete records in tblBlogKeywords based on  param @Keyword 
   DELETE FROM tblBlogKeywords WHERE BlogId=@BlogId and KeywordId 
   NOT IN (SELECT f.KID FROM #TblTempKeywordid f);  
     -- Update Primary classification.It is data should be json format  
  IF(@Classification != '')          
  BEGIN        CREATE table #tblClassificationtemp (CategoryId int,CategoryName nvarchar(100),Level varchar(100),UID nvarchar(100));      
  INSERT INTO #tblClassificationtemp (CategoryId,CategoryName,Level,UID) SELECT CategoryId,CategoryName,Level,UID      
  FROM OPENJSON(@Classification) WITH ([CategoryId] int,[CategoryName]  nvarchar(100), [Level] nvarchar(100),[UID]  nvarchar(100))      
      
  INSERT tblClassificationReferenceMaster (ClassificationRefId,ClassificationLevel,ModuleRefId,ModuleType,IsPrimary)      
  SELECT DISTINCT CategoryId,Level,@BlogId,'tblBlog',1 FROM #tblClassificationtemp cr       
  WHERE NOT EXISTS (SELECT * FROM #tblClassificationtemp cr       
  inner join tblClassificationReferenceMaster c on c.ClassificationRefId = cr.CategoryId  and c.ModuleRefId = @BlogId and c.IsPrimary = 1)      
      
  delete tblClassificationReferenceMaster where ClassificationId in (      
  select ClassificationId from tblClassificationReferenceMaster c inner join #tblClassificationtemp cr on  c.ModuleRefId =  @BlogId      
  WHERE NOT EXISTS (select * from #tblClassificationtemp cr where c.ClassificationRefId = cr.CategoryId and c.ModuleRefId =  @BlogId and c.IsPrimary = 1))      
  END       
  ELSE      
  BEGIN      
  DELETE tblClassificationReferenceMaster where ModuleRefId = @BlogId and IsPrimary = 1      
  END         
       -- Update secondary classification.It is may be multiple classification records.It is data should be json format  
  IF(@SecondaryClassification != '')          
  BEGIN        
  CREATE table #tblSubClassificationtemp (CategoryId int,CategoryName nvarchar(100),Level varchar(100),UID nvarchar(100));      
  INSERT INTO #tblSubClassificationtemp (CategoryId,CategoryName,Level,UID) SELECT CategoryId,CategoryName,Level,UID      
  FROM OPENJSON(@SecondaryClassification) WITH ([CategoryId] int,[CategoryName]  nvarchar(100), [Level] nvarchar(100),[UID]  nvarchar(100))      
      
  INSERT tblClassificationReferenceMaster (ClassificationRefId,ClassificationLevel,ModuleRefId,ModuleType,IsPrimary)      
  SELECT DISTINCT CategoryId,Level, @BlogId,'tblBlog',0 FROM #tblSubClassificationtemp cr       
  WHERE NOT EXISTS (SELECT * FROM #tblSubClassificationtemp cr       
  inner join tblClassificationReferenceMaster c on c.ClassificationRefId = cr.CategoryId  and c.ModuleRefId =  @BlogId and c.IsPrimary = 0)      
        
  delete tblClassificationReferenceMaster where ClassificationId in (      
  select Distinct ClassificationId from tblClassificationReferenceMaster c inner join #tblSubClassificationtemp cr on  c.ModuleRefId =  @BlogId  and c.ModuleType='tblBlog' and   c.IsPrimary = 0    
  WHERE classificationId not in (select c.ClassificationId from #tblSubClassificationtemp cr inner join tblClassificationReferenceMaster c on c.ClassificationRefId = cr.CategoryId    
  and c.ModuleRefId =  @BlogId and cr.Level = c.ClassificationLevel and c.IsPrimary = 0))     
    
  END        
        
  ELSE      
  BEGIN      
  DELETE tblClassificationReferenceMaster where ModuleRefId = @BlogId and IsPrimary = 0      
  END          
      
      
        -- update relatedblogs.It is may be more than one values separate with comma separator.
  IF(@RelatedBlogs != '')          
  BEGIN       
  CREATE TABLE #tblRelatedBlogs (RelatedBlog nvarchar(max))      
  INSERT INTO #tblRelatedBlogs(RelatedBlog)  SELECT DISTINCT value FROM [dbo].[fnSplitString](@RelatedBlogs)      
      
  INSERT INTO tblRelatedBlogs(BlogId,RelatedBlogs)       
  SELECT @BlogId, RelatedBlog FROM #tblRelatedBlogs bl      
  WHERE RelatedBlog NOT IN (SELECT RelatedBlog FROM #tblRelatedBlogs bl       
  INNER JOIN tblRelatedBlogs b on b.RelatedBlogs = bl.RelatedBlog and b.BlogId = @BlogId)      
  -- delete relatedblogs based on param @RelatedBlogs values
  DELETE FROM tblRelatedBlogs where RelatedBlogId in (      
  SELECT RelatedBlogId FROM tblRelatedBlogs B inner join  #tblRelatedBlogs bl on b.BlogId = @BlogId      
  WHERE NOT EXISTS (SELECT * from #tblRelatedBlogs bl where bl.RelatedBlog = b.RelatedBlogs and b.BlogId = @BlogId))      
  END      
      
  ELSE      
  BEGIN      
  DELETE tblRelatedBlogs where blogId = @BlogId       
  END        
      
   COMMIT TRANSACTION ;      
  select 'Success' ErrorMessage;       
    END TRY      
    BEGIN CATCH      
        IF @@TRANCOUNT > 0      
        BEGIN      
            ROLLBACK TRANSACTION ;      
   select ERROR_MESSAGE() AS ErrorMessage;       
        END      
    END CATCH      
 END;
GO
/****** Object:  StoredProcedure [dbo].[spUpdateDigipartnerProfile]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE procedure [dbo].[spUpdateDigipartnerProfile](  
@DigiPartnerProfileId int,  
@Email varchar(50),  
@CompanyName varchar(100),  
@Logo varchar(250),  
@Slogan varchar(max),  
@CompanyProfile nvarchar(max),  
@ProductProfile nvarchar(max),  
@HouseNumber varchar(25),  
@PostalCode varchar(25),  
@Place varchar(50),  
@Country varchar(50),  
@EmployeeCount varchar(20),  
@YearOfFounding varchar(10),  
@PhoneNumber varchar(25),  
@ContactPersonFirstName varchar(25),  
@ContactPersonLastName varchar(25),  
@PositionInCompany varchar(50),  
@RoleId int,  
@IsPublic bit
)  
as  
  -- update digipartner personal details based on Id
update tblDigiPartnerProfile set CompanyName=@CompanyName,Logo=@Logo,Slogan=@Slogan,CompanyProfile=@CompanyProfile,  
ProductProfile=@ProductProfile,HouseNumber=@HouseNumber,PostalCode=@PostalCode,Place=@Place,Country=@Country,EmployeeCount=@EmployeeCount,  
YearOfFounding=@YearOfFounding,PhoneNumber=@PhoneNumber,ContactPersonFirstName=@ContactPersonFirstName,ContactPersonLastName=@ContactPersonLastName,  
PositionInCompany=@PositionInCompany,RoleId=@RoleId,ModifiedDate=getdate(),IsPublic=@IsPublic  where DigiPartnerProfileId=@DigiPartnerProfileId;  

GO
/****** Object:  StoredProcedure [dbo].[spUpdateFollowUpMailContent]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[spUpdateFollowUpMailContent](@SurveyId int,@UserId int,@FollowUpMailContent nvarchar(max))
as 

begin
update tblUserSurvey set FollowUpMailContent=@FollowUpMailContent where SurveyId=@SurveyId and RespondentId=@UserId;
end
GO
/****** Object:  StoredProcedure [dbo].[spUpdateKMUUser]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[spUpdateKMUUser](      
@KMUUserId int,      
@SurName varchar(50),      
@FirstName varchar(50),      
@Title varchar(100),      
@Salutation varchar(20),      
@Email varchar(50),      
@PhoneNumber varchar(50),      
@Position varchar(50),      
@CompanyName varchar(100),      
@StreetAndHouseNo varchar(250),      
@PostalCode varchar(25),      
@Turnover varchar(50),      
@EmployeeCount varchar(20),     
@Country varchar(50),    
@SurveyId int,      
@IsSurveyCompleted bit,      
@GraphValues nvarchar(max)    
 )       
  as        
    BEGIN      
 -- Update KMUUser details   
    update tblKMUUser set SurName=@SurName,FirstName=@FirstName,Title=@Title,Salutation=@Salutation,PhoneNumber=@PhoneNumber,Position=@Position,      
 CompanyName=@CompanyName,StreetAndHouseNo=@StreetAndHouseNo,PostalCode=@PostalCode,Turnover=@Turnover,EmployeeCount=@EmployeeCount,Country=@Country,    
 UpdatedDate=getdate()      
 where KMUUserId=@KMUUserId;      
      
 if @IsSurveyCompleted=1       
 begin      
 -- check survey already completed.      
 if (select IsSurveyCompleted from tblUserSurvey where SurveyId=@SurveyId and RespondentId=@KMUUserId)=0      
 begin      
 update tblUserSurvey set IsSurveyCompleted=@IsSurveyCompleted,SurveyModifiedDate=GETDATE(),    
 GraphValues=@GraphValues where SurveyId=@SurveyId and RespondentId=@KMUUserId;      
    select 'Not send email' EmailTemplate,(select EmailTemplate from tblSurvey where  SurveyId=@SurveyId)HtmlContent;      
 end      
 else     
 update tblUserSurvey set IsSurveyCompleted=@IsSurveyCompleted,SurveyModifiedDate=GETDATE(),    
 GraphValues=@GraphValues where SurveyId=@SurveyId and RespondentId=@KMUUserId;   
 select 'Completed' EmailTemplate,(select EmailTemplate from tblSurvey where  SurveyId=@SurveyId)HtmlContent;      
 end      
            
END   
GO
/****** Object:  StoredProcedure [dbo].[spUpdateKMUUserDetails]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[spUpdateKMUUserDetails](  
@KMUUserId int,  
@SurName varchar(50),  
@FirstName varchar(50),  
@Title varchar(100),  
@Salutation varchar(20),  
@Email varchar(50),  
@PhoneNumber varchar(50),  
@Position varchar(50),  
@CompanyName varchar(100),  
@StreetAndHouseNo varchar(250),  
@PostalCode varchar(25),  
@Turnover varchar(50),  
@EmployeeCount varchar(20),
@Country varchar(50)
 )   
  as    
    BEGIN  
	-- Update KMUUser details 
   update tblKMUUser set SurName=@SurName,FirstName=@FirstName,Title=@Title,Salutation=@Salutation,PhoneNumber=@PhoneNumber,Position=@Position,  
 CompanyName=@CompanyName,StreetAndHouseNo=@StreetAndHouseNo,PostalCode=@PostalCode,Turnover=@Turnover,EmployeeCount=@EmployeeCount,Country=@Country,
 UpdatedDate=getdate()  
 where KMUUserId=@KMUUserId;  
 -- Select KMUUser details by KMUUserId 
 select KMUUserId UserId,SurName,FirstName,Title,Salutation,Email,PhoneNumber,Position,CompanyName,StreetAndHouseNo,PostalCode,Turnover,
 EmployeeCount,CreatedDate,UpdatedDate,PasswordUpdatedDate,Country from  tblKMUUser  where KMUUserId=@KMUUserId; 

END 
GO
/****** Object:  StoredProcedure [dbo].[spUpdatePasswordKMUUser]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
    
  CREATE procedure [dbo].[spUpdatePasswordKMUUser](@Password varchar(50),@Email varchar(50))
  as 
   declare @Status varchar(50);
    -- check email is already exist or not.
  if(select count(*) from  tblKMUUser where Email=@Email and IsDeleted=0)> 0
  begin
   update  tblKMUUser set Password=@Password,PasswordUpdatedDate=getdate()  where Email=@Email and IsDeleted=0; 
  set @Status='Success';
  end
   else
   begin
   set @Status='Invalid user';
   end
    select @Status as Status;
GO
/****** Object:  StoredProcedure [dbo].[spUpdatePasswordMDUser]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

   
  CREATE procedure [dbo].[spUpdatePasswordMDUser](@Password varchar(50),@Email varchar(50))
  as 
   declare @Status varchar(50);
   -- check email already exist.if email is exist update password,otherwise return invalid user
  if(select count(*) from  tblMatchdigitalUser where Email=@Email and IsDeleted=0)> 0  
  begin
   update  tblMatchdigitalUser set Password=@Password,PasswordUpdatedDate=getdate()  where Email=@Email and IsDeleted=0; 
  set @Status='Success';
  end
   else
   begin
   set @Status='Invalid user';
   end
    select @Status as Status;
GO
/****** Object:  StoredProcedure [dbo].[spUpdatePasswordProfileUser]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

  CREATE procedure [dbo].[spUpdatePasswordProfileUser](@Password varchar(50),@Email varchar(50))
  as 
   declare @Status varchar(50);
   -- check email already exist in tblDigiPartnerProfile
  if(select count(*) from  tblDigiPartnerProfile where Email=@Email and IsDeleted=0)> 0
  begin
   update  tblDigiPartnerProfile set Password=@Password,PasswordUpdatedDate=getdate()  where Email=@Email; 
  set @Status='Success';
  end
   else
   begin
   set @Status='Invalid user';
   end
    select @Status as Status;
GO
/****** Object:  StoredProcedure [dbo].[spUpdateProject]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 
CREATE PROCEDURE [dbo].[spUpdateProject]  
(  
@ProjectId INT,  
@UserId varchar(max),   
@KMUUserId varchar(max))  
AS  
 BEGIN  
    
    BEGIN TRANSACTION;   
    BEGIN TRY  
   -- move UserId record in temp table    
  create table #tblProjectUserId (UserId int,ProjectId int);    
  INSERT INTO #tblProjectUserId (UserId,ProjectId) SELECT DISTINCT  Value,@ProjectId FROM [dbo].[fnSplitComma]( @UserId );    
  -- insert not exist UserId record    
  INSERT tblProjectOwner(UserId,ProjectId)SELECT DISTINCT UserId,ProjectId FROM #tblProjectUserId cr     
  WHERE NOT EXISTS (SELECT UserId,ProjectId FROM tblProjectOwner c    
  WHERE cr.UserId= c.UserId and cr.ProjectId=c.ProjectId);    
    
  -- delete remaining UserId record     
   DELETE FROM tblProjectOwner WHERE UserId Is not null and ProjectId=@ProjectId and UserId    
    NOT IN (SELECT f.UserId FROM #tblProjectUserId f);  
     
  -- move KMUUserId record in temp table   
  create table #tblProjectKMUUserId (KMUUserId int,ProjectId int);    
  INSERT INTO #tblProjectKMUUserId (KMUUserId,ProjectId) SELECT DISTINCT  Value,@ProjectId FROM [dbo].[fnSplitComma]( @KMUUserId );    
  -- insert not exist KMUUserId record    
  INSERT tblProjectOwner(KMUUserId,ProjectId)SELECT DISTINCT KMUUserId,ProjectId FROM #tblProjectKMUUserId cr     
  WHERE NOT EXISTS (SELECT KMUUserId,ProjectId FROM tblProjectOwner c    
  WHERE cr.KMUUserId= c.KMUUserId and cr.ProjectId=c.ProjectId);    
    
  -- delete remaining KMUUserId record     

   DELETE FROM tblProjectOwner WHERE KMUUserId Is not null and ProjectId=@ProjectId and KMUUserId    
   NOT IN (SELECT f.KMUUserId FROM #tblProjectKMUUserId f);  
 
 COMMIT TRANSACTION ;  
  select 'Success' ErrorMessage;   
    END TRY  
    BEGIN CATCH  
        IF @@TRANCOUNT > 0  
        BEGIN  
            ROLLBACK TRANSACTION ;  
   select ERROR_MESSAGE() AS ErrorMessage;   
        END  
    END CATCH  
   
 END  
GO
/****** Object:  StoredProcedure [dbo].[spUpdateSuccessStoryStatus]    Script Date: 8/9/2019 7:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
   create procedure [dbo].[spUpdateSuccessStoryStatus](
 @SuccessStoryId int,@Status varchar(25)
 )
 as
update tblSuccessStory set Status=@Status where SuccessStoryId=@SuccessStoryId
GO
ALTER DATABASE [DevSurvey] SET  READ_WRITE 
GO
