
CREATE TABLE [optitrackSDK].[AlreadyRegisteredVisitorsAsCustomers]
(
	[CLIENT_CUSTOMER_ID] NVARCHAR(50) NOT NULL,
	[Optimove_Customer_ID] BIGINT NOT NULL,
	[VISITOR_ID] NVARCHAR(100) NOT NULL,
	[Optimove_VISITOR_ID] BIGINT NOT NULL
)

GO
CREATE  UNIQUE NONCLUSTERED INDEX [ix_ClientCustomerIDVisitorId] ON [optitrackSDK].[AlreadyRegisteredVisitorsAsCustomers]
(
	[CLIENT_CUSTOMER_ID] ASC,
	[VISITOR_ID] ASC
)WITH (IGNORE_DUP_KEY = ON,PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]



CREATE TABLE [optitrackSDK].[Config]
(
	[LastAggregatedVisitId] [bigint] NOT NULL,
	[LastAggregatedActionId] [bigint] NOT NULL,
	[CustomerAvgSessionVisitLastId] [bigint] NOT NULL,
	[UTMDataVisitLastId] [bigint] NOT NULL,
	[PrevCustomerAvgSessionProcessDate] [datetime] NOT NULL

)

INSERT INTO [optitrackSDK].[Config]
VALUES(0,0,0,0,0)


CREATE TABLE [optitrackSDK].[CustomersBeforeRegister_TMP](
	[CustomerId] [nvarchar](255) NOT NULL,
	[OriginalVisitorID] varchar(255) DEFAULT NULL
) ON [PRIMARY]

GO
CREATE  UNIQUE NONCLUSTERED INDEX [ix_CustomerIDOriginalVisitorID] ON [optitrackSDK].[CustomersBeforeRegister_TMP]
(
	[CustomerId] ASC,
	[OriginalVisitorID] ASC
)WITH (IGNORE_DUP_KEY = ON,PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]



