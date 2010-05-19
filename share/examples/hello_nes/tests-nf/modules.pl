#!/usr/bin/perl

  use Nes::Framework;
  
  use strict;
  use warnings;   
  
  my $view = Nes::Framework::View->new( 'modules' );
  my $vars = {};

  my @modules = (
                  'Nes',
                  'Nes::Framework',
                  'Crypt::CBC',
                  'Crypt::Blowfish',
                  'IO::String',
                  'IO::File',
                  'IO::Scalar',
                  'Env::C',
                  'IPC::Run',
                  'DBI',
                  'DBD::mysql',
                  'DBD::Pg',
                  'DBD::CSV',
                  'SQL::Abstract',
                  'File::ShareDir',
                  'File::Copy::Recursive',
                  'HTML::Normalize',
                  'HTML::Packer',
                  'CSS::Packer',
                  'JavaScript::Packer',
                  'Benchmark',
                  'Time::HiRes',
                  'Data::Dumper'
                );
  
  $vars->{'modules'}   = [ {} ];
  $vars->{'recommend'} = '';
  my $count = 0;
  foreach my $module ( @modules ) {
    $vars->{'modules'}[$count]{'module'} = $module;
    eval "require $module;";    
    my $ver = $module->VERSION || 'unknown';
    if ( $@ ) {
      $vars->{'modules'}[$count]{'installed'} = '*** Not installed ***';
      $vars->{'recommend'} ||= 'Recommend installing: ';
      $vars->{'recommend'}  .= $module.', ';
    } else {
      $vars->{'modules'}[$count]{'installed'} = 'v. '.$ver;
    }
    $count++;
  }
    
  $view->fill($vars);

1;
