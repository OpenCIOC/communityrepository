SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_Community_l_Browse] (
	@OpenList varchar(max)
)
AS BEGIN

SET NOCOUNT ON

DECLARE @OpenListTable TABLE (
	CM_ID int NOT NULL PRIMARY KEY,
	OpenItem bit NOT NULL DEFAULT (0)
)

INSERT INTO @OpenListTable
SELECT CM_ID, 1 FROM Community WHERE ParentCommunity IS NULL

INSERT INTO @OpenListTable
SELECT DISTINCT CM_ID, 1
	FROM Community cm
	INNER JOIN dbo.fn_ParseIntIDList(@OpenList, ',') t
		ON cm.CM_ID=t.ItemID
WHERE NOT EXISTS(SELECT * FROM @OpenListTable WHERE CM_ID=cm.CM_ID)
		
INSERT INTO @OpenListTable
	SELECT DISTINCT Parent_CM_ID, 1
		FROM Community_ParentList cmpl
	WHERE CM_ID IN (SELECT CM_ID FROM @OpenListTable)
		AND NOT EXISTS(SELECT * FROM @OpenListTable WHERE CM_ID=cmpl.Parent_CM_ID)

INSERT INTO @OpenListTable
	SELECT CM_ID, 0
		FROM Community cm
	WHERE ParentCommunity IN (SELECT CM_ID FROM @OpenListTable)
		AND NOT EXISTS(SELECT * FROM @OpenListTable WHERE CM_ID=cm.CM_ID)


SELECT cm.CM_ID, cmn.Name, AlternativeArea, ISNULL(olt.OpenItem,0) AS OpenItem, cm.Depth, cm.ParentCommunity, CAST(CASE WHEN EXISTS(SELECT * FROM Community_ParentList WHERE Parent_CM_ID=cm.CM_ID) THEN 1 ELSE 0 END AS bit) AS HasChildren
FROM Community cm
INNER JOIN Community_Name cmn
	ON cm.CM_ID=cmn.CM_ID AND cmn.LangID=(SELECT TOP 1 LangID FROM Community_Name WHERE CM_ID=cm.CM_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
INNER JOIN @OpenListTable olt
	ON cm.CM_ID=olt.CM_ID
ORDER BY ParentCommunity, SortCode

SET NOCOUNT OFF

END



GO
GRANT EXECUTE ON  [dbo].[sp_Community_l_Browse] TO [web_user]
GO
