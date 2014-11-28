CREATE TABLE [dbo].[Community_ParentList]
(
[CM_ID] [int] NOT NULL,
[Parent_CM_ID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Community_ParentList] ADD CONSTRAINT [PK_Community_ParentList] PRIMARY KEY CLUSTERED  ([CM_ID], [Parent_CM_ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Community_ParentList_CMIDInclParentCMID] ON [dbo].[Community_ParentList] ([CM_ID]) INCLUDE ([Parent_CM_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Community_ParentList] ADD CONSTRAINT [FK_Community_ParentList_Community] FOREIGN KEY ([CM_ID]) REFERENCES [dbo].[Community] ([CM_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[Community_ParentList] ADD CONSTRAINT [FK_Community_ParentList_Community_Parent] FOREIGN KEY ([Parent_CM_ID]) REFERENCES [dbo].[Community] ([CM_ID])
GO
