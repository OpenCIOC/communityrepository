CREATE TABLE [dbo].[Users_ManageExternalSystem]
(
[User_ID] [int] NOT NULL,
[SystemCode] [varchar] (30) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[tr_Users_ManageExternalSystem_iud] ON [dbo].[Users_ManageExternalSystem]
FOR INSERT, DELETE, UPDATE AS 
BEGIN
	SET NOCOUNT ON

    UPDATE Users
		SET ManageExternalSystemList = dbo.fn_Users_ManageExternalSystem_List(Users.User_ID)
	WHERE EXISTS(SELECT * FROM inserted i WHERE i.User_ID=Users.User_ID)
		OR EXISTS(SELECT * FROM deleted d WHERE d.User_ID=Users.User_ID)

	SET NOCOUNT OFF
END

GO

ALTER TABLE [dbo].[Users_ManageExternalSystem] ADD CONSTRAINT [PK_Users_ManageExternalSystem] PRIMARY KEY CLUSTERED  ([User_ID], [SystemCode]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Users_ManageExternalSystem] ADD CONSTRAINT [FK_Users_ManageExternalSystem_ExternalSystem] FOREIGN KEY ([SystemCode]) REFERENCES [dbo].[External_System] ([SystemCode]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[Users_ManageExternalSystem] ADD CONSTRAINT [FK_Users_ManageExternalSystem_Users] FOREIGN KEY ([User_ID]) REFERENCES [dbo].[Users] ([User_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
