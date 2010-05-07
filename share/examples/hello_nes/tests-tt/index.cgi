#!/usr/bin/perl

  use strict;
  use warnings;
  use Template::Nes::Inject;

  my $top_template = Template::Nes::Inject->new({ 
                       template    => './index.nhtml',
                       nes_top_dir => '/full/path/to/cgi-bin/nes' 
                     });


  my $vars = {
     title => "Template::Nes::Inject Nes templates in Template Toolkit."
  };
  
  $top_template->process($vars);
  $top_template->out();  

 