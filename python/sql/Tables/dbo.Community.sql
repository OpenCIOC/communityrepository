CREATE TABLE [dbo].[Community]
(
[CM_ID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NULL,
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL,
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[CM_GUID] [uniqueidentifier] NOT NULL ROWGUIDCOL CONSTRAINT [DF_Community_CM_GUID] DEFAULT (newid()),
[ParentCommunity] [int] NULL,
[ProvinceState] [int] NULL,
[AlternativeArea] [bit] NOT NULL CONSTRAINT [DF_Community_AlternativeArea] DEFAULT ((0)),
[Source] [nvarchar] (200) COLLATE Latin1_General_100_CI_AI NULL,
[Code] [varchar] (20) COLLATE Latin1_General_100_CI_AI NULL,
[SortCode] [varchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[Depth] [smallint] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[tr_Community_iu] ON [dbo].[Community]
FOR INSERT, UPDATE AS 
BEGIN
	SET NOCOUNT ON

	IF UPDATE(ProvinceState) BEGIN
		UPDATE cmn
			SET ProvinceStateCache = i.ProvinceState
		FROM Community_Name cmn
		INNER JOIN inserted i ON i.CM_ID=cmn.CM_ID
	END
	
	IF UPDATE(ParentCommunity) BEGIN		
		WITH ParentList (CM_ID, Parent_CM_ID) AS
		(
			SELECT CM_ID, ParentCommunity
			FROM Community
			WHERE ParentCommunity IS NOT NULL
		  UNION ALL
			SELECT cm1.CM_ID, p.Parent_CM_ID
			FROM Community cm1
			INNER JOIN ParentList p
				ON cm1.ParentCommunity=p.CM_ID
		)
		
		MERGE INTO Community_ParentList AS cmpl
		USING ParentList AS p
		ON cmpl.CM_ID=p.CM_ID AND cmpl.Parent_CM_ID=p.Parent_CM_ID
		WHEN NOT MATCHED BY TARGET
			THEN INSERT (CM_ID, Parent_CM_ID) VALUES (p.CM_ID, p.Parent_CM_ID)
		WHEN NOT MATCHED BY SOURCE
			THEN DELETE
		OPTION (MAXRECURSION 30);
		
		WITH SiblingRank(CM_ID, SortCode) AS 
		(
			SELECT cm.CM_ID, CAST(RIGHT('0000000' + CAST(RANK() OVER (ORDER BY cmn.Name) AS VARCHAR(3)), 3) AS varchar(MAX))
			FROM Community cm
			INNER JOIN Community_Name cmn
				ON cm.CM_ID=cmn.CM_ID AND cmn.LangID=0
			WHERE ParentCommunity IS NULL
			UNION ALL
			SELECT cm.CM_ID, s.SortCode + '-' + CAST(RIGHT('0000000' + CAST(RANK() OVER (ORDER BY cmn.Name) AS VARCHAR(3)), 3) AS varchar(MAX))
			FROM Community cm
			INNER JOIN Community_Name cmn
				ON cm.CM_ID=cmn.CM_ID AND cmn.LangID=0
			INNER JOIN SiblingRank s
				ON s.CM_ID=cm.ParentCommunity
		)	
		UPDATE cm
			SET
				Depth = (SELECT COUNT(*) FROM Community_ParentList WHERE CM_ID=cm.CM_ID),
				SortCode = s.SortCode
		FROM Community cm
		INNER JOIN SiblingRank s
			ON cm.CM_ID=s.CM_ID
	END

	SET NOCOUNT OFF
END

GO

ALTER TABLE [dbo].[Community] ADD CONSTRAINT [PK_Community] PRIMARY KEY CLUSTERED  ([CM_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Community] ADD CONSTRAINT [IX_Community] UNIQUE NONCLUSTERED  ([CM_GUID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Community_CMID] ON [dbo].[Community] ([CM_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Community] ADD CONSTRAINT [FK_Community_Community] FOREIGN KEY ([ParentCommunity]) REFERENCES [dbo].[Community] ([CM_ID])
GO
ALTER TABLE [dbo].[Community] ADD CONSTRAINT [FK_Community_ProvinceState] FOREIGN KEY ([ProvinceState]) REFERENCES [dbo].[ProvinceState] ([ProvID]) ON DELETE SET NULL ON UPDATE CASCADE
GO
