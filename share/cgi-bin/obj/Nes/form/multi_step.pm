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
#  multi_step.pm
#
#  DOCUMENTATION:
#  perldoc Nes::Obj::multi_step  
#
# --------------------------------------------------------------------------------

use strict;
use Nes;

package multi_step;

{
  
  sub new {
    my $class = shift;
    my $self =  bless {}, $class;;
    
    my $nes = Nes::Singleton->new();
    my $cfg = $nes->{'CFG'};

    $self->{'script_handler'}    = '';
    $self->{'function_handler'}  = '';
    $self->{'script_NES'}        = '';

    $self->{'referer'}           = '';
    $self->{'private_key'}       = '';
    $self->{'show_captcha'}      = 1;
    $self->{'table_width'}       = '95%';
    $self->{'form_expire'}       = '15m';
    $self->{'form_name'}         = 'multi_sf';
    $self->{'captcha_name'}      = 'multi_sc';
    $self->{'captcha_type'}      = 'ascii';
    $self->{'captcha_digits'}    = 5;
    $self->{'captcha_size'}      = 2;
    $self->{'captcha_noise'}     = 3;
    $self->{'captcha_sig'}       = '';
    $self->{'captcha_spc'}       = ' ';
    $self->{'captcha_expire'}    = '1m';
    $self->{'captcha_atempts'}   = '5/10';
    $self->{'captcha_tag_start'} = $cfg->{'multi_step_captcha_tag_start'} 
                                || '<pre style="font-size:2px; line-height:1.0;">';
    $self->{'captcha_tag_start'} = '' if $self->{'captcha_size'} ne 'none';
    $self->{'captcha_tag_end'}   = $cfg->{'multi_step_captcha_tag_end'} 
                                || '<br></pre>';
    $self->{'captcha_tag_end'}   = '' if $self->{'captcha_size'} ne 'none';
    $self->{'out_page'}          = 'http://'.$ENV{'SERVER_NAME'}.$ENV{'REQUEST_URI'};
    $self->{'msg_legend'}        = $cfg->{'multi_step_msg_legend'} 
                                || '';
    $self->{'msg_submit'}        = $cfg->{'multi_step_msg_submit'} 
                                || 'Enter';
    $self->{'msg_captcha'}       = $cfg->{'multi_step_msg_captcha'} 
                                || 'Security code';
    $self->{'txt_captcha'}       = $cfg->{'multi_step_txt_captcha'} 
                                || '<center>Finally, enter the security code below.</center><br>';
    $self->{'msg_error_captcha'} = $cfg->{'multi_step_msg_error_captcha'} 
                                || '<img src="'.$cfg->{'img_dir'}.'/error.gif">';
    $self->{'msg_error_form'}   = $cfg->{'multi_step_msg_error_form'} 
                                || '<center>The following fields are invalid:</center><br>';                                
    $self->{'id_form'}           = '';
    $self->{'class_form'}        = '';
    $self->{'action_form'}       = '';
    $self->{'tpl_errors'}        = 'multi_step_errors.nhtml';
    $self->{'tpl_options'}       = '';
    $self->{'msg_error_fields'}  = $cfg->{'multi_step_msg_error_fields'} 
                                || '<img src="'.$cfg->{'img_dir'}.'/error.gif">';
                                

    my $data    = '('.$nes->{'query'}->{'q'}{'multi_step_param_1'}.')';
    my %param   = eval "$data";
    foreach my $this (keys %param) {
      $self->{$this} = $param{$this};
    }    
    
    return $self;
  } 

}

# don't forget to return a true value from the file
1;



 