#!/usr/bin/env perl -w

use strict;
use vars qw($VERSION %IRSSI @Listeners $Sock);
use IO::Socket;

use Irssi;

$VERSION = '0.1';
%IRSSI = (
        authors     => 'Bartosz Oler',
        contact     => 'http://github.com/brtsz/gipxy',
        name        => 'gipxy-broker',
        description => 'Sends notifications to Growl over a custom protocol.',
        license     => 'BSD',
        url         => 'http://github.com/brtsz/gipxy',
);

my %CHANNELS;

sub cmd_gipxy {
	my ($arg, $server, $witem) = @_;
	Irssi::command_runsub('gipxy', $arg, $server, $witem);
}

sub cmd_gipxy_test() {
	my ($arg, $server, $witem) = @_;

	my $count = scalar @Listeners;
	Irssi::print("%G>>%n Sending test message to $count listeners");
	for my $client (@Listeners) {
		broadcast("Test message", "Test message from gipxy-broker.");
	}
}

sub cmd_gipxy_reinit {
	my ($arg, $server, $witem) = @_;
	reinit();
}

sub reinit {
	my $chans = Irssi::settings_get_str('gipxy_channels');
	@CHANNELS{split($chans, / /)} = 1;

	for my $client (@Listeners) {
		$client->close();
	}

	$Sock->close() if defined $Sock;

	@Listeners = ();

	$Sock = new IO::Socket::INET (
		LocalHost => 'localhost',
		LocalPort => Irssi::settings_get_int('gipxy_port'),
		Proto => 'tcp',
		Listen => 1,
		Reuse => 1,
		Blocking => 0,
	);

	Irssi::print("%R>>%n Could not create socket: $!") unless $Sock;
	Irssi::input_add(fileno($Sock), INPUT_READ, 'handle_accept', "");
	Irssi::print("%G>>%n GIPXY reinitialized.");
}

sub broadcast {
	my $title = shift;
	my $message = shift;

	for my $client (@Listeners) {
		$client->send("$title\0$message\r\n");
	}
}

sub event_message_private {
	my ($server, $data, $nick, $address) = @_;

	broadcast("GI-PXY: Privmsg", "From $nick");
}

sub event_message_public {
	my ($server, $msg, $nick, $address, $target) = @_;

	if (exists $CHANNELS{$target}) {
		broadcast("GI-PXY: Channel Act", "$nick just wrote something");
	}
}

sub handle_accept {
	Irssi::print(">> Trying to handle accept...");
	my $client = $Sock->accept();
	Irssi::print(">> Accepted conn: $client");
	$client->send("GARYMOVEOUT\r\n");

	push @Listeners, $client;
}

Irssi::settings_add_int('gipxy', 'gipxy_port', 8001);
Irssi::settings_add_str('gipxy', 'gipxy_channels', '');

reinit();

Irssi::command_bind('gipxy', \&cmd_gipxy);
Irssi::command_bind('gipxy test',  \&cmd_gipxy_test);
Irssi::command_bind('gipxy reinit',  \&cmd_gipxy_reinit);

Irssi::signal_add_last('message private', 'event_message_private');
Irssi::signal_add_last('message public', 'event_message_public');

Irssi::print('%G>>%n '.$IRSSI{name}.' '.$VERSION.' loaded.');

