Bing.com wallpaper scrapper
===========================

## Information

This is a scrapper to download the latest picture of the day from Bing.com and saves it to a directory. This program is an adaptation from Alejandro Figueroa's [`bing-wallpaper`](https://github.com/thejandroman/bing-wallpaper) with the main difference that in this case the wallpaper configuration in the user machine is out of scope. This is only to scrap the wallpaper.

This fork also fix some problems detected with [`bing-wallpaper`](https://github.com/thejandroman/bing-wallpaper). 


## Install

...


## Use

- Just run `bingwallscrapper` from the command line. The scrapper will download today's Bing.com image.
- Use `--help` flag to know more options:

```sh
$ bingwallscrapper --help
bingwallscrapper  Copyright (C) 2021  Borja González Seoane
Based on Alejandro Figeroa's work with bing-wallpaper

Usage:
  bingwallscrapper [options]
  bingwallscrapper -h | --help
  bingwallscrapper --version

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
                                 [default: '$BINGWALLSCRAPPER_DIR' or current 
                                 directory if this is not defined]
  -r --resolution <resolution>   The resolution of the image to retrieve.
                                 Supported resolutions: 1920x1200, 1920x1080, 
                                 800x480, 400x240. Default and recommended is
                                 1920x1080 (usually doesn't contain watermarks).
  -h --help                      Show this screen.
  --version                      Show version.
```
