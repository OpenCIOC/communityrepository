SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_Community_u]
	@CM_ID [int] OUTPUT,
	@User_ID int,
	@AlternativeArea bit,
	@ParentCommunity [int],
	@ProvinceState [int],
	@ReasonForChange nvarchar(max),
	@Descriptions [xml],
	@AltNames [xml],
	@AltSearchAreas [xml],
	@ErrMsg [nvarchar](500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

DECLARE	@Error		int
SET @Error = 0

DECLARE	@CommunityObjectName nvarchar(100),
		@LanguageObjectName nvarchar(100),
		@NameObjectName nvarchar(100),
		@ParentObjectName nvarchar(100),
		@ProvinceStateObjectName nvarchar(100)

SET @CommunityObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Community')
SET @LanguageObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Language')
SET @NameObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Name')
SET @ParentObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Parent Community')
SET @ProvinceStateObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Province/State')


DECLARE @DescTable TABLE (
	Culture varchar(5) NOT NULL,
	LangID smallint NULL,
	Name nvarchar(200) NULL/*,
	Display nvarchar(200) NULL*/
)

DECLARE @AltNamesTable TABLE (
	Culture varchar(5) NOT NULL,
	LangID smallint NULL,
	AltName nvarchar(200) NULL
)

DECLARE @AltSearchAreasTable TABLE (
	CM_ID int NOT NULL
)

DECLARE @MODIFIED_BY nvarchar(50),
		@UsedNames nvarchar(max),
		@BadCultures nvarchar(max),
		@BadAltNameCultures nvarchar(max)
		
SELECT @MODIFIED_BY=UserName FROM Users WHERE User_ID=@User_ID

INSERT INTO @DescTable (
	Culture,
	LangID,
	Name/*,
	Display*/
)
SELECT
	N.value('Culture[1]', 'varchar(5)') AS Culture,
	(SELECT LangID FROM Language sl WHERE sl.Culture = N.value('Culture[1]', 'varchar(5)') AND Active/*Record*/=1) AS LangID,
	N.value('Name[1]', 'nvarchar(200)') AS Name/*,
	N.value('Display[1]', 'nvarchar(200)') AS Display*/
FROM @Descriptions.nodes('//DESC') as T(N)

SELECT @UsedNames = COALESCE(@UsedNames + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + Name
FROM @DescTable nt
WHERE EXISTS(SELECT * FROM Community_Name cmn WHERE Name=nt.Name AND LangID=nt.LangID AND ISNULL(cmn.ProvinceStateCache, -1)=ISNULL(@ProvinceState, -1) AND (cmn.CM_ID<>@CM_ID or @CM_ID IS NULL))

SELECT @BadCultures = COALESCE(@BadCultures + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + ISNULL(Culture,cioc_shared.dbo.fn_SHR_STP_ObjectName('Unknown'))
FROM @DescTable nt
WHERE LangID IS NULL

INSERT INTO @AltNamesTable (
	Culture,
	LangID,
	AltName
)
SELECT DISTINCT
	N.value('Culture[1]', 'varchar(5)') AS Culture,
	(SELECT LangID FROM Language sl WHERE sl.Culture = N.value('Culture[1]', 'varchar(5)') AND Active/*Record*/=1) AS LangID,
	N.value('AltName[1]', 'nvarchar(200)') AS AltName
FROM @AltNames.nodes('//Name') as T(N)

SELECT @BadAltNameCultures = COALESCE(@BadAltNameCultures + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + ISNULL(Culture,cioc_shared.dbo.fn_SHR_STP_ObjectName('Unknown'))
FROM @AltNamesTable nt
WHERE LangID IS NULL

IF @AlternativeArea = 1 BEGIN
	INSERT INTO @AltSearchAreasTable (
		CM_ID
	)
	SELECT DISTINCT
	N.value('.', 'int') AS CM_ID
	FROM @AltSearchAreas.nodes('//CM_ID') AS T(N)
END

IF @CM_ID IS NOT NULL AND NOT EXISTS (SELECT * FROM Community WHERE CM_ID=@CM_ID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@CM_ID AS varchar), @CommunityObjectName)
END IF  @ParentCommunity IS NOT NULL AND NOT EXISTS(SELECT * FROM Community WHERE CM_ID=@ParentCommunity) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@CM_ID AS varchar), @ParentObjectName)
END IF @ProvinceState IS NOT NULL AND NOT EXISTS(SELECT * FROM ProvinceState WHERE ProvID=@ProvinceState) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@ProvinceState AS varchar), @ProvinceStateObjectName)
END ELSE IF NOT EXISTS(SELECT * FROM @DescTable WHERE Name IS NOT NULL) BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @NameObjectName, @CommunityObjectName)
END ELSE IF @UsedNames IS NOT NULL BEGIN
	SET @Error = 6 -- Value In Use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @UsedNames, @NameObjectName)
