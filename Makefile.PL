use strict;
use warnings;
use inc::Module::Install;
  
name           'Nes';
perl_version   '5.008';
all_from       'lib/Nes.pm';
  
requires       'Crypt::CBC'      => '2.30';
requires       'Crypt::Blowfish' => '2.10';
requires       'IO::String'      => '1.08';
requires       'IO::File'        => '1.14';
recommends     'File::ShareDir'  => '1.01';
recommends     'Env::C'          => '0.08';
recommends     'IPC::Run'        => '0.84';
recommends     'DBI'             => '1.601';
recommends     'DBD::mysql'      => '4.006';
recommends     'DBD::Pg'         => '2.5.0';

install_script 'set_nes_site';
install_share  'share';
  
WriteAll;
