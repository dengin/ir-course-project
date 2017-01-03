require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'active_record'

MAKALE_DOSYASI="D:/Kisisel/Ozyegin/Dersler/Donem1/InformationRetrieval/Proje/Makaleler/Openaire/makale.xml"
MAKALE_SAYISI_DOSYASI="D:/Kisisel/Ozyegin/Dersler/Donem1/InformationRetrieval/Proje/Makaleler/Openaire/makale_sayisi.txt"
SORGULANAN_SAYFA_SAYISI_DOSYASI="D:/Kisisel/Ozyegin/Dersler/Donem1/InformationRetrieval/Proje/Makaleler/Openaire/sayfa_sayisi.txt"

URL_PRE="https://www.openaire.eu"
URL ="https://www.openaire.eu/search/browse/publications?language=tur&size=10&type=0001"

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

def makaleBul()
  siradaki_sayfa_numarasi = File.read(SORGULANAN_SAYFA_SAYISI_DOSYASI).to_i
  son_sayfa_numarasi = siradaki_sayfa_numarasi + 1000

  while siradaki_sayfa_numarasi < son_sayfa_numarasi do
    makaleler = makaleBilgileriniAl(URL + "&page=#{siradaki_sayfa_numarasi}")

    if siradaki_sayfa_numarasi.even? then
      sleep(2)
    end

    #puts makaleler

    open(MAKALE_DOSYASI, "a") { |dosya|
      dosya.puts "\n" + makaleler
    }
    siradaki_sayfa_numarasi += 1
    File.write(SORGULANAN_SAYFA_SAYISI_DOSYASI, siradaki_sayfa_numarasi)
  end

  File.write(SORGULANAN_SAYFA_SAYISI_DOSYASI, son_sayfa_numarasi)
end

def makaleBilgileriniAl(url)
  makale_sayisi = File.read(MAKALE_SAYISI_DOSYASI).to_i
  page = sayfayiOku(url)
  makaleler = ""

  page.css("div.searchResults").css("div.srchRow").map do |link|
    makaleler += "<makale>"

    #makale basligi
    #puts link.css("h4.openAccess").at_css("a").text
    makaleler += "<baslik>"
    baslik = link.css("h4.openAccess").at_css("a")
    if baslik != nil then
      makaleler += baslik.text.strip
    end
    makaleler += "</baslik>"

    #makale yili
    #puts link.css("div.biblio").text.tr('()', '')
    makaleler += "<yil>"
    yil = link.css("div.biblio")
    if yil != nil then
      makaleler += link.css("div.biblio").text.tr('()', '')
    end
    makaleler += "</yil>"

    #makale detayi
    if baslik != nil then
      articleDetail = sayfayiOku(URL_PRE + "#{baslik.at("@href")}")

      if articleDetail != nil then
        #yazarlar
        yazarlar = articleDetail.css("div.uk-width-7-10 div.publication div.infoline.authors")
        if yazarlar != nil then
          makaleler += "<yazarlar>"
          yazarlar.map do |authorLink|
            makaleler += "<yazar>"
            #yazar id
            #puts authorLink.css("span.auth").at_css("a").at("@href")
            yazar = authorLink.css("span.auth").at_css("a")
            if yazar != nil then
              makaleler += "<id>" + yazar.at("@href").text.strip + "</id>"
              #yazar tam adi
              #puts authorLink.css("span.auth").at_css("a").text
              makaleler += "<tamAdi>" + yazar.text.strip + "</tamAdi>"
              #yazar ad soyad
              authorPage = sayfayiOku(URL_PRE + "#{yazar.at("@href")}")

              if authorPage != nil then
                yazardetay = authorPage.css("div.uk-width-7-10 div.projectInfo div.curveBox.xtraMargin10 dl.uk-description-list-horizontal")
                if yazardetay != nil then
                  authorChilds = yazardetay.children
                  #puts authorChilds.css("dd")[0].inner_text
                  #puts authorChilds.css("dd")[1].inner_text
                  adsoyad = authorChilds.css("dd")
                  if adsoyad != nil then
                    if adsoyad[0] != nil then
                      makaleler += "<soyad>" + adsoyad[0].inner_text.strip + "</soyad>"
                    end
                    if adsoyad[1] != nil then
                      makaleler += "<ad>" + adsoyad[1].inner_text.strip + "</ad>"
                    end
                  end
                end
              end
            end
            makaleler += "</yazar>"
          end
          makaleler += "</yazarlar>"
        end

        #makale konulari - makale anahtar kelimeleri
        makaleler += "<anahtarlar>"
        anahtarlar = articleDetail.css("div.uk-width-7-10 div.publication div.subjects div.dcinfo span.subject_item")
        if anahtarlar != nil then
          anahtarlar.map do |keyword|
            #puts keyword.text
            makaleler += "<anahtar>" + keyword.text.strip + "</anahtar>"
          end
        end
        makaleler += "</anahtarlar>"

        #doi
        doilink = articleDetail.css("div.uk-width-7-10 div.publication div.dcinfo a.custom-external")
        if doilink != nil then
          makaleler += "<doi>" + doilink.text + "</doi>"
        end

        #makale ozeti
        #puts articleDetail.css("div.uk-width-7-10 div.publication div.description").text.strip
        makaleler += "<ozet>"
        ozet = articleDetail.css("div.uk-width-7-10 div.publication div.description")
        if ozet != nil then
          makaleler += articleDetail.css("div.uk-width-7-10 div.publication div.description").text.strip
        end
        makaleler += "</ozet>"
      end


    end

    makaleler += "</makale>"

    makale_sayisi += 1
  end
  File.write(MAKALE_SAYISI_DOSYASI, makale_sayisi)
  return makaleler
end

def sayfayiOku(uri)
  begin
    return Nokogiri::HTML(open(uri))#, :proxy_http_basic_authentication => ["http://10.200.125.229:80", "TTEDEMIRCIOGLU", "Turk2000cell"]))
  rescue
    return nil
  end
end

makaleBul()