unit module Bitcoin::Helpers;

use v6;
use Slippy::Semilist;

class Config is export {

  has Str $!platform = 'unknown';
  has Str $!config-path = '';
  has %!config = ();

  submethod BUILD(:$config-path = '') {
    $!config-path = $config-path;
    self!read-platform();
    self!read-config();
  }
  method get-config() {
    return %!config;
  }
  method get-value-for(Str $key) {
    return %!config{$key};
  }
  method !read-platform() {
    if $*DISTRO.is-win {
      $!platform = "windows";
    } elsif $*DISTRO.name eq 'macosx' {
      $!platform = "macosx";
    } else {
      $!platform = "linux";
    }
  }
  method !read-config() {
    if ($!config-path eq '') {
        if ($!platform eq 'windows') {
            $!config-path = %*ENV<USERPROFILE> ~ '\\AppData\\Roaming\\Bitcoin\\bitcoin.conf';
        }
        elsif ($!platform eq 'macosx') {
            $!config-path = "~/Library/Application Support/Bitcoin/Bitcoin.conf";
        }
        else {
            $!config-path = "~/.bitcoin/bitcoin.conf";
        }
      }
      return unless $!config-path.IO.e;
      # code shamelessly stolen from:
      # https://gfldex.wordpress.com/2017/04/17/slipping-in-a-config-file/
      my %h;
      slurp($!config-path).lines\
          >>.chomp\
          .grep(!*.starts-with('#'))\
          .grep(*.chars)\
          >>.split(/\s* '=' \s*/)\
          .flat.map(-> $k, $v { %h{||$k.split('.').cache} = $v });
      %!config = %h;
  }
}
