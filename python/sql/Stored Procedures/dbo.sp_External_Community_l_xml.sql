SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[sp_External_Community_l_xml] 
	@SystemCode varchar(30)
AS
BEGIN
	SET NOCOUNT ON

	SELECT	
	(SELECT
	excm.EXT_ID AS [@id],
			excm.AreaName AS [@AreaName],
		    excm.ExternalID AS [@ExternalID],
			excm.PrimaryAreaType AS [@PrimaryAreaType],
			excm.SubAreaType AS [@SubAreaType],
			psc.NameOrCode AS [@Province],
			psc.Country AS [@Country],
			excm.AIRSExportType AS [@AIRSExportType],
			cm.CM_GUID AS [@MappedGUID],
			excm2.AreaName AS [@ParentName],
			excm2.ExternalID AS [@ParentExternalID]
	FOR XML PATH('MapEntry')) AS row
	FROM External_Community excm
	LEFT JOIN External_Community excm2
		ON excm2.EXT_ID=excm.Parent_ID
	LEFT JOIN Community_Type pat
		ON pat.Code = excm.PrimaryAreaType
	LEFT JOIN Community_Type_Name patn
		ON patn.Code = pat.Code AND patn.LangID=(SELECT TOP 1 LangID FROM Community_Type_Name WHERE pat.Code=Code ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	LEFT JOIN ProvinceState psc
		ON excm.ProvinceState=psc.ProvID
	LEFT JOIN Community cm
		ON cm.CM_ID = excm.CM_ID
	WHERE excm.SystemCode=@SystemCode


	SET NOCOUNT OFF
END






GO
GRANT EXECUTE ON  [dbo].[sp_External_Community_l_xml] TO [web_user]
GO
