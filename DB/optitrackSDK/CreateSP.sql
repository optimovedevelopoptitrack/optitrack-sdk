SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('optitrackSDK.USP_AggregateCustomerAvgVisitTimeData') IS NOT NULL DROP PROCEDURE [OptitrackSDK].[USP_AggregateCustomerAvgVisitTimeData] ;
GO

CREATE PROCEDURE [optitrackSDK].[USP_AggregateCustomerAvgVisitTimeData]
@profileServerName nvarchar(100)= '',
@profileDBName nvarchar(100) = '',
@Alpha Float = 0.05,
@RetroCalc Bit = 0,
@Customers Nvarchar(100) = ''

with recompile

AS
BEGIN
SET XACT_ABORT ON;
set nocount on
set transaction isolation level read uncommitted

DECLARE 

@FullTargetPath nvarchar(max) = '',
@TEMP nvarchar(max) = '',
@sql nvarchar(max) = '',
@SQLSourcePart nvarchar(max) = '',
@CustomersTableExist Bit, 
@CustomersHashLookupTable nvarchar(max) = '',
@HoursSinceLastRun int

SET @HoursSinceLastRun = DATEDIFF(HOUR, (SELECT [PrevCustomerAvgSessionProcessDate] FROM [optitrackSDK].[Config]), GETDATE());

--Check if 24 hours passed since the last run
IF(@HoursSinceLastRun < 24)
	BEGIN
		RETURN
	END
ELSE
	BEGIN
		SET @FullTargetPath =  '[' +  @profileDBName + '].';

		IF(LEN(@profileServerName) >= 1)
		BEGIN
		              SET @FullTargetPath = '['+@profileServerName+']' + '.' +'[' +  @profileDBName + '].' ;
		END
		PRINT(@FullTargetPath);
		
		
		IF(LEN(@Customers) >= 1)
		BEGIN
		SET @CustomersHashLookupTable = @FullTargetPath + '[dbo].' +  @Customers; 
		END
		     
		
		SET @TEMP =  CAST((SELECT [CustomerAvgSessionVisitLastId] FROM [optitrackSDK].[Config]) as nvarchar (50) );
		
		SET @sql = 'select TOP 1 * from ' + @CustomersHashLookupTable
		
		BEGIN TRY
		       EXEC (@sql)
		
		       IF @@ROWCOUNT = 1 
		       BEGIN
		              SET @CustomersTableExist = 1
		       END 
		       ELSE 
		       BEGIN
		              SET @CustomersTableExist = 0
		       END
		END TRY
		BEGIN CATCH
		       SET @CustomersTableExist = 0
		END CATCH
		
		
		
		SET @SQLSourcePart = ';with source as (
		       select Customer_ID, AVG(datediff(second,[VisitFirstActionTime],[VisitLastActionTime])) CustomerAvgTime, count(1) AS NumberOfSessions, MAX(ID) LastComputedSessionID, count (DISTINCT CAST(VisitFirstActionTime AS DATE)) ActiveSessionDays
		       from [optitrackSDK].[PiwikVisit] PS '
		       
		IF @CustomersTableExist = 1
		BEGIN
		       SET @SQLSourcePart += 'INNER JOIN '    + @CustomersHashLookupTable + ' C ON PS.UserId = C.PublicCustomerId 
		                              INNER JOIN [dbo].[OptimoveCustomerIds] DB ON C.CustomerId = DB.Client_Customer_ID'
		END
		ELSE
		BEGIN
		       SET @SQLSourcePart += ' inner join [dbo].[OptimoveCustomerIds] DB ON PS.UserId = DB.Client_Customer_ID'
		END
		
		SET @SQLSourcePart +=    
		          
		          '
		       where PS.Id >= CAST( ' + @TEMP + ' as bigint)' + '
		                and VisitFirstActionTime < VisitLastActionTime'
		                             + CASE WHEN @RetroCalc = 1 THEN 'and not exists(select 1 FROM [optitrackSDK].[CustomerVisitAvgTime] AS T WHERE DB.Customer_ID = T.CustomerID AND PS.Id <= T.LastComputedSessionID)' ELSE '' END +
		                             '
		       group by Customer_ID )'
		
		
		
		SET @sql = @SQLSourcePart + '   
		       MERGE [optitrackSDK].[CustomerVisitAvgTime] AS TARGET USING SOURCE
			   ON TARGET.CustomerID = source.Customer_ID
			   WHEN MATCHED 
			   THEN UPDATE SET CustomerAvgTime = CASE WHEN TARGET.ActiveSessionDays >=7 THEN TARGET.CustomerAvgTime * (1-' + CAST(@Alpha AS NVARCHAR(100)) + ') + SOURCE.CustomerAvgTime * ' + CAST(@Alpha AS NVARCHAR(100)) + '
		       ELSE
		       ((TARGET.CustomerAvgTime * TARGET.NumberOfSessions) + (SOURCE.CustomerAvgTime * SOURCE.NumberOfSessions)) / (TARGET.NumberOfSessions + SOURCE.NumberOfSessions) END, 
		       LastComputedSessionID = source.LastComputedSessionID,
		       NumberOfSessions += source.NumberOfSessions,
		       ActiveSessionDays += source.ActiveSessionDays
			   WHEN NOT MATCHED BY TARGET THEN 
		       INSERT (CustomerID, CustomerAvgTime, NumberOfSessions, LastComputedSessionID,ActiveSessionDays)
		       VALUES(source.Customer_ID, source.CustomerAvgTime, source.NumberOfSessions, source.LastComputedSessionID, SOURCE.ActiveSessionDays);
		       '
		
		print(@sql)
		exec (@sql)


		UPDATE [optitrackSDK].[Config]
		SET [PrevCustomerAvgSessionProcessDate] = GETDATE();
	END

END




SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('optitrackSDK.USP_AggregateCustomerAvgVisitTimeData_Visitor') IS NOT NULL DROP PROCEDURE [OptitrackSDK].[USP_AggregateCustomerAvgVisitTimeData_Visitor] ;
GO

CREATE PROCEDURE [optitrackSDK].[USP_AggregateCustomerAvgVisitTimeData_Visitor]

@Alpha Float = 0.05,
@RetroCalc Bit = 0

with recompile

AS
BEGIN
SET XACT_ABORT ON;
set nocount on
set transaction isolation level read uncommitted

DECLARE 

@TEMP nvarchar(max) = '',
@sql nvarchar(max) = '',
@SQLSourcePart nvarchar(max) = '',
@HoursSinceLastRun int

SET @HoursSinceLastRun = DATEDIFF(HOUR, (SELECT [PrevVisitorsAvgSessionProcessDate] FROM [optitrackSDK].[Config_Visitor]), GETDATE());

--Check if 24 hours passed since the last run
IF(@HoursSinceLastRun < 24)
	BEGIN
		RETURN
	END
ELSE 
	BEGIN
		SET @TEMP =  CAST((SELECT [VisitorsAvgSessionVisitLastId] FROM [optitrackSDK].[Config_Visitor]) as nvarchar (50) );
		
		
		SET @SQLSourcePart = ';with source as (
		       select Customer_ID, AVG(datediff(second,[VisitFirstActionTime],[VisitLastActionTime])) CustomerAvgTime, count(1) AS NumberOfSessions, MAX(ID) LastComputedSessionID, count (DISTINCT CAST(VisitFirstActionTime AS DATE)) ActiveSessionDays
		       from [optitrackSDK].[PiwikVisit] PS '
		       
		
		BEGIN
		       SET @SQLSourcePart += ' inner join [vis].[VisitorOptimoveIds] VI ON PS.VisitorId = VI.VISITOR_ID'
		END
		
		SET @SQLSourcePart +=    
		          
		          '
		       where PS.Id >= CAST( ' + @TEMP + ' as bigint)' + '
		                and VisitFirstActionTime < VisitLastActionTime'
		                             + CASE WHEN @RetroCalc = 1 THEN 'and not exists(select 1 FROM [optitrackSDK].[CustomerVisitAvgTime_Visitor] AS T WHERE VI.CUSTOMER_ID = T.CustomerID AND PS.Id <= T.LastComputedSessionID)' ELSE '' END +
		                             '
		       group by Customer_ID )'
		
		
		
		SET @sql = @SQLSourcePart + '   
		       MERGE [optitrackSDK].[CustomerVisitAvgTime_Visitor] AS TARGET USING SOURCE
			   ON TARGET.CustomerID = source.Customer_ID
			   WHEN MATCHED 
			   THEN UPDATE SET CustomerAvgTime = CASE WHEN TARGET.ActiveSessionDays >=7 THEN TARGET.CustomerAvgTime * (1-' + CAST(@Alpha AS NVARCHAR(100)) + ') + SOURCE.CustomerAvgTime * ' + CAST(@Alpha AS NVARCHAR(100)) + '
		       ELSE
		       ((TARGET.CustomerAvgTime * TARGET.NumberOfSessions) + (SOURCE.CustomerAvgTime * SOURCE.NumberOfSessions)) / (TARGET.NumberOfSessions + SOURCE.NumberOfSessions) END, 
		       LastComputedSessionID = source.LastComputedSessionID,
		       NumberOfSessions += source.NumberOfSessions,
		       ActiveSessionDays += source.ActiveSessionDays
			   WHEN NOT MATCHED BY TARGET THEN 
		       INSERT (CustomerID, CustomerAvgTime, NumberOfSessions, LastComputedSessionID,ActiveSessionDays)
		       VALUES(source.Customer_ID, source.CustomerAvgTime, source.NumberOfSessions, source.LastComputedSessionID, SOURCE.ActiveSessionDays);
		       '
		
		print(@sql)
		exec (@sql)
		
		UPDATE [optitrackSDK].[Config_Visitor]
		SET  [PrevVisitorsAvgSessionProcessDate] = GETDATE();
	END

END


    

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF [dbo].[udf_IsObjectExists]('[optitrackSDK].[USP_AggregateCustomEventData]','SP') = 1 DROP PROCEDURE [optitrackSDK].[USP_AggregateCustomEventData]
GO
CREATE PROCEDURE [optitrackSDK].[USP_AggregateCustomEventData]
AS 
BEGIN

	IF OBJECT_ID('tempdb..#MostRecentCustomEventData') IS NOT NULL DROP TABLE #MostRecentCustomEventData
	SELECT	EventActionTime,													-- EventDateTime
			custom_dimension_1,													-- EventId
			IdsMapping.Customer_ID AS Customer_ID,								-- CustomerId
			piwikVisitAction.Id AS ActionId,
			LOWER(LTRIM(RTRIM(custom_dimension_3))) AS custom_dimension_3,		--1
			LOWER(LTRIM(RTRIM(custom_dimension_4))) AS custom_dimension_4,		--2
			LOWER(LTRIM(RTRIM(custom_dimension_5))) AS custom_dimension_5,		--3
			LOWER(LTRIM(RTRIM(custom_dimension_6))) AS custom_dimension_6,		--4
			LOWER(LTRIM(RTRIM(custom_dimension_7))) AS custom_dimension_7,		--5
			LOWER(LTRIM(RTRIM(custom_dimension_8))) AS custom_dimension_8,		--6
			LOWER(LTRIM(RTRIM(custom_dimension_9))) AS custom_dimension_9,		--7
			LOWER(LTRIM(RTRIM(custom_dimension_10))) AS custom_dimension_10,	--8
			LOWER(LTRIM(RTRIM(custom_dimension_11))) AS custom_dimension_11,	--9
			LOWER(LTRIM(RTRIM(custom_dimension_12))) AS custom_dimension_12,	--10
			LOWER(LTRIM(RTRIM(custom_dimension_13))) AS custom_dimension_13,	--11
			LOWER(LTRIM(RTRIM(custom_dimension_14))) AS custom_dimension_14,	--12
			LOWER(LTRIM(RTRIM(custom_dimension_15))) AS custom_dimension_15,	--13
			LOWER(LTRIM(RTRIM(custom_dimension_16))) AS custom_dimension_16,	--14
			LOWER(LTRIM(RTRIM(custom_dimension_17))) AS custom_dimension_17,	--15
			LOWER(LTRIM(RTRIM(custom_dimension_18))) AS custom_dimension_18,	--16
			LOWER(LTRIM(RTRIM(custom_dimension_19))) AS custom_dimension_19,	--17
			LOWER(LTRIM(RTRIM(custom_dimension_20))) AS custom_dimension_20,	--18
			LOWER(LTRIM(RTRIM(custom_dimension_21))) AS custom_dimension_21,	--19
			LOWER(LTRIM(RTRIM(custom_dimension_22))) AS custom_dimension_22,	--20
			LOWER(LTRIM(RTRIM(custom_dimension_23))) AS custom_dimension_23,	--21
			LOWER(LTRIM(RTRIM(custom_dimension_24))) AS custom_dimension_24,	--22
			LOWER(LTRIM(RTRIM(custom_dimension_25))) AS custom_dimension_25		--23
	INTO #MostRecentCustomEventData
	FROM [optitrackSDK].[PiwikVisitAction] piwikVisitAction 
	JOIN [optitrackSDK].[OptimoveAlias] optimoveAlias ON piwikVisitAction.VisitorId = optimoveAlias.VisitorId
	JOIN [dbo].[OptimoveCustomerIds] IdsMapping ON optimoveAlias.CustomerId = IdsMapping.CLIENT_CUSTOMER_ID
	WHERE custom_dimension_1 > 1100		-- only custom events
		AND NOT EXISTS (				-- prevent duplicates (without error)
			SELECT 1 FROM [optitrackSDK].[CustomEventsRawData]
			WHERE [optitrackSDK].[CustomEventsRawData].ActionId = piwikVisitAction.Id )



	-- keep a copy of the most recent data with dates
	IF OBJECT_ID('tempdb..#VisitActionsWithOnlyDatePart') IS NOT NULL DROP TABLE #VisitActionsWithOnlyDatePart
	SELECT CONVERT(DATE, EventActionTime) AS EventActionDay, *
		INTO #VisitActionsWithOnlyDatePart
		FROM #MostRecentCustomEventData




	-- fill custom event raw data
	------------------------

	INSERT INTO [optitrackSDK].[CustomEventsRawData]
	SELECT * FROM #MostRecentCustomEventData mostRecentData
	



	-- fill total customer daily event aggregation
	----------------------------------------------

	;WITH AggregationByDayCustomer_Latest AS (
		SELECT 
			EventActionDay,
			MAX(ActionId) LastComputedActionID,
			Customer_ID,
			COUNT(*) NumberOfAdditionalDailyEvents
		FROM #VisitActionsWithOnlyDatePart newEvents
		GROUP BY EventActionDay, Customer_ID
	)

	MERGE [optitrackSDK].[TotalCustomDailyEvents] AS MergeTarget
	USING AggregationByDayCustomer_Latest AS MergeSource
	ON (MergeSource.EventActionDay = CONVERT(DATE, MergeTarget.EventDate)
		AND MergeSource.Customer_ID = MergeTarget.CustomerId)

	WHEN MATCHED THEN		-- EXISTING (day, customer) combo -> update existing record in table
		UPDATE SET 
			MergeTarget.NumberOfDailyEvents += MergeSource.NumberOfAdditionalDailyEvents,
			MergeTarget.LastComputedActionID = MergeSource.LastComputedActionID	

	WHEN NOT MATCHED THEN	-- NEW (day, customer) combo -> enter new record in table
		INSERT (EventDate, LastComputedActionID, CustomerId, NumberOfDailyEvents)
		VALUES (EventActionDay, LastComputedActionID, Customer_ID, NumberOfAdditionalDailyEvents);





	-- fill total daily aggregation per event
	-----------------------------------------

	;WITH AggregationByEventDayCustomer_Latest AS (
		SELECT 
			EventActionDay,
			MAX(ActionId) LastComputedActionID,
			Customer_ID,
			custom_dimension_1,
			COUNT(*) NumberOfAdditionalDailyEvents
		FROM #VisitActionsWithOnlyDatePart newEvents
		GROUP BY custom_dimension_1, EventActionDay, Customer_ID
	)


	MERGE [optitrackSDK].[TotalDailyAggregationPerEvent] AS MergeTarget
	USING AggregationByEventDayCustomer_Latest AS MergeSource
	ON (MergeSource.EventActionDay = CONVERT(DATE, MergeTarget.EventDate)
		AND MergeSource.Customer_ID = MergeTarget.CustomerId	
		AND MergeSource.custom_dimension_1 = MergeTarget.EventID)

	WHEN MATCHED THEN		-- EXISTING (day, customer-id, event-id) combo -> update existing record in table
		UPDATE SET 	 
		MergeTarget.NumberOfDailyEvent += MergeSource.NumberOfAdditionalDailyEvents,
		MergeTarget.[LastComputedActionID] = MergeSource.[LastComputedActionID]

	WHEN NOT MATCHED THEN	-- NEW (day, customer-id, event-id) combo -> enter new record in table
		INSERT (EventDate, LastComputedActionID, CustomerId, EventID, NumberOfDailyEvent)
		VALUES (EventActionDay, LastComputedActionID, Customer_ID, custom_dimension_1, NumberOfAdditionalDailyEvents);


