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

import win32serviceutil
import win32service
import win32event
import sys
import os
import getopt
import ConfigParser


def getServiceClassString(o, argv):
    return win32serviceutil.GetServiceClassString(o, argv)


class ServiceSettings(object):
    _wssection_ = "winservice"

    def __init__(self, cfg_file_name, override=None):

        if override is None:
            override = {}

        self.override = override

        c = ConfigParser.SafeConfigParser()
        c.read(cfg_file_name)

        self.cfg_file_name = cfg_file_name
        self.c = c

    def getCfgFileDir(self):
        return os.path.dirname(self.cfg_file_name)

    def getCfgFileName(self):  # this filename is absolute
        return self.cfg_file_name

    def getSvcName(self):
        val = self.override.get('svc_name')
        if val:
            return val

        try:
            return self.c.get(self._wssection_, "svc_name")
        except (ConfigParser.NoOptionError, ConfigParser.NoSectionError):
            return os.path.splitext(os.path.basename(self.cfg_file_name))[0]

    def getSvcDisplayName(self):
        val = self.override.get('svc_display_name')
        if val:
            return val

        try:
            return self.c.get(self._wssection_, "svc_display_name")
        except (ConfigParser.NoOptionError, ConfigParser.NoSectionError):
            return "%s Paste Service" % self.getSvcName()

    def getHttpPort(self):
        val = self.override.get('http_port')
        if val:
            return val

        try:
            return self.c.get(self._wssection_, "http_port").strip()
        except (ConfigParser.NoOptionError, ConfigParser.NoSectionError):
            return None

    def getSvcDescription(self):
        try:
            desc = self.c.get(self._wssection_, "svc_description") + "; "
        except (ConfigParser.NoOptionError, ConfigParser.NoSectionError):
            desc = ""
        return desc + "wsgi_ini_file: %s" % (self.getCfgFileName(),)

    def getVirtualEnv(self):
        val = self.override.get('virtual_env')
        if val:
            return val

        try:
            return self.c.get(self._wssection_, "virtual_env")
        except (ConfigParser.NoOptionError, ConfigParser.NoSectionError):
            return None

    def transferEssential(self, o):
        o._svc_name_ = self.getSvcName()
        o._svc_display_name_ = self.getSvcDisplayName()
        o._svc_description_ = self.getSvcDescription()


def checkIniFileName(file_name):
    if not os.path.exists(file_name):
        raise Exception("The specified paster ini file ( %s ) doesn't exist. Correct the wsgi_ini_file attribute" % file_name)


def activate_virtualenv(ve_dir):
    activate_this = os.path.abspath(os.path.join(ve_dir, 'scripts', 'activate_this.py'))
    execfile(activate_this, dict(__file__=activate_this))


class PasteWinService(win32serviceutil.ServiceFramework):

    def __init__(self, args):
        self._svc_name_ = args[0]

        override = getOverrideFromRegistry(self._svc_name_)
        self.ss = ServiceSettings(getCfgNameFromRegistry(self._svc_name_), override)
        self.ss.transferEssential(self)

        win32serviceutil.ServiceFramework.__init__(self, args)
        self.stop_event = win32event.CreateEvent(None, 0, 0, None)

    def SvcDoRun(self):

        if self.ss.getVirtualEnv():
            activate_virtualenv(self.ss.getVirtualEnv())

        os.chdir(self.ss.getCfgFileDir())
        sys.path.append(self.ss.getCfgFileDir())

        from paste.script.serve import ServeCommand as Server
        s = Server(None)
        args = [self.ss.getCfgFileName()]

        http_port = self.ss.getHttpPort()
        if http_port:
            args.append('http_port=' + str(http_port))

        s.run(args)
        win32event.WaitForSingleObject(self.stop_event, win32event.INFINITE)

    def SvcStop(self):
        self.ReportServiceStatus(win32service.SERVICE_STOP_PENDING)
        "send stop event"
        win32event.SetEvent(self.stop_event)
        "stop event sent"
        self.ReportServiceStatus(win32service.SERVICE_STOPPED)
        "Exit"
        sys.exit()


