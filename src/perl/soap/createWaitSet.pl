#!/usr/bin/perl

# SPDX-FileCopyrightText: 2022 Synacor, Inc.
# SPDX-FileCopyrightText: 2022 Zextras <https://www.zextras.com>
#
# SPDX-License-Identifier: GPL-2.0-only

use strict;
use warnings;
use lib '.';

use LWP::UserAgent;
use Getopt::Long;
use XmlDoc;
use Soap;
use ZimbraSoapTest;

# If you're using ActivePerl, you'll need to go and install the Crypt::SSLeay
# module for htps: to work...
#
#         ppm install http://theoryx5.uwinnipeg.ca/ppms/Crypt-SSLeay.ppd
#
# specific to this app
my ($defTypes, $accounts, $admin, $allAccounts);

#standard options
my ($user, $pw, $host, $help); #standard
my ($name, $value);
GetOptions("u|user=s" => \$user,
           "pw=s" => \$pw,
           "h|host=s" => \$host,
           "help|?" => \$help,
           # add specific params below:
           "d=s"  => \$defTypes,
           "a=s@" => \$accounts,
           "admin" => \$admin,
           "allAccounts" => \$allAccounts,
          );

if (!defined($user) || defined($help) || !defined($defTypes)) {
  my $usage = <<END_OF_USAGE;
    
USAGE: $0 -u USER -d defTypes [-admin [-allAccounts]] [-a account -a account...]
END_OF_USAGE
    die $usage;
}

my $z = ZimbraSoapTest->new($user, $host, $pw);

my $urn;
my $requestName;

if (defined($admin)) {
  $z->doAdminAuth();
  $urn = $Soap::ZIMBRA_ADMIN_NS;
  $requestName = "AdminCreateWaitSetRequest";
} else {
  $z->doStdAuth();
  $urn = $Soap::ZIMBRA_MAIL_NS;
  $requestName = "CreateWaitSetRequest";
}

my %args =  (  'defTypes' => "$defTypes" );

if (defined $allAccounts) {
  $args{'allAccounts'} = "1";
}
              

my $d = new XmlDoc;
  
$d->start($requestName, $urn, \%args);

if (defined $accounts) {
  $d->start("add");
  {
    foreach my $a (@$accounts) {
      (my $aid, my $tok) = split /,/,$a;
      if (!defined $tok) {
        $d->add("a", undef, { 'name' => $a, }); #'token'=>"608"
      } else {
        $d->add("a", undef, { 'name' => $aid, 'token'=>$tok}); 
      }
    }
  } $d->end(); # add
}
$d->end(); # 'CreateWaitSetRequest'

my $response;

if (defined($admin)) {
  $response = $z->invokeAdmin($d->root());
} else {
  $response = $z->invokeMail($d->root());
}

print "REQUEST:\n-------------\n".$z->to_string_simple($d);
print "RESPONSE:\n--------------\n".$z->to_string_simple($response);

          
