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
#  show_source.cgi 
# 
#  Utilidad para navegar por el código fuente del ejemplo de use Nes;
#
# ------------------------------------------------------------------------------

use Nes;

# Creamos un objeto de la clase Singleton
my $nes = Nes::Singleton->new();

# en $nes_tags vamos a guardar los valores que posteriormente le pasaremos a $nes en el método out
my $nes_tags = {};

# El objeto {'query'} maneja los métodos POST y GET y la variable {'q'} contiene
# los parametros de los métodos POST y GET de igual modo que el módulo CGI
# Esto es similar a hacer my $q = CGI->new; y podemos seguir haciendolo así.
# Aquí hemos asigando la variable en dos pasos como ejemplo se uso
# pero podemos hacer directamente my $q = $nes->{'query'}->{'q'};
my $query = $nes->{'query'};
my $q = $query->{'q'};


# buscamos el directorio raiz de la web, DOCUMENT_ROOT puede dar otro distinto
my ($document_root) = split("$ENV{'PATH_INFO'}",$ENV{'PATH_TRANSLATED'});

# obtenemos el archivo mediante PATH_INFO si file no está definido
my $file = $q->{'show_source_param_1'} || $ENV{'PATH_INFO'};

my $path = $ENV{'PATH_INFO'};
$path =~ s/\/(.*\/).*/\/$1/;

# impedimos que se puedan leer archivos distintos a los de esta utilidad.
while ( $file =~ s/\.\.\/\.\.\/\.\.\//\.\.\/\.\.\//g ) {}
my $file_open = $document_root.$file;

open(F,$file_open);
my @file = <F>;
close F;

$nes_tags->{'file_name'}   = $file;
$nes_tags->{'file_open'}   = $file_open;
$nes_tags->{'file_source'} = "@file";

# impedimos que se puedan leer archivos distintos a los de esta utilidad.
$nes_tags->{'file_source'} = '' if ! -e $file_open; 
$nes_tags->{'file_source'} = '' if $file_open !~ /\.(cgi|html|htm|nhtml|nhtm|pl|pm|sh|php|txt|nsql)$/;

# hacemos visible el HTML
$nes_tags->{'file_source'} =~ s/\</&lt;/g;
$nes_tags->{'file_source'} =~ s/\>/&gt;/g;
$nes_tags->{'file_source'} =~ s/\{/&#123;/g;
$nes_tags->{'file_source'} =~ s/\}/&#125;/g;

# creamos enlaces a los archivos incluidos
$nes_tags->{'file_source'} =~ s/((\.\/|\.\.\/)+[\w\d\%\-\/]*\.(cgi|html|htm|nhtml|nhtm|pl|pm|sh|php|txt|nsql))/\<a href=\"?show_source=$path$1\">$1<\/a>/g;

# creamos enlaces a la descriptción de los Tags
$nes_tags->{'file_source'} =~ s/(&#123;:)(\s*)(include)/$1$2\<a href=\".\/?item=Tag include (file)\">$3<\/a>/g;
$nes_tags->{'file_source'} =~ s/(&#123;:)(\s*)(\#)/$1$2\<a href=\".\/?item=Tag comentario\">$3<\/a>/g;
$nes_tags->{'file_source'} =~ s/(&#123;:)(\s*)(\$)/$1$2\<a href=\".\/?item=Tag \$ (variable)\">$3<\/a>/g;
$nes_tags->{'file_source'} =~ s/(&#123;:)(\s*)(\*)/$1$2\<a href=\".\/?item=Tag \* (environment_variable)\">$3<\/a>/g;
$nes_tags->{'file_source'} =~ s/(&#123;:)(\s*)(\@\$|\@)/$1$2\<a href=\".\/?item=Tag @ (table)\">$3<\/a>/g;
$nes_tags->{'file_source'} =~ s/(&#123;:)(\s*)(\~)/$1$2\<a href=\".\/?item=Tag \~ (expresión)\">$3<\/a>/g;
$nes_tags->{'file_source'} =~ s/(&#123;:)(\s*)(NES)/$1$2\<a href=\".\/?item=Tag NES ver (file)\">$3<\/a>/g;
$nes_tags->{'file_source'} =~ s/(&#123;:)(\s*)(sql)/$1$2\<a href=\".\/?item=Tag sql (SQL SELECT)\">$3<\/a>/g;
$nes_tags->{'file_source'} =~ s/(&#123;:)(\s*)(\&\s*captcha)/$1$2\<a href=\".\/?item=Plugin Captcha\">$3<\/a>/g;
$nes_tags->{'file_source'} =~ s/(&#123;:)(\s*)(\&\s*form)/$1$2\<a href=\".\/?item=Plugin Forms\">$3<\/a>/g;

# por último mostramos la página pasandole los datos en el método out
$nes->out(%$nes_tags);

# don't forget to return a true value from the file
1;
