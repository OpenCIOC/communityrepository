
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_External_Community_u]
	@SystemCode varchar(30),
	@EXT_ID [int] OUTPUT,
	@AreaName nvarchar(200),
	@PrimaryAreaType varchar(30),
	@SubAreaType varchar(30),
	@ProvinceState int,
	@ExternalID varchar(50),
	@AIRSExportType varchar(20),
	@Parent_ID int,
	@CM_ID int,
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
		@ProvinceStateObjectName nvarchar(100),
		@PrimaryAreaTypeObjectName nvarchar(100),
		@SubAreaTypeObjectName nvarchar(100),
		@ExternalCommunityObjectName nvarchar(100),
		@AIRSExportTypeObjectName nvarchar(100)

SET @CommunityObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Community')
SET @LanguageObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Language')
SET @NameObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Name')
SET @ParentObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Parent Community')
SET @ProvinceStateObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Province/State')
SET @PrimaryAreaTypeObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Primary Area Type')
SET @SubAreaTypeObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Sub Area Type')
SET @ExternalCommunityObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('External Community')
SET @AIRSExportTypeObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('External Community')

IF @EXT_ID IS NOT NULL AND NOT EXISTS (SELECT * FROM External_Community WHERE EXT_ID=@EXT_ID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@EXT_ID AS varchar), @ExternalCommunityObjectName)
END IF  @CM_ID IS NOT NULL AND NOT EXISTS(SELECT * FROM Community WHERE CM_ID=@CM_ID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@CM_ID AS varchar), @CommunityObjectName)
END IF @ProvinceState IS NOT NULL AND NOT EXISTS(SELECT * FROM ProvinceState WHERE ProvID=@ProvinceState) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@ProvinceState AS varchar), @ProvinceStateObjectName)
END IF @AreaName IS NULL BEGIN
	SET @Error = 10 -- Required Field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @NameObjectName, @ExternalCommunityObjectName)
END IF @PrimaryAreaType IS NOT NULL AND NOT EXISTS(SELECT * FROM Community_Type WHERE Code=@PrimaryAreaType) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@PrimaryAreaType AS varchar), @PrimaryAreaTypeObjectName)
END IF @SubAreaType IS NOT NULL AND NOT EXISTS(SELECT * FROM Community_Type WHERE Code=@SubAreaType) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@SubAreaType AS varchar), @SubAreaTypeObjectName)
END IF @AIRSExportType IS NOT NULL AND NOT EXISTS(SELECT * FROM AIRSExportType WHERE AIRSExportType=@AIRSExportType) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@AIRSExportType AS varchar), @AIRSExportTypeObjectName)
END IF @Parent_ID IS NOT NULL AND NOT EXISTS(SELECT * FROM External_Community WHERE SystemCode=@SystemCode AND EXT_ID=@Parent_ID AND (@EXT_ID IS NULL OR EXT_ID<>@EXT_ID)) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@Parent_ID AS varchar), @ParentObjectName)
END IF EXISTS(SELECT * FROM External_Community WHERE (@CM_ID IS NULL OR CM_ID<>@CM_ID) AND SystemCode=@SystemCode AND AreaName=@AreaName AND ISNULL(ProvinceState, -1)=ISNULL(@ProvinceState, -1) AND ISNULL(PrimaryAreaType,'')=ISNULL(@PrimaryAreaType, '') AND ISNULL(Parent_ID,-1)=ISNULL(@Parent_ID,-1)) BEGIN
	SET @Error = 6 -- Value in Use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @AreaName, @ExternalCommunityObjectName)
END

IF @Error = 0 BEGIN
	IF @EXT_ID IS NULL BEGIN
		INSERT INTO External_Community (
			SystemCode,
			AreaName,
			PrimaryAreaType,
			SubAreaType,
			ProvinceState,
			ExternalID,
			AIRSExportType,
			Parent_ID,
			CM_ID
		) VALUES (
			@SystemCode, -- SystemCode - varchar(30)
			@AreaName, -- AreaName - nvarchar(200)
			@PrimaryAreaType, -- PrimaryAreaType - varchar(30)
			@SubAreaType, -- SubAreaType - varchar(30)
			@ProvinceState, -- ProvinceState - int
			@ExternalID, -- ExternalID - varchar(50)
			@AIRSExportType,
			@Parent_ID,
			@CM_ID  -- CM_ID - int
		)
		SET @EXT_ID = SCOPE_IDENTITY()
	END ELSE BEGIN
		UPDATE External_Community
		SET	
			AreaName = @AreaName,
			PrimaryAreaType = @PrimaryAreaType,
			SubAreaType = @SubAreaType,
			ProvinceState	= @ProvinceState,
			ExternalID = @ExternalID,
			AIRSExportType = @AIRSExportType,
			Parent_ID = @Parent_ID,
			CM_ID = @CM_ID
		WHERE EXT_ID = @EXT_ID	
	END
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @CommunityObjectName, @ErrMsg
	
END

RETURN @Error

SET NOCOUNT OFF












GO




GRANT EXECUTE ON  [dbo].[sp_External_Community_u] TO [web_user]
GO
