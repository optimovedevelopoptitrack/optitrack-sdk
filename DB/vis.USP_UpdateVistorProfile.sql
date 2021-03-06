IF (OBJECT_ID('[vis].[USP_UpdateVistorProfile]') IS NOT NULL)
	DROP PROCEDURE [vis].[USP_UpdateVistorProfile]
GO

CREATE PROCEDURE [vis].[USP_UpdateVistorProfile]
@ProfileDate Date 
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
	SET NOCOUNT ON
	SET XACT_ABORT ON
	
	DECLARE @ITERATION_NUMBER Int

	DECLARE @MissingProfileDate Date

	SELECT @MissingProfileDate = DATEADD(DAY,1,MAX(ProfileDate))
	FROM vis.VisitorProfileDailyUpdates
	
	WHILE @MissingProfileDate < @ProfileDate
	BEGIN
		EXEC [vis].[USP_UpdateVistorProfile_sdk] @MissingProfileDate
		SET @MissingProfileDate = DATEADD(DAY,1,@MissingProfileDate)
	END

	;WITH Events_30Days AS (
		   SELECT CustomerId, COUNT(DISTINCT Date) AS SessionDays
		   FROM [optitrackSDK].[TotalVisitsInfoAggregation_Visitor]
		   WHERE Date BETWEEN DATEADD(DAY,-29,@ProfileDate) AND @ProfileDate
		   group by CustomerId)
	,Events_7Days AS (
		   SELECT CustomerId, COUNT(DISTINCT Date) AS SessionDays
		   FROM [optitrackSDK].[TotalVisitsInfoAggregation_Visitor]
		   WHERE Date BETWEEN DATEADD(DAY,-6,@ProfileDate) AND @ProfileDate
		   group by CustomerId)
	,Events_Today AS (
		   SELECT T.CustomerId, MAX(V.LocationCityId) Last_GEO_Location
		   FROM [optitrackSDK].[TotalVisitsInfoAggregation_Visitor] T
		   JOIN [optitrackSDK].[VisitInfoRawData_Visitor] V
				ON T.CustomerId = V.CustomerId
		   WHERE T.Date = @ProfileDate
		   group by T.CustomerId)
	,Events_All AS (
		   SELECT T.CustomerId, SUM(T.TotalNumberOfVisits) AS TotalSessions, MAX(T.Date) AS LastSessionDate, MIN(T.Date) AS FirstSessionDate, COUNT(DISTINCT T.Date) as NumberOfVisitDays, sum(T.TotalVisitTime) AS TotalVisitTime, sum(TD.NumOfPageVisits) AS NumberOfPageVisits
		   FROM [optitrackSDK].[TotalVisitsInfoAggregation_Visitor] T
		   JOIN [optitrackSDK].[TotalDailyPagesVisitsAggregation_Visitor] TD
				ON T.CustomerId = TD.CustomerId
		   WHERE T.Date <= @ProfileDate
		   group by T.CustomerId
		   )
	--,Click AS (
	--       SELECT CustomerId, SUM(NumberOfClicks) AS NumberOfClicks
	--                             FROM [optitrack].[EventClicks_UniqueVisitors] ECUV 
	--							 WHERE Date <= @ProfileDate
	--                             group by CustomerId
	--       )
       , Source as (
       SELECT 
       VOI.CUSTOMER_ID,
       LastSessionDate,
       ISNULL(Events_7Days.SessionDays,0) AS NumberOfSessionsDays_Last7Days,
       ISNULL(Events_30Days.SessionDays,0) AS NumberOfSessionsDays_Last30Days,
       NumberOfVisitDays,
       FirstSessionDate,
       Events_All.TotalSessions / NULLIF(CAST(Events_All.NumberOfVisitDays AS Decimal(10,2)),0) AS AvgNumberOfSessionsPerActiveDay,
       Events_All.TotalVisitTime / NULLIF(CAST(Events_All.TotalSessions AS Decimal(10,2)),0) AS AvgSessionLength,
       Events_All.NumberOfPageVisits / NULLIF(CAST(Events_All.NumberOfVisitDays AS Decimal(10,2)),0) AS AvgNumberOfPagesPerActiveDay,
       --ISNULL(Click.NumberOfClicks,0) / NULLIF(CAST(Events_All.NumberOfVisitDays AS Decimal(10,2)),0) AS AvgNumberOfClicksPerActiveDay,
       NULLIF(RTRIM(LTRIM(Last_GEO_Location)),'') AS LastGeoLocationId
       FROM [vis].[VisitorOptimoveIds] VOI
       inner JOIN Events_All ON VOI.Customer_ID = Events_All.CustomerId
       LEFT JOIN Events_30Days ON VOI.Customer_ID = Events_30Days.CustomerId
       LEFT JOIN Events_7Days ON VOI.Customer_ID = Events_7Days.CustomerId
       LEFT JOIN Events_Today ON VOI.Customer_ID = Events_Today.CustomerId
       --LEFT JOIN Click ON VOI.Customer_ID = Click.Customer_ID
	   LEFT JOIN [optitrackSDK].[LocationCity] LC ON Events_Today.Last_GEO_Location = LC.LocationCityId
	   WHERE LastSessionDate >= DATEADD(DAY, -180, @ProfileDate)
       )

	   MERGE [vis].[VisitorProfileDaily] AS TARGET
	   USING SOURCE
	   ON TARGET.Customer_ID = SOURCE.Customer_ID
	   WHEN MATCHED AND (ISNULL(TARGET.LastSessionDate,'2001/01/01')        <> ISNULL(SOURCE.LastSessionDate,'2001/01/01') OR 
						 ISNULL(TARGET.NumberOfSessionsDays_Last7Days,-1)     <> ISNULL(SOURCE.NumberOfSessionsDays_Last7Days,-1) OR 
						 ISNULL(TARGET.NumberOfSessionsDays_Last30Days,-1)    <> ISNULL(SOURCE.NumberOfSessionsDays_Last30Days,-1) OR 
						 ISNULL(TARGET.NumberOfVisitDays,-1)                  <> ISNULL(SOURCE.NumberOfVisitDays,-1) OR 
						 ISNULL(TARGET.FirstSessionDate,'2001/01/01')       <> ISNULL(SOURCE.FirstSessionDate,'2001/01/01') OR 
						 /*ISNULL(TARGET.AvgNumberOfSessionsPerActiveDay,-1)    <> ISNULL(SOURCE.AvgNumberOfSessionsPerActiveDay,-1) OR 
						 ISNULL(TARGET.AvgSessionLength,-1)                   <> ISNULL(SOURCE.AvgSessionLength,-1) OR 
						 ISNULL(TARGET.AvgNumberOfPagesPerActiveDay,-1)       <> ISNULL(SOURCE.AvgNumberOfPagesPerActiveDay,-1) OR 
						 ISNULL(TARGET.AvgNumberOfClicksPerActiveDay,-1)      <> ISNULL(SOURCE.AvgNumberOfClicksPerActiveDay,-1) OR*/ 
						 ISNULL(TARGET.LastGeoLocationId,'@@@')             <> SOURCE.LastGeoLocationId)
	   THEN UPDATE SET  LastSessionDate                    = SOURCE.LastSessionDate,
						NumberOfSessionsDays_Last7Days     = SOURCE.NumberOfSessionsDays_Last7Days,
						NumberOfSessionsDays_Last30Days    = SOURCE.NumberOfSessionsDays_Last30Days,
						NumberOfVisitDays                  = SOURCE.NumberOfVisitDays,
						FirstSessionDate                   = SOURCE.FirstSessionDate,
						AvgNumberOfSessionsPerActiveDay    = SOURCE.AvgNumberOfSessionsPerActiveDay,
						AvgSessionLength                   = SOURCE.AvgSessionLength,
						AvgNumberOfPagesPerActiveDay       = SOURCE.AvgNumberOfPagesPerActiveDay,
						--AvgNumberOfClicksPerActiveDay      = SOURCE.AvgNumberOfClicksPerActiveDay,
						LastGeoLocationId                  = ISNULL(SOURCE.LastGeoLocationId,TARGET.LastGeoLocationId)
	   WHEN NOT MATCHED BY SOURCE THEN
	   DELETE
	   WHEN NOT MATCHED BY TARGET THEN
	   INSERT (CUSTOMER_ID,LastSessionDate,NumberOfSessionsDays_Last7Days,NumberOfSessionsDays_Last30Days,
              NumberOfVisitDays,FirstSessionDate,AvgNumberOfSessionsPerActiveDay,AvgSessionLength,AvgNumberOfPagesPerActiveDay,
              --AvgNumberOfClicksPerActiveDay,
			  LastGeoLocationId)
       VALUES(SOURCE.CUSTOMER_ID,SOURCE.LastSessionDate,SOURCE.NumberOfSessionsDays_Last7Days,SOURCE.NumberOfSessionsDays_Last30Days,SOURCE.NumberOfVisitDays,SOURCE.FirstSessionDate,SOURCE.AvgNumberOfSessionsPerActiveDay,
              SOURCE.AvgSessionLength,SOURCE.AvgNumberOfPagesPerActiveDay,--SOURCE.AvgNumberOfClicksPerActiveDay,
			  SOURCE.LastGeoLocationId);

	;WITH Source AS (
	SELECT @ProfileDate AS SNAPSHOT_DATE, T.CustomerId CUSTOMER_ID, SUM(T.TotalNumberOfVisits) AS TotalSessions, SUM(TD.NumOfPageVisits) AS NumberOfPageVisits,NULL AS NumberOfClicks,SUM(T.TotalVisitTime) AS TotalVisitTime
	FROM [optitrackSDK].[TotalVisitsInfoAggregation_Visitor] T
	JOIN [optitrackSDK].[TotalDailyPagesVisitsAggregation_Visitor] TD
			ON T.CustomerId = TD.CustomerId
	--OUTER APPLY (SELECT SUM(NumberOfClicks) AS NumberOfClicks
	--			 FROM [optitrack].[EventClicks_UniqueVisitors] ECUV -------------------------------------------------------------------
	--			 WHERE ECUV.CustomerId = UV.CustomerId
	--					AND Date = @ProfileDate) SUB
	WHERE T.Date = @ProfileDate
			AND T.TotalNumberOfVisits > 0
	GROUP BY T.CustomerId)

	MERGE vis.visitorgranulardata AS Target
	USING Source 
	ON Target.SNAPSHOT_DATE = Source.SNAPSHOT_DATE
	AND Target.CUSTOMER_ID = Source.CUSTOMER_ID
	WHEN MATCHED AND (Target.NumberOfSessions <> Source.TotalSessions OR 
					  Target.TotalSessionsTime <> Source.TotalVisitTime OR
					  Target.NumberOfPages <> Source.NumberOfPageVisits OR
					  Target.NumberOfClicks <> Source.NumberOfClicks)
		THEN UPDATE SET Target.NumberOfSessions = Source.TotalSessions,
					  Target.TotalSessionsTime = Source.TotalVisitTime,
					  Target.NumberOfPages = Source.NumberOfPageVisits,
					  Target.NumberOfClicks = Source.NumberOfClicks,
					  Target.AvgSessionLength = Source.TotalVisitTime / NULLIF(CAST(Source.TotalSessions AS Float),0)
	WHEN NOT MATCHED BY TARGET THEN 
	INSERT (SNAPSHOT_DATE,CUSTOMER_ID,NumberOfSessions,TotalSessionsTime,AvgSessionLength,NumberOfPages,NumberOfClicks)
	VALUES (Source.SNAPSHOT_DATE,Source.CUSTOMER_ID,Source.TotalSessions,Source.TotalVisitTime,Source.TotalVisitTime  / NULLIF(CAST(Source.TotalSessions AS Float),0),Source.NumberOfPageVisits,Source.NumberOfClicks);


	SELECT @ITERATION_NUMBER = ITERATION_NUMBER
	FROM [IterationsDictionary]
	WHERE [IterationsDictionary].END_DATE = @ProfileDate

	;WITH cte AS
	(
	SELECT  VPD.CUSTOMER_ID
	,L1.ClusterId DaysSinceFirstVisit_ClusterId
	,L2.ClusterId NumberOfVisitDays_ClusterId
	,L3.ClusterId DaysSinceLastVisit_ClusterId
	FROM [vis].[VisitorProfileDaily] VPD
			INNER JOIN vis.VisitorLayerValues_DaysSinceFirstVisit L1 ON VPD.FirstSessionDate BETWEEN DATEADD(DAY,-L1.ToValue,DATEADD(DAY, 1, @ProfileDate)) AND DATEADD(DAY,-L1.FromValue,DATEADD(DAY, 1, @ProfileDate))
			INNER JOIN vis.VisitorLayerValues_NumberOfVisitDays L2 ON VPD.NumberOfVisitDays BETWEEN L2.FromValue AND L2.ToValue
			INNER JOIN vis.VisitorLayerValues_DaysSinceLastVisit L3 ON VPD.LastSessionDate  BETWEEN DATEADD(DAY,-L3.ToValue,DATEADD(DAY, 1, @ProfileDate)) AND DATEADD(DAY,-L3.FromValue,DATEADD(DAY, 1, @ProfileDate))
	)
	, SOURCE AS (
	SELECT  ITERATION_NUMBER,cte.CUSTOMER_ID, VSM.SegmentID AS SEGMENT_ID,
	LastSessionDate,
	NumberOfSessionsDays_Last7Days,
	NumberOfSessionsDays_Last30Days,
	NumberOfVisitDays,
	FirstSessionDate,
	AvgNumberOfSessionsPerActiveDay,
	AvgSessionLength,
	AvgNumberOfPagesPerActiveDay,
	--AvgNumberOfClicksPerActiveDay,
	LastGeoLocationId,
	LastUtmSource,
	LastUtmMedium,
	LastUtmCampaign,
	LastUtmTerm,
	LastUtmContent,
	Email
	FROM [vis].[VisitorProfileDaily] VPD
		LEFT JOIN [vis].[VisitorProfileExtendedData] VPED ON VPED.Customer_ID = VPD.Customer_ID
		CROSS JOIN [dbo].[IterationsDictionary]
		INNER JOIN cte ON VPD.Customer_ID = cte.Customer_ID
		INNER JOIN [vis].[VisitorSegmentsMapping] VSM ON cte.DaysSinceFirstVisit_ClusterId = VSM.DaysSinceFirstVisit_ClusterId
					AND cte.NumberOfVisitDays_ClusterId = VSM.NumberOfVisitDays_ClusterId
					AND cte.DaysSinceLastVisit_ClusterId = VSM.DaysSinceLastVisit_ClusterId 
		WHERE [IterationsDictionary].END_DATE = @ProfileDate
	)		
	,
	TARGET AS (SELECT * FROM Vis.VisitorProfile WHERE ITERATION_NUMBER = @ITERATION_NUMBER)
	
	MERGE TARGET
	USING SOURCE
	ON TARGET.ITERATION_NUMBER = SOURCE.ITERATION_NUMBER
		AND TARGET.Customer_ID = SOURCE.Customer_ID
	WHEN MATCHED THEN UPDATE SET TARGET.SEGMENT_ID = SOURCE.SEGMENT_ID,
								TARGET.LastSessionDate = SOURCE.LastSessionDate,
								TARGET.NumberOfSessionsDays_Last7Days = SOURCE.NumberOfSessionsDays_Last7Days,
								TARGET.NumberOfSessionsDays_Last30Days = SOURCE.NumberOfSessionsDays_Last30Days,
								TARGET.NumberOfVisitDays = SOURCE.NumberOfVisitDays,
								TARGET.FirstSessionDate = SOURCE.FirstSessionDate,
								TARGET.AvgNumberOfSessionsPerActiveDay = SOURCE.AvgNumberOfSessionsPerActiveDay,
								TARGET.AvgSessionLength = SOURCE.AvgSessionLength,
								TARGET.AvgNumberOfPagesPerActiveDay = SOURCE.AvgNumberOfPagesPerActiveDay,
								--TARGET.AvgNumberOfClicksPerActiveDay = SOURCE.AvgNumberOfClicksPerActiveDay,
								TARGET.LastGeoLocationId = SOURCE.LastGeoLocationId,
								TARGET.LastUtmSource = SOURCE.LastUtmSource,
								TARGET.LastUtmMedium = SOURCE.LastUtmMedium,
								TARGET.LastUtmCampaign = SOURCE.LastUtmCampaign,
								TARGET.LastUtmTerm = SOURCE.LastUtmTerm,
								TARGET.LastUtmContent = SOURCE.LastUtmContent,
								TARGET.Email = SOURCE.Email
	WHEN NOT MATCHED BY SOURCE THEN DELETE
	WHEN NOT MATCHED BY TARGET THEN INSERT (ITERATION_NUMBER,CUSTOMER_ID,SEGMENT_ID,LastSessionDate,NumberOfSessionsDays_Last7Days,NumberOfSessionsDays_Last30Days,NumberOfVisitDays,
	FirstSessionDate,AvgNumberOfSessionsPerActiveDay,AvgSessionLength,AvgNumberOfPagesPerActiveDay,--AvgNumberOfClicksPerActiveDay,
	LastGeoLocationId,LastUtmSource,LastUtmMedium,LastUtmCampaign,
	LastUtmTerm,LastUtmContent,Email)
	VALUES (SOURCE.ITERATION_NUMBER,SOURCE.CUSTOMER_ID,SOURCE.SEGMENT_ID,SOURCE.LastSessionDate,SOURCE.NumberOfSessionsDays_Last7Days,SOURCE.NumberOfSessionsDays_Last30Days,SOURCE.NumberOfVisitDays,
	SOURCE.FirstSessionDate,SOURCE.AvgNumberOfSessionsPerActiveDay,SOURCE.AvgSessionLength,SOURCE.AvgNumberOfPagesPerActiveDay,--SOURCE.AvgNumberOfClicksPerActiveDay,
	SOURCE.LastGeoLocationId,SOURCE.LastUtmSource,SOURCE.LastUtmMedium,SOURCE.LastUtmCampaign,
	SOURCE.LastUtmTerm,SOURCE.LastUtmContent,SOURCE.Email);

	DELETE Vis.IterationDictionaryImportedVisitorProfiles
	WHERE END_DATE = @ProfileDate	

  	INSERT Vis.IterationDictionaryImportedVisitorProfiles
	SELECT ITERATION_NUMBER, END_DATE
	FROM [IterationsDictionary]
	WHERE [IterationsDictionary].END_DATE = @ProfileDate	

	;WITH Source AS (SELECT @ProfileDate AS ProfileDate, GETDATE() AS UpdateDate, GETDATE() AS FirstUpdateDate, 1 AS TotalUpdates)

	MERGE vis.VisitorProfileDailyUpdates AS TARGET
	USING SOURCE 
	ON TARGET.ProfileDate = SOURCE.ProfileDate
	WHEN MATCHED THEN UPDATE SET UpdateDate = SOURCE.UpdateDate,
								 TotalUpdates += SOURCE.TotalUpdates
	WHEN NOT MATCHED BY TARGET THEN
	INSERT (ProfileDate, UpdateDate, FirstUpdateDate, TotalUpdates)
	VALUES (SOURCE.ProfileDate, SOURCE.UpdateDate, SOURCE.FirstUpdateDate, SOURCE.TotalUpdates);
END
