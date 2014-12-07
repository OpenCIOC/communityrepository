SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_User_LoginCheck] 
	-- Add the parameters for the stored procedure here
	@UserName nvarchar(50) 
AS
BEGIN
	SET NOCOUNT ON;

	SELECT [User_ID], UserName, StartLanguage, PasswordHash, PasswordHashRepeat, PasswordHashSalt, Inactive
	FROM Users WHERE UserName=@UserName
END


GO
GRANT EXECUTE ON  [dbo].[sp_User_LoginCheck] TO [web_user]
GO
