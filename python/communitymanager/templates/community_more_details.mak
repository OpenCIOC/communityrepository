<%doc>
  =========================================================================================
   Copyright 2015 Community Information Online Consortium (CIOC) and KCL Software Solutions
 
   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at
 
       http://www.apache.org/licenses/LICENSE-2.0
 
   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
  =========================================================================================
</%doc>

%if community.OtherNames:
<p>
<strong>${_('Other Names: ')}</strong> ${'; '.join(x['Name'] for x in community.OtherNames)}
</p>
%endif
%if community.ParentCommunityName and False:
<p>
<strong>${_('Parent Community: ')}</strong> ${community.ParentCommunityName['Name']}
</p>
%endif
%if community.ChildCommunities:
<p>
<strong>${_('Child Communities: ')}</strong> ${'; '.join(x['Name'] for x in  community.ChildCommunities)}
</p>
%endif
%if community.SearchCommunities:
<p>
<strong>${_('Search Communities: ')}</strong> ${'; '.join(x['Name'] for x in community.SearchCommunities)}
</p>
%endif
%if community.ProvinceStateCountry:
<p>
<strong>${_('Province/State/Country: ')}</strong> ${community.ProvinceStateCountry}
</p>
%endif
<p>
<p class="smaller">
<strong>${_('Managed By: ')}</strong> ${'; '.join(x['UserName'] for x in community.Managers)}
%if community.CREATED_BY or community.CREATED_DATE:
<br><strong>${_('Created: ')}</strong> ${request.format_date(community.CREATED_DATE) if community.CREATED_DATE else ''} 
${'(' if community.CREATED_DATE and community.CREATED_BY else ''}${community.CREATED_BY or ''}${')' if community.CREATED_DATE and community.CREATED_BY else ''}
%endif
%if community.MODIFIED_BY or community.MODIFIED_DATE:
<br><strong>${_('Modified: ')}</strong> ${request.format_date(community.MODIFIED_DATE) if community.MODIFIED_DATE else ''} 
${'(' if community.MODIFIED_DATE and community.MODIFIED_BY else ''}${community.MODIFIED_BY or ''}${')' if community.MODIFIED_DATE and community.MODIFIED_BY else ''}

%endif

</p>
