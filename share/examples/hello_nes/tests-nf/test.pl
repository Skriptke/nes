#!/usr/bin/perl


  use Nes::View;
  
  use strict;
  use warnings;   
  
  my $template = Nes::View->new({ 
    template    => './test.nhtml',
    nes_top_dir => '/home/kike/trabajos/workspace/cgi-bin/nes',
    nes_dir     => '/cgi-bin/nes',
  });

  $template->fill();
 
1;
