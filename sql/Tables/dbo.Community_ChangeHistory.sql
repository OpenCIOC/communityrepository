CREATE TABLE [dbo].[Community_ChangeHistory]
(
[HST_ID] [int] NOT NULL IDENTITY(1, 1),
[CM_ID] [int] NULL,
[CM_GUID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_Community_ChangeHistory_CM_GUID1] DEFAULT (newid()),
[FormerName] [nvarchar] (200) COLLATE Latin1_General_100_CI_AI NULL,
[CurrentName] [nvarchar] (200) COLLATE Latin1_General_100_CI_AI NULL,
[ChangeComment] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NOT NULL,
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NOT NULL,
[MODIFIED_DATE] [datetime] NOT NULL CONSTRAINT [DF_Community_ChangeHistory_MODIFIED_DATE] DEFAULT (getdate()),
[TypeOfChange] [bit] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Community_ChangeHistory] ADD CONSTRAINT [PK_Community_ChangeHistory] PRIMARY KEY CLUSTERED  ([HST_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Community_ChangeHistory] ADD CONSTRAINT [FK_Community_ChangeHistory_Community] FOREIGN KEY ([CM_ID]) REFERENCES [dbo].[Community] ([CM_ID]) ON DELETE SET NULL ON UPDATE CASCADE
GO