END ELSE IF NOT EXISTS(SELECT * FROM @DescTable) BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @LanguageObjectName, @CommunityObjectName)
END ELSE IF @BadCultures IS NOT NULL BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @BadCultures, @LanguageObjectName)
END ELSE IF @BadAltNameCultures IS NOT NULL BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @BadAltNameCultures, @LanguageObjectName)
END

IF @Error = 0 BEGIN
	DECLARE @FormerName nvarchar(200), @TypeOfChange bit
	
	IF @CM_ID IS NULL BEGIN
		SET @FormerName = NULL
		SET @TypeOfChange = 1
	END ELSE BEGIN
		SELECT TOP 1 @FormerName = Name
		FROM Community_Name cmn
		WHERE CM_ID=@CM_ID 
		ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID
		SET @TypeOfChange = NULL
	END
		
	
	IF @CM_ID IS NULL BEGIN
		INSERT INTO Community (
			CREATED_DATE,
			CREATED_BY,
			MODIFIED_DATE,
			MODIFIED_BY,
			ParentCommunity,
			ProvinceState,
			AlternativeArea
		) VALUES (
			GETDATE(),
			@MODIFIED_BY,
			GETDATE(),
			@MODIFIED_BY,
			@ParentCommunity,
			@ProvinceState,
			@AlternativeArea
		)
		SELECT @CM_ID = SCOPE_IDENTITY()
	END ELSE BEGIN
		UPDATE Community
		SET	MODIFIED_DATE	= GETDATE(),
			MODIFIED_BY		= @MODIFIED_BY,
			ParentCommunity	= @ParentCommunity,
			ProvinceState	= @ProvinceState
		WHERE CM_ID = @CM_ID	
	END
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @CommunityObjectName, @ErrMsg
	

	IF @Error=0 AND @CM_ID IS NOT NULL BEGIN
		MERGE INTO Community_Name cmn
		USING @DescTable nt
			ON cmn.CM_ID=@CM_ID AND cmn.LangID=nt.LangID
		WHEN MATCHED AND cmn.ProvinceStateCache<>@ProvinceState OR cmn.Name<>nt.Name COLLATE Latin1_General_100_CS_AS /*,
					cmn.Display<>nt.Display COLLATE Latin1_General_100_CS_AS */
			THEN UPDATE SET ProvinceStateCache=@ProvinceState, Name=nt.Name /*, Display=nt.Display */
		
		WHEN NOT MATCHED BY TARGET 
			THEN INSERT (CM_ID, LangID, ProvinceStateCache, Name)
				VALUES (@CM_ID, nt.LangID, @ProvinceState, nt.Name)
		
		WHEN NOT MATCHED BY SOURCE AND cmn.CM_ID=@CM_ID
			THEN DELETE
			
			;
		
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @CommunityObjectName, @ErrMsg
		
		
		MERGE INTO Community_AltName cma
		USING @AltNamesTable nt
			ON cma.CM_ID=@CM_ID AND cma.LangID=nt.LangID AND cma.AltName=nt.AltName
			
		WHEN MATCHED AND cma.AltName<>nt.AltName COLLATE Latin1_General_100_CS_AS
			THEN UPDATE SET cma.AltName = nt.AltName
			
		WHEN NOT MATCHED BY TARGET
			THEN INSERT  (CM_ID, LangID, AltName) 
				VALUES (@CM_ID, nt.LangID, nt.AltName)
				
		WHEN NOT MATCHED BY SOURCE AND cma.CM_ID=@CM_ID
			THEN DELETE
			
			;
			
		IF @AlternativeArea = 1 BEGIN
			
			MERGE INTO Community_AltAreaSearch aas
			USING @AltSearchAreasTable nt
				ON aas.CM_ID=@CM_ID AND aas.Search_CM_ID=nt.CM_ID
			WHEN NOT MATCHED BY TARGET 
				THEN INSERT (CM_ID, Search_CM_ID) 
					VALUES (@CM_ID, nt.CM_ID)
			WHEN NOT MATCHED BY SOURCE AND aas.CM_ID=@CM_ID
				THEN DELETE
				
				;
			
		END
		
	END
	
	IF @Error=0 AND @CM_ID IS NOT NULL BEGIN
		DECLARE @CM_GUID uniqueidentifier, 
				@CurrentName nvarchar(200)
		SELECT @CM_GUID=CM_GUID FROM Community WHERE CM_ID=@CM_ID
		SELECT TOP 1 @CurrentName = Name 
		FROM Community_Name
		WHERE CM_ID=@CM_ID
		ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID
		
		
		INSERT INTO Community_ChangeHistory 
			(CM_ID, CM_GUID, FormerName, CurrentName, ChangeComment, MODIFIED_BY, MODIFIED_DATE, TypeOfChange)
		VALUES
			(@CM_ID, @CM_GUID, @FormerName, @CurrentName, @ReasonForChange, @MODIFIED_BY, GETDATE(), @TypeOfChange)
	END
END

RETURN @Error

SET NOCOUNT OFF











GO
GRANT EXECUTE ON  [dbo].[sp_Community_u] TO [web_user]
GO
