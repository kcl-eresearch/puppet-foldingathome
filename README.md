# puppet-foldingathome
Puppet module to install folding@home

[![Build Status](https://travis-ci.org/njhowell/puppet-foldingathome.svg?branch=master)](https://travis-ci.org/njhowell/puppet-foldingathome)


# Development

## Running Tests

This module uses PDK and Puppet Litmus with a vagrant provider. 

- `pdk validate` to validate syntax
- `pdk test unit` to run unit tests

Litmus acceptance tests are a little more involved

- `pdk bundle install`
- `pdk bundle exec rake litmus:provision_list[vagrant]`
- `pdk bundle exec rake litmus:install_agent`
- `pdk bundle exec bolt task run provision::fix_secure_path --modulepath spec/fixtures/modules -i inventory.yaml -t ssh_nodes`. This adds the puppet executable to the path of the root user
- `pdk bundle exec rake litmus:install_module` to install the module (and it's dependencies) for testing
- `pdk bundle exec rake litmus:acceptance:parallel` to run the acceptance tests
- `pdk bundle exec rake litmus:tear_down` to destroy the VMs
