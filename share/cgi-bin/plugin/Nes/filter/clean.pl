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
#  clean.pl
#
# -----------------------------------------------------------------------------

  use strict;
  use Nes;
  use HTML::Packer;
  use CSS::Packer;
  use JavaScript::Packer;
  
  my $nes       = Nes::Singleton->new();
  my $container = $nes->{'container'};
  my $cfg       = $nes->{'CFG'};
  my $cfg_file  = $cfg->{'plugin_top_dir'}.'/Nes/filter/.clean.nes.cfg';
  
  $nes->{'register'}->add_obj('filter_clean', 'clean', '', $cfg_file );
  
  my $options = { 
    remove_comments => $cfg->{'clean_remove_comments'},
    remove_newlines => $cfg->{'clean_remove_newlines'},
    do_javascript   => $cfg->{'clean_do_javascript'},
    do_stylesheet   => $cfg->{'clean_do_stylesheet'}
  };
   
  HTML::Packer::minify( \$container->{'content_obj'}->{'out'}, $options);
  $nes->{'register'}->set_obj('filter_clean', 'clean', $options);
  


# don't forget to return a true value from the file
1;

