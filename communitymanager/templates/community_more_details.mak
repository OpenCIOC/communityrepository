%if community.OtherNames:
<p>
<strong>${_('Other Names:')}</strong> ${'; '.join(x['Name'] for x in community.OtherNames)}
</p>
%endif
%if community.ParentCommunityName and False:
<p>
<strong>${_('Parent Community:')}</strong> ${community.ParentCommunityName['Name']}
</p>
%endif
%if community.ChildCommunities:
<p>
<strong>${_('Child Communities:')}</strong> ${'; '.join(x['Name'] for x in  community.ChildCommunities)}
</p>
%endif
%if community.SearchCommunities:
<p>
<strong>${_('Search Communities:')}</strong> ${'; '.join(x['Name'] for x in community.SearchCommunities)}
</p>
%endif
%if community.ProvinceStateCountry:
<p>
<strong>${_('Province/State/Country:')}</strong> ${community.ProvinceStateCountry}
</p>
%endif
<p>
<p>
<strong>${_('Managed By:')}</strong> ${'; '.join(x['UserName'] for x in community.Managers)}
%if community.CREATED_BY or community.CREATED_DATE:
<br><strong>${_('Created:')}</strong> ${community.CREATED_BY or ''} ${request.format_date(community.CREATED_DATE) if community.CREATED_DATE else ''}
%endif
%if community.MODIFIED_BY or community.MODIFIED_DATE:
<br><strong>${_('Modified:')}</strong> ${community.MODIFIED_BY or ''} ${request.format_date(community.MODIFIED_DATE) if community.MODIFIED_DATE else ''}
%endif

</p>
