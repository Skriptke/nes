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
#  Version 1.04
#
#  secure_login.pl
#
#  DOCUMENTATION:
#  perldoc Nes::Obj::secure_login
#
# -----------------------------------------------------------------------------

use Nes;
use secure_login;

my $nes      = Nes::Singleton->new;
my $vars     = secure_login->new;
my $top      = $nes->{'top_container'};
my $obj      = $nes->{'query'}->{'q'}{'obj_param_0'};
my $nes_env  = $top->{'nes_env'};
my $fld_user = $vars->{'form_name'}.'_User';
my $fld_pass = $vars->{'form_name'}.'_Password';
my $fld_send = $vars->{'form_name'}.'_send';
my $is_send  = $nes->{'query'}->{'q'}{$fld_send};
my $theuser  = $nes->{'query'}->{'q'}{$fld_user} || 'pppp';
my $thepass  = $nes->{'query'}->{'q'}{$fld_pass} || 'pppp';  
my $form     = $nes->{'register'}->get( 'fc_plugin', $vars->{'form_name'} );


if ( $form->{'is_ok'} ) {

  if ( $vars->{'script_handler'} && $vars->{'function_handler'} ) {
    require "$vars->{'script_handler'}";
    my $handler = \&{$vars->{'function_handler'}};
    $vars->{'login_id'} = $handler->($theuser,$thepass);
  } 
  
  if ( $vars->{'from_table'} && $vars->{'from_user_field'} && $vars->{'from_pass_field'} ) {
    $vars->{'login_id'} = from_table();
  } 
        
  if ( $vars->{'login_id'} ) {
    $form->clear_attempts();
  } else {
    $vars->{'error_user_pass'} = 1;
  }     

}

# en script_handler de fc_plugin usar add y nunca out
$nes->add(%$vars);

sub from_table {

  return '' if !$theuser || !$thepass;
  
  my $user = '\''.$theuser.'\'';
     $user = $vars->{'from_user_function'}.'(\''.$theuser.'\')' if $vars->{'from_user_function'};
  my $pass = '\''.$thepass.'\'';
     $pass = $vars->{'from_pass_function'}.'(\''.$thepass.'\')' if $vars->{'from_pass_function'};

  my $query = qq~SELECT `$vars->{'from_user_field'}`  
                 FROM  `$vars->{'from_table'}`
                 WHERE ( 
                         `$vars->{'from_user_field'}` = $user  AND 
                         `$vars->{'from_pass_field'}` = $pass
                         
                       )
                 LIMIT 0,1;~;  

  require Nes::DB;
  my $config    = $nes->{'CFG'};
  my $db_name   = $vars->{'DB_base'}   || $config->{'DB_base'};
  my $db_user   = $vars->{'DB_user'}   || $config->{'DB_user'};
  my $db_pass   = $vars->{'DB_pass'}   || $config->{'DB_pass'};
  my $db_driver = $vars->{'DB_driver'} || $config->{'DB_driver'};
  my $db_host   = $vars->{'DB_host'}   || $config->{'DB_host'};
  my $db_port   = $vars->{'DB_port'}   || $config->{'DB_port'};
  my $base      = Nes::DB->new( $db_name, $db_user, $db_pass, $db_driver, $db_host, $db_port );

  my @result  = $base->sen_select($query);
  my $user_id = $result[0]->{$vars->{'from_user_field'}};

  return $user_id;
}

# don't forget to return a true value from the file
1;


 