#!/usr/bin/perl

# ------------------------------------------------------------------------------
#
#  NES by - Skriptke
#  Copyright 2009 - 2010 Enrique F. Castañón
#  Licensed under the GNU GPL.
#  http://nes.sourceforge.net/
# 
#  Version 0.9 pre
#
#  debug_info.pl
#
# ------------------------------------------------------------------------------

use strict;
use warnings;
use debug_info;

my $nes       = Nes::Singleton->new();
my $info      = debug_info->new($nes->{'container'});
my $container = $nes->{'container'};
my $config    = $nes->{'CFG'};

return 1 if $nes->{'top_container'}->get_nes_env('nes_remote_ip') !~ /^$config->{'debug_info_only_from_ip'}/;

$info->add();

if ( $nes->{'container'} eq $nes->{'top_container'}->{'container'} && $config->{'debug_info_show_in_out'} ) {
  
  $nes->{'container'}->set_out_content( $container->get_out_content.$info->{'out'} );

}

# don't forget to return a true value from the file
1;

