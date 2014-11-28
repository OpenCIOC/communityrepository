CREATE TABLE [dbo].[Community_AltAreaSearch]
(
[CM_ID] [int] NOT NULL,
[Search_CM_ID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Community_AltAreaSearch] ADD CONSTRAINT [CK_Community_AltAreaSearch] CHECK (([CM_ID]<>[Search_CM_ID]))
GO
ALTER TABLE [dbo].[Community_AltAreaSearch] ADD CONSTRAINT [PK_Community_AltAreaSearch] PRIMARY KEY CLUSTERED  ([CM_ID], [Search_CM_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Community_AltAreaSearch] ADD CONSTRAINT [FK_Community_AltAreaSearch_Community] FOREIGN KEY ([CM_ID]) REFERENCES [dbo].[Community] ([CM_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[Community_AltAreaSearch] ADD CONSTRAINT [FK_Community_AltAreaSearch_Community_Search] FOREIGN KEY ([Search_CM_ID]) REFERENCES [dbo].[Community] ([CM_ID])
GO
