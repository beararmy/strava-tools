## strava-tools
Some useful tools I've cobbled together that make strava automating nicer.

##### Strava-CheckCommute
Feed this an activityID and it will guesstimate if it's a commute or not.

Example: _Strava-CheckCommute -ActivityID 1626198717_

##### Strava-NewSinceLast
Eventually this will enable periodic importing and background running, pulls data since -LastRun

Example: _Strava-NewSinceLast -LastRun $var_lastrun_unix_ts -Bearer $var_bearer | ft_

##### Strava-Details
Generic table of details for an activity

Example: _Strava-Details -ActivityID 1626198717 -Bearer $var_bearer | ft_

##### Strava-SetAsCommute
Once there's a bit more logic and something to get the Oauth key this will set as Commute in strava

Example: _Strava-SetAsCommute -ActivityID 1631078707 -Direction Workwards_