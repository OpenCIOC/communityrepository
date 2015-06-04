SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[sp_External_Community_ls_ParentSelector] (
	@SystemCode varchar(30),
	@EXT_ID int,
	@searchStr nvarchar(100)
)
AS BEGIN

SET NOCOUNT ON

SELECT excm.EXT_ID, excm.AreaName, excm.AreaName
FROM External_Community excm
WHERE SystemCode = @SystemCode AND AreaName LIKE '%' + @searchStr + '%'
AND (@EXT_ID IS NULL OR EXT_ID<>@EXT_ID)

ORDER BY excm.AreaName

SET NOCOUNT OFF

END



GO
GRANT EXECUTE ON  [dbo].[sp_External_Community_ls_ParentSelector] TO [web_user]
GO
