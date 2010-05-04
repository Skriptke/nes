#!/usr/bin/perl

# -----------------------------------------------------------------------------
#
#  Nes by Skriptke
#  Copyright 2009 - 2010 Enrique F. Castañón Barbero & Luis Romero
#  Licensed under the GNU GPL.
#
#  CPAN:
#  http://search.cpan.org/dist/Nes/
#
#  Sample:
#  http://nes.sourceforge.net/
#
#  Repository:
#  http://github.com/Skriptke/nes
# 
#  Version 1.03
#
#  respondedor.pl
#
# -----------------------------------------------------------------------------

use Nes;
my $nes = Nes::Singleton->new();
my $q   = $nes->{'query'}->{'q'};
my $cgi = $nes->{'query'}->{'CGI'};
my $nes_tags  = {};

sleep 1;
$nes_tags->{'time'}  = time;

foreach my $param ( $cgi->param ) {
    my %tag;
    $tag{'name'}  = $param;
    $tag{'value'} = $cgi->param($param);
    push(@{$nes_tags->{'params'}},\%tag);
}


$nes->out(%$nes_tags);

1;