def getOverrideFromRegistry(svc_name):
    override = {}
    try:
        keys = win32serviceutil.GetServiceCustomOption(svc_name, 'wsgi_override_keys')
    except:
        return override

    for key in keys.split():
        try:
            val = win32serviceutil.GetServiceCustomOption(svc_name, 'wsgi_' + key)
        except:
            pass

        override[key] = val

    return override


def getCfgNameFromRegistry(svc_name):
    return win32serviceutil.GetServiceCustomOption(svc_name, 'wsgi_ini_file')


def custom_usage():
    print ""
    print "Option for wsgi deployments as windows services. This option is mandatory! :"
    print " -c config_file : the deployment ini file"
    print
    print "Optional settings for wsgi deployments via command line: "
    print " -n name : The name of the service "
    print " -d dispname : The display name of the service "
    print " -v virtualenv : the virtualenv to activate"


def usage():
    try:
        win32serviceutil.usage()
    except:
        custom_usage()


def handle_command_line(argv):

    options_pattern = "c:v:n:d:p:"
    optlist, args = getopt.getopt(sys.argv[1:], options_pattern)

    if not optlist:
        usage()
        return

    if not args:
        usage()
        return

    if len(args) == 1 and args[0] == 'list':
        print "List of wsgi services (display names) installed: "
        print listServices()
        return

    cmd_cfg_file = None
    override = {}

    for opt, val in optlist:
        if opt == '-c':
            cmd_cfg_file = val

        elif opt == '-n':
            override['svc_name'] = val

        elif opt == '-d':
            override['svc_display_name'] = val

        elif opt == '-v':
            override['virtual_env'] = os.path.abspath(val)

        elif opt == '-p':
            override['http_port'] = val

    if not cmd_cfg_file:
        print "Incorrect parameters"
        usage()
        return

    try:
        ds = ServiceSettings(os.path.abspath(cmd_cfg_file), override)

        class A(object):
            pass

        ds.transferEssential(A)
        win32serviceutil.HandleCommandLine(A, serviceClassString=getServiceClassString(PasteWinService, argv), argv=argv, customInstallOptions=options_pattern)
        win32serviceutil.SetServiceCustomOption(ds.getSvcName(), 'wsgi_ini_file', os.path.abspath(cmd_cfg_file))

        for key, value in override.items():
            win32serviceutil.SetServiceCustomOption(ds.getSvcName(), 'wsgi_' + key, value)

        if override:
            win32serviceutil.SetServiceCustomOption(ds.getSvcName(), 'wsgi_override_keys', ' '.join(override.keys()))

    except SystemExit, e:
        if e.code == 1:
            custom_usage()


def listServices():
    import win32api
    import win32con
    import prettytable
    wsgi_svcs = prettytable.PrettyTable(["name", "display name"])
    wsgi_svcs.set_field_align("name", "l")
    wsgi_svcs.set_field_align("display name", "l")
    services_key = win32api.RegOpenKey(win32con.HKEY_LOCAL_MACHINE, "System\\CurrentControlSet\\Services")
    i = 0
    try:
        while 1:
            svc_name = win32api.RegEnumKey(services_key, i)
            try:
                params_key = win32api.RegOpenKey(win32con.HKEY_LOCAL_MACHINE, "System\\CurrentControlSet\\Services\\" + svc_name + "\\Parameters")
                try:
                    win32api.RegQueryValueEx(params_key, 'wsgi_ini_file')[0]
                    main_svc_key = win32api.RegOpenKey(win32con.HKEY_LOCAL_MACHINE, "System\\CurrentControlSet\\Services\\" + svc_name)
                    try:
                        pass
                        wsgi_svcs.add_row([svc_name, win32api.RegQueryValueEx(main_svc_key, 'DisplayName')[0]])
                    except win32api.error:
                        pass
                    win32api.RegCloseKey(main_svc_key)
                except win32api.error:
                    pass
                win32api.RegCloseKey(params_key)
            except win32api.error:
                pass
            i = i + 1

    except:
        pass

    win32api.RegCloseKey(services_key)
    return str(wsgi_svcs)


def main():
    handle_command_line(argv=sys.argv)

if __name__ == '__main__':
    main()
