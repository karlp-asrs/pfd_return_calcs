pfd.return=function(cf,int,freq=4,mdate=NA) {
  require(zoo)
  require(lubridate)
  #check validity of compounding period
  if(!freq%in%c(1,4,12)) stop('freq must be annual(1), quarterly(4) or monthly(12)')
  #check that cf is a zoo object
  if(!is.zoo(cf)) stop('cash flow must be zoo object')
  #ignore cash flow elements after the measurement date
  if(!is.na(mdate)) {
    cf=cf[time(cf)<=mdate]
    cf=zoosum(cf,zoo(0,mdate))
  } 
  tl=time(cf)
  if("Date"!=class(tl)) {
    tl=as.Date(tl)
    warning ('time index coerced to Date class')
  }
  if(freq==1) {
    time.ld=seq(year(tl[1]),year(lastinvec(tl)))
    time.ld=-1+as.Date(1+yearmon(time.ld))
    report.ld=.25+seq(as.yearqtr(tl[1]),as.yearqtr(lastinvec(tl)),by=.25)
    while(1!=quarter(lastinvec(report.ld))) {
      report.ld=c(report.ld,.25+lastinvec(report.ld))
    }
    report.ld=-1+as.Date(report.ld)
    if(is.na(mdate)) mdate=lastinvec(time.ld)
    if(lastinvec(time.ld)>mdate) {
      time.ld[length(time.ld)]=mdate
      report.ld=report.ld[report.ld<mdate]
      if(mdate!=lastinvec(report.ld)) report.ld=c(report.ld,mdate)
    }
  }
  if(freq==4) {
    time.ld=.25+seq(as.yearqtr(tl[1]),as.yearqtr(lastinvec(tl)),by=.25)
    time.ld=-1+as.Date(time.ld)
    if(is.na(mdate)) mdate=lastinvec(time.ld)
    if(lastinvec(time.ld)>mdate) {
      time.ld[length(time.ld)]=mdate
    }
    report.ld=time.ld
  }
  if(freq==12) {
    nmon=1+round(12*(as.yearmon(lastinvec(tl))-as.yearmon(tl[1])))
    time.ld=-1+as.Date(as.yearmon((tl[1])+months(1:nmon)))
    if(is.na(mdate)) mdate=lastinvec(time.ld)
    if(lastinvec(time.ld)>mdate) {
      time.ld[length(time.ld)]=mdate
    }
    report.ld=time.ld
  }
  acc.pref=current.pref=unreturned=zoo(0,report.ld)
  pref.paid=cap.paid=residual=0*cf
  time.comb=time(zoosum(cf,unreturned))
  unreturned.bal=current.bal=acc.bal=0
  n=length(time.comb)
  for (i in 1:n) {
    now=time.comb[i]
    ndays=0
    if(i!=1) ndays=as.numeric(time.comb[i]-time.comb[i-1])
    current.bal=current.bal+(int*ndays/365)*(acc.bal+unreturned.bal)
    if (now%in%tl) {
      cf.now=as.numeric(cf[now])
      if(cf.now>0) {
        split=waterfall(c(current.bal,acc.bal,unreturned.bal),cf.now)
        current.bal=current.bal-split[1]
        acc.bal=acc.bal-split[2]
        unreturned.bal=unreturned.bal-split[3]
        pref.paid[time.comb[i]]=split[1]+split[2]
        cap.paid[time.comb[i]]=split[3]
        residual[time.comb[i]]=split[4]
      } else {
        unreturned.bal=unreturned.bal-cf.now
      }
    }
    if(now%in%report.ld) {
      unreturned[now]=unreturned.bal
      acc.pref[now]=acc.bal
      current.pref[now]=current.bal
    }
    if(now%in%time.ld) {
      acc.bal=acc.bal+current.bal
      acc.pref[now]=acc.bal
      current.pref[now]=0
      current.bal=0
    }
  }
  ans=list()
  ans$current.pref=current.pref
  ans$acc.pref=acc.pref
  ans$unreturned=unreturned
  ans$pref.paid=pref.paid
  ans$cap.paid=cap.paid
  ans$residual=residual
  ans$cf=cf
  return(ans)
}


zoosum = function(...) {
  sumz = merge(...)
  if(is.null(dim(sumz))) return(sumz)
  zoo(rowSums(sumz, na.rm = TRUE), time(sumz))
}

lastinvec=function(x,naremove=FALSE) {
  ans=tail(x,1)
  if(length(ans)> 0){
    if(naremove & is.na(ans)) ans=0
  }
  return(ans)
}
