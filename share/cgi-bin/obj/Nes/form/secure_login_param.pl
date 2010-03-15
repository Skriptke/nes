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
#  Version 1.03
#
#  DOCUMENTATION:
#  perldoc Nes::Obj::secure_login
#  
# -----------------------------------------------------------------------------

use Nes;

my $nes     = Nes::Singleton->new();
my $obj     = $nes->{'query'}->{'q'}{'obj_param_0'};
my $ddumper = '('.$nes->{'query'}->{'q'}{$obj.'_param_1'}.')';
my %vars    =  eval "$ddumper";

# get parameters
$vars{'script_handler'}    ||= '';
$vars{'function_handler'}  ||= '';
$vars{'script_NES'}        ||= '';
$vars{'min_len_name'}      ||= 2;
$vars{'max_len_name'}      ||= 15;
$vars{'min_len_pass'}      ||= 2;
$vars{'max_len_pass'}      ||= 15;
$vars{'attempts'}          ||= 3;
$vars{'form_attempts'}     ||= '10/5';
$vars{'form_location'}     ||= 'none';
$vars{'form_exp_last'}     ||= '1m';
$vars{'form_expire'}       ||= '10m';
$vars{'form_name'}         ||= 'secure_login';
$vars{'captcha_name'}      ||= 'secure_login';
$vars{'captcha_digits'}    ||= 5;
$vars{'captcha_size'}      ||= 2;
$vars{'captcha_noise'}     ||= 2;
$vars{'captcha_sig'}       ||= '';
$vars{'captcha_spc'}       ||= '';
$vars{'captcha_expire'}    ||= '1m';
$vars{'captcha_atempts'}   ||= '10/5';
$vars{'captcha_tag_start'} ||= '<pre style="font-size:2px; line-height:1.0;">';
$vars{'captcha_tag_start'} =   '' if $vars{'captcha_size'} ne 'none';
$vars{'captcha_tag_end'}   ||= '<br></pre>';
$vars{'captcha_tag_end'}   =   '' if $vars{'captcha_size'} ne 'none';
$vars{'out_page'}          ||= 'http://'.$ENV{'SERVER_NAME'}.$ENV{'REQUEST_URI'};
$vars{'expire_session'}    ||= '12h';
$vars{'expire_session'}    =   '10y' if $nes->{'query'}->{'q'}{'l_Remember'};
$vars{'msg_legend'}        ||= '';
$vars{'msg_name'}          ||= 'User';
$vars{'msg_pass'}          ||= 'Password';
$vars{'msg_remember'}      ||= '';
$vars{'msg_login'}         ||= 'Enter';
$vars{'msg_captcha'}       ||= 'Security code';
$vars{'msg_error_form'}    ||= '<span style="text-decoration:blink;color:#880000;"">&#9658;</span> Incorrect User/Pass<br>';
$vars{'msg_error_captcha'} ||= '<span style="text-decoration:blink;color:#880000;"">&#9668;</span>';
$vars{'id_form'}           ||= 'secure_login_id';
$vars{'class_form'}        ||= 'secure_login_class';
$vars{'msg_error_name'}    ||= '<span style="text-decoration:blink;color:#880000;"">&#9668;</span>';
$vars{'msg_error_pass'}    ||= '<span style="text-decoration:blink;color:#880000;"">&#9668;</span>';
$vars{'tpl_errors'}        ||= 'secure_login_errors.nhtml';
$vars{'tpl_options'}       ||= '';

# undef previous env, pointer to this form
my $nes_env = $nes->{'top_container'}->{'nes_env'};
foreach my $key ( keys %{ $nes->{'top_container'}->{'nes_env'} } ) {
  if ( $key =~ /^sl_this_/ ) {
    $nes->{'top_container'}->del_nes_env( $key );
  }
}

$nes->{'container'}->add_tags(%vars);

# don't forget to return a true value from the file
1;



 