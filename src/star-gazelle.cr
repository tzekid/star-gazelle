#!/usr/bin/crystal
require "http/client"
require "json"
require "option_parser"

# TODO(s):
# [ ] find a solution for windows
# [ ] Prompt / Option to autostart

macro on_error( reason, message )
  (puts {{message}}; exit) if {{reason}}
end

# Defaults
IMAGE_DIR = "/home/#{System.hostname}/.star-gazelle"
CONFIG_FILE = "#{IMAGE_DIR}/config.json"
LINK = "http://himawari8-dl.nict.go.jp/himawari8/img/D531106/latest.json"


class Gazelle
  property image_dir = IMAGE_DIR
  property link = "http://himawari8-dl.nict.go.jp/himawari8/img/D531106/latest.json"
  property response : JSON::Any?
  property image_path : String?
  property download_only

  def initialize(@download_only = false)
    File.write CONFIG_FILE, self.to_json
  end

  private def download_latest
    if response = JSON.parse( HTTP::Client.get(link).body )
      date_time = Time.parse(response["date"].to_s, "%Y-%m-%d %T").to_s("%Y%m%d%H%M%S")
      image_link = "http://rammb.cira.colostate.edu/ramsdis/online/images/latest_hi_res/himawari-8/full_disk_ahi_natural_color.jpg"

      HTTP::Client.get image_link do |res|
        image_path = "#{@image_dir}/#{date_time}.jpg"
        File.write image_path, res.body_io if image_path
        @image_path = image_path 
      end
    else
      puts "Invalid JSON"; exit 1;
    end
  end

  private def change_background
    if system "gnome-session --version"
      system "gsettings set org.gnome.desktop.background picture-uri #{@image_path}"
    
    elsif system "plasmashell --version"
      plasma_script = %(
var allDesktops = desktops();
print (allDesktops);

for (i=0;i<allDesktops.length;i++) {
    d = allDesktops[i];
    d.wallpaperPlugin = "org.kde.image";
    d.currentConfigGroup = Array("Wallpaper", "org.kde.image", "General");
    d.writeConfig("Image", "#{@image_path}")
}
)
      system "qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript '#{plasma_script}'"
    else
      system "feh --bg-scale #{@image_path}" # Should work for x11 environments (and osx, afaik)
    end

    puts "New image set: #{@image_path}"
  end

  def run
    on_error !system("feh --version &>/dev/null"), "ERROR: Could not find feh installed on your system.
$ brew install feh # for osx
# pacman -S feh # Arch Linux
# apt-get install feh # Debian, Ubuntu &co."

    unless Dir.exists? image_dir
      Dir.mkdir image_dir
      puts "Directory created succesfully @ #{@image_dir}"
    end

    loop do 
      download_latest
      change_background
      sleep 600 # There's a new image every 10 min
    end
  end

  JSON.mapping(
    image_dir: String,
    download_only: Bool
  )
end


some_path = IMAGE_DIR
some_answer = false

OptionParser.parse! do |parzar|
  parzar.banner = %q{
         __                                                    .__  .__          
  ______/  |______ _______            _________  ________ ____ |  | |  |   ____  
 /  ___\   __\__  \\_  __ \  ______  / ___\__  \ \___   _/ __ \|  | |  | _/ __ \ 
 \___ \ |  |  / __ \|  | \/ /_____/ / /_/  / __ \_/    /\  ___/|  |_|  |_\  ___/ 
/____  >|__| (____  |__|            \___  (____  /_____ \\___  |____|____/\___  >
     \/           \/               /_____/     \/      \/    \/               \/ 

Usage: star-gazelle [option]
}
  parzar.on(
    "-d PATH",
    "--dir PATH",
    "Change the default '~/.star-gazelle' directory"){ |path| some_path = path }
  parzar.on(
    "-s PATH",
    "--no-wall-set PATH",
    "Only download the wallpapers"){ |tf| some_answer = true if tf }
  parzar.on(
    "-h",
    "--help",
    "Show this help"){
      puts parzar
      exit 0
    }
end


star : Gazelle
if File.exists? CONFIG_FILE
  star = Gazelle.from_json File.read CONFIG_FILE
else
  star = Gazelle.new
end

Signal::INT.trap do
  puts "\rDone. Bye !"
  exit
end

puts "And so the gazelle runs"
star.run

