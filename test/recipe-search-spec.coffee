should = require 'should'
rs = require "#{__dirname}/../lib/recipe-search"
{allrecipe_busted,scrape_allrecipe,base_url,make_url} = require './test-utils'
L = console.log.bind console

describe 'recipe-search', ->

  describe '_get_find_by_ingredients_url', ->

    it 'should handle no arguments', ->
      should.strictEqual undefined, rs._get_find_by_ingredients_url()

    it "should handle no ingredient array", ->
      should.strictEqual undefined, rs._get_find_by_ingredients_url([])

    it "should handle one ingredient array", ->
      arg = 'one'
      rs._get_find_by_ingredients_url([arg]).should.equal "#{base_url}Wanted1=#{arg}"

    it "should handle multiple ingredients array", ->
      args = ['one','two','three']
      rs._get_find_by_ingredients_url(args)
        .should.equal "#{base_url}Wanted1=#{args[0]}&Wanted2=#{args[1]}&Wanted3=#{args[2]}"


  describe 'find_by_ingredients_url', ->

    it 'when passed no ingredients, should call callback with error', (done)->
      rs.find_by_ingredients (err)->
        err.should.equal 'No ingredients specified'
        done()
    
    it 'when passed ingredients, should return recipes scraped allrecipes.com', (done)->
      scrape_allrecipe (ingredients = ['onion','green pepper']), ($)->
        recipe_links = $ '.rectitlediv > h3 > a'
        if not recipe_links? or recipe_links.length <= 0
          allrecipe_busted("Expected atleast one recipe link")
        
        expected_recipes = do->
          for link in recipe_links then do->
            $link = $(link)

            name: $link.text()
            url: $link.attr 'href'
            rating: do->
              if text = $('.starsimg > a > img', $link.closest('.recipes.recipes_compact')).attr('alt')
                matches = /(\d(.\d+)?) stars: (\d+) ratings/.exec text
                stars: Number(matches[1])
                total_votes: Number(matches[3])

        rs.find_by_ingredients ingredients, (err,recipe_names)->
          recipe_names.should.eql expected_recipes
          done()
    
    it 'when allrecipes.com gives no results, should return empty array', (done)->

      scrape_allrecipe (ingredients = ['totallyBoGus','totallyBoGus2']), ($)->
        recipe_links = $ '.rectitlediv > h3 > a'
        if recipe_links? and recipe_links.length > 0
          allrecipe_busted("Expected atleast NO recipe links") 

        rs.find_by_ingredients ingredients, (err,recipe_names)->
          recipe_names.should.eql []
          done()