analytics-client
================

Client for different analytics services used for reporting needs

Installation
------------

```bash
gem install analytics-client
```

Usage
-----

```bash
analytics-client.rb -c PATH_TO_CONFIG
```

You can also specify jobs to run

```bash
analytics-client.rb -c PATH_TO_CONFIG -j JOB_NAME1,JOB_NAME2
```

to turn on more verbose output run it with -v option

```bash
analytics-client.rb -c PATH_TO_CONFIG -v
```

Configuration
-------------

configuration is written in YAML

Example config:

```yaml
Flurry: #Job name
  mobile_flurry_events: #Task name - each job can have more tasks in it
    type: Flurry # Type of fetcher to be used
    config: # config passed to fetcher
      key: API_KEY
      app_keys:
        APP_NAME: APP_KEY
    format: csv # csv is default
    output: mobile_apps.csv # file you want results to be saved in
GTMetrix_job:
  page_metrix:
    type: GTMetrixs
    config:
      user: USER
      password: PASSWORD
      urls:
        - http://example.com
        - http://example.com/page/admin.php
    output: ga_mobile_pvGTM
GA_Mobile:
  page_views:
    type: GoogleAnalytics
    config:
      client_id: CLIENT_ID
      client_secret: CLIENT_SECRET
      token: TOKEN
      refresh_token: REFRESH_TOKEN
      conf: Path/to/Legato/models.rb
      model: ModelName
      filters:
        - it_can_be_omitted_and_will_run_all_filters_in_model
        - page_views
    output: ga_mobile_events
```