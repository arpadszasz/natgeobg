#!/usr/bin/env perl

use 5.010;
use strict;
use utf8;
use warnings FATAL => 'all';
use POSIX qw( uname );
use Mojo::UserAgent;

use constant DARWIN => 'darwin';

my $base_path = '/tmp/';
my $url
  = 'http://photography.nationalgeographic.com/photography/photo-of-the-day';

my $ua      = Mojo::UserAgent->new;
my $img_url = $ua->get($url)->res->dom->at('div.download_link a')->{href};

my $filename = $base_path . Mojo::Path->new($img_url)->parts->[-1];
$ua->get($img_url)->res->content->asset->move_to($filename);

set_wallpaper($filename);

exit 0;

sub set_wallpaper {
    my ($filename) = @_;

    my ($sysname) = uname();
    my $desk_env = lc $sysname eq DARWIN
                 ? DARWIN
                 : exists $ENV{XDG_CURRENT_DESKTOP} && lc $ENV{XDG_CURRENT_DESKTOP};

    given ($desk_env) {
        when (/gnome|unity/) {
            system(
                'gsettings',                    'set',
                'org.gnome.desktop.background', 'picture-uri',
                "file://$filename"
            );
        }
        when ("xfce") {
            system( 'xfconf-query', '-c', 'xfce4-desktop', '-p',
                '/backdrop/screen0/monitor0/image-path', '-s', $filename );
        }
        when (DARWIN) {
            system( 'defaults', 'write', 'com.apple.desktop', 'Background',
                qq({default = {ImageFilePath = "$filename"; };}) );
            system( 'killall', 'Dock' );
        }
        default {
            say
              "Your Desktop Environment ($desk_env) is not supported yet :-(";
            say "Regardless, your picture is saved at: $filename";
        }
    }
    return;
}
