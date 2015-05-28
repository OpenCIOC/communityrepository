SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fn_Users_ManageExternalSystem_List](
	@User_ID int
)
RETURNS varchar(MAX) WITH EXECUTE AS CALLER
AS 
BEGIN

DECLARE	@returnStr	varchar(MAX)

SELECT @returnStr =  COALESCE(@returnStr + ',','') + CAST(SystemCode AS varchar)
	FROM dbo.Users_ManageExternalSystem ume
WHERE ume.[User_ID]=@User_ID

IF @returnStr = '' SET @returnStr = NULL
RETURN @returnStr
END

GO
