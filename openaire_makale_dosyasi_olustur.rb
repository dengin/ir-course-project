require 'rubygems'
require 'nokogiri'
require 'open-uri'

DOSYALANAN_MAKALE_SAYISI_DOSYASI="D:/Kisisel/Ozyegin/Dersler/Donem1/InformationRetrieval/Proje/Makaleler/Openaire/dosyalanan_makale_sayisi.txt"
MAKALE_DOSYASI="D:/Kisisel/Ozyegin/Dersler/Donem1/InformationRetrieval/Proje/Makaleler/Openaire/makale.xml"
GECICI_DOSYA="D:/Kisisel/Ozyegin/Dersler/Donem1/InformationRetrieval/Proje/Makaleler/Openaire/makale_yedek.xml"

def dosyala()
  makale_sayisi = File.read(DOSYALANAN_MAKALE_SAYISI_DOSYASI).to_i

  File.open(GECICI_DOSYA, 'w') do |fo|
    fo.puts '<root>'
    File.foreach(MAKALE_DOSYASI) do |li|
      fo.puts li
    end
    fo.puts '</root>'
  end

  doc = Nokogiri::XML(File.open(GECICI_DOSYA))
  doc.xpath("//makale").each do |m|

    my_file = File.new("D:/Kisisel/Ozyegin/Dersler/Donem1/InformationRetrieval/Proje/Makaleler/Openaire/makale/makale#{makale_sayisi}.txt", "w+")
    File.write(my_file, m)
    my_file.close

    makale_sayisi += 1

    File.write(DOSYALANAN_MAKALE_SAYISI_DOSYASI, makale_sayisi)
  end

  File.open(MAKALE_DOSYASI, "w") {|file| file.truncate(0) }
end

dosyala()