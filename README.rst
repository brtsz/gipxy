GI-PXY -- Growl-Irssi Proxy
===========================


Installation
============

1. Add LocalForward to ``~/.ssh/config`` on your local machine, something like this::

    Host myhost.com
    LocalForward 8001 127.0.0.1:8001

2. Install ``gipxy-broker.pl`` Irssi plugin. Copy it to ``~/.irssi/scripts``.

3. In Irssi run ``/run gipxy-broker.pl`` to load the script.

4. In Irssi use ``/set`` command to configure *gipxy*. Settings start with
   ``gipxy_``.

5. Install ``growlnotify`` application on your local machine. You can find it
   in *Extras* folder on the DMG with *Growl*.

6. Create a virtualenv and install Twisted in it.

7. Copy ``gipxy.conf.sample`` to ``~/.config/gipxy.conf`` and edit it.

8. Run: ``./run-gipxy-listener`` and enjoy. Listener will automatically daemonize. By default logs and pid is stored in ``/tmp/gipxy.{pid,log}``.


.. vim: set sw=4 ts=4 sts=4 et:
