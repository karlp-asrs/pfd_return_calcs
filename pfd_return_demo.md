# Demonstration of pfd.return function
Karl Polen  
Thursday, July 03, 2014  
This is a demonstration of the pfd.return function.  It calculates preferred returns in typical private equity structures.  

It takes four arguments as follows  

  * `cf` is a cash flow zoo object with negative values for draws
  * `int` is the annual preferred return rate
  * `freq` is the compounding period, 1 for annual, 4 for quarterly and 12 for monthly
  * `mdate` is for measurement date which forces an accounting on the measurement date
    + cash flows after the measurement date are ignored
    + if measurement date is not provided, then the model is to extended to the end of the current fiscal period as determined by the compounding rate

  

```r
require(zoo)
source('pfd.return.r')
#illustrate the function with the b2 capital calls
b2.call=c(12595909,8235312,4392537,2351426,1693938,1294561,1608555,1551163)
b2.call=zoo(b2.call,as.Date(c("2013-4-25","2013-5-31","2013-6-27","2013-7-31","2013-8-30","2013-9-30","2013-12-12","2014-2-18")))
#asset management fee apportioned by weight of contributed capital
am.call=36365476/(71353128-1058219)*c(322603,365754,369863)
am.call=zoo(am.call,as.Date(c("2013-7-31","2013-10-31","2014-2-18")))
#combined cash flow in variable b2
b2=zoosum(b2.call,am.call)
b2.pfd=pfd.return(-b2,int=.06,freq=1,mdate=as.Date("2014-8-1"))
do.call(merge,b2.pfd)
```

```
##            current.pref acc.pref unreturned pref.paid cap.paid residual
## 2013-04-25           NA       NA         NA         0        0        0
## 2013-05-31           NA       NA         NA         0        0        0
## 2013-06-27           NA       NA         NA         0        0        0
## 2013-06-30     179435.7        0   25223758        NA       NA       NA
## 2013-07-31           NA       NA         NA         0        0        0
## 2013-08-30           NA       NA         NA         0        0        0
## 2013-09-30     594786.1        0   30730574         0        0        0
## 2013-10-31           NA       NA         NA         0        0        0
## 2013-12-12           NA       NA         NA         0        0        0
## 2013-12-31          0.0  1066455   32528344        NA       NA       NA
## 2014-02-18           NA       NA         NA         0        0        0
## 2014-03-31     508762.9  1066455   34270847        NA       NA       NA
## 2014-06-30    1037370.2  1066455   34270847        NA       NA       NA
## 2014-08-01          0.0  2289709   34270847         0        0        0
##                     cf
## 2013-04-25 -12595909.0
## 2013-05-31  -8235312.0
## 2013-06-27  -4392537.0
## 2013-06-30          NA
## 2013-07-31  -2518317.3
## 2013-08-30  -1693938.0
## 2013-09-30  -1294561.0
## 2013-10-31   -189214.5
## 2013-12-12  -1608555.0
## 2013-12-31          NA
## 2014-02-18  -1742503.2
## 2014-03-31          NA
## 2014-06-30          NA
## 2014-08-01         0.0
```
