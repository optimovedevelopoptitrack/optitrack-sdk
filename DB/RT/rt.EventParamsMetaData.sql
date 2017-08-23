  CREATE TABLE [rt].[EventParamsMetaData](
	[Id] [int]  NOT NULL,
	[EventId] [int] NOT NULL,
	[Key] [nvarchar](100) NOT NULL,
	[Type] [int] NOT NULL,
	[DefaultValue] [nvarchar](50) NULL,
	[ParamName] [nvarchar](255) NULL,
	[AnyAvailable] [bit] NOT NULL DEFAULT ((0)),
	[OperationType] [varchar](255) NULL,
	[Required] [bit] NOT NULL DEFAULT ((0)),
	[OptiTrackDimensionId] [int] NULL,
	[PersonalizationTagId] [int] NULL,
	[OptiTrackParametersId] [varchar](255) NULL)

  
SELECT TOP 1000 [Id]
      ,[EventId]
      ,[Key]
      ,[Type]
      ,[DefaultValue]
      ,[ParamName]
      ,[AnyAvailable]
      ,[OperationType]
      ,[Required]
      ,[OptiTrackDimensionId]
      ,[PersonalizationTagId]
      ,[OptiTrackParametersId]
  FROM [rt].[EventParamsMetaData];

  insert into [rt].[EventParamsMetaData] ([Id], [EventId], [Key], [Type], [DefaultValue], [ParamName], [AnyAvailable], [OperationType], [Required], [OptiTrackDimensionId], [PersonalizationTagId], [OptiTrackParametersId])
  values
(1, 1001, N'originalVisitorId', 0, NULL, N'originalVisitorId', 0, NULL, 0, 8, 0, N'Parameter1'),
(2, 1001, N'userId', 0, NULL, N'userId', 0, NULL, 0, 9, 0, N'Parameter2'),
(3, 1001, N'updatedVisitorId', 0, NULL, N'updatedVisitorId', 0, NULL, 0, 10, 0, N'Parameter3'),

(1, 1002, N'email', 0, NULL, N'email', 0, NULL, 0, 8, 0, N'Parameter1'),

(1, 1003, N'category', 0, NULL, N'category', 0, NULL, 0, 8, 0, N'Parameter1'),

(1, 1004, N'sourcePublicCustomerId', 0, NULL, N'sourcePublicCustomerId', 0, NULL, 0, 8, 0, N'Parameter1') ,
(2, 1004, N'sourceVisitorId', 0, NULL, N'sourceVisitorId', 0, NULL, 0, 9, 0, N'Parameter2'),
(3, 1004, N'targetVsitorId', 0, NULL, N'targetVsitorId', 0, NULL, 0, 10, 0, N'Parameter3'),

(1, 1005, N'user_agent_header', 0, NULL, N'user_agent_header', 0, NULL, 0, 10, 0, N'Parameter1'),
(1, 1005, N'user_agent_header', 0, NULL, N'user_agent_header', 0, NULL, 0, 10, 0, N'Parameter1'),

(1, 1101, N'deposit', 0, NULL, N'deposit', 0, NULL, 0, 8, 0, N'Parameter1')