END



SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF [dbo].[udf_IsObjectExists]('[optitrackSDK].[USP_AggregateCustomEventData_Visitor]','SP') = 1 DROP PROCEDURE [optitrackSDK].[USP_AggregateCustomEventData_Visitor]
GO
CREATE PROCEDURE [optitrackSDK].[USP_AggregateCustomEventData_Visitor]
AS 
BEGIN

	IF OBJECT_ID('tempdb..#MostRecentCustomEventData') IS NOT NULL DROP TABLE #MostRecentCustomEventData
	SELECT	EventActionTime,													-- EventDateTime
			custom_dimension_1,													-- EventId
			IdsMapping.Customer_ID AS Customer_ID,								-- CustomerId
			piwikVisitAction.Id AS ActionId,									-- ActionId
			LOWER(LTRIM(RTRIM(custom_dimension_3))) AS custom_dimension_3,		--1
			LOWER(LTRIM(RTRIM(custom_dimension_4))) AS custom_dimension_4,		--2
			LOWER(LTRIM(RTRIM(custom_dimension_5))) AS custom_dimension_5,		--3
			LOWER(LTRIM(RTRIM(custom_dimension_6))) AS custom_dimension_6,		--4
			LOWER(LTRIM(RTRIM(custom_dimension_7))) AS custom_dimension_7,		--5
			LOWER(LTRIM(RTRIM(custom_dimension_8))) AS custom_dimension_8,		--6
			LOWER(LTRIM(RTRIM(custom_dimension_9))) AS custom_dimension_9,		--7
			LOWER(LTRIM(RTRIM(custom_dimension_10))) AS custom_dimension_10,	--8
			LOWER(LTRIM(RTRIM(custom_dimension_11))) AS custom_dimension_11,	--9
			LOWER(LTRIM(RTRIM(custom_dimension_12))) AS custom_dimension_12,	--10
			LOWER(LTRIM(RTRIM(custom_dimension_13))) AS custom_dimension_13,	--11
			LOWER(LTRIM(RTRIM(custom_dimension_14))) AS custom_dimension_14,	--12
			LOWER(LTRIM(RTRIM(custom_dimension_15))) AS custom_dimension_15,	--13
			LOWER(LTRIM(RTRIM(custom_dimension_16))) AS custom_dimension_16,	--14
			LOWER(LTRIM(RTRIM(custom_dimension_17))) AS custom_dimension_17,	--15
			LOWER(LTRIM(RTRIM(custom_dimension_18))) AS custom_dimension_18,	--16
			LOWER(LTRIM(RTRIM(custom_dimension_19))) AS custom_dimension_19,	--17
			LOWER(LTRIM(RTRIM(custom_dimension_20))) AS custom_dimension_20,	--18
			LOWER(LTRIM(RTRIM(custom_dimension_21))) AS custom_dimension_21,	--19
			LOWER(LTRIM(RTRIM(custom_dimension_22))) AS custom_dimension_22,	--20
			LOWER(LTRIM(RTRIM(custom_dimension_23))) AS custom_dimension_23,	--21
			LOWER(LTRIM(RTRIM(custom_dimension_24))) AS custom_dimension_24,	--22
			LOWER(LTRIM(RTRIM(custom_dimension_25))) AS custom_dimension_25	--23
	INTO #MostRecentCustomEventData
	FROM [optitrackSDK].[PiwikVisitAction] piwikVisitAction 
	JOIN vis.VisitorOptimoveIds IdsMapping ON piwikVisitAction.VisitorId = IdsMapping.VISITOR_ID
	WHERE custom_dimension_1 > 1100 -- only custom events
		AND NOT EXISTS (			-- prevent duplicates (without error)
			SELECT 1 FROM [optitrackSDK].[CustomEventsRawData_Visitor]
			WHERE [optitrackSDK].[CustomEventsRawData_Visitor].ActionId = piwikVisitAction.Id )


	-- keep a copy of the most recent data with dates
	IF OBJECT_ID('tempdb..#VisitActionsWithOnlyDatePart') IS NOT NULL DROP TABLE #VisitActionsWithOnlyDatePart
	SELECT CONVERT(DATE, EventActionTime) AS EventActionDay, *
		INTO #VisitActionsWithOnlyDatePart
		FROM #MostRecentCustomEventData




	-- fill custom event raw data
	------------------------

	INSERT INTO [optitrackSDK].[CustomEventsRawData_Visitor]
	SELECT * FROM #MostRecentCustomEventData mostRecentData
	



	-- fill total customer daily event aggregation
	----------------------------------------------

	;WITH AggregationByDayCustomer_Latest AS (
		SELECT 
			EventActionDay,
			MAX(ActionId) LastComputedActionID,
			Customer_ID,
			COUNT(*) NumberOfAdditionalDailyEvents
		FROM #VisitActionsWithOnlyDatePart newEvents
		GROUP BY EventActionDay, Customer_ID
	)

	MERGE [optitrackSDK].[TotalCustomDailyEvents_Visitor] AS MergeTarget
	USING AggregationByDayCustomer_Latest AS MergeSource
	ON (MergeSource.EventActionDay = CONVERT(DATE, MergeTarget.EventDate)
		AND MergeSource.Customer_ID = MergeTarget.CustomerId)

	WHEN MATCHED THEN		-- EXISTING (day, customer) combo -> update existing record in table
		UPDATE SET 
			MergeTarget.NumberOfDailyEvents += MergeSource.NumberOfAdditionalDailyEvents,
			MergeTarget.LastComputedActionID = MergeSource.LastComputedActionID	

	WHEN NOT MATCHED THEN	-- NEW (day, customer) combo -> enter new record in table
		INSERT (EventDate, LastComputedActionID, CustomerId, NumberOfDailyEvents)
		VALUES (EventActionDay, LastComputedActionID, Customer_ID, NumberOfAdditionalDailyEvents);





	-- fill total daily aggregation per event
	-----------------------------------------

	;WITH AggregationByEventDayCustomer_Latest AS (
		SELECT 
			EventActionDay,
			MAX(ActionId) LastComputedActionID,
			Customer_ID,
			custom_dimension_1,
			COUNT(*) NumberOfAdditionalDailyEvents
		FROM #VisitActionsWithOnlyDatePart newEvents
		GROUP BY custom_dimension_1, EventActionDay, Customer_ID
	)


	MERGE [optitrackSDK].[TotalDailyAggregationPerEvent_Visitor] AS MergeTarget
	USING AggregationByEventDayCustomer_Latest AS MergeSource
	ON (MergeSource.EventActionDay = CONVERT(DATE, MergeTarget.EventDate)
		AND MergeSource.Customer_ID = MergeTarget.CustomerId	
		AND MergeSource.custom_dimension_1 = MergeTarget.EventID)

	WHEN MATCHED THEN		-- EXISTING (day, customer-id, event-id) combo -> update existing record in table
		UPDATE SET 	 
		MergeTarget.NumberOfDailyEvent += MergeSource.NumberOfAdditionalDailyEvents,
		MergeTarget.[LastComputedActionID] = MergeSource.[LastComputedActionID]

	WHEN NOT MATCHED THEN	-- NEW (day, customer-id, event-id) combo -> enter new record in table
		INSERT (EventDate, LastComputedActionID, CustomerId, EventID, NumberOfDailyEvent)
		VALUES (EventActionDay, LastComputedActionID, Customer_ID, custom_dimension_1, NumberOfAdditionalDailyEvents);


END

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('optitrackSDK.USP_AggregatedVisitInfoRawData') IS NOT NULL DROP PROCEDURE [OptitrackSDK].[USP_AggregatedVisitInfoRawData] ;
GO

CREATE PROCEDURE [optitrackSDK].[USP_AggregatedVisitInfoRawData]
AS
BEGIN
	
  ;WITH Source AS (
	SELECT [FirstVisitTime],[VisitId],[CustomerId],[PlatformId],[LocationCityId],[IP],[LanguageId],[TotalVisitTime]
	FROM (
			SELECT PV.[VisitFirstActionTime] AS [FirstVisitTime], PV.[Id] AS [VisitId], OC.[Customer_ID] AS [CustomerId], PLAT.[PlatformId],
			CITY.[LocationCityId], PV.[IP], LANG.[LanguageId], PV.[TotalVisitTime]
			FROM [optitrackSDK].[PiwikVisit] PV
			JOIN
			[optitrackSDK].[OptimoveAlias] OA
			ON
			PV.[VisitorId] = OA.[VisitorId]
			JOIN
			[dbo].[OptimoveCustomerIds] OC
			ON
			OA.[CustomerId] = OC.[CLIENT_CUSTOMER_ID]
			JOIN
			[optitrackSDK].[Platform] PLAT
			ON 
			PLAT.[Platform] = PV.[Platform]
			JOIN
			[optitrackSDK].[Language] LANG
			ON
			LANG.[Language] = PV.[Language]
			JOIN
			[optitrackSDK].[LocationCity] CITY
			ON CITY.[LocationCity] = PV.[GEO_Location]
	) A
	WHERE [VisitId] > (SELECT [LastAggregatedVisitId] FROM [optitrackSDK].[Config])
	OR ([TotalVisitTime] <> (SELECT [TotalVisitTime] FROM [optitrackSDK].[VisitInfoRawData] WHERE [VisitId] = A.[VisitId])
		AND (SELECT [TotalVisitTime] FROM [optitrackSDK].[VisitInfoRawData] WHERE [VisitId] = A.[VisitId]) IS NOT NULL)	  
	)
	
MERGE [optitrackSDK].[VisitInfoRawData] AS Target
USING Source 
ON Target.[VisitId] = Source.[VisitId] AND Target.[CustomerId] = Source.[CustomerId]
WHEN MATCHED THEN UPDATE SET [TotalVisitTime] = SOURCE.[TotalVisitTime]
WHEN NOT MATCHED BY TARGET THEN INSERT([FirstVisitTime],[VisitId],[CustomerId],[PlatformId],[LocationCityId],[IP],[LanguageId],[TotalVisitTime])
VALUES (SOURCE.[FirstVisitTime],SOURCE.[VisitId],SOURCE.[CustomerId],SOURCE.[PlatformId],SOURCE.[LocationCityId],SOURCE.[IP],SOURCE.[LanguageId],SOURCE.[TotalVisitTime]);

END

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('optitrackSDK.USP_AggregatedVisitInfoRawData_Visitor') IS NOT NULL DROP PROCEDURE [OptitrackSDK].[USP_AggregatedVisitInfoRawData_Visitor] ;
GO
CREATE PROCEDURE [optitrackSDK].[USP_AggregatedVisitInfoRawData_Visitor]
AS
BEGIN
	
  ;WITH Source AS (
	SELECT [FirstVisitTime],[VisitId],[CustomerId],[PlatformId],[LocationCityId],[IP],[LanguageId],[TotalVisitTime]
	FROM (
			SELECT PV.[VisitFirstActionTime] AS [FirstVisitTime], PV.[Id] AS [VisitId], VIS.[CUSTOMER_ID] AS [CustomerId], PLAT.[PlatformId],
			CITY.[LocationCityId], PV.[IP], LANG.[LanguageId], PV.[TotalVisitTime]
			FROM [optitrackSDK].[PiwikVisit] PV
			JOIN
			[vis].[VisitorOptimoveIds] VIS
			ON
			PV.[VisitorId] = VIS.[VISITOR_ID]
			JOIN
			[optitrackSDK].[Platform] PLAT
			ON 
			PLAT.[Platform] = PV.[Platform]
			JOIN
			[optitrackSDK].[Language] LANG
			ON
			LANG.[Language] = PV.[Language]
			JOIN
			[optitrackSDK].[LocationCity] CITY
			ON CITY.[LocationCity] = PV.[GEO_Location]
	) A
	WHERE [VisitId] > (SELECT [LastAggregatedVisitId] FROM [optitrackSDK].[Config])
	OR ([TotalVisitTime] <> (SELECT [TotalVisitTime] FROM [optitrackSDK].[VisitInfoRawData_Visitor] WHERE [VisitId] = A.[VisitId])
		AND (SELECT [TotalVisitTime] FROM [optitrackSDK].[VisitInfoRawData_Visitor] WHERE [VisitId] = A.[VisitId]) IS NOT NULL)	  
	)
	
MERGE [optitrackSDK].[VisitInfoRawData_Visitor] AS Target
USING Source 
ON Target.[VisitId] = Source.[VisitId] AND Target.[CustomerId] = Source.[CustomerId]
WHEN MATCHED THEN UPDATE SET [TotalVisitTime] = SOURCE.[TotalVisitTime]
WHEN NOT MATCHED BY TARGET THEN INSERT([FirstVisitTime],[VisitId],[CustomerId],[PlatformId],[LocationCityId],[IP],[LanguageId],[TotalVisitTime])
VALUES (SOURCE.[FirstVisitTime],SOURCE.[VisitId],SOURCE.[CustomerId],SOURCE.[PlatformId],SOURCE.[LocationCityId],SOURCE.[IP],SOURCE.[LanguageId],SOURCE.[TotalVisitTime]);

END


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('optitrackSDK.USP_AggregateEmailRegister') IS NOT NULL DROP PROCEDURE [OptitrackSDK].[USP_AggregateEmailRegister] ;
GO
CREATE PROCEDURE [optitrackSDK].[USP_AggregateEmailRegister]

AS
BEGIN
	
SET NOCOUNT ON
insert into [optitrackSDK].[EmailRegister] ([CustomerId], [Hash], [Email], [EventDateTime])
	SELECT CustomerId, Hash, Email, FirstTimeEventDateTime FROM
  (select OC.Customer_Id as CustomerId, HASHBYTES('SHA1', LOWER(LTRIM(RTRIM(custom_dimension_3)))) as Hash, LOWER(LTRIM(RTRIM(custom_dimension_3))) as Email, EventActionTime as  FirstTimeEventDateTime,
  row_number() over(partition by OC.Customer_Id, custom_dimension_3 order by EventActionTime asc) as number
  from
    [optitrackSDK].[PiwikVisitAction] PV
    JOIN
    [optitrackSDK].[OptimoveAlias] OA
    ON
    PV.[VisitorId] = OA.[VisitorId]
    JOIN
    [dbo].[OptimoveCustomerIds] OC
    ON
    OA.[CustomerId] = OC.[CLIENT_CUSTOMER_ID]
	WHERE 
	PV.custom_dimension_1 = 1002 
	and 
	PV.custom_dimension_2 = 'Set_email_event' 
	and
	NOT EXISTS (
    SELECT *
    FROM [optitrackSDK].[EmailRegister]  EM 
    WHERE EM.[CustomerId] =  OC.Customer_Id and EM.Hash =  HASHBYTES('SHA1', LOWER(LTRIM(RTRIM(custom_dimension_3)))))	
	) sub 
	where 
	number = 1

END


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('optitrackSDK.USP_AggregateEmailRegister_Visitor') IS NOT NULL DROP PROCEDURE [OptitrackSDK].[USP_AggregateEmailRegister_Visitor] ;
GO
CREATE PROCEDURE [optitrackSDK].[USP_AggregateEmailRegister_Visitor]

AS
BEGIN
	
SET NOCOUNT ON
insert into [optitrackSDK].[EmailRegister_Visitor] ([CustomerId], [Hash], [Email], [EventDateTime])
	SELECT CustomerId, Hash, Email, FirstTimeEventDateTime FROM
  (select VOCID.CUSTOMER_ID as CustomerId, HASHBYTES('SHA1', LOWER(LTRIM(RTRIM(custom_dimension_3)))) as Hash, LOWER(LTRIM(RTRIM(custom_dimension_3))) as Email, EventActionTime as  FirstTimeEventDateTime,
  row_number() over(partition by VOCID.CUSTOMER_ID, custom_dimension_3 order by EventActionTime asc) as number
  from
    [optitrackSDK].[PiwikVisitAction] PV    
     JOIN
    [vis].[VisitorOptimoveIds] VOCID
    ON
    PV.[VisitorId] = VOCID.[VISITOR_ID]
	WHERE 
	PV.custom_dimension_1 = 1002 
	and 
	PV.custom_dimension_2 = 'Set_email_event' 
	and
	NOT EXISTS (
    SELECT * 
    FROM [optitrackSDK].[EmailRegister_Visitor]  EM 
    WHERE EM.[CustomerId] =   VOCID.CUSTOMER_ID and EM.Hash =  HASHBYTES('SHA1', LOWER(LTRIM(RTRIM(custom_dimension_3)))))	
	) sub 
	where 
	number = 1

END



SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('optitrackSDK.USP_AggregatePageVisitEventsRawData') IS NOT NULL DROP PROCEDURE [OptitrackSDK].[USP_AggregatePageVisitEventsRawData] ;
GO
CREATE PROCEDURE [optitrackSDK].[USP_AggregatePageVisitEventsRawData]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	WITH Source AS (SELECT [LastVisitTime],[VisitId],[LastComputedActionID], [CustomerId],[PageTitleId],[NumOfOccurrences] FROM
		( SELECT PV.[VisitFirstActionTime] AS [LastVisitTime], PV.[Id] AS [VisitId], PA.ID AS [LastComputedActionID], OC.[Customer_ID] AS [CustomerId], [PageTitleId],
			ROW_NUMBER() OVER (PARTITION BY [VisitId],[PageTitleId] ORDER BY PA.ID DESC) AS NUMBER,
			COUNT(*) OVER (PARTITION BY [VisitId],[PageTitleId]) AS [NumOfOccurrences]
			FROM 
			[optitrackSDK].[PiwikVisit] PV
			JOIN
			[optitrackSDK].[OptimoveAlias] OA
			ON
			PV.[VisitorId] = OA.[VisitorId]
			JOIN
			[dbo].[OptimoveCustomerIds] OC
			ON
			OA.[CustomerId] = OC.[CLIENT_CUSTOMER_ID]
			JOIN
			[optitrackSDK].[PiwikVisitAction] PA
			ON
			PA.[VisitId] = PV.[Id]
			JOIN
			[optitrackSDK].[PageTitle] T
			ON 
			T.[PageTitleID] = PA.[ActionNameId]
		) A
		WHERE NUMBER = 1	
		AND (
				A.[LastComputedActionID] > (SELECT MAX([LastComputedActionID]) FROM [optitrackSDK].[PageVisitEventsRawData] 
											WHERE [VisitId] = A.[VisitId] AND [PageTitleId] = A.[PageTitleId] AND [CustomerId] = A.[CustomerId])
				OR	(SELECT MAX([LastComputedActionID]) FROM [optitrackSDK].[PageVisitEventsRawData] 
					 WHERE [VisitId] = A.[VisitId] AND [PageTitleId] = A.[PageTitleId] AND [CustomerId] = A.[CustomerId]) 
					 IS NULL
		))
	
	MERGE [optitrackSDK].[PageVisitEventsRawData] AS Target
	USING Source 
	ON Target.[VisitId] = Source.[VisitId] AND Target.[PageTitleId] = Source.[PageTitleId] AND Target.[CustomerId] = Source.[CustomerId]
	WHEN MATCHED THEN UPDATE SET [LastVisitTime] = SOURCE.[LastVisitTime],
								 [LastComputedActionID] = SOURCE.[LastComputedActionID],
								 [NumOfOccurrences] += SOURCE.[NumOfOccurrences]
	WHEN NOT MATCHED BY TARGET THEN INSERT([LastVisitTime],[VisitId],[LastComputedActionID], [CustomerId],[PageTitleId],[NumOfOccurrences])
	VALUES (SOURCE.[LastVisitTime],SOURCE.[VisitId],SOURCE.[LastComputedActionID],SOURCE.[CustomerId],SOURCE.[PageTitleId],SOURCE.[NumOfOccurrences]);

END



SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('optitrackSDK.USP_AggregatePageVisitEventsRawData_Visitor') IS NOT NULL DROP PROCEDURE [OptitrackSDK].[USP_AggregatePageVisitEventsRawData_Visitor] ;
GO
CREATE PROCEDURE [optitrackSDK].[USP_AggregatePageVisitEventsRawData_Visitor]
AS
BEGIN
	WITH Source AS (SELECT [LastVisitTime],[VisitId],[LastComputedActionID], [CustomerId],[PageTitleId],[NumOfOccurrences] FROM
		( SELECT PV.[VisitFirstActionTime] AS [LastVisitTime], PV.[Id] AS [VisitId], PA.ID AS [LastComputedActionID], VIS.[CUSTOMER_ID] AS [CustomerId], [PageTitleId],
			ROW_NUMBER() OVER (PARTITION BY [VisitId],[PageTitleId] ORDER BY PA.ID DESC) AS NUMBER,
			COUNT(*) OVER (PARTITION BY [VisitId],[PageTitleId]) AS [NumOfOccurrences]
			FROM 
			[optitrackSDK].[PiwikVisit] PV
			JOIN
			[vis].[VisitorOptimoveIds] VIS
			ON
			PV.[VisitorId] = VIS.[VISITOR_ID]
			JOIN
			[optitrackSDK].[PiwikVisitAction] PA
			ON
			PA.[VisitId] = PV.[Id]
			JOIN
			[optitrackSDK].[PageTitle] T
			ON 
			T.[PageTitleID] = PA.[ActionNameId]
		) A
		WHERE NUMBER = 1	
		AND (
				A.[LastComputedActionID] > (SELECT MAX([LastComputedActionID]) FROM [optitrackSDK].[PageVisitEventsRawData_Visitor] 
											WHERE [VisitId] = A.[VisitId] AND [PageTitleId] = A.[PageTitleId] AND [CustomerId] = A.[CustomerId])
				OR	(SELECT MAX([LastComputedActionID]) FROM [optitrackSDK].[PageVisitEventsRawData_Visitor] 
					 WHERE [VisitId] = A.[VisitId] AND [PageTitleId] = A.[PageTitleId] AND [CustomerId] = A.[CustomerId]) 
					 IS NULL
		))
	
	MERGE [optitrackSDK].[PageVisitEventsRawData_Visitor] AS Target
	USING Source 
	ON Target.[VisitId] = Source.[VisitId] AND Target.[PageTitleId] = Source.[PageTitleId] AND Target.[CustomerId] = Source.[CustomerId]
	WHEN MATCHED THEN UPDATE SET [LastVisitTime] = SOURCE.[LastVisitTime],
								 [LastComputedActionID] = SOURCE.[LastComputedActionID],
								 [NumOfOccurrences] += SOURCE.[NumOfOccurrences]
	WHEN NOT MATCHED BY TARGET THEN INSERT([LastVisitTime],[VisitId],[LastComputedActionID], [CustomerId],[PageTitleId],[NumOfOccurrences])
	VALUES (SOURCE.[LastVisitTime],SOURCE.[VisitId],SOURCE.[LastComputedActionID],SOURCE.[CustomerId],SOURCE.[PageTitleId],SOURCE.[NumOfOccurrences]);
END


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('optitrackSDK.USP_AggregateSetUserIdEvents') IS NOT NULL DROP PROCEDURE [OptitrackSDK].[USP_AggregateSetUserIdEvents] ;
GO
CREATE PROCEDURE [optitrackSDK].[USP_AggregateSetUserIdEvents] 

AS
BEGIN
	
	SET NOCOUNT ON
insert into [optitrackSDK].[SetUserIdEvent] (VisitId, OriginalvisitorId, UpdatedVisitorId, PublicUserId, FirstTimeEventDateTime)
  (
  SELECT VisitId, OriginalvisitorId, UpdatedVisitorId, PublicUserId ,FirstTimeEventDateTime FROM
  (select VisitId,  custom_dimension_3 as OriginalvisitorId,  custom_dimension_5 as UpdatedVisitorId,  custom_dimension_4 as PublicUserId, EventActionTime as  FirstTimeEventDateTime,
  row_number() over(partition by custom_dimension_3 order by EventActionTime asc) as number
  from
   [optitrackSDK].[PiwikVisitAction] 

   WHERE  custom_dimension_1 = 1001 and custom_dimension_3 not in (select OriginalvisitorId from [optitrackSDK].[SetUserIdEvent] )) SUB
      where number = 1
	  )

END

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('optitrackSDK.USP_AggregateTotalDailyPagesVisitsAggregation') IS NOT NULL DROP PROCEDURE [OptitrackSDK].[USP_AggregateTotalDailyPagesVisitsAggregation] ;
GO
CREATE PROCEDURE [optitrackSDK].[USP_AggregateTotalDailyPagesVisitsAggregation]
AS
BEGIN
	WITH Source AS (
	SELECT [Date],[LastComputedActionID], [CustomerId],[NumOfPageVisits] FROM
		( 
			SELECT [Date],MAX([LastComputedActionID]) AS [LastComputedActionID],[CustomerId],SUM([NumOfTotalPageVisits]) AS NumOfPageVisits
			FROM [optitrackSDK].[TotalDailySinglePageVisitsAggregation]
			GROUP BY [Date],[CustomerId]
		) A
		WHERE [LastComputedActionID] > (SELECT MAX([LastComputedActionID]) FROM [optitrackSDK].[TotalDailyPagesVisitsAggregation] 
										 WHERE [Date] = A.[Date] AND [CustomerId] = A.[CustomerId])
		OR 
		(SELECT MAX([LastComputedActionID]) FROM [optitrackSDK].[TotalDailyPagesVisitsAggregation] 
			WHERE [Date] = A.[Date] AND [CustomerId] = A.[CustomerId]
		) IS NULL
	)
	
	MERGE [optitrackSDK].[TotalDailyPagesVisitsAggregation] AS Target
	USING Source 
	ON CONVERT(date, Target.[Date]) = CONVERT(date, Source.[Date]) AND Target.[CustomerId] = Source.[CustomerId]
	WHEN MATCHED THEN UPDATE SET [NumOfPageVisits] = SOURCE.[NumOfPageVisits],
								 [LastComputedActionID] = SOURCE.[LastComputedActionID]
	WHEN NOT MATCHED BY TARGET THEN INSERT([Date],[LastComputedActionID],[CustomerId],[NumOfPageVisits])
	VALUES (SOURCE.[Date],SOURCE.[LastComputedActionID],SOURCE.[CustomerId],SOURCE.[NumOfPageVisits]);
END



SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('optitrackSDK.USP_AggregateTotalDailyPagesVisitsAggregation_Visitor') IS NOT NULL DROP PROCEDURE [OptitrackSDK].[USP_AggregateTotalDailyPagesVisitsAggregation_Visitor] ;
GO

CREATE PROCEDURE [optitrackSDK].[USP_AggregateTotalDailyPagesVisitsAggregation_Visitor]
AS
BEGIN
	WITH Source AS (
	SELECT [Date],[LastComputedActionID], [CustomerId],[NumOfPageVisits] FROM
		( 
			SELECT [Date],MAX([LastComputedActionID]) AS [LastComputedActionID],[CustomerId],SUM([NumOfTotalPageVisits]) AS NumOfPageVisits
			FROM [optitrackSDK].[TotalDailySinglePageVisitsAggregation_Visitor]
			GROUP BY [Date],[CustomerId]
		) A
		WHERE [LastComputedActionID] > (SELECT MAX([LastComputedActionID]) FROM [optitrackSDK].[TotalDailyPagesVisitsAggregation_Visitor] 
										 WHERE [Date] = A.[Date] AND [CustomerId] = A.[CustomerId])
		OR 
		(SELECT MAX([LastComputedActionID]) FROM [optitrackSDK].[TotalDailyPagesVisitsAggregation_Visitor] 
			WHERE [Date] = A.[Date] AND [CustomerId] = A.[CustomerId]
		) IS NULL
	)
	
	MERGE [optitrackSDK].[TotalDailyPagesVisitsAggregation_Visitor] AS Target
	USING Source 
	ON CONVERT(date, Target.[Date]) = CONVERT(date, Source.[Date]) AND Target.[CustomerId] = Source.[CustomerId]
	WHEN MATCHED THEN UPDATE SET [NumOfPageVisits] = SOURCE.[NumOfPageVisits],
								 [LastComputedActionID] = SOURCE.[LastComputedActionID]
	WHEN NOT MATCHED BY TARGET THEN INSERT([Date],[LastComputedActionID],[CustomerId],[NumOfPageVisits])
	VALUES (SOURCE.[Date],SOURCE.[LastComputedActionID],SOURCE.[CustomerId],SOURCE.[NumOfPageVisits]);
END



SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('optitrackSDK.USP_AggregateTotalDailySinglePageTitleAggregation') IS NOT NULL DROP PROCEDURE [OptitrackSDK].[USP_AggregateTotalDailySinglePageTitleAggregation] ;
GO
CREATE PROCEDURE [optitrackSDK].[USP_AggregateTotalDailySinglePageTitleAggregation]

AS
BEGIN

WITH Source AS (
	SELECT [Date],[LastComputedActionID], [CustomerId],[PageTitleID],[NumOfOccurrences] FROM
		( 
		SELECT PV.[VisitFirstActionTime] AS [Date], PA.[Id] AS [LastComputedActionID], OC.[Customer_ID] AS [CustomerId], PA.[ActionNameId] AS [PageTitleID],
			ROW_NUMBER() OVER (PARTITION BY [Customer_ID],[ActionNameId] ORDER BY PA.[Id] DESC) AS NUMBER,
			COUNT(*) OVER (PARTITION BY [Customer_ID],[ActionNameId]) AS [NumOfOccurrences]
			FROM 
			[optitrackSDK].[PiwikVisit] PV
			JOIN
			[optitrackSDK].[OptimoveAlias] OA
			ON
			PV.[VisitorId] = OA.[VisitorId]
			JOIN
			[dbo].[OptimoveCustomerIds] OC
			ON
			OA.[CustomerId] = OC.[CLIENT_CUSTOMER_ID]
			JOIN
			[optitrackSDK].[PiwikVisitAction] PA
			ON
			PA.[VisitId] = PV.[Id]
		) A
		WHERE NUMBER = 1
		AND [PageTitleID] IS NOT NULL
		AND (
						A.[LastComputedActionID] > (SELECT MAX([LastComputedActionID]) FROM [optitrackSDK].[TotalDailySinglePageTitleAggregation] 
											WHERE CONVERT(date, [Date]) = CONVERT(date, A.[Date]) AND [PageTitleID] = A.[PageTitleID] AND [CustomerId] = A.[CustomerId])
				OR	
				(SELECT MAX([LastComputedActionID]) FROM [optitrackSDK].[TotalDailySinglePageTitleAggregation] 
					 WHERE  CONVERT(date, [Date]) = CONVERT(date, A.[Date]) AND [PageTitleID] = A.[PageTitleID] AND [CustomerId] = A.[CustomerId]) 
					 IS NULL
		))
	
	MERGE [optitrackSDK].[TotalDailySinglePageTitleAggregation] AS Target
	USING Source 
	ON CONVERT(date, Target.[Date]) = CONVERT(date, Source.[Date]) AND Target.[PageTitleID] = Source.[PageTitleID] AND Target.[CustomerId] = Source.[CustomerId]
	WHEN MATCHED THEN UPDATE SET [NumOfTotalPageVisits] += SOURCE.[NumOfOccurrences],
								 [LastComputedActionID] = SOURCE.[LastComputedActionID]
	WHEN NOT MATCHED BY TARGET THEN INSERT([Date],[LastComputedActionID],[CustomerId],[PageTitleID],[NumOfTotalPageVisits])
	VALUES (SOURCE.[Date],SOURCE.[LastComputedActionID],SOURCE.[CustomerId],SOURCE.[PageTitleID],SOURCE.[NumOfOccurrences]);

END



SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('optitrackSDK.USP_AggregateTotalDailySinglePageTitleAggregation_Visitor') IS NOT NULL DROP PROCEDURE [OptitrackSDK].[USP_AggregateTotalDailySinglePageTitleAggregation_Visitor] ;
GO
CREATE PROCEDURE [optitrackSDK].[USP_AggregateTotalDailySinglePageTitleAggregation_Visitor]

AS
BEGIN

WITH Source AS (
	SELECT [Date],[LastComputedActionID], [CustomerId],[PageTitleID],[NumOfOccurrences] FROM
		( 
		SELECT PV.[VisitFirstActionTime] AS [Date], PA.[Id] AS [LastComputedActionID], VIS.[CUSTOMER_ID] AS [CustomerId], PA.[ActionNameId] AS [PageTitleID],
			ROW_NUMBER() OVER (PARTITION BY [Customer_ID],[ActionNameId] ORDER BY PA.[Id] DESC) AS NUMBER,
			COUNT(*) OVER (PARTITION BY [Customer_ID],[ActionNameId]) AS [NumOfOccurrences]
			FROM 
			[optitrackSDK].[PiwikVisit] PV
			JOIN
			[vis].[VisitorOptimoveIds] VIS
			ON
			PV.[VisitorId] = VIS.[VISITOR_ID]
			JOIN
			[optitrackSDK].[PiwikVisitAction] PA
			ON
			PA.[VisitId] = PV.[Id]
		) A
		WHERE NUMBER = 1
		AND [PageTitleID] IS NOT NULL
		AND (
						A.[LastComputedActionID] > (SELECT MAX([LastComputedActionID]) FROM [optitrackSDK].[TotalDailySinglePageTitleAggregation_Visitor] 
											WHERE CONVERT(date, [Date]) = CONVERT(date, A.[Date]) AND [PageTitleID] = A.[PageTitleID] AND [CustomerId] = A.[CustomerId])
				OR	
				(SELECT MAX([LastComputedActionID]) FROM [optitrackSDK].[TotalDailySinglePageTitleAggregation_Visitor] 
					 WHERE  CONVERT(date, [Date]) = CONVERT(date, A.[Date]) AND [PageTitleID] = A.[PageTitleID] AND [CustomerId] = A.[CustomerId]) 
					 IS NULL
		))
	
	MERGE [optitrackSDK].[TotalDailySinglePageTitleAggregation_Visitor] AS Target
	USING Source 
	ON CONVERT(date, Target.[Date]) = CONVERT(date, Source.[Date]) AND Target.[PageTitleID] = Source.[PageTitleID] AND Target.[CustomerId] = Source.[CustomerId]
	WHEN MATCHED THEN UPDATE SET [NumOfTotalPageVisits] += SOURCE.[NumOfOccurrences],
								 [LastComputedActionID] = SOURCE.[LastComputedActionID]
	WHEN NOT MATCHED BY TARGET THEN INSERT([Date],[LastComputedActionID],[CustomerId],[PageTitleID],[NumOfTotalPageVisits])
	VALUES (SOURCE.[Date],SOURCE.[LastComputedActionID],SOURCE.[CustomerId],SOURCE.[PageTitleID],SOURCE.[NumOfOccurrences]);

