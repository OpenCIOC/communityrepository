CREATE TABLE [dbo].[External_System]
(
[SystemCode] [varchar] (30) COLLATE Latin1_General_100_CI_AI NOT NULL,
[SystemName] [varchar] (200) COLLATE Latin1_General_100_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[External_System] ADD CONSTRAINT [PK_External_System] PRIMARY KEY CLUSTERED  ([SystemCode]) ON [PRIMARY]
GO
