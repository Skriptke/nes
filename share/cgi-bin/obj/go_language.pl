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
#  go_language.pl
#
# -----------------------------------------------------------------------------

  use Nes;
  my $nes = Nes::Singleton->new('./go_language.nhtml');
  
  my %tags;

    
  ( my $accept_language, my $none ) = split(/,/, $ENV{'HTTP_ACCEPT_LANGUAGE'}, 2);
  
  my $count = 1;
  while ( my $this_param = $nes->{'query'}->{'q'}{'go_language_param_'.$count} ) {
    my ( $lang, $url ) = split(/\s*:\s*/, $this_param, 2);
    if ( $accept_language =~ /^$lang/ || !$lang ) {
      $tags{'url'} = $url;
      $nes->out(%tags);
      $nes->{'container'}->{'content_obj'}->location( $url );
      return 1;
    }
    $count++;
  }


1;

