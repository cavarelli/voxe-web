class window.CountriesCollection extends Backbone.Collection
  model: CountryModel

  url: ->
    '/api/v1/countries/search'

  parse: (response) ->
    response.response
