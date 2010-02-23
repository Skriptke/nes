#!/usr/bin/perl

# ------------------------------------------------------------------------------
#
#  NES by - Skriptke
#  Copyright 2009 - 2010 Enrique F. Castañón
#  Licensed under the GNU GPL.
#  http://sourceforge.net/projects/nes/
# 
#  Version 0.8 beta
#
#  suerte.cgi 
#
# ------------------------------------------------------------------------------

use strict;
use Nes;

my $nes = Nes::Singleton->new('./suerte.html');

my $tags = {};

$tags->{'numero_suerte'} = int (rand 10); # el número de la suerte

$nes->out(%$tags);


1;
