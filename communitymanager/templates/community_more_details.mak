%if community.OtherNames:
<h3>${_('Other Names:')}</h3>
<ul>
    %for other_name in community.OtherNames:
    <li>${other_name['Name']}</li>
    %endfor
</ul>
%endif
%if community.ParentCommunityName:
<h3>${_('Parent Community:')}</h3>
${community.ParentCommunityName['Name']}
%endif
%if community.ChildCommunities:
<h3>${_('Child Communities')}</h3>
<ul>
    %for child in community.ChildCommunities:
    <li>${child['Name']}</li>
    %endfor
</ul>
%endif
