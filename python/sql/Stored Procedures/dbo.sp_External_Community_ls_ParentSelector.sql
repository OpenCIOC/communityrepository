
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

SELECT excm.EXT_ID, 
	excm.AreaName, 
	excm.AreaName 
		+ CASE WHEN EXISTS(SELECT * FROM External_Community excm3 WHERE excm3.EXT_ID<>excm.EXT_ID AND excm3.SystemCode=excm.SystemCode AND excm3.AreaName=excm.AreaName) AND pst.ProvinceStateCountry IS NOT NULL THEN ', ' + pst.ProvinceStateCountry ELSE '' END AS Display,
	excm2.AreaName AS ParentCommunityName
FROM External_Community excm
LEFT JOIN vw_ProvinceStateCountry pst
		ON excm.ProvinceState=pst.ProvID AND pst.LangID=(SELECT TOP 1 LangID FROM vw_ProvinceStateCountry WHERE ProvID=pst.ProvID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
LEFT JOIN External_Community excm2
	ON excm2.EXT_ID=excm.Parent_ID
WHERE excm.SystemCode = @SystemCode AND excm.AreaName LIKE '%' + @searchStr + '%'
AND (@EXT_ID IS NULL OR excm.EXT_ID<>@EXT_ID)

ORDER BY excm.AreaName

SET NOCOUNT OFF

END



GO

GRANT EXECUTE ON  [dbo].[sp_External_Community_ls_ParentSelector] TO [web_user]
GO
