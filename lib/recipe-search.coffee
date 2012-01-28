jsdom = require 'jsdom'
jquery = require('fs').readFileSync "#{__dirname}/../vendor/jquery.min.js"
{parse} = require 'url'

scrape = (url,done_err, done)->
  jsdom.env html: url, src: [jquery], done: (err,window)->
    if err then done_err err
    else done window.$

parse_time = (time_string)-> Number /PT(\d+)M/.exec(time_string)[1]

module.exports =

  _get_find_by_ingredients_url: _get_find_by_ingredients_url = (ingrs)->
    if ingrs? and Array.isArray(ingrs) and ingrs.length > 0
      "http://allrecipes.com/Search/Ingredients.aspx?WithTerm=&SearchIn=All&" +
        ("Wanted#{i+1}=#{ingr}" for ingr,i in ingrs).join '&'

  find_by_ingredients: (ingrs, done)->
    ingrs 'No ingredients specified' if typeof ingrs is 'function' and not done?
    if typeof done isnt 'function' then return

    if not (url = _get_find_by_ingredients_url ingrs)? then done 'Bad ingredients: #{ingrs}'
    else
      scrape url, done, ($)->
        if not (links = $('.rectitlediv > h3 > a'))? or links.length <= 0
          done undefined, []
        else
          done undefined, do->
            for l in links then do->
              $l = $ l
              name: $l.text()
              url: $l.attr 'href'
              rating: do->
                if text = $('.starsimg > a > img', $l.closest('.recipes.recipes_compact')).attr('alt')
                  matches = /(\d(.\d+)?) stars: (\d+) ratings/.exec text
                  stars: Number(matches[1])
                  total_votes: Number(matches[3])

  get_recipe_details: (recipe_url,done)->
    recipe_url 'No recipe url specified' if typeof recipe_url is 'function' and not done?
    if typeof done isnt 'function' then return

    recipe_url = parse recipe_url
    if recipe_url.hostname isnt 'allrecipes.com' then done 'Not an allrecipes.com url'
    else
      scrape recipe_url.href, done, ($)->
        if (name = $('#itemTitle').text().trim()) is ''
          done "Bad allrecipe.com recipe details url"
        else
          done undefined,
            name: name
            ingredients: ($(li).text().trim() for li in $('.ingredients > ul > li'))
            directions: ($(li).text().trim() for li in $('.directions > ol > li'))
            prep_time: parse_time $('.prepTime > span').attr('title')
            cook_time: parse_time $('.cookTime > span').attr('title')
