#!/bin/perl

# -----------------------------------------------------------------------------
#
#  Nes by Skriptke
#  Copyright 2009 - 2010 Enrique Castañón
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
#  Version 1.03
#
#  multi_step_captcha.pl
#
#  DOCUMENTATION:
#  perldoc Nes::Obj::multi_step  
#
# -----------------------------------------------------------------------------

use strict;
use multi_step;

my $nes     = Nes::Singleton->new();
my $nes_env = $nes->{'top_container'}->{'nes_env'};
my $cfg     = $nes->{'CFG'};
my $vars    = multi_step->new;

if ( $nes->{'query'}->{'q'}{'_'.$vars->{'form_name'}.'_step'} > $#{$vars->{'steps'}} && $vars->{'show_captcha'} ) {

  my $dir_plugin = $cfg->{'plugin_top_dir'};

  # Insecure dependency in require while running with -T switch at
  if ($dir_plugin =~ /^([-\@\w.\\\/]+)$/) {
      $dir_plugin = $1;                  
  }    

  $nes->add(%$vars);
  push( @INC, $dir_plugin );
  do "$dir_plugin/captcha.pl";
  
  $vars->{'captcha_error_fatal'} = 1 if $nes_env->{'nes_captcha_plugin_'.$vars->{'captcha_name'}.'_error_fatal'} =~ /1|3|4/;
  $vars->{'captcha_error'}       = $nes_env->{'nes_captcha_plugin_'.$vars->{'captcha_name'}.'_error_fatal'};
  $vars->{'captcha_ok'}          = $nes_env->{'nes_captcha_plugin_'.$vars->{'captcha_name'}.'_is_ok'};
  $nes->add(%$vars);
  
  my $captcha = nes_plugin->get( 'captcha_plugin', $vars->{'captcha_name'} );
  $captcha->{'tmp'}->clear() if $vars->{'captcha_ok'}; 
  
} 

# don't forget to return a true value from the file
1;

