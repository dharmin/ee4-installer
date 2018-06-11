#!/usr/bin/env bash

#************************************************#
#                 setup_bats.sh                  #
#           written by Mriyam Tamuli             #
#                 Jun 28, 2017                   #
#                                                #
#    Script to install bats testing framework.   #
#            Tested on Ubuntu 14.04.             #
#************************************************#

check_and_install_prerequisites()
{
	git_version=$(git --version)
	if [[ "$?" != 0  ]]; then
		apt install git -yqq > /dev/null 2>&1
	fi
}

global_install()
{
	echo -e "\e[0;34mNOTICE\e[0m  Installing bats globally."
	git clone https://github.com/sstephenson/bats.git
	pushd bats > /dev/null 2>&1
	./install.sh /usr/local
	popd bats > /dev/null 2>&1
	echo -e "\e[0;34mNOTICE\e[0m  Installation complete."
	exit 0
}

local_install()
{
	echo -e "\e[0;34mNOTICE\e[0m  Installing libraries."
	mkdir -p test/libs

	check_git_repo="$( git -C $PWD rev-parse > /dev/null 2>&1 )"
	if [[ "$?" -eq 0 ]]; then
		git submodule add https://github.com/sstephenson/bats test/libs/bats
		git submodule add https://github.com/ztombol/bats-support test/libs/bats-support
		git submodule add https://github.com/ztombol/bats-assert test/libs/bats-assert
	else
		git clone https://github.com/sstephenson/bats test/libs/bats
		git clone https://github.com/ztombol/bats-support test/libs/bats-support
		git clone https://github.com/ztombol/bats-assert test/libs/bats-assert
	fi

	echo -e "\e[0;34mNOTICE\e[0m  Installed bats locally."
	echo -e "\e[4;31mACTION\e[0m  Run \e[1;31m\e[47m./test/libs/bats/bin/bats test/*.bats\e[0m"
}

main()
{
	check_and_install_prerequisites
	if [[ "$1" == "global" ]]; then
		global_install
	else
		local_install
	fi
}

main "$@"
