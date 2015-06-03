SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[sp_External_System_s] 
	@SystemCode varchar(30)
AS
BEGIN
	SET NOCOUNT ON

	SELECT * FROM External_System WHERE SystemCode=@SystemCode

	SET NOCOUNT OFF
END






GO
GRANT EXECUTE ON  [dbo].[sp_External_System_s] TO [web_user]
GO
