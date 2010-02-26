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
#  CPAN:
#  http://search.cpan.org/perldoc?Nes
# 
#  Version 1.00
#
#  form_comment.cgi
#
# ------------------------------------------------------------------------------

use Nes;

# Creamos un objeto de la clase Singleton
my $nes = Nes::Singleton->new;

require 'lib.cgi';

# archivo de configuración .nes.cfg
my $config = $nes->{'CFG'};

# Obtenemos la direción de los plugin, para comprobar posteriormente que no hay errores
my $formulario = nes_plugin->get( 'forms_plugin', 'form1' );

# Cuando el Captcha se usa junto Forms, no es necesario comprobar el Captcha, Forms se ocupa
# my $captcha    = nes_plugin->get('captcha_plugin','captcha1');

# en %tags vamos a guardar los valores que posteriormente le pasaremos a $nes en el método out
my $nes_tags = {};

$nes_tags->{'firma_ok'} = 0;

# El objeto {'query'} maneja los métodos POST y GET y la variable {'q'} contiene
# los parametros de los métodos POST y GET de igual modo que el módulo CGI
# Esto es similar a hacer my $q = CGI->new; y podemos seguir haciendolo así.
# Aquí hemos asigando la variable en dos pasos como ejemplo se uso
# pero podemos hacer directamente my $q = $nes->{'query'}->{'q'};
my $query = $nes->{'query'};
my $q     = $query->{'q'};

# los campos del formulario
# quote es DBI::quote impite inyección de código SQL
my $comentario = utl::quote( $q->{'comentario'} );
my $nombre     = utl::quote( $q->{'nombre'} );
my $email      = utl::quote( $q->{'email'} );
my $article    = utl::quote( $q->{'item'} );
my $submit     = utl::quote( $q->{'enviar'} );

my $lang = $ENV{'PATH_INFO'};
$lang =~ s/.*\/(..)\/[^\/]*/$1/;
$lang = utl::quote( $lang );

$nes_tags->{'item'} = $q->{'item'} || last_article();
$nes_tags->{'item'} = last_article() if ! -e "$config->{'miniblog_item_dir'}/$nes_tags->{'item'}.html"; 

if ( !$formulario->{'is_ok'} ) {

  # no se ha pulsado el boton de envio y es la primera entrada
  # al formulario o existe algún error en los campos o captcha.
  # ** No hacemos nada **
  
} else {

  use Nes::DB;
  my $config = $nes->{'CFG'};
  my $name   = $config->{'DB_base'};
  my $user   = $config->{'DB_user'};
  my $pass   = $config->{'DB_pass'};
  my $driver = $config->{'DB_driver'};
  my $host   = $config->{'DB_host'};
  my $port   = $config->{'DB_port'};
  my $base   = Nes::DB->new( $name, $user, $pass, $driver, $host, $port );

  # filtramos retorno de carro
  $comentario =~ s/\n/<br>/g;
  # máximo dos retornos de carro seguidos
  while ( $comentario =~ s/<br><br><br>/<br><br>/g ) { }

  # filtramos el HTML
  $comentario = utl::no_html($comentario,'br');
  $nombre     = utl::no_html($nombre);
  $email      = utl::no_html($email);

  my $values = qq~$article,$lang,$nombre,$comentario,$email,NOW()~;

  my $sql = qq~INSERT INTO `comments` 
                (
                  `article` ,
                  `lang` ,
                  `name` ,
                  `comment` ,
                  `email` ,
                  `date`
                )
                VALUES 
                (
                  $values
                );~;

  $base->sen_no_select($sql);

  $nes_tags->{'firma_ok'} = 1;
}

# por último mostramos la página pasandole los datos en el método out
$nes->out(%$nes_tags);

# importante que devuelvan 1 para evitar un error "couldn't run"
1;
