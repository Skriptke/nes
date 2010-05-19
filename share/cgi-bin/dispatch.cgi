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
#  dispatch.cgi
#
# -----------------------------------------------------------------------------

  package dispatch;
  use strict;
  use Nes::View;

  Nes::View->new_by_dispatch->run;
  