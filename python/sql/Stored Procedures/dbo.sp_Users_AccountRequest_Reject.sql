SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[sp_Users_AccountRequest_Reject]
	@Request_ID [int],
	@MODIFIED_BY varchar(50),
	@ErrMsg [nvarchar](500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

DECLARE	@Error	int
SET @Error = 0

DECLARE	@AccountRequestObjectName nvarchar(60)

SET @AccountRequestObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Account Request')

IF @Request_ID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @AccountRequestObjectName, NULL)
END ELSE IF NOT EXISTS (SELECT Request_ID FROM Users_AccountRequest WHERE Request_ID = @Request_ID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@Request_ID AS varchar), @AccountRequestObjectName)
END ELSE BEGIN
	UPDATE Users_AccountRequest
		SET REJECTED_BY = @MODIFIED_BY,
			REJECTED_DATE = GETDATE()
	WHERE Request_ID = @Request_ID
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @AccountRequestObjectName, @ErrMsg
END
			
			

RETURN @Error

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_Users_AccountRequest_Reject] TO [web_user]
GO
