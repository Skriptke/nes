#!/bin/perl

# -----------------------------------------------------------------------------
#
#  Nes by Skriptke
#  Copyright 2009 - 2010 Enrique Casta\xc3\xb1\xc3\xb3n
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
#  perldoc Nes::Obj::multi_step  
#
# -----------------------------------------------------------------------------

use strict;
use Nes;
use multi_step;

my $vars       = multi_step->new;
my $nes        = Nes::Singleton->new();
my $cfg        = $nes->{'CFG'};
my $nes_env    = $nes->{'top_container'}->{'nes_env'};
my $remote     = $nes->{'query'}->{'q'}{'_'.$vars->{'form_name'}.'_ip'};   
my $send       = $nes->{'query'}->{'q'}{'_'.$vars->{'form_name'}.'_send'};
my $q_step     = $nes->{'query'}->{'q'}{'_'.$vars->{'form_name'}.'_step'} || 1;
my $q_err      = $nes->{'query'}->{'q'}{'_'.$vars->{'form_name'}.'_err'};
my $q_autho    = $nes->{'query'}->{'q'}{'_'.$vars->{'form_name'}.'_autho'};
my $key        = $vars->{'private_key'} || $nes->{'CFG'}{'private_key'};
my %data;
my $vars_error;
my %return_fields_error;
$vars->{'show_captcha'} = 0 if $q_autho;
$vars->{'autho'}        = $q_autho;

my $error_referer   = $vars->{'referer'} && $ENV{'HTTP_REFERER'} !~ /$vars->{'referer'}/;
my $captcha_ok      = $nes->{'container'}->get_tag('captcha_ok');
   $captcha_ok      = 1 if !$vars->{'show_captcha'};
my $in_errors_step  = $q_err;
my $in_captcha_step = 1 if defined $nes->{'query'}->{'q'}{$vars->{'captcha_name'}};
my $in_fields_step  = !$in_errors_step && !$in_captcha_step;
my $last            = $#{$vars->{'steps'}};
   $last           += 1 if $vars->{'show_captcha'};
my $end_form        = $q_step > $last && $captcha_ok;
my $fields_is_ok    = 0;

set_this_step();
set_fields_default();

if ( $send ) {
  
  if ( $error_referer ) {
    $vars->{'form_error_fatal'} = 1;
    $nes->add(%$vars);
    return 1;
  }
  if ( check_autho() ) {
    $vars->{'form_error_fatal'} = 5;
    $nes->add(%$vars);
    return 1;
  }  

  set_fields();
  save_step();
  $fields_is_ok = check_fields();
}

if ( $fields_is_ok ) {

  if ( $end_form ) {  

    $vars->{'fields_err'}       = '';
    %return_fields_error        = undef;
    $vars->{'form_error_fatal'} = check_form();

    if ( !$vars->{'form_error_fatal'} ) {
      $vars->{'exec_script_NES'} = $vars->{'script_NES'};
      my $error = send_data() if $vars->{'script_handler'} && $vars->{'function_handler'};
      if ( $error ) {
        $in_errors_step  = 1;
        $in_captcha_step = 0;
        $in_fields_step  = 0;
        go_next_step();
      }
    }
    
    if ( !$vars->{'form_error_fatal'} && !$vars->{'error_handler'} ) {
      $nes->{'container'}->{'content_obj'}->location( $vars->{'out_page'}, "302 Found" ) if $vars->{'out_page'};
    }    
    
  } else {
    go_next_step();
  }
  
}

$vars->{'private_key'} = ''; # For safety, do not show
$nes->add(%$vars);
# end.

sub send_data {
  
  $vars->{'error_handler'} = 0;
  require "$vars->{'script_handler'}";
  no strict "refs";
  %return_fields_error = &{$vars->{'function_handler'}}(\%data);
  $vars->{'error_handler'} = 1 if %return_fields_error;  
  
  return $vars->{'error_handler'};
}

