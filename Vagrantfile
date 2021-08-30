#
# The development environment for the company database.
#
# This script configures Vagrant to create multiple VirtualBox machines.
#

require_relative './infrastructure/configuration/machines'
require_relative './infrastructure/library/environment_helper'

output_vagrant_runtime_environment_details

Vagrant.configure('2') do |configuration|

    MACHINE_CONFIGURATIONS.each do |machine_configuration|

        configuration.vm.define(
            machine_configuration[:name],
            autostart: machine_configuration[:starts_on_vagrant_up],
            primary: machine_configuration[:is_primary]
        ) do |machine|

            # We are using the official Debian 11 image from the Vagrant Cloud.
            # See https://app.vagrantup.com/debian/boxes/bullseye64
            machine.vm.box = 'debian/bullseye64'

            # The hostname of the virtual machine.
            machine.vm.hostname = "#{machine_configuration[:name]}.local"

            # Create a private network with a static IP.
            machine.vm.network 'private_network', ip: machine_configuration[:ip_v4_address]

            # Configure optional port forwarding.
            if (machine_configuration.key?(:forwarded_ports))

                machine_configuration[:forwarded_ports].each do |forwarded_port|

                    machine.vm.network 'forwarded_port',
                        id: forwarded_port[:id],
                        guest: forwarded_port[:guest],
                        host: forwarded_port[:host],
                        auto_correct: true
                end
            end

            # Disable the default shared folder.
            configuration.vm.synced_folder '.', '/vagrant', :disabled => true

            # Execute optional shell inline provisioning code.
            if (machine_configuration.key?(:shell_inline_provisioning))
                machine.vm.provision 'shell',
                    privileged: true,
                    keep_color: true,
                    inline: machine_configuration[:shell_inline_provisioning]
            end

            # Execute optional shell inline code that runs on every vagrant up.
            if (machine_configuration.key?(:shell_inline_always))

                machine.vm.provision 'shell',
                    privileged: false,
                    keep_color: true,
                    run: 'always',
                    inline: machine_configuration[:shell_inline_always]
            end

            # VirtualBox configuration.
            machine.vm.provider 'virtualbox' do |virtualbox|

                # Set the machine name within VirtualBox.
                virtualbox.name = machine_configuration[:name]

                # Set if the machine runs with a GUI.
                virtualbox.gui = machine_configuration[:has_gui]

                # See http://www.virtualbox.org/manual/ch08.html#vboxmanage-modifyvm for further options.
                virtualbox.customize [
                    'modifyvm', :id,
                    '--cpus', machine_configuration[:cpus],
                    '--memory', machine_configuration[:memory],
                    '--paravirtprovider', machine_configuration[:para_virtualization_provider],

                    # This setting is enforced, because capping the CPU will cripple the VirtualBox performance.
                    '--cpuexecutioncap', 100,

                    # Enable NAT hosts DNS resolver to avoid "The remote name could not be resolved" errors.
                    '--natdnsproxy1', 'on',
                    '--natdnshostresolver1', 'on',
                ]
            end
        end
    end
end
