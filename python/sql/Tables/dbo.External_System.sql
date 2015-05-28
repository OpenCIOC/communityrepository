CREATE TABLE [dbo].[External_System]
(
[SystemCode] [varchar] (30) COLLATE Latin1_General_100_CI_AI NOT NULL,
[SystemName] [varchar] (200) COLLATE Latin1_General_100_CI_AI NULL,
[CopyrightHolder1] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[CopyrightHolder2] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[Description] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[ContactEmail] [varchar] (60) COLLATE Latin1_General_100_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[External_System] ADD CONSTRAINT [PK_External_System] PRIMARY KEY CLUSTERED  ([SystemCode]) ON [PRIMARY]
GO
