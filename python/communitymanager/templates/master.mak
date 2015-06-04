<!doctype html>
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
<!-- paulirish.com/2008/conditional-stylesheets-vs-css-hacks-answer-neither/ -->
<!--[if lt IE 7]> <html class="no-js ie6 oldie" lang="en"> <![endif]-->
<!--[if IE 7]>    <html class="no-js ie7 oldie" lang="en"> <![endif]-->
<!--[if IE 8]>    <html class="no-js ie8 oldie" lang="en"> <![endif]-->
<!-- Consider adding an manifest.appcache: h5bp.com/d/Offline -->
<!--[if gt IE 8]><!--> <html class="no-js" lang="en"> <!--<![endif]-->
<head>
  <meta charset="utf-8">

  <!-- Use the .htaccess and remove these lines to avoid edge case issues.
       More info: h5bp.com/b/378 -->
  <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">

  <title><%block name="title"/></title>
  <meta name="description" content="">
  <meta name="author" content="">

  <!-- Mobile viewport optimized: j.mp/bplateviewport -->
  <meta name="viewport" content="width=device-width,initial-scale=1">

  <!-- Place favicon.ico and apple-touch-icon.png in the root directory: mathiasbynens.be/notes/touch-icons -->

  <!-- CSS: implied media=all -->
  <!-- CSS concatenated and minified via ant build script-->
  <!-- XXX only local styles -->
  <link rel="stylesheet" href="//ajax.googleapis.com/ajax/libs/jqueryui/1.8.23/themes/redmond/jquery-ui.css" type="text/css" />
  <link rel="stylesheet" href="/static/css/style.css">
  <style type="text/css">
    /* fix the broken font handling in default jquery-ui styles */
    .ui-widget {
        font-family: inherit;
        font-size: 1em;
    }
  </style>
  <!-- end CSS-->

  <!-- More ideas for your <head> here: h5bp.com/d/head-Tips -->

  <!-- All JavaScript at the bottom, except for Modernizr / Respond.
       Modernizr enables HTML5 elements & feature detects; Respond is a polyfill for min/max-width CSS3 Media Queries
       For optimal performance, use a custom Modernizr build: www.modernizr.com/download/ -->
  <script src="/static/js/libs/modernizr-2.0.6-custom.min.js"></script>
</head>

<body>

<div id="wrap">
<header>
<h1 style="margin: 0; padding-left: 1em;" class="ui-widget-header"><a href="${request.route_path('home')}">${_('CIOC Communities Repository')}</a></h1>
<nav class="site-nav"><%block name="sitenav">
<%block name="browse"><a class="ui-button ui-widget ui-state-default ui-corner-bottom ui-button-text-icon-primary" href="${request.route_url('communities')}"><span class="ui-icon ui-icon-search ui-button-icon-primary"></span><span class="ui-button-text">${_('Search')}</span></a></%block>
<a class="ui-button ui-widget ui-state-default ui-corner-bottom ui-button-text-icon-primary" href="${request.route_url('downloads')}"><span class="ui-icon ui-icon-script ui-button-icon-primary"></span><span class="ui-button-text">${_('Downloads')}</span></a>
%if request.user:
<a class="ui-button ui-widget ui-state-default ui-corner-bottom ui-button-text-icon-primary" href="${request.route_url('suggest')}"><span class="ui-icon ui-icon-comment ui-button-icon-primary"></span><span class="ui-button-text">${_('Suggest Change')}</span></a>
%if request.user.Admin or request.user.ManageAreaList:
<a class="ui-button ui-widget ui-state-default ui-corner-bottom ui-button-text-icon-primary" href="${request.route_url('review_suggestions')}"><span class="ui-icon ui-icon-mail-open ui-button-icon-primary"></span><span class="ui-button-text">${_('Suggestions')}</span></a>
%endif
%if request.user.Admin:
<a class="ui-button ui-widget ui-state-default ui-corner-bottom ui-button-text-icon-primary" href="${request.route_url('users')}"><span class="ui-icon ui-icon-contact ui-button-icon-primary"></span><span class="ui-button-text">${_('Manage Users')}</span></a>
%endif
<a class="ui-button ui-widget ui-state-default ui-corner-bottom ui-button-text-icon-primary" href="${request.route_url('account')}"><span class="ui-icon ui-icon-person ui-button-icon-primary"></span><span class="ui-button-text">${_('My Account')}</span></a>
<a class="ui-button ui-widget ui-state-default ui-corner-bottom ui-button-text-icon-primary" href="${request.route_path('logout')}"><span class="ui-icon ui-icon-power ui-button-icon-primary"></span><span class="ui-button-text">${_('Logout')}</span></a>
%else:
<a class="ui-button ui-widget ui-state-default ui-corner-bottom ui-button-text-icon-primary" href="${request.route_path('request_account')}"><span class="ui-icon ui-icon-person ui-button-icon-primary"></span><span class="ui-button-text">${_('Request Account')}</span></a>
<a class="ui-button ui-widget ui-state-default ui-corner-bottom ui-button-text-icon-primary" href="${request.route_path('login')}"><span class="ui-icon ui-icon-power ui-button-icon-primary"></span><span class="ui-button-text">${_('Login')}</span></a>
%endif
</%block>
</nav>
</header>
<header id="pagetitle" class="clearfix">
<h1 style="margin-top: 0">${self.title()}</h1>
</header>

    <div id="main" role="main">
    <% errmsg = request.session.pop_flash('errorqueue') %>
    %if errmsg:
        ${renderer.error_msg(errmsg[0])}
    %endif
	<% message = request.session.pop_flash() %>
	%if message:
        ${printInfoMessage(message[0])}
	%endif

    ${next.body()}

    </div>

