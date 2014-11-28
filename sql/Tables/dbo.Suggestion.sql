CREATE TABLE [dbo].[Suggestion]
(
[Suggest_ID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NOT NULL CONSTRAINT [DF_Suggestion_CREATED_DATE] DEFAULT (getdate()),
[User_ID] [int] NOT NULL,
[Suggestion] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NOT NULL,
[COMPLETED_DATE] [smalldatetime] NULL,
[COMPLETED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Suggestion] ADD CONSTRAINT [PK_Suggestion] PRIMARY KEY CLUSTERED  ([Suggest_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Suggestion] ADD CONSTRAINT [FK_Suggestion_Users] FOREIGN KEY ([User_ID]) REFERENCES [dbo].[Users] ([User_ID])
GO
