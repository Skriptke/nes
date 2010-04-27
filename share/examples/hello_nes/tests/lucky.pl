#!/usr/bin/perl

# -----------------------------------------------------------------------------
#
#  Nes by Skriptke
#  Copyright 2009 - 2010 Enrique F. Castañón Barbero
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
#  Version 1.04
#
#  lucky.pl
#
# -----------------------------------------------------------------------------

  use Nes;
  my $nes = Nes::Singleton->new('./lucky.nhtml');
  my $q   = $nes->{'query'}->{'q'};
  my $min = $q->{'lucky_param_1'} || 0;
  my $max = $q->{'lucky_param_2'} || 9;
   
  my %nes_tags;
  $nes_tags{'number'} = $min + int(rand($max+1-$min));
  
  $nes->out(%nes_tags);

1;
