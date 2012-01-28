should = require 'should'
rs = require "#{__dirname}/../lib/recipe-search"
{allrecipe_busted,scrape_allrecipe_details,base_url,make_url} = require './test-utils'
L = console.log.bind console

parse_time = (time_string)-> Number /PT(\d+)M/.exec(time_string)[1]

describe 'recipe-search', ->

  describe 'get_recipe_details', ->

    it 'when passed no recipe url', (done)->
      rs.get_recipe_details (err)->
        err.should.equal 'No recipe url specified'
        done()

    it 'when passed bad non-allrecipe.com url', (done)->
      rs.get_recipe_details 'http://www.google.com', (err)->
        err.should.equal 'Not an allrecipes.com url'
        done()

    it 'when passed bad allrecipe.com url', (done)->
      rs.get_recipe_details 'http://allrecipes.com/blargo', (err)->
        err.should.equal 'Bad allrecipe.com recipe details url'
        done()
    
    it 'should return recipe details scraped from allrecipe.com', (done)->
      scrape_allrecipe_details (url = 'http://allrecipes.com/recipe/rice-on-the-grill/detail.aspx'), ($)->
        ingredients = $ '.ingredients > ul > li'
        if not ingredients? or ingredients.length <= 0
          allrecipe_busted "Expected atleast one ingredient"

        directions = $ '.directions > ol > li'
        if not directions? or directions.length <= 0
          allrecipe_busted "Expected atleast one direction"
        
        expected_details =
          name: $('#itemTitle').text().trim()
          ingredients: ($(li).text().trim() for li in ingredients)
          directions: ($(li).text().trim() for li in directions)
          prep_time: parse_time $('.prepTime > span').attr('title')
          cook_time: parse_time $('.cookTime > span').attr('title')

        rs.get_recipe_details url, (err,details)->
          details.should.eql expected_details
          done()
    