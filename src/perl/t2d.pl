#!/usr/bin/perl

# SPDX-FileCopyrightText: 2022 Synacor, Inc.
# SPDX-FileCopyrightText: 2022 Zextras <https://www.zextras.com>
#
# SPDX-License-Identifier: GPL-2.0-only

use strict;

if (@ARGV[0] eq "") {
    print "USAGE: t2d SECONDS_OR_MILLISECONDS_SINCE_EPOCH\n";
    exit(1);
}
my $str = @ARGV[0];
                
if ($str > 9999999999) {
    $str /= 1000;
}

my $now_string = localtime($str);

print "$now_string\n";
