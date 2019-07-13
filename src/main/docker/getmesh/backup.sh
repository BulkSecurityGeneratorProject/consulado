#!/usr/bin/env sh

WAIT_FOR_SYNC="60s"
BASE_URL="localhost:8080"
MESH_ADMIN_USER="admin"
MESH_ADMIN_PASSWORD="admin"
CONTAINER_ID=$(docker ps | grep 'miconsulado/getmesh:latest' | awk '{ print $1 }')
echo "CONTAINER:"${CONTAINER_ID}

curl -c ./cookies.txt ${MESH_ADMIN_USER}":"${MESH_ADMIN_PASSWORD}"@"${BASE_URL}"/api/v2/auth/login"

curl -X POST -b ./cookies.txt ${BASE_URL}"/api/v2/admin/consistency/repair"
curl -X POST -b ./cookies.txt ${BASE_URL}"/api/v2/search/clear"
curl -X POST -b ./cookies.txt ${BASE_URL}"/api/v2/search/sync"
echo "Waiting for index sync: "${WAIT_FOR_SYNC}
docker exec --user root ${CONTAINER_ID} find /backups -name "*.zip" -delete
sleep ${WAIT_FOR_SYNC}
curl -X POST -b ./cookies.txt ${BASE_URL}"/api/v2/admin/graphdb/backup"

rm -rf ./backup/*
docker cp ${CONTAINER_ID}":/backups" "./backup/"
docker cp ${CONTAINER_ID}":/uploads" "./backup/"
rm ./cookies.txt

