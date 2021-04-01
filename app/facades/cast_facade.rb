class CastFacade
  attr_reader :person, :results

  def initialize(id, limit)
    @person = MovieService.person_info(id)
    @results = MovieService.movies_by_cast_id(id, limit)
  end
end
