
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
#  fc_plugin.pm
#
# -----------------------------------------------------------------------------

use strict;
use warnings;
use Nes;

{
  package fc_plugin;

  sub fc {
    my ( $out, $name, @param ) = @_;
    my $self = nes_fc->new( $out, $name, @param );
    
    return $self->init_form();   
  }
  
  sub _end {
    my ( $out, $name ) = @_;
    my $self = Nes::Singleton->instance->{'register'}->get( 'fc_plugin', $name );
  
    return $self->end_form($out);  
  }

  sub _begin {
    my ( $out, $name ) = @_;
    my $self = Nes::Singleton->instance->{'register'}->get( 'fc_plugin', $name );
  
    return $self->being_form($out);  
  }  
   
  sub check {
    my ( $out, $name, @param ) = @_;
    my $self = Nes::Singleton->instance->{'register'}->get( 'fc_plugin', $name );
    
    return if !$self->{'fc_is_start'};
    return $self->check(@param);
  }
  
  sub field_attempts {
    my ( $out, $name, @param ) = @_;
    my $self = Nes::Singleton->instance->{'register'}->get( 'fc_plugin', $name );
  
    return if $self->{'error_check'};

    return $self->field_attempts(@param);
  }

  sub obfuscated {
    my ( $out, $name, $field ) = @_;
    my $self = Nes::Singleton->instance->{'register'}->get( 'fc_plugin', $name );
  
    return $self->obfuscated($field);
  }

  sub captcha {
    my ( $out, @param ) = @_;
    my ( $form_name, $name, $last, $type, @params ) = @param;
    my $self = Nes::Singleton->instance->{'register'}->get( 'fc_plugin', $form_name );
    
    $self->{'captcha_show'} = 1;
    $self->{'captcha_last'} = $last || 0;

    if ( $self->{'attempts'} < $self->{'for_captcha'}  ) {
      $self->{'captcha_show'} = 0;
      return;
    }
    
    if ( $self->{'captcha_last'} ) {
      $self->{'auto_submit'}  = 0;
      $self->{'captcha_show'} = 0 if !$self->{'fc_is_start'} || $self->{'error_check'};
      return if !$self->{'fc_is_start'} || $self->{'error_check'};
    }     

    $type = 'ascii' if !$type;
    $self->{'captcha'} = nes_fc_captcha->new( $form_name, $name, $last, $type, @params );

  
    return;
  }    

  sub captcha_code {
    my ( $out, $form_name, $name ) = @_;
    my $self = Nes::Singleton->instance->{'register'}->get( 'fc_plugin', $form_name );
    
    return if !$self->{'captcha_show'};
    return $self->{'captcha'}->out();   
  }  
  
  sub captcha_html {
    my ( $out, $form_name, $name ) = @_;
    my $self = Nes::Singleton->instance->{'register'}->get( 'fc_plugin', $form_name );
    
    return if !$self->{'captcha_show'};
    return $out;   
  }
  
  sub script_handler {
    my ( $out, $form_name, $script ) = @_;
    my $self = Nes::Singleton->instance->{'register'}->get( 'fc_plugin', $form_name );
    
    my $return = do $script;
    unless ($return) {
      
      # mod_perl muestra un error cuando se usa exit
      return if $@ =~ /ModPerl::Util::exit/;
      
      warn "couldn't parse $script: $@" if $@;
      warn "couldn't do $script: $!" unless defined $return;
      warn "couldn't run $script" unless $return;
    } 

    foreach my $tag ( keys %{ $self->{'container'}->{'content_obj'}->{'tags'} } ) {
      $self->{'container'}->{'content_obj'}->{'interpret'}->{'tags'}{$tag} = $self->{'container'}->{'content_obj'}->{'tags'}{$tag};
    }    

    return '';   
  }  

}

