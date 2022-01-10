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
my ($sortBy, $folder, $id, $attrs);
$sortBy = "dateDesc";

#standard options
my ($user, $pw, $host, $help); #standard
GetOptions("u|user=s" => \$user,
           "pw=s" => \$pw,
           "h|host=s" => \$host,
           "help|?" => \$help,
           # add specific params below:
           "sort=s" => \$sortBy,
           "id=s" => \$id,
           "attrs=s" => \$attrs,
           "folder=s" => \$folder);



if (!defined($user) || defined($help)) {
    my $usage = <<END_OF_USAGE;
    
USAGE: $0 -u USER [-s SORT] [-i id_list] [-f folder] [-a attrs]
    SORT = dateDesc|dateAsc|subjDesc|subjAsc|nameDesc|nameAsc|score
    TYPES = message|conversation|contact|appointment
END_OF_USAGE
    die $usage;
}

my $z = ZimbraSoapTest->new($user, $host, $pw);
$z->doStdAuth();

my $d = new XmlDoc;
my $searchName = "GetContactsRequest";

my %args =  ( 
             'sortBy' => $sortBy,
            );

if (defined($folder)) {
  $args{"l"} = $folder;
}
  

$d->start("GetContactsRequest", $Soap::ZIMBRA_MAIL_NS, \%args);
{
  if (defined $id) {
    $d->add('cn', undef, { "id" => $id });
  }
  
  if (defined($attrs)) {
    foreach (split(/,/, $attrs)) {
      $d->add('a', undef, { "n" => $_ } );
    }
  }
}
$d->end();                      # 'GetContactsRequest'

my $response = $z->invokeMail($d->root());

print "REQUEST:\n-------------\n".$z->to_string_simple($d);
print "RESPONSE:\n--------------\n".$z->to_string_simple($response);

