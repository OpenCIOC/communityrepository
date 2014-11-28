CREATE TABLE [dbo].[ProvinceState_Name]
(
[ProvID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[Name] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProvinceState_Name] ADD CONSTRAINT [PK_ProvinceState_Name] PRIMARY KEY CLUSTERED  ([ProvID], [LangID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProvinceState_Name] ADD CONSTRAINT [FK_ProvinceState_Name_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[Language] ([LangID])
GO
ALTER TABLE [dbo].[ProvinceState_Name] ADD CONSTRAINT [FK_ProvinceState_Name_ProvinceState] FOREIGN KEY ([ProvID]) REFERENCES [dbo].[ProvinceState] ([ProvID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
