CREATE TABLE [dbo].[Community_AltName]
(
[CM_ID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[AltName] [nvarchar] (200) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Community_AltName] ADD CONSTRAINT [PK_Community_AltName] PRIMARY KEY CLUSTERED  ([CM_ID], [LangID], [AltName]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Community_AltName_UniquePerCommunity] ON [dbo].[Community_AltName] ([CM_ID], [LangID], [AltName]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Community_AltName] ADD CONSTRAINT [FK_Community_AltName_Community] FOREIGN KEY ([CM_ID]) REFERENCES [dbo].[Community] ([CM_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[Community_AltName] ADD CONSTRAINT [FK_Community_AltName_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[Language] ([LangID])
GO
