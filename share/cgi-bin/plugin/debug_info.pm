#!/usr/bin/perl

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
#  debug_info.pm
#
# -----------------------------------------------------------------------------

use strict;
use Nes;
use Benchmark qw(:all :hireswallclock);

{

  package debug_info;
  use vars qw(@ISA);
  @ISA = qw( Nes );

  my $instance;
  
  sub new {
    my $class  = shift;
    my $self   = $instance || $class->SUPER::new();
    my ($template) = @_;
    
    $self->{'inter'} = $template->{'this_inter'}; 
    $self->{'first_time'} = 1;
    $self->init($template) if !$instance;
    $self->{'first_time'} = 0 if $instance; 

    $instance = $self;
    return $self;
  }

  sub init {
    my $self = shift;
    my ($template) = @_;
    
    $self->del_instance();

    $self->{'tag_first_time'} = 1;
    $self->{'load_plugin_first'} = 0;
    $self->{'redirect_err'} = 0; 
    $self->{'benchmark_continue'} = undef;
    $self->{'tree'} = [{}];
    
    $self->{'plugin'}    = $self->{'register'}->add_obj('debug_info', 'debug_info', $self );
    $self->{'objects'}   = ();
    $self->{'template'}  = $template;
    $self->{'remote_ip'} = $self->{'top_container'}->get_nes_env('nes_remote_ip');
    
    use POSIX qw(strftime);
    my $gmt = POSIX::strftime( "%a %e %b %Y %H:%M:%S", gmtime );
    $self->{'starting'}  = "*----------------------------------";
    $self->{'starting'} .= "* debug_info starting at $gmt GMT *";
    $self->{'starting'} .= "----------------------------------*\n\n";   
    $self->{'starting_show'} = 1; 
    
    my $interpret = nes_interpret->new( $self->{'CFG'}->{'debug_info_template'} );
    $self->{'debug_info_template'} = $interpret->go();

    return;
  }
  
  sub redirect_err {
    my $self = shift;

    use IO::Scalar;
    tie *STDERR, 'IO::Scalar', \$self->{'STDERR'}{$self->{'inter'}};  
    $self->{'redirect_err'} = 1;  

  }
  
  sub unredirect_err {
    my $self = shift;

    return if !$self->{'redirect_err'};
    
    untie *STDERR;
    $self->{'redirect_err'} = 0; 
    
  }  
  
  sub add {
    my $self = shift;
    my ($container) = @_;
    my $inter = $container->{'this_inter'};    

    $self->{'obj'} = debug_obj->new;
    
    $self->{'obj'}->{'tags'}->{'first_time'} = $self->{'tag_first_time'};
    $self->{'obj'}->{'tags'}->{'benchmark'}  = $self->{'benchmark'}{$inter};
    $self->{'obj'}->{'tags'}->{'STDERR'}     = $self->{'STDERR'}{$self->{'inter'}};
   
    $self->{'obj'}->add;
    $self->{'tree'}[$inter] = $self->{'obj'}->tree;
    $self->{'obj'}->{'tags'}->{'tree'} = $self->tree if $self->{'obj'}->{'is_top'}; 

    $self->{'tag_first_time'} = 0;
    push( @{$self->{'objects'}}, $self->{'obj'} );
      
    $self->{'top'} = nes_top_container->new();  

    $self->{'top'}->{'container'} = nes_container->new($self->{'debug_info_template'});
    $self->{'top'}->{'container'}->set_tags(%{$self->{'obj'}->{'tags'}});
    $self->{'top'}->{'container'}->interpret(); 
    $self->{'obj'}->{'out'} = $self->{'top'}->{'container'}->get_out;
    $self->{'out'}         .= $self->{'obj'}->{'out'};
  
    $self->save;
    
    $self->{'top'}->{'container'}->forget();
    $self->{'top'}->forget();

    return;
  }
  
  sub tree {
    my $self = shift;
    my $out  = '';

    my $img_error = '<img title="Eror" src="http://'.$ENV{'SERVER_NAME'}.$self->{'CFG'}->{'img_dir'}.'/error_i.gif">';
    my $img_warn  = '<img title="Warning" src="http://'.$ENV{'SERVER_NAME'}.$self->{'CFG'}->{'img_dir'}.'/error_b_i_s.gif">';
      
    my $last_inter = @{$self->{'tree'}};
    my $absolute   = $self->{'tree'}[1]->{'benchmark'};
    $absolute =~ s/\s*([\d\.\,]*).*/$1/;
    $absolute =~ s/\,/\./;
    my $level = 0;

    foreach my $inter ( @{$self->{'tree'}} ) {
      next if !$inter->{'template'}; 
      
      my $benchmark = $inter->{'benchmark'};
      $benchmark =~ s/\s*([\d\.\,]*).*/$1/;
      $benchmark =~ s/\,/\./;
      $inter->{'benchmark'} = sprintf("%.1f", $benchmark*100/$absolute) if $inter->{'benchmark'};
      $inter->{'benchmark_s'} = $benchmark;      
     
      $inter->{'level'} = 0 if !$inter->{'parent'};
      $inter->{'level'} = $self->{'tree'}[$inter->{'parenti'}]->{'level'}+1;
      my $tab = 4*$inter->{'level'};
      $tab = ' 'x$tab; 

      my (@errors) = split(/\n/,$inter->{'STDERR'});
      my $box  = '';
         $box .= $tab.'.--'.'-'x length($inter->{'url'}).'.'."\n" if $inter->{'url'};
         $box .= $tab.'| <b>'.$inter->{'url'}.'</b>'." |\n" if $inter->{'url'};
         $box .= $tab.'&brvbar;--'.'-'x length($inter->{'url'}).'\''."\n" if $inter->{'url'};
         $box .= $tab.'.--'.'-'x length($inter->{'template'}).'.'."\n" if !$inter->{'url'};
         $box .= $tab.'| <b>'.$inter->{'template'}.'</b>'." |\n";
         $box .= $tab.'&brvbar;--'.'-'x length($inter->{'template'}).'\''."\n";
         $box .= $tab.'| '.$inter->{'NES'}."\n" if $inter->{'NES'};         
         $box .= $tab.'| '.$inter->{'benchmark'}.'% of execution time '.'('.$inter->{'benchmark_s'}.' secs)'."\n" if $inter->{'benchmark_s'};
         foreach my $error ( @errors ) {
           my $img = $img_error;
           $img    = $img_warn if $error =~ /^Warning/;           
           $box   .= $tab.'| '.$img.' '.$error."\n";
         }
         $box .= $tab.'\'---&middot'."\n";

      $out .= $box;
    }

    
    return $out;
  }
  
  sub benchmark_init {
    my $self = shift;
    my ($container) = @_;
    my $inter = $container->{'this_inter'};
    
    return $self->{'init_benchmark'}{$inter} = new Benchmark;
  }
  
  sub benchmark_end {
    my $self = shift;
    my ($container) = @_;
    my $inter = $container->{'this_inter'};
    return if !$self->{'init_benchmark'}{$inter};

    $self->{'benchmark'}{$inter} = Benchmark::timediff(new Benchmark, $self->{'init_benchmark'}{$inter});
    
    # quitamos el tiempo que ha consumido el debug
    if ( $self->{'benchmark_time_debug'}{$inter} ) {
      foreach my $par ( keys %{$self->{'benchmark_time_debug'}{$inter}} ) {
        next if !$self->{'benchmark_time_debug'}{$inter}{$par};
        $self->{'benchmark'}{$inter} = Benchmark::timediff($self->{'benchmark'}{$inter}, $self->{'benchmark_time_debug'}{$inter}{$par});
      }
    }
    $self->{'benchmark'}{$inter} = Benchmark::timestr($self->{'benchmark'}{$inter});
    
    return;
  }
  
  sub benchmark_stop {
    my $self = shift;
    my ($container) = @_;
    my $inter = $container->{'this_inter'};
    return if !$self->{'init_benchmark'}{$inter};
    
    while ($inter) {
      $container = $container->{'parent'};
      $inter = $container->{'this_inter'};
      $self->{'benchmark_stop'}{$inter} = new Benchmark;
    }

    return;
  }
  
  sub benchmark_continue {
    my $self = shift;
    my ($container) = @_;
    my $inter = $container->{'this_inter'};
    return if !$inter;
    return if !$self->{'init_benchmark'}{$inter};

    while ($inter) {
      $container = $container->{'parent'};
      $inter = $container->{'this_inter'};
      my $par = $self->{'benchmark_continue'}{$inter} || 0;
      $self->{'benchmark_time_debug'}{$inter}{$par} = Benchmark::timediff(new Benchmark,$self->{'benchmark_stop'}{$inter});
      $self->{'benchmark_continue'}{$inter}++;
    }

    return;
  }  
  
  sub save {
    my $self = shift;

    if ( $self->{'CFG'}->{'debug_info_save_to_log'} ) {
      open(my $log, '>>', $self->{'CFG'}->{'debug_info_save_to_log'}) || warn "couldn't open $self->{'CFG'}->{'debug_info_save_to_log'}";
      print $log $self->{'starting'} if $self->{'starting_show'};
      print $log $self->{'obj'}->{'out'};
      close $log;
      $self->{'starting_show'} = 0;
    }  

    return;
  }
  
  sub del_instance {
    my $self = shift;

    utl::cleanup(\$instance) if $ENV{'MOD_PERL'}; 

    return;
  }   
  
{

  package debug_obj;
  use vars qw(@ISA);
  @ISA = qw( Nes );

  sub new {
    my $class = shift;
    my $self  = $class->SUPER::new();

    $self->{'tags'}              = {};
    $self->{'tags'}->{'cfg'}     = [ {} ];
    $self->{'tags'}->{'env_cgi'} = [ {} ];
    $self->{'tags'}->{'env_nes'} = [ {} ]; 
    $self->{'template'} = $self->{'container'};

    $self->{'is_top'} = ( $self->{'container'}->{'file_name'} eq $self->{'top_container'}->{'file'} );

    return $self;
  }
  
  sub add_top {
    my $self = shift;
    
    my $obj     = $self->{'template'};
    my $object  = $self->{'tags'};
    
    $object->{'top_template'} = 1;
    $object->{'url'}  = 'http://' if $ENV{'SERVER_PROTOCOL'} =~ /http/i;
    $object->{'url'} .= $ENV{'SERVER_NAME'}.$ENV{'REQUEST_URI'};

    $object->{'GET'}   = $ENV{'QUERY_STRING'};
#    if ( $self->{'query'}->{'save_buffer'} ) {
#      while ( my $buffer = $self->{'query'}->get_buffer ) {
#        $object->{'POST'} .= $buffer;
#      }
#    } else {
      $object->{'POST'}  = $self->{'query'}->get_buffer_raw;
#    }    
    
    $object->{'cookies'} = $obj->{'cookies'}->out;
    $object->{'headers'} = $obj->{'content_obj'}->{'HTTP-headers'} || 
                           $obj->{'content_obj'}->{'TAG_HTTP-headers'} || 
                           $obj->{'content_obj'}->{'Content-type'};

    @{$object->{'tail'}} = ();
    for (my $i = 0; $i <  @{$self->{'CFG'}->{'debug_info_tail_files'}}; $i++) {
      my $file  = $self->{'CFG'}->{'debug_info_tail_files'}[$i];
      my $lines = $self->{'CFG'}->{'debug_info_tail_lines'}[$i] || 50;
      my $tail = {};   
      $tail->{'file'} = $file;
      $tail->{'name'} = $file;
      $tail->{'name'} =~ s/.*\///;
      $tail->{'tail'} = qx(tail --lines=$lines $file) || ' *** file empty or error on read ***';
      $object->{'tail'}[$i] = $tail; 
    }
     
    return;
  }  
  
  sub add {
    my $self = shift;
    
    $self->add_top if $self->{'is_top'};    
    
    my $obj = $self->{'template'};
    my $object  = $self->{'tags'};

    foreach my $tag ( keys %{ $obj->{'top_container'}->{'nes_env'} } ) {
      my $value = $obj->{'top_container'}->{'nes_env'}{$tag};
      $value = "@{$value}" if ref $value eq 'ARRAY';
      $value = keys %{$value} if ref $value eq 'HASH';       
      $object->{'NES_'.$tag} = $value;
    }
    foreach my $tag ( keys %{ $self->{'CFG'} } ) {
      my $value = $self->{'CFG'}->{$tag};
      $value = "@{$value}" if ref $value eq 'ARRAY';
      $value = keys %{$value} if ref $value eq 'HASH';         
      $object->{'NES_'.$tag} = $value;
    }    

    $object->{'object'}            = $obj->{'file_name'};
    $object->{'object_no_path'}    = $obj->{'file_name'};
    $object->{'object_no_path'}    =~ s/.*\///;
    $object->{'object_no_ext'}     = $object->{'object_no_path'};
    $object->{'object_no_ext'}     =~ s/\.[^\.]*$//;
    $object->{'object_path'}       = $obj->{'file_name'};
    $object->{'object_path'}       =~ s/\/[^\/]*$//;
    $object->{'parent'}            = $obj->{'parent_file_name'};
    $object->{'parent_no_path'}    = $object->{'parent'};
    $object->{'parent_no_path'}    =~ s/\/[^\/]*$//;
    $object->{'type'}              = $obj->{'container'}->{'type'};
    $object->{'top_container_obj'} = $obj->{'top_container'};
    $object->{'container_obj'}     = $obj;
    $object->{'content_obj'}       = $obj->{'container'}->{'content_obj'};
    $object->{'interactions'}      = $obj->{'container'}->{'this_inter'};
    $object->{'scripts'}           = "@{ $obj->{'file_script'} }";
    $object->{'source'}            = $obj->{'container'}->{'file_nes_line'} || '';
    $object->{'source'}           .= "\n" if $obj->{'container'}->{'file_nes_line'};
    foreach my $line ( @{ $obj->{'container'}->{'file_souce'} } ) {
       $object->{'source'} .= $line;
    }    
    $object->{'out'}               = $obj->get_out_content();
    $object->{'dumper_top'}        = $self->dumper(\$obj->{'top_container'},3,'TOP');
    $object->{'dumper_container'}  = $self->dumper(\$obj->{'container'},6,'CONTAINER');
    $object->{'dumper_template'}   = $self->dumper(\$obj->{'container'}->{'content_obj'},6,'TEMPLATE');
    $object->{'dumper_cookies'}    = $self->dumper(\$obj->{'cookies'},6,'COOKIES');
    $object->{'dumper_session'}    = $self->dumper(\$obj->{'session'},6,'SESSION');
    $object->{'dumper_query'}      = $self->dumper(\$obj->{'query'},9,'QUERY');
    $object->{'dumper_CFG'}        = $self->dumper(\$obj->{'CFG'},6,'CFG');
    # {'nes'} contiene un puntero a si mismo, si $Maxdepth es mas de 3 empieza a dar problemas con la recursividad
    $object->{'dumper_nes'}        = $self->dumper(\$obj->{'nes'},3,'NES',1);
    $object->{'dumper_interpret'}  = $self->dumper(\$obj->{'content_obj'}->{'interpret'},6,'INTERPRET');
    $object->{'dumper_register'}   = $self->dumper(\$obj->{'register'},6,'REGISTER');
    $object->{'dumper_plugin'}     = $self->dumper(\$obj->{'register'}->{'obj'},9,'REGISTER_PLUGIN'); 
    $object->{'dumper_tags'}       = $self->dumper(\$obj->{'container'}->{'content_obj'}->{'tags'},8,'TAG',1);

    while ( $object->{'out'} =~ /($Nes::Tags::start\s*(($Nes::Tags::all_or).+?)$Nes::Tags::end)/gsio ) 
    { 
      my $tag = $2;
      $tag =~ s/$Nes::Tags::start/$Nes::Tags::start_html/g;
      $tag =~ s/$Nes::Tags::end/$Nes::Tags::end_html/g;
      $tag =~ s/(.{2,50}[\S]*)\s.*/$1 <b>...<\/b>/;
      $tag =~ s/\n|<br>/ /g;
      $object->{'STDERR'} .= "Not replaced: $tag\n";
    }

    eval {
      require HTML::Normalize;
      my $norm = HTML::Normalize->new();
      $object->{'normalize_out'} = $norm->cleanup(-keepimplicit => 1,-html => $object->{'out'});
    };

#    eval {
#      require HTML::Packer;
#      $object->{'clean_out'} = $object->{'out'};
#      HTML::Packer::minify( \$object->{'clean_out'}, { remove_comments => 1, remove_newlines => 1 });      
#    };    

    $self->env();   
    
    $self->{'tree'} =
    {
       template     => $object->{'object_no_path'},
       interaction  => $object->{'interactions'},
       parent       => $object->{'parent'},
       parenti      => $obj->{'container'}->{'parent'}->{'this_inter'},
       tags         => $object->{'dumper_tags'},
       object       => $object->{'object'},
       scripts      => $object->{'scripts'},
       NES          => $obj->{'container'}->{'file_nes_line'},
       url          => $object->{'url'},
       STDERR       => $object->{'STDERR'},
       benchmark    => $object->{'benchmark'}
    };

    return;
  }
  
  sub tree {
    my $self = shift;
    
    return $self->{'tree'};  
  }
  
  sub dumper {
    my $self = shift;
    my ($var, $Maxdepth, $Varname, $no_filter) = @_;
    
    use Data::Dumper;
    $Data::Dumper::Sortkeys = 1;
    $Data::Dumper::Sortkeys = \&debug_obj::_filter if !$no_filter;
    $Data::Dumper::Deepcopy = 0;
    $Data::Dumper::Indent   = 1;
    $Data::Dumper::Terse    = 0;
    $Data::Dumper::Terse    = 1 if !$Varname;
    $Data::Dumper::Varname  = $Varname  || 'Dumper_VARS';
    $Data::Dumper::Maxdepth = $Maxdepth || 8;

    my $data = Data::Dumper::Dumper($var);
    $data =~ s/(private.+\s*=>\s*\'|pass.+\s*=>\s*\')([^\']*)(\')/$1 *** REMOVED FOR SAFETY *** $3/ig;

    return $data;
  }
  
  sub _filter {
    my ($hashref) = @_;
    
    my @exclude = ( 'nes',
                    'out',
                    'container',
                    'content_obj',
                    'cookies',
                    'interpret',
                    'query',
                    'register',
                    'session',
                    'top_container',
                    'CFG',
                    'previous',
                    'parent',
                    'pre_end',
                    'pre_start',
                    'pre_subs_end',
                    'pre_subs_start',
                    'tag_comment',
                    'tag_end',
                    'tag_env',
                    'tag_expre',
                    'tag_field',
                    'tag_hash',
                    'tag_include',
                    'tag_nes',
                    'tag_sql',
                    'tag_start',
                    'tag_tpl',
                    'tag_var',
                    'tag_plugin',
                    'MAX_INTERACTIONS',
                    'MAX_SCRIPTS',
                    'debug_info'
                  );

    my $exclu = '^'.join('$|^',@exclude).'$';
    my @keys = ();
    foreach my $key ( keys %$hashref ){
      push(@keys, $key) if $key !~ /$exclu/;
    }
    @keys = sort @keys;

    return \@keys;
  }  
  
#  sub tidy {
#    my $self = shift;
#    
#    #/usr/bin/tidy
#    
#  }
  
  sub env {
    my $self = shift;
    
    my $obj = $self->{'template'};
    
    my $cfg     = $self->{'tags'}->{'cfg'};
    my $env_cgi = $self->{'tags'}->{'env_cgi'};
    my $env_nes = $self->{'tags'}->{'env_nes'};

    my $c = 0;
    foreach my $key ( sort keys %{ $self->{'CFG'} } ) {
      my $value = $self->{'CFG'}->{$key};
      $value = "@{$self->{'CFG'}->{$key}}" if ref $self->{'CFG'}->{$key} eq 'ARRAY';
      $value = keys %{$self->{'CFG'}->{$key}} if ref $self->{'CFG'}->{$key} eq 'HASH';  
      $cfg->[$c]->{'key'}   = $key;
      $cfg->[$c]->{'value'} = $value;      
      $cfg->[$c]->{'value'} = '*** REMOVED FOR SAFETY ***' if $key =~ /priv|pass/i;
      $c++;
    }

    $c = 0;
    foreach my $key ( sort keys %ENV ) {
      $env_cgi->[$c]->{'key'}   = $key;
      $env_cgi->[$c]->{'value'} = $ENV{$key};
      $env_cgi->[$c]->{'value'} = '*** REMOVED FOR SAFETY ***' if $key =~ /priv|pass/i;
      $c++;
    }    
    
    $c = 0;
    foreach my $key ( sort keys %{ $self->{'top_container'}->{'nes_env'} } ) {
      my $value = $self->{'top_container'}->{'nes_env'}{$key};
      $value = "@{$value}" if ref $value eq 'ARRAY';
      $value = keys %{$value} if ref $value eq 'HASH';        
      $env_nes->[$c]->{'key'}   = $key;
      $env_nes->[$c]->{'value'} = $value;
      $env_nes->[$c]->{'value'} = '*** REMOVED FOR SAFETY ***' if $key =~ /priv|pass/i;
      $c++;
    }       
    
  }  

}  


}




# don't forget to return a true value from the file
1;

