#!/usr/bin/perl

# -----------------------------------------------------------------------------
#
#  Nes by Skriptke
#  Copyright 2009 - 2010 Enrique F. Castañón
#  Licensed under the GNU GPL.
#
#  Sample:
#  http://nes.sourceforge.net/
#
#  Repository:
#  http://github.com/Skriptke/nes
# 
#  Version 1.00_02
#
#  dispatch.cgi
#
# -----------------------------------------------------------------------------

use strict;
use Nes;

{ 
  
  package dispatch;

  my $nes = Nes::Singleton->new();
  $nes->run();
  
}

