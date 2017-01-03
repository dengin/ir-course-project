require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'active_record'

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

MAKALE_DOSYASI = "D:/Kisisel/Ozyegin/Dersler/Donem1/InformationRetrieval/Proje/Makaleler/Doaj/makale/"
DOSYALANAN_MAKALE_SAYISI_DOSYASI = "D:/Kisisel/Ozyegin/Dersler/Donem1/InformationRetrieval/Proje/Makaleler/Doaj/dosyalanan_makale_sayisi.txt"

URL ="http://localhost:8081/"

def basla()

  i = 1
  while i < 8 do
    makaleleriHazirla(i)
    i += 1
  end

end

def makaleleriHazirla(i)

  makale_sayisi = File.read(DOSYALANAN_MAKALE_SAYISI_DOSYASI).to_i

  page = sayfayiOku("#{i}.html")

  page.css("table#facetview_results tr").map do |row|

    makale = "<makale>"

    baslik = row.css("span.title")

    #makale basligi
    if baslik != nil and baslik.at_css("a") then
      makale += "<baslik>"
      makale += baslik.at_css("a").text.strip
      makale += "</baslik>"

      if baslik.at_css("a").at("@href") != nil then
        makale += "<makaledetayi>"
        makale += "http://doaj.org/" + baslik.at_css("a").at("@href").text.strip
        makale += "</makaledetayi>"
      end
    end

    #yazarlar
    em = row.css("em")
    if em != nil then
      makale += "<yazarlar>"
      em.text.split(',').each do |yazar|
        makale += "<yazar>"
        makale += yazar.strip
        makale += "</yazar>"
      end
      makale += "</yazarlar>"
    end

    #doi
    doi = row.css("a")
    if doi != nil then
      doi.each do |doilink|
        if doilink != nil and doilink.at("@href") != nil and doilink.at("@href").text.start_with?  "http://dx.doi" then
          makale += "<doi>"
          makale += doilink.text.strip
          makale += "</doi>"
          makale += "<doilink>"
          makale += doilink.at("@href").text.strip
          makale += "</doilink>"
        end
      end
    end

    #ozet
    ozet = row.css("div.abstract_text")
    if ozet != nil then
      makale += "<ozet>"
      makale += ozet.text.strip
      makale += "</ozet>"
    end

    makale += "</makale>\n"

    open((MAKALE_DOSYASI + "makale#{makale_sayisi}.xml"), "a") { |dosya|
      dosya.puts makale
    }
    makale_sayisi += 1
  end
  File.write(DOSYALANAN_MAKALE_SAYISI_DOSYASI, makale_sayisi)
end

def sayfayiOku(uri)
  return Nokogiri::HTML(open(uri))
end

basla()