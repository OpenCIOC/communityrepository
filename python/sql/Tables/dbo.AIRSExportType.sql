CREATE TABLE [dbo].[AIRSExportType]
(
[AIRSExportType] [varchar] (20) COLLATE Latin1_General_100_CI_AI NOT NULL,
[Official] [bit] NOT NULL CONSTRAINT [DF_AIRSExportType_Official] DEFAULT ((1))
) ON [PRIMARY]
ALTER TABLE [dbo].[AIRSExportType] ADD 
CONSTRAINT [PK_AIRSExportType] PRIMARY KEY CLUSTERED  ([AIRSExportType]) ON [PRIMARY]
GO
