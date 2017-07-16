require "http/client"
require "json"

# TODO(s):
# [ ] find a solution for windows

macro on_error( reason, message )
  (puts {{message}}; exit) if {{reason}}
end


on_error !system("feh --version &>/dev/null"), "ERROR: Could not find feh installed on your system.
$ brew install feh # for osx
# pacman -S feh # Arch Linux
# apt-get install feh # Debian, Ubuntu &co."


def do_all_the_things
  temp_path = "/home/#{System.hostname}/.star-gazelle"
  link = "http://himawari8-dl.nict.go.jp/himawari8/img/D531106/latest.json"
  response = nil
  image_link = nil
  image_path = nil

  unless Dir.exists? temp_path
    Dir.mkdir temp_path
    puts "Directory created succesfully @ #{temp_path}"
  end

  if response = JSON.parse( HTTP::Client.get(link).body )
    date_time = Time.parse(response["date"].to_s, "%Y-%m-%d %T").to_s("%Y%m%d%H%M%S")
    image_link = "http://rammb.cira.colostate.edu/ramsdis/online/images/latest_hi_res/himawari-8/full_disk_ahi_natural_color.jpg"

    HTTP::Client.get image_link do |res|
      image_path = "#{temp_path}/#{date_time}.png"
      File.write image_path, res.body_io
    end

    if system "gnome-session --version"
      system "gsettings set org.gnome.desktop.background picture-uri #{image_path}"
    elsif system "plasmashell --version"
      plasma_script = %(
var allDesktops = desktops();
print (allDesktops);

for (i=0;i<allDesktops.length;i++) {
    d = allDesktops[i];
    d.wallpaperPlugin = "org.kde.image";
    d.currentConfigGroup = Array("Wallpaper", "org.kde.image", "General");
    d.writeConfig("Image", "#{image_path}")
}
)
      system "qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript '#{plasma_script}'"
    else
      system "feh --bg-scale #{image_path}" # Should work for x11 environments (and osx, afaik)
    end

    puts "New image set: #{image_path}"
  else
    puts "Invalid JSON"; exit 1;
  end
end

loop do
  do_all_the_things
  sleep 10 * 60
end
