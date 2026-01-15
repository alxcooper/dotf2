.PHONY: install

# Optional tags parameter (use: make install tags=zsh,vim)
tags ?=

install:
	@ANSIBLE_LOCALHOST_WARNING=false ansible-playbook provision/install.yml \
		-i "localhost," \
		--vault-password-file .vault_pass \
		$(if $(tags),--tags $(tags),)
