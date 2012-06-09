#heroku scale web=0 clock=1
web: shotgun web/app.rb -p $PORT -o 0.0.0.0
clock: bundle exec clockwork bin/event_capture.rb -p