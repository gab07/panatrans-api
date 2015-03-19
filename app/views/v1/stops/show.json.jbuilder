json.prettify! if @prettify
json.status @status
json.data do
  json.extract! @stop, :id, :name, :lat, :lon
  json.routes @stop.routes do |route| 
    json.extract! route, :id, :name
    # ONLY if with_stop_sequences is set => get the trips with the stop_sequences 
    json.trips (@with_stop_sequences ? @stop.trips.includes(:stop_sequences) : @stop.trips) do |trip|
      if trip.route_id == route.id
        json.extract! trip, :id, :headsign, :direction, :route_id
        if @with_stop_sequences
          json.stop_sequences trip.stop_sequences do |stop_sequence|
            json.extract! stop_sequence, :id, :sequence, :stop_id, :trip_id
          end
        end
      end
    end # trip
  end # route
end # data
  


