SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_Community_Parents_l] 
	@CM_ID int
AS BEGIN

SET NOCOUNT ON

SELECT Parent_CM_ID
FROM Community_ParentList 
WHERE CM_ID=@CM_ID

SET NOCOUNT OFF

END





GO
GRANT EXECUTE ON  [dbo].[sp_Community_Parents_l] TO [web_user]
GO
