#!/bin/bash

function install_ee4 {
    # Install ee4
    wget https://raw.githubusercontent.com/easyengine/installer/master/ee -O ee
    chmod +x ee
    sudo mv ee /usr/local/bin/ee
}

# Check OS
if [ "$(uname -s | tr '[:upper:]' '[:lower:]')" = "linux" ]; then
    echo "EasyEngine v4 is currently in beta. Do you still want to install ? [y/n] : "
    read ee4

    if [ "$ee4" = "y" -o "$ee4" = 'Y' ]; then
        # Setup docker
        if ! which docker > /dev/null 2>&1; then
            echo "Installing docker"
            wget get.docker.com -O docker-setup.sh
            if ! sh docker-setup.sh > /dev/null 2>&1; then
                if sudo usermod -aG docker $USER > /dev/null 2>&1; then
                    rm docker-setup.sh
                else
                    echo "Please logout and login again to complete the docker setup"
                fi
            else
                echo "Docker installation failed"
            fi
        fi
        if ! sudo ee -v | grep "v3" > /dev/null; then
            
            # Create temp ee4 bin
            mkdir ~/.ee4
            wget https://raw.githubusercontent.com/easyengine/installer/master/ee -O ~/.ee4/ee4
            chmod +x ~/.ee4/ee4

            echo "EasyEngine v3 found on the system!  We have to disable EasyEngine v3 and all of its stacks permanently to setup EasyEngine v4.  Do you want to continue ? [y/n] : "
            read ee3
            if [ "$ee3" = "y" -o "$ee3" = 'Y' ]; then
                
                echo "Do you want to migrate the sites ? ( Some sites may not work as you expected. ) [y/n] : "
                sites_path=~/ee4-sites
                if [ -f ~/.ee4/config.yml ]; then
                    sed -e 's/:[^:\/\/]/=/g;s/$//g;s/ ^C/=/g' ~/.ee4/config.yml | tail -n +2  > ee4-config
                    source ee4-config
                    rm ee4-config
                fi

                # Get ee3 sites from db
                sites=$(sudo sqlite3 /var/lib/ee/ee.db "select sitename,cache_type from sites")

                sudo ee stack start --mysql > /dev/null
                sudo ee stack stop --nginx > /dev/null

                for site in $sites;do

                    # Export site from ee3
                    site_name=$(echo $site | cut -d'|' -f1)
                    cache_type=$(echo $site | cut -d'|' -f2)
                    echo -e "\nMigrating site: $site_name\n"
                    echo "Exporting db..."
                    sudo wp db export "$site_name.db" --path="/var/www/$site_name/htdocs" --allow-root

                    # Create Site
                    echo "Creating $site_name in EasyEngine v4. This may take some time please wait..."
                    if [ "$cache_type" = "wpredis" ]; then 
                        ~/.ee4/ee4 site create "$site_name" --wpredis
                    else
                        ~/.ee4/ee4 site create "$site_name"
                    fi
                    echo "$site_name created in ee4"
                    
                    # Import site to ee4
                    echo "Copying files to the new site."
                    sudo cp -R . $sites_path/$site_name/app/src
                    echo "Importing db..."
                    ee4 wp "$site_name" db import "$site_name.db"

                    # Remove database files
                    sudo rm "$sites_path/$site_name/app/src/$site_name.db"
                    sudo rm "/var/www/$site_name/htdocs/$site_name.db"


                done

                sudo ee stack stop --all > /dev/null
            fi
        fi
        install_ee4
    fi
else
    # MacOS
    echo "Docker is required to use EasyEngine v4."
    exit
fi