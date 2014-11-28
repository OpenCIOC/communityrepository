SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_Users_ManageArea_List](
	@User_ID int
)
RETURNS varchar(max) WITH EXECUTE AS CALLER
AS 
BEGIN

DECLARE	@returnStr	varchar(max)

SELECT @returnStr =  COALESCE(@returnStr + ',','') + CAST(CM_ID AS varchar)
	FROM Users_ManageArea uma
WHERE uma.[User_ID]=@User_ID

IF @returnStr = '' SET @returnStr = NULL
RETURN @returnStr
END

GO
