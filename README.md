# foldingathome
Puppet module to install folding@home client on Linux systems.

[![Build Status](https://travis-ci.org/njhowell/puppet-foldingathome.svg?branch=master)](https://travis-ci.org/njhowell/puppet-foldingathome)


# Module Description
This is a simple module to install the [Folding@Home](https://foldingathome.org/) client on Linux systems.

# Setup
`include foldingathome` is enough to get started. However, you may wish to pass in a username and/or team ID:
```
class {'foldingathome':
  user_name => 'example_user',
  team_id   => '1234'
}
```

# Usage
## Configuring identity
Specify username, team ID and a passkey to configure your folding@home identity.

```
class {'foldingathome':
  user_name    => 'example_user',
  team_id      => '1234',
  user_passkey => 'secretpasskey',
}
```

## FAHClient version
Specify the package URL to install a specific version
```
class {'foldingathome':
  url => 'http://download.foldingathome.org/releases/public/release/fahclient/debian-stable-64bit/v7.5/fahclient_7.5.1_amd64.deb'
}
```

## Configure CPU Slots
Specify a Hash of CPU Slots and CPU Core counts. For example, to have two CPU slots one with 2 core, and one with 4 cores:

```
class {'foldingathome':
  cpu_slots => {
    '0' => '2',
    '1' => '4'
  }
}
```

## Configure Web management
Configure the remote web control for the FAHClient:
```
class {'foldingathome':
  allow        => '0/0',
  web_allow    => '0/0',
  web_password => 'foobar'
}
```

This allows remote web control from all IPs, with password `foobar`.

## Misc
### GPU
Set `gpu_enable = true` to enable GPU. However, no other configuration is currently present in this module and the functionality is not yet tested.

### Service state
Use `service_ensure` to control the state of the `FAHClient` service. Implemented here mostly for testing so we don't run the service and take work units when we don't intend to complete them.

# Limitations

Currently this is only implemented for Linux, and even then only for those that use the deb package format. 

The module is tested against:
- Ubuntu 18.04
- Ubuntu 20.04
- Debian 9
  
Not all possible config options in `config.xml` are managed, only the ones I immediately found useful. 
# Development

## Contributions
Contributions via Issues and PRs are welcome.

## Running Tests

This module uses PDK and Puppet Litmus.

There are two provisioning sets for litmus - `vagrant` and `travis_docker`. The Vagrant list is intended to aid local development when working on Windows sytems. The travis_docker list is for Travis CI to use when performing automated testing, although there's no reason this cannot be used when development on a Linux system with a suitable local docker configuration.

Run the parser validators and unit tests:

- `pdk validate` to validate syntax
- `pdk test unit` to run unit tests

Litmus acceptance tests are a little more involved:

- `pdk bundle install`
- `pdk bundle exec rake litmus:provision_list[vagrant]`
- `pdk bundle exec rake litmus:install_agent`
- `pdk bundle exec bolt task run provision::fix_secure_path --modulepath spec/fixtures/modules -i inventory.yaml -t ssh_nodes`. This adds the puppet executable to the path of the root user, but is only nescessary when using the vagrant provisioner
- `pdk bundle exec rake litmus:install_module` to install the module (and it's dependencies) for testing
- `pdk bundle exec rake litmus:acceptance:parallel` to run the acceptance tests
- `pdk bundle exec rake litmus:tear_down` to destroy the VMs
