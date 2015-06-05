
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_External_Community_l] 
	@SystemCode varchar(30)
AS
BEGIN
	SET NOCOUNT ON

	SELECT	excm.EXT_ID,
			excm.AreaName,
		    excm.ExternalID,
			patn.Name AS PrimaryAreaTypeName,
			-- satn.Name AS SubAreaTypeName,
			psc.ProvinceStateCountry,
			cmn.Name AS MappedCommunityName,
			--pst.ProvinceStateCountry AS MappedProvinceStateCountry,
			cmn2.Name AS MappedParentCommunityName,
			excm2.AreaName AS ParentName,
			excm.AIRSExportType,
			CAST(CASE WHEN EXISTS(SELECT * FROM dbo.External_Community ec2 WHERE excm.EXT_ID<>ec2.EXT_ID AND excm.CM_ID=ec2.CM_ID) THEN 1 ELSE 0 END AS bit) AS DuplicateWarning
	FROM External_Community excm
	LEFT JOIN External_Community excm2
		ON excm2.EXT_ID=excm.Parent_ID
	LEFT JOIN Community_Type pat
		ON pat.Code = excm.PrimaryAreaType
	LEFT JOIN Community_Type_Name patn
		ON patn.Code = pat.Code AND patn.LangID=(SELECT TOP 1 LangID FROM Community_Type_Name WHERE pat.Code=Code ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
		/*
	LEFT JOIN Community_Type sat
		ON sat.Code = excm.SubAreaType
	LEFT JOIN Community_Type_Name satn
		ON satn.Code = sat.Code AND satn.LangID=(SELECT TOP 1 LangID FROM Community_Type_Name WHERE sat.Code=Code ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
		*/
	LEFT JOIN dbo.vw_ProvinceStateCountry psc
		ON excm.ProvinceState=psc.ProvID
	LEFT JOIN Community cm
		ON cm.CM_ID = excm.CM_ID
	LEFT JOIN Community_Name cmn
		ON cmn.CM_ID = cm.CM_ID AND cmn.LangID=(SELECT TOP 1 LangID FROM Community_Name WHERE cm.CM_ID=CM_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	LEFT JOIN Community cm2
		ON cm.ParentCommunity = cm2.CM_ID
	LEFT JOIN Community_Name cmn2
		ON cm2.CM_ID=cmn2.CM_ID
			AND cmn2.LangID=(SELECT TOP 1 LangID FROM Community_Name WHERE CM_ID=cm2.CM_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
			/*
	LEFT JOIN vw_ProvinceStateCountry pst
		ON cm.ProvinceState=pst.ProvID AND pst.LangID=(SELECT TOP 1 LangID FROM vw_ProvinceStateCountry WHERE ProvID=pst.ProvID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
		*/
	WHERE excm.SystemCode=@SystemCode
	ORDER BY excm.SortCode, AreaName

	SET NOCOUNT OFF
END





GO


GRANT EXECUTE ON  [dbo].[sp_External_Community_l] TO [web_user]
GO