END



SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('optitrackSDK.USP_AggregateTotalDailySinglePageVisitsAggregation') IS NOT NULL DROP PROCEDURE [OptitrackSDK].[USP_AggregateTotalDailySinglePageVisitsAggregation] ;
GO

CREATE PROCEDURE [optitrackSDK].[USP_AggregateTotalDailySinglePageVisitsAggregation]

AS
BEGIN

WITH Source AS (
	SELECT [Date],[LastComputedActionID], [CustomerId],[URLID],[NumOfOccurrences] FROM
		( 
		SELECT PV.[VisitFirstActionTime] AS [Date], PA.[Id] AS [LastComputedActionID], OC.[Customer_ID] AS [CustomerId], PA.[UrlActionId] AS [URLID],
			ROW_NUMBER() OVER (PARTITION BY [Customer_ID],[UrlActionId] ORDER BY PA.[Id] DESC) AS NUMBER,
			COUNT(*) OVER (PARTITION BY [Customer_ID],[UrlActionId]) AS [NumOfOccurrences]
			FROM 
			[optitrackSDK].[PiwikVisit] PV
			JOIN
			[optitrackSDK].[OptimoveAlias] OA
			ON
			PV.[VisitorId] = OA.[VisitorId]
			JOIN
			[dbo].[OptimoveCustomerIds] OC
			ON
			OA.[CustomerId] = OC.[CLIENT_CUSTOMER_ID]
			JOIN
			[optitrackSDK].[PiwikVisitAction] PA
			ON
			PA.[VisitId] = PV.[Id]
		) A
		WHERE NUMBER = 1	
		AND [URLID] IN (SELECT [URLID] FROM [optitrackSDK].[URL])
		AND (
						A.[LastComputedActionID] > (SELECT MAX([LastComputedActionID]) FROM [optitrackSDK].[TotalDailySinglePageVisitsAggregation] 
											WHERE CONVERT(date, [Date]) = CONVERT(date, A.[Date]) AND [URLID] = A.[URLID] AND [CustomerId] = A.[CustomerId])
				OR	
				(SELECT MAX([LastComputedActionID]) FROM [optitrackSDK].[TotalDailySinglePageVisitsAggregation] 
					 WHERE  CONVERT(date, [Date]) = CONVERT(date, A.[Date]) AND [URLID] = A.[URLID] AND [CustomerId] = A.[CustomerId]) 
					 IS NULL
		))

	MERGE [optitrackSDK].[TotalDailySinglePageVisitsAggregation] AS Target
	USING Source 
	ON CONVERT(date, Target.[Date]) = CONVERT(date, Source.[Date]) AND Target.[URLID] = Source.[URLID] AND Target.[CustomerId] = Source.[CustomerId]
	WHEN MATCHED THEN UPDATE SET [NumOfTotalPageVisits] += SOURCE.[NumOfOccurrences],
								 [LastComputedActionID] = SOURCE.[LastComputedActionID]
	WHEN NOT MATCHED BY TARGET THEN INSERT([Date],[LastComputedActionID],[CustomerId],[URLID],[NumOfTotalPageVisits])
	VALUES (SOURCE.[Date],SOURCE.[LastComputedActionID],SOURCE.[CustomerId],SOURCE.[URLID],SOURCE.[NumOfOccurrences]);

END


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('optitrackSDK.USP_AggregateTotalDailySinglePageVisitsAggregation_Visitor') IS NOT NULL DROP PROCEDURE [OptitrackSDK].[USP_AggregateTotalDailySinglePageVisitsAggregation_Visitor] ;
GO

CREATE PROCEDURE [optitrackSDK].[USP_AggregateTotalDailySinglePageVisitsAggregation_Visitor]

AS
BEGIN

WITH Source AS (
	SELECT [Date],[LastComputedActionID], [CustomerId],[URLID],[NumOfOccurrences] FROM
		( 
		SELECT PV.[VisitFirstActionTime] AS [Date], PA.[Id] AS [LastComputedActionID], VIS.[CUSTOMER_ID] AS [CustomerId], PA.[UrlActionId] AS [URLID],
			ROW_NUMBER() OVER (PARTITION BY [Customer_ID],[UrlActionId] ORDER BY PA.[Id] DESC) AS NUMBER,
			COUNT(*) OVER (PARTITION BY [Customer_ID],[UrlActionId]) AS [NumOfOccurrences]
			FROM 
			[optitrackSDK].[PiwikVisit] PV
			JOIN
			[vis].[VisitorOptimoveIds] VIS
			ON
			PV.[VisitorId] = VIS.[VISITOR_ID]
			JOIN
			[optitrackSDK].[PiwikVisitAction] PA
			ON
			PA.[VisitId] = PV.[Id]
		) A
		WHERE NUMBER = 1	
		AND [URLID] IN (SELECT [URLID] FROM [optitrackSDK].[URL])
		AND (
						A.[LastComputedActionID] > (SELECT MAX([LastComputedActionID]) FROM [optitrackSDK].[TotalDailySinglePageVisitsAggregation_Visitor] 
											WHERE CONVERT(date, [Date]) = CONVERT(date, A.[Date]) AND [URLID] = A.[URLID] AND [CustomerId] = A.[CustomerId])
				OR	
				(SELECT MAX([LastComputedActionID]) FROM [optitrackSDK].[TotalDailySinglePageVisitsAggregation_Visitor] 
					 WHERE  CONVERT(date, [Date]) = CONVERT(date, A.[Date]) AND [URLID] = A.[URLID] AND [CustomerId] = A.[CustomerId]) 
					 IS NULL
		))

	MERGE [optitrackSDK].[TotalDailySinglePageVisitsAggregation_Visitor] AS Target
	USING Source 
	ON CONVERT(date, Target.[Date]) = CONVERT(date, Source.[Date]) AND Target.[URLID] = Source.[URLID] AND Target.[CustomerId] = Source.[CustomerId]
	WHEN MATCHED THEN UPDATE SET [NumOfTotalPageVisits] += SOURCE.[NumOfOccurrences],
								 [LastComputedActionID] = SOURCE.[LastComputedActionID]
	WHEN NOT MATCHED BY TARGET THEN INSERT([Date],[LastComputedActionID],[CustomerId],[URLID],[NumOfTotalPageVisits])
	VALUES (SOURCE.[Date],SOURCE.[LastComputedActionID],SOURCE.[CustomerId],SOURCE.[URLID],SOURCE.[NumOfOccurrences]);

END


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('optitrackSDK.USP_AggregateTotalVisitsInfoAggregation') IS NOT NULL DROP PROCEDURE [OptitrackSDK].[USP_AggregateTotalVisitsInfoAggregation] ;
GO
CREATE PROCEDURE [optitrackSDK].[USP_AggregateTotalVisitsInfoAggregation]

AS
BEGIN
	
	;WITH Source AS (
	SELECT [Date],[CustomerId],[TotalVisitTime],[TotalNumberOfVisits] FROM
		( 
			SELECT CONVERT(date, [FirstVisitTime]) AS [Date],[CustomerId],SUM([TotalVisitTime]) AS [TotalVisitTime], COUNT([VisitId]) AS [TotalNumberOfVisits]
			FROM [optitrackSDK].[VisitInfoRawData] 
			GROUP BY CONVERT(date, [FirstVisitTime]),[CustomerId]
		) A
		WHERE NOT EXISTS (SELECT * FROM [optitrackSDK].[TotalVisitsInfoAggregation] TVI
							WHERE TVI.[Date] = A.[Date] AND TVI.[CustomerId] = A.[CustomerId] 
							AND TVI.[TotalVisitTime] = A.[TotalVisitTime] AND TVI.[TotalNumberOfVisits] = A.[TotalNumberOfVisits])
	)
	
	MERGE [optitrackSDK].[TotalVisitsInfoAggregation] AS Target
	USING Source 
	ON CONVERT(date, Target.[Date]) = CONVERT(date, Source.[Date]) AND Target.[CustomerId] = Source.[CustomerId]
	WHEN MATCHED THEN UPDATE SET [TotalNumberOfVisits] = SOURCE.[TotalNumberOfVisits],
								 [TotalVisitTime] = SOURCE.[TotalVisitTime]
	WHEN NOT MATCHED BY TARGET THEN INSERT([Date],[CustomerId],[TotalVisitTime],[TotalNumberOfVisits])
	VALUES (SOURCE.[Date],SOURCE.[CustomerId],SOURCE.[TotalVisitTime],SOURCE.[TotalNumberOfVisits]);

END


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('optitrackSDK.USP_AggregateTotalVisitsInfoAggregation_Visitor') IS NOT NULL DROP PROCEDURE [OptitrackSDK].[USP_AggregateTotalVisitsInfoAggregation_Visitor] ;
GO
CREATE PROCEDURE [optitrackSDK].[USP_AggregateTotalVisitsInfoAggregation_Visitor]

AS
BEGIN
	
	;WITH Source AS (
	SELECT [Date],[CustomerId],[TotalVisitTime],[TotalNumberOfVisits] FROM
		( 
			SELECT CONVERT(date, [FirstVisitTime]) AS [Date],[CustomerId],SUM([TotalVisitTime]) AS [TotalVisitTime], COUNT([VisitId]) AS [TotalNumberOfVisits]
			FROM [optitrackSDK].[VisitInfoRawData_Visitor]
			GROUP BY CONVERT(date, [FirstVisitTime]),[CustomerId]
		) A
		WHERE NOT EXISTS (SELECT * FROM [optitrackSDK].[TotalVisitsInfoAggregation_Visitor] TVI
							WHERE TVI.[Date] = A.[Date] AND TVI.[CustomerId] = A.[CustomerId] 
							AND TVI.[TotalVisitTime] = A.[TotalVisitTime] AND TVI.[TotalNumberOfVisits] = A.[TotalNumberOfVisits])
	)
	
	MERGE [optitrackSDK].[TotalVisitsInfoAggregation_Visitor] AS Target
	USING Source 
	ON CONVERT(date, Target.[Date]) = CONVERT(date, Source.[Date]) AND Target.[CustomerId] = Source.[CustomerId]
	WHEN MATCHED THEN UPDATE SET [TotalNumberOfVisits] = SOURCE.[TotalNumberOfVisits],
								 [TotalVisitTime] = SOURCE.[TotalVisitTime]
	WHEN NOT MATCHED BY TARGET THEN INSERT([Date],[CustomerId],[TotalVisitTime],[TotalNumberOfVisits])
	VALUES (SOURCE.[Date],SOURCE.[CustomerId],SOURCE.[TotalVisitTime],SOURCE.[TotalNumberOfVisits]);

END


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('optitrackSDK.USP_AggregateUserAgentIds') IS NOT NULL DROP PROCEDURE [OptitrackSDK].[USP_AggregateUserAgentIds] ;
GO
CREATE PROCEDURE [optitrackSDK].[USP_AggregateUserAgentIds]
AS
BEGIN
	
	SET NOCOUNT ON

  insert into  [optitrackSDK].[UserAgentsId] ( UserAgent, Hash)
	(SELECT DIstinct LOWER(LTRIM(RTRIM(custom_dimension_3))),  HASHBYTES('SHA1', LOWER(LTRIM(RTRIM(custom_dimension_3)))) FROM  [optitrackSDK].[PiwikVisitAction] 
	WHERE 
	custom_dimension_1 = 1005 
	and 
	custom_dimension_2 = 'user_agent_header_event' 

	 And 
	 HASHBYTES('SHA1', LOWER(LTRIM(RTRIM(custom_dimension_3)))) 
	 not in (select Hash from [optitrackSDK].[UserAgentsId])
	)
 

END


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('optitrackSDK.USP_AggregateUserAgentsHeaderEvent') IS NOT NULL DROP PROCEDURE [OptitrackSDK].[USP_AggregateUserAgentsHeaderEvent] ;
GO
-- =============================================
-- Author:		Yossi Cohn
-- Create date:
-- Description:	
-- Using the Unique Coupled key to prevent double insertion per <CustomerId, UserAgentId>
-- =============================================
CREATE PROCEDURE [optitrackSDK].[USP_AggregateUserAgentsHeaderEvent] 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   
insert into [optitrackSDK].[UserAgentHeaderEvent] (CustomerId, UserAgentId, FirstRecognitionEventDateTime)

	select
	 CustomerId, UserAgentId, FirstRecognitionEventDateTime 
	from  
	(select  OC.Customer_ID as CustomerId, UAID.UserAgentId as UserAgentId  , EventActionTime as FirstRecognitionEventDateTime, row_number() over( partition by CustomerId ,UAID.UserAgentId order by  EventActionTime asc) as number
	  from [optitrackSDK].[PiwikVisitAction] PV
    JOIN
    [optitrackSDK].[OptimoveAlias] OA
    ON
    PV.[VisitorId] = OA.[VisitorId]
    JOIN
    [dbo].[OptimoveCustomerIds] OC
    ON
    OA.[CustomerId] = OC.[CLIENT_CUSTOMER_ID]
	inner Join 
	[optitrackSDK].[UserAgentsId] UAID
	ON
	UAID.Hash =  HASHBYTES('SHA1', LOWER(LTRIM(RTRIM(PV.custom_dimension_3)))) 
	WHERE 
	PV.custom_dimension_1 = 1005 
	and 
	PV.custom_dimension_2 = 'user_agent_header_event' ) sub 
	where 
	number = 1
	
END
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('optitrackSDK.USP_AggregateUserAgentsHeaderEvent_Visitor') IS NOT NULL DROP PROCEDURE [OptitrackSDK].[USP_AggregateUserAgentsHeaderEvent_Visitor] ;
GO
CREATE PROCEDURE [optitrackSDK].[USP_AggregateUserAgentsHeaderEvent_Visitor] 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   
insert into [optitrackSDK].[UserAgentHeaderEvent_Visitor] (CustomerId, UserAgentId, FirstRecognitionEventDateTime)

	select
	 CustomerId, UserAgentId, FirstRecognitionEventDateTime 
	from  
	(select  VOCID.[CUSTOMER_ID] as CustomerId, UAID.UserAgentId as UserAgentId  , EventActionTime as FirstRecognitionEventDateTime, row_number() over( partition by VOCID.[CUSTOMER_ID] ,UAID.UserAgentId order by  EventActionTime asc) as number
	  from [optitrackSDK].[PiwikVisitAction] PV
    JOIN
    [vis].[VisitorOptimoveIds] VOCID
    ON
    PV.[VisitorId] = VOCID.[VISITOR_ID]
	inner Join 
	[optitrackSDK].[UserAgentsId] UAID
	ON
	UAID.Hash =  HASHBYTES('SHA1', LOWER(LTRIM(RTRIM(PV.custom_dimension_3)))) 
	WHERE 
	PV.custom_dimension_1 = 1005 
	and 
	PV.custom_dimension_2 = 'user_agent_header_event' ) sub 
	where 
	number = 1
	
END
GO



SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('optitrackSDK.USP_CollectSplittedVisitIdsFromPreviousETL') IS NOT NULL DROP PROCEDURE [OptitrackSDK].[USP_CollectSplittedVisitIdsFromPreviousETL] ;
GO


CREATE PROCEDURE [optitrackSDK].[USP_CollectSplittedVisitIdsFromPreviousETL] 

AS
BEGIN
	
	SET NOCOUNT ON

	INSERT [optitrackSDK].[SplittedVisitIds_TEMP]
	SELECT DISTINCT [VisitId]
	FROM [optitrackSDK].[PiwikVisitAction]
	WHERE [VisitId] <= (SELECT [LastAggregatedVisitId] FROM [optitrackSDK].[Config])
	GROUP BY [VisitId]