sub go_next_step {
  
  if ( $in_fields_step ) {

    $vars->{'next_step'}++;
    $vars->{'this_step'}  = $vars->{'next_step'} - 1;
    $vars->{'fields'}     = $vars->{'steps'}[$vars->{'this_step'}];
    $vars->{'last_step'}  = 1 if $vars->{'this_step'} > $vars->{'last'};
  
  } elsif ( $in_errors_step ) {

    set_fields_error();
    $vars->{'error_fields'} = 1;
    $vars->{'next_step'}    = $#{$vars->{'steps'}} + 1;
    $vars->{'next_step'}   += 1 if $vars->{'show_captcha'};
    $vars->{'this_step'}    = $vars->{'next_step'};
    $vars->{'last_step'}    = 0;
    $vars->{'fields'}       = $vars_error;

  } elsif ( $in_captcha_step ) {

    $vars->{'next_step'}++;
    $vars->{'this_step'}  = $vars->{'next_step'} - 1;
    $vars->{'fields'}     = $vars->{'steps'}[$vars->{'this_step'}];
    $vars->{'last_step'}  = 1 if $vars->{'this_step'} > $vars->{'last'};    
  
  } 
  js_regexp();
  
}

sub set_this_step {
  
  $vars->{'last'} = $#{$vars->{'steps'}};
  
  if ( $in_fields_step ) {

    $vars->{'next_step'}  = $q_step;
    $vars->{'this_step'}  = $vars->{'next_step'} - 1;
    $vars->{'fields'}     = $vars->{'steps'}[$vars->{'this_step'}];
    
  } elsif ( $in_errors_step ) {
   
    restore_fields_error();
    $vars->{'error_fields'} = 1;
    $vars->{'next_step'}    = $#{$vars->{'steps'}} + 1;
    $vars->{'next_step'}   += 1 if $vars->{'show_captcha'};
    $vars->{'this_step'}    = $vars->{'next_step'};
    $vars->{'last_step'}    = 0;
    $vars->{'fields'}       = $vars_error;

  } elsif ( $in_captcha_step ) {

    $vars->{'next_step'}  = $q_step;
    $vars->{'this_step'}  = $q_step;
    $vars->{'fields'}     = undef;    
    
  }
  js_regexp();
  
}

