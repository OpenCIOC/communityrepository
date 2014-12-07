SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_Community_s_MoreInfo] 
	@CM_ID int
AS
BEGIN
	SET NOCOUNT ON

	SELECT	cm.CREATED_DATE, cm.CREATED_BY, cm.MODIFIED_DATE, cm.MODIFIED_BY,
			cmn.Name, cm.AlternativeArea, pst.ProvinceStateCountry, 
			(SELECT CM_ID, Name
				FROM Community_Name parent
				WHERE parent.CM_ID=cm.ParentCommunity
					AND parent.LangID=(SELECT TOP 1 LangID FROM Community_Name WHERE CM_ID=parent.CM_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
				FOR XML AUTO, TYPE) AS ParentCommunityName,
			(SELECT DISTINCT nm.Name
				FROM (
						SELECT alt.AltName AS Name
							FROM Community_AltName alt
							WHERE CM_ID=cm.CM_ID
						UNION ALL SELECT Name
							FROM Community_Name
						WHERE CM_ID=cm.CM_ID AND Name<>cmn.Name
					) nm
				ORDER BY nm.Name
				FOR XML AUTO, TYPE) AS OtherNames,
			(SELECT CM_ID, Name
				FROM Community_Name child
				WHERE LangID=(SELECT TOP 1 LangID FROM Community_Name WHERE CM_ID=child.CM_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
					AND EXISTS(SELECT * FROM Community WHERE CM_ID=child.CM_ID AND ParentCommunity=cm.CM_ID)
				ORDER BY Name
				FOR XML AUTO, TYPE) AS ChildCommunities,
			(SELECT CM_ID, Name
				FROM Community_Name search
				WHERE LangID=(SELECT TOP 1 LangID FROM Community_Name WHERE CM_ID=search.CM_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
					AND EXISTS(SELECT * FROM Community_AltAreaSearch WHERE CM_ID=cm.CM_ID AND Search_CM_ID=search.CM_ID)
				ORDER BY Name
				FOR XML AUTO, TYPE) AS SearchCommunities,
			(SELECT UserName, Initials
				FROM Users u
				WHERE u.Admin=1
					OR EXISTS(SELECT * FROM Users_ManageArea uma
						WHERE u.[User_ID]=uma.[User_ID] AND (uma.CM_ID=cm.CM_ID OR EXISTS(SELECT * FROM Community_ParentList cmpl WHERE cmpl.Parent_CM_ID=uma.CM_ID AND cmpl.CM_ID=cm.CM_ID)))
				ORDER BY UserName
				FOR XML AUTO, TYPE) AS Managers
	FROM Community cm
	INNER JOIN Community_Name cmn
		ON cm.CM_ID=cmn.CM_ID AND cmn.LangID=(SELECT TOP 1 LangID FROM Community_Name WHERE CM_ID=cm.CM_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	LEFT JOIN vw_ProvinceStateCountry pst
		ON cm.ProvinceState=pst.ProvID AND pst.LangID=(SELECT TOP 1 LangID FROM vw_ProvinceStateCountry WHERE ProvID=pst.ProvID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	WHERE cm.CM_ID=@CM_ID
	
	SET NOCOUNT OFF
END



GO
GRANT EXECUTE ON  [dbo].[sp_Community_s_MoreInfo] TO [web_user]
GO
