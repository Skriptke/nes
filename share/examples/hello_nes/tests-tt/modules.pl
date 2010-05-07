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
#  modules.pl
#
# -----------------------------------------------------------------------------

  use Nes;
  my $nes = Nes::Singleton->new('./modules.nhtml');
  my %nes_tags;
  
  my @modules = (
                  'Nes',
                  'Template',
                  'Template::Nes::Inject',
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
                
  my $count = 0;
  $nes_tags{'modules'} = [ {} ];
  $nes_tags{'recommend'} = '';
  foreach my $module ( @modules ) {
    $nes_tags{'modules'}[$count]{'module'} = $module;
    eval "require $module;";    
    my $ver = $module->VERSION || 'unknown';
    if ( $@ ) {
      $nes_tags{'modules'}[$count]{'installed'} = '*** Not installed ***';
      $nes_tags{'recommend'} ||= 'Recommend installing: ';
      $nes_tags{'recommend'}  .= $module.', ';
    } else {
      $nes_tags{'modules'}[$count]{'installed'} = 'v. '.$ver;
    }
    $count++;
  }
    
  $nes->out(%nes_tags);

1;
