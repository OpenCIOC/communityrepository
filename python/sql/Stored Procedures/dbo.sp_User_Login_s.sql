
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_User_Login_s] 
	@UserName nvarchar(50) 
AS
BEGIN
	SET NOCOUNT ON

	SELECT [User_ID], UserName, FirstName, LastName, Initials, Email, [Admin], ManageAreaList, ManageExternalSystemList, Inactive, PasswordHash, PasswordHashRepeat, PasswordHashSalt
	FROM Users WHERE UserName=@UserName
	
	SET NOCOUNT OFF
END



GO

GRANT EXECUTE ON  [dbo].[sp_User_Login_s] TO [web_user]
GO
