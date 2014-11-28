CREATE TABLE [dbo].[Users_ManageArea]
(
[User_ID] [int] NOT NULL,
[CM_ID] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_Users_ManageArea_iud] ON [dbo].[Users_ManageArea]
FOR INSERT, DELETE, UPDATE AS 
BEGIN
	SET NOCOUNT ON

    UPDATE Users
		SET ManageAreaList = dbo.fn_Users_ManageArea_List(Users.User_ID)
	WHERE EXISTS(SELECT * FROM inserted i WHERE i.User_ID=Users.User_ID)
		OR EXISTS(SELECT * FROM deleted d WHERE d.User_ID=Users.User_ID)

	SET NOCOUNT OFF
END
GO
ALTER TABLE [dbo].[Users_ManageArea] ADD CONSTRAINT [PK_Users_ManageArea] PRIMARY KEY CLUSTERED  ([User_ID], [CM_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Users_ManageArea] ADD CONSTRAINT [FK_Users_ManageArea_Community] FOREIGN KEY ([CM_ID]) REFERENCES [dbo].[Community] ([CM_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[Users_ManageArea] ADD CONSTRAINT [FK_Users_ManageArea_Users] FOREIGN KEY ([User_ID]) REFERENCES [dbo].[Users] ([User_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
