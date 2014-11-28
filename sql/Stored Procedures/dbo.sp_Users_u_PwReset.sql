SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[sp_Users_u_PwReset] (
	@UserName varchar(50),
	@PasswordHashRepeat int,
	@PasswordHashSalt char(44),
	@PasswordHash char(44)
)
AS BEGIN

SET NOCOUNT ON

DECLARE	@Error		int
SET @Error = 0

UPDATE Users
	SET PasswordHashRepeat = @PasswordHashRepeat,
		PasswordHashSalt = @PasswordHashSalt,
		PasswordHash = @PasswordHash
	WHERE UserName=@UserName
	
SELECT FirstName, Email, l.Culture
FROM Users u
INNER JOIN Language l
	ON u.StartLanguage=l.LangID
WHERE u.UserName=@UserName

RETURN @Error

SET NOCOUNT OFF

END






GO
GRANT EXECUTE ON  [dbo].[sp_Users_u_PwReset] TO [web_user]
GO
