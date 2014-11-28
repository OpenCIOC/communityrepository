SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_Community_d]
	@CM_ID [int],
	@MODIFIED_BY varchar(50),
	@ReasonForChange nvarchar(max),
	@ErrMsg [nvarchar](500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

DECLARE	@Error	int
SET @Error = 0

DECLARE	@CommunityObjectName nvarchar(60)

SET @CommunityObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Community')

IF @CM_ID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @CommunityObjectName, NULL)
END ELSE IF NOT EXISTS (SELECT CM_ID FROM Community WHERE CM_ID = @CM_ID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@CM_ID AS varchar), @CommunityObjectName)
END ELSE IF EXISTS(SELECT * FROM Community WHERE ParentCommunity=@CM_ID) BEGIN
	SET @Error = 7 -- Can't delete value in use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @CommunityObjectName, @CommunityObjectName)
END ELSE IF EXISTS(SELECT * FROM Community_AltAreaSearch WHERE Search_CM_ID=@CM_ID) BEGIN
	SET @Error = 7 -- Can't delete value in use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @CommunityObjectName, @CommunityObjectName)
END ELSE BEGIN
	DECLARE @FormerName nvarchar(200), @CM_GUID uniqueidentifier 
	SELECT TOP 1 @FormerName = Name, @CM_GUID=CM_GUID
	FROM Community_Name cmn
	INNER JOIN Community cm
		ON cm.CM_ID=cmn.CM_ID
	WHERE cm.CM_ID=@CM_ID 
	ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID
		
	DELETE Community
	WHERE (CM_ID = @CM_ID)
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @CommunityObjectName, @ErrMsg
	
	
	INSERT INTO Community_ChangeHistory 
		(CM_ID, CM_GUID, FormerName, CurrentName, ChangeComment, MODIFIED_BY, MODIFIED_DATE, TypeOfChange)
	VALUES
		(NULL, @CM_GUID, @FormerName, NULL, @ReasonForChange, @MODIFIED_BY, GETDATE(), 0)
END
			
			

RETURN @Error

SET NOCOUNT OFF




GO
GRANT EXECUTE ON  [dbo].[sp_Community_d] TO [web_user]
GO
