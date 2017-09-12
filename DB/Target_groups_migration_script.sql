-- In case the customer has migrated to OptitrackSDK:
--===================================================

-- if client has the old version of optitrack, hide old optitrack conditions
UPDATE TargetGroupConditions SET IS_DISABLED = 1, IS_HIDDEN = 1, FOLDER_ID = 0 WHERE ID = 12	-- customers
UPDATE TargetGroupConditions SET IS_DISABLED = 1, IS_HIDDEN = 1, FOLDER_ID = 0 WHERE ID = 21 	-- visitors

-- activate new optitrack sdk conditions
UPDATE TargetGroupConditions SET IS_DISABLED = 0, IS_HIDDEN = 0, FOLDER_ID = 3 WHERE ID = 24	-- customers
UPDATE TargetGroupConditions SET IS_DISABLED = 0, IS_HIDDEN = 0, FOLDER_ID = 4 WHERE ID = 25	-- visitors




