
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_Community_External_Map_u]
	@SystemCode varchar(30)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

IF EXISTS(SELECT * FROM dbo.External_System WHERE SystemCode=@SystemCode) BEGIN

MERGE INTO dbo.Community_External_Map cem
USING dbo.Community cm
	ON cm.CM_ID=cem.CM_ID AND cem.SystemCode=@SystemCode
WHEN MATCHED 
THEN UPDATE SET MapOneEXTID = CASE WHEN (SELECT COUNT(*) FROM dbo.External_Community excm WHERE excm.CM_ID=cm.CM_ID AND excm.SystemCode=@SystemCode)=1
			THEN (SELECT excm.EXT_ID FROM dbo.External_Community excm WHERE excm.CM_ID=cm.CM_ID AND excm.SystemCode=@SystemCode)
			ELSE NULL
			END,
		MapAllEXTID = (SELECT excm.EXT_ID AS "@EXT_ID" FROM dbo.External_Community excm WHERE excm.CM_ID=cm.CM_ID AND excm.SystemCode=@SystemCode FOR XML PATH('Map'), TYPE)
WHEN NOT MATCHED BY TARGET
	THEN INSERT (CM_ID, SystemCode, MapOneEXTID, MapAllEXTID)
		VALUES (
			cm.CM_ID,
			@SystemCode,
			CASE WHEN (SELECT COUNT(*) FROM dbo.External_Community excm WHERE excm.CM_ID=cm.CM_ID AND excm.SystemCode=@SystemCode)=1
				THEN (SELECT excm.EXT_ID FROM dbo.External_Community excm WHERE excm.CM_ID=cm.CM_ID AND excm.SystemCode=@SystemCode)
				ELSE NULL
				END,
			(SELECT	excm.EXT_ID AS "@EXT_ID" FROM dbo.External_Community excm WHERE excm.CM_ID=cm.CM_ID AND excm.SystemCode=@SystemCode
					FOR XML PATH('Map'), TYPE))
WHEN NOT MATCHED BY SOURCE AND cem.SystemCode=@SystemCode
	THEN DELETE
;

WHILE EXISTS(SELECT * FROM dbo.Community_External_Map cem
	INNER JOIN dbo.Community cm ON cm.CM_ID = cem.CM_ID
	INNER JOIN dbo.Community_External_Map cemp ON cm.ParentCommunity=cemp.CM_ID AND cemp.SystemCode=@SystemCode AND cemp.MapOneEXTID IS NOT NULL
	WHERE cem.SystemCode=@SystemCode AND cem.MapOneEXTID IS NULL) BEGIN
		UPDATE cem
			SET MapOneEXTID=cemp.MapOneEXTID
		FROM dbo.Community_External_Map cem
		INNER JOIN dbo.Community cm ON cm.CM_ID=cem.CM_ID
		INNER JOIN dbo.Community_External_Map cemp ON cm.ParentCommunity=cemp.CM_ID AND cemp.SystemCode=@SystemCode AND cemp.MapOneEXTID IS NOT NULL
		WHERE cem.SystemCode=@SystemCode AND cem.MapOneEXTID IS NULL
END

-- Has a Map-to-one, has no Map-to-all, is not an Alt area, does not have any mapped children
-- Map-to-all will be same as Map-to-one
UPDATE cem
	SET MapAllExtID = (SELECT MapOneEXTID AS "@EXT_ID" FOR XML PATH('Map'), TYPE)
FROM dbo.Community_External_Map cem
INNER JOIN dbo.Community cm ON cm.CM_ID=cem.CM_ID AND cem.SystemCode=@SystemCode
WHERE cem.MapAllEXTID IS NULL
	AND cem.MapOneEXTID IS NOT NULL
	AND cm.AlternativeArea=0
	AND NOT EXISTS(SELECT *
		FROM dbo.Community_External_Map cem2
		INNER JOIN dbo.Community_ParentList cmpl ON cmpl.CM_ID=cem2.CM_ID
		WHERE cmpl.Parent_CM_ID=cem.CM_ID
			AND cem2.MapAllEXTID IS NOT NULL
			AND cem2.SystemCode=@SystemCode
		)

DECLARE @MapToChildren tinyint
SET @MapToChildren=3

WHILE @MapToChildren > 0 BEGIN
	-- Run 3 times
	-- Has a Map-to-one, has no Map-to-all, is not an Alt area, all immediate children are mapped
	-- Map-to-all will union of mapped children
	UPDATE cem
		SET MapAllEXTID= (SELECT DISTINCT N.value('@EXT_ID','int') AS '@EXT_ID'
				FROM dbo.Community cm
				INNER JOIN dbo.Community_External_Map cem2 ON cm.CM_ID=cem2.CM_ID AND cem2.SystemCode=@SystemCode
				CROSS APPLY MapAllEXTID.nodes('/Map') AS T(N)
					WHERE cm.ParentCommunity=cem.CM_ID
				AND cem2.MapAllEXTID IS NOT NULL
				FOR XML	PATH('Map'))
	FROM dbo.Community_External_Map cem
	INNER JOIN dbo.Community cm ON cm.CM_ID=cem.CM_ID AND cem.SystemCode=@SystemCode
	WHERE cem.MapAllEXTID IS NULL
		AND cem.MapOneEXTID IS NOT NULL
		AND cm.AlternativeArea=0
		AND EXISTS(SELECT *
			FROM dbo.Community cm
			INNER JOIN dbo.Community_External_Map cem2 ON cm.CM_ID=cem2.CM_ID AND cem2.SystemCode=@SystemCode
			WHERE cm.ParentCommunity=cem.CM_ID
				AND cem2.MapAllEXTID IS NOT NULL)
		AND NOT EXISTS(SELECT *
			FROM dbo.Community cm
			INNER JOIN dbo.Community_External_Map cem2 ON cm.CM_ID=cem2.CM_ID AND cem2.SystemCode=@SystemCode
			WHERE cm.ParentCommunity=cem.CM_ID
				AND cem2.MapAllEXTID IS NULL)
	SET @MapToChildren = @MapToChildren-1
END

-- Expand out Alternative Search Areas
UPDATE cem
	SET MapAllEXTID=(SELECT DISTINCT N.value('@EXT_ID','int') AS '@EXT_ID'
			FROM dbo.Community_AltAreaSearch cm
			INNER JOIN dbo.Community_External_Map cem2 ON cm.Search_CM_ID=cem2.CM_ID AND cem2.SystemCode=@SystemCode
			CROSS APPLY MapAllEXTID.nodes('/Map') AS T(N)
				WHERE cm.CM_ID=cem.CM_ID
			AND cem2.MapAllEXTID IS NOT NULL
			FOR XML	PATH('Map'))
FROM dbo.Community_External_Map cem
INNER JOIN dbo.Community cm ON cm.CM_ID=cem.CM_ID AND cem.SystemCode=@SystemCode
WHERE cem.MapAllEXTID IS NULL
	AND	cm.AlternativeArea=1

-- Last chance - make Map-to-all equal to Map-to-one
UPDATE cem
	SET MapAllExtID = (SELECT MapOneEXTID AS "@EXT_ID" FOR XML PATH('Map'), TYPE)
FROM dbo.Community_External_Map cem
INNER JOIN dbo.Community cm ON cm.CM_ID=cem.CM_ID AND cem.SystemCode=@SystemCode
WHERE cem.MapAllEXTID IS NULL
	AND cem.MapOneEXTID IS NOT NULL

END

SET NOCOUNT OFF

GO

GRANT EXECUTE ON  [dbo].[sp_Community_External_Map_u] TO [web_user]
GO
