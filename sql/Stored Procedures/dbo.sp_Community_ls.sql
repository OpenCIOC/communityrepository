SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_Community_ls]
	@User_ID int,
	@searchStr nvarchar(100)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

SELECT DISTINCT cmn.CM_ID, cm.AlternativeArea,
		cmn.Name
			+ CASE WHEN cmn.Name LIKE '%' + @searchStr + '%' THEN '' ELSE ' [' + anm.AltName + ']' END
			+ CASE WHEN EXISTS(SELECT * FROM Community_Name cmn3 WHERE cmn3.CM_ID<>cm.CM_ID AND cmn.Name=cmn3.Name) AND pst.ProvinceStateCountry IS NOT NULL THEN ', ' + pst.ProvinceStateCountry ELSE '' END AS Display,
		cmn2.Name AS ParentCommunityName,
	CASE WHEN EXISTS(SELECT * FROM Users u
			WHERE u.[User_ID]=@User_ID AND (
				u.[Admin]=1 OR
				EXISTS(SELECT * FROM Users_ManageArea uma
					WHERE u.[User_ID]=uma.[User_ID] AND (uma.CM_ID=cm.CM_ID OR EXISTS(SELECT * FROM Community_ParentList cmpl WHERE cmpl.Parent_CM_ID=uma.CM_ID AND cmpl.CM_ID=cm.CM_ID))
				)
			)
		) THEN 1 ELSE 0 END AS CanEdit
	FROM Community cm
	INNER JOIN Community_Name cmn
		ON cm.CM_ID=cmn.CM_ID
			AND cmn.LangID=(SELECT TOP 1 LangID FROM Community_Name WHERE CM_ID=cm.CM_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	LEFT JOIN Community cm2
		ON cm.ParentCommunity = cm2.CM_ID
	LEFT JOIN Community_Name cmn2
		ON cm2.CM_ID=cmn2.CM_ID
			AND cmn2.LangID=(SELECT TOP 1 LangID FROM Community_Name WHERE CM_ID=cm2.CM_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	LEFT JOIN Community_AltName anm
		ON cm.CM_ID=anm.CM_ID AND anm.LangID=@@LANGID
	LEFT JOIN vw_ProvinceStateCountry pst
		ON cm.ProvinceState=pst.ProvID AND pst.LangID=(SELECT TOP 1 LangID FROM vw_ProvinceStateCountry WHERE ProvID=pst.ProvID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE cmn.Name LIKE '%' + @searchStr + '%'
	OR anm.AltName LIKE '%' + @searchStr + '%'
ORDER BY Display

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_Community_ls] TO [web_user]
GO
