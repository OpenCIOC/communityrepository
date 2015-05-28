# =========================================================================================
#  Copyright 2015 Community Information Online Consortium (CIOC) and KCL Software Solutions
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
# =========================================================================================

from pyramid.security import NO_PERMISSION_REQUIRED
from pyramid.view import view_config

from communitymanager.views.base import ViewBase


@view_config(route_name="faq", renderer='faq.mak', permission=NO_PERMISSION_REQUIRED)
@view_config(route_name="home", renderer='home.mak', permission=NO_PERMISSION_REQUIRED)
class Home(ViewBase):
    def __call__(self):

        return {}
