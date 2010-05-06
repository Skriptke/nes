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

  use Nes;
  use strict;
  use POSIX qw(strftime);
  
  my $nes = Nes::Singleton->new('./date.nhtml');
  my $q   = $nes->{'query'}->{'q'};
  my $local_gmt = $q->{'local_gmt'} || $q->{'date_time_param_1'} || shift @ARGV || 'local';
  my $format    = $q->{'format'}    || $q->{'date_time_param_2'} || "@ARGV"     || '%a %e %b %Y %H:%M:%S';
  
  my $tags = {};
  $tags->{'date'} = POSIX::strftime( "$format", localtime ); # default
  $tags->{'date'} = POSIX::strftime( "$format", gmtime ) if $local_gmt =~ /gmt/i;
  
  $nes->out(%$tags);

# don't forget to return a true value from the file
1;

