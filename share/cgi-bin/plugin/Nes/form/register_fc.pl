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
#  Version 1.03
#
#  register_captcha.pl
#
# -----------------------------------------------------------------------------

use strict;
use fc_plugin;

Nes::Singleton->instance->{'register'}->tag( 'fc_plugin', 'fc',                'fc_plugin::fc' );
Nes::Singleton->instance->{'register'}->tag( 'fc_plugin', 'fc_obfuscated',     'fc_plugin::obfuscated' );
Nes::Singleton->instance->{'register'}->tag( 'fc_plugin', 'fc_check',          'fc_plugin::check' );
Nes::Singleton->instance->{'register'}->tag( 'fc_plugin', 'fc_field_attempts', 'fc_plugin::field_attempts' );
Nes::Singleton->instance->{'register'}->tag( 'fc_plugin', 'fc_captcha',        'fc_plugin::captcha' );
Nes::Singleton->instance->{'register'}->tag( 'fc_plugin', 'fc_captcha_html',   'fc_plugin::captcha_html' );
Nes::Singleton->instance->{'register'}->tag( 'fc_plugin', 'fc_captcha_code',   'fc_plugin::captcha_code' );
Nes::Singleton->instance->{'register'}->tag( 'fc_plugin', 'fc_handler',        'fc_plugin::script_handler' );

# don't use this tags in you template
Nes::Singleton->instance->{'register'}->tag( 'fc_plugin', '_fc_begin',         'fc_plugin::_begin' );
Nes::Singleton->instance->{'register'}->tag( 'fc_plugin', '_fc_end',           'fc_plugin::_end' );

# don't forget to return a true value from the file
1;

