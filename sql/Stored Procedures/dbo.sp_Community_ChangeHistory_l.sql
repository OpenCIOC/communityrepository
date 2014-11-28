SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_Community_ChangeHistory_l]
	@NewerThan smalldatetime = NULL
AS BEGIN

SET NOCOUNT ON

SELECT * 
FROM Community_ChangeHistory 
WHERE @NewerThan IS NULL OR @NewerThan <= MODIFIED_DATE
ORDER BY MODIFIED_DATE DESC

SET NOCOUNT OFF

END







GO
GRANT EXECUTE ON  [dbo].[sp_Community_ChangeHistory_l] TO [web_user]
GO
