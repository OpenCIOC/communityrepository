SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_Community_ls_Names]
	@CMList varchar(MAX)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

SELECT DISTINCT cm.CM_ID,
		cmn.Name,
		cmn.Name
			+ CASE WHEN EXISTS(SELECT * FROM Community_Name cmn3 WHERE cmn3.CM_ID<>cm.CM_ID AND cmn.Name=cmn3.Name) AND pst.ProvinceStateCountry IS NOT NULL THEN ', ' + pst.ProvinceStateCountry ELSE '' END AS Display
	FROM Community cm
	INNER JOIN Community_Name cmn
		ON cm.CM_ID=cmn.CM_ID
			AND cmn.LangID=(SELECT TOP 1 LangID FROM Community_Name WHERE CM_ID=cm.CM_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	LEFT JOIN vw_ProvinceStateCountry pst
		ON cm.ProvinceState=pst.ProvID AND pst.LangID=(SELECT TOP 1 LangID FROM vw_ProvinceStateCountry WHERE ProvID=pst.ProvID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	INNER JOIN dbo.fn_ParseIntIDList(@CMList, ',') t
		ON cm.CM_ID=t.ItemID
ORDER BY Display

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_Community_ls_Names] TO [web_user]
GO
