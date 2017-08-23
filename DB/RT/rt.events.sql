
  CREATE TABLE [rt].[Event](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[Recuranceable] [bit] NOT NULL,
	[Comments] [nvarchar](1000) NULL,
	[ContradictingEventId] [int] NULL,
	[InvokeBy] [int] NULL,
	[RecycleBy] [int] NULL,
	[EventNameKey] [varchar](255) NULL,
	[EnableRealtime] [bit] NOT NULL DEFAULT ((0)),
	[EnableOptitrack] [bit] NOT NULL DEFAULT ((0)),
	[OptiTrackParametersId] [varchar](255) NULL,
 CONSTRAINT [PK_Event] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]


 
  SET IDENTITY_INSERT [rt].[Event] ON;
  insert into [rt].[Event] ([Id], [Name], [Recuranceable], [Comments], [ContradictingEventId], [InvokeBy], [EventNameKey], [EnableRealtime], [EnableOptitrack])
  values 
  (1001, 'set user Id Predefined event', 0, 'core private sdk predefined event', NULL, NULL, 'set_user_id_event', 1,1),
  (1002, 'set email Predefined event', 0, 'core private sdk predefined event', NULL, NULL, 'Set_email_event', 1,1),
  (1003, 'set page category Predefined event', 0, 'core private sdk predefined event', NULL, NULL, 'page_category_event', 0,1),
  (1004, 'set stitched Predefined event', 0, 'core private sdk predefined event', NULL, NULL, 'stitch_event', 0,1),
  (1005, 'set useragent header Predefined event', 0, 'core private sdk predefined event', NULL, NULL, 'user_agent_header_event', 0,1)
  (1101, 'deposit event', 0, 'custom event', NULL, NULL, 'deposit_event', 1,1)


  SET IDENTITY_INSERT [rt].[Event] OFF;
