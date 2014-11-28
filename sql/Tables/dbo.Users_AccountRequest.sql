CREATE TABLE [dbo].[Users_AccountRequest]
(
[Request_ID] [int] NOT NULL IDENTITY(1, 1),
[REQUEST_DATE] [smalldatetime] NULL,
[IPAddress] [varchar] (20) COLLATE Latin1_General_100_CI_AI NULL,
[User_ID] [int] NULL,
[PreferredUserName] [varchar] (50) COLLATE Latin1_General_100_CI_AI NOT NULL,
[StartLanguage] [smallint] NOT NULL,
[FirstName] [varchar] (50) COLLATE Latin1_General_100_CI_AI NOT NULL,
[LastName] [varchar] (50) COLLATE Latin1_General_100_CI_AI NOT NULL,
[Organization] [varchar] (200) COLLATE Latin1_General_100_CI_AI NULL,
[Initials] [varchar] (6) COLLATE Latin1_General_100_CI_AI NOT NULL,
[Email] [varchar] (60) COLLATE Latin1_General_100_CI_AI NULL,
[ManageAreaRequest] [bit] NOT NULL CONSTRAINT [DF_Users_AccountRequest_ManageAreaRequest] DEFAULT ((0)),
[ManageAreaDetail] [varchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[REJECTED_DATE] [smalldatetime] NULL,
[REJECTED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Users_AccountRequest] ADD CONSTRAINT [CK_Users_AccountRequest_AcceptedOrRejected] CHECK (([User_ID] IS NULL OR [REJECTED_DATE] IS NULL))
GO
ALTER TABLE [dbo].[Users_AccountRequest] ADD CONSTRAINT [PK_Users_AccountRequest] PRIMARY KEY CLUSTERED  ([Request_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Users_AccountRequest] ADD CONSTRAINT [FK_Users_AccountRequest_Users] FOREIGN KEY ([User_ID]) REFERENCES [dbo].[Users] ([User_ID])
GO