CREATE TABLE [optitrackSDK].[CustomerVisitAvgTime](
	[CustomerId] [bigint] NOT NULL,
	[CustomerAvgTime] [int] NULL,
	[NumberOfSessions] [int] NULL,
	[LastComputedSessionID] [bigint] NULL,
	[ActiveSessionDays] [int] NOT NULL DEFAULT ((0)),
PRIMARY KEY CLUSTERED 
(
	[CustomerId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO



CREATE TABLE [optitrackSDK].[CustomerVisitAvgTime_Visitor](
	[CustomerID] [bigint] NOT NULL,
	[CustomerAvgTime] [int] NULL,
	[NumberOfSessions] [int] NULL,
	[LastComputedSessionID] [bigint] NULL,
	[ActiveSessionDays] [int] NOT NULL DEFAULT ((0)),
PRIMARY KEY CLUSTERED 
(
	[CustomerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [optitrackSDK].[CustomEventsParametersUpdateStatus]
(
	[EventId] [int] NOT NULL,
	[ParamId] [tinyint] NOT NULL,
	[ParameterType] NVARCHAR(16) NOT NULL,
	[NumberofValues] [int] NOT NULL,
	[LastUpdateDate] [smalldatetime] NOT NULL,
	[supportUpload] [bit] NOT NULL
)

GO
CREATE  UNIQUE NONCLUSTERED INDEX [ix_EventId] ON [optitrackSDK].[CustomEventsParametersUpdateStatus]
(
	[EventId] ASC
)WITH (IGNORE_DUP_KEY = ON,PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]

GO
CREATE  UNIQUE NONCLUSTERED INDEX [ix_ParamId] ON [optitrackSDK].[CustomEventsParametersUpdateStatus]
(
	[ParamId] ASC
)WITH (IGNORE_DUP_KEY = ON,PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]

CREATE TABLE [optitrackSDK].[CustomEventsParametersValues]
(
	[EventId] [int] NOT NULL,
	[ParamId] [int] NOT NULL,
	[ParamValue] NVARCHAR(255)
)

GO
CREATE  UNIQUE NONCLUSTERED INDEX [ix_EventId] ON [optitrackSDK].[CustomEventsParametersValues]
(
	[EventId] ASC
)WITH (IGNORE_DUP_KEY = ON,PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]

GO
CREATE  UNIQUE NONCLUSTERED INDEX [ix_ParamId] ON [optitrackSDK].[CustomEventsParametersValues]
(
	[ParamId] ASC
)WITH (IGNORE_DUP_KEY = ON,PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]

CREATE TABLE [optitrackSDK].[CustomEventsPiwikMapping]
(
	[IdAction] [bigint] NOT NULL,
	[EventId] [tinyint] NOT NULL,
	[EventName] NVARCHAR(255)
	PRIMARY KEY CLUSTERED 
	(
		[IdAction] DESC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
)

GO
CREATE  UNIQUE NONCLUSTERED INDEX [ix_EventId] ON [optitrackSDK].[CustomEventsPiwikMapping]
(
	[EventId] ASC
)WITH (IGNORE_DUP_KEY = ON,PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]

CREATE TABLE [optitrackSDK].[CustomEventsRawData]
(
	[EventDateTime] [datetime] NOT NULL,
	[EventId] [int] NOT NULL,
	[CustomerId] [bigint] NOT NULL,
	[ActionId] [bigint] NOT NULL,
	[Parameter1] NVARCHAR(255),
	[Parameter2] NVARCHAR(255),
	[Parameter3] NVARCHAR(255),
	[Parameter4] NVARCHAR(255),
	[Parameter5] NVARCHAR(255),
	[Parameter6] NVARCHAR(255),
	[Parameter7] NVARCHAR(255),
	[Parameter8] NVARCHAR(255),
	[Parameter9] NVARCHAR(255),
	[Parameter10] NVARCHAR(255),
	[Parameter11] NVARCHAR(255),
	[Parameter12] NVARCHAR(255),
	[Parameter13] NVARCHAR(255),
	[Parameter14] NVARCHAR(255),
	[Parameter15] NVARCHAR(255),
	[Parameter16] NVARCHAR(255),
	[Parameter17] NVARCHAR(255),
	[Parameter18] NVARCHAR(255),
	[Parameter19] NVARCHAR(255),
	[Parameter20] NVARCHAR(255),
	[Parameter21] NVARCHAR(255),
	[Parameter22] NVARCHAR(255),
	[Parameter23] NVARCHAR(255),
)

GO
CREATE CLUSTERED INDEX [IX_EventDateTimeEventId] ON [optitrackSDK].[CustomEventsRawData]
(
		[EventDateTime] DESC,
		[EventId] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]



GO
CREATE NONCLUSTERED INDEX [IX_CustomerId] ON [optitrackSDK].[CustomEventsRawData]
(
	[CustomerId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]


CREATE TABLE [optitrackSDK].[EmailRegister]
(
	[CustomerId] [bigint] NOT NULL,
	[Hash] VARBINARY(64) NOT NULL,
	[Email] NVARCHAR(255) NOT NULL,
	[EventDateTime] [smalldatetime] NOT NULL
)

GO
CREATE  UNIQUE CLUSTERED INDEX [ix_CustomerIdHash] ON [optitrackSDK].[EmailRegister]
(
	[CustomerId] ASC,
	[Hash] ASC
)WITH (IGNORE_DUP_KEY = ON,PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]


CREATE TABLE [optitrackSDK].[Language]
(
	[LanguageId] INT NOT NULL IDENTITY(1,1),
	[Language] nvarchar(16)
)

GO
CREATE UNIQUE CLUSTERED INDEX [ix_LanguageId] ON [optitrackSDK].[Language]
(
	[LanguageId]
)WITH (IGNORE_DUP_KEY = OFF,PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]

CREATE TABLE [optitrackSDK].[LocationCity]
(
	[LocationCityId] INT NOT NULL IDENTITY(1,1),
	[LocationCity] nvarchar(64)
)

GO
CREATE UNIQUE CLUSTERED INDEX [ix_LocationCityId] ON [optitrackSDK].[LocationCity]
(
	[LocationCityId]
)WITH (IGNORE_DUP_KEY = OFF,PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]


CREATE TABLE [optitrackSDK].[LogEventPiwikMapping]
(
	[IdAction] [bigint] NOT NULL,
	[EventName] NVARCHAR(255)
)

CREATE TABLE [optitrackSDK].[OptimoveAlias] (
    [VisitorId]  NVARCHAR (200) NOT NULL,
    [CustomerId] NVARCHAR (200) NOT NULL,
    [IsUnique]   BIT            NOT NULL
);


GO

CREATE  UNIQUE NONCLUSTERED INDEX [ix_VisitorIdCustomerID] ON [optitrackSDK].[OptimoveAlias]
(
	[VisitorId] ASC,
	[CustomerId] ASC
)WITH (IGNORE_DUP_KEY = ON,PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]

GO
CREATE NONCLUSTERED INDEX IX_CustomerId
ON [optitrackSDK].[OptimoveAlias] ([CustomerId])
with(online=on)


CREATE TABLE [optitrackSDK].[OptitrackVersion]
(
	[Version] [nvarchar](200),
	[isSupportedOptitrack] [BIT] DEFAULT 0,
	[ConversionDate] [datetime]
)

CREATE TABLE [optitrackSDK].[PagesCategories]
(
	[Id] INT NOT NULL IDENTITY(1,1),
	[PageCategory] NVARCHAR(255) NOT NULL,
	[Hash] VARBINARY(64)  NOT NULL
	PRIMARY KEY CLUSTERED 
	(
		[Id] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Hash] ON [optitrackSDK].[PagesCategories]
(
	[Hash] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = ON, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

CREATE TABLE [optitrackSDK].[PagesCategoriesEventsRawData]
(
	[ActionTime] [smalldatetime] NOT NULL,
	[ActionID] [bigint] NOT NULL,
	[VisitId] [bigint] NOT NULL,
	[CustomerId] [bigint] NOT NULL,
	[PageCategoryID] [int] NOT NULL
)

GO
CREATE UNIQUE CLUSTERED INDEX [IX_ActoinTimeActionID] ON [optitrackSDK].[PagesCategoriesEventsRawData]
(
		[ActionTime] DESC,
		[ActionID] DESC
)WITH (PAD_INDEX = OFF, IGNORE_DUP_KEY = ON, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

CREATE TABLE [optitrackSDK].[PageTitle]
(
	[PageTitleID] [bigint] NOT NULL,
	[Title] NVARCHAR(2100),
	[Hash] VARBINARY(64)  NOT NULL
	PRIMARY KEY CLUSTERED 
	(
		[PageTitleID] DESC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Hash] ON [optitrackSDK].[PageTitle]
(
	[Hash] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = ON, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]


CREATE TABLE [optitrackSDK].[PageVisitEventsRawData]
(
	[LastVisitTime] [smalldatetime] NOT NULL,
	[VisitId] [bigint] NOT NULL,
	[LastComputedActionID] [bigint] NOT NULL,
	[CustomerId] [bigint] NOT NULL,
	[PageTitleId] [bigint] NOT NULL,
	[NumOfOccurrences] [int] NOT NULL
)

GO
CREATE CLUSTERED INDEX [IX_LastVisitTimeVisitIdCustomerId] ON [optitrackSDK].[PageVisitEventsRawData]
(
	[LastVisitTime] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]


GO
CREATE NONCLUSTERED INDEX [IX_VisitId] ON [optitrackSDK].[PageVisitEventsRawData]
(
	[VisitId] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]


CREATE TABLE [optitrackSDK].[PageVisitEventsRawData_Visitor]
(
	[LastVisitTime] [smalldatetime] NOT NULL,
	[VisitId] [bigint] NOT NULL,
	[LastComputedActionID] [bigint] NOT NULL,
	[CustomerId] [bigint] NOT NULL,
	[PageTitleId] [bigint] NOT NULL,
	[NumOfOccurrences] [int] NOT NULL
)

GO
CREATE CLUSTERED INDEX [IX_LastVisitTimeVisitIdCustomerId] ON [optitrackSDK].[PageVisitEventsRawData_Visitor]
(
	[LastVisitTime] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]


GO
CREATE NONCLUSTERED INDEX [IX_VisitId] ON [optitrackSDK].[PageVisitEventsRawData_Visitor]
(
	[VisitId] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

CREATE TABLE [optitrackSDK].[PiwikIdentity]
(
	[TableName] [nvarchar](50) NOT NULL,
	[Id] [bigint] NULL
)


CREATE TABLE [optitrackSDK].[PiwikVisit]
(
	[Id] [bigint] NOT NULL,
	[UserId] [nvarchar](200) NULL,
	[VisitorId] [nvarchar](200) NULL,
	[VisitFirstActionTime] [datetime] NULL,
	[VisitLastActionTime] [datetime] NULL,
	[TotalVisitTime] [int] NULL,
	[Referer] [nvarchar](200) NULL,
	[Platform] [nvarchar](200) NULL,
	[IsUnique] [bit] NULL,
	[Campaign_name] [nvarchar](255) DEFAULT NULL,
	[Campaign_keyword] [nvarchar](255) DEFAULT NULL,
	[Campaign_source] [nvarchar](255) DEFAULT NULL,
	[Campaign_medium] [nvarchar](255) DEFAULT NULL,
	[Campaign_content] [nvarchar](255) DEFAULT NULL,
	[Campaign_id] [nvarchar](100) DEFAULT NULL,
	[GEO_Location][varchar](255) DEFAULT NULL,
	[Location_latitude] DECIMAL(9,6),
    [Location_longitude] DECIMAL(9,6),
	[IP] [varchar](64),
	[Language] [varchar](16)
)

GO
CREATE UNIQUE CLUSTERED INDEX [CIX_ID] ON [optitrackSDK].[PiwikVisit]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = ON, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
CREATE NONCLUSTERED INDEX [IX_UserIdVisitFirstActionTime] ON [optitrackSDK].[PiwikVisit]
(
	[UserId] ASC,
	[VisitFirstActionTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

CREATE TABLE [optitrackSDK].[PiwikVisitAction]
(
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
	   [custom_dimension_1] NVARCHAR(255),
	   [custom_dimension_2] NVARCHAR(255),
	   [custom_dimension_3] NVARCHAR(255),
	   [custom_dimension_4] NVARCHAR(255),
	   [custom_dimension_5] NVARCHAR(255),
	   [custom_dimension_6] NVARCHAR(255),
	   [custom_dimension_7] NVARCHAR(255),
	   [custom_dimension_8] NVARCHAR(255),
	   [custom_dimension_9] NVARCHAR(255),
	   [custom_dimension_10] NVARCHAR(255),
	   [custom_dimension_11] NVARCHAR(255),
	   [custom_dimension_12] NVARCHAR(255),
	   [custom_dimension_13] NVARCHAR(255),
	   [custom_dimension_14] NVARCHAR(255),
	   [custom_dimension_15] NVARCHAR(255),
	   [custom_dimension_16] NVARCHAR(255),
	   [custom_dimension_17] NVARCHAR(255),
	   [custom_dimension_18] NVARCHAR(255),
	   [custom_dimension_19] NVARCHAR(255),
	   [custom_dimension_20] NVARCHAR(255),
	   [custom_dimension_21] NVARCHAR(255),
	   [custom_dimension_22] NVARCHAR(255),
	   [custom_dimension_23] NVARCHAR(255),
	   [custom_dimension_24] NVARCHAR(255),
	   [custom_dimension_25] NVARCHAR(255)
)


CREATE TABLE [optitrackSDK].[Platform]
(
	[PlatformId] INT NOT NULL IDENTITY(1,1),
	[Platform] nvarchar(8)
)

GO
CREATE UNIQUE CLUSTERED INDEX [ix_PlatformId] ON [optitrackSDK].[Platform]
(
	[PlatformId]
)WITH (IGNORE_DUP_KEY = ON,PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]


CREATE TABLE [optitrackSDK].[SetUserIdEvent]
(
	[VisitId] [bigint] NOT NULL,
	[OriginalvisitorId] NVARCHAR(200) NOT NULL,
	[UpdatedVisitorId] NVARCHAR(200) NOT NULL,
	[PublicUserId] NVARCHAR(200) NOT NULL,
	[FirstTimeEventDateTime] [smalldatetime] NOT NULL
)

GO
CREATE UNIQUE CLUSTERED INDEX [IX_VisitId] ON [optitrackSDK].[SetUserIdEvent]
(
		[VisitId] DESC
)WITH (IGNORE_DUP_KEY = ON,PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) 


GO
CREATE NONCLUSTERED INDEX [IX_PublicUserId] ON [optitrackSDK].[SetUserIdEvent]
(
	[PublicUserId] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) 
GO
CREATE NONCLUSTERED INDEX [IX_OriginalvisitorId] ON [optitrackSDK].[SetUserIdEvent]
(
	[OriginalvisitorId] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)


CREATE TABLE [optitrackSDK].[SplittedVisitData]
(
	[Id] [bigint] NOT NULL,
	[UserId] [nvarchar](200) NULL,
	[VisitorId] [nvarchar](200) NULL,
	[VisitLastActionTime] [datetime] NULL,
	[TotalVisitTime] [int] NULL
)

GO
CREATE UNIQUE CLUSTERED INDEX [CIX_ID] ON [optitrackSDK].[SplittedVisitData]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = ON, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]


CREATE TABLE [optitrackSDK].[SplittedVisitIds_TEMP]
(
	[VisitId] [bigint] NOT NULL
)

GO
CREATE UNIQUE CLUSTERED INDEX [CIX_VisitId] ON [optitrackSDK].[SplittedVisitIds_TEMP]
(
	[VisitId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = ON, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]


CREATE TABLE [optitrackSDK].[T_Configuration](
	[ConfigurationName] [nvarchar](100) NOT NULL,
	[ConfigurationValue] [nvarchar](1000) NULL,
PRIMARY KEY CLUSTERED 
(
	[ConfigurationName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

CREATE TABLE [optitrackSDK].[T_TempSessionUsers](
	[UserId] [nvarchar](200) NULL,
	[VisitorId] [nvarchar](200) NULL,
	[VisitFirstActionTime] [datetime2](0) NULL
) ON [PRIMARY]

CREATE TABLE [optitrackSDK].[T_VisitorSessionFirstTouch](
	[Id] [bigint] NULL,
	[UserId] [nvarchar](200) NULL,
	[VisitorId] [nvarchar](200) NULL,
	[VisitFirstActionTime] [datetime] NULL,
	[utm_campaign] [nvarchar](255) NULL,
	[utm_term] [nvarchar](255) NULL,
	[utm_source] [nvarchar](255) NULL,
	[utm_medium] [nvarchar](255) NULL,
	[utm_content] [nvarchar](255) NULL
) ON [PRIMARY]

GO
/****** Object:  Index [FIX_VisitorId]    Script Date: 02/8/2017 6:33:16 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [FIX_VisitorId] ON [optitrackSDK].[T_VisitorSessionFirstTouch]
(
	[VisitorId] ASC
)
INCLUDE ( 	[UserId]) 
WHERE ([UserId] IS NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_VisitorId]    Script Date: 02/8/2017 6:33:16 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_VisitorId] ON [optitrackSDK].[T_VisitorSessionFirstTouch]
(
	[VisitorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = ON, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO


CREATE TABLE [optitrackSDK].[T_VisitorSessionLastTouch](
	[Id] [bigint] NULL,
	[UserId] [varchar](200) NULL,
	[VisitorId] [nvarchar](200) NULL,
	[VisitFirstActionTime] [datetime] NULL,
	[utm_campaign] [nvarchar](255) NULL,
	[utm_term] [nvarchar](255) NULL,
	[utm_source] [nvarchar](255) NULL,
	[utm_medium] [nvarchar](255) NULL,
	[utm_content] [nvarchar](255) NULL
) ON [PRIMARY]

GO
/****** Object:  Index [IX_VisitorId]    Script Date: 02/8/2017 6:33:16 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_VisitorId] ON [optitrackSDK].[T_VisitorSessionLastTouch]
(
	[VisitorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = ON, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

CREATE TABLE [optitrackSDK].[TotalCustomDailyEvents]
(
	[EventDate] [smalldatetime] NOT NULL,
	[LastComputedActionID] [bigint] NOT NULL,
	[CustomerId] [bigint] NOT NULL,
	[NumberOfDailyEvents] [int]
)

GO
CREATE UNIQUE CLUSTERED INDEX [IX_EventDateCustomerId] ON [optitrackSDK].[TotalCustomDailyEvents]
(
		[EventDate] DESC,
		[CustomerId] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

CREATE TABLE [optitrackSDK].[TotalDailyAggregationPerEvent]
(
	[EventDate] [smalldatetime] NOT NULL,
	[LastComputedActionID] [bigint] NOT NULL,
	[CustomerId] [bigint] NOT NULL,
	[EventID] INT NOT NULL,
	[NumberOfDailyEvent] [int] NOT NULL
)

GO
CREATE CLUSTERED INDEX [IX_EventDateCustomerId] ON [optitrackSDK].[TotalDailyAggregationPerEvent]
(
		[EventDate] DESC,
		[CustomerId] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]


GO
CREATE NONCLUSTERED INDEX [IX_EventID] ON [optitrackSDK].[TotalDailyAggregationPerEvent]
(
	[EventID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

CREATE TABLE [optitrackSDK].[TotalDailyAggregationPerEvent_Visitor]
(
	[EventDate] [smalldatetime] NOT NULL,
	[LastComputedActionID] [bigint] NOT NULL,
	[CustomerId] [bigint] NOT NULL,
	[EventID] INT NOT NULL,
	[NumberOfDailyEvent] [int] NOT NULL
)

GO
CREATE CLUSTERED INDEX [IX_EventDateCustomerId] ON [optitrackSDK].[TotalDailyAggregationPerEvent_Visitor]
(
		[EventDate] DESC,
		[CustomerId] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]


GO
CREATE NONCLUSTERED INDEX [IX_EventID] ON [optitrackSDK].[TotalDailyAggregationPerEvent_Visitor]
(
	[EventID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]


CREATE TABLE [optitrackSDK].[TotalDailyPagesCategoriesAggregation]
(
	[Date] [date] NOT NULL,
	[LastComputedActionId] [bigint] NOT NULL,
	[CustomerId] [bigint] NOT NULL,
	[PageCategoryID] [int] NOT NULL,
	[NumOfPageVisits] [int] NOT NULL
)


GO
CREATE CLUSTERED INDEX [IX_Date] ON [optitrackSDK].[TotalDailyPagesCategoriesAggregation]
(
		[Date] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

CREATE TABLE [optitrackSDK].[TotalDailyPagesCategoriesAggregation_Visitor]
(
	[Date] [date] NOT NULL,
	[LastComputedActionId] [bigint] NOT NULL,
	[CustomerId] [bigint] NOT NULL,
	[PageCategoryID] [int] NOT NULL,
	[NumOfPageVisits] [int] NOT NULL
)


GO
CREATE CLUSTERED INDEX [IX_Date] ON [optitrackSDK].[TotalDailyPagesCategoriesAggregation_Visitor]
(
		[Date] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

CREATE TABLE [optitrackSDK].[TotalDailyPagesVisitsAggregation]
(
	[Date] [date] NOT NULL,
	[LastComputedActionID] [bigint] NOT NULL,
	[CustomerId] [bigint] NOT NULL,
	[NumOfPageVisits] [int] NOT NULL
)

GO
CREATE UNIQUE CLUSTERED INDEX [IX_DateCustomerId] ON [optitrackSDK].[TotalDailyPagesVisitsAggregation]
(
		[Date] DESC,
		[CustomerId] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]


CREATE TABLE [optitrackSDK].[TotalDailyPagesVisitsAggregation_Visitor]
(
	[Date] [date] NOT NULL,
	[LastComputedActionID] [bigint] NOT NULL,
	[CustomerId] [bigint] NOT NULL,
	[NumOfPageVisits] [int] NOT NULL
)

GO
CREATE UNIQUE CLUSTERED INDEX [IX_DateCustomerId] ON [optitrackSDK].[TotalDailyPagesVisitsAggregation_Visitor]
(
		[Date] DESC,
		[CustomerId] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]


CREATE TABLE [optitrackSDK].[TotalDailySinglePageTitleAggregation]
(
	[Date] [date] NOT NULL,
	[LastComputedActionID] [bigint] NOT NULL,
	[CustomerId] [bigint] NOT NULL,
	[PageTitleID] [bigint] NOT NULL,
	[NumOfTotalPageVisits] [Int] NOT NULL
)

GO
CREATE CLUSTERED INDEX [IX_DateCustomerId] ON [optitrackSDK].[TotalDailySinglePageTitleAggregation]
(
		[Date] DESC,
		[CustomerId] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]


CREATE TABLE [optitrackSDK].[TotalDailySinglePageTitleAggregation_Visitor]
(
	[Date] [date] NOT NULL,
	[LastComputedActionID] [bigint] NOT NULL,
	[CustomerId] [bigint] NOT NULL,
	[PageTitleID] [bigint] NOT NULL,
	[NumOfTotalPageVisits] [Int] NOT NULL
)

GO
CREATE CLUSTERED INDEX [IX_DateCustomerId] ON [optitrackSDK].[TotalDailySinglePageTitleAggregation_Visitor]
(
		[Date] DESC,
		[CustomerId] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]


CREATE TABLE [optitrackSDK].[TotalDailySinglePageVisitsAggregation]
(
	[Date] [date] NOT NULL,
	[LastComputedActionID] [bigint] NOT NULL,
	[CustomerId] [bigint] NOT NULL,
	[URLID] [bigint] NOT NULL,
	[NumOfTotalPageVisits] [Int] NOT NULL
)


GO
CREATE CLUSTERED INDEX [IX_DateCustomerId] ON [optitrackSDK].[TotalDailySinglePageVisitsAggregation]
(
		[Date] DESC,
		[CustomerId] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]



CREATE TABLE [optitrackSDK].[TotalDailySinglePageVisitsAggregation_Visitor]
(
	[Date] [date] NOT NULL,
	[LastComputedActionID] [bigint] NOT NULL,
	[CustomerId] [bigint] NOT NULL,
	[URLID] [bigint] NOT NULL,
	[NumOfTotalPageVisits] [Int] NOT NULL
)


GO
CREATE CLUSTERED INDEX [IX_DateCustomerId] ON [optitrackSDK].[TotalDailySinglePageVisitsAggregation_Visitor]
(
		[Date] DESC,
		[CustomerId] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

CREATE TABLE [optitrackSDK].[TotalVisitsInfoAggregation]
(
	[Date] [smalldatetime] NOT NULL,
	[CustomerId] [bigint] NOT NULL,
	[TotalVisitTime] [int] NOT NULL,
	[TotalNumberOfVisits] [int] NOT NULL
)

GO
CREATE UNIQUE CLUSTERED INDEX [IX_DateCustomerId] ON [optitrackSDK].[TotalVisitsInfoAggregation]
(
		[Date] DESC,
		[CustomerId] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]


CREATE TABLE [optitrackSDK].[TotalVisitsInfoAggregation_Visitor]
(
	[Date] [smalldatetime] NOT NULL,
	[CustomerId] [bigint] NOT NULL,
	[TotalVisitTime] [int] NOT NULL,
	[TotalNumberOfVisits] [int] NOT NULL
)

GO
CREATE UNIQUE CLUSTERED INDEX [IX_DateCustomerId] ON [optitrackSDK].[TotalVisitsInfoAggregation_Visitor]
(
		[Date] DESC,
		[CustomerId] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]






CREATE TABLE [optitrackSDK].[URL]
(
	[URLID] [bigint] NOT NULL,
	[URL] NVARCHAR(2100) NOT NULL,
	[Hash] VARBINARY(64)  NOT NULL
	PRIMARY KEY CLUSTERED 
	(
		[URLID] DESC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]


CREATE UNIQUE NONCLUSTERED INDEX [IX_Hash] ON [optitrackSDK].[URL]
(
	[Hash] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = ON, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]


CREATE TABLE [optitrackSDK].[URLsPageTitle_TEMP]
(
	[ActionId] INT NOT NULL,
    [URL]      NVARCHAR (2100) NULL,
    [Type]     INT NULL
)

GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_ActionId] ON [optitrackSDK].[URLsPageTitle_TEMP]
(
	[ActionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = ON, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

CREATE TABLE [optitrackSDK].[UserAgentHeaderEvent]
(
	[CustomerId] [bigint] NOT NULL,
	[UserAgentId] [int] NOT NULL,
	[FirstRecognitionEventDateTime] [smalldatetime] NOT NULL
)

GO
CREATE UNIQUE CLUSTERED INDEX [IX_CustomerIdUserAgentId] ON [optitrackSDK].[UserAgentHeaderEvent]
(
	[CustomerId] ASC,
	[UserAgentId] ASC
)WITH (IGNORE_DUP_KEY = ON,  PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]


CREATE TABLE [optitrackSDK].[UserAgentHeaderEvent_Visitor]
(
	[CustomerId] [bigint] NOT NULL,
	[UserAgentId] [int] NOT NULL,
	[FirstRecognitionEventDateTime] [smalldatetime] NOT NULL
)

GO
CREATE UNIQUE CLUSTERED INDEX [IX_CustomerIdUserAgentId] ON [optitrackSDK].[UserAgentHeaderEvent_Visitor]
(
	[CustomerId] ASC,
	[UserAgentId] ASC
)WITH (IGNORE_DUP_KEY = ON,  PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]


CREATE TABLE [optitrackSDK].[UserAgentsId]
(
	[UserAgentId] [int] IDENTITY(1,1) NOT NULL,
	[Hash] VARBINARY(64) NOT NULL,
	[UserAgent] nvarchar(255) NOT NULL
	PRIMARY KEY CLUSTERED 
	(
		[UserAgentId] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE NONCLUSTERED INDEX [IX_Hash] ON [optitrackSDK].[UserAgentsId]
(
	[Hash] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

CREATE TABLE [optitrackSDK].[VisitInfoRawData]
(
	[FirstVisitTime] [smalldatetime] NOT NULL,
	[VisitId] [bigint] NOT NULL,
	[CustomerId] [bigint] NOT NULL,
	[PlatformId] [int] NULL,
	[LocationCityId] [int] NULL,
	[IP] nvarchar(64) NOT NULL,
	[LanguageId] [int],
	[TotalVisitTime] [int] NOT NULL
)


GO
CREATE UNIQUE CLUSTERED INDEX [IX_FirstVisitTimeVisitId] ON [optitrackSDK].[VisitInfoRawData]
(
		[FirstVisitTime] DESC,
		[VisitId] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]


CREATE TABLE [optitrackSDK].[VisitInfoRawData_Visitor]
(
	[FirstVisitTime] [smalldatetime] NOT NULL,
	[VisitId] [bigint] NOT NULL,
	[CustomerId] [bigint] NOT NULL,
	[PlatformId] [int] NULL,
	[LocationCityId] [int] NULL,
	[IP] nvarchar(64) NOT NULL,
	[LanguageId] [int],
	[TotalVisitTime] [int] NOT NULL
)


GO
CREATE UNIQUE CLUSTERED INDEX [IX_FirstVisitTimeVisitId] ON [optitrackSDK].[VisitInfoRawData_Visitor]
(
		[FirstVisitTime] DESC,
		[VisitId] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]


CREATE TABLE [optitrackSDK].[VisitorMappedTypes]
(
	[TypeId] [int] NOT NULL,
	[Type] NVARCHAR(16) NOT NULL
)


CREATE TABLE [optitrackSDK].[VisitorsConversion]
(
	[CLIENT_CUSTOMER_ID] [nvarchar](200) NULL,
	[Customer_ID] [bigint] NULL,
	[VisitId] [bigint] NOT NULL,
	[VisitorId] [nvarchar](200) NULL,
	[OriginalVisitorID] varchar(255) DEFAULT NULL,
	[Platform] [nvarchar](200) NULL,
	[ConversionDate] [smalldatetime] NULL
) ON [PRIMARY]

GO
CREATE UNIQUE CLUSTERED INDEX [ix_CLIENT_CUSTOMER_IDVisitorId] ON [optitrackSDK].[VisitorsConversion]
(
	[CLIENT_CUSTOMER_ID] DESC,
	[Customer_ID] DESC,
	[VisitorId] DESC
)WITH (IGNORE_DUP_KEY = ON,PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]


CREATE TABLE [optitrackSDK].[VisitorsMapping]
(
	[CLIENT_CUSTOMER_ID] [nvarchar](200) NULL,
	[VisitorId] [nvarchar](200) NULL,
	[Customer_ID] [bigint] NULL,
	[Type] [INT] NULL
)


GO
CREATE UNIQUE CLUSTERED INDEX [ix_CLIENT_CUSTOMER_ID_VisitorId] ON [optitrackSDK].[VisitorsMapping]
(
	[CLIENT_CUSTOMER_ID] DESC,
	[VisitorId] DESC
)WITH (IGNORE_DUP_KEY = ON,PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]


GO
CREATE NONCLUSTERED INDEX [ix_Customer_ID] ON [optitrackSDK].[VisitorsMapping]
(
	Customer_ID ASC
)WITH (IGNORE_DUP_KEY = OFF,PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]



CREATE TABLE [optitrackSDK].[EmailRegister_Visitor]
(
	[CustomerId] [bigint] NOT NULL,
	[Hash] VARBINARY(64) NOT NULL,
	[Email] NVARCHAR(255) NOT NULL,
	[EventDateTime] [smalldatetime] NOT NULL
)

GO
CREATE  UNIQUE CLUSTERED INDEX [ix_CustomerIdHash] ON [optitrackSDK].[EmailRegister_Visitor]
(
	[CustomerId] ASC,
	[Hash] ASC
)WITH (IGNORE_DUP_KEY = ON,PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]



CREATE TABLE [optitrackSDK].[CustomEventsRawData_Visitor]
(
	[EventDateTime] [datetime] NOT NULL,
	[EventId] [int] NOT NULL,
	[CustomerId] [bigint] NOT NULL,
	[ActionId] [bigint] NOT NULL,
	[Parameter1] NVARCHAR(255),
	[Parameter2] NVARCHAR(255),
	[Parameter3] NVARCHAR(255),
	[Parameter4] NVARCHAR(255),
	[Parameter5] NVARCHAR(255),
	[Parameter6] NVARCHAR(255),
	[Parameter7] NVARCHAR(255),
	[Parameter8] NVARCHAR(255),
	[Parameter9] NVARCHAR(255),
	[Parameter10] NVARCHAR(255),
	[Parameter11] NVARCHAR(255),
	[Parameter12] NVARCHAR(255),
	[Parameter13] NVARCHAR(255),
	[Parameter14] NVARCHAR(255),
	[Parameter15] NVARCHAR(255),
	[Parameter16] NVARCHAR(255),
	[Parameter17] NVARCHAR(255),
	[Parameter18] NVARCHAR(255),
	[Parameter19] NVARCHAR(255),
	[Parameter20] NVARCHAR(255),
	[Parameter21] NVARCHAR(255),
	[Parameter22] NVARCHAR(255),
	[Parameter23] NVARCHAR(255),
)

GO
CREATE CLUSTERED INDEX [IX_EventDateTimeEventId] ON [optitrackSDK].[CustomEventsRawData_Visitor]
(
		[EventDateTime] DESC,
		[EventId] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]



GO
CREATE NONCLUSTERED INDEX [IX_CustomerId] ON [optitrackSDK].[CustomEventsRawData_Visitor]
(
	[CustomerId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]



CREATE TABLE [optitrackSDK].[TotalCustomDailyEvents_Visitor]
(
	[EventDate] [smalldatetime] NOT NULL,
	[LastComputedActionID] [bigint] NOT NULL,
	[CustomerId] [bigint] NOT NULL,
	[NumberOfDailyEvents] [int]
)

GO
CREATE UNIQUE CLUSTERED INDEX [IX_EventDateCustomerId] ON [optitrackSDK].[TotalCustomDailyEvents_Visitor]
(
		[EventDate] DESC,
		[CustomerId] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]


CREATE TABLE [optitrackSDK].[Config_Visitor]
(
	[LastAggregatedVisitId] [bigint] NOT NULL,
	[LastAggregatedActionId] [bigint] NOT NULL,
	[VisitorsAvgSessionVisitLastId] [bigint] NOT NULL,
	[UTMDataVisitLastId] [bigint] NOT NULL,
	[PrevVisitorsAvgSessionProcessDate] [datetime] NOT NULL
)

INSERT INTO [optitrackSDK].[Config_Visitor]
VALUES(0,0,0,0,0)

GO
CREATE TABLE [optitrackSDK].[OptimoveAlias_HashedCustomers]
(
    [VisitorId]  NVARCHAR (200) NOT NULL,
    [CustomerId] NVARCHAR (200) NOT NULL,
    [IsUnique]   BIT            NOT NULL
);


GO

CREATE  UNIQUE NONCLUSTERED INDEX [ix_VisitorIdCustomerID] ON [optitrackSDK].[OptimoveAlias_HashedCustomers]
(
	[VisitorId] ASC,
	[CustomerId] ASC
)WITH (IGNORE_DUP_KEY = ON,PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]

GO
CREATE NONCLUSTERED INDEX IX_CustomerId
ON [optitrackSDK].[OptimoveAlias_HashedCustomers] ([CustomerId])
with(online=on)






CREATE TABLE [optitrackSDK].[UTM_Data_Visitor](
	[Id] [bigint] NOT NULL,
	[CUSTOMER_ID] [bigint] NOT NULL,
	[first_action_time] [date] NULL,
	[Name] [varchar](255) NULL,
	[campaign_Source] [varchar](255) NULL,
	[Keyword] [varchar](255) NULL,
	[Medium] [varchar](255) NULL,
	[Content] [varchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]


GO
SET ANSI_PADDING OFF
GO
/****** Object:  Index [CustomerId_Indx]    Script Date: 15/02/2016 13:44:21 ******/
CREATE NONCLUSTERED INDEX [VisitorId_Indx] ON [optitrackSDK].[UTM_Data_Visitor]
(
	[CUSTOMER_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO


CREATE UNIQUE NONCLUSTERED INDEX [IX_PiwikSession_Id] ON [optitrackSDK].[UTM_Data_Visitor]
(
       [Id] ASC
)WITH (IGNORE_DUP_KEY = ON, PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO




CREATE TABLE [optitrackSDK].[UTM_Data](
	[Id] [bigint] NOT NULL,
	[CustomerId] [bigint] NULL,
	[first_action_time] [date] NULL,
	[Name] [varchar](255) NULL,
	[campaign_Source] [varchar](255) NULL,
	[Keyword] [varchar](255) NULL,
	[Medium] [varchar](255) NULL,
	[Content] [varchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]


GO
SET ANSI_PADDING OFF
GO
/****** Object:  Index [CustomerId_Indx]    Script Date: 15/02/2016 13:44:21 ******/
CREATE NONCLUSTERED INDEX [CustomerId_Indx] ON [optitrackSDK].[UTM_Data]
(
	[CustomerId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO


CREATE UNIQUE NONCLUSTERED INDEX [IX_PiwikSession_Id] ON [optitrackSDK].[UTM_Data] 
(
       [Id] ASC
)WITH (IGNORE_DUP_KEY = ON, PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO



CREATE TABLE [optitrackSDK].[PagesCategoriesEventsRawData_Visitor]
(
	[ActionTime] [smalldatetime] NOT NULL,
	[ActionID] [bigint] NOT NULL,
	[VisitId] [bigint] NOT NULL,
	[CustomerId] [bigint] NOT NULL,
	[PageCategoryID] [int] NOT NULL
)

GO
CREATE UNIQUE CLUSTERED INDEX [IX_ActoinTimeActionID] ON [optitrackSDK].[PagesCategoriesEventsRawData_Visitor]
(
		[ActionTime] DESC,
		[ActionID] DESC
)WITH (PAD_INDEX = OFF, IGNORE_DUP_KEY = ON, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

