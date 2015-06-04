
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[sp_External_Community_s] 
	@SystemCode varchar(30),
	@EXT_ID int
AS
BEGIN
	SET NOCOUNT ON

	SELECT	excm.*,
			cmn.Name AS CM_IDName,
			excm2.AreaName AS Parent_IDName
	FROM External_Community excm
	LEFT JOIN Community cm
		ON cm.CM_ID = excm.CM_ID
	LEFT JOIN Community_Name cmn
		ON cmn.CM_ID = cm.CM_ID AND cmn.LangID=(SELECT TOP 1 LangID FROM Community_Name WHERE cm.CM_ID=CM_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	LEFT JOIN External_Community excm2
		ON excm2.EXT_ID = excm.Parent_ID
	WHERE excm.SystemCode=@SystemCode AND excm.EXT_ID=@EXT_ID

	SET NOCOUNT OFF
END






GO

GRANT EXECUTE ON  [dbo].[sp_External_Community_s] TO [web_user]
GO
