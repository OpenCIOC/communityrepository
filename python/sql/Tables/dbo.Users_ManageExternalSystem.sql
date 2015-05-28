CREATE TABLE [dbo].[Users_ManageExternalSystem]
(
[User_ID] [int] NOT NULL,
[SystemCode] [varchar] (30) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Users_ManageExternalSystem] ADD CONSTRAINT [PK_Users_ManageExternalSystem] PRIMARY KEY CLUSTERED  ([User_ID], [SystemCode]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Users_ManageExternalSystem] ADD CONSTRAINT [FK_Users_ManageExternalSystem_ExternalSystem] FOREIGN KEY ([SystemCode]) REFERENCES [dbo].[External_System] ([SystemCode]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[Users_ManageExternalSystem] ADD CONSTRAINT [FK_Users_ManageExternalSystem_Users] FOREIGN KEY ([User_ID]) REFERENCES [dbo].[Users] ([User_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
