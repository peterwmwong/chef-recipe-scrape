jsdom = require "jsdom"
jquery = require('fs').readFileSync "#{__dirname}/../vendor/jquery.min.js"

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
      jsdom.env html: url, src: [jquery], done: (err,{$})->
        if err then done err
        else
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

