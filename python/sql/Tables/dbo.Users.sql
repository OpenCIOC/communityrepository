CREATE TABLE [dbo].[Users]
(
[User_ID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NULL,
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL,
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[UserUID] [uniqueidentifier] NOT NULL ROWGUIDCOL CONSTRAINT [DF_Users_UserUID] DEFAULT (newid()),
[UserName] [varchar] (50) COLLATE Latin1_General_100_CI_AI NOT NULL,
[StartLanguage] [smallint] NOT NULL CONSTRAINT [DF_Users_StartLanguage] DEFAULT ((0)),
[FirstName] [varchar] (50) COLLATE Latin1_General_100_CI_AI NOT NULL,
[LastName] [varchar] (50) COLLATE Latin1_General_100_CI_AI NOT NULL,
[Initials] [varchar] (6) COLLATE Latin1_General_100_CI_AI NOT NULL,
[Organization] [varchar] (200) COLLATE Latin1_General_100_CI_AI NULL,
[Email] [varchar] (60) COLLATE Latin1_General_100_CI_AI NULL,
[PasswordHashRepeat] [int] NOT NULL,
[PasswordHashSalt] [char] (44) COLLATE Latin1_General_100_CI_AI NOT NULL,
[PasswordHash] [char] (44) COLLATE Latin1_General_100_CI_AI NOT NULL,
[Admin] [bit] NOT NULL CONSTRAINT [DF_Users_Admin] DEFAULT ((0)),
[ManageAreaList] [varchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[ManageExternalSystemList] [varchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[Inactive] [bit] NOT NULL CONSTRAINT [DF_Users_Inactive] DEFAULT ((0))
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
ALTER TABLE [dbo].[Users] ADD 
CONSTRAINT [PK_Users] PRIMARY KEY CLUSTERED  ([User_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Users] ADD CONSTRAINT [IX_Users] UNIQUE NONCLUSTERED  ([UserName]) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_Users_Initials] ON [dbo].[Users] ([Initials]) ON [PRIMARY]

GO

ALTER TABLE [dbo].[Users] ADD CONSTRAINT [FK_Users_Language] FOREIGN KEY ([StartLanguage]) REFERENCES [dbo].[Language] ([LangID])
GO