{

  package nes_fc;
  use vars qw(@ISA);
  @ISA = qw( Nes );

  sub new {
    my $class = shift;
    my ( $out, $name, $expire, $expire_last, $attempts, $attempts_for_captcha, $location_error, $tpl_errors, $msg_errors ) = @_;
    my $self = $class->SUPER::new();
  
    # register plugin
    my $cfg_file = $self->{'CFG'}{'plugin_top_dir'}.'/Nes/form/.fc_plugin.nes.cfg';
    $self->{'plugin'} = $self->{'register'}->add_obj('fc_plugin', $name, $self, $cfg_file);  
  
    # parametros
    $self->{'out'}          = $out;
    $self->{'name'}         = $name;
    $self->{'auto_submit'}  = 1;
    $self->{'location'}     = $location_error || $self->{'CFG'}{'fc_form_location_errors'} || '';
    $self->{'for_captcha'}  = $attempts_for_captcha || $self->{'CFG'}{'fc_form_attempts_captcha'} ||  0;
    $self->{'tpl_errors'}   = $tpl_errors || $self->{'CFG'}{'fc_form_tpl_errors'} || '';
    $self->{'msg_errors'}   = $msg_errors || $self->{'CFG'}{'fc_form_msg_errors'} || '';
    
    # campos ofuscados
    %{ $self->{'obfuscated'} } = ();
    
    # intentos campos
    %{ $self->{'field_attempts'} } = ();
    
    # campos de control
    $self->{'fc_start_name'}     = $self->{'CFG'}{'fc_form_start'} .'_'.$self->{'name'};
    $self->{'fc_finish_name'}    = $self->{'CFG'}{'fc_form_finish'}.'_'.$self->{'name'};
    $self->{'fc_last_name'}      = $self->{'CFG'}{'fc_form_last'}  .'_'.$self->{'name'};
    $self->{'fc_start'}          = $self->{'query'}->get( $self->{'fc_start_name'} )  || '';
    $self->{'fc_finish'}         = $self->{'query'}->get( $self->{'fc_finish_name'} ) || '';
    $self->{'fc_last'}           = $self->{'query'}->get( $self->{'fc_last_name'} )   || '';
    $self->{'fc_start_field'}    = '<input type="hidden" name="' . $self->{'fc_start_name'} . '"  value="' . $self->{'name'} . '" />';
    $self->{'fc_finish_field'}   = '<input type="hidden" name="' . $self->{'fc_finish_name'}. '"  value="' . $self->{'name'} . '" />';
    $self->{'fc_finish_last'}    = '<input type="hidden" name="' . $self->{'fc_last_name'}  . '"  value="' . $self->{'name'} . '" />';
    $self->{'auto_submit_field'} = 'document.'.$self->{'name'}.'.submit();';
    $self->{'auto_submit_field'} = '' if $self->{'nes'}->{'debug_info'}{'is_load'};

    
    # variables de control
    $self->{'fc_tag_begin'} = $self->{'pre_start'}.' & _fc_begin (\''.$self->{'name'}.'\') '.$self->{'pre_end'};
    $self->{'fc_tag_end'}   = $self->{'pre_start'}.' & _fc_end   (\''.$self->{'name'}.'\') '.$self->{'pre_end'};
    $self->{'fc_is_start'}  = 0;
    $self->{'fc_is_start'}  = 1 if $self->{'fc_start'}  eq $self->{'name'};
    $self->{'fc_is_finish'} = 0;
    $self->{'fc_is_finish'} = 1 if $self->{'fc_finish'} eq $self->{'name'};
    $self->{'last_step'}    = 0;
    $self->{'field_num'}    = 0;    
    $self->{'expire'}       = $expire      || $self->{'CFG'}{'fc_form_expire'};
    $self->{'expire_last'}  = $expire_last || $self->{'CFG'}{'fc_form_expire_last'};
    $self->{'expired'}      = $self->{'expire'};

    # variables de verificación
    $self->{'error_check'} = 0;    
    $self->{'key_name'}    = '';
    $self->{'key_value'}   = '';
    $self->{'time_cookie'} = 0;
    $self->{'last_error'}  = '';
    $self->{'fatal_error'} = 0;
    $self->{'is_ok'}       = 0;   
    $self->{'attempts'}    = 0;
    $self->{'captcha_ok'}  = 1;
    
    # attempts
    $attempts ||= $self->{'CFG'}{'fc_form_max_attempts'};
    ( $self->{'max_attempts'}, $self->{'max_time'} ) = split( '/', $attempts );
    $self->{'expire_tmp'}  = utl::expires_time( $self->{'CFG'}{'fc_form_expire_attempts'} );
    $self->{'tmp'} = nes_tmp->new( $self->{'CFG'}{'fc_form_suffix'}, $self->{'name'} );
    
    # captcha
    $self->{'captcha'} = undef;
    
    
    return $self;
  }
  
  sub clear_attempts {
    my $self = shift;
    my ( $field ) = @_;
    
    $self->{'tmp'}->clear();
    foreach my $field ( keys %{ $self->{'field_attempts'} } ) {
      $self->{'field_attempts'}{$field}{'tmp'}->clear();
    }

    return;
  }   
  
  sub get_attempts {
    my $self = shift;

    my @data = $self->{'tmp'}->load();
    return if !@data;
    
    my ( $first_attempt, $used_key ) = split( ':', $data[0] );
    my $attempts = $#data;
    $first_attempt =~ s/:.*//;
    $self->{'used_key'} = $used_key;

    if ( $first_attempt ) {
      if ( time - $first_attempt > $self->{'expire_tmp'} ) {
        $self->{'tmp'}->clear();
        $attempts = -1;
        $first_attempt = time;
        $self->{'used_key'} = '';
      }
    }

    if ( $attempts >= $self->{'max_attempts'} ) {
      $self->{'tmp'}->clear() if time - $first_attempt > ( $self->{'max_time'} * 60 );
    }

    $self->{'attempts'} = $attempts + 1;
    $self->{'attempts'} = 0 if $attempts < 0;
    $self->{'plugin'}->add_env( 'fc_plugin', $self->{'name'}, 'attempts', $self->{'attempts'} );
    $self->{'plugin'}->add_env( 'fc_plugin', 'self',          'attempts', $self->{'attempts'} );

    return;
  }  

  sub field_attempts {
    my $self = shift;
    my ( $field,$attps,$lc ) = @_;
 
    $lc ||= '';
    $attps ||= $self->{'CFG'}{'fc_form_field_max_attempts'};
    
    my $value = $self->{'query'}->get( $field ) || return;
       $value = lc($value) if $lc;
    my ( $max_attempts, $max_time ) = split( '/', $attps );
    $self->{'field_attempts'}{$field}{'max_attempts'} = $max_attempts;
    $self->{'field_attempts'}{$field}{'max_time'}     = $max_time;
  
    $self->{'field_attempts'}{$field}{'id'}  = $value;
    $self->{'field_attempts'}{$field}{'tmp'} = nes_tmp->new( $self->{'CFG'}{'fc_form_suffix'}, $self->{'name'}, $value );
    if ( $self->{'fc_is_start'} && !$self->{'last_step'} ) {
      $self->{'field_attempts'}{$field}{'tmp'}->save( time . ':' );
    }

    my @data = $self->{'field_attempts'}{$field}{'tmp'}->load();
    return if !@data;
    
    my ( $first_attempt, $used_key ) = split( ':', $data[0] );
    my $attempts = $#data;
    $first_attempt =~ s/:.*//;
    $self->{'used_key'} = $used_key;

    if ( $first_attempt ) {
      if ( time - $first_attempt > $self->{'expire_tmp'} ) {
        $self->{'field_attempts'}{$field}{'tmp'}->clear();
        $attempts = -1;
        $first_attempt = time;
        $self->{'used_key'} = '';
      }
    }
 
    if ( $attempts > $max_attempts ) {
      $self->{'field_attempts'}{$field}{'tmp'}->clear() if time - $first_attempt > ( $max_time * 60 );
    }
    
    $self->{'field_attempts'}{$field}{'attempts'} = $attempts + 1;
    $self->{'field_attempts'}{$field}{'attempts'} = 0 if $attempts < 0;
    my $field_num = keys %{$self->{'field_attempts'}};
    $self->{'field_attempts'}{$field}{'field_num'} = $field_num;
    $self->{'plugin'}->add_env( 'fc_plugin', $self->{'name'}.'_'.$field, 'attempts', $self->{'field_attempts'}{$field}{'attempts'} );
    $self->{'plugin'}->add_env( 'fc_plugin', 'self_field_'.$field_num, 'attempts', $self->{'field_attempts'}{$field}{'attempts'} );

    if ( $self->{'field_attempts'}{$field}{'attempts'} > $self->{'field_attempts'}{$field}{'max_attempts'} ) {
      $self->{'error_check'} = 1;
      $self->{'last_error'}  = "8 max attempts field $field, wait $self->{'field_attempts'}{$field}{'max_time'} minutes";
      $self->{'fatal_error'} = 8;
      $self->{'plugin'}->add_fatal_error( 'fc_plugin', $self->{'name'}, '8' );
      $self->{'plugin'}->add_last_error( 'fc_plugin', $self->{'name'}, "8 max attempts field $field, wait $self->{'field_attempts'}{$field}{'max_time'} minutes" );
      $self->{'plugin'}->add_fatal_error( 'fc_plugin', 'self', '8' );
      $self->{'plugin'}->add_last_error( 'fc_plugin', 'self', "8 max attempts field $field, wait $self->{'field_attempts'}{$field}{'max_time'} minutes" );
      $self->{'plugin'}->add_env( 'fc_plugin', 'self_field_'.$field_num, 'error_attempts', "max attempts field $field, wait $self->{'field_attempts'}{$field}{'max_time'} minutes" );
      $self->{'plugin'}->add_env( 'fc_plugin', $self->{'name'}.'_'.$field, 'error_attempts', "max attempts field $field, wait $self->{'field_attempts'}{$field}{'max_time'} minutes" );
      $self->{'plugin'}->add_env( 'fc_plugin', $self->{'name'}, 'error_field_attempts', "$field" );
      $self->{'plugin'}->add_env( 'fc_plugin', 'self', 'error_field_attempts', "$field" );
    }

    return;
  }
  
  sub init_form {
    my $self = shift;
    
    # reestablecer variables de entorno
    my @fc_env = $self->{'top_container'}->get_nes_env_keys( 'nes_fc_plugin' );
    foreach my $key ( @fc_env ) {
      $self->{'top_container'}->del_nes_env( $key ) if $key =~ /self/;
    }

    if ( $self->{'fc_is_start'} ) {
      $self->load;
      $self->{'tmp'}->save( time . ':' ) if !$self->{'fc_is_finish'};    
    }
    
    $self->get_attempts; 
    $self->is_ok();
    
    # por compatibilidad con otras versiones
    $self->{'container'}->{'content_obj'}->{'tags'}{'form_error_fatal'} = $self->{'fatal_error'};
    # captcha_error_fatal
    
    if ( $self->{'fatal_error'} ) {
      if ( $self->{'location'} ne 'none' ) {
        if ( $self->{'location'} ) {
          $self->{'container'}->{'content_obj'}->location( $self->{'location'} );
          exit 1;
        } else {
          $self->{'container'}->{'content_obj'}->location("http://$ENV{'SERVER_NAME'}$ENV{'PATH_INFO'}?error_forms=$self->{'fatal_error'}");
          exit 1;
        }
      }
      if ( $self->{'tpl_errors'} ) {
        return $self->{'pre_start'}.' include (\''.$self->{'tpl_errors'}.'\') '.$self->{'pre_end'};
      } else {
        return $self->{'msg_errors'} || 'El Error GORDO ha ocurrido y nadie sabe como ha sido.';
      }
    } else {
      $self->{'out'} =~ s/$self->{'pre_start'}\s*\&\s*fc_begin_form\s*$self->{'pre_end'}/$self->{'fc_tag_begin'}/;
      $self->{'out'} =~ s/$self->{'pre_start'}\s*\&\s*fc_end_form\s*$self->{'pre_end'}/$self->{'fc_tag_end'}/;
    }

    # se vuelve a iniciar el formulario
    if ( $self->{'is_ok'} ) {
      $self->{'fc_is_start'}   = 0;
      $self->{'fc_is_finish'}  = 0;
      $self->{'expired'}       = $self->{'expire'};
    }

    $self->{'plugin'}->add_env( 'fc_plugin', $self->{'name'}, 'expire', $self->{'expired'} );
    $self->{'plugin'}->add_env( 'fc_plugin', 'self', 'expire', $self->{'expired'} );    
    
    return $self->{'out'};
  }
  
  sub being_form {
    my $self = shift;
    my ( $out ) = @_;

    $self->{'last_step'} = 1 if $self->{'fc_is_start'} && !$self->{'fc_is_finish'} && !$self->{'error_check'};
    
    if ( $self->{'captcha'} && $self->{'captcha_show'}  ) {
      $self->{'captcha'}->create;
      $self->{'captcha_ok'}   = 0 if !$self->{'captcha'}->is_ok;
      $self->{'last_step'}    = 0 if !$self->{'captcha_ok'} && !$self->{'captcha_last'}; 
      $self->{'captcha_show'} = 1;
      $self->{'captcha_show'} = 0 if !$self->{'captcha_last'} && $self->{'last_step'};
      $self->{'captcha_show'} = 0 if $self->{'captcha_last'} && $self->{'captcha_ok'};
    }
       
    if ( $self->{'last_step'} ) {
      $self->{'plugin'}->add_env( 'fc_plugin', $self->{'name'}, 'last_step', '1' );
      $self->{'plugin'}->add_env( 'fc_plugin', 'self', 'last_step', '1' );
    } else {
      $self->{'plugin'}->add_env( 'fc_plugin', $self->{'name'}, 'last_step', '0' );
      $self->{'plugin'}->add_env( 'fc_plugin', 'self', 'last_step', '0' );
    }      

    return $out;
  }    
  
  sub end_form {
    my $self = shift;
    my ( $out ) = @_;
    
    $out .= $self->{'fc_start_field'};
    $out .= $self->{'captcha'}->{'captcha_start_field'} if $self->{'captcha'};
    
    if ( $self->{'last_step'} ) {
      $self->{'expired'} = $self->{'expire_last'};
      $self->{'key_name'}  = $self->get_key( 9 + int rand 9 );
      $self->{'key_value'} = $self->get_key( 9 + int rand 9 );
      my $form_key = '<input type="hidden" name="'.$self->{'key_name'}.'"  value="'.$self->{'key_value'}.'" />';
      my $js_code  = $form_key;
      my $js_var   = $self->get_key( 9 + int rand 9 );
         $js_code  = '<script>'.$js_var.' = unescape(\''.utl::escape($js_code).'\');document.write('.$js_var.');'.$self->{'auto_submit_field'}.'</script>';

      # desactivar campos con javascript
      my $catpcha_name = $self->{'captcha'}->{'captcha_name'} || '';
      $out .= '<script> var fields_'.$self->{'name'}.' = document.getElementsByName(\''.$self->{'name'}.'\')[0]; for (var n=0; n < fields_'.$self->{'name'}.'.length; n++) { if ( fields_'.$self->{'name'}.'[n].type == "submit" || fields_'.$self->{'name'}.'[n].name == "'.$catpcha_name.'" ) { next; } fields_'.$self->{'name'}.'[n].setAttribute(\'readonly\',0); } </script>';

      if ( $self->{'captcha'} && $self->{'captcha_last'} && !$self->{'captcha_ok'} ) {
        # error en captcha last, no hacer nada.
      } else {
        $out .= $self->{'fc_finish_field'}.$js_code; 
      }
    }
    
#    use Data::Dumper;
#        foreach my $tag ( keys %{ $self->{'container'}->{'content_obj'}->{'tags'} } ) {
#      $self->{'container'}->{'content_obj'}->{'interpret'}->{'tags'}{$tag} = $self->{'container'}->{'content_obj'}->{'tags'}{$tag};
#    }
#    $self->{'container'}->{'content_obj'}->{'interpret'}->{'tags'}{'dumper_fc_plugin'} = '{: hola :} 〈 hola 〉';
#warn ": $self->{'container'}->{'content_obj'}->{'interpret'}->{'tags'}{'dumper_fc_plugin'}";
    $self->save;
    
    return $out;
  }
   
  sub obfuscated {
    my $self = shift;
    my ( $field ) = @_;

    return $self->{'obfuscated'}{$field} = $self->get_key( 6 + int rand 6 );
  } 

  sub check {
    my $self = shift;
    my ( $field, $min, $max, $type) = @_;
    $min  ||= 0;
    $max  ||= 0;
    $type ||= '';
    
    my $value = $self->{'query'}->get($field) || '';
    my $error = '';
    $self->{'field_num'}++;
    
    $self->{'plugin'}->add_error( 'fc_plugin', 'self', 'field_' . $field, '' );
    $self->{'plugin'}->add_error( 'fc_plugin', 'self', 'field',           '' );            
    
    if ($min) {
      $error .= 'min, ' if length($value) < $min;
    }
    if ($max) {
      $error .= 'max, ' if length($value) > $max;
    }
    if ( $type eq 'num' ) {
      $error .= 'num, ' if $value =~ /\D+/;
    }
    if ( $type eq 'email' ) {

      if ($value) {    # sólo da error si el campo no esta vacío, podía ser opcional
        $error .= 'email, ' if $value !~ /[a-z0-9!#$%&'*+\/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+\/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?/;
      }

    }
    if ( $type =~ /^\/(.*)\/(.*)$/ ) {
      my $regex = "(?x$2)$1";

      if ($value) {    # sólo da error si el campo no esta vacío, podía ser opcional
        $error .= 'regular expression' if $value !~ /$regex/;
      }  
    }

    if ( $error ) {
      $self->{'error_check'} = 1;
      $self->{'plugin'}->add_error( 'fc_plugin', $self->{'name'}, 'field_' . $field, $error );
      $self->{'plugin'}->add_error( 'fc_plugin', $self->{'name'}, 'field',           $error );
      $self->{'plugin'}->add_error( 'fc_plugin', 'self', 'field_' . $field, $error );
      $self->{'plugin'}->add_error( 'fc_plugin', 'self', 'field',           $error );
      $self->{'plugin'}->add_error( 'fc_plugin', 'self', 'field_' . $self->{'field_num'}, $error );
    }
    
    return;
  }
  
  sub save {
    my $self = shift;

    use Digest::MD5 qw(md5_hex);
    my $pass = '';
    my %obfuscated = %{ $self->{'obfuscated'} };
    $self->{'data'} = '';
    $self->{'data'} .= $self->{'key_name'} . '=' . $self->{'key_value'};
    $self->{'data'} .= "\n";

    my $tmp_data = '';
    foreach my $key ( keys %obfuscated ) {
      $tmp_data .= $obfuscated{$key} . '=' . $key . "\n";
      $pass .= $self->{'query'}->get( $key ) || '';
    }
    $self->{'save_hash'} = md5_hex($pass);
    
    my $last = $self->{'last_step'};
    if ( $self->{'captcha'} && $self->{'captcha_last'} ) {
      if ( $self->{'captcha_ok'} ) {
        $last = 1;
        $self->{'expired'} = $self->{'expire_last'};
      } else {
        $last = 0;
        $self->{'expired'} = $self->{'expire'};
      }
    }
    
    # controla la expiración de la cookie
    $self->{'data'} .= time;
    $self->{'data'} .= "\n";
    $self->{'data'} .= $self->{'save_hash'};
    $self->{'data'} .= "\n";
    $self->{'data'} .= $last;    
    $self->{'data'} .= "\n";    
    $self->{'data'} .= $tmp_data;

    $self->{'cookies'}->create( $self->{'name'}, $self->{'data'}, $self->{'expired'} );
    $self->{'plugin'}->add_env( 'fc_plugin', $self->{'name'}, 'expire', $self->{'expired'} );
    $self->{'plugin'}->add_env( 'fc_plugin', 'self', 'expire', $self->{'expired'} );    

  }  
  
  sub load {
    my $self = shift;

    use Digest::MD5 qw(md5_hex);
    $self->{'cookie'} = $self->{'cookies'}->get( $self->{'name'} ) || '';

    my %obfuscated;
    my @lines = split( /\n/, $self->{'cookie'} );
    my $fline = shift @lines || '';
    ( $self->{'key_name'}, $self->{'key_value'} ) = split( '=', $fline );
    my $time = shift @lines || 0;
    my $hash = shift @lines || '';
    my $last = shift @lines || 0;
    my $pass = '';

    foreach my $line (@lines) {
      my ( $var, $value ) = split( '=', $line );
      
      $obfuscated{$var} = $value;
      $pass .= $self->{'query'}->{'q'}{$var} || '';
    }
    
    $self->{'generated_hash'} = md5_hex($pass);
    $self->{'load_hash'}      = $hash;
    $self->{'time_cookie'}    = $time;
    $self->{'last_cookie'}    = $last;
    $self->{'expired'}        = $self->{'expire_last'} if $self->{'last_cookie'};

    foreach my $key ( keys %obfuscated ) {
      my $key_value = $self->{'query'}->get($key);
      my $field     = $obfuscated{$key};
      $self->{'query'}->set( $field, $key_value );
    }

    $self->{'top_container'}->init_nes_env();

    return;
  }
  
  sub is_ok {
    my $self = shift;

    $self->{'fatal_error'} = 0;
    $self->{'plugin'}->set_data( 'fc_plugin', $self->{'name'}, 'is_ok', 0 );
    $self->{'plugin'}->add_env( 'fc_plugin', $self->{'name'}, 'is_ok', 0 ); 
    $self->{'plugin'}->add_env( 'fc_plugin', 'self', 'is_ok', 0 ); 

    # no se ha terminado de llenar el formulario
    if ( !$self->{'fc_is_start'} ) {
      $self->{'last_error'} = 'no form start';
      $self->{'fatal_error'} = 0;
      $self->{'plugin'}->add_last_error(  'fc_plugin', $self->{'name'}, 'no form start' );
      $self->{'plugin'}->add_fatal_error( 'fc_plugin', $self->{'name'}, '' );
      $self->{'plugin'}->add_last_error(  'fc_plugin', 'self', 'no form start' );
      $self->{'plugin'}->add_fatal_error( 'fc_plugin', 'self', '' );   
      return 0;
    }

    # maximo de intentos
    if ( $self->{'attempts'} > $self->{'max_attempts'} ) {
      $self->{'last_error'}  = "5 max attempts, wait $self->{'max_time'} minutes";
      $self->{'fatal_error'} = 5;
      $self->{'plugin'}->add_fatal_error( 'fc_plugin', $self->{'name'}, '5' );
      $self->{'plugin'}->add_last_error( 'fc_plugin', $self->{'name'}, "max attempts, wait $self->{'max_time'} minutes" );
      $self->{'plugin'}->add_fatal_error( 'fc_plugin', 'self', '5' );
      $self->{'plugin'}->add_last_error( 'fc_plugin', 'self', "max attempts, wait $self->{'max_time'} minutes" );
      return 0;
    }
    
    # no existe la cookie
    if ( !$self->{'cookie'} ) {
      $self->{'last_error'}  = 'no cookie';
      $self->{'fatal_error'} = 1;
      $self->{'plugin'}->add_fatal_error( 'fc_plugin', $self->{'name'}, '1' );
      $self->{'plugin'}->add_last_error( 'fc_plugin', $self->{'name'}, 'no cookie o expire' );
      $self->{'plugin'}->add_fatal_error( 'fc_plugin', 'self', '1' );
      $self->{'plugin'}->add_last_error( 'fc_plugin', 'self', 'no cookie o expire' );      
      return 0;
    }

    # la cookie ha expirado, expiración interna, "posible" manipulación de la cookie
    if ( ( $self->{'time_cookie'} + utl::expires_time( $self->{'expired'} ) ) < time  ) {
      $self->{'last_error'}  = 'cookie expired, posible manipulate cookie';
      $self->{'fatal_error'} = 2;
      $self->{'plugin'}->add_fatal_error( 'fc_plugin', $self->{'name'}, '2' );
      $self->{'plugin'}->add_last_error( 'fc_plugin', $self->{'name'}, 'cookie expired, posible manipulate cookie' );
      $self->{'plugin'}->add_fatal_error( 'fc_plugin', 'self', '2' );
      $self->{'plugin'}->add_last_error( 'fc_plugin', 'self', 'cookie expired, posible manipulate cookie' );    
      return 0;
    }

    # no se ha terminado de llenar el formulario
    if ( !$self->{'fc_is_finish'} ) {
      $self->{'last_error'} = 'no form finish';
      $self->{'fatal_error'} = 0;
      $self->{'plugin'}->add_last_error( 'fc_plugin', $self->{'name'}, 'no form finish' );
      $self->{'plugin'}->add_fatal_error( 'fc_plugin', $self->{'name'}, '' );
      $self->{'plugin'}->add_last_error( 'fc_plugin', 'self', 'no form finish' );
      $self->{'plugin'}->add_fatal_error( 'fc_plugin', 'self', '' );      
      return 0;
    }

    # hash no coninciden, seguramente la cookie ha sido manipulada
    if ( $self->{'generated_hash'} ne $self->{'load_hash'} ) {
      $self->{'last_error'}  = 'posible manipulate cookie data';
      $self->{'fatal_error'} = 3;
      $self->{'plugin'}->add_fatal_error( 'fc_plugin', $self->{'name'}, '3' );
      $self->{'plugin'}->add_last_error( 'fc_plugin', $self->{'name'}, 'posible manipulate cookie data' );
      $self->{'plugin'}->add_fatal_error( 'fc_plugin', 'self', '3' );
      $self->{'plugin'}->add_last_error( 'fc_plugin', 'self', 'posible manipulate cookie data' );      
      return 0;
    }

    # no se ha definido la "key", tal vez no tenga javascript habilitado
    if ( !$self->{'query'}->get( $self->{'key_name'} ) ) {
      $self->{'last_error'}  = 'no javascript key, javascript enabled?';
      $self->{'fatal_error'} = 4;
      $self->{'plugin'}->add_fatal_error( 'fc_plugin', $self->{'name'}, '4' );
      $self->{'plugin'}->add_last_error( 'fc_plugin', $self->{'name'}, 'no javascript key, javascript enabled?' );
      $self->{'plugin'}->add_fatal_error( 'fc_plugin', 'self', '4' );
      $self->{'plugin'}->add_last_error( 'fc_plugin', 'self', 'no javascript key, javascript enabled?' );      
      return 0;
    }

    # se intenta usar una cookie válida ya usada
    if ( $self->{'used_key'} eq $self->{'key_value'} ) {
      $self->{'last_error'}  = "already been used";
      $self->{'fatal_error'} = 6;
      $self->{'plugin'}->add_fatal_error( 'fc_plugin', $self->{'name'}, '6' );
      $self->{'plugin'}->add_last_error( 'fc_plugin', $self->{'name'}, "already been used" );
      $self->{'plugin'}->add_fatal_error( 'fc_plugin', 'self', '6' );
      $self->{'plugin'}->add_last_error( 'fc_plugin', 'self', "already been used" );      
      return 0;
    }

    # javascript está habilitado, posible manipulación del formulario
    if ( $self->{'key_value'} ne $self->{'query'}->get( $self->{'key_name'} ) ) {
      $self->{'last_error'}  = 'no javascript key value, posible manipulate form';
      $self->{'fatal_error'} = 7;
      $self->{'plugin'}->add_fatal_error( 'fc_plugin', $self->{'name'}, '7' );
      $self->{'plugin'}->add_last_error( 'fc_plugin', $self->{'name'}, 'no javascript key value, posible manipulate form' );
      $self->{'plugin'}->add_fatal_error( 'fc_plugin', 'self', '7' );
      $self->{'plugin'}->add_last_error( 'fc_plugin', 'self', 'no javascript key value, posible manipulate form' );
      return 0;
    }

    $self->{'last_error'}  = '';
    $self->{'fatal_error'} = 0;
    $self->{'plugin'}->add_fatal_error( 'fc_plugin', $self->{'name'}, 0 );
    $self->{'plugin'}->add_last_error( 'fc_plugin', $self->{'name'}, 'ok' );
    $self->{'plugin'}->add_fatal_error( 'fc_plugin', 'self', 0 );
    $self->{'plugin'}->add_last_error( 'fc_plugin', 'self', 'ok' );    

    $self->{'is_ok'} = 1;
    $self->{'plugin'}->set_data( 'fc_plugin', $self->{'name'}, 'is_ok', 1 );
    $self->{'plugin'}->add_env( 'fc_plugin', $self->{'name'}, 'is_ok', 1 ); 
    $self->{'plugin'}->add_env( 'fc_plugin', 'self', 'is_ok', 1 );     

    return 1;
  }


}

{

  package nes_fc_captcha;
  use vars qw(@ISA);
  @ISA = qw( Nes );

  sub new {
    my $class = shift;
    my ( $form_name, $name, $last, $type, $digits, $noise, $size, $sig, $spc, $key ) = @_;
    my $self = $class->SUPER::new();

    $self->{'form'} = Nes::Singleton->instance->{'register'}->get( 'fc_plugin', $form_name );

    # register plugin
    $self->{'plugin'} = $self->{'register'};

    $self->{'captcha_start_name'}  = $self->{'CFG'}{'fc_captcha_start'} . '_' . $name;
    $self->{'captcha_start'}       = $self->{'query'}->get( $self->{'captcha_start_name'} ) || '';
    $self->{'captcha_start_field'} = '<input type="hidden" name="' . $self->{'captcha_start_name'} . '"  value="' . $name . '" />';
    $self->{'class'}               = 'nes_fc_captcha_' . $type;
    $self->{'captcha'}             = $self->{'class'}->new( $name, $digits, $noise, $size, $sig, $spc, $key );
    $self->{'captcha_name'}        = $name || '';
    $self->{'fc_name'}             = 'captcha_'.$self->{'captcha_name'};
    $self->{'fc_name_self'}        = 'captcha_self';
    $self->{'captcha_tmp'}         = nes_tmp->new($self->{'CFG'}{'fc_captcha_suffix'},$self->{'form'}->{'name'}.'_'.$self->{'captcha_name'});
    
    $self->{'time'}        = 0;
    $self->{'load_key_ok'} = '';

    $self->{'is_ok'} = 0;
    $self->load_captcha();  

    return $self;
  }
  
  sub create {
    my $self = shift;

    $self->{'captcha'}->create();
    $self->{'key_ok'} = $self->{'captcha'}->{'key_ok'};
    $self->save_captcha();
#    $self->load_captcha(); 
    
  }  
  
  sub is_ok {
    my $self = shift;
    my ($key_ok) = @_;
    
    $key_ok = $self->{'query'}->get( $self->{'captcha_name'} ) if !$key_ok;
    
    $self->{'is_ok'} = 0;
    $self->{'fatal_error'} = 0;

    # no se ha terminado de llenar el formulario
    $self->{'last_error'} = 'no captcha start';
    $self->{'plugin'}->add_fatal_error( 'fc_plugin', $self->{'fc_name'}, 0 );
    $self->{'plugin'}->add_last_error( 'fc_plugin', $self->{'fc_name'}, 'no captcha start' );
    $self->{'plugin'}->add_fatal_error( 'fc_plugin', $self->{'fc_name_self'}, 0 );
    $self->{'plugin'}->add_last_error( 'fc_plugin', $self->{'fc_name_self'}, 'no captcha start' );    
    return 0 if !$self->{'form'}->{'fc_is_start'} || !$self->{'captcha_start'};    

    $self->{'last_error'}  = 2;
    $self->{'fatal_error'} = 2;
    $self->{'plugin'}->add_last_error( 'fc_plugin', $self->{'fc_name'}, 'no key' );
    $self->{'plugin'}->add_fatal_error( 'fc_plugin', $self->{'fc_name'}, 2 );
    $self->{'plugin'}->add_fatal_error( 'fc_plugin', $self->{'fc_name_self'}, 2 );
    $self->{'plugin'}->add_last_error( 'fc_plugin', $self->{'fc_name_self'}, 'no key' );          
    return (0) if !$key_ok;

    if ( $key_ok eq $self->{'load_key_ok'} ) {
      $self->{'last_error'}  = 0;
      $self->{'fatal_error'} = 0;
      $self->{'plugin'}->add_last_error( 'fc_plugin', $self->{'fc_name'}, '' );
      $self->{'plugin'}->add_fatal_error( 'fc_plugin', $self->{'fc_name'}, 0 );
      $self->{'plugin'}->add_env( 'fc_plugin', $self->{'fc_name'}, 'is_ok', 1 );
      $self->{'plugin'}->add_fatal_error( 'fc_plugin', $self->{'fc_name_self'}, 0 );
      $self->{'plugin'}->add_last_error( 'fc_plugin', $self->{'fc_name_self'}, '' ); 
      $self->{'plugin'}->add_env( 'fc_plugin', $self->{'fc_name_self'}, 'is_ok', 1 );     
      $self->{'is_ok'} = 1;
      $self->{'captcha_tmp'}->clear();
      return (1);
    }

    $self->{'last_error'}  = 5;
    $self->{'fatal_error'} = 5;
    $self->{'plugin'}->add_last_error( 'fc_plugin', $self->{'fc_name'}, 'incorrect key' );
    $self->{'plugin'}->add_fatal_error( 'fc_plugin', $self->{'fc_name'}, 5 );
    $self->{'plugin'}->add_fatal_error( 'fc_plugin', $self->{'fc_name_self'}, 5 );
    $self->{'plugin'}->add_last_error( 'fc_plugin', $self->{'fc_name_self'}, 'incorrect key' );    
    $self->{'is_ok'} = 0;
    return (0);
  }

  sub save_captcha {
    my $self = shift;

    my $key_ok  = $self->{'key_ok'};
    $self->{'captcha_tmp'}->save(time.':'.$key_ok);
    
    return;
  }

  sub load_captcha {
    my $self = shift;
    
    my @data = $self->{'captcha_tmp'}->load();
    my $line = pop @data || ':';
    ( $self->{'time'}, $self->{'load_key_ok'} ) = split( ':', $line, 2 );    
    return;
  }

  sub out {
    my $self = shift;

    return $self->{'captcha'}->out;
  }
  
  
}


{

  package nes_fc_captcha_ascii;
  use vars qw(@ISA);
  @ISA = qw( Nes );

  sub new {
    my $class = shift;
    my ( $name, $digits, $noise_level, $size, $sig_char, $space_char, $key ) = @_;
    my $self = $class->SUPER::new();

    $self->{'captcha_name'} = $name;
    $self->{'key_ok'}       = $key;

    my @sigs = ( '0', 'X', '9', '@', '&#9617;', '&#9619;', '&#9689;' );
    my @spaces = ( ' ', '·', '.', ',', ' ', '&#732;', '&#39;', '&nbsp;', '&#8249;', '&nbsp;' );

    $self->{'noise_level'} = $self->{'CFG'}{'fc_captcha_noise'} || 1;

    # $noise_level puede ser 0
    $self->{'noise_level'} = $noise_level if defined $noise_level;
    $self->{'noise_level'} = 9 if $self->{'noise_level'} > 9;

    $self->{'digits'}     = $digits     || $self->{'CFG'}{'fc_captcha_digits'} || ( 5 + int rand 3 );
    $self->{'size'}       = $size       || $self->{'CFG'}{'fc_captcha_size'}   || 2;
    $self->{'sig_char'}   = $sig_char   || $self->{'CFG'}{'fc_captcha_sig'}    || ( $sigs[ int rand $#sigs + 1 ] );
    $self->{'space_char'} = $space_char || $self->{'CFG'}{'fc_captcha_spc'}    || ( $spaces[ int rand $#spaces + 1 ] );

    return ($self);
  }

  sub create {
    my $self = shift;

    my $fonts = nes_fc_captcha_fonts->new();
    my @type  = @{ $fonts->{'ceros'}{'font'} };
    my $sig   = $fonts->{'ceros'}{'sig'};

    my $nums = $self->{'key_ok'};
    if ( ! $nums ) {
      for ( 1 .. $self->{'digits'} ) {
        $nums .= int rand 10;
      }
      $self->{'key_ok'} = $nums;
    }

    my @lines;
    my $noise;
    foreach my $num ( split( '', $nums ) ) {
      my @char  = @{ $type[$num] };
      my $n1    = int rand 9;
      my $space = ' ' x 1;
      $space = ' ' x ( int rand 4 ) if $self->{'noise_level'};
      unshift( @char, pop(@char) ) if int rand 2;
      for ( my $i = 0 ; $i < @char ; $i++ ) {
        $lines[$i] .= $space . $char[$i] . $space;
      }
    }

    # add noise
    if ( $self->{'noise_level'} ) {

      # corta una columna, dificulta que se detecte el comienzo de cada número
      my $colums = ',';
      for ( my $c = 0 ; $c < length( $lines[0] ) ; $c++ ) {
        if ( !int rand 9 - $self->{'noise_level'} ) {
          $colums .= $c . ',';
          $c = $c + 4;
        }
      }
      foreach my $line (@lines) {
        my $colum = int rand length($line);
        for ( my $c = 0 ; $c < length($line) ; $c++ ) {
          for ( my $level = 0 ; $level < $self->{'noise_level'} && $level < 10 ; $level++ ) {
            substr( $line, $c, 1, ' ' ) if $colums =~ /,$c,/;
            substr( $line, $c, 1, $sig ) if $colums =~ /,$c,/ && !int rand 5;
            substr( $line, $c, 1, $sig ) if !int rand 50;
            substr( $line, $c, 1, ' ' )  if !int rand 50;
          }
        }
      }
    }

    my $line_out;
    foreach my $line (@lines) {
      $line =~ s/ /$self->{'space_char'}/gi;
      $line =~ s/$sig/$self->{'sig_char'}/gi;
      $line .= "\n";
      $line_out .= $line;
    }

    if ( $self->{'size'} ne 'none' ) {
      $line_out = '<pre style="font-size:' . $self->{'size'} . 'px; line-height:1.0;">' . $line_out . '<br></pre>';
    }

    $self->{'out'} = $line_out;

    return;
  }

  sub out {
    my $self = shift;

    return $self->{'out'};
  }

}

{

  package nes_fc_captcha_fonts;

  sub new {
    my $class = shift;
    my $self = bless {}, $class;

    # con el caracter que esta escrita la fuente
    $self->{'ceros'}{'sig'} = '0';
    @{ $self->{'ceros'}{'font'} } = (
      [
        '               ',
        ' 0000000000000 ',
        '000000000000000',
        '0000       0000',
        '0000       0000',
        '0000       0000',
        '0000       0000',
        '0000       0000',
        '0000       0000',
        '0000       0000',
        '0000       0000',
        '000000000000000',
        ' 0000000000000 ',
        '               ',
        '               ',
      ],
      [
        '               ',
        '    000000     ',
        '   0000000     ',
        '      0000     ',
        '      0000     ',
        '      0000     ',
        '      0000     ',
        '      0000     ',
        '      0000     ',
        '      0000     ',
        '      0000     ',
        '000000000000000',
        ' 0000000000000 ',
        '               ',
        '               ',
      ],
      [
        '               ',
        ' 0000000000000 ',
        '000000000000000',
        '           0000',
        '           0000',
        '           0000',
        ' 00000000000000',
        '00000000000000 ',
        '0000           ',
        '0000           ',
        '0000           ',
        '000000000000000',
        ' 0000000000000 ',
        '               ',
        '               ',
      ],
      [
        '               ',
        ' 0000000000000 ',
        '000000000000000',
        '           0000',
        '           0000',
        '           0000',
        ' 00000000000000',
        ' 00000000000000',
        '           0000',
        '           0000',
        '           0000',
        '000000000000000',
        ' 0000000000000 ',
        '               ',
        '               ',
      ],
      [
        '               ',
        ' 000       000 ',
        '0000       0000',
        '0000       0000',
        '0000       0000',
        '0000       0000',
        '000000000000000',
        ' 00000000000000',
        '           0000',
        '           0000',
        '           0000',
        '           0000',
        '           000 ',
        '               ',
        '               ',
      ],
      [
        '               ',
        ' 0000000000000 ',
        '000000000000000',
        '0000           ',
        '0000           ',
        '0000           ',
        '00000000000000 ',
        ' 00000000000000',
        '           0000',
        '           0000',
        '           0000',
        '000000000000000',
        ' 0000000000000 ',
        '               ',
        '               ',
      ],
      [
        '               ',
        ' 0000000000000 ',
        '000000000000000',
        '0000           ',
        '0000           ',
        '0000           ',
        '00000000000000 ',
        '000000000000000',
        '0000       0000',
        '0000       0000',
        '0000       0000',
        '000000000000000',
        ' 0000000000000 ',
        '               ',
        '               ',
      ],
      [
        '               ',
        ' 0000000000000 ',
        '000000000000000',
        '           0000',
        '           0000',
        '           0000',
        '           0000',
        '           0000',
        '           0000',
        '           0000',
        '           0000',
        '           0000',
        '           000 ',
        '               ',
        '               ',
      ],
      [
        '               ',
        ' 0000000000000 ',
        '000000000000000',
        '0000       0000',
        '0000       0000',
        '0000       0000',
        '000000000000000',
        '000000000000000',
        '0000       0000',
        '0000       0000',
        '0000       0000',
        '000000000000000',
        ' 0000000000000 ',
        '               ',
        '               ',
      ],
      [
        '               ',
        ' 0000000000000 ',
        '000000000000000',
        '0000       0000',
        '0000       0000',
        '0000       0000',
        '000000000000000',
        ' 00000000000000',
        '           0000',
        '           0000',
        '           0000',
        '           0000',
        '           000 ',
        '               ',
        '               ',
      ]
    );

    return $self;
  }

}


1;