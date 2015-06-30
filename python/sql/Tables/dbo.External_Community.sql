CREATE TABLE [dbo].[External_Community]
(
[EXT_ID] [int] NOT NULL IDENTITY(1, 1),
[SystemCode] [varchar] (30) COLLATE Latin1_General_100_CI_AI NOT NULL,
[AreaName] [nvarchar] (200) COLLATE Latin1_General_100_CI_AI NOT NULL,
[PrimaryAreaType] [varchar] (30) COLLATE Latin1_General_100_CI_AI NULL,
[SubAreaType] [varchar] (30) COLLATE Latin1_General_100_CI_AI NULL,
[AIRSExportType] [varchar] (20) COLLATE Latin1_General_100_CI_AI NULL,
[ProvinceState] [int] NULL,
[ExternalID] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[CM_ID] [int] NULL,
[Parent_ID] [int] NULL,
[SortCode] [varchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[Depth] [smallint] NULL,
[EXT_GUID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_External_Community_EXT_GUID] DEFAULT (newid())
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
CREATE UNIQUE NONCLUSTERED INDEX [IX_External_Community] ON [dbo].[External_Community] ([SystemCode], [AreaName], [ProvinceState], [PrimaryAreaType], [Parent_ID]) ON [PRIMARY]

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE TRIGGER [dbo].[tr_External_Community_iu] ON [dbo].[External_Community]
FOR INSERT, UPDATE AS 
BEGIN
	SET NOCOUNT ON
	
	IF UPDATE(Parent_ID) BEGIN			
	WITH SiblingRank(EXT_ID, SortCode) AS 
		(
			SELECT cm.EXT_ID, CAST(RIGHT('0000000' + CAST(RANK() OVER (ORDER BY cm.AreaName) AS VARCHAR(3)), 3) AS varchar(MAX))
			FROM dbo.External_Community cm
			WHERE Parent_ID IS NULL
			UNION ALL
			SELECT cm.CM_ID, s.SortCode + '-' + CAST(RIGHT('0000000' + CAST(RANK() OVER (ORDER BY cm.AreaName) AS VARCHAR(3)), 3) AS varchar(MAX))
			FROM dbo.External_Community cm
			INNER JOIN SiblingRank s
				ON s.EXT_ID=cm.Parent_ID
		)	
		UPDATE cm
			SET
				SortCode = s.SortCode
		FROM dbo.External_Community cm
		INNER JOIN SiblingRank s
			ON cm.EXT_ID=s.EXT_ID
	END

	SET NOCOUNT OFF
END


GO

ALTER TABLE [dbo].[External_Community] ADD
CONSTRAINT [FK_External_Community_AIRSExportType] FOREIGN KEY ([AIRSExportType]) REFERENCES [dbo].[AIRSExportType] ([AIRSExportType])
ALTER TABLE [dbo].[External_Community] ADD 
CONSTRAINT [PK_External_Community] PRIMARY KEY CLUSTERED  ([EXT_ID]) ON [PRIMARY]





ALTER TABLE [dbo].[External_Community] ADD
CONSTRAINT [FK_External_Community_Community_Type_Primary] FOREIGN KEY ([PrimaryAreaType]) REFERENCES [dbo].[Community_Type] ([Code])
ALTER TABLE [dbo].[External_Community] ADD
CONSTRAINT [FK_External_Community_Community_Type_Sub] FOREIGN KEY ([SubAreaType]) REFERENCES [dbo].[Community_Type] ([Code])
GO

ALTER TABLE [dbo].[External_Community] ADD CONSTRAINT [FK_External_Community_Community] FOREIGN KEY ([CM_ID]) REFERENCES [dbo].[Community] ([CM_ID]) ON DELETE SET NULL
GO

ALTER TABLE [dbo].[External_Community] ADD CONSTRAINT [FK_External_Community_ProvinceState] FOREIGN KEY ([ProvinceState]) REFERENCES [dbo].[ProvinceState] ([ProvID])
GO
ALTER TABLE [dbo].[External_Community] ADD CONSTRAINT [FK_External_Community_External_System] FOREIGN KEY ([SystemCode]) REFERENCES [dbo].[External_System] ([SystemCode])
GO
