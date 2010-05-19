#!/usr/bin/perl


  use Nes::View;
  
  use strict;
  use warnings;   
  
  my $template = Nes::View->new();
#  my $template = Nes::Singleton->new();
#  warn "02:$template->{'container'}";
  
  my $vars->{'pp'} = 'pepe';
 
 
  $template->fill($vars);
 
1;
