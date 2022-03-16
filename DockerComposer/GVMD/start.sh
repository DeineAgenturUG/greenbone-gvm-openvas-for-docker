#!/bin/bash
set -e

gvmd () {
  /gvm/sbin/gvmd --database=$POSTGRES_DB --db-host=database --db-port=5432 --db-user=$POSTGRES_USER "$@"
}

if [ ! -f "/gvm/var/lib/gvm/CA/cacert.pem" ]; then
    /gvm/bin/gvm-manage-certs -a
fi

gvmd --migrate

gvmd

echo "Waiting for Greenbone Vulnerability Manager to finish startup..."
until gvmd --get-users; do
	sleep 1
done

if [ ! -f "/gvm/var/lib/gvm/created_gvm_user" ]; then
	echo "Creating Greenbone Vulnerability Manager admin user"
	gvmd --role="Super Admin" --create-user="$GVM_USERNAME" --password="$GVM_PASSWORD"
	
	USERSLIST=$(gvmd --get-users --verbose)
	IFS=' '
	read -ra ADDR <<<"$USERSLIST"
	
	echo "${ADDR[1]}"
	
	gvmd --modify-setting 78eceaec-3385-11ea-b237-28d24461215b --value ${ADDR[1]}
	
	touch /gvm/var/lib/gvm/created_gvm_user
fi

echo "--- GVMD Started ---"

tail -f /gvm/var/log/gvm/gvmd.log