sub set_fields {
  
  foreach my $field ( @{ $vars->{'fields'} } ) {
    
    my $name  = $vars->{'form_name'}.'_'.$field->{'name'};
    my $value = $nes->{'query'}->{'q'}{$name};
    my $set   = 1 if defined $nes->{'query'}->{'q'}{$name};

    if ( $field->{'type'} =~ /^button$/i ) {
      # el mismo que tenia, no cambia
    } elsif ( $field->{'type'} =~ /^select$/i && $set ) { 
      $field->{'options'} =~ s/(<option.+?)selected\s*=\s*\"?selected\"?\s*|selected\s*(.+?>)/$1$2/gi;
      $field->{'options'} =~ s/(<option\s*)(value\s*=\s*\"?$value|.*>$value)/$1 selected $2/i;
    } elsif ( $field->{'type'} =~ /^checkbox$/i ) {
      $field->{'checked'} = 0;
      $field->{'checked'} = 1 if $value;
    } elsif ( $field->{'type'} =~ /^radio/i ) {
      $field->{'checked'} = 0;
      $field->{'checked'} = 1 if $value eq $field->{'value'};
    } else {
      $field->{'value'} = $value if $set;
    }
  }
   
}

sub set_fields_default {
  
  foreach my $field ( @{ $vars->{'fields'} } ) {
    
    my $value = $field->{'value'};
  
    if ( $field->{'type'} =~ /^button$/i ) {
      # el mismo que tenia, no cambia
    } elsif ( $field->{'type'} =~ /^select$/i ) { 
      $field->{'options'} =~ s/(<option.+?)selected\s*=\s*\"?selected\"?\s*|selected\s*(.+?>)/$1$2/gi;
      $field->{'options'} =~ s/(<option\s*)(value\s*=\s*\"?$value|.*>$value)/$1 selected $2/i;
    } elsif ( $field->{'type'} =~ /^checkbox$/i ) {
      my $value = $field->{'checked'};
      $field->{'checked'} = 0;
      $field->{'checked'} = 1 if $value;
    } elsif ( $field->{'type'} =~ /^radio$/i ) {
      my $value = $field->{'checked'};
      $field->{'checked'} = 0;
      $field->{'checked'} = 1 if $value;
    } else {
      $field->{'value'} = $value;
    }

    $field->{'msg_error'} = $vars->{'msg_error_fields'} if !$field->{'msg_error'};
  }
  
}

sub save_step {

  my %fields;
  $vars->{'fields_pre'} = undef;
  my $n = 0;

  foreach my $this ( keys %{ $nes->{'query'}->{'q'} } ) {
    next if $this !~ /^sv_$vars->{'form_name'}_/;
    $fields{$this}{'name'}  = $this;
    $fields{$this}{'value'} = $nes->{'query'}->{'q'}{$this};
  }

  foreach my $field ( @{ $vars->{'fields'} } ) {
    my $name  = 'sv_'.$vars->{'form_name'}.'_'.$field->{'name'};
    my $value = $nes->{'query'}->get("$vars->{'form_name'}_$field->{'name'}");
    $fields{$name}{'name'}  = $name;
    $fields{$name}{'value'} = encrypt($value,$key);
#    $fields{$name}{'value'} = decrypt($fields{$name}{'value'},$key);
  }
   
  foreach my $this ( keys %fields ) {
    push(@{$vars->{'fields_pre'}},$fields{$this});
  }
  

}

sub set_fields_error {

  $vars_error = undef;
  foreach my $step ( @{ $vars->{'steps'} } ) {
    foreach my $field ( @{ $step } ) {
      if ( $return_fields_error{$field->{'name'}} ) {
        $field->{'error'} = $field->{$return_fields_error{$field->{'name'}}};
        if ( $field->{'type'} =~ /^radio$/i ) {
          $field->{'value'} = $field->{'value'}; # el mismo.
        } elsif ( $field->{'type'} =~ /^checkbox$/i ) {
          $field->{'checked'} = 0;
          $field->{'checked'} = 1 if $data{$field->{'name'}};
        } elsif ( $field->{'type'} =~ /^select$/i ) {
          $field->{'value'} = $data{$field->{'name'}};
          $field->{'options'} =~ s/(<option.+?)selected\s*=\s*\"?selected\"?\s*|selected\s*(.+?>)/$1$2/gi;
          $field->{'options'} =~ s/(<option\s*)(value\s*=\s*\"?$data{$field->{'name'}}|.*>$data{$field->{'name'}})/$1 selected $2/i;
        } else {
          $field->{'value'} = $data{$field->{'name'}};
        }
        push(@{$vars_error},$field); 
        $vars->{'fields_err'} .= ':'.$field->{'name'}.':';       
        next;
      }      
    }
  }
  set_autho();
  
}

sub restore_fields_error {

  $vars_error = undef;
  foreach my $step ( @{ $vars->{'steps'} } ) {
    foreach my $field ( @{ $step } ) {  
      if ( $q_err =~ /:$field->{'name'}:/i ) {
        push(@{$vars_error},$field);
        $vars->{'fields_err'} .= ':'.$field->{'name'}.':';
      }
    }
  }
#  set_autho();
  
}

sub check_fields {

  my $error;
  foreach my $field ( @{ $vars->{'fields'} } ) {
    next if !$field->{'check'};
    my $field_error = check($field,$nes->{'query'}->{'q'}{$vars->{'form_name'}.'_'.$field->{'name'}});
    $field->{'error'} = $field->{'msg_error'} if $field_error;
    $error = 1 if $field_error;
  }

  return 0 if $error;
  return 1;
}

# does not display the captcha in error checking
sub set_autho {
  
  my $captcha = 'ko';
     $captcha = 'ok' if $captcha_ok;
  
  require Crypt::CBC;
  my $cipher = Crypt::CBC->new(
    -key    => $key,
    -cipher => 'Blowfish'
  );

  my $refuse = $nes->{'nes'}->get_key( 4 + int rand 10 );
  $refuse =~ s/\|//g;
  my $value = $nes_env->{'nes_remote_ip'}.'|'.$refuse.'|'.time.'|'.$vars->{'fields_err'}.'|'.$captcha;  

  $vars->{'autho'} = $cipher->encrypt_hex($value);  
#  $vars->{'autho'} = decrypt($vars->{'autho'},$key);

}

sub check_autho {
  
  return 0 if !$q_autho;
  my ($ip, $refuse, $time, $fields, $captcha) = split('\|',decrypt($q_autho,$key));
#     ($ip, $refuse, $time, $fields, $captcha) = split('\|',$q_autho);
  my $expire = $time + utl::expires_time($vars->{'form_expire'});

  return 5 if $nes_env->{'nes_remote_ip'} ne $ip;
  return 5 if time > $expire;
  return 5 if $fields ne $vars->{'fields_err'};
  return 5 if $captcha ne 'ok';
  
  return 0;
}

sub check {
  my ($field,$value) = @_;

  return if !$field->{'check'};
  my $field_error = '';
  my ( $min, $max, $regex ) = split( ',', $field->{'check'},3 );

  if ( $min ) {
    $field_error .= 'min, ' if length($value) < $min;
  }
  if ( $max ) {
    $field_error .= 'max, ' if length($value) > $max;
  }
  if ( $regex =~ /^\/(.*)\/(.*)$/ ) {
    $regex = "(?$2)$1";
    if ($value) {  # sólo da error si el campo no esta vacío, podía ser opcional
      $field_error .= 'regular expression' if $value !~ /$regex/;
    }
  }

  $field->{'error'} = $field->{'msg_error'} if $field_error;
  return $field_error;
}

sub check_form {
  
  foreach my $this ( keys %{ $nes->{'query'}->{'q'} } ) {
    next if $this !~ /^sv_$vars->{'form_name'}_/;
    my $name = $this;
       $name =~ s/^sv_$vars->{'form_name'}_//;
    my ($refuse, $remote, $time, $data) = split(':',decrypt($nes->{'query'}->{'q'}{$this},$key),4);
#       ($refuse, $remote, $time, $data) = split(':',$nes->{'query'}->{'q'}{$this},4);
    $data{$name} = $data;
    my $expire = $time + utl::expires_time($vars->{'form_expire'});
    return 2 if time > $expire;
    return 3 if $remote ne $nes_env->{'nes_remote_ip'};
  }

  foreach my $field ( @{ $vars->{'fields'} } ) {
    my $name = $vars->{'form_name'}.'_'.$field->{'name'};
    $data{$field->{'name'}} = $nes->{'query'}->{'q'}{$name};
  }
  
  # volver a chequear todos los campos
  foreach my $step ( @{ $vars->{'steps'} } ) {
    foreach my $field ( @{ $step } ) {
      next if !$field->{'check'};
      return 4 if check($field, $data{$field->{'name'}});
    }
  }
  
  return 0;
}

sub encrypt {
  my ($data,$key) = @_;

  require Crypt::CBC;
  my $cipher = Crypt::CBC->new(
    -key    => $key,
    -cipher => 'Blowfish'
  );

  my $refuse = $nes->{'nes'}->get_key( 8 + int rand 8 );
  $refuse =~ s/\://g;
  my $value = $refuse.':'.$remote.':'.time.':'.$data;  

  return $cipher->encrypt_hex($value);
}

sub decrypt {
  my ($data,$key) = @_;

  require Crypt::CBC;
  my $cipher = Crypt::CBC->new(
    -key    => $key,
    -cipher => 'Blowfish'
  );
  
  my $decrypt = '';
  eval { $decrypt = $cipher->decrypt_hex( $data ); };
  
  return $decrypt;    
  
}

sub js_regexp {

  my $count = 0;
  foreach my $field ( @{ $vars->{'fields'} } ) {
    my $check = $field->{'check'} || $field->{'js_check'};
    my ( $min, $max, $regex ) = split( ',', $check,3 );
    $field->{'js_RegExp'}     = $regex || '/(:?)/';
    $field->{'js_min'}        = $min   || '0';
    $field->{'js_max'}        = $max   || '9999';
    $field->{'js_id'}         = $count;
    $field->{'js_msg_error'}  = $field->{'js_msg_error'} || $field->{'msg_error'} || $vars->{'msg_error_fields'};
    $count++;
  }
  
}


  
# don't forget to return a true value from the file
1;


