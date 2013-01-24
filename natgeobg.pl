#!/usr/bin/env perl

use 5.010;
use strict;
use utf8;
use warnings FATAL => 'all';
use Mojo::UserAgent;

my $base_path = '/tmp/';
my $url =
  'http://photography.nationalgeographic.com/photography/photo-of-the-day';

my $ua      = Mojo::UserAgent->new;
my $img_url = $ua->get($url)->res->dom->at('div.download_link a')->{href};

my $filename = $base_path . Mojo::Path->new($img_url)->parts->[-1];
$ua->get($img_url)->res->content->asset->move_to($filename);

system( 'gsettings set org.gnome.desktop.background'
      . " picture-uri file://$filename" );

exit 0;
