
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
		excm.EXT_ID AS [@ID],
		excm.EXT_GUID AS [@GUID],
		excm.AreaName AS [@AreaName],
		excm.ExternalID AS [@ExternalID],
		excm.PrimaryAreaType AS [@PrimaryAreaType],
		excm.SubAreaType AS [@SubAreaType],
		psc.NameOrCode AS [@Province],
		psc.Country AS [@Country],
		excm.AIRSExportType AS [@AIRSExportType],
		excm.Parent_ID AS [@Parent_ID]
	FOR XML PATH('MapEntry')) AS row
FROM External_Community excm
LEFT JOIN Community_Type pat
	ON pat.Code = excm.PrimaryAreaType
LEFT JOIN Community_Type_Name patn
	ON patn.Code = pat.Code AND patn.LangID=(SELECT TOP 1 LangID FROM Community_Type_Name WHERE pat.Code=Code ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
LEFT JOIN ProvinceState psc
	ON excm.ProvinceState=psc.ProvID
LEFT JOIN Community cm
	ON cm.CM_ID = excm.CM_ID
WHERE excm.SystemCode=@SystemCode

SELECT
	(SELECT
		[@GUID] = cm.CM_GUID,
		[@MapOne_EXT_ID] = cem.MapOneEXTID,
		[MapAll] = cem.MapAllEXTID
		FOR XML PATH('Community'), TYPE)
	FROM Community cm
	INNER JOIN dbo.Community_External_Map cem ON cem.CM_ID = cm.CM_ID
	ORDER BY cm.SortCode

SET NOCOUNT OFF

END






GO

GRANT EXECUTE ON  [dbo].[sp_External_Community_l_xml] TO [web_user]
GO
