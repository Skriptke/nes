#!/usr/bin/perl

# ------------------------------------------------------------------------------
#
#  NES by - Skriptke
#  Copyright 2009 - 2010 Enrique F. Castañón
#  Licensed under the GNU GPL.
#  http://nes.sourceforge.net/
# 
#  Version 0.9 pre
#
#  item.cgi
#
# ------------------------------------------------------------------------------

use Nes;

# Creamos un objeto de la clase Singleton
my $nes = Nes::Singleton->new('../es/index.html');

require 'lib.cgi';

# archivo de configuración .nes.cfg
my $config = $nes->{'CFG'};

# en %tags vamos a guardar los valores que posteriormente le pasaremos a 
# $nes en el método out
my $nes_tags = {};

# El objeto {'query'} maneja los métodos POST y GET y la variable {'q'} contiene
# los parametros de los métodos POST y GET de igual modo que el módulo CGI
# Esto es similar a hacer my $q = CGI->new; y podemos seguir haciendolo así.
# Aquí hemos asigando la variable en dos pasos como ejemplo se uso
# pero podemos hacer directamente my $q = $nes->{'query'}->{'q'};
my $query = $nes->{'query'};
my $q     = $query->{'q'};

# si ?item= no tiene valor mostramos el último artículo creado
my $item_name = $q->{'item'} || last_article();
my $file_name = $config->{'miniblog_item_dir'} . '/' . $item_name . '.html';

$nes_tags->{'item_name'} = $item_name;
$nes_tags->{'article'}   = $file_name;

# por último mostramos la página pasandole los datos en el método out
$nes->out(%$nes_tags);

# importante que devuelvan 1 para evitar un error "couldn't run"
1;
