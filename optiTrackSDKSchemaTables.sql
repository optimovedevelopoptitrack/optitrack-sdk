USE [optimove_visitors_A]
GO
/****** Object:  Schema [exp]    Script Date: 27/7/2017 3:19:16 PM ******/
CREATE SCHEMA [exp]
GO
/****** Object:  Schema [optitrack]    Script Date: 27/7/2017 3:19:16 PM ******/
CREATE SCHEMA [optitrack]
GO
/****** Object:  Schema [optitrackSDK]    Script Date: 27/7/2017 3:19:16 PM ******/
CREATE SCHEMA [optitrackSDK]
GO
/****** Object:  Schema [vis]    Script Date: 27/7/2017 3:19:16 PM ******/
CREATE SCHEMA [vis]
GO
/****** Object:  Table [optitrackSDK].[Config]    Script Date: 27/7/2017 3:19:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [optitrackSDK].[Config](
	[LastAggregatedVisitId] [bigint] NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Table [optitrackSDK].[CustomersBeforeRegister_TMP]    Script Date: 27/7/2017 3:19:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [optitrackSDK].[CustomersBeforeRegister_TMP](
	[CustomerId] [nvarchar](255) NOT NULL,
	[OriginalVisitorID] [varchar](255) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [optitrackSDK].[CustomEventsParametersUpdateStatus]    Script Date: 27/7/2017 3:19:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [optitrackSDK].[CustomEventsParametersUpdateStatus](
	[EventId] [int] NOT NULL,
	[ParamId] [tinyint] NOT NULL,
	[ParameterType] [nvarchar](16) NOT NULL,
	[NumberofValues] [tinyint] NOT NULL,
	[LastUpdateDate] [date] NOT NULL,
	[supportUpload] [bit] NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Table [optitrackSDK].[CustomEventsParametersValues]    Script Date: 27/7/2017 3:19:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [optitrackSDK].[CustomEventsParametersValues](
	[EventId] [int] NOT NULL,
	[ParamId] [tinyint] NOT NULL,
	[ParamValue] [nvarchar](255) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [optitrackSDK].[CustomEventsPiwikMapping]    Script Date: 27/7/2017 3:19:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [optitrackSDK].[CustomEventsPiwikMapping](
	[IdAction] [bigint] NOT NULL,
	[EventId] [tinyint] NOT NULL,
	[EventName] [nvarchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[IdAction] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [optitrackSDK].[CustomEventsRowData]    Script Date: 27/7/2017 3:19:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [optitrackSDK].[CustomEventsRowData](
	[EventDateTime] [smalldatetime] NOT NULL,
	[EventId] [tinyint] NOT NULL,
	[CustomerId] [bigint] NOT NULL,
	[Parameter1] [nvarchar](255) NULL,
	[Parameter2] [nvarchar](255) NULL,
	[Parameter3] [nvarchar](255) NULL,
	[Parameter4] [nvarchar](255) NULL,
	[Parameter5] [nvarchar](255) NULL,
	[Parameter6] [nvarchar](255) NULL,
	[Parameter7] [nvarchar](255) NULL,
	[Parameter8] [nvarchar](255) NULL,
	[Parameter9] [nvarchar](255) NULL,
	[Parameter10] [nvarchar](255) NULL,
	[Parameter11] [nvarchar](255) NULL,
	[Parameter12] [nvarchar](255) NULL,
	[Parameter13] [nvarchar](255) NULL,
	[Parameter14] [nvarchar](255) NULL,
	[Parameter15] [nvarchar](255) NULL,
	[Parameter16] [nvarchar](255) NULL,
	[Parameter17] [nvarchar](255) NULL,
	[Parameter18] [nvarchar](255) NULL,
	[Parameter19] [nvarchar](255) NULL,
	[Parameter20] [nvarchar](255) NULL,
	[Parameter21] [nvarchar](255) NULL,
	[Parameter22] [nvarchar](255) NULL,
	[Parameter23] [nvarchar](255) NULL
) ON [PRIMARY]

GO
/****** Object:  Index [IX_EventDateTimeEventId]    Script Date: 27/7/2017 3:19:17 PM ******/
CREATE CLUSTERED INDEX [IX_EventDateTimeEventId] ON [optitrackSDK].[CustomEventsRowData]
(
	[EventDateTime] DESC,
	[EventId] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [optitrackSDK].[EmailRegister]    Script Date: 27/7/2017 3:19:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [optitrackSDK].[EmailRegister](
	[CustomerId] [bigint] NOT NULL,
	[Hash] [nvarchar](64) NOT NULL,
	[Email] [nvarchar](255) NOT NULL,
	[EventDateTime] [smalldatetime] NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ix_CustomerIdHash]    Script Date: 27/7/2017 3:19:17 PM ******/
CREATE UNIQUE CLUSTERED INDEX [ix_CustomerIdHash] ON [optitrackSDK].[EmailRegister]
(
	[CustomerId] ASC,
	[Hash] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = ON, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Table [optitrackSDK].[Language]    Script Date: 27/7/2017 3:19:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [optitrackSDK].[Language](
	[LanguageId] [int] NOT NULL,
	[Language] [nvarchar](8) NULL
) ON [PRIMARY]

GO
/****** Object:  Index [ix_LanguageId]    Script Date: 27/7/2017 3:19:17 PM ******/
CREATE UNIQUE CLUSTERED INDEX [ix_LanguageId] ON [optitrackSDK].[Language]
(
	[LanguageId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Table [optitrackSDK].[LocationCity]    Script Date: 27/7/2017 3:19:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [optitrackSDK].[LocationCity](
	[LocationCityId] [int] NOT NULL,
	[LocationCity] [nvarchar](8) NULL
) ON [PRIMARY]

GO
/****** Object:  Index [ix_LocationCityId]    Script Date: 27/7/2017 3:19:17 PM ******/
CREATE UNIQUE CLUSTERED INDEX [ix_LocationCityId] ON [optitrackSDK].[LocationCity]
(
	[LocationCityId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Table [optitrackSDK].[LogEventPiwikMapping]    Script Date: 27/7/2017 3:19:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [optitrackSDK].[LogEventPiwikMapping](
	[IdAction] [bigint] NOT NULL,
	[EventName] [nvarchar](255) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [optitrackSDK].[OptimoveAlias]    Script Date: 27/7/2017 3:19:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [optitrackSDK].[OptimoveAlias](
	[VisitorId] [nvarchar](200) NOT NULL,
	[CustomerId] [nvarchar](200) NOT NULL,
	[IsUnique] [bit] NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Table [optitrackSDK].[OptitrackVersion]    Script Date: 27/7/2017 3:19:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [optitrackSDK].[OptitrackVersion](
	[Version] [nvarchar](200) NULL,
	[isSupportedOptitrack] [bit] NULL,
	[ConversionDate] [datetime] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [optitrackSDK].[PagesCategories]    Script Date: 27/7/2017 3:19:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [optitrackSDK].[PagesCategories](
	[Id] [int] NOT NULL,
	[PageCategory] [nvarchar](255) NOT NULL,
	[Hash] [nvarchar](64) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [optitrackSDK].[PagesCategoriesEventsRowData]    Script Date: 27/7/2017 3:19:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [optitrackSDK].[PagesCategoriesEventsRowData](
	[VisitDateTime] [smalldatetime] NOT NULL,
	[VisitId] [bigint] NOT NULL,
	[CustomerId] [bigint] NOT NULL,
	[PageCategoryID] [int] NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Index [IX_VisitDateTimeVisitId]    Script Date: 27/7/2017 3:19:17 PM ******/
CREATE CLUSTERED INDEX [IX_VisitDateTimeVisitId] ON [optitrackSDK].[PagesCategoriesEventsRowData]
(
	[VisitDateTime] DESC,
	[VisitId] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [optitrackSDK].[PageTitle]    Script Date: 27/7/2017 3:19:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [optitrackSDK].[PageTitle](
	[PageTitleID] [bigint] NOT NULL,
	[Title] [nvarchar](2100) NULL,
PRIMARY KEY CLUSTERED 
(
	[PageTitleID] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [optitrackSDK].[PageVisitEventsRowData]    Script Date: 27/7/2017 3:19:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [optitrackSDK].[PageVisitEventsRowData](
	[VisitDateTime] [smalldatetime] NOT NULL,
	[VisitId] [bigint] NOT NULL,
	[CustomerId] [bigint] NOT NULL,
	[URLID] [bigint] NOT NULL,
	[PageTitleId] [bigint] NOT NULL,
	[NumOfOccurrences] [int] NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Index [IX_VisitDateTime]    Script Date: 27/7/2017 3:19:17 PM ******/
CREATE CLUSTERED INDEX [IX_VisitDateTime] ON [optitrackSDK].[PageVisitEventsRowData]
(
	[VisitDateTime] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [optitrackSDK].[PiwikIdentity]    Script Date: 27/7/2017 3:19:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [optitrackSDK].[PiwikIdentity](
	[TableName] [nvarchar](50) NOT NULL,
	[Id] [bigint] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [optitrackSDK].[PiwikVisit]    Script Date: 27/7/2017 3:19:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [optitrackSDK].[PiwikVisit](
	[Id] [bigint] NOT NULL,
	[UserId] [nvarchar](200) NULL,
	[VisitorId] [nvarchar](200) NULL,
	[VisitFirstActionTime] [datetime] NULL,
	[VisitLastActionTime] [datetime] NULL,
	[Referer] [nvarchar](200) NULL,
	[Platform] [nvarchar](200) NULL,
	[IsUnique] [bit] NOT NULL,
	[Campaign_name] [nvarchar](255) NULL DEFAULT (NULL),
	[Campaign_keyword] [nvarchar](255) NULL DEFAULT (NULL),
	[Campaign_source] [nvarchar](255) NULL DEFAULT (NULL),
	[Campaign_medium] [nvarchar](255) NULL DEFAULT (NULL),
	[Campaign_content] [nvarchar](255) NULL DEFAULT (NULL),
	[Campaign_id] [nvarchar](100) NULL DEFAULT (NULL),
	[GEO_Location] [varchar](255) NULL DEFAULT (NULL),
	[Location_latitude] [decimal](9, 6) NULL,
	[Location_longitude] [decimal](9, 6) NULL,
	[IP] [varchar](64) NULL,
	[Language] [varchar](16) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Index [CIX_ID]    Script Date: 27/7/2017 3:19:17 PM ******/
CREATE UNIQUE CLUSTERED INDEX [CIX_ID] ON [optitrackSDK].[PiwikVisit]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = ON, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [optitrackSDK].[PiwikVisitAction]    Script Date: 27/7/2017 3:19:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [optitrackSDK].[PiwikVisitAction](
	[Id] [bigint] NOT NULL,
	[VisitId] [bigint] NULL,
	[VisitorId] [nvarchar](200) NULL,
	[EventActionTime] [datetime] NOT NULL,
	[UrlActionId] [int] NULL,
	[UrlRefActionID] [int] NULL,
	[ActionNameId] [int] NULL,
	[ActionNameRefId] [int] NULL,
	[ActionEventCategoryId] [int] NULL,
	[ActionEventId] [int] NULL,
	[TimeSpent] [int] NULL,
	[TimeSpentRefAction] [int] NULL,
	[custom_dimension_1] [nvarchar](255) NULL,
	[custom_dimension_2] [nvarchar](255) NULL,
	[custom_dimension_3] [nvarchar](255) NULL,
	[custom_dimension_4] [nvarchar](255) NULL,
	[custom_dimension_5] [nvarchar](255) NULL,
	[custom_dimension_6] [nvarchar](255) NULL,
	[custom_dimension_7] [nvarchar](255) NULL,
	[custom_dimension_8] [nvarchar](255) NULL,
	[custom_dimension_9] [nvarchar](255) NULL,
	[custom_dimension_10] [nvarchar](255) NULL,
	[custom_dimension_11] [nvarchar](255) NULL,
	[custom_dimension_12] [nvarchar](255) NULL,
	[custom_dimension_13] [nvarchar](255) NULL,
	[custom_dimension_14] [nvarchar](255) NULL,
	[custom_dimension_15] [nvarchar](255) NULL,
	[custom_dimension_16] [nvarchar](255) NULL,
	[custom_dimension_17] [nvarchar](255) NULL,
	[custom_dimension_18] [nvarchar](255) NULL,
	[custom_dimension_19] [nvarchar](255) NULL,
	[custom_dimension_20] [nvarchar](255) NULL,
	[custom_dimension_21] [nvarchar](255) NULL,
	[custom_dimension_22] [nvarchar](255) NULL,
	[custom_dimension_23] [nvarchar](255) NULL,
	[custom_dimension_24] [nvarchar](255) NULL,
	[custom_dimension_25] [nvarchar](255) NULL
) ON [PRIMARY]

GO
/****** Object:  Index [cix_EventActionTime]    Script Date: 27/7/2017 3:19:17 PM ******/
CREATE CLUSTERED INDEX [cix_EventActionTime] ON [optitrackSDK].[PiwikVisitAction]
(
	[EventActionTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [optitrackSDK].[Platform]    Script Date: 27/7/2017 3:19:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [optitrackSDK].[Platform](
	[PlatformId] [int] NOT NULL,
	[Platform] [nvarchar](8) NULL
) ON [PRIMARY]

GO
/****** Object:  Index [ix_PlatformId]    Script Date: 27/7/2017 3:19:17 PM ******/
CREATE UNIQUE CLUSTERED INDEX [ix_PlatformId] ON [optitrackSDK].[Platform]
(
	[PlatformId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Table [optitrackSDK].[SetUserIdEvent]    Script Date: 27/7/2017 3:19:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [optitrackSDK].[SetUserIdEvent](
	[VisitId] [bigint] NOT NULL,
	[OriginalvisitorId] [nvarchar](200) NOT NULL,
	[UpdatedVisitorId] [nvarchar](200) NOT NULL,
	[PublicUserId] [nvarchar](200) NOT NULL,
	[FirstTimeEventDateTime] [smalldatetime] NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_VisitIdOriginalvisitorId]    Script Date: 27/7/2017 3:19:17 PM ******/
CREATE UNIQUE CLUSTERED INDEX [IX_VisitIdOriginalvisitorId] ON [optitrackSDK].[SetUserIdEvent]
(
	[VisitId] DESC,
	[OriginalvisitorId] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [optitrackSDK].[SplittedVisitData]    Script Date: 27/7/2017 3:19:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [optitrackSDK].[SplittedVisitData](
	[Id] [bigint] NOT NULL,
	[UserId] [nvarchar](200) NULL,
	[VisitorId] [nvarchar](200) NULL,
	[VisitLastActionTime] [datetime] NULL
) ON [PRIMARY]

GO
/****** Object:  Index [CIX_ID]    Script Date: 27/7/2017 3:19:17 PM ******/
CREATE UNIQUE CLUSTERED INDEX [CIX_ID] ON [optitrackSDK].[SplittedVisitData]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = ON, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [optitrackSDK].[SplittedVisitIds_TEMP]    Script Date: 27/7/2017 3:19:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [optitrackSDK].[SplittedVisitIds_TEMP](
	[VisitId] [bigint] NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Index [CIX_VisitId]    Script Date: 27/7/2017 3:19:17 PM ******/
CREATE UNIQUE CLUSTERED INDEX [CIX_VisitId] ON [optitrackSDK].[SplittedVisitIds_TEMP]
(
	[VisitId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = ON, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [optitrackSDK].[TotalCustomerDailyEvents]    Script Date: 27/7/2017 3:19:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [optitrackSDK].[TotalCustomerDailyEvents](
	[EventDate] [smalldatetime] NOT NULL,
	[CustomerId] [bigint] NOT NULL,
	[NumberOfDailyEvents] [int] NULL
) ON [PRIMARY]

GO
/****** Object:  Index [IX_EventDateCustomerId]    Script Date: 27/7/2017 3:19:17 PM ******/
CREATE UNIQUE CLUSTERED INDEX [IX_EventDateCustomerId] ON [optitrackSDK].[TotalCustomerDailyEvents]
(
	[EventDate] DESC,
	[CustomerId] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [optitrackSDK].[TotalDailyAggregationPerEvent]    Script Date: 27/7/2017 3:19:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [optitrackSDK].[TotalDailyAggregationPerEvent](
	[EventDate] [smalldatetime] NOT NULL,
	[CustomerId] [bigint] NOT NULL,
	[EventID] [tinyint] NOT NULL,
	[NumberOfDailyEvent] [int] NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Index [IX_EventDateCustomerId]    Script Date: 27/7/2017 3:19:17 PM ******/
CREATE CLUSTERED INDEX [IX_EventDateCustomerId] ON [optitrackSDK].[TotalDailyAggregationPerEvent]
(
	[EventDate] DESC,
	[CustomerId] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [optitrackSDK].[TotalDailyPagesCategoriesAggregation]    Script Date: 27/7/2017 3:19:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [optitrackSDK].[TotalDailyPagesCategoriesAggregation](
	[Date] [date] NOT NULL,
	[CustomerId] [bigint] NOT NULL,
	[PageCategoryID] [int] NOT NULL,
	[NumOfPageVisits] [int] NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Index [IX_DateCustomerId]    Script Date: 27/7/2017 3:19:17 PM ******/
CREATE CLUSTERED INDEX [IX_DateCustomerId] ON [optitrackSDK].[TotalDailyPagesCategoriesAggregation]
(
	[Date] DESC,
	[CustomerId] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [optitrackSDK].[TotalDailyPagesVisitsAggregation]    Script Date: 27/7/2017 3:19:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [optitrackSDK].[TotalDailyPagesVisitsAggregation](
	[Date] [date] NOT NULL,
	[CustomerId] [bigint] NOT NULL,
	[NumOfPageVisits] [int] NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Index [IX_DateCustomerId]    Script Date: 27/7/2017 3:19:17 PM ******/
CREATE CLUSTERED INDEX [IX_DateCustomerId] ON [optitrackSDK].[TotalDailyPagesVisitsAggregation]
(
	[Date] DESC,
	[CustomerId] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [optitrackSDK].[TotalDailySinglePageTitleAggregation]    Script Date: 27/7/2017 3:19:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [optitrackSDK].[TotalDailySinglePageTitleAggregation](
	[Date] [date] NOT NULL,
	[CustomerId] [bigint] NOT NULL,
	[PageTitleID] [bigint] NOT NULL,
	[NumOfTotalPageVisits] [int] NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Index [IX_DateCustomerId]    Script Date: 27/7/2017 3:19:17 PM ******/
CREATE CLUSTERED INDEX [IX_DateCustomerId] ON [optitrackSDK].[TotalDailySinglePageTitleAggregation]
(
	[Date] DESC,
	[CustomerId] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [optitrackSDK].[TotalDailySinglePageVisitsAggregation]    Script Date: 27/7/2017 3:19:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [optitrackSDK].[TotalDailySinglePageVisitsAggregation](
	[Date] [date] NOT NULL,
	[CustomerId] [bigint] NOT NULL,
	[URLID] [bigint] NOT NULL,
	[NumOfTotalPageVisits] [int] NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Index [IX_DateCustomerId]    Script Date: 27/7/2017 3:19:17 PM ******/
CREATE CLUSTERED INDEX [IX_DateCustomerId] ON [optitrackSDK].[TotalDailySinglePageVisitsAggregation]
(
	[Date] DESC,
	[CustomerId] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [optitrackSDK].[TotalVisitsInfoAggregation ]    Script Date: 27/7/2017 3:19:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [optitrackSDK].[TotalVisitsInfoAggregation ](
	[Date] [smalldatetime] NOT NULL,
	[CustomerId] [bigint] NOT NULL,
	[TotalVisitTime] [int] NOT NULL,
	[TotalNumberOfVisits] [int] NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Index [IX_DateCustomerId]    Script Date: 27/7/2017 3:19:17 PM ******/
CREATE UNIQUE CLUSTERED INDEX [IX_DateCustomerId] ON [optitrackSDK].[TotalVisitsInfoAggregation ]
(
	[Date] DESC,
	[CustomerId] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [optitrackSDK].[URL]    Script Date: 27/7/2017 3:19:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [optitrackSDK].[URL](
	[URLID] [bigint] NOT NULL,
	[URL] [nvarchar](2100) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[URLID] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [optitrackSDK].[UserAgentHeaderEvent]    Script Date: 27/7/2017 3:19:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [optitrackSDK].[UserAgentHeaderEvent](
	[CustomerId] [bigint] NOT NULL,
	[UserAgentId] [int] NOT NULL,
	[FirstRecognitionEventDateTime] [smalldatetime] NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Index [IX_CustomerId]    Script Date: 27/7/2017 3:19:17 PM ******/
CREATE CLUSTERED INDEX [IX_CustomerId] ON [optitrackSDK].[UserAgentHeaderEvent]
(
	[CustomerId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [optitrackSDK].[UserAgentsId]    Script Date: 27/7/2017 3:19:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [optitrackSDK].[UserAgentsId](
	[UserAgentId] [int] NOT NULL,
	[Hash] [nvarchar](64) NOT NULL,
	[UserAgent] [nvarchar](255) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[UserAgentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [optitrackSDK].[VisitInfoRowData]    Script Date: 27/7/2017 3:19:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [optitrackSDK].[VisitInfoRowData](
	[EventDate] [smalldatetime] NOT NULL,
	[VisitId] [bigint] NOT NULL,
	[CustomerId] [bigint] NOT NULL,
	[PlatformId] [int] NULL,
	[LocationCityId] [int] NULL,
	[IP] [nvarchar](64) NOT NULL,
	[LanguageId] [int] NULL,
	[TotalVisitTime] [int] NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Index [IX_EventDateVisitId]    Script Date: 27/7/2017 3:19:17 PM ******/
CREATE UNIQUE CLUSTERED INDEX [IX_EventDateVisitId] ON [optitrackSDK].[VisitInfoRowData]
(
	[EventDate] DESC,
	[VisitId] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [optitrackSDK].[VisitorMappedTypes]    Script Date: 27/7/2017 3:19:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [optitrackSDK].[VisitorMappedTypes](
	[TypeId] [int] NOT NULL,
	[Type] [nvarchar](16) NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Table [optitrackSDK].[VisitorsConversion]    Script Date: 27/7/2017 3:19:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [optitrackSDK].[VisitorsConversion](
	[CLIENT_CUSTOMER_ID] [nvarchar](200) NULL,
	[Customer_ID] [bigint] NULL,
	[VisitId] [bigint] NOT NULL,
	[VisitorId] [nvarchar](200) NULL,
	[OriginalVisitorID] [varchar](255) NULL,
	[Platform] [nvarchar](200) NULL,
	[ConversionDate] [smalldatetime] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ix_CLIENT_CUSTOMER_IDVisitorId]    Script Date: 27/7/2017 3:19:17 PM ******/
CREATE UNIQUE CLUSTERED INDEX [ix_CLIENT_CUSTOMER_IDVisitorId] ON [optitrackSDK].[VisitorsConversion]
(
	[CLIENT_CUSTOMER_ID] DESC,
	[Customer_ID] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = ON, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Table [optitrackSDK].[VisitorsMapping]    Script Date: 27/7/2017 3:19:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [optitrackSDK].[VisitorsMapping](
	[CLIENT_CUSTOMER_ID] [nvarchar](200) NULL,
	[VisitorId] [nvarchar](200) NULL,
	[Customer_ID] [bigint] NULL,
	[Type] [int] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ix_CLIENT_CUSTOMER_ID_VisitorId]    Script Date: 27/7/2017 3:19:17 PM ******/
CREATE UNIQUE CLUSTERED INDEX [ix_CLIENT_CUSTOMER_ID_VisitorId] ON [optitrackSDK].[VisitorsMapping]
(
	[CLIENT_CUSTOMER_ID] DESC,
	[VisitorId] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Table [vis].[VisitorOptimoveIds]    Script Date: 27/7/2017 3:19:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [vis].[VisitorOptimoveIds](
	[CUSTOMER_ID] [bigint] NOT NULL,
	[VISITOR_ID] [nvarchar](1000) NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Index [CIX_CUSTOMER_ID]    Script Date: 27/7/2017 3:19:17 PM ******/
CREATE UNIQUE CLUSTERED INDEX [CIX_CUSTOMER_ID] ON [vis].[VisitorOptimoveIds]
(
	[CUSTOMER_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ix_CustomerIDOriginalVisitorID]    Script Date: 27/7/2017 3:19:17 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [ix_CustomerIDOriginalVisitorID] ON [optitrackSDK].[CustomersBeforeRegister_TMP]
(
	[CustomerId] ASC,
	[OriginalVisitorID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = ON, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [ix_EventId]    Script Date: 27/7/2017 3:19:17 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [ix_EventId] ON [optitrackSDK].[CustomEventsParametersUpdateStatus]
(
	[EventId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = ON, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [ix_ParamId]    Script Date: 27/7/2017 3:19:17 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [ix_ParamId] ON [optitrackSDK].[CustomEventsParametersUpdateStatus]
(
	[ParamId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = ON, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [ix_EventId]    Script Date: 27/7/2017 3:19:17 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [ix_EventId] ON [optitrackSDK].[CustomEventsParametersValues]
(
	[EventId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = ON, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [ix_ParamId]    Script Date: 27/7/2017 3:19:17 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [ix_ParamId] ON [optitrackSDK].[CustomEventsParametersValues]
(
	[ParamId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = ON, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [ix_EventId]    Script Date: 27/7/2017 3:19:17 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [ix_EventId] ON [optitrackSDK].[CustomEventsPiwikMapping]
(
	[EventId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = ON, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_CustomerId]    Script Date: 27/7/2017 3:19:17 PM ******/
CREATE NONCLUSTERED INDEX [IX_CustomerId] ON [optitrackSDK].[CustomEventsRowData]
(
	[CustomerId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_EventDateTime]    Script Date: 27/7/2017 3:19:17 PM ******/
CREATE NONCLUSTERED INDEX [IX_EventDateTime] ON [optitrackSDK].[EmailRegister]
(
	[EventDateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_CustomerId]    Script Date: 27/7/2017 3:19:17 PM ******/
CREATE NONCLUSTERED INDEX [IX_CustomerId] ON [optitrackSDK].[OptimoveAlias]
(
	[CustomerId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ix_VisitorIdCustomerID]    Script Date: 27/7/2017 3:19:17 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [ix_VisitorIdCustomerID] ON [optitrackSDK].[OptimoveAlias]
(
	[VisitorId] ASC,
	[CustomerId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = ON, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_Hash]    Script Date: 27/7/2017 3:19:17 PM ******/
CREATE NONCLUSTERED INDEX [IX_Hash] ON [optitrackSDK].[PagesCategories]
(
	[Hash] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_CustomerId]    Script Date: 27/7/2017 3:19:17 PM ******/
CREATE NONCLUSTERED INDEX [IX_CustomerId] ON [optitrackSDK].[PagesCategoriesEventsRowData]
(
	[CustomerId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_CustomerId]    Script Date: 27/7/2017 3:19:17 PM ******/
CREATE NONCLUSTERED INDEX [IX_CustomerId] ON [optitrackSDK].[PageVisitEventsRowData]
(
	[CustomerId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_PageTitleId]    Script Date: 27/7/2017 3:19:17 PM ******/
CREATE NONCLUSTERED INDEX [IX_PageTitleId] ON [optitrackSDK].[PageVisitEventsRowData]
(
	[PageTitleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_URLID]    Script Date: 27/7/2017 3:19:17 PM ******/
CREATE NONCLUSTERED INDEX [IX_URLID] ON [optitrackSDK].[PageVisitEventsRowData]
(
	[URLID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_VisitId]    Script Date: 27/7/2017 3:19:17 PM ******/
CREATE NONCLUSTERED INDEX [IX_VisitId] ON [optitrackSDK].[PageVisitEventsRowData]
(
	[VisitId] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_UserIdVisitFirstActionTime]    Script Date: 27/7/2017 3:19:17 PM ******/
CREATE NONCLUSTERED INDEX [IX_UserIdVisitFirstActionTime] ON [optitrackSDK].[PiwikVisit]
(
	[UserId] ASC,
	[VisitFirstActionTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Id]    Script Date: 27/7/2017 3:19:17 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_Id] ON [optitrackSDK].[PiwikVisitAction]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = ON, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ix_VisitorIdId]    Script Date: 27/7/2017 3:19:17 PM ******/
CREATE NONCLUSTERED INDEX [ix_VisitorIdId] ON [optitrackSDK].[PiwikVisitAction]
(
	[VisitorId] ASC,
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_PublicUserId]    Script Date: 27/7/2017 3:19:17 PM ******/
CREATE NONCLUSTERED INDEX [IX_PublicUserId] ON [optitrackSDK].[SetUserIdEvent]
(
	[PublicUserId] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_UpdatedVisitorId]    Script Date: 27/7/2017 3:19:17 PM ******/
CREATE NONCLUSTERED INDEX [IX_UpdatedVisitorId] ON [optitrackSDK].[SetUserIdEvent]
(
	[UpdatedVisitorId] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_EventID]    Script Date: 27/7/2017 3:19:17 PM ******/
CREATE NONCLUSTERED INDEX [IX_EventID] ON [optitrackSDK].[TotalDailyAggregationPerEvent]
(
	[EventID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_NumOfPageVisits]    Script Date: 27/7/2017 3:19:17 PM ******/
CREATE NONCLUSTERED INDEX [IX_NumOfPageVisits] ON [optitrackSDK].[TotalDailyPagesCategoriesAggregation]
(
	[NumOfPageVisits] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_PageCategoryID]    Script Date: 27/7/2017 3:19:17 PM ******/
CREATE NONCLUSTERED INDEX [IX_PageCategoryID] ON [optitrackSDK].[TotalDailyPagesCategoriesAggregation]
(
	[PageCategoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_NumOfPageVisits]    Script Date: 27/7/2017 3:19:17 PM ******/
CREATE NONCLUSTERED INDEX [IX_NumOfPageVisits] ON [optitrackSDK].[TotalDailyPagesVisitsAggregation]
(
	[NumOfPageVisits] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_PageTitleID]    Script Date: 27/7/2017 3:19:17 PM ******/
CREATE NONCLUSTERED INDEX [IX_PageTitleID] ON [optitrackSDK].[TotalDailySinglePageTitleAggregation]
(
	[PageTitleID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_URLID]    Script Date: 27/7/2017 3:19:17 PM ******/
CREATE NONCLUSTERED INDEX [IX_URLID] ON [optitrackSDK].[TotalDailySinglePageVisitsAggregation]
(
	[URLID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_FirstRecognitionEventDateTime]    Script Date: 27/7/2017 3:19:17 PM ******/
CREATE NONCLUSTERED INDEX [IX_FirstRecognitionEventDateTime] ON [optitrackSDK].[UserAgentHeaderEvent]
(
	[FirstRecognitionEventDateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_UserAgentId]    Script Date: 27/7/2017 3:19:17 PM ******/
CREATE NONCLUSTERED INDEX [IX_UserAgentId] ON [optitrackSDK].[UserAgentHeaderEvent]
(
	[UserAgentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_Hash]    Script Date: 27/7/2017 3:19:17 PM ******/
CREATE NONCLUSTERED INDEX [IX_Hash] ON [optitrackSDK].[UserAgentsId]
(
	[Hash] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_LanguageId]    Script Date: 27/7/2017 3:19:17 PM ******/
CREATE NONCLUSTERED INDEX [IX_LanguageId] ON [optitrackSDK].[VisitInfoRowData]
(
	[LanguageId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_LocationCityId]    Script Date: 27/7/2017 3:19:17 PM ******/
CREATE NONCLUSTERED INDEX [IX_LocationCityId] ON [optitrackSDK].[VisitInfoRowData]
(
	[LocationCityId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_PlatformId]    Script Date: 27/7/2017 3:19:17 PM ******/
CREATE NONCLUSTERED INDEX [IX_PlatformId] ON [optitrackSDK].[VisitInfoRowData]
(
	[PlatformId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [ix_Customer_ID]    Script Date: 27/7/2017 3:19:17 PM ******/
CREATE NONCLUSTERED INDEX [ix_Customer_ID] ON [optitrackSDK].[VisitorsMapping]
(
	[Customer_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [CIX_VISITOR_ID]    Script Date: 27/7/2017 3:19:17 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [CIX_VISITOR_ID] ON [vis].[VisitorOptimoveIds]
(
	[VISITOR_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = ON, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [optitrackSDK].[CustomersBeforeRegister_TMP] ADD  DEFAULT (NULL) FOR [OriginalVisitorID]
GO
ALTER TABLE [optitrackSDK].[OptitrackVersion] ADD  DEFAULT ((0)) FOR [isSupportedOptitrack]
GO
ALTER TABLE [optitrackSDK].[VisitorsConversion] ADD  DEFAULT (NULL) FOR [OriginalVisitorID]
GO
