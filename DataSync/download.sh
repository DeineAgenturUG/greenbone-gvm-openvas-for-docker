#!/bin/bash

FEED_HOME="https://community.greenbone.net/t/about-greenbone-community-feed-gcf/1224"
FEED_VENDOR="Greenbone Networks GmbH"

write_feed_xml () {

  if [ ! -f "${FEED_DIR}/timestamp" ]; then
    echo "timestamp file not found!"
    exit 1
  fi

  FEED_VERSION=$(cat "${FEED_DIR}/timestamp")

  mkdir -p "${FEED_DIR}"
  {
  echo '<feed id="6315d194-4b6a-11e7-a570-28d24461215b">'
  echo "<type>${FEED_TYPE}</type>"
  echo "<name>${FEED_NAME}</name>"
  echo "<version>${FEED_VERSION}</version>"
  echo "<vendor>${FEED_VENDOR}</vendor>"
  echo "<home>${FEED_HOME}</home>"
  echo "<description>"
  echo "This script synchronizes a ${FEED_TYPE} collection with the '${FEED_NAME}'."
  echo "The '${FEED_NAME}' is provided by '${FEED_VENDOR}'."
  echo "Online information about this feed: '${FEED_HOME}'."
  echo "</description>"
  echo "</feed>"
  } > "${FEED_DIR}/feed.xml"
}

mkdir -p data

echo "RSYNC: NVT-Feed..."

while ! rsync --compress-level=9 --links --times --omit-dir-times --recursive --partial --quiet rsync://feed.community.greenbone.net:/nvt-feed ./data/nvt-feed
do
  echo "Retrying..."
  sleep 10
done

sleep 10

FEED_DIR="./data/gvmd-data"
FEED_TYPE="GVMD_DATA"
FEED_NAME="Greenbone Community gvmd Data Feed"

echo "RSYNC: Data-Objects GVMD..."

while ! rsync --compress-level=9 --links --times --omit-dir-times --recursive --partial --quiet rsync://feed.community.greenbone.net:/data-objects/gvmd/ "${FEED_DIR}"
do
  echo "Retrying..."
  sleep 10
done

write_feed_xml

sleep 10

FEED_DIR="./data/cert-data"
FEED_TYPE="CERT"
FEED_NAME="Greenbone Community CERT Feed"

echo "RSYNC: Cert-Data..."

while ! rsync --compress-level=9 --links --times --omit-dir-times --recursive --partial --quiet rsync://feed.community.greenbone.net:/cert-data "${FEED_DIR}"
do
  echo "Retrying..."
  sleep 10
done

write_feed_xml

sleep 10

FEED_DIR="./data/scap-data"
FEED_TYPE="SCAP"
FEED_NAME="Greenbone Community SCAP Feed"

echo "RSYNC: Scap-Data..."

while ! rsync --compress-level=9 --links --times --omit-dir-times --recursive --partial --quiet rsync://feed.community.greenbone.net:/scap-data "${FEED_DIR}"
do
  echo "Retrying..."
  sleep 10
done

write_feed_xml
