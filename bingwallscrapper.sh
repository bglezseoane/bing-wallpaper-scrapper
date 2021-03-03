#!/usr/bin/env bash

readonly PROGRAM_NAME=$(basename "$0" | cut -f1 -d'.')
readonly VERSION='0.4.0'
readonly RESOLUTIONS=(1920x1200 1920x1080 800x480 400x240)

usage() {
cat <<EOF
bingwallscrapper  Copyright (C) 2021  Borja González Seoane
Based on Alejandro Figeroa's work with bing-wallpaper

Usage:
  $PROGRAM_NAME [options]
  $PROGRAM_NAME -h | --help
  $PROGRAM_NAME --version

Options:
  -f --force                     Force download of picture. This will overwrite
                                 the picture if the filename already exists.
  -s --ssl                       Communicate with Bing.com over SSL.
  -b --boost <n>                 Use boost mode. Try to fetch latest <n> pictures.
  -q --quiet                     Do not display log messages.
  -n --filename <file name>      The name of the downloaded picture. Defaults to
                                 the upstream name.
  -p --picturedir <picture dir>  The full path to the picture download dir.
                                 Will be created if it does not exist.
                                 [default: \'\$BINGWALLSCRAPPER_DIR\' or current 
                                 directory if this is not defined]
  -r --resolution <resolution>   The resolution of the image to retrieve.
                                 Supported resolutions: 1920x1200, 1920x1080, 
                                 800x480, 400x240
  -h --help                      Show this help information.
  --version                      Show version.
EOF
}

print_message() {
    if [ -z "$QUIET" ]; then
        printf "%s\n" "${1}"
    fi
}

transform_urls() {
    sed -e "s/\\\//g" | \
        sed -e "s/[[:digit:]]\{1,\}x[[:digit:]]\{1,\}/$RESOLUTION/" | \
        tr "\n" " "
}

# Default resolution
RESOLUTION="1920x1080"

# Calculate picture directory attending to 'BINGWALLSCRAPPER_DIR' variable definition
if [[ -z "${BINGWALLSCRAPPER_DIR}" ]]
then
    picture_dir="$PWD"/"$PROGRAM_NAME"_img
else
    picture_dir=${BINGWALLSCRAPPER_DIR}
fi

# Option parsing
while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        -r|--resolution)
            RESOLUTION="$2"
            shift
            ;;
        -p|--picturedir)
            PICTURE_DIR="$2"
            shift
            ;;
        -n|--filename)
            FILENAME="$2"
            shift
            ;;
        -f|--force)
            FORCE=true
            ;;
        -s|--ssl)
            SSL=true
            ;;
        -b|--boost)
            BOOST=$(($2-1))
            shift
            ;;
        -q|--quiet)
            QUIET=true
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        --version)
            printf "%s\n" $VERSION
            exit 0
            ;;
        *)
            (>&2 printf "Unknown parameter: %s\n" "$1")
            usage
            exit 1
            ;;
    esac
    shift
done

# Set options
[ -n "$QUIET" ] && CURL_QUIET='-s'
[ -n "$SSL" ]   && PROTO='https'   || PROTO='http'

# Create picture directory if it doesn't already exist
mkdir -p "${PICTURE_DIR}"

# Parse Bing.com and acquire picture URL(s)
read -ra urls < <(curl -sL $PROTO://www.bing.com | \
    grep -Eo "url\(.*?\)" | \
    sed -e "s/url(\([^']*\)).*/http:\/\/bing.com\1/" | \
    transform_urls)

if [ -n "$BOOST" ]; then
    read -ra archiveUrls < <(curl -sL "$PROTO://www.bing.com/HPImageArchive.aspx?format=js&n=$BOOST" | \
        grep -Eo "url\(.*?\)" | \
        sed -e "s/url(\([^']*\)).*/http:\/\/bing.com\1/" | \
        transform_urls)
    urls=( "${urls[@]}" "${archiveUrls[@]}" )
fi

for p in "${urls[@]}"; do
    if [ -z "$FILENAME" ]; then
        filename=$(echo "$p" | sed -e 's/.*[?&;]id=\([^&]*\).*/\1/' | grep -oe '[^\.]*\.[^\.]*$')
    else
        filename="$FILENAME"
    fi
    if [ -n "$FORCE" ] || [ ! -f "$PICTURE_DIR/$filename" ]; then
        print_message "Downloading: $filename..."
        curl $CURL_QUIET -Lo "$PICTURE_DIR/$filename" "$p"
    else
        print_message "Skipping: $filename..."
    fi
done
