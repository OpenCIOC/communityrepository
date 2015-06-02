
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_Users_u] (
	@User_ID int OUTPUT,
	@MODIFIED_BY varchar(50),
	@UserName varchar(50),
	@Culture varchar(5),
	@FirstName varchar(50),
	@LastName varchar(50),
	@Initials varchar(6),
	@Organization varchar(200),
	@Email varchar(60),
	@PasswordHashRepeat int,
	@PasswordHashSalt char(44),
	@PasswordHash char(44),
	@ErrMsg nvarchar(500) OUTPUT,
	@ManageAreas xml = NULL,
	@ManageExternalSystems xml = NULL,
	@Admin bit = NULL,
	@Inactive bit = NULL,
	@Request_ID int = NULL
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

DECLARE @ManageAreasTable TABLE (
	CM_ID int NOT NULL PRIMARY KEY
)

IF @ManageAreas IS NOT NULL BEGIN
	INSERT INTO @ManageAreasTable (
		CM_ID
	)
	SELECT DISTINCT
	N.value('.', 'int') AS CM_ID
	FROM @ManageAreas.nodes('//CM_ID') AS T(N)
	INNER JOIN dbo.Community cm ON N.value('.', 'int') = cm.CM_ID
END

DECLARE @ManageSystemsTable TABLE (
	SystemCode varchar(30) NOT NULL PRIMARY KEY
)

IF @ManageExternalSystems IS NOT NULL BEGIN
	INSERT INTO @ManageSystemsTable
	        ( SystemCode )
	SELECT DISTINCT
	N.value('.', 'varchar(30)') AS SystemCode
	FROM @ManageExternalSystems.nodes('//SystemCode') AS T(N)
	INNER JOIN dbo.External_System es ON N.value('.', 'varchar(30)') = es.SystemCode
END

IF @StartLanguage IS NULL BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @Culture, @LanguageObjectName)
END ELSE IF EXISTS(SELECT * FROM Users WHERE (@User_ID IS NULL OR @User_ID<>User_ID) AND @UserName=UserName) BEGIN
	SET @Error = 6 -- Value in Use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @UserName, @NameObjectName)
END ELSE IF EXISTS(SELECT * FROM Users WHERE (@User_ID IS NULL OR @User_ID<>User_ID) AND @Initials=Initials) BEGIN
	SET @Error = 6 -- Value in Use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @Initials, cioc_shared.dbo.fn_SHR_STP_ObjectName('Initials'))
END ELSE BEGIN
	IF @User_ID IS NULL BEGIN
		INSERT INTO Users (
			CREATED_DATE,
			CREATED_BY,
			MODIFIED_DATE,
			MODIFIED_BY,
			UserName,
			StartLanguage,
			FirstName,
			LastName,
			Initials,
			Organization,
			Email,
			PasswordHashRepeat,
			PasswordHashSalt,
			PasswordHash,
			Admin,
			Inactive
		) VALUES (
			GETDATE(),
			@MODIFIED_BY,
			GETDATE(),
			@MODIFIED_BY,
			@UserName,
			@StartLanguage,
			@FirstName,
			@LastName,
			@Initials,
			@Organization,
			@Email,
			@PasswordHashRepeat,
			@PasswordHashSalt,
			@PasswordHash,
			@Admin,
			0
		)
		SET @User_ID = SCOPE_IDENTITY()
		IF @Request_ID IS NOT NULL BEGIN
			UPDATE Users_AccountRequest SET
				User_ID=@User_ID, REJECTED_DATE=NULL, REJECTED_BY=NULL
			WHERE @Request_ID=Request_ID
		END
	END ELSE BEGIN
		UPDATE Users SET
			MODIFIED_DATE=GETDATE(),
			MODIFIED_BY=@MODIFIED_BY,
			UserName=@UserName,
			StartLanguage=@StartLanguage,
			FirstName=@FirstName,
			LastName=@LastName,
			Initials=@Initials,
			Organization=@Organization,
			Email=@Email,
			PasswordHashRepeat=ISNULL(@PasswordHashRepeat, PasswordHashRepeat),
			PasswordHashSalt=ISNULL(@PasswordHashSalt, PasswordHashSalt),
			PasswordHash=ISNULL(@PasswordHash, PasswordHash),
			Admin=ISNULL(@Admin, Admin),
			Inactive=ISNULL(@Inactive, Inactive)
		WHERE User_ID=@User_ID
	END
	
	IF @ManageAreas IS NOT NULL BEGIN
		MERGE INTO Users_ManageArea ma
		USING (SELECT CM_ID FROM @ManageAreasTable mat
				WHERE EXISTS(SELECT * FROM Community WHERE mat.CM_ID=CM_ID)) nt
			ON ma.User_ID=@User_ID AND ma.CM_ID=nt.CM_ID
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (User_ID, CM_ID) VALUES (@User_ID, nt.CM_ID)
		WHEN NOT MATCHED BY SOURCE AND ma.User_ID=@User_ID THEN
			DELETE
			;
	END
	
	IF @ManageExternalSystems IS NOT NULL BEGIN
		MERGE INTO dbo.Users_ManageExternalSystem me
		USING (SELECT SystemCode FROM @ManageSystemsTable met
				WHERE EXISTS(SELECT * FROM dbo.External_System WHERE met.SystemCode=SystemCode)) nt
			ON me.SystemCode=nt.SystemCode AND me.User_ID=@User_ID
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (User_ID, SystemCode) VALUES (@User_ID, nt.SystemCode)
		WHEN NOT MATCHED BY SOURCE AND me.User_ID=@User_ID THEN
			DELETE	
			;
	END
END 

SET NOCOUNT OFF

END





GO


GRANT EXECUTE ON  [dbo].[sp_Users_u] TO [web_user]
GO
