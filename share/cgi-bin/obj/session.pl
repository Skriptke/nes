#!/usr/bin/perl

# ------------------------------------------------------------------------------
#
#  NES by - Skriptke
#  Copyright 2009 - 2010 Enrique F. Castañón
#  Licensed under the GNU GPL.
#  http://nes.sourceforge.net/
# 
#  Version 0.8 beta
#
#  session.pl 
#
#  {: include ( '{: * cfg_obj_top_dir :}/session.nhtml',
#               action,  {: # default: get | create | del :}
#               user,    {: # if get action: user :}
#               expire   {: # if get action: expire :}
#             )
#  :}
#
#  Expire format:
#
#    time suffix: s: seconds, m: minutes h: hours d: days, M: months, y: years
#    30s = 30 seconds
#    12h = 12 hours
#    2y  = 2 years
#    ...
#
# ------------------------------------------------------------------------------

use Nes;
use strict;

my $nes = Nes::Singleton->new('./session.nhtml');
my $session = $nes->{'session'};
my $q = $nes->{'query'}->{'q'};

my $action = $q->{'session_param_1'} || 'get';
my $user   = $q->{'session_param_2'};
my $expire = $q->{'session_param_3'} || '24h';
my %tags;

if ( $action eq 'create' ) {
  $session->create($user, $expire);
}

if ( $action eq 'del' ) {
  $session->del;
}

if ( $action eq 'get' ) {
  $tags{'user'} = $session->{'user'};
}

$nes->out(%tags);

# don't forget to return a true value from the file
1;
