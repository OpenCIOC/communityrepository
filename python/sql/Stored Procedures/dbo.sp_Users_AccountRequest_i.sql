SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_Users_AccountRequest_i] (
	@Request_ID int OUTPUT,
	@UserName varchar(50),
	@Culture varchar(5),
	@FirstName varchar(50),
	@LastName varchar(50),
	@Initials varchar(6),
	@Organization varchar(200),
	@Email varchar(60),
	@ManageAreaRequest bit,
	@ManageAreaDetail varchar(max),
	@ErrMsg nvarchar(500) OUTPUT
)
AS BEGIN

SET NOCOUNT ON

DECLARE	@Error		int
SET @Error = 0

DECLARE	@UserObjectName nvarchar(100),
		@LanguageObjectName nvarchar(100),
		@NameObjectName nvarchar(100),
		@ParentObjectName nvarchar(100),
		@ProvinceStateObjectName nvarchar(100)

SET @UserObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('User')
SET @LanguageObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Language')
SET @NameObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Name')

DECLARE @StartLanguage smallint
SELECT @StartLanguage = LangID FROM Language WHERE @Culture=Culture AND Active=1

IF @StartLanguage IS NULL BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @Culture, @LanguageObjectName)
END ELSE IF EXISTS(SELECT * FROM Users WHERE  @UserName=UserName) BEGIN
	SET @Error = 6 -- Value in Use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @UserName, @NameObjectName)
END ELSE IF EXISTS(SELECT * FROM Users WHERE @Initials=Initials) BEGIN
	SET @Error = 6 -- Value in Use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @Initials, cioc_shared.dbo.fn_SHR_STP_ObjectName('Initials'))
END ELSE BEGIN
		INSERT INTO Users_AccountRequest (
			REQUEST_DATE,
			PreferredUserName,
			StartLanguage,
			FirstName,
			LastName,
			Initials,
			Organization,
			Email,
			ManageAreaRequest,
			ManageAreaDetail
		) VALUES (
			GETDATE(),
			@UserName,
			@StartLanguage,
			@FirstName,
			@LastName,
			@Initials,
			@Organization,
			@Email,
			@ManageAreaRequest,
			@ManageAreaDetail
		)
		SET @Request_ID = SCOPE_IDENTITY()
END 

RETURN @Error

SET NOCOUNT OFF

END





GO
GRANT EXECUTE ON  [dbo].[sp_Users_AccountRequest_i] TO [web_user]
GO
