CREATE TABLE [dbo].[External_Community]
(
[EXT_ID] [int] NOT NULL IDENTITY(1, 1),
[SystemCode] [varchar] (30) COLLATE Latin1_General_100_CI_AI NOT NULL,
[AreaName] [nvarchar] (200) COLLATE Latin1_General_100_CI_AI NOT NULL,
[AreaType] [varchar] (30) COLLATE Latin1_General_100_CI_AI NULL,
[ProvinceState] [int] NOT NULL,
[ExternalID] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[CM_ID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[External_Community] ADD CONSTRAINT [PK_External_Community] PRIMARY KEY CLUSTERED  ([EXT_ID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_External_Community] ON [dbo].[External_Community] ([AreaName], [AreaType], [ProvinceState], [SystemCode]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[External_Community] ADD CONSTRAINT [FK_External_Community_Community] FOREIGN KEY ([CM_ID]) REFERENCES [dbo].[Community] ([CM_ID]) ON DELETE SET NULL
GO
ALTER TABLE [dbo].[External_Community] ADD CONSTRAINT [FK_External_Community_External_Community] FOREIGN KEY ([EXT_ID]) REFERENCES [dbo].[External_Community] ([EXT_ID])
GO
ALTER TABLE [dbo].[External_Community] ADD CONSTRAINT [FK_External_Community_ProvinceState] FOREIGN KEY ([ProvinceState]) REFERENCES [dbo].[ProvinceState] ([ProvID])
GO
ALTER TABLE [dbo].[External_Community] ADD CONSTRAINT [FK_External_Community_External_System] FOREIGN KEY ([SystemCode]) REFERENCES [dbo].[External_System] ([SystemCode])
GO
