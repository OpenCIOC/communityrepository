CREATE TABLE [dbo].[Community_External_Map]
(
[CM_ID] [int] NOT NULL,
[SystemCode] [varchar] (30) COLLATE Latin1_General_100_CI_AI NOT NULL,
[RollUp] [bit] NOT NULL CONSTRAINT [DF_Community_External_Map_RollUp] DEFAULT ((1)),
[MapOneEXTID] [int] NULL,
[MapAllEXTID] [xml] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Community_External_Map] ADD CONSTRAINT [PK_Community_External_Map] PRIMARY KEY CLUSTERED  ([CM_ID], [SystemCode]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Community_External_Map] ADD CONSTRAINT [FK_Community_External_Map_Community] FOREIGN KEY ([CM_ID]) REFERENCES [dbo].[Community] ([CM_ID]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Community_External_Map] ADD CONSTRAINT [FK_Community_External_Map_External_Community] FOREIGN KEY ([MapOneEXTID]) REFERENCES [dbo].[External_Community] ([EXT_ID]) ON DELETE SET NULL
GO
ALTER TABLE [dbo].[Community_External_Map] ADD CONSTRAINT [FK_Community_External_Map_External_System] FOREIGN KEY ([SystemCode]) REFERENCES [dbo].[External_System] ([SystemCode])
GO
