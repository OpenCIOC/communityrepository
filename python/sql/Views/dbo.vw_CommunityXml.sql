
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






CREATE VIEW [dbo].[vw_CommunityXml]
AS
SELECT
(SELECT
  (SELECT 
	[@id] = ProvID,
	[@name_or_code] = NameOrCode,
	[@country] = Country,
	[names] = (SELECT
					psn.Name [@value],
					sl.Culture [@culture]
				FROM ProvinceState_Name psn
				INNER JOIN Language sl
					ON psn.LangID=sl.LangID
				WHERE ps.ProvID = psn.ProvID
			FOR XML PATH('name'), TYPE)
  FROM ProvinceState ps
  FOR XML PATH('province_state'), ROOT('province_states'), TYPE) as [node()],
	(SELECT
		(SELECT
			[@id] = cm.CM_ID,
			[@parent_id] = cm.ParentCommunity,
			[@created_date] = cm.CREATED_DATE,
			[@modified_date] = cm.MODIFIED_DATE,
			[@guid] = cm.CM_GUID,
			[@prov_state] = cm.ProvinceState,
			[names] = (SELECT
						cmn.Name [@value],
						sl.Culture [@culture]
					FROM Community_Name cmn
					INNER JOIN Language sl
						ON cmn.LangID=sl.LangID
					WHERE cmn.CM_ID = cm.CM_ID
					FOR XML PATH('name'), TYPE),
			[alt_names] = (SELECT
						an.AltName [@value],
						sl.Culture [@culture]
					FROM Community_AltName an
					INNER JOIN Language sl
						ON an.LangID=sl.LangID
					WHERE an.CM_ID = cm.CM_ID
					FOR XML PATH('name'), TYPE)
			FOR XML PATH('community'), TYPE) 
		FROM Community cm
		WHERE cm.AlternativeArea=0
		ORDER BY Depth, CM_ID
		FOR XML PATH(''), ROOT('communities'), TYPE) AS [node()],
	 (SELECT
		(SELECT
			[@id] = cm.CM_ID,
			[@parent_id] = cm.ParentCommunity,
			[@created_date] = cm.CREATED_DATE,
			[@modified_date] = cm.MODIFIED_DATE,
			[@guid] = cm.CM_GUID,
			[names] = (SELECT
						cmn.Name [@value],
						sl.Culture [@culture]
					FROM Community_Name cmn
					INNER JOIN Language sl
						ON cmn.LangID=sl.LangID
					WHERE cm.CM_ID = cmn.CM_ID
					FOR XML PATH('name'), TYPE ),
			[alt_names] = (SELECT
						an.AltName [@value],
						sl.Culture [@culture]
					FROM Community_AltName an
					INNER JOIN Language sl
						ON an.LangID=sl.LangID
					WHERE an.CM_ID = cm.CM_ID
					FOR XML PATH('name'), TYPE ),
			[search_areas] = (SELECT
								Search_CM_ID AS [@value]
					FROM Community_AltAreaSearch aas
					WHERE aas.CM_ID=cm.CM_ID
					FOR XML PATH('cm_id'), TYPE)
			FOR XML PATH('alt_search_area'), TYPE)
		FROM Community cm
		WHERE cm.AlternativeArea=1
		FOR XML PATH(''), ROOT('alt_search_areas'), TYPE) AS [node()]
 
FOR XML PATH(''),TYPE
) AS data



GO

GRANT SELECT ON  [dbo].[vw_CommunityXml] TO [web_user]
GO
