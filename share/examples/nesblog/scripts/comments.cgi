#!/usr/bin/perl

# ------------------------------------------------------------------------------
#
#  NES by - Skriptke
#  Copyright 2009 - 2010 Enrique F. Castañón
#  Licensed under the GNU GPL.
#  http://sourceforge.net/projects/nes/
#
#  Version 0.9 pre
#
#  comments.cgi
#
#  Muestra los comentarios del artículo
#
# ------------------------------------------------------------------------------

use strict;

use Nes;

my $nes = Nes::Singleton->new();

# comentario para generar un enlace en "Ver fuente" a lib.cgi: ../scripts/lib.cgi
require 'lib.cgi';

# en $nes_tags vamos a guardar los valores que posteriormente le pasaremos a $nes en el método out
my $nes_tags = {};

# El objeto {'query'} maneja los métodos POST y GET y la variable {'q'} contiene
# los parametros de los métodos POST y GET de igual modo que el módulo CGI
# Esto es similar a hacer my $q = CGI->new; y podemos seguir haciendolo así.
# Aquí hemos asigando la variable en dos pasos como ejemplo se uso
# pero podemos hacer directamente my $q = $nes->{'query'}->{'q'};
my $query = $nes->{'query'};
my $q     = $query->{'q'};

my $lang = $ENV{'PATH_INFO'};
$lang =~ s/.*\/(..)\/[^\/]*/$1/;

$nes_tags->{'article'} = $q->{'item'} || last_article();
$nes_tags->{'lang'}    = $lang;

$nes->out(%$nes_tags);

1;
