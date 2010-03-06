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
#  Version 1.02
#
#  secure_login.pl
#
# -----------------------------------------------------------------------------

use Nes;

my $nes  = Nes::Singleton->new('./secure_login.nhtml');
my $obj  = $nes->{'query'}->{'q'}{'obj_param_0'};
my %vars;

# get parameters
$vars{'script_test'}       = $nes->{'query'}->{'q'}{$obj.'_param_1'};
$vars{'min_len_name'}      = $nes->{'query'}->{'q'}{$obj.'_param_2'};
$vars{'max_len_name'}      = $nes->{'query'}->{'q'}{$obj.'_param_3'};
$vars{'min_len_pass'}      = $nes->{'query'}->{'q'}{$obj.'_param_4'};
$vars{'max_len_pass'}      = $nes->{'query'}->{'q'}{$obj.'_param_5'};
$vars{'attempts'}          = $nes->{'query'}->{'q'}{$obj.'_param_6'};
$vars{'form_attempts'}     = $nes->{'query'}->{'q'}{$obj.'_param_7'};
$vars{'captcha_size'}      = $nes->{'query'}->{'q'}{$obj.'_param_8'};
$vars{'captcha_noise'}     = $nes->{'query'}->{'q'}{$obj.'_param_9'};
$vars{'captcha_atempts'}   = $nes->{'query'}->{'q'}{$obj.'_param_10'};
$vars{'out_page'}          = $nes->{'query'}->{'q'}{$obj.'_param_11'} || 'http://'.$ENV{'SERVER_NAME'}.$ENV{'REQUEST_URI'};
$vars{'expire_session'}    = $nes->{'query'}->{'q'}{$obj.'_param_12'} || '12h';
$vars{'msg_legend'}        = $nes->{'query'}->{'q'}{$obj.'_param_13'};
$vars{'expire_session'}    = '1y' if $nes->{'query'}->{'q'}{'l_Remember'};
$vars{'msg_name'}          = $nes->{'query'}->{'q'}{$obj.'_param_14'} || 'User';
$vars{'msg_pass'}          = $nes->{'query'}->{'q'}{$obj.'_param_15'} || 'Password';
$vars{'msg_remember'}      = $nes->{'query'}->{'q'}{$obj.'_param_16'};
$vars{'msg_login'}         = $nes->{'query'}->{'q'}{$obj.'_param_17'} || 'Enter';
$vars{'msg_captcha'}       = $nes->{'query'}->{'q'}{$obj.'_param_18'} || 'Security code';
$vars{'msg_error_form'}    = $nes->{'query'}->{'q'}{$obj.'_param_19'} || '<span style="text-decoration:blink;color:#880000;"">&#9658;</span> Incorrect User/Pass<br>';
$vars{'msg_error_captcha'} = $nes->{'query'}->{'q'}{$obj.'_param_20'} || '<span style="text-decoration:blink;color:#880000;"">&#9668;</span>';
$vars{'id_form'}           = $nes->{'query'}->{'q'}{$obj.'_param_21'} || 'secure_login_id';
$vars{'class_form'}        = $nes->{'query'}->{'q'}{$obj.'_param_22'} || 'secure_login_class';
$vars{'msg_error_name'}    = $nes->{'query'}->{'q'}{$obj.'_param_23'} || '<span style="text-decoration:blink;color:#880000;"">&#9668;</span>';
$vars{'msg_error_pass'}    = $nes->{'query'}->{'q'}{$obj.'_param_24'} || '<span style="text-decoration:blink;color:#880000;"">&#9668;</span>';
$vars{'tpl_errors'}        = $nes->{'query'}->{'q'}{$obj.'_param_25'} || 'secure_login_errors.nhtml';
$vars{'tpl_options'}       = $nes->{'query'}->{'q'}{$obj.'_param_26'} || '';

# get form 
my $form    = nes_plugin->get( 'forms_plugin',   'secure_login_form' );
my $captcha = nes_plugin->get( 'captcha_plugin', 'secure_login_captcha' );

# user and password
$vars{'user_name'} = $nes->{'query'}->{'q'}{'l_User'};
my $user_pass        = $nes->{'query'}->{'q'}{'l_Password'};

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
      require "$vars{'script_test'}";
      $vars{'login_id'} = nes_test_login($vars{'user_name'},$user_pass);
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



 