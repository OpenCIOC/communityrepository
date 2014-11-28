CREATE TABLE [dbo].[Community_Name]
(
[CM_ID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[Name] [nvarchar] (200) COLLATE Latin1_General_100_CI_AI NOT NULL,
[ProvinceStateCache] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Community_Name] ADD CONSTRAINT [PK_Community_Name] PRIMARY KEY CLUSTERED  ([CM_ID], [LangID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Community_Name_CMIDInclLangID] ON [dbo].[Community_Name] ([CM_ID]) INCLUDE ([LangID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Community_Name_CMIDLangIDInclName] ON [dbo].[Community_Name] ([CM_ID], [LangID]) INCLUDE ([Name]) WITH (ALLOW_PAGE_LOCKS=OFF) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Community_Name_UniqueName] ON [dbo].[Community_Name] ([LangID], [Name], [ProvinceStateCache]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Community_Name_NameLangIDInclCMID] ON [dbo].[Community_Name] ([Name], [LangID], [ProvinceStateCache]) INCLUDE ([CM_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Community_Name] ADD CONSTRAINT [FK_Community_Name_Community] FOREIGN KEY ([CM_ID]) REFERENCES [dbo].[Community] ([CM_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[Community_Name] ADD CONSTRAINT [FK_Community_Name_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[Language] ([LangID])
GO
