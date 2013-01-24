#!/usr/bin/env perl

use 5.10.1;
use strict;
use utf8;
use warnings FATAL => 'all';
use Mojo::UserAgent;

my $url
  = 'http://photography.nationalgeographic.com/photography/photo-of-the-day';

my $ua = Mojo::UserAgent->new;
my ( $picture_url, $picture_file_name )
  = $ua->get($url)->res->dom('div.download_link a')
  =~ /href="(.+\/(.+?\.jpg))"/;

open( my $picture_fh, '>', '/tmp/' . $picture_file_name );
binmode $picture_fh;
print $picture_fh $ua->get($picture_url)->res->body;
close $picture_fh;

system( 'gsettings set org.gnome.desktop.background'
      . " picture-uri file:///tmp/$picture_file_name" );

exit 0;
