readme:
	sed -i "/<!--BEGIN-->/,/<!--END-->/d" ./.github/README.md
	echo -e "<!--BEGIN-->" >> ./.github/README.md
	echo -e "\`\`\`json" >> ./.github/README.md
	nix flake show --json | jq -r ".packages" >> ./.github/README.md
	echo -e "\`\`\`" >> ./.github/README.md
	echo -e "<!--END-->" >> ./.github/README.md

switch:
	sudo nixos-rebuild switch --flake ${FLAKE} || true
	home-manager switch --flake ${FLAKE} || true

update:
	git stash
	nix flake update
	rg -l fetchFromGitHub | sed '/Makefile/d' | xargs -n1 update-nix-fetchgit
	bash ~/.nix-inputs/nixpkgs/pkgs/misc/vscode-extensions/update_installed_exts.sh > modules/home-manager/vscode/extensions.nix
	git add .
	git commit -m "nix: automatic update"
	git stash pop

hooks:
	ln -sf ${PWD}/.github/hooks/* .git/hooks
	echo "use flake .#devShellPlus.x86_64-linux" > .envrc


clean:
	find -name *.qcow2 -exec rm {} \;
	find -name source -exec rm -rf {} \;
	find -name result -exec unlink {} \;

IMG_DIR?=/var/lib/libvirt/images

base-vm:
	nix build .#base-vm
	-virsh destroy nixos
	@if [ -f ${IMG_DIR}/nixos.qcow2 ]; then\
		rm -i ${IMG_DIR}/nixos.qcow2;\
	fi
	cp result/nixos.qcow2 ${IMG_DIR}/nixos.qcow2
	virsh start nixos

test-vm:
	nix build .#test-vm
	-virsh destroy viperML-dotfiles-test-vm
	@if [ -f ${IMG_DIR}/viperML-dotfiles-test-vm.qcow2 ]; then\
		rm -i ${IMG_DIR}/viperML-dotfiles-test-vm.qcow2;\
	fi
	cp result/nixos.qcow2 ${IMG_DIR}/viperML-dotfiles-test-vm.qcow2
	virsh start viperML-dotfiles-test-vm
