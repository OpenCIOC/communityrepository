SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[sp_External_Community_d]
	@SystemCode varchar(30),
	@EXT_ID [int],
	@ErrMsg [nvarchar](500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

DECLARE	@Error	int
SET @Error = 0

DECLARE	@ExternalCommunityObjectName nvarchar(60)

SET @ExternalCommunityObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('External Community')

IF @EXT_ID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @ExternalCommunityObjectName, NULL)
END ELSE IF NOT EXISTS (SELECT EXT_ID FROM External_Community WHERE EXT_ID = @EXT_ID AND SystemCode=@SystemCode) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@EXT_ID AS varchar), @ExternalCommunityObjectName)
END ELSE BEGIN
		
	DELETE External_Community
	WHERE (EXT_ID = @EXT_ID AND SystemCode=@SystemCode)

	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @ExternalCommunityObjectName, @ErrMsg
	
END

RETURN @Error

SET NOCOUNT OFF





GO
GRANT EXECUTE ON  [dbo].[sp_External_Community_d] TO [web_user]
GO
