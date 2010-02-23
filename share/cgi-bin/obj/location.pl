#!/usr/bin/perl

# ------------------------------------------------------------------------------
#
#  NES by - Skriptke
#  Copyright 2009 - 2010 Enrique F. Castañón
#  Licensed under the GNU GPL.
#  http://sourceforge.net/projects/nes/
# 
#  Version 0.7 beta
#
#  location.pl 
#   {: include ('{: * cfg_obj_top_dir :}/location.nhtml', URL, [STATUS] ) :}
#
# ------------------------------------------------------------------------------

use Nes;
my $nes = Nes::Singleton->new('./location.nhtml');
my $url = $nes->{'query'}->{'q'}{'location_param_1'};
my $sta = $nes->{'query'}->{'q'}{'location_param_2'} || "302 Found";

my %tags;
$tags{'status'} = $sta;
$nes->out(%tags);

$nes->{'container'}->{'content_obj'}->location( $url, $sta );
