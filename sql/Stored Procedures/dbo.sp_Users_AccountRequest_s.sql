SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_Users_AccountRequest_s] (
	@Request_ID int
)
AS BEGIN

SET NOCOUNT ON

SELECT *, l.Culture,
			CASE WHEN EXISTS(SELECT * FROM Users WHERE PreferredUserName=UserName) THEN 0 ELSE 1 END AS CanUseRequestedName,
			CASE WHEN EXISTS(SELECT * FROM Users WHERE UserName=u.LastName + LEFT(u.FirstName, 1)) THEN 0 ELSE 1 END AS CanUseLastPlusInital,
			CASE WHEN EXISTS(SELECT * FROM Users WHERE UserName=u.FirstName + '.' + u.LastName) THEN 0 ELSE 1 END AS CanUseDottedJoin
FROM Users_AccountRequest u
INNER JOIN Language l
	ON u.StartLanguage=l.LangID
WHERE User_ID IS NULL AND Request_ID=@Request_ID

SET NOCOUNT OFF

END




GO
GRANT EXECUTE ON  [dbo].[sp_Users_AccountRequest_s] TO [web_user]
GO
