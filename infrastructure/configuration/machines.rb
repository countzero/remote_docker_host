require_relative '../library/environment_helper'

MACHINE_CONFIGURATIONS = [
    {
        :name => 'remote-docker-host',
        :ip_v4_address => '10.0.0.50',
        :forwarded_ports => [
            {
                :id => 'ssh',
                :guest => 2375,
                :host => 2375,
            },
        ],
        :is_primary => true,
        :starts_on_vagrant_up => true,
        :has_gui => false,
        :cpus => get_physical_processor_count,
        :memory => 1024,
        :para_virtualization_provider => get_paravirt_provider,
        :shell_inline_provisioning => <<-SHELL,

            echo "Installing common packages..."
            apt-get update && apt-get --yes install \
                apt-transport-https \
                ca-certificates \
                curl \
                gnupg \
                lsb-release \
                nano \
                htop

            echo "Adding Docker’s official GPG key..."
            curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

            echo "Setting up Docker’s official stable repository..."
            echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
                https://download.docker.com/linux/debian $(lsb_release -cs) stable" |
            tee /etc/apt/sources.list.d/docker.list > /dev/null

            echo "Installing the latest version of Docker..."
            apt-get update && apt-get --yes install \
                docker-ce \
                docker-ce-cli \
                containerd.io

            echo "Adding the 'vagrant' user to the 'docker' group..."
            usermod -aG docker vagrant

            echo "Configuring 'dockerd' to also bind to tcp://0.0.0.0:2375..."
            mkdir /etc/systemd/system/docker.service.d
            echo -e "[Service]\nExecStart=\nExecStart=/usr/bin/dockerd -H unix:///var/run/docker.sock -H tcp://0.0.0.0:2375" \
            >> /etc/systemd/system/docker.service.d/docker.conf

            echo "Reloading 'systemd' configuration..."
            systemctl daemon-reload

            echo "Restarting 'dockerd'..."
            systemctl restart docker

        SHELL
        :shell_inline_always => <<-SHELL,

            echo "Getting system-wide docker information..."
            sudo docker info

        SHELL
    },
]