END


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('optitrackSDK.USP_FillAlreadyRegisteredVisitorsAsCustomersTable') IS NOT NULL DROP PROCEDURE [OptitrackSDK].[USP_FillAlreadyRegisteredVisitorsAsCustomersTable] ;
GO

CREATE PROCEDURE [optitrackSDK].[USP_FillAlreadyRegisteredVisitorsAsCustomersTable]
	-- Add the parameters for the stored procedure here
	@profileServerName nvarchar(50)= '',
    @profileDBName nvarchar(50) = '',
	@lookupTableName nvarchar(100) = '',
	@isHashingTableNotExists int

AS
BEGIN

	SET NOCOUNT ON;

	DECLARE 
	@sql nvarchar(max) = '',
	@FullTargetPath nvarchar(max) = '',
	@lookupTableNameTargetPath nvarchar(max) = ''

	SET @FullTargetPath = '[' + @profileDBName + ']' + '.';
	IF(LEN(@profileServerName) >= 1)
	BEGIN
              SET @FullTargetPath = '[' + @profileServerName + ']' + '.' + '[' + @profileDBName + ']' + '.' ;
	END


	IF(LEN(@lookupTableName) >= 1)
	BEGIN
	SET @lookupTableNameTargetPath = @FullTargetPath + '[dbo].' +  @lookupTableName; 
	END

	IF(@isHashingTableNotExists = 0)
		BEGIN
			SET @sql = 'INSERT INTO [optitrackSDK].[AlreadyRegisteredVisitorsAsCustomers]
					SELECT * FROM 
					(
							SELECT OC.[CLIENT_CUSTOMER_ID],OC.[Customer_ID] AS Optimove_Customer_ID, V.[VISITOR_ID], V.[CUSTOMER_ID] AS Optimove_VISITOR_ID
							FROM 
							[dbo].[OptimoveCustomerIds] OC
							JOIN
							' + @lookupTableNameTargetPath + ' H
							ON
							OC.[CLIENT_CUSTOMER_ID] = H.[CustomerID]
							JOIN
							[optitrackSDK].[CustomersBeforeRegister_TMP] CBR
							ON 
							CBR.[CustomerId] = H.[PublicCustomerId]
							JOIN
							[vis].[VisitorOptimoveIds] V
							ON CBR.[OriginalVisitorID] = V.[VISITOR_ID]
					) A'

			EXEC(@sql)
		END
	ELSE
		BEGIN
			INSERT INTO [optitrackSDK].[AlreadyRegisteredVisitorsAsCustomers]
			SELECT * FROM 
			(
				SELECT OC.[CLIENT_CUSTOMER_ID],OC.[Customer_ID] AS Optimove_Customer_ID, V.[VISITOR_ID], V.[CUSTOMER_ID] AS Optimove_VISITOR_ID
				FROM 
				[dbo].[OptimoveCustomerIds] OC
				JOIN
				[optitrackSDK].[CustomersBeforeRegister_TMP] CBR
				ON CBR.[CustomerId] = OC.[CLIENT_CUSTOMER_ID]
				JOIN
				[vis].[VisitorOptimoveIds] V
				ON CBR.[OriginalVisitorID] = V.[VISITOR_ID]
			) A
		END
	
END





SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF [dbo].[udf_IsObjectExists]('[optitrackSDK].[USP_FillCustomEventDataForUI]','SP') = 1 DROP PROCEDURE [optitrackSDK].[USP_FillCustomEventDataForUI]
GO
CREATE PROCEDURE [optitrackSDK].[USP_FillCustomEventDataForUI]
AS 
BEGIN
	
	DECLARE @lastAggregatedActionId BIGINT
	SELECT @lastAggregatedActionId = LastAggregatedActionId FROM [optitrackSDK].Config
	--SELECT @lastAggregatedActionId

	IF OBJECT_ID('tempdb..#RecentCustomEventData') IS NOT NULL DROP TABLE #RecentCustomEventData
	SELECT * INTO #RecentCustomEventData 
	FROM 
	(
		SELECT * FROM [optitrackSDK].[CustomEventsRawData]
		UNION 
		SELECT * FROM [optitrackSDK].[CustomEventsRawData_Visitor]
	) u
	WHERE u.ActionId > @lastAggregatedActionId


	IF OBJECT_ID('tempdb..#PivotedRecentCustomEventData') IS NOT NULL DROP TABLE #PivotedRecentCustomEventData
	SELECT EventDateTime, EventId, ParameterName, ParameterValue
	INTO #PivotedRecentCustomEventData
	FROM #RecentCustomEventData
	UNPIVOT
	(
	  ParameterValue
	  for ParameterName IN ([Parameter1], [Parameter2],	[Parameter3], [Parameter4], [Parameter5], [Parameter6],
							[Parameter7], [Parameter8],	[Parameter9], [Parameter10], [Parameter11], [Parameter12],
							[Parameter13], [Parameter14], [Parameter15], [Parameter16], [Parameter17], [Parameter18],
							[Parameter19], [Parameter20], [Parameter21], [Parameter22], [Parameter23])
	) UNPIV


	IF OBJECT_ID('tempdb..#CompleteRecentCustomEventData') IS NOT NULL DROP TABLE #CompleteRecentCustomEventData
	SELECT
		eventParamsMetaData.EventId,
		eventParamsMetaData.Id AS ParamId,
		pivotedCustomEventsRawData.ParameterValue AS ParamValue,
		EventDateTime,
		eventParamsMetaData.[Type]
	INTO #CompleteRecentCustomEventData
	FROM [rt].[EventParamsMetaData] eventParamsMetaData
	JOIN #PivotedRecentCustomEventData pivotedCustomEventsRawData ON pivotedCustomEventsRawData.EventId = eventParamsMetaData.EventId
																AND eventParamsMetaData.OptiTrackParametersId = pivotedCustomEventsRawData.ParameterName



	-- update CustomEventsParametersValues table
	--------------------------------------------

	MERGE [optitrackSDK].[CustomEventsParametersValues] AS MergeTarget
	USING (SELECT DISTINCT EventId, ParamId, ParamValue FROM #CompleteRecentCustomEventData) AS MergeSource
	ON (MergeSource.EventId = MergeTarget.EventId AND MergeSource.ParamId = MergeTarget.ParamId)
	WHEN NOT MATCHED THEN 
		INSERT (EventId, ParamId, ParamValue)
		VALUES (EventId, ParamId, ParamValue);



	-- update CustomEventsParametersUpdateStatus table
	--------------------------------------------

	DECLARE @maxValuesForUploadSupport INT = 1000

	;WITH AggregatedRecentCustomEventData AS (
			SELECT 
				EventId, 
				ParamId,
				ParameterType = MAX([Type]),
				NumberofValues = COUNT(ParamValue),
				LastUpdateDate = MAX(EventDateTime),
				supportUpload = CASE MAX([Type]) WHEN 2 THEN 1 ELSE 
					CASE WHEN COUNT(ParamValue) > @maxValuesForUploadSupport THEN 1 ELSE 0 END
				END
		FROM #CompleteRecentCustomEventData
		GROUP BY EventId, ParamId
	)

	MERGE [optitrackSDK].[CustomEventsParametersUpdateStatus] AS MergeTarget
	USING AggregatedRecentCustomEventData AS MergeSource
	ON (MergeSource.EventId = MergeTarget.EventId AND MergeSource.ParamId = MergeTarget.ParamId)
	WHEN MATCHED THEN
		UPDATE SET	MergeTarget.NumberOfValues += MergeSource.NumberOfValues, 
					MergeTarget.LastUpdateDate = MergeSource.LastUpdateDate,
					MergeTarget.SupportUpload = CASE MergeTarget.ParameterType
						WHEN 2 THEN 1 
						ELSE 
							CASE WHEN (MergeTarget.NumberOfValues + MergeSource.NumberOfValues) > @maxValuesForUploadSupport THEN 1 ELSE 0 END
						END
	WHEN NOT MATCHED THEN 
		INSERT (EventId, ParamId, ParameterType, NumberOfValues, LastUpdateDate, SupportUpload)
		VALUES (MergeSource.EventId, 
				MergeSource.ParamId, 
				MergeSource.ParameterType, 
				MergeSource.NumberofValues, 
				MergeSource.LastUpdateDate, 
				MergeSource.supportUpload
		);

END


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('optitrackSDK.USP_FillVisitorsConversionAndMappingTalbels') IS NOT NULL DROP PROCEDURE [OptitrackSDK].[USP_FillVisitorsConversionAndMappingTalbels] ;
GO

CREATE PROCEDURE [optitrackSDK].[USP_FillVisitorsConversionAndMappingTalbels] 

	-- Add the parameters for the stored procedure here
	@profileServerName nvarchar(50)= '',
    @profileDBName nvarchar(50) = '',
	@lookupTableName nvarchar(100) = '',
	@isHashingTableNotExists int

AS
BEGIN
	
	SET NOCOUNT ON;

	DECLARE 
	@sql nvarchar(max) = '',
	@FullTargetPath nvarchar(max) = '',
	@lookupTableNameTargetPath nvarchar(max) = ''

	SET @FullTargetPath = '[' + @profileDBName + ']' + '.';
	IF(LEN(@profileServerName) >= 1)
	BEGIN
              SET @FullTargetPath = '[' + @profileServerName + ']' + '.' + '[' + @profileDBName + ']' + '.' ;
	END


	IF(LEN(@lookupTableName) >= 1)
	BEGIN
	SET @lookupTableNameTargetPath = @FullTargetPath + '[dbo].' +  @lookupTableName; 
	END



	IF(@isHashingTableNotExists = 0)
		BEGIN
			
			INSERT INTO [optitrackSDK].[VisitorsConversion]
			SELECT [CLIENT_CUSTOMER_ID], -1 AS [Customer_ID],[VisitId],[VisitorId],[OriginalVisitorID],[Platform],[ConversionDate]
			FROM (
				SELECT CBR.[CustomerId] AS [CLIENT_CUSTOMER_ID], CBR.[OriginalVisitorID], 
						VA.[VisitId], VA.[custom_dimension_5] AS [VisitorId], 
						PV.[Platform], VA.[EventActionTime] AS [ConversionDate]
				FROM (
						[optitrackSDK].[CustomersBeforeRegister_TMP] CBR
						JOIN
						[optitrackSDK].[PiwikVisitAction] VA
						ON
						VA.[custom_dimension_3] = CBR.[OriginalVisitorID]
						JOIN
						[optitrackSDK].[PiwikVisit] PV
						ON 
						PV.[Id] = VA.[VisitId]
				) 
			) A
			WHERE CLIENT_CUSTOMER_ID NOT IN (
			SELECT DISTINCT [UserId] FROM
				[optitrackSDK].[PiwikVisit] PV
				WHERE PV.[VisitFirstActionTime] < (SELECT [ConversionDate] FROM [optitrackSDK].[OptitrackVersion] WHERE [Version] = '1.9.0')
			)
			-- this condition is to prevent insertion of the same customer with -1 id
			AND A.[VisitorId] NOT IN (SELECT [VisitorId] FROM [optitrackSDK].[VisitorsConversion])
			

			SET @sql = 'INSERT INTO [optitrackSDK].[VisitorsMapping]
				SELECT CBR.[CustomerId] AS [CLIENT_CUSTOMER_ID], CBR.[OriginalVisitorID] AS [VisitorId],
						-1 AS [Customer_ID], 1 AS [Type]
				FROM
				[optitrackSDK].[CustomersBeforeRegister_TMP] CBR
				WHERE CBR.[OriginalVisitorID] NOT IN (SELECT [VisitorId] FROM [optitrackSDK].[VisitorsMapping])
				AND CBR.[CustomerId] NOT IN (SELECT [PublicCustomerId] FROM [profile_visitors].[dbo].[CustomersforOptitrack])
				AND NOT EXISTS (SELECT [CustomerID] FROM ' + @lookupTableNameTargetPath + ' WHERE [PublicCustomerId] = CBR.[CustomerId]) 
			UNION
			-- insert the final visitorId after the conversion
				SELECT CBR.[CustomerId] AS [CLIENT_CUSTOMER_ID], OA.[VisitorId] AS [VisitorId],
					   -1 AS [Customer_ID], 1 AS [Type]
				FROM
				[optitrackSDK].[CustomersBeforeRegister_TMP] CBR
				JOIN
				[optitrackSDK].[OptimoveAlias_HashedCustomers] OA
				ON
				OA.[CustomerId] = CBR.[CustomerId]
				WHERE OA.[VisitorId] NOT IN (SELECT [VisitorId] FROM [optitrackSDK].[VisitorsMapping])
			UNION
			-- insert visitorIds that made log-in after we detect conversion of the user in the past
				SELECT H.[CustomerId] AS [CLIENT_CUSTOMER_ID], CBR.[OriginalVisitorID] AS [VisitorId],
				   OC.[Customer_ID] AS [Customer_ID], 1 AS [Type]
				FROM
				[optitrackSDK].[CustomersBeforeRegister_TMP] CBR
				JOIN
				' + @lookupTableNameTargetPath + ' H
				ON
				CBR.[CustomerId] = H.[PublicCustomerId]
				JOIN
				[dbo].[OptimoveCustomerIds] OC
				ON 
				H.[CustomerId] = OC.[CLIENT_CUSTOMER_ID]
				JOIN [vis].[VisitorOptimoveIds] V
				ON V.[VISITOR_ID] = CBR.[OriginalVisitorID]
				WHERE CBR.[OriginalVisitorID] NOT IN (SELECT [VisitorId] FROM [optitrackSDK].[VisitorsMapping])
			UNION
			-- insert visitorIds that made log-in after we detect conversion of the user in the past but the original vusutir id did not apeared in the [vis].[VisitorOptimoveIds] table
			SELECT H.[CustomerID] AS [CLIENT_CUSTOMER_ID], CBR.[OriginalVisitorID] AS [VisitorId], OC.[Customer_ID], 1 AS [Type]
			FROM ' + @lookupTableNameTargetPath + ' H
			JOIN
			[optitrackSDK].[CustomersBeforeRegister_TMP] CBR
			ON
			CBR.[CustomerId] = H.[PublicCustomerId]
			JOIN
			[dbo].[OptimoveCustomerIds] OC
			ON
			OC.[CLIENT_CUSTOMER_ID] = H.[CustomerID]
			WHERE CBR.[OriginalVisitorID] NOT IN (SELECT [VisitorId] FROM [optitrackSDK].[VisitorsMapping])'

			EXEC(@sql)

		END
	ELSE 
		BEGIN
			INSERT INTO [optitrackSDK].[VisitorsConversion]
			SELECT [CLIENT_CUSTOMER_ID],[Customer_ID],[VisitId],[VisitorId],[OriginalVisitorID],[Platform],[ConversionDate]
			FROM (
				SELECT CBR.[CustomerId] AS [CLIENT_CUSTOMER_ID], CBR.[OriginalVisitorID], 
						OC.[Customer_ID], VA.[VisitId], VA.[custom_dimension_5] AS [VisitorId], 
						PV.[Platform], VA.[EventActionTime] AS [ConversionDate]
				FROM (
						[optitrackSDK].[CustomersBeforeRegister_TMP] CBR
						JOIN
						[dbo].[OptimoveCustomerIds] OC
						ON
						CBR.[CustomerId] = OC.[CLIENT_CUSTOMER_ID]
						JOIN
						[optitrackSDK].[PiwikVisitAction] VA
						ON
						VA.[custom_dimension_3] = CBR.[OriginalVisitorID]
						JOIN
						[optitrackSDK].[PiwikVisit] PV
						ON 
						PV.[Id] = VA.[VisitId]
				) 
			) A
			WHERE CLIENT_CUSTOMER_ID NOT IN (
			SELECT DISTINCT [UserId] FROM
			[optitrackSDK].[PiwikVisit] PV
			JOIN 
			[optitrackSDK].[AlreadyRegisteredVisitorsAsCustomers] AR
			ON 
			PV.[UserId] = AR.[CLIENT_CUSTOMER_ID]
			AND PV.[VisitFirstActionTime] < (SELECT [ConversionDate] FROM [optitrackSDK].[OptitrackVersion] WHERE [Version] = '1.9.0')
			)
		
			INSERT INTO [optitrackSDK].[VisitorsMapping]
			-- insert the original visitorId before the conversion
				SELECT CBR.[CustomerId] AS [CLIENT_CUSTOMER_ID], CBR.[OriginalVisitorID] AS [VisitorId],
				   OC.[Customer_ID] AS [Customer_ID], 1 AS [Type]
				FROM
				[optitrackSDK].[CustomersBeforeRegister_TMP] CBR
				JOIN
				[dbo].[OptimoveCustomerIds] OC
				ON 
				CBR.[CustomerId] = OC.[CLIENT_CUSTOMER_ID]
				WHERE CBR.[OriginalVisitorID] NOT IN (SELECT [VisitorId] FROM [optitrackSDK].[VisitorsMapping])
			UNION
			-- insert the final visitorId after the conversion
				SELECT CBR.[CustomerId] AS [CLIENT_CUSTOMER_ID], OA.[VisitorId] AS [VisitorId],
					   OC.[Customer_ID] AS [Customer_ID], 1 AS [Type]
				FROM
				[optitrackSDK].[CustomersBeforeRegister_TMP] CBR
				JOIN
				[dbo].[OptimoveCustomerIds] OC
				ON 
				CBR.[CustomerId] = OC.[CLIENT_CUSTOMER_ID]
				JOIN
				[optitrackSDK].[OptimoveAlias] OA
				ON
				OA.[CustomerId] = OC.[CLIENT_CUSTOMER_ID]
				WHERE OA.[VisitorId] NOT IN (SELECT [VisitorId] FROM [optitrackSDK].[VisitorsMapping])
			UNION
			-- insert visitorIds that made log-in after we detect conversion of the user in the past
				SELECT CBR.[CustomerId] AS [CLIENT_CUSTOMER_ID], CBR.[OriginalVisitorID] AS [VisitorId],
				   OC.[Customer_ID] AS [Customer_ID], 1 AS [Type]
				FROM
				[optitrackSDK].[CustomersBeforeRegister_TMP] CBR
				JOIN
				[dbo].[OptimoveCustomerIds] OC
				ON 
				CBR.[CustomerId] = OC.[CLIENT_CUSTOMER_ID]
				JOIN [vis].[VisitorOptimoveIds] V
				ON V.[VISITOR_ID] = CBR.[OriginalVisitorID]
				WHERE CBR.[OriginalVisitorID] NOT IN (SELECT [VisitorId] FROM [optitrackSDK].[VisitorsMapping])
		

			-- clean the [vis].[VisitorOptimoveIds] from visitorIds that made conversion
			DELETE FROM [vis].[VisitorOptimoveIds]  
			WHERE [VISITOR_ID] IN (SELECT [VisitorId] FROM [optitrackSDK].[VisitorsMapping])
		
		END 


	-- TRUNCATE THE TEMP TABLE
	DELETE FROM [optitrackSDK].[CustomersBeforeRegister_TMP]
	
	-- delete profiles of visitor who made a conversion
	DELETE FROM [vis].[VisitorProfileDaily] 
	WHERE CUSTOMER_ID IN (SELECT [Customer_ID] FROM [optitrackSDK].[VisitorsMapping])
	AND CUSTOMER_ID NOT IN (SELECT [CUSTOMER_ID] FROM [vis].[VisitorOptimoveIds])
	
END





SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('optitrackSDK.USP_FillVisitorsMappingWithAlreadyRegisteredVisitorsAsCustomers') IS NOT NULL DROP PROCEDURE [OptitrackSDK].[USP_FillVisitorsMappingWithAlreadyRegisteredVisitorsAsCustomers] ;
GO

CREATE PROCEDURE [optitrackSDK].[USP_FillVisitorsMappingWithAlreadyRegisteredVisitorsAsCustomers]


AS
BEGIN
	

	INSERT INTO [optitrackSDK].[VisitorsConversion]
	SELECT [CLIENT_CUSTOMER_ID],[Customer_ID],[VisitId],[VisitorId],[OriginalVisitorID],[Platform],[ConversionDate]
	FROM (
		SELECT AR.[CLIENT_CUSTOMER_ID], AR.[Optimove_Customer_ID] AS [Customer_ID], PV.[Id] AS [VisitId], PA.[custom_dimension_5] AS [VisitorId], AR.[VISITOR_ID] AS [OriginalVisitorID], 
		PV.[Platform], PA.[EventActionTime] AS [ConversionDate]
		FROM (
				[optitrackSDK].[AlreadyRegisteredVisitorsAsCustomers] AR
				JOIN
				[optitrackSDK].[PiwikVisitAction] PA
				ON 
				AR.[VISITOR_ID] = PA.[custom_dimension_3]
				JOIN
				[optitrackSDK].[PiwikVisit] PV
				ON
				PA.[VisitId] = PV.[Id]
		)  
	) A
	WHERE CLIENT_CUSTOMER_ID NOT IN (
		SELECT DISTINCT [UserId] FROM
		[optitrackSDK].[PiwikVisit] PV
		JOIN 
		[optitrackSDK].[AlreadyRegisteredVisitorsAsCustomers] AR
		ON 
		PV.[UserId] = AR.[CLIENT_CUSTOMER_ID]
		AND PV.[VisitFirstActionTime] < (SELECT [ConversionDate] FROM [optitrackSDK].[OptitrackVersion] WHERE [Version] = '1.9.0')
	)


	INSERT INTO [optitrackSDK].[VisitorsMapping]
	SELECT [CLIENT_CUSTOMER_ID], [VisitorId], [Customer_ID], [Type] 
	FROM (
		SELECT AR.[CLIENT_CUSTOMER_ID], OA.[VisitorId], AR.[Optimove_Customer_ID] AS [Customer_ID], 1 AS [Type]
		FROM 
			[optitrackSDK].[AlreadyRegisteredVisitorsAsCustomers] AR
			JOIN
			[optitrackSDK].[OptimoveAlias] OA
			ON AR.[CLIENT_CUSTOMER_ID] = OA.[CustomerId]
		UNION
			SELECT AR.[CLIENT_CUSTOMER_ID], AR.[VISITOR_ID] AS [VisitorId], AR.[Optimove_VISITOR_ID] AS [Customer_ID], 1 AS [Type]
			FROM [optitrackSDK].[AlreadyRegisteredVisitorsAsCustomers] AR
	) A
	WHERE [VisitorId] NOT IN (SELECT [VisitorId] FROM [optitrackSDK].[VisitorsMapping])
	
	DELETE FROM [vis].[VisitorOptimoveIds]
	WHERE [CUSTOMER_ID]
	IN (SELECT [Optimove_VISITOR_ID] FROM [optitrackSDK].[AlreadyRegisteredVisitorsAsCustomers])
	AND [CUSTOMER_ID]
	IN (SELECT [Customer_ID] FROM [optitrackSDK].[VisitorsMapping])
	
	-- We delete the customers to prevent insert them twice to the conversion table in the next optitrack step
	DELETE FROM [optitrackSDK].[CustomersBeforeRegister_TMP] 
	WHERE [CustomerId] IN (SELECT [CLIENT_CUSTOMER_ID] FROM [optitrackSDK].[AlreadyRegisteredVisitorsAsCustomers])

	-- delete profiles of visitor who made a conversion
	DELETE FROM [vis].[VisitorProfileDaily] 
	WHERE CUSTOMER_ID IN (SELECT [Customer_ID] FROM [optitrackSDK].[VisitorsMapping])
	AND CUSTOMER_ID NOT IN (SELECT [CUSTOMER_ID] FROM [vis].[VisitorOptimoveIds])

	DELETE FROM [optitrackSDK].[AlreadyRegisteredVisitorsAsCustomers]
	
END



SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('optitrackSDK.USP_FindNewCustomersSinceLastETL') IS NOT NULL DROP PROCEDURE [OptitrackSDK].[USP_FindNewCustomersSinceLastETL] ;
GO

CREATE PROCEDURE [optitrackSDK].[USP_FindNewCustomersSinceLastETL] 

AS
BEGIN
	
	INSERT INTO [optitrackSDK].[CustomersBeforeRegister_TMP]
	SELECT * FROM (
		SELECT DISTINCT custom_dimension_4 AS [CustomerId], custom_dimension_3 AS [OriginalVisitorID] 
		FROM [optitrackSDK].[PiwikVisitAction]
		WHERE custom_dimension_2 = 'set_user_id_event'
	) SUB
	
END



SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('optitrackSDK.USP_GetMinMaxSplittedVisitIds') IS NOT NULL DROP PROCEDURE [OptitrackSDK].[USP_GetMinMaxSplittedVisitIds] ;
GO


CREATE PROCEDURE  [optitrackSDK].[USP_GetMinMaxSplittedVisitIds]
       -- Add the parameters for the stored procedure here
              @isMax bit

with recompile
AS 
BEGIN
    set xact_abort on;
       SET NOCOUNT OFF;
 
	IF(@isMax <= 0)
		BEGIN
			IF EXISTS (SELECT TOP 1 * FROM [optitrackSDK].[SplittedVisitIds_TEMP])
				SELECT MIN([VisitId]) FROM  [optitrackSDK].[SplittedVisitIds_TEMP]
			ELSE 
				SELECT 0		
		END
	ELSE
		BEGIN
			IF EXISTS (SELECT TOP 1 * FROM [optitrackSDK].[SplittedVisitIds_TEMP])
				SELECT MAX([VisitId]) FROM  [optitrackSDK].[SplittedVisitIds_TEMP]
			ELSE 
				SELECT 0		
	END
END



SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('optitrackSDK.USP_GetNext100000SplittedVisitIDs') IS NOT NULL DROP PROCEDURE [OptitrackSDK].[USP_GetNext100000SplittedVisitIDs] ;
GO


CREATE PROCEDURE [optitrackSDK].[USP_GetNext100000SplittedVisitIDs]

	@LastCopiedId BIGINT

AS
BEGIN

	SET NOCOUNT ON;
	
	DECLARE @SQL NVARCHAR(MAX) = ''

	SET @SQL = '
		SELECT TOP 100000 * FROM [optitrackSDK].[SplittedVisitIds_TEMP]
		                                        WHERE VisitId >= ' + CAST(@LastCopiedId as nvarchar(21)) +'
		                                        ORDER BY VisitId ASC
	'
	
	EXEC(@SQL)

END


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('optitrackSDK.USP_GetPiwikIdentityData') IS NOT NULL DROP PROCEDURE [OptitrackSDK].[USP_GetPiwikIdentityData] ;
GO


CREATE PROCEDURE [optitrackSDK].[USP_GetPiwikIdentityData]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	SELECT * FROM [optitrackSDK].[PiwikIdentity]
			
END


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('optitrackSDK.USP_GetPublicCustomerIds') IS NOT NULL DROP PROCEDURE [OptitrackSDK].[USP_GetPublicCustomerIds] ;
GO

CREATE PROCEDURE [optitrackSDK].[USP_GetPublicCustomerIds] 
	@isHashingTableNotExists int
AS
BEGIN
	
	SET NOCOUNT ON

	IF(@isHashingTableNotExists = 0)
		BEGIN
			INSERT INTO [optitrackSDK].[OptimoveAlias_HashedCustomers]
			SELECT DISTINCT P.[VisitorId],P.[UserId],@isHashingTableNotExists
			FROM   [optitrackSDK].[PiwikVisit] P LEFT JOIN [optitrackSDK].[OptimoveAlias_HashedCustomers]  OA ON P.[UserId] = OA.[CustomerId]
			LEFT JOIN [optitrackSDK].[OptimoveAlias_HashedCustomers] OAV ON P.[VisitorId] = OAV.[VisitorId]
			WHERE  P.[UserId] IS NOT NULL AND P.[Id] >= (SELECT MIN(VisitId) FROM [optitrackSDK].[PiwikVisitAction]) AND ( OA.[CustomerId] IS NULL OR OAV.[VisitorId] IS NULL )
		END
	ELSE
		BEGIN
			INSERT INTO [optitrackSDK].[OptimoveAlias]
			SELECT DISTINCT P.[VisitorId],P.[UserId],@isHashingTableNotExists
			FROM   [optitrackSDK].[PiwikVisit] P LEFT JOIN [optitrackSDK].[OptimoveAlias]  OA ON P.[UserId] = OA.[CustomerId]
			LEFT JOIN [optitrackSDK].[OptimoveAlias] OAV ON P.[VisitorId] = OAV.[VisitorId]
			WHERE  P.[UserId] IS NOT NULL AND P.[Id] >= (SELECT MIN(VisitId) FROM [optitrackSDK].[PiwikVisitAction]) AND ( OA.[CustomerId] IS NULL OR OAV.[VisitorId] IS NULL )
		END


END




SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('optitrackSDK.USP_MigrateVisitAvgTimeToSDKSchema') IS NOT NULL DROP PROCEDURE [OptitrackSDK].[USP_MigrateVisitAvgTimeToSDKSchema] ;
GO
CREATE PROCEDURE [OptitrackSDK].[USP_MigrateVisitAvgTimeToSDKSchema]
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	MERGE [optitrackSDK].[CustomerVisitAvgTime] CVAT
	USING [optitrack].[CustomerSessionsAvgTime] CSAT
	ON CVAT.CustomerID = CSAT.CustomerID
	WHEN MATCHED AND CSAT.LastComputedSessionID > CVAT.LastComputedSessionID
	THEN UPDATE SET CustomerAvgTime = CSAT.CustomerAvgTime, NumberOfSessions = CSAT.NumberOfSessions, LastComputedSessionID = CSAT.LastComputedSessionID, ActiveSessionDays = CSAT.ActiveSessionDays
	WHEN NOT MATCHED BY TARGET THEN INSERT (CustomerID, CustomerAvgTime,  NumberOfSessions, LastComputedSessionID, ActiveSessionDays) 
	VALUES(CSAT.CustomerID, CSAT.CustomerAvgTime,  CSAT.NumberOfSessions, CSAT.LastComputedSessionID, CSAT.ActiveSessionDays);

	MERGE [optitrackSDK].[CustomerVisitAvgTime_Visitor] CVATV
	USING [optitrack].[CustomerSessionsAvgTime_UniqueVisitors] CSATV
	ON CVATV.CustomerID = CSATV.CustomerID
	WHEN MATCHED AND CSATV.LastComputedSessionID > CVATV.LastComputedSessionID
	THEN UPDATE SET CustomerAvgTime = CSATV.CustomerAvgTime, NumberOfSessions = CSATV.NumberOfSessions, LastComputedSessionID = CSATV.LastComputedSessionID, ActiveSessionDays = CSATV.ActiveSessionDays
	WHEN NOT MATCHED BY TARGET THEN INSERT (CustomerID, CustomerAvgTime,  NumberOfSessions, LastComputedSessionID, ActiveSessionDays) 
	VALUES(CSATV.CustomerID, CSATV.CustomerAvgTime,  CSATV.NumberOfSessions, CSATV.LastComputedSessionID, CSATV.ActiveSessionDays);

END
GO



SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('optitrackSDK.USP_MigrateVisitUTMData') IS NOT NULL DROP PROCEDURE [OptitrackSDK].[USP_MigrateVisitUTMData] ;
GO
CREATE PROCEDURE [optitrackSDK].[USP_MigrateVisitUTMData]

AS
BEGIN
	

	MERGE [optitrackSDK].[T_Configuration] CNFT
	USING [optitrack].[T_Configuration] CNFS
	ON CNFT.ConfigurationName = CNFS.ConfigurationName 
	WHEN MATCHED  AND CNFT.ConfigurationValue <> CNFS.ConfigurationValue
	THEN UPDATE SET ConfigurationValue = CNFS.ConfigurationValue
	WHEN NOT MATCHED BY TARGET THEN INSERT (ConfigurationName, ConfigurationValue) 
	VALUES(CNFS.ConfigurationName, CNFS.ConfigurationValue);
	

	MERGE [optitrackSDK].[T_TempSessionUsers] TSUT
	USING [optitrack].[T_TempSessionUsers] TSUS
	ON TSUT.UserId = TSUS.UserId 
	WHEN MATCHED  AND TSUT.VisitorId = TSUS.VisitorId AND TSUT.VisitFirstActionTime <> TSUS.VisitFirstActionTime
	THEN UPDATE SET VisitFirstActionTime = TSUS.VisitFirstActionTime
	WHEN NOT MATCHED BY TARGET THEN INSERT (UserId, VisitorId, VisitFirstActionTime) 
	VALUES(TSUS.UserId,  TSUS.VisitorId, TSUS.VisitFirstActionTime);

	
	MERGE [optitrackSDK].[T_VisitorSessionFirstTouch] VSFTT
	USING [optitrack].[T_VisitorSessionFirstTouch] VSFTS
	ON VSFTT.Id = VSFTS.Id 
	WHEN MATCHED AND VSFTT.UserId = VSFTS.UserId AND VSFTT.VisitFirstActionTime <> VSFTS.VisitFirstActionTime
	THEN UPDATE SET VisitorId = VSFTS.VisitorId, VisitFirstActionTime = VSFTS.VisitFirstActionTime, utm_campaign = VSFTS.utm_campaign, utm_term = VSFTS.utm_term, utm_source = VSFTS.utm_source, utm_medium = VSFTS.utm_medium
	WHEN NOT MATCHED BY TARGET THEN INSERT (Id, UserId, VisitorId, VisitFirstActionTime, utm_campaign, utm_term, utm_source, utm_medium) 
	VALUES (VSFTS.Id, VSFTS.UserId, VSFTS.VisitorId, VSFTS.VisitFirstActionTime, VSFTS.utm_campaign, VSFTS.utm_term, VSFTS.utm_source, VSFTS.utm_medium);
		
	
	MERGE [optitrackSDK].[T_VisitorSessionLastTouch] VSLTT
	USING [optitrack].[T_VisitorSessionLastTouch] VSLTS
	ON VSLTT.Id = VSLTS.Id 
	WHEN MATCHED AND VSLTT.UserId = VSLTS.UserId AND VSLTT.VisitFirstActionTime <> VSLTS.VisitFirstActionTime
	THEN UPDATE SET VisitorId = VSLTS.VisitorId, VisitFirstActionTime = VSLTS.VisitFirstActionTime, utm_campaign = VSLTS.utm_campaign, utm_term = VSLTS.utm_term, utm_source = VSLTS.utm_source, utm_medium = VSLTS.utm_medium
	WHEN NOT MATCHED BY TARGET THEN INSERT (Id, UserId, VisitorId, VisitFirstActionTime, utm_campaign, utm_term, utm_source, utm_medium) 
	VALUES (VSLTS.Id, VSLTS.UserId, VSLTS.VisitorId, VSLTS.VisitFirstActionTime, VSLTS.utm_campaign, VSLTS.utm_term, VSLTS.utm_source, VSLTS.utm_medium);
RETURN 0
END


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('optitrackSDK.USP_PopulateLanguage') IS NOT NULL DROP PROCEDURE [OptitrackSDK].[USP_PopulateLanguage] ;
GO

CREATE PROCEDURE [optitrackSDK].[USP_PopulateLanguage]
AS
BEGIN

	DECLARE @MIN_ID_VISIT BIGINT
	
	SET @MIN_ID_VISIT = (SELECT MIN([VisitId]) FROM [optitrackSDK].[PiwikVisitAction])

	INSERT INTO [optitrackSDK].[Language]
	SELECT DISTINCT [Language] FROM [optitrackSDK].[PiwikVisit] PV
	WHERE PV.ID >= @MIN_ID_VISIT 
	AND [Language] NOT IN (SELECT [Language] FROM [optitrackSDK].[Language])

END

	


	SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('OptitrackSDK.USP_PopulateLocationCity') IS NOT NULL DROP PROCEDURE [OptitrackSDK].[USP_PopulateLocationCity];
GO

CREATE PROCEDURE [optitrackSDK].[USP_PopulateLocationCity]
AS
BEGIN

	DECLARE @MIN_ID_VISIT BIGINT
	
	SET @MIN_ID_VISIT = (SELECT MIN([VisitId]) FROM [optitrackSDK].[PiwikVisitAction])

	INSERT INTO [optitrackSDK].[LocationCity]
	SELECT DISTINCT [GEO_Location] FROM [optitrackSDK].[PiwikVisit] PV
	WHERE PV.ID >= @MIN_ID_VISIT
	AND [GEO_Location] NOT IN (SELECT [LocationCity] FROM [optitrackSDK].[LocationCity])
	AND [GEO_Location] <> ''

END

	


	SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('OptitrackSDK.USP_PopulatePageCategories') IS NOT NULL DROP PROCEDURE [OptitrackSDK].[USP_PopulatePageCategories];
GO

CREATE PROCEDURE [OptitrackSDK].[USP_PopulatePageCategories]

AS
BEGIN
	INSERT INTO [OptitrackSDK].[PagesCategories]
	SELECT LOWER(LTRIM(RTRIM(custom_dimension_3))),  HASHBYTES('SHA1', LOWER(LTRIM(RTRIM(custom_dimension_3)))) FROM  [optitrackSDK].[PiwikVisitAction] 
	WHERE custom_dimension_1 = 1003 and custom_dimension_2 = 'page_category_event'

	select @@ROWCOUNT


END




SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF [dbo].[udf_IsObjectExists]('[optitrackSDK].[USP_PopulatePagesCategoriesEventsRawData]','SP') = 1 DROP PROCEDURE [optitrack].[USP_PopulatePagesCategoriesEventsRawData]
GO


CREATE PROCEDURE [optitrackSDK].[USP_PopulatePagesCategoriesEventsRawData]

AS
BEGIN
     INSERT INTO [optitrackSDK].[PagesCategoriesEventsRawData]
     SELECT DISTINCT pva.EventActionTime , pva.id  , pva.VisitId , oci.Customer_ID, pc.Id FROM [optitrackSDK].[PiwikVisitAction] AS pva 
     JOIN [optitrackSDK].[PiwikVisit] AS pv ON pva.VisitId = pv.Id 
     JOIN [OptitrackSDK].[PagesCategories] AS pc  ON pva.custom_dimension_3 = pc.pagecategory
     JOIN [optitrackSDK].[OptimoveAlias] AS oa ON pv.VisitorId = oa.VisitorId 
     JOIN dbo.OptimoveCustomerIds AS oci ON oa.CustomerId = oci.CLIENT_CUSTOMER_ID
     WHERE custom_dimension_1 = 1003 and custom_dimension_2 = 'page_category_event'

END



SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('optitrackSDK.USP_PopulatePlatform') IS NOT NULL DROP PROCEDURE [OptitrackSDK].[USP_PopulatePlatform] ;
GO


CREATE PROCEDURE [optitrackSDK].[USP_PopulatePlatform]
AS
BEGIN

	DECLARE @MIN_ID_VISIT BIGINT
	
	SET @MIN_ID_VISIT = (SELECT MIN([VisitId]) FROM [optitrackSDK].[PiwikVisitAction])

	INSERT INTO [optitrackSDK].[Platform]
	SELECT DISTINCT [Platform] FROM [optitrackSDK].[PiwikVisit] PV
	WHERE PV.ID >= @MIN_ID_VISIT 
	AND [Platform] NOT IN (SELECT [Platform] FROM [optitrackSDK].[Platform])

END



SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('OptitrackSDK.USP_PopulateTotalDailyPagesCategoriesAggregation') IS NOT NULL DROP PROCEDURE [OptitrackSDK].[USP_PopulateTotalDailyPagesCategoriesAggregation];
GO

CREATE PROCEDURE [OptitrackSDK].[USP_PopulateTotalDailyPagesCategoriesAggregation]

AS
BEGIN
	MERGE [optitrackSDK].[TotalDailyPagesCategoriesAggregation] AS NEW_TDPCA
	USING (	SELECT CONVERT(date, DATEADD(DAY,0, DATEDIFF(DAY,0, ActionTime))) AS DATE,MAX(ActionId) AS LastComputedActionId ,CustomerId,PageCategoryID,Count(PageCategoryID) AS NumOfPageVisits
			FROM [optitrackSDK].[PagesCategoriesEventsRawData] AS PCERD
			GROUP BY CONVERT(date, DATEADD(DAY,0, DATEDIFF(DAY,0, ActionTime))),CustomerId,PageCategoryID) AS OLD_TDPCA
	ON NEW_TDPCA.DATE = OLD_TDPCA.DATE AND NEW_TDPCA.CustomerId = OLD_TDPCA.CustomerId AND NEW_TDPCA.PageCategoryID = OLD_TDPCA.PageCategoryID
	WHEN MATCHED THEN
		UPDATE 
		SET  NumOfPageVisits = OLD_TDPCA.NumOfPageVisits,
			 LastComputedActionId = OLD_TDPCA.LastComputedActionId
	WHEN NOT MATCHED THEN                                 
		INSERT                                  
		VALUES (OLD_TDPCA.DATE, OLD_TDPCA.LastComputedActionId ,OLD_TDPCA.CustomerId,OLD_TDPCA.PageCategoryID ,OLD_TDPCA.NumOfPageVisits);  
	

	SELECT @@ROWCOUNT
END




SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('optitrackSDK.USP_RegisterNewCustomersFromOptitrack') IS NOT NULL DROP PROCEDURE [OptitrackSDK].[USP_RegisterNewCustomersFromOptitrack] ;
GO


CREATE PROCEDURE [optitrackSDK].[USP_RegisterNewCustomersFromOptitrack] 

	@isHashingTableNotExists int

AS
BEGIN
	
	SET NOCOUNT ON
	
	IF(@isHashingTableNotExists = 0)
		BEGIN 
			PRINT(1)
		END
	ELSE
		BEGIN
			-- check if we know the customers as visitor and if so save their optimove id
			;WITH CTE AS (	
			SELECT [CustomerId] AS CLIENT_CUSTOMER_ID, [OriginalVisitorID] AS Visitor_ID
			FROM [optitrackSDK].[CustomersBeforeRegister_TMP]
			)


			INSERT OptimoveCustomerIds (CLIENT_CUSTOMER_ID,Customer_ID)
			SELECT CLIENT_CUSTOMER_ID, Customer_ID FROM (
			DELETE [vis].[VisitorOptimoveIds] 
			OUTPUT DELETED.Customer_ID, CTE.CLIENT_CUSTOMER_ID
			FROM [vis].[VisitorOptimoveIds] INNER JOIN CTE ON CTE.Visitor_ID = VisitorOptimoveIds.VISITOR_ID
			) SUB

			-- register the new customers that we don't know as visitors
			EXEC [exp].[USP_CVM_RegisterNewIds] '[optitrackSDK].[CustomersBeforeRegister_TMP]','CustomerId';		
		END
	
END



SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('optitrackSDK.USP_RegisterNewUniqueVisitorsIds') IS NOT NULL DROP PROCEDURE [OptitrackSDK].[USP_RegisterNewUniqueVisitorsIds] ;
GO

CREATE PROCEDURE [optitrackSDK].[USP_RegisterNewUniqueVisitorsIds]

		@minSessionTime int = 10

		with recompile
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	

	INSERT vis.VisitorOptimoveIds(CUSTOMER_ID,VISITOR_ID)
	SELECT NEXT VALUE FOR SEQ_OptimoveCustomerIDs Customer_ID, VisitorId 
	   FROM (
				SELECT DISTINCT P.[VisitorId]
				FROM   [optitrackSDK].[PiwikVisit] P
				WHERE NOT EXISTS (SELECT 1 
								   FROM   [optitrackSDK].[OptimoveAlias] OA 
								   WHERE  OA.[VisitorId] = P.[VisitorId])
				AND
				P.[UserId] IS NULL
				AND
				P.ID > (SELECT [LastAggregatedVisitId] FROM [optitrackSDK].[Config])
				AND
				DATEDIFF(SECOND, P.VisitFirstActionTime, P.VisitLastActionTime) >= @minSessionTime
			) Q
	WHERE (
		NOT EXISTS(SELECT 1 FROM vis.VisitorOptimoveIds v WHERE v.VISITOR_ID = Q.VisitorId) 
		AND 
		NOT EXISTS (SELECT 1 FROM [optitrackSDK].[VisitorsMapping] M WHERE M.[VisitorId] = Q.VisitorId)
	)

END



SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('optitrackSDK.USP_ReplaceHashedCustomersIds') IS NOT NULL DROP PROCEDURE [OptitrackSDK].[USP_ReplaceHashedCustomersIds] ;
GO

CREATE PROCEDURE [optitrackSDK].[USP_ReplaceHashedCustomersIds]
	-- Add the parameters for the stored procedure here
	@profileServerName nvarchar(50)= '',
    @profileDBName nvarchar(50) = '',
	@lookupTableName nvarchar(100) = ''
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE 
	@sql nvarchar(max) = '',
	@FullTargetPath nvarchar(max) = '',
	@lookupTableNameTargetPath nvarchar(max) = ''


	SET @FullTargetPath = '[' + @profileDBName + ']' + '.';
	IF(LEN(@profileServerName) >= 1)
	BEGIN
              SET @FullTargetPath = '[' + @profileServerName + ']' + '.' + '[' + @profileDBName + ']' + '.' ;
	END


	IF(LEN(@lookupTableName) >= 1)
	BEGIN
	SET @lookupTableNameTargetPath = @FullTargetPath + '[dbo].' +  @lookupTableName; 
	END

	-- insert into optimoveAlias the new customers that has an hashed value 
	SET @sql = 'INSERT INTO [optitrackSDK].[OptimoveAlias] ([VisitorId],[CustomerId],[IsUnique])
				SELECT DISTINCT [VisitorId],Lkp.[CustomerId],0
				FROM [optitrackSDK].[OptimoveAlias_HashedCustomers] OAHased INNER JOIN ' + @lookupTableNameTargetPath + ' Lkp ON OAHased.[CustomerId] = LOWER(Lkp.[PublicCustomerId]) OPTION (MAXDOP 1)'
	EXEC(@sql)


	-- register the new customers with the customerId of the original visitor id
	;WITH CTE AS (	
		SELECT CLIENT_CUSTOMER_ID,Visitor_ID FROM (
			SELECT OA.[CustomerId] AS CLIENT_CUSTOMER_ID, [OriginalVisitorID] AS Visitor_ID, ROW_NUMBER() OVER(PARTITION BY [UpdatedVisitorId] ORDER BY [VisitId] ASC) AS NUMBER
			FROM [optitrackSDK].[OptimoveAlias] OA
			JOIN
			[optitrackSDK].[SetUserIdEvent] S
			ON 
			OA.[VisitorId] = S.[UpdatedVisitorId]				
		) SUB
		WHERE NUMBER = 1
	)


	INSERT OptimoveCustomerIds (CLIENT_CUSTOMER_ID,Customer_ID)
	SELECT CLIENT_CUSTOMER_ID, Customer_ID FROM (
	DELETE [vis].[VisitorOptimoveIds] 
	OUTPUT DELETED.Customer_ID, CTE.CLIENT_CUSTOMER_ID
	FROM [vis].[VisitorOptimoveIds] INNER JOIN CTE ON CTE.Visitor_ID = VisitorOptimoveIds.VISITOR_ID
	) SUB


	-- register the new customers that has an hashed value and didn't has a customerId from their original visitor id
	EXEC [exp].[USP_CVM_RegisterNewIds] '[optitrackSDK].[OptimoveAlias]','CustomerId';



	--update the conversion table with the new optimove customer id of the user

	IF OBJECT_ID(N'#TempFirst') IS NOT NULL DROP TABLE #TempFirst;

	SELECT OA.[CustomerId] AS [CLIENT_CUSTOMER_ID],OC.[Customer_ID] AS [CustomerId],[VisitId],VC.[VisitorId],[OriginalVisitorID],[Platform],[ConversionDate]
	INTO #TempFirst
	FROM  [optitrackSDK].[OptimoveAlias] OA
	JOIN
	[dbo].[OptimoveCustomerIds] OC
	ON
	OA.[CustomerId] = OC.[CLIENT_CUSTOMER_ID]
	JOIN
	[optitrackSDK].[VisitorsConversion] VC
	ON
	OA.[VisitorId] = VC.[VisitorId]
	

	UPDATE [optitrackSDK].[VisitorsConversion] 
	SET [optitrackSDK].[VisitorsConversion].[CLIENT_CUSTOMER_ID] = T.[CLIENT_CUSTOMER_ID],
		[optitrackSDK].[VisitorsConversion].[Customer_ID] = T.[CustomerId]
	FROM [optitrackSDK].[VisitorsConversion] 
	JOIN #TempFirst T
	ON [optitrackSDK].[VisitorsConversion].[VisitId] = T.[VisitId]




	--update the mapping table with the new optimove customer id of the user
	IF OBJECT_ID(N'#TempSecond') IS NOT NULL DROP TABLE #TempSecond;

	SELECT OA.[CustomerId] AS [CLIENT_CUSTOMER_ID], OC.[Customer_ID] AS [Customer_ID], OAH.[CustomerId] AS [OLD_CLIENT_CUSTOMER_ID]
	INTO #TempSecond
	FROM  [optitrackSDK].[OptimoveAlias] OA
	JOIN
	[dbo].[OptimoveCustomerIds] OC
	ON
	OA.[CustomerId] = OC.[CLIENT_CUSTOMER_ID]
	JOIN
	[optitrackSDK].[OptimoveAlias_HashedCustomers] OAH
	ON
	OA.[VisitorId] = OAH.[VisitorId]
	

	UPDATE [optitrackSDK].[VisitorsMapping]
	SET [optitrackSDK].[VisitorsMapping].[CLIENT_CUSTOMER_ID] = T.[CLIENT_CUSTOMER_ID],
		[optitrackSDK].[VisitorsMapping].[Customer_ID] = T.[Customer_ID]
	FROM [optitrackSDK].[VisitorsMapping] 
	JOIN #TempSecond T
	ON
	[optitrackSDK].[VisitorsMapping].[CLIENT_CUSTOMER_ID] = T.[OLD_CLIENT_CUSTOMER_ID]




	DELETE FROM [optitrackSDK].[OptimoveAlias_HashedCustomers] WHERE [VisitorId] IN (SELECT [VisitorId] FROM [optitrackSDK].[OptimoveAlias])

	
	UPDATE [optitrackSDK].[OptimoveAlias]
	SET [IsUnique] = 1


END




SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('optitrackSDK.USP_SeparateAndHashURLsAndPageTitle') IS NOT NULL DROP PROCEDURE [OptitrackSDK].[USP_SeparateAndHashURLsAndPageTitle] ;
GO

CREATE PROCEDURE [optitrackSDK].[USP_SeparateAndHashURLsAndPageTitle]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DELETE FROM [optitrackSDK].[URLsPageTitle_TEMP]
	WHERE ([Type] <> 1 AND [Type] <> 4) 

	
	INSERT INTO [optitrackSDK].[URL]
	SELECT [ActionId] AS [URLID], LOWER(LTRIM(RTRIM([URL]))), HASHBYTES('SHA1', LOWER(LTRIM(RTRIM([URL])))) AS [Hash]
	FROM [optitrackSDK].[URLsPageTitle_TEMP]
	WHERE [optitrackSDK].[URLsPageTitle_TEMP].[Type] = 1
	AND HASHBYTES('SHA1', LOWER(LTRIM(RTRIM([URL])))) NOT IN (SELECT [Hash] FROM [optitrackSDK].[URL])
	

	INSERT INTO [optitrackSDK].[PageTitle]
	SELECT [ActionId] AS [PageTitleID], LOWER(LTRIM(RTRIM([URL]))) AS [Title], HASHBYTES('SHA1', LOWER(LTRIM(RTRIM([URL])))) AS [Hash]
	FROM [optitrackSDK].[URLsPageTitle_TEMP]
	WHERE [optitrackSDK].[URLsPageTitle_TEMP].[Type] = 4
	AND HASHBYTES('SHA1', LOWER(LTRIM(RTRIM([URL])))) NOT IN (SELECT [Hash] FROM [optitrackSDK].[PageTitle])	
	

	DELETE FROM [optitrackSDK].[URLsPageTitle_TEMP]
			
END


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('optitrackSDK.USP_UpdatePiwikIdentityData') IS NOT NULL DROP PROCEDURE [OptitrackSDK].[USP_UpdatePiwikIdentityData] ;
GO

CREATE PROCEDURE [optitrackSDK].[USP_UpdatePiwikIdentityData]

	@TableName nvarchar(255),
	@Id BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @SQL NVARCHAR(MAX) =''

	SET @SQL = '
	
	UPDATE [optitrackSDK].[PiwikIdentity]
	SET [Id] = ' + CAST(@Id as nvarchar(21)) + '
	WHERE [TableName] = ''' + @TableName + '''
	'
	EXEC(@SQL)

END


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('optitrackSDK.USP_UpdateSplittedVisits') IS NOT NULL DROP PROCEDURE [OptitrackSDK].[USP_UpdateSplittedVisits] ;
GO

CREATE PROCEDURE [optitrackSDK].[USP_UpdateSplittedVisits] 

AS
BEGIN
	
	SET NOCOUNT ON



UPDATE [optitrackSDK].[PiwikVisit]
SET [UserId] = T.[UserId],
	[VisitorId] = T.[VisitorId],
	[VisitLastActionTime] = T.[VisitLastActionTime],
	[TotalVisitTime] = T.[TotalVisitTime]

FROM [optitrackSDK].[PiwikVisit] P JOIN [optitrackSDK].[SplittedVisitData] T
ON P.[Id] = T.[Id]
WHERE P.[Id] >= (SELECT MIN([Id]) FROM [optitrackSDK].[SplittedVisitData])


DELETE FROM [optitrackSDK].[SplittedVisitData]
DELETE FROM [optitrackSDK].[SplittedVisitIds_TEMP]


END



SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('optitrackSDK.USP_UpdateConfigTable') IS NOT NULL DROP PROCEDURE [OptitrackSDK].[USP_UpdateConfigTable] ;
GO

CREATE PROCEDURE [optitrackSDK].[USP_UpdateConfigTable]
AS
BEGIN
	
	UPDATE [optitrackSDK].[Config]
	SET [UTMDataVisitLastId] = (SELECT MAX([Id]) FROM [optitrackSDK].[PiwikVisit])

	UPDATE [optitrackSDK].[Config]
	SET [LastAggregatedVisitId] = (SELECT MAX([Id]) FROM [optitrackSDK].[PiwikVisit])

	UPDATE [optitrackSDK].[Config]
	SET [LastAggregatedActionId] = (SELECT MAX([Id]) FROM [optitrackSDK].[PiwikVisitAction])

END


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('optitrackSDK.USP_UpdateConfigVisitorsTable') IS NOT NULL DROP PROCEDURE [OptitrackSDK].[USP_UpdateConfigVisitorsTable] ;
GO

CREATE PROCEDURE [optitrackSDK].[USP_UpdateConfigVisitorsTable]
AS
BEGIN
	
	UPDATE [optitrackSDK].[Config_Visitor]
	SET [UTMDataVisitLastId] = (SELECT MAX([Id]) FROM [optitrackSDK].[PiwikVisit])

	UPDATE [optitrackSDK].[Config_Visitor]
	SET [LastAggregatedVisitId] = (SELECT MAX([Id]) FROM [optitrackSDK].[PiwikVisit])

	UPDATE [optitrackSDK].[Config_Visitor]
	SET [LastAggregatedActionId] = (SELECT MAX([Id]) FROM [optitrackSDK].[PiwikVisitAction])

	TRUNCATE TABLE [optitrackSDK].[PiwikVisitAction]

END


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('optitrackSDK.USP_ExtractOptitrackUTMData_Visitor') IS NOT NULL DROP PROCEDURE [OptitrackSDK].[USP_ExtractOptitrackUTMData_Visitor] ;
GO

CREATE PROCEDURE [optitrackSDK].[USP_ExtractOptitrackUTMData_Visitor]


with recompile

AS
BEGIN
SET XACT_ABORT ON;

DECLARE 
@TEMP nvarchar(max) = '',
@sql nvarchar(max) = ''


SET @TEMP =  CAST((SELECT [UTMDataVisitLastId] FROM [optitrackSDK].[Config]) as nvarchar (50) );

set nocount on
set transaction isolation level read uncommitted

SET @sql = 
              '
              INSERT INTO [optitrackSDK].[UTM_Data_Visitor]
              SELECT
              Id,
              CUSTOMER_ID,
              VisitFirstActionTime as first_action_time,
              Campaign_name as Name,
              Campaign_keyword as Keyword,
              Campaign_source as campaign_Source,
              Campaign_medium as Medium,
              Campaign_content as Content FROM  [optitrackSDK].[PiwikVisit]  PS 
              
			  inner join [vis].[VisitorOptimoveIds] VOI ON PS.VisitorId = VOI.VISITOR_ID 
			  
			  WHERE 
              PS.Id >= CAST( ' + @TEMP + ' as bigint) 
              AND
              COALESCE(PS.[Campaign_name],PS.[Campaign_keyword], PS.[Campaign_source], PS.[Campaign_medium], PS.[Campaign_content]) IS NOT NULL
			  ';

print(@sql)
exec (@sql)

END



SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('optitrackSDK.USP_ExtractOptitrackUTMData') IS NOT NULL DROP PROCEDURE [OptitrackSDK].[USP_ExtractOptitrackUTMData] ;
GO
CREATE PROCEDURE [optitrackSDK].[USP_ExtractOptitrackUTMData]
        @profileServerName nvarchar(50)= '',
        @profileDBName nvarchar(50) = '',
		@Customers Nvarchar(100) = ''



with recompile

AS
BEGIN
SET XACT_ABORT ON;

DECLARE 

@FullTargetPath nvarchar(max) = '',
@TEMP nvarchar(max) = '',
@sql nvarchar(max) = '',
@CustomersTableExist Bit, 
@CustomersHashLookupTable nvarchar(max) = ''


SET @FullTargetPath = '[' + @profileDBName + ']' + '.';
IF(LEN(@profileServerName) >= 1)
BEGIN
              SET @FullTargetPath = '[' + @profileServerName + ']' + '.' + '[' + @profileDBName + ']' + '.' ;
END

IF(LEN(@Customers) >= 1)
BEGIN
SET @CustomersHashLookupTable = @FullTargetPath + '[dbo].' +  @Customers; 
END


SET @sql = 'select TOP 1 * from ' + @CustomersHashLookupTable

BEGIN TRY
       EXEC (@sql)

       IF @@ROWCOUNT = 1 
       BEGIN
              SET @CustomersTableExist = 1
       END 
       ELSE 
       BEGIN
              SET @CustomersTableExist = 0
       END
END TRY
BEGIN CATCH
       SET @CustomersTableExist = 0
END CATCH


SET @TEMP =  CAST((SELECT [UTMDataVisitLastId] FROM [optitrackSDK].[Config]) as nvarchar (50) );

set nocount on
set transaction isolation level read uncommitted

SET @sql = 
              '
              INSERT INTO [optitrackSDK].[UTM_Data]
              SELECT
              Id,
              Customer_ID as CustomerId,
              VisitFirstActionTime as first_action_time,
              Campaign_name as Name,
              Campaign_keyword as Keyword,
              Campaign_source as campaign_Source,
              Campaign_medium as Medium,
              Campaign_content as Content FROM  [optitrackSDK].[PiwikVisit]  PS '
              IF @CustomersTableExist = 1
              BEGIN
                      SET @sql +=   'INNER JOIN '    + @CustomersHashLookupTable + ' C ON PS.UserId = C.PublicCustomerId 
                                           INNER JOIN [dbo].[OptimoveCustomerIds] CI ON C.CustomerId = CI.Client_Customer_ID '
              END
              ELSE
              BEGIN
                      SET @sql += 'inner join [dbo].[OptimoveCustomerIds] CI ON UserId = CI.Client_Customer_ID '
              END
              
              SET @sql += ' WHERE 
              PS.Id >= CAST( ' + @TEMP + ' as bigint) 
              AND
              COALESCE(PS.[Campaign_name],PS.[Campaign_keyword], PS.[Campaign_source], PS.[Campaign_medium], PS.[Campaign_content]) IS NOT NULL
              ';  

print(@sql)
exec (@sql)

END


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('optitrackSDK.USP_InsertStitchVisitorsToTheMappingTable') IS NOT NULL DROP PROCEDURE [OptitrackSDK].[USP_InsertStitchVisitorsToTheMappingTable] ;
GO


CREATE PROCEDURE [optitrackSDK].[USP_InsertStitchVisitorsToTheMappingTable] 

	-- Add the parameters for the stored procedure here
	@profileServerName nvarchar(50)= '',
    @profileDBName nvarchar(50) = '',
	@lookupTableName nvarchar(100) = '',
	@isHashingTableNotExists int

AS
BEGIN

	SET NOCOUNT ON;

	DECLARE 
	@sql nvarchar(max) = '',
	@FullTargetPath nvarchar(max) = '',
	@lookupTableNameTargetPath nvarchar(max) = ''

	SET @FullTargetPath = '[' + @profileDBName + ']' + '.';
	IF(LEN(@profileServerName) >= 1)
	BEGIN
              SET @FullTargetPath = '[' + @profileServerName + ']' + '.' + '[' + @profileDBName + ']' + '.' ;
	END


	IF(LEN(@lookupTableName) >= 1)
	BEGIN
	SET @lookupTableNameTargetPath = @FullTargetPath + '[dbo].' +  @lookupTableName; 
	END



	IF(@isHashingTableNotExists = 0)
		BEGIN

			SET @sql ='
			INSERT INTO [optitrackSDK].[VisitorsMapping]
			SELECT * FROM (
				SELECT DISTINCT custom_dimension_3 AS [CLIENT_CUSTOMER_ID], custom_dimension_5 AS [VisitorId], OC.[Customer_ID] AS [Customer_ID], 2 AS [Type]
				FROM [optitrackSDK].[PiwikVisitAction] PV
				JOIN
				' + @lookupTableNameTargetPath + ' H
				ON
				PV.custom_dimension_3 = H.[PublicCustomerId]
				JOIN
				[dbo].[OptimoveCustomerIds] OC
				ON
				H.[CustomerID] = OC.[CLIENT_CUSTOMER_ID]
				WHERE PV.custom_dimension_2 = ''stitch_event''
				AND PV.custom_dimension_4 IN (SELECT [VISITOR_ID] FROM [vis].[VisitorOptimoveIds])
			) SUB
			WHERE SUB.[VisitorId] NOT IN (SELECT [VisitorId] FROM [optitrackSDK].[VisitorsMapping])			
			'

			EXEC(@sql);
		END
	ELSE
		BEGIN
			
			INSERT INTO [optitrackSDK].[VisitorsMapping]
			SELECT * FROM (
				SELECT DISTINCT custom_dimension_3 AS [CLIENT_CUSTOMER_ID], custom_dimension_5 AS [VisitorId], OC.[Customer_ID] AS [Customer_ID], 2 AS [Type]
				FROM [optitrackSDK].[PiwikVisitAction] PV
				JOIN
				[dbo].[OptimoveCustomerIds] OC
				ON
				PV.custom_dimension_3 = OC.[CLIENT_CUSTOMER_ID]
				WHERE PV.custom_dimension_2 = 'stitch_event'
				AND PV.custom_dimension_4 IN (SELECT [VISITOR_ID] FROM [vis].[VisitorOptimoveIds])
			) SUB
			WHERE SUB.[VisitorId] NOT IN (SELECT [VisitorId] FROM [optitrackSDK].[VisitorsMapping])
		
		END

	DELETE FROM [vis].[VisitorOptimoveIds] 
	WHERE [VISITOR_ID] IN (SELECT [VisitorId] FROM [optitrackSDK].[VisitorsMapping] WHERE [Type] = 2)
	
	-- delete profiles of visitor who made a conversion
	DELETE FROM [vis].[VisitorProfileDaily] 
	WHERE CUSTOMER_ID IN (SELECT [Customer_ID] FROM [optitrackSDK].[VisitorsMapping])
	AND CUSTOMER_ID NOT IN (SELECT [CUSTOMER_ID] FROM [vis].[VisitorOptimoveIds])

END





SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF [dbo].[udf_IsObjectExists]('[optitrackSDK].[USP_PopulatePagesCategoriesEventsRawData_Visitor]','SP') = 1 DROP PROCEDURE [optitrack].[USP_PopulatePagesCategoriesEventsRawData_Visitor]
GO



CREATE PROCEDURE [optitrackSDK].[USP_PopulatePagesCategoriesEventsRawData_Visitor]

AS
BEGIN
     INSERT INTO [optitrackSDK].[PagesCategoriesEventsRawData_Visitor]
     SELECT DISTINCT pva.EventActionTime , pva.id  , pva.VisitId , voi.Customer_ID, pc.Id FROM [optitrackSDK].[PiwikVisitAction] AS pva 
     JOIN [optitrackSDK].[PiwikVisit] AS pv ON pva.VisitId = pv.Id 
     JOIN [OptitrackSDK].[PagesCategories] AS pc  ON pva.custom_dimension_3 = pc.pagecategory
     JOIN vis.VisitorOptimoveIds AS voi ON voi.VISITOR_ID = pva.VisitorId
     WHERE custom_dimension_1 = 1003 and custom_dimension_2 = 'page_category_event'

END



SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF [dbo].[udf_IsObjectExists]('[optitrackSDK].[USP_PopulateTotalDailyPagesCategoriesAggregation_Visitor]','SP') = 1 DROP PROCEDURE [optitrack].[USP_PopulateTotalDailyPagesCategoriesAggregation_Visitor]
GO

CREATE PROCEDURE [optitrackSDK].[USP_PopulateTotalDailyPagesCategoriesAggregation_Visitor]

AS
BEGIN
     MERGE [optitrackSDK].[TotalDailyPagesCategoriesAggregation_Visitor] AS NEW_TDPCA
     USING (    SELECT CONVERT(date, DATEADD(DAY,0, DATEDIFF(DAY,0, ActionTime))) AS DATE,MAX(ActionId) AS LastComputedActionId ,CustomerId,PageCategoryID,Count(PageCategoryID) AS NumOfPageVisits
                FROM [optitrackSDK].[PagesCategoriesEventsRawData_Visitor] AS PCERD
                GROUP BY CONVERT(date, DATEADD(DAY,0, DATEDIFF(DAY,0, ActionTime))),CustomerId,PageCategoryID) AS OLD_TDPCA
     ON NEW_TDPCA.DATE = OLD_TDPCA.DATE AND NEW_TDPCA.CustomerId = OLD_TDPCA.CustomerId AND NEW_TDPCA.PageCategoryID = OLD_TDPCA.PageCategoryID
     WHEN MATCHED THEN
           UPDATE 
           SET  NumOfPageVisits = OLD_TDPCA.NumOfPageVisits,
                LastComputedActionId = OLD_TDPCA.LastComputedActionId
     WHEN NOT MATCHED THEN                                 
           INSERT                                  
           VALUES (OLD_TDPCA.DATE, OLD_TDPCA.LastComputedActionId ,OLD_TDPCA.CustomerId,OLD_TDPCA.PageCategoryID ,OLD_TDPCA.NumOfPageVisits);  
     

     SELECT @@ROWCOUNT
END
