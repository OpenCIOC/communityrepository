CREATE TABLE [dbo].[Language]
(
[LangID] [smallint] NOT NULL,
[LanguageName] [nvarchar] (50) COLLATE Latin1_General_100_CI_AI NOT NULL,
[LanguageAlias] [nvarchar] (50) COLLATE Latin1_General_100_CI_AI NOT NULL,
[Culture] [varchar] (5) COLLATE Latin1_General_100_CI_AI NOT NULL,
[LCID] [int] NOT NULL,
[Active] [bit] NOT NULL,
[ActiveRecord] [bit] NOT NULL CONSTRAINT [DF_Language_RecordActive] DEFAULT ((0)),
[DateFormatCode] [int] NOT NULL CONSTRAINT [DF_Language_DateFormatCode] DEFAULT ((106))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Language] ADD CONSTRAINT [PK_Language] PRIMARY KEY CLUSTERED  ([LangID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Language_LangIDIncl] ON [dbo].[Language] ([LangID]) INCLUDE ([DateFormatCode]) ON [PRIMARY]
GO
