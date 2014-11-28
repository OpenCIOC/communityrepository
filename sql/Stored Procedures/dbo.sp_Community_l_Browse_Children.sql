SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_Community_l_Browse_Children] (
	@CM_ID int
)
AS
BEGIN

SET NOCOUNT ON


SELECT cm.CM_ID, cmn.Name, AlternativeArea, 0 AS OpenItem, cm.Depth, cm.ParentCommunity, CAST(CASE WHEN EXISTS(SELECT * FROM Community_ParentList WHERE Parent_CM_ID=cm.CM_ID) THEN 1 ELSE 0 END AS bit) AS HasChildren
FROM Community cm
INNER JOIN Community_Name cmn
	ON cm.CM_ID=cmn.CM_ID AND cmn.LangID=(SELECT TOP 1 LangID FROM Community_Name WHERE CM_ID=cm.CM_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE cm.ParentCommunity=@CM_ID
ORDER BY SortCode

SET NOCOUNT OFF

END


GO
GRANT EXECUTE ON  [dbo].[sp_Community_l_Browse_Children] TO [web_user]
GO
