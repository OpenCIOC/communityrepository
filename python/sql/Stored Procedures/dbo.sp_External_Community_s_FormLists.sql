
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[sp_External_Community_s_FormLists] 
AS
BEGIN
	SET NOCOUNT ON

	SELECT t.Code, tn.Name
	FROM Community_Type t
	INNER JOIN Community_Type_Name tn
		ON tn.Code = t.Code AND tn.LangID=(SELECT TOP 1 LangID FROM Community_Type_Name WHERE Code=t.Code ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	ORDER BY tn.Name

	SELECT ProvID, ProvinceStateCountry
	FROM dbo.vw_ProvinceStateCountry
	ORDER BY Country, ProvinceStateCountry

	SET NOCOUNT OFF
END






GO

GRANT EXECUTE ON  [dbo].[sp_External_Community_s_FormLists] TO [web_user]
GO
