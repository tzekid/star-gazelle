#!/usr/bin/env ruby
require 'curb'
require 'json'
require 'open3'
require 'rmagick'
include Magick

$level = 4 #level can be 4 / 8 / 16 / 20
$TempPath = "./Temp" #Location to store the seperate parts of the immage (you have to create the folder yourself)

#Get the latest datetime
def GetLatestPictureInfo()
    begin
        c = Curl::Easy.perform("http://himawari8-dl.nict.go.jp/himawari8/img/D531106/latest.json")
    rescue 
        puts("Unable to download latest info!")
        return false;
    else
        data = JSON.parse(c.body_str)
        datetime = data.fetch("date")
        return datetime
    end
end

#Download the pictures | datetime format: yyyy-MM-dd HH:mm:ss
def SetPicture(datetime)
    #Format the datetime 
    datetime = datetime.split(' ')
    datetime[0] = datetime[0].split('-')
    datetime[1] = datetime[1].delete! ':'
    
    year = datetime[0][0]
    month = datetime[0][1]
    day = datetime[0][2]
    time = datetime[1]

    #Download / Composite
    url = "http://himawari8-dl.nict.go.jp/himawari8/img/D531106/#{$level}d/550/#{year}/#{month}/#{day}/#{time}"

    final = ImageList.new

    for i in 0..$level - 1
        currColumn = ImageList.new
        for j in 0..$level - 1
            begin
            Curl::Easy.download("#{url}_#{i}_#{j}.png","#{$TempPath}/#{i}_#{j}.png") end
            currpic = Image.read("#{$TempPath}/#{i}_#{j}.png").first
            currColumn.push(currpic)
        end
        final.push(currColumn.append(true))
    end

    final.append(false).write("final.png")
end

#Script to chnage the Wallpaper (>Plasma 5.8)
set_wallpaper_script = %Q[
  var allDesktops = desktops();
  print (allDesktops);
  for (i=0; i<allDesktops.length; i++) {
    d = allDesktops[i];
    d.wallpaperPlugin = "org.kde.image";
    d.currentConfigGroup = Array("Wallpaper", "org.kde.image", "General");
    d.writeConfig("Image", "file:///home/sleider/Documents/Code/Desktop/LiveEarth/final.png")
  }
]

#Update to the latest Picture (new picture every 10min)
info = GetLatestPictureInfo()
SetPicture(info)
puts("Wallpaper updated!")

#Execute the Script
stdin, stdout, stderr, wait_thr = Open3.popen3(
"qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript '#{set_wallpaper_script}'"
)
if stdout.read =~ /Widgets are locked/
    puts "Cannot change the wallpaper while widgets are locked! (unlock the widgets)"
    exit
end
