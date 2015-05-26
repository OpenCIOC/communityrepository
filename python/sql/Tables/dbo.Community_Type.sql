CREATE TABLE [dbo].[Community_Type]
(
[Code] [varchar] (30) COLLATE Latin1_General_100_CI_AI NOT NULL,
[AIRSExportType] [varchar] (20) COLLATE Latin1_General_100_CI_AI NOT NULL,
[HierarchyLevel] [tinyint] NOT NULL CONSTRAINT [DF_Community_Type_HierarchyLevel] DEFAULT ((0)),
[HighlightColour] [varchar] (7) COLLATE Latin1_General_100_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Community_Type] ADD CONSTRAINT [PK_Community_Type] PRIMARY KEY CLUSTERED  ([Code]) ON [PRIMARY]
GO
