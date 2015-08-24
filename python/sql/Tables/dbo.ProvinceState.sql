CREATE TABLE [dbo].[ProvinceState]
(
[ProvID] [int] NOT NULL IDENTITY(1, 1),
[NameOrCode] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[Country] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NOT NULL,
[DisplayOrder] [tinyint] NOT NULL CONSTRAINT [DF_ProvinceState_DisplayOrder] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProvinceState] ADD CONSTRAINT [PK_ProvinceState] PRIMARY KEY CLUSTERED  ([ProvID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_ProvinceState] ON [dbo].[ProvinceState] ([Country], [NameOrCode]) ON [PRIMARY]
GO
