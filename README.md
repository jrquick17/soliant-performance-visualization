# Soliant Query Performance Visualization

# Development #

## Gather Results
* Open relevant link below
* Alter time range and/or set additional filters
* If changes, then click 'Save'
* Click 'Share' -> 'CSV Reports' -> 'Generate CSV'
* Go to [the reporting page](http://laselk.bullhorn.com/app/management/insightsAndAlerting/reporting) to download results 
### Links ###
#### All Corps ####
* [Link to All Corps' Invoice Logs](http://laselk.bullhorn.com/app/discover#/view/23a53f10-d6f0-11ec-b935-a74f67d110ca?_g=(filters:!(),refreshInterval:(pause:!t,value:0),time:(from:'2022-01-01T06:00:00.000Z',to:now))&_a=(columns:!(corp,path,query,msec),filters:!(('$state':(store:appState),meta:(alias:!n,disabled:!f,index:rest-access,key:corp,negate:!f,params:(query:13408),type:phrase),query:(match_phrase:(corp:13408)))),index:rest-access,interval:auto,query:(language:kuery,query:'path:%20%22*query%2FInvoiceStatement*%22'),sort:!()))
* [Link to All Corps' Billable Charge Logs](http://laselk.bullhorn.com/app/discover#/view/0f979450-d6f0-11ec-bafa-d9416a9da518?_g=(filters:!(),refreshInterval:(pause:!t,value:0),time:(from:'2022-01-01T06:00:00.000Z',to:now))&_a=(columns:!(corp,path,query,msec),filters:!(('$state':(store:appState),meta:(alias:!n,disabled:!f,index:rest-access,key:corp,negate:!f,params:(query:13408),type:phrase),query:(match_phrase:(corp:13408)))),index:rest-access,interval:auto,query:(language:kuery,query:'path:%20%22*query%2FBillableCharge*%22'),sort:!()))
* [Link to All Corps' Payable Charge Logs](http://laselk.bullhorn.com/app/discover#/view/f9ffa010-d6ef-11ec-bafa-d9416a9da518?_g=(filters:!(),refreshInterval:(pause:!t,value:0),time:(from:'2022-01-01T06:00:00.000Z',to:now))&_a=(columns:!(corp,path,query,msec),filters:!(('$state':(store:appState),meta:(alias:!n,disabled:!f,index:rest-access,key:corp,negate:!f,params:(query:13408),type:phrase),query:(match_phrase:(corp:13408)))),index:rest-access,interval:auto,query:(language:kuery,query:'path:%20%22*query%2FPayableCharge*%22'),sort:!()))

#### Soliant ####
* [Link to Soliant's Invoice Logs](http://laselk.bullhorn.com/app/discover#/view/dab7cec0-d5ec-11ec-bafa-d9416a9da518?_g=(filters:!(),refreshInterval:(pause:!t,value:0),time:(from:'2022-01-01T06:00:00.000Z',to:now))&_a=(columns:!(corp,path,query,msec),filters:!(('$state':(store:appState),meta:(alias:!n,disabled:!f,index:rest-access,key:corp,negate:!f,params:(query:13408),type:phrase),query:(match_phrase:(corp:13408)))),index:rest-access,interval:auto,query:(language:kuery,query:'path:%20%22*query%2FInvoiceStatement*%22%20AND%20corp%20%3D%2013408%20'),sort:!()))
* [Link to Soliant's Billable Charge Logs](http://laselk.bullhorn.com/app/discover#/view/dab7cec0-d5ec-11ec-bafa-d9416a9da518?_g=(filters:!(),refreshInterval:(pause:!t,value:0),time:(from:'2022-01-01T06:00:00.000Z',to:now))&_a=(columns:!(corp,path,query,msec),filters:!(('$state':(store:appState),meta:(alias:!n,disabled:!f,index:rest-access,key:corp,negate:!f,params:(query:13408),type:phrase),query:(match_phrase:(corp:13408)))),index:rest-access,interval:auto,query:(language:kuery,query:'path:%20%22*query%2FBillableCharge*%22%20AND%20corp%20%3D%2013408%20'),sort:!()))
* [Link to Soliant's Payable Charge Logs](http://laselk.bullhorn.com/app/discover#/view/88bae400-d6ef-11ec-bafa-d9416a9da518?_g=(filters:!(),refreshInterval:(pause:!t,value:0),time:(from:'2022-01-01T06:00:00.000Z',to:now))&_a=(columns:!(corp,path,query,msec),filters:!(('$state':(store:appState),meta:(alias:!n,disabled:!f,index:rest-access,key:corp,negate:!f,params:(query:13408),type:phrase),query:(match_phrase:(corp:13408)))),index:rest-access,interval:auto,query:(language:kuery,query:'path:%20%22*query%2FPayableCharge*%22%20AND%20corp%20%3D%2013408%20'),sort:!()))

## To Do ##
* Add checkboxes instead of buttons so that multiple params can be combined
* Add ability to limit results via date range
* Allow clicking unique ids to see the full log
* Create enums for fields and data types
* Combine unique calls into single msec and take average
