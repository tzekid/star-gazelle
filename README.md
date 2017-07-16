# star-gazelle

Have the latest [himawari8](https://himawari8.nict.go.jp/) shots as your wallpaper! (Wallpapers update every 10 min)

## Installation

You need to have [crystal](https://crystal-lang.org/docs/installation/), and ```feh``` installed.


You can either compile the project, or just run it with:  
```
curl -fsSLo- https://raw.githubusercontent.com/tzekid/star-gazelle/master/src/star-gazelle.cr | crystal
```

## Usage
```
         __                                                    .__  .__
  ______/  |______ _______            _________  ________ ____ |  | |  |   ____
 /  ___\   __\__  \\_  __ \  ______  / ___\__  \ \___   _/ __ \|  | |  | _/ __ \
 \___ \ |  |  / __ \|  | \/ /_____/ / /_/  / __ \_/    /\  ___/|  |_|  |_\  ___/
/____  >|__| (____  |__|            \___  (____  /_____ \\___  |____|____/\___  >
     \/           \/               /_____/     \/      \/    \/               \/

Usage: star-gazelle [option]

    -d PATH, --dir PATH              Change the default '~/.star-gazelle' directory
    -s PATH, --no-wall-set PATH      Only download the wallpapers
    -h, --help                       Show this help
```

## Development

```
# TODO(s):
# [ ] find a solution for windows
# [ ] Prompt / Option to autostart
```

## Contributing

1. Fork it ( https://github.com/tzekid/star-gazelle/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [tzekid](https://github.com/tzekid) Mircea Ilie Ploscaru - creator, maintainer
- [SleiderCoding](https://github.com/SleiderCoding) Sleider - the guy I stole idea from
