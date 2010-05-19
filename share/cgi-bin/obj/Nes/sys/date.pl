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
#  date.pl
#
# -----------------------------------------------------------------------------

  use Nes::View;
  use strict;
  use POSIX qw(strftime);
  
  my $view   = Nes::View->new('./date.nhtml');
  my $q      = $view->{'query'}->{'q'};
  my $params = $view->{'obj_params'};
  
  my $local_gmt = $q->{'local_gmt'} || $params->[0] || shift @ARGV || 'local';
  my $format    = $q->{'format'}    || $params->[1] || "@ARGV"     || '%a %e %b %Y %H:%M:%S';
  
  my $vars = {};
  $vars->{'date'} = POSIX::strftime( "$format", localtime ); # default
  $vars->{'date'} = POSIX::strftime( "$format", gmtime ) if $local_gmt =~ /gmt/i;
  
  $view->fill($vars);

# don't forget to return a true value from the file
1;

