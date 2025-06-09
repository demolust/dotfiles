# This is a sample commands.py.  You can add your own commands here.
#
# Please refer to commands_full.py for all the default commands and a complete
# documentation.  Do NOT add them all here, or you may end up with defunct
# commands when upgrading ranger.

# A simple command for demonstration purposes follows.
# -----------------------------------------------------------------------------

from __future__ import (absolute_import, division, print_function)

# You can import any python module as needed.
import os, shutil

# You always need to import ranger.api.commands here to get the Command class:
from ranger.api.commands import Command

home = os.path.expanduser("~")
relative_trash = ".local/share/Trash"
trash = os.path.join(home, relative_trash)

# Any class that is a subclass of "Command" will be integrated into ranger as a
# command.  Try typing ":my_edit<ENTER>" in ranger!
class my_edit(Command):
    # The so-called doc-string of the class will be visible in the built-in
    # help that is accessible by typing "?c" inside ranger.
    """:my_edit <filename>

    A sample command for demonstration purposes that opens a file in an editor.
    """

    # The execute method is called when you run this command in ranger.
    def execute(self):
        # self.arg(1) is the first (space-separated) argument to the function.
        # This way you can write ":my_edit somefilename<ENTER>".
        if self.arg(1):
            # self.rest(1) contains self.arg(1) and everything that follows
            target_filename = self.rest(1)
        else:
            # self.fm is a ranger.core.filemanager.FileManager object and gives
            # you access to internals of ranger.
            # self.fm.thisfile is a ranger.container.file.File object and is a
            # reference to the currently selected file.
            target_filename = self.fm.thisfile.path

        # This is a generic function to print text in ranger.
        self.fm.notify("Let's edit the file " + target_filename + "!")

        # Using bad=True in fm.notify allows you to print error messages:
        if not os.path.exists(target_filename):
            self.fm.notify("The given file does not exist!", bad=True)
            return

        # This executes a function from ranger.core.acitons, a module with a
        # variety of subroutines that can help you construct commands.
        # Check out the source, or run "pydoc ranger.core.actions" for a list.
        self.fm.edit_file(target_filename)

    # The tab method is called when you press tab, and should return a list of
    # suggestions that the user will tab through.
    # tabnum is 1 for <TAB> and -1 for <S-TAB> by default
    def tab(self, tabnum):
        # This is a generic tab-completion function that iterates through the
        # content of the current directory.
        return self._tab_directory_content()


class empty(Command):
    """:empty
        Deletes all files and dirs of the trash directory
    """

    def execute(self):
        cmd = "find %s -mindepth 1 -maxdepth 1 -exec rm -rf {} \\;" % (trash)
        self.fm.run(cmd)

from ranger.ext.img_display import ImageDisplayer, register_image_displayer
import subprocess
from shlex import quote, split

@register_image_displayer("wezterm-image-display-method")
class WeztermImageDisplayer(ImageDisplayer):

    def draw(self, path, start_x, start_y, width, height):
        print("\033[%d;%dH" % (start_y, start_x + 1))
        path = quote(path)
        draw_cmd = "wezterm imgcat {} --tmux-passthru detect --width={} --height={}".format(path, width, height)
        #draw_cmd = "wezterm imgcat {} --tmux-passthru detect --width=45% --height=50%".format(path)
        subprocess.run(split(draw_cmd))

    def clear(self, start_x, start_y, width, height):
        cleaner = " " * width
        for i in range(height):
            print("\033[%d;%dH" % (start_y + i, start_x + 1))
            print(cleaner)

"""
from ranger.ext.img_display import ImageDisplayer, register_image_displayer
import subprocess
from shlex import quote

@register_image_displayer("wezterm-image-display-method")
class WeztermImageDisplayer(ImageDisplayer):
    def draw(self, path, start_x, start_y, width, height):
        print("\033[%d;%dH" % (start_y, start_x+1))
        path = quote(path)
        draw_cmd = "wezterm imgcat {} --width {} --height {}".format(path, width, height)
        subprocess.run(draw_cmd.split(" "))
    def clear(self, start_x, start_y, width, height):
        cleaner = " "*width
        for i in range(height):
            print("\033[%d;%dH" % (start_y+i, start_x+1))
            print(cleaner)
"""

import subprocess
import json
import atexit
import socket
import sys
from pathlib import Path

import logging
logger = logging.getLogger(__name__)
import traceback

from ranger.ext.img_display import ImageDisplayer, register_image_displayer

@register_image_displayer("mpv")
class MPVImageDisplayer(ImageDisplayer):
    """Implementation of ImageDisplayer using mpv, a general media viewer.
    Opens media in a separate X window.

    mpv 0.25+ needs to be installed for this to work.
    """

    def _send_command(self, path, sock):

        message = '{"command": ["raw","loadfile",%s]}\n' % json.dumps(path)
        s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        s.connect(str(sock))
        logger.info('-> ' + message)
        s.send(message.encode())
        message = s.recv(1024).decode()
        logger.info('<- ' + message)

    def _launch_mpv(self, path, sock):

        proc = subprocess.Popen([
            * os.environ.get("MPV", "mpv").split(),
            "--no-terminal",
            "--force-window",
            "--input-ipc-server=" + str(sock),
            "--image-display-duration=inf",
            "--loop-file=inf",
            "--no-osc",
            "--no-input-default-bindings",
            "--keep-open",
            "--idle",
            "--",
            path,
        ])

        @atexit.register
        def cleanup():
            proc.terminate()
            sock.unlink()

    def draw(self, path, start_x, start_y, width, height):

        path = os.path.abspath(path)
        cache = Path(os.environ.get("XDG_CACHE_HOME", "~/.cache")).expanduser()
        cache = cache / "ranger"
        cache.mkdir(exist_ok=True)
        sock = cache / "mpv.sock"

        try:
            self._send_command(path, sock)
        except (ConnectionRefusedError, FileNotFoundError):
            logger.info('LAUNCHING ' + path)
            self._launch_mpv(path, sock)
        except Exception as e:
            logger.exception(traceback.format_exc())
            sys.exit(1)
        logger.info('SUCCESS')

from ranger.ext.img_display import ImageDisplayer, register_image_displayer
from subprocess import Popen, PIPE, run
import time

@register_image_displayer("imv")
class IMVImageDisplayer(ImageDisplayer):
    """
    Implementation of ImageDisplayer using imv
    """
    is_initialized = False

    def __init__(self):
        self.process = None

    def initialize(self):
        """ start imv """
        if (self.is_initialized and self.process.poll() is None and
                not self.process.stdin.closed):
            return

        self.process = Popen(['imv'], cwd=self.working_dir,
                             stdin=PIPE, universal_newlines=True)
        self.is_initialized = True
        time.sleep(1)

    def draw(self, path, start_x, start_y, width, height):
        self.initialize()
        run(['imv-msg', str(self.process.pid), 'close'])
        run(['imv-msg', str(self.process.pid), 'open', path])

    def clear(self, start_x, start_y, width, height):
        self.initialize()
        run(['imv-msg', str(self.process.pid), 'close'])

    def quit(self):
        if self.is_initialized and self.process.poll() is None:
            self.process.terminate()

