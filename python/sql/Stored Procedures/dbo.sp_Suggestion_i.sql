SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_Suggestion_i] (
	@User_ID int,
	@Suggestion nvarchar(max),
	@ErrMsg nvarchar(500) OUTPUT
)
AS BEGIN

SET NOCOUNT ON

DECLARE	@Error		int
SET @Error = 0

DECLARE @SuggestionObjectName nvarchar(100),
		@UserObjectName nvarchar(100)

SET @SuggestionObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Suggestion')
SET @UserObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('User')


IF @Suggestion IS NULL BEGIN
	SET @Error = 10 -- Required
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @SuggestionObjectName, @SuggestionObjectName)
END ELSE IF @User_ID IS NULL BEGIN
	SET @Error = 10 -- Required
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @UserObjectName, @SuggestionObjectName)
END ELSE IF NOT EXISTS(SELECT * FROM Users WHERE User_ID=@User_ID) BEGIN
	SET @Error = 3 -- No record with id
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @User_ID, @UserObjectName)
END ELSE BEGIN
	INSERT INTO Suggestion (User_ID, Suggestion) VALUES (@User_ID, @Suggestion)
END

RETURN @Error

SET NOCOUNT OFF

END






GO
GRANT EXECUTE ON  [dbo].[sp_Suggestion_i] TO [web_user]
GO
