CREATE TABLE [dbo].[Community_Type_Name]
(
[Code] [varchar] (30) COLLATE Latin1_General_100_CI_AI NOT NULL,
[LangID] [smallint] NOT NULL CONSTRAINT [DF_Community_Type_Name_LangID] DEFAULT ((0)),
[Name] [nvarchar] (200) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Community_Type_Name] ADD CONSTRAINT [PK_Community_Type_Name] PRIMARY KEY CLUSTERED  ([Code], [LangID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Community_Type_Name] ADD CONSTRAINT [FK_Community_Type_Name_Community_Type] FOREIGN KEY ([Code]) REFERENCES [dbo].[Community_Type] ([Code]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[Community_Type_Name] ADD CONSTRAINT [FK_Community_Type_Name_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[Language] ([LangID])
GO
