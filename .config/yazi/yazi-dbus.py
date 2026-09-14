#!/usr/bin/env python3
import os
import sys
import subprocess
from urllib.parse import unquote, urlparse
import dbus
import dbus.service
from dbus.mainloop.glib import DBusGMainLoop
from gi.repository import GLib

class FileManager(dbus.service.Object):
    def __init__(self):
        bus_name = dbus.service.BusName('org.freedesktop.FileManager1', bus=dbus.SessionBus())
        super().__init__(bus_name, '/org/freedesktop/FileManager1')

    def _open_path(self, uri):
        try:
            parsed = urlparse(uri)
            if parsed.scheme == 'file':
                path = unquote(parsed.path)
            else:
                path = unquote(uri)
            
            if os.path.exists(path):
                # If it's a file, open its parent or the path itself
                subprocess.Popen(['kitty', '-e', 'yazi', path])
        except Exception as e:
            print(f"Error opening URI {uri}: {e}", file=sys.stderr)

    @dbus.service.method('org.freedesktop.FileManager1', in_signature='ass', out_signature='')
    def ShowFolders(self, URIs, startup_id):
        if URIs:
            self._open_path(URIs[0])

    @dbus.service.method('org.freedesktop.FileManager1', in_signature='ass', out_signature='')
    def ShowItems(self, URIs, startup_id):
        if URIs:
            self._open_path(URIs[0])

    @dbus.service.method('org.freedesktop.FileManager1', in_signature='ass', out_signature='')
    def ShowItemProperties(self, URIs, startup_id):
        pass

if __name__ == '__main__':
    DBusGMainLoop(set_as_default=True)
    loop = GLib.MainLoop()
    obj = FileManager()
    loop.run()
