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
#  secure_login.pl
#
#  DOCUMENTATION:
#  perldoc Nes::Obj::secure_login
#
# -----------------------------------------------------------------------------

use Nes;

my $nes     = Nes::Singleton->new('./secure_login.nhtml');
my $top     = $nes->{'top_container'};
my $obj     = $nes->{'query'}->{'q'}{'obj_param_0'};
my $ddumper = '('.$nes->{'query'}->{'q'}{$obj.'_param_1'}.')';
my %param   =  eval "$ddumper";
my %vars;

$param{'form_name'}    ||= 'secure_login';
$param{'captcha_name'} ||= 'secure_login';
$param{'attempts'}     ||= 3;

# fields names
my $fld_user = $param{'form_name'}.'_User';
my $fld_pass = $param{'form_name'}.'_Password';
my $fld_reme = $param{'form_name'}.'_Remember';

$vars{'user_name'} = $nes->{'query'}->{'q'}{'l_User'};

# fields
$vars{'Remember'} = 'checked="checked"' if $nes->{'query'}->{'q'}{$fld_reme};
$vars{'User'}     = $nes->{'query'}->{'q'}{$fld_user};
$vars{'Password'} = $nes->{'query'}->{'q'}{$fld_pass};


# set env, pointer to this form
my $nes_env = $top->{'nes_env'};
$top->set_nes_env( 'sl_this_form_error_field_User', $nes_env->{'nes_forms_plugin_'.$param{'form_name'}.'_error_field_'.$fld_user} );
$top->set_nes_env( 'sl_this_form_error_field_Password', $nes_env->{'nes_forms_plugin_'.$param{'form_name'}.'_error_field_'.$fld_pass} );
$top->set_nes_env( 'sl_this_form_max_attempts', 1 ) 
  if $nes_env->{'nes_forms_plugin_'.$param{'form_name'}.'_attempts'} > $param{'attempts'};
#                nes_forms_plugin_secure_login_form      _attempts
foreach my $key ( keys %{ $nes_env } ) {
  my $type = $key;
  if ( $type =~ s/^nes_forms_plugin_$param{'form_name'}// ) {
    $top->set_nes_env( 'sl_this_form'.$type, $nes_env->{$key} );
  }
  if ( $type =~ s/^nes_captcha_plugin_$param{'captcha_name'}// ) {
    $top->set_nes_env( 'sl_this_captcha'.$type, $nes_env->{$key} );
  }
}

# get form 
my $form    = nes_plugin->get( 'forms_plugin',   $param{'form_name'} );
my $captcha = nes_plugin->get( 'captcha_plugin', $param{'captcha_name'} );


# errors
$vars{'fatal_error'} = 0;
if ( $form->{'fatal_error'}      ||
  $captcha->{'fatal_error'} == 1 ||
  $captcha->{'fatal_error'} == 3 ||
  $captcha->{'fatal_error'} == 4 ) {

  $vars{'fatal_error'} = 1;
}

# action if ok form
if ( $form->{'is_ok'} ) {
   {
      if ( $param{'script_handler'} && $param{'function_handler'} ) {
        require "$param{'script_handler'}";
        no strict "refs";
        $vars{'login_id'} = &{$param{'function_handler'}}($vars{'User'},$vars{'Password'});
      } 
      if ( $vars{'login_id'} ) {
        $form->{'tmp'}->clear();
      } else {
        $vars{'error_user_pass'} = 1;
      }     
   }
}

$nes->out(%vars);


# don't forget to return a true value from the file
1;



 