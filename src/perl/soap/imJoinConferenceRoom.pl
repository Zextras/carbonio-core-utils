#!/usr/bin/perl -w

# SPDX-FileCopyrightText: 2022 Synacor, Inc.
# SPDX-FileCopyrightText: 2022 Zextras <https://www.zextras.com>
#
# SPDX-License-Identifier: GPL-2.0-only

use strict;
use lib '.';

use LWP::UserAgent;
use Getopt::Long;
use XmlDoc;
use Soap;
use ZimbraSoapTest;

# specific to this app
my ($threadId, $addr, $nickname, $pass);

#standard options
my ($user, $pw, $host, $help); #standard
GetOptions("u|user=s" => \$user,
           "pw=s" => \$pw,
           "h|host=s" => \$host,
           "help|?" => \$help,
           # add specific params below:
           "t=s", \$threadId,
           "a=s", \$addr,
           "n=s", \$nickname,
           "pass=s", \$pass,
          );



if (!defined($user) || !defined($addr) || defined($help)) {
    my $usage = <<END_OF_USAGE;
    
USAGE: $0 -u USER [-t threadId] -a addr [-n nickname] [-pass room_password]
END_OF_USAGE
    die $usage;
}

my $z = ZimbraSoapTest->new($user, $host, $pw);
$z->doStdAuth();

my $d = new XmlDoc;
my $searchName = "SearchRequest";

my %args = ('addr' => $addr, 'thread' => $threadId);

if (defined $nickname) {
  $args{'nick'} = $nickname;
}

if (defined $pass) {
  $args{'password'} = $pass;
}

$d->start("IMJoinConferenceRoomRequest", $Soap::ZIMBRA_IM_NS, \%args);

$d->end(); 

my $response = $z->invokeMail($d->root());

print "REQUEST:\n-------------\n".$z->to_string_simple($d);
print "RESPONSE:\n--------------\n".$z->to_string_simple($response);

