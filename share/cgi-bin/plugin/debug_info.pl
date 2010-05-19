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
#  debug_info.pl
#
# -----------------------------------------------------------------------------

  use strict;
  use warnings;
  use debug_info;

  my $nes       = Nes::Singleton->instance;
  my $container = nes_container->get_obj();
#  my $nes       = Nes::View->new;
#  my $container = nes_container->get_obj();
  my $this_template_name = $container->{'file_name'};
  my $top_template_name  = $nes->{'top_container'}->{'file'};  
  my $info      = debug_info->new($container);
  my $template  = $container->{'content_obj'};
  my $config    = $nes->{'CFG'};
  my $remote    = $nes->{'top_container'}->get_nes_env('nes_remote_ip');
  my $in_top    = ( $container eq $nes->{'top_container'}->{'container'} );
  
  return 1 if $remote !~ /^$config->{'debug_info_only_from_ip'}/;

  $nes->{'nes'}->{'debug_info'}{'is_load'}     = 1;
  $nes->{'nes'}->{'debug_info'}{'obj'} = $info if !$nes->{'nes'}->{'debug_info'}{'obj'};
  
  return 1 if $container->{'error_not_exist'};

  if ( !$template->{'exec'} ) {
    $info->{'load_plugin_first'} = 1;
    $info->redirect_err;
    $info->benchmark_init($container);
    return 1;
  } else {
    $info->redirect_err_parent;
    $info->benchmark_end($container);
  }
  

  # no cuenta el tiempo de debug
  $info->benchmark_stop($container);

  my $exclude = '\/'.join('$|\/',@{$config->{'debug_info_exclude'}}).'$';

  if ( $in_top ) {

    $nes->{'nes'}->{'debug_info'}{'is_load'} = 0;
    return 1 if $this_template_name =~ /$exclude/;
    
    $info->add($container);
    $info->unredirect_err;
    
    if ( $config->{'debug_info_show_in_out'} ) {
      if ( $info->{'location'} ) {
        $container->set_out_content( $info->{'out'} );
      } else {
        $container->set_out_content( $info->{'out'}.$container->get_out_content ) if $config->{'debug_info_show_up'};
        $container->set_out_content( $container->get_out_content.$info->{'out'} ) if !$config->{'debug_info_show_up'};
      }
    }
    
  } else {
    
    $info->add($container) if $this_template_name !~ /$exclude/;;
    
  }
  $info->benchmark_continue($container);

1;



