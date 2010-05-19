#!/usr/bin/perl

  use Nes::Framework;
  
  use strict;
  use warnings;   
  
  my ( 
    $view, 
    $query, 
    $config, 
    $session, 
    $cookies 
  ) = Nes::Framework::View->new( 'view' );
  
  my $vars           = {};
  $vars->{'query'}   = $query->param('action') || 'no set';
  $vars->{'session'} = $session->get           || 'no session';
  $vars->{'config'}  = $config->{'test_var'}   || '';
  $vars->{'cookies'} = 'no cookie session';
  $vars->{'cookies'} = $config->{'session_prefix'} if $cookies->get($config->{'session_prefix'});

  my $container = Nes::Framework::Container->new( 'container' );
  my $lucky     = Nes::Framework::Container->new( 'lucky',  { template => 'lucky.nhtml' } );
  my $sh_cal    = Nes::Framework::Container->new( 'cal',    { template => 'cal.sh' } );
  my $perl_pl   = Nes::Framework::Container->new( 'perl',   { template => 'perl.pl' } );
  my $source    = Nes::Framework::Container->new( 'source', { source => 'Nes version: {: * nes_ver :}' } );
  my $date_sour = Nes::Framework::Container->new( 'date by source' );
  my $date_file = Nes::Framework::Container->new( 'date by file' );
  my $add_out   = Nes::Framework::Container->new( 'add out' );

  #  #
  #  $container->set({
  #    _always => { var_container => $container->set({ source => '{: include lucky.nhtml :}' })->fill }
  #  });
  #  # /
  #  $vars->{'var_container'} = $container->set({ source => '{: include lucky.nhtml :}' })->fill;
  #  #

  $lucky->set({
    _always => { var_lucky => $lucky->fill }
  });

  $vars->{'var_perl'}   = $perl_pl->fill;
  $vars->{'var_source'} = $source->fill;

  $container->set({
    source => '{: include ("{: $ var_include :}") :}',
  });
  $vars->{'var_container'} = $container->fill({ var_include => 'html.html' });
 
  my $nes_object = '{: include ("{: * cfg_obj_top_dir :}/Nes/sys/date.nhtml", "local", "%A %e %B %H:%M") :}';
  $date_sour->set({
    template => '',
    source   => $nes_object,
  });
  $vars->{'var_date1'} = $date_sour->fill;
  
  $date_file->set({
    source     => '',
    template   => $config->{'obj_top_dir'}.'/Nes/sys/date.nhtml',
    obj_params => [ 'GMT', '%e %B %Y %H:%M' ],
  });  
  $vars->{'var_date2'} = $date_file->fill;
  
  $add_out->set({
    template => '',
    source   => 'add 1<br>',
  });
  $add_out->fill;
  $add_out->set({
    template => '',
    source   => 'add 2<br>',
  });  
  $vars->{'var_add'} = $add_out->fill;  
  
  $view->set({
    _always => { var_cal => $sh_cal->fill },
  });
 
  $view->fill($vars,$view,$lucky,$container);
 
1;
