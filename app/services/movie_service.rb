class MovieService
  def self.top_rated(limit)
    self.get_needed_info("movie/top_rated?language=en-US", limit)
  end

  def self.search(keywords, limit)
    keywords = keywords.gsub(/ /, '%20')
    self.get_needed_info("search/movie?language=en-US&query=#{keywords}&include_adult=false", limit)
  end

  def self.trending(limit)
    self.get_needed_info("trending/movie/week?", limit)
  end

  def self.get_needed_info(uri, limit)
    @results = []
    page_num = 1
    until @results.count >= limit
      info = make_api_call("#{uri}&page=#{page_num}")
      return info if info[:error]
      return create_objects(@results, limit) if info[:results].count.zero?

      @results += info[:results]
      page_num += 1
    end
    create_objects(@results, limit)
  end

  def self.movies_by_cast_id(id, limit)
    info = make_api_call("person/#{id}/movie_credits?language=en-US")
    return info if info[:error]
    create_objects(info[:cast], limit)
  end

  def self.movie_info(api_movie_id)
    details = make_api_call("movie/#{api_movie_id}?language=en-US")
    cast = make_api_call("movie/#{api_movie_id}/credits?language=en-US")
    reviews = make_api_call("movie/#{api_movie_id}/reviews?language=en-US&page=1")

    OpenStruct.new({
                     id: details[:id],
                     title: details[:title],
                     genres: details[:genres],
                     runtime: details[:runtime],
                     runtime_hours: details[:runtime] / 60,
                     runtime_mins: details[:runtime] % 60,
                     vote_average: details[:vote_average],
                     overview: details[:overview],
                     cast: cast_info(cast).first(10),
                     reviews: review_info(reviews),
                     poster_path: details[:poster_path]
                   })
  end
  def self.person_info(id)
    details = make_api_call("person/#{id}?language=en-US")
    return details if details[:error]

    OpenStruct.new({
                     id: details[:id],
                     name: details[:name],
                     biography: details[:biography],
                     profile_path: details[:profile_path]
                   })
  end

  def self.create_objects(info, limit)
    info.map do |movie|
      OpenStruct.new({ id: movie[:id], title: movie[:title], vote_average: movie[:vote_average],
                       poster_path: movie[:poster_path] })
    end.first(limit)
  end

  def self.cast_info(info)
    info[:cast].map do |cast_member|
      { id: cast_member[:id], name: cast_member[:name], character: cast_member[:character] }
    end
  end

  def self.review_info(info)
    info[:results].map do |review|
      { author: review[:author], content: review[:content] }
    end
  end

  def self.make_api_call(url)
    response = connection.get(url)
    if response.status == 200
      data = response.body
      JSON.parse(data, symbolize_names: true)
    else
      response = Hash.new([])
      response[:error] = true
      response
    end
  end

  def self.connection
    Faraday.new(url: 'https://api.themoviedb.org/3/', params: { api_key: ENV['movie_api_key'] })
  end
end
