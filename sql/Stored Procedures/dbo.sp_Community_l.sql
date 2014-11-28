SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_Community_l] (
	@User_ID int
)
AS BEGIN

SET NOCOUNT ON

SELECT cm.CM_ID, cmn.Name, cm.AlternativeArea, cm.ParentCommunity,
	CASE WHEN EXISTS(SELECT * FROM Users u
			WHERE u.[User_ID]=@User_ID AND (
				u.[Admin]=1 OR
				EXISTS(SELECT * FROM Users_ManageArea uma
					WHERE u.[User_ID]=uma.[User_ID] AND (uma.CM_ID=cm.CM_ID OR EXISTS(SELECT * FROM Community_ParentList cmpl WHERE cmpl.Parent_CM_ID=uma.CM_ID AND cmpl.CM_ID=cm.CM_ID))
				)
			)
		) THEN 1 ELSE 0 END AS CanEdit
FROM Community cm
INNER JOIN Community_Name cmn
	ON cm.CM_ID=cmn.CM_ID AND cmn.LangID=(SELECT TOP 1 LangID FROM Community_Name WHERE CM_ID=cm.CM_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
ORDER BY ParentCommunity, cmn.Name

SET NOCOUNT OFF

END






GO
GRANT EXECUTE ON  [dbo].[sp_Community_l] TO [web_user]
GO