<footer class="footer">
<a rel="license" href="https://creativecommons.org/licenses/by/4.0/"><img alt="Creative Commons Licence" style="border-width:0" src="https://i.creativecommons.org/l/by/4.0/80x15.png" /></a><br>${_('The geography data on this site is licensed under a ')}<a rel="license" href="https://creativecommons.org/licenses/by/4.0/">${_('Creative Commons Attribution 4.0 International License')}</a>.
</footer>

</div> <!-- #wrap -->


  <!-- JavaScript at the bottom for fast page loading -->

  <!-- Grab Google CDN's jQuery, with a protocol relative URL; fall back to local if offline -->
  <!-- XXX only local scripts -->
  <!-- Grab Google CDN's jQuery, with a protocol relative URL; fall back to local if offline -->
  <script src="//ajax.googleapis.com/ajax/libs/jquery/1.8.0/jquery.min.js"></script>
  <script src="//ajax.googleapis.com/ajax/libs/jqueryui/1.8.23/jquery-ui.min.js"></script>

  
  <!-- scripts concatenated and minified via ant build script-->
  <script defer src="/static/js/plugins.js"></script>
  <!-- end scripts-->
  
  <%block name="bottomscripts"/>
	
</body>
</html>

<%def name="printInfoMessage(message)">
    <div class="ui-widget error-notice clearfix">
        <div class="ui-state-highlight ui-corner-all error-notice-wrapper"> 
            <p><span class="ui-icon ui-icon-info error-notice-icon"></span> ${message} </p>
        </div>
    </div>
</%def>

<%def name="makeMgmtInfo(model, show_created=True, show_modified=True)">
%if show_created:
<%
	created_date = getattr(model, 'CREATED_DATE', None)
	created_by = getattr(model, 'CREATED_BY', None) or _('Unknown')
%>
<tr>
    <td class="ui-widget-header field">${_('Date Created')}</td>
    <td class="ui-widget-content">${request.format_date(created_date) if created_date else _('Unknown')} (${_('set automatically')})</td>
</tr>
<tr>
    <td class="ui-widget-header field">${_('Created By')}</td>
    <td class="ui-widget-content">${created_by} (${_('set automatically')})</td>
</tr>

%endif
%if show_modified:
<%
	modified_date = getattr(model, 'MODIFIED_DATE', None)
	modified_by = getattr(model, 'MODIFIED_BY', None) or _('Unknown')
%>
<tr>
    <td class="ui-widget-header field">${_('Last Modified')}</td>
    <td class="ui-widget-content">${request.format_date(modified_date) if modified_date else _('Unknown')} (${_('set automatically')})</td>
</tr>
<tr>
    <td class="ui-widget-header field">${_('Last Modified By')}</td>
    <td class="ui-widget-content">${modified_by} (${_('set automatically')})</td>
</tr>

%endif
</%def>

