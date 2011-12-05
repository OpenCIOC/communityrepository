<%inherit file="master.mak"/>
<%block name="title">${_('Welcome')}</%block>

<p>${_('Some blurb about this tool and how to get access.')}</p>

<p>${_('Alread have an account?')} <a href="${request.route_path('login')}">${_('Login Now!')}</a> 
