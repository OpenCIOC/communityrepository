SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_Users_s] (
	@User_ID int
)
AS BEGIN

SET NOCOUNT ON

SELECT u.*, l.Culture
FROM Users u
INNER JOIN Language l
	ON u.StartLanguage=l.LangID
WHERE User_ID = @User_ID

SELECT cmn.CM_ID, cmn.Name 
FROM Users_ManageArea ma
INNER JOIN Community_Name cmn
	ON cmn.CM_ID=ma.CM_ID AND cmn.LangID=(SELECT TOP 1 LangID FROM Community_Name 
									WHERE CM_ID=cmn.CM_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE ma.User_ID=@User_ID

SET NOCOUNT OFF

END







GO
GRANT EXECUTE ON  [dbo].[sp_Users_s] TO [web_user]
GO
