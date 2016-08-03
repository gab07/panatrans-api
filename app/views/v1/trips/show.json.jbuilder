# The MIT License (MIT)
#
# Copyright (c) 2015 Juan M. Merlos, panatrans.org
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

json.prettify! if @prettify
json.status @status
json.data do
  json.extract! @trip, :id, :headsign, :direction
  json.route do
    json.id @trip.route.id
    json.url @trip.route.url
    json.name @trip.route.short_name
  end
  json.stop_times @trip.stop_times.includes(:stop).ordered do |sequence|
    json.extract! sequence, :id
    json.sequence sequence.stop_sequence
    json.stop sequence.stop, :id, :name, :lat, :lon
   end
  if @with_shape
    json.shape @trip.shapes do |shape_pt|
      json.extract! shape_pt, :id, :pt_lat, :pt_lon, :pt_sequence
    end
  end
end
