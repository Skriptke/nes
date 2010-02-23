#!/usr/bin/perl

# ------------------------------------------------------------------------------
#
#  NES by - Skriptke
#  Copyright 2009 - 2010 Enrique F. Castañón
#  Licensed under the GNU GPL.
#  http://sourceforge.net/projects/nes/
#
#  Version 0.7 beta
#
#  lib.cgi
#
# ------------------------------------------------------------------------------

use Nes;

my $nes = Nes::Singleton->new();

# archivo de configuración .nes.cfg
my $config = $nes->{'CFG'};

# obtiene el último artículo publicado
sub last_article {

  my @articles = latest(1);

  return $articles[0]->{'name'};
}

# obtiene $num últimos artículos publicados, ordenados por fecha
sub latest {
  my ( $num, $dirname ) = @_;
  $dirname = $config->{'miniblog_item_dir'} || './items' if !$dirname;
  $num     = 1000      if $num <= 0;    # nunca está de más poner límites
  my @articles;

  opendir( DIR, $dirname );
  my @files = sort { -M "$dirname/$a" <=> -M "$dirname/$b" } readdir(DIR);
  closedir(DIR);

  my $count = 0;
  foreach my $filename (@files) {
    my %this;
    $filename =~ s/(.*)\.html$/$1/ || next;
    last if $count++ >= $num;
    $this{'name'} = $filename;
    push( @articles, \%this );
  }

  return @articles;
}

sub fecha {

  my $ampm = "AM";
  my ( $minuto, $hora, $dia, $mes, $anio ) = ( localtime(time) )[ 1, 2, 3, 4, 5 ];
  $mes++;
  $ampm   = "PM"          if ( $hora > 11 );
  $hora   = $hora - 12    if ( $hora > 12 );
  $minuto = "0" . $minuto if ( length($minuto) == 1 );
  $anio += 1900;

  return ("$mes/$dia/$anio $hora:$minuto $ampm");
}

# importante que devuelvan 1 para evitar un error "couldn't run"
1;
