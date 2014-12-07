SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_Users_l]
AS BEGIN

SET NOCOUNT ON

SELECT *, (SELECT Name 
			FROM Community_Name cmn
			INNER JOIN Users_ManageArea	uma
				ON cmn.CM_ID=uma.CM_ID AND LangID=(SELECT TOP 1 LangID FROM Community_Name WHERE cmn.CM_ID=CM_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
			WHERE uma.User_ID=u.User_ID
			FOR XML AUTO, TYPE) AS ManageCommunities
FROM Users u
ORDER BY Inactive, CASE WHEN Admin = 1 THEN 0 ELSE 1 END, CASE WHEN ManageAreaList IS NOT NULL THEN 1 ELSE 0 END, u.UserName

SET NOCOUNT OFF

END







GO
GRANT EXECUTE ON  [dbo].[sp_Users_l] TO [web_user]
GO
