vg-status:
	@echo "Listing the status of all Vagrant machines:"
	@vagrant global-status --prune

vg-get-box:
	vagrant box add canonical/jammy64 https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64-vagrant.box

# List the IP addresses of all Vagrant machines
vg-ip:
	@echo "Listing Vagrant machine IPs (multi-machine ready):"
	@TMP_CACHE=$$(mktemp); \
	trap "rm -f $$TMP_CACHE" EXIT; \
	vagrant global-status --prune --machine-readable 2>/dev/null | \
	awk -F, '\
	$$3=="machine-id"   {id=$$4} \
	$$3=="machine-home" {dir[id]=$$4} \
	$$3=="state" && $$4=="running" {running[id]=1} \
	END {for (i in running) print i "," dir[i]} \
	' | \
	while IFS=, read id dir; do \
		[ -z "$$dir" ] && continue; \
		cd "$$dir" || continue; \
		# Try to get name from global-status table \
		name=$$(vagrant global-status --prune | awk -v ID="$$id" '$$1==ID {print $$2}'); \
		# Fallback to tmp cache \
		if [ -z "$$name" ]; then \
			name=$$(grep "^$$id=" $$TMP_CACHE | cut -d= -f2); \
		else \
			# Update tmp cache \
			sed -i "/^$$id=/d" $$TMP_CACHE; \
			echo "$$id=$$name" >> $$TMP_CACHE; \
		fi; \
		[ -z "$$name" ] && name="(no name)"; \
		ip=$$(VAGRANT_LOG=error vagrant ssh -c 'hostname -I' 2>/dev/null | \
			grep -oE '192\.168\.56\.[0-9]+' | tr "\n" " "); \
		[ -z "$$ip" ] && ip="(no host-only IP)"; \
		echo "$$name ($$id): $$ip"; \
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
	curl -sLo ./deployment/certs/fiksim_privkey.pem https://github.com/Voronenko/fiks.im/releases/download/$(shell curl -s https://api.github.com/repos/Voronenko/fiks.im/releases/latest | grep tag_name | cut -d '"' -f 4)/fiksim_privkey.pem
	curl -sLo ./deployment/certs/fiksim_cert.pem https://github.com/Voronenko/fiks.im/releases/download/$(shell curl -s https://api.github.com/repos/Voronenko/fiks.im/releases/latest | grep tag_name | cut -d '"' -f 4)/fiksim_cert.pem
	curl -sLo ./deployment/certs/fiksim_fullchain.pem https://github.com/Voronenko/fiks.im/releases/download/$(shell curl -s https://api.github.com/repos/Voronenko/fiks.im/releases/latest | grep tag_name | cut -d '"' -f 4)/fiksim_fullchain.pem

build:
	vagrant up
	vagrant reload
