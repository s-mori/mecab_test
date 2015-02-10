require 'open-uri'
require 'nokogiri'
require 'natto'
require 'levenshtein'

# title取得
def getTitle(html)
  html.search("title").text
end

# description取得
def getDescription(html)
  html.search("meta[@name='description']/@content")
end

# keywords取得
def getKeywords(html)
  html.search("meta[@name='keywords']/@content")
end

# Twitterアカウント取得
def getTwitterID(html)
  html.search("meta[@name='twitter:site']/@content")
end

# bodyタグの中身取得
def getBodyText(html)
  html.search("body").text
end

# 単語の出現回数をカウントする
# return Hash (key:単語 value:出現回数)
def countNumberOfNoun(text)
  natto = Natto::MeCab.new
  noun = Hash.new

  natto.parse(text) do |word|
    # 名詞だけを対象とする場合
    if word.feature.split(",")[0] == "名詞"
      # 該当する単語が既に出てきている場合+1カウント　なければ1カウント
      if noun.key?(word.surface)
        num = noun[word.surface].to_i
        num += 1
      else
        num = 1
      end
      noun[word.surface] = num
    end
  end
  noun
end

# レーベンシュタイン距離の算出（0に近いほど文章が似ている）
def calcLevenshtein(target_text="target_text", text="text")
  Levenshtein.normalized_distance(target_text, text)
end

# test url
url = "https://ferret-plus.com/588"
url2 = "http://mery.jp/73327"

doc = Nokogiri::HTML(open(url).read)
doc2 = Nokogiri::HTML(open(url2).read)

# ferretの本文のみ（関連記事などのない文章）取得
text = doc.search("div[@class='body']").text
# meryの本文のみ（関連記事などのない文章）取得
text2 = doc2.search("p[@class='article_product_desc']").text

noun_and_num = countNumberOfNoun(text)
# 単語の総数を出力
puts "number of all words = #{noun_and_num.values.inject(:+)}"
puts "distance of text and text2 = #{calcLevenshtein(text, text2)}"
