import ConfigParser, os, sys

from twisted.application import internet, service

import gipxy


conf = ConfigParser.SafeConfigParser()
conf.read([
    'gipxy.conf',
    os.path.expanduser('~/.config/gipxy.conf'),
    ])

application = service.Application('gipxy')
serviceCollection = service.IServiceCollection(application)

internet.TCPClient(
    conf.get('broker', 'host'),
    conf.getint('broker', 'port'),
    gipxy.GIPXYListenerFactory()).setServiceParent(serviceCollection)


# vim: set ft=python:
