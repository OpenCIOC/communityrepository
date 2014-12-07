SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_Suggestion_u_Complete] (
	@Suggest_ID int,
	@UserName varchar(50),
	@ErrMsg nvarchar(500) OUTPUT
)
AS BEGIN

SET NOCOUNT ON

DECLARE @Error int
SET @Error = 0

DECLARE @SuggestionObjectName nvarchar(100)

SET @SuggestionObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Suggestion')

IF @Suggest_ID IS NULL BEGIN
	SET @Error = 2 -- No Id Provided
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @SuggestionObjectName, NULL)
END ELSE IF NOT EXISTS(SELECT * FROM Suggestion WHERE Suggest_ID=@Suggest_ID) BEGIN
	SET @Error = 3 -- No record with id
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@Suggest_ID AS varchar(20)), @SuggestionObjectName)
END ELSE BEGIN
	UPDATE Suggestion SET COMPLETED_DATE=GETDATE(), COMPLETED_BY=@UserName
	WHERE Suggest_ID=@Suggest_ID
END

RETURN @Error

SET NOCOUNT OFF

END

GO
GRANT EXECUTE ON  [dbo].[sp_Suggestion_u_Complete] TO [web_user]
GO
