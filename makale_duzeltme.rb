require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'active_record'

DIZIN="D:/Kisisel/Ozyegin/Dersler/Donem1/InformationRetrieval/Proje/Makaleler/Openaire"
MAKALE_DOSYASI=DIZIN + "/bol"

MAKALE_SAYISI=DIZIN + "/dosyalanan_makale_sayisi.txt"


makale_sayisi=File.read(MAKALE_SAYISI).to_i

Dir[MAKALE_DOSYASI + "/*"].each do |filePath|

  if filePath.match(/(.*)makale(.*).txt/)

    dosya = File.read(filePath)

    dosya.gsub! "<makale/>", "<makale></makale>\n"
    dosya.gsub! "<baslik/>", "<baslik></baslik>\n"
    dosya.gsub! "<yil/>", "<yil></yil>\n"
    dosya.gsub! "<anahtarlar/>", "<anahtarlar></anahtarlar>\n"
    dosya.gsub! "<anahtar/>", "<anahtar></anahtar>\n"
    dosya.gsub! "<doi/>", "<doi></doi>\n"
    dosya.gsub! "<ozet/>", "<ozet></ozet>\n"
    dosya.gsub! "</doi></makale>", "</doi><ozet></ozet></makale>\n"
    dosya.gsub! "</yil></makale>", "</yil><ozet></ozet></makale>\n"
    dosya.gsub! "</baslik></makale>", "</baslik><ozet></ozet></makale>\n"
    dosya.gsub! "</ozet></baslik>", "</ozet>\n"

    str1_markerstring = "<baslik>"
    str2_markerstring = "</ozet>"

    yedek=""
    dosya.split(/#{str2_markerstring}/).each_with_index do |item, index|

      if index == 0
        icerik = item.split(/#{str1_markerstring}/)
        icerik.each_with_index do |item2, index2|
          if icerik.length - 1 == index2
            yedek="<makale>\n<baslik>\n" + item2 + "\n</ozet>\n</makale>"
          end
        end
      else
        if item.length > 100
          icerik = item.split(/#{str1_markerstring}/)
          icerik.each_with_index do |item2, index2|
            if icerik.length - 1 == index2
              makale_sayisi += 1
              my_file = File.new(DIZIN + "/bol/yeni/makale#{makale_sayisi}.txt", "w")
              icerik = "<makale>\n<baslik>\n" + item2 + "\n</ozet>\n</makale>"
              File.write(my_file, icerik)
              my_file.close
            end
          end
        end
      end
    end

    my_file = File.new(filePath, "w")
    File.write(my_file, yedek)
    my_file.close

  end
end