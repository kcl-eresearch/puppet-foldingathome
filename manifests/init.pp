# @summary Installs the folding@home client
#
#
# @example
#   include foldingathome
class foldingathome {
  package {'fahclient':
    ensure   => installed,
    provider => 'dpkg',
    source   => 'https://download.foldingathome.org/releases/public/release/fahclient/debian-stable-64bit/v7.5/fahclient_7.5.1_amd64.deb'
  }
}
