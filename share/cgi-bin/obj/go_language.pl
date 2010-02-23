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
#  go_language.pl 
#
#    {: include ('{: * cfg_obj_top_dir :}/go_language.nhtml', 
#                'es_ES: http//example.com/es_ES',
#                'es:    http//example.com/es_generic',
#                'en_US: http//example.com/en_US',
#                ...
#                ':      http//example.com/default'
#                )
#    :}
#
# ---------------------------------------------------------------------------------

  use Nes;
  my $nes = Nes::Singleton->new('./go_language.nhtml');
  
  ( my $accept_language, my $none ) = split(/,/, $ENV{'HTTP_ACCEPT_LANGUAGE'}, 2);
  
  my $count = 1;
  while ( my $this_param = $nes->{'query'}->{'q'}{'go_language_param_'.$count} ) {
    my ( $lang, $url ) = split(/\s*:\s*/, $this_param, 2);
    if ( $accept_language =~ /^$lang/ || !$lang ) {
      $nes->{'container'}->{'content_obj'}->location( $url );
      exit;
    }
    $count++;
  }


1;

