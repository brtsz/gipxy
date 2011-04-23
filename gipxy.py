#!/usr/bin/env python

import os, sys

from twisted.internet import protocol, reactor, utils
from twisted.protocols import basic
from twisted.python import log


class IrssiListenerProtocol(basic.LineOnlyReceiver):
    magic = 'GARYMOVEOUT'

    def __init__(self, resetDelay):
        self.resetDelay = resetDelay

    def connectionMade(self):
        self.fullyConnected = False

    def lineReceived(self, line):
        print 'got %d bytes: %s' % (len(line), line.encode('hex'))
        if not self.fullyConnected:
            if line == self.magi:
                self.fullyConnected = True
                self.resetDelay()
                p = self.transport.getPeer()
                self._notify('GI-PXY connected', 'Connected to %s:%d' % (p.host, p.port))
            else:
                log.msg('Connected to unknown service. Hmpf.')
                # TODO: What now?
                self.transport.loseConnection()
        else:
            title, _, message = line.partition('\0')
            self._notify(title, message)

    def _notify(self, title, message):
        args = ['-n', 'irssi', '-m', message, title]
        d = utils.getProcessOutput('growlnotify', args, env=os.environ)
        d.addErrback(log.err)
        return d


class GIPXYListenerFactory(protocol.ReconnectingClientFactory):
    protocol = IrssiListenerProtocol
    maxDelay = 60

    def buildProtocol(self, addr):
        print 'Connected!'
        return self.protocol(self.resetDelay)

    def clientConnectionLost(self, connector, reason):
        print 'Lost connection.  Reason:', reason
        protocol.ReconnectingClientFactory.clientConnectionLost(self, connector, reason)

    def clientConnectionFailed(self, connector, reason):
        print 'Connection failed. Reason:', reason
        protocol.ReconnectingClientFactory.clientConnectionFailed(self, connector, reason)

