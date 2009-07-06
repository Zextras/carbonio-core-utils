#!/usr/bin/perl -w
# 
# ***** BEGIN LICENSE BLOCK *****
# 
# Zimbra Collaboration Suite Server
# Copyright (C) 2005, 2007 Zimbra, Inc.
# 
# The contents of this file are subject to the Yahoo! Public License
# Version 1.0 ("License"); you may not use this file except in
# compliance with the License.  You may obtain a copy of the License at
# http://www.zimbra.com/license.
# 
# Software distributed under the License is distributed on an "AS IS"
# basis, WITHOUT WARRANTY OF ANY KIND, either express or implied.
# 
# ***** END LICENSE BLOCK *****
# 

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
my $msgID = 0;
my $invID = 0;

if ($ARGV[1] ne "") {
    $userId = $ARGV[0];
    $msgID = $ARGV[1];
    if (defined($ARGV[2])) {
        $invID = $ARGV[2];
    }
} else {
    print "USAGE: getMsg USERID MAILITEM [INVID]\n";
    exit 1;
}
    

my $ACCTNS = "urn:zimbraAccount";
my $MAILNS = "urn:zimbraMail";

my $url = "http://localhost:7070/service/soap/";

my $SOAP = $Soap::Soap12;
my $d = new XmlDoc;
$d->start('AuthRequest', $ACCTNS);
$d->add('account', undef, { by => "name"}, $userId );
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

#

my %getApptSumAttrs = (
                       'id' => $msgID,
                       );

if ($invID != 0) {
    $getApptSumAttrs{'subId'} = $invID;
}

$d = new XmlDoc;
$d->start('GetMsgRequest', $MAILNS);
$d->start('m', $MAILNS, \%getApptSumAttrs);

$d->end(); # m
$d->end(); # GetMsgRequest

print "\nOUTGOING XML:\n-------------\n";
my $out =  $d->to_string("pretty")."\n";
$out =~ s/ns0\://g;
print $out."\n";

my $start = time;
my $firstStart = time;
my $response;

my $i = 0;
my $end;
my $avg;
my $elapsed;

#do {

    $start = time;
#    $msgAttrs{'sortby'} = "subjasc";
$response = $SOAP->invoke($url, $d->root(), $context);
#    $end = time;
#    $elapsed = $end - $start;
#    $avg = $elapsed *1000;
#    print("Ran iter in $elapsed time ($avg ms)\n");
    
#    $start = time;
#    $msgAttrs{'sortby'} = "subjdesc";
#$response = $SOAP->invoke($url, $d->root(), $context);
#    $end = time;
#    $elapsed = $end - $start;
#    $avg = $elapsed *1000;
#    print("Ran iter in $elapsed time ($avg ms)\n");

#$i++;
#} while($i < 50) ;

#my $lastEnd = time;
#$avg = ($lastEnd - $firstStart) / $i * 1000;
print "\nRESPONSE:\n--------------\n";
$out =  $response->to_string("pretty")."\n";
$out =~ s/ns0\://g;
print $out."\n";

# print("\nRan $i iters in $elapsed time (avg = $avg ms)\n");
