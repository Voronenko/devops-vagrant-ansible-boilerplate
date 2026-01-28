vg-status:
	@echo "Listing the status of all Vagrant machines:"
	@vagrant global-status

vg-get-box:
	vagrant box add canonical/jammy64 https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64-vagrant.box

# List the IP addresses of all Vagrant machines
vg-ip:
	@echo "Listing IP addresses of all Vagrant machines:"
	@for id in $$(vagrant global-status --machine-readable | awk -F, '/^machine/{print $$1}'); do \
		cd $$(dirname $$(vagrant global-status --machine-readable | grep $$id | cut -d',' -f2)); \
		echo "Machine: $$id"; \
		vagrant ssh-config | grep HostName; \
	done

# List the forwarded ports of all Vagrant machines
vg-ports:
	@echo "Listing forwarded ports of all Vagrant machines:"
	@for id in $$(vagrant global-status --machine-readable | awk -F, '/^machine/{print $$1}'); do \
		cd $$(dirname $$(vagrant global-status --machine-readable | grep $$id | cut -d',' -f2)); \
		echo "Machine: $$id"; \
		vagrant port; \
	done

update-certs:
	curl -sLo ./deployment/k0s/traefik/certs/fiksim_privkey.pem https://github.com/Voronenko/fiks.im/releases/download/$(shell curl -s https://api.github.com/repos/Voronenko/fiks.im/releases/latest | grep tag_name | cut -d '"' -f 4)/fiksim_privkey.pem
	curl -sLo ./deployment/k0s/traefik/certs/fiksim_cert.pem https://github.com/Voronenko/fiks.im/releases/download/$(shell curl -s https://api.github.com/repos/Voronenko/fiks.im/releases/latest | grep tag_name | cut -d '"' -f 4)/fiksim_cert.pem
	curl -sLo ./deployment/k0s/traefik/certs/fiksim_fullchain.pem https://github.com/Voronenko/fiks.im/releases/download/$(shell curl -s https://api.github.com/repos/Voronenko/fiks.im/releases/latest | grep tag_name | cut -d '"' -f 4)/fiksim_fullchain.pem
	kubectl delete secret fiksim-tls-secret --namespace=traefik --ignore-not-found
	kubectl create secret tls fiksim-tls-secret --cert=./deployment/k0s/traefik/certs/fiksim_fullchain.pem --key=./deployment/k0s/traefik/certs/fiksim_privkey.pem --namespace=traefik

build:
	vagrant up
	vagrant reload
