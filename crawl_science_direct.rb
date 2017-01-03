require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'active_record'
require timeout

URL="http://www.sciencedirect.com/science?_ob=ArticleListURL&_method=tag&searchtype=a&refSource=search&_st=13&count=1000&sort=r&filterType=&_chunk=2&hitCount=1881146&view=c&md5=c1fc7ba14a7adb6ed382faa65d22e11c&_ArticleListID=-1087699775&chunkSize=25&sisr_search=&TOTAL_PAGES=75246&zone=exportDropDown&citation-type=RIS&format=cite-abs&bottomPaginationBoxChanged=&displayPerPageFlag=t&resultsPerPage=200"

def getPage(uri)
  return Nokogiri::HTML(open(uri)) # html sayfasini aciyor
end

def findPapers()

  page = getPage(URL)

  baslangic_sayfasi = 0
  makale_sirasi = 1
  sayfadaki_kayit_sayisi = 100000
  toplam_kayit_sayisi_text = page.css("div.amtResults").css("h1.queryText").css("strong").text
  toplam_kayit_sayisi_text = toplam_kayit_sayisi_text[16..toplam_kayit_sayisi_text.length]
  toplam_kayit_sayisi_text = toplam_kayit_sayisi_text.gsub!(",", "")
  toplam_kayit_sayisi = toplam_kayit_sayisi_text.to_i

  while baslangic_sayfasi < (toplam_kayit_sayisi / sayfadaki_kayit_sayisi) do
    gidilecek_adres = URL + "&PREV_LIST=#{baslangic_sayfasi}"
    baslangic_sayfasi += 1
    gidilecek_adres += "&NEXT_LIST=#{baslangic_sayfasi}"

    page = getPage(gidilecek_adres)
    page.css("ol.articleList").css("li.detail").map do |link|

      puts "#{makale_sirasi}" + ". Makale Başlığı: " + link.css("li.title").at_css("a").text
      puts "Numara: " + link.css("li.selection input").attr("value").text
      puts "Yazar: " + link.css("li.authorTxt").text

      abstractPage = getPage(link.css("li.external").css('div.external').css("ul.extLinkBlock a").attr("data-url").text)
      puts "Özet: " + abstractPage.css("div.articleText_indent p").text
      puts "\n"
      makale_sirasi += 1

    end
  end
end

findPapers()





