SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_Languages_l] 
AS
BEGIN
	SET NOCOUNT ON

	SELECT Culture, LanguageName, LanguageAlias, LCID, LangID, Active, ActiveRecord FROM [Language]
	
	SET NOCOUNT OFF
END

GO
GRANT EXECUTE ON  [dbo].[sp_Languages_l] TO [web_user]
GO
