use strict;
use Test::More tests => 2;

BEGIN { use_ok('Nes') };

my $output = `t/test.cgi`;
ok($output =~ /Testing Nes Templates/i,"Nes templates worked");
