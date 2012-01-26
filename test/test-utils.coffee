should = require 'should'
jsdom = require 'jsdom'
jquery = require('fs').readFileSync "#{__dirname}/../vendor/jquery.min.js"
util = require 'util'

scrape = (url,done)->
  jsdom.env
    html: url
    src: [jquery]
    done: (err,window)->
      allrecipe_busted("Expected no errors retrieving url=#{url}") if err
      done window.$

module.exports =
  allrecipe_busted: allrecipe_busted = (msg)->
    should.fail "allrecipes.com is busted or has changed. #{msg or ''}"
    throw "TEST BUSTED"

  scrape_allrecipe: scrape_allrecipe = (ingredients, done)->
    scrape make_url(ingredients), done
  
  scrape_allrecipe_details: scrape_allrecipe_details = (recipe_url, done)->
    scrape recipe_url, done

  base_url: base_url = "http://allrecipes.com/Search/Ingredients.aspx?WithTerm=&SearchIn=All&"
  make_url: make_url = (ingredients)->
    base_url + ("Wanted#{i+1}=#{ingr}" for ingr,i in ingredients).join '&'