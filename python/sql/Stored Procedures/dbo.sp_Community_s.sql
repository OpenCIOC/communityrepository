
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_Community_s] 
	@CM_ID int,
	@OnlyStatus bit = 0
AS
BEGIN
	SET NOCOUNT ON

	SELECT	*,
		(SELECT cmn.CM_ID, cmn.Name
		 FROM Community cm2
		INNER JOIN Community_Name cmn
			ON cm2.CM_ID=cmn.CM_ID AND LangID=(SELECT TOP 1 LangID FROM Community_Name WHERE CM_ID=cmn.CM_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
			WHERE ParentCommunity=@CM_ID
		FOR XML AUTO, TYPE) AS ChildCommunities,
		(SELECT cmn.Name
		 FROM Community_Name cmn
		 WHERE CM_ID=ParentCommunity AND 
			LangID=(SELECT TOP 1 LangID FROM Community_Name WHERE CM_ID=cmn.CM_ID 
					ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
				) AS ParentCommunityName,
		(SELECT cmn.CM_ID, cmn.Name
		 FROM Community_AltAreaSearch cm2
		INNER JOIN Community_Name cmn
			ON cm2.CM_ID=cmn.CM_ID AND LangID=(SELECT TOP 1 LangID FROM Community_Name WHERE CM_ID=cmn.CM_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
			WHERE Search_CM_ID=@CM_ID
		FOR XML AUTO, TYPE) AS AltSearchArea
		FROM Community cm
		WHERE CM_ID=@CM_ID
		
	SELECT Parent_CM_ID
	FROM Community_ParentList 
	WHERE CM_ID=@CM_ID
		
	IF @OnlyStatus = 0 BEGIN
	SELECT cmn.*,
		(SELECT Culture FROM Language WHERE LangID=cmn.LangID) AS Culture
	FROM Community_Name cmn
	WHERE CM_ID=@CM_ID
	
	SELECT an.*, l.Culture
	FROM Community_AltName an
	INNER JOIN Language l
		ON an.LangID=l.LangID
	WHERE CM_ID=@CM_ID
	ORDER BY CASE WHEN an.LangID=@@LANGID THEN 0 ELSE 1 END, LangID, AltName
	
	SELECT Search_CM_ID, cmn.Name 
	FROM Community_AltAreaSearch aas
		INNER JOIN Community_Name cmn
			ON cmn.CM_ID=aas.Search_CM_ID AND LangID=(SELECT TOP 1 LangID FROM Community_Name WHERE CM_ID=cmn.CM_ID 
												ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	WHERE aas.CM_ID=@CM_ID
	ORDER BY cmn.Name
	
	END
	
	SET NOCOUNT OFF
END








GO

GRANT EXECUTE ON  [dbo].[sp_Community_s] TO [web_user]
GO
