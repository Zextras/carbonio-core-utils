#!/usr/bin/perl -w

# SPDX-FileCopyrightText: 2022 Synacor, Inc.
# SPDX-FileCopyrightText: 2022 Zextras <https://www.zextras.com>
#
# SPDX-License-Identifier: GPL-2.0-only

#
# Simple SOAP test-harness for the AddMsg API
#

use Date::Parse;
use Time::HiRes qw ( time );
use strict;

use lib '.';

use LWP::UserAgent;

use XmlElement;
use XmlDoc;
use Soap;

my $userId;
my $addr;
my $show = "";
my $status;

if (defined $ARGV[1] && $ARGV[1] ne "") {
    $userId = shift(@ARGV);
    $show = shift(@ARGV);
    if (defined $ARGV[0]) {
        $status = shift(@ARGV);
    }
} else {
    print "USAGE: IMSetMyPres USERID SHOW [status]\n";
    exit 1;
}

print "Status is $status\n";

my $ACCTNS = "urn:zimbraAccount";
my $MAILNS = "urn:zimbraIM";

my $url = "http://localhost:7070/service/soap/";

my $SOAP = $Soap::Soap12;
my $d = new XmlDoc;
$d->start('AuthRequest', $ACCTNS);
$d->add('account', undef, { by => "name"}, $userId);
$d->add('password', undef, undef, "test123");
$d->end();

my $authResponse = $SOAP->invoke($url, $d->root());

print "AuthResponse = ".$authResponse->to_string("pretty")."\n";

my $authToken = $authResponse->find_child('authToken')->content;
print "authToken($authToken)\n";

my $sessionId = $authResponse->find_child('sessionId')->content;
print "sessionId = $sessionId\n";

my $context = $SOAP->zimbraContext($authToken, $sessionId);

my $contextStr = $context->to_string("pretty");
print("Context = $contextStr\n");

$d = new XmlDoc;
$d->start('IMSetPresenceRequest', $MAILNS);

if (!defined($status)) {
    $d->add('presence', $MAILNS, { "show" => $show} );
} else {
    $d->add('presence', $MAILNS, { "show" => $show, "status" => $status } );
}

$d->end(); #

print "\nOUTGOING XML:\n-------------\n";
my $out =  $d->to_string("pretty")."\n";
$out =~ s/ns0\://g;
print $out."\n";

my $response = $SOAP->invoke($url, $d->root(), $context);
print "\nRESPONSE:\n--------------\n";
$out =  $response->to_string("pretty")."\n";
$out =~ s/ns0\://g;
print $out."\n";

