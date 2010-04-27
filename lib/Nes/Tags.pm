#!/bin/perl

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
#  Tags.pm
#
# -----------------------------------------------------------------------------

{
  package Nes::Tags;
  use strict;
  no warnings;
  
  $Nes::Tags::start     = '{:';
  $Nes::Tags::end       = ':}';
  $Nes::Tags::pre_start = '〈';
  $Nes::Tags::pre_end   = '〉';  
  
  $Nes::Tags::start_html     = '&#123;:';
  $Nes::Tags::end_html       = ':&#125;';  
  $Nes::Tags::pre_start_html = '&lang;';
  $Nes::Tags::pre_end_html   = '&rang;';    
  
  $Nes::Tags::pre_subs_start = ':&lang;:';
  $Nes::Tags::pre_subs_end   = ':&rang;:';  
  
  $Nes::Tags::nes     = 'NES';
  $Nes::Tags::var     = '\$';
  $Nes::Tags::env     = '\*';
  $Nes::Tags::expre   = '\~';
  $Nes::Tags::tpl     = '\@';
  $Nes::Tags::sql     = 'sql';
  $Nes::Tags::hash    = '\%';
  $Nes::Tags::field   = '\@\$';
  $Nes::Tags::include = 'include';
  $Nes::Tags::comment = '\#';
  $Nes::Tags::plugin  = '\&';
  
  $Nes::Tags::l_nes     = "NES";
  $Nes::Tags::l_var     = "\$";
  $Nes::Tags::l_env     = "\*";
  $Nes::Tags::l_expre   = "\~";
  $Nes::Tags::l_tpl     = "\@";
  $Nes::Tags::l_sql     = "sql";
  $Nes::Tags::l_hash    = "\%";
  $Nes::Tags::l_field   = "\@\$";
  $Nes::Tags::l_include = "include";
  $Nes::Tags::l_comment = "\#";
  $Nes::Tags::l_plugin  = "\&";   
  
  $Nes::Tags::all_or  = 'NES|\@\$|\$|\*|\~|\@|sql|\%|include|\#|\&';
}

1;