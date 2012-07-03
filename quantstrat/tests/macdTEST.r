# Simple MACD strategy
#
# MACD may be used in many ways, this will demonstrate a trend indicator.
# 
# traditionally, when the MACD signal crosses zero, this indicated a establishment of a positive trend
#
# we'll buy on positive treshold crossover of the 'signal' column, and sell on negative threshold crossover
# 
# Author: brian
###############################################################################


require(quantstrat)
suppressWarnings(rm("order_book.macd",pos=.strategy))
suppressWarnings(rm("account.macd","portfolio.macd",pos=.blotter))
suppressWarnings(rm("account.st","portfolio.st","stock.str","stratMACD","initDate","initEq",'start_t','end_t'))

stock.str='AAPL' # what are we trying it on

#MA parameters for MACD
fastMA = 12 
slowMA = 26 
signalMA = 9
maType="EMA"

currency('USD')
stock(stock.str,currency='USD',multiplier=1)

#or use fake data
#stock.str='sample_matrix' # what are we trying it on
#data(sample_matrix)                 # data included in package xts
#sample_matrix<-as.xts(sample_matrix)


initDate='2006-12-31'
initEq=1000000
portfolio.st='macd'
account.st='macd'

initPortf(portfolio.st,symbols=stock.str, initDate=initDate)
initAcct(account.st,portfolios=portfolio.st, initDate=initDate)
initOrders(portfolio=portfolio.st,initDate=initDate)

strat.st<-portfolio.st
# define the strategy
strategy(strat.st, store=TRUE)

#one indicator
add.indicator(strat.st, name = "MACD", arguments = list(x=quote(Cl(mktdata))) )

#two signals
add.signal(strat.st,name="sigThreshold",arguments = list(column="signal",relationship="gt",threshold=0,cross=TRUE),label="signal.gt.zero")
add.signal(strat.st,name="sigThreshold",arguments = list(column="signal",relationship="lt",threshold=0,cross=TRUE),label="signal.lt.zero")

####
# add rules

# entry
add.rule(strat.st,name='ruleSignal', arguments = list(sigcol="signal.gt.zero",sigval=TRUE, orderqty=100, ordertype='market', orderside='long', threshold=NULL),type='enter',label='enter',storefun=FALSE)

#alternatives for risk stops:
# simple stoplimit order, with threshold multiplier
add.rule(strat.st,name='ruleSignal', arguments = list(sigcol="signal.gt.zero",sigval=TRUE, orderqty='all', ordertype='stoplimit', orderside='long', threshold=-.05,tmult=TRUE, orderset='exit2'),type='risk',label='risk',storefun=FALSE)
# alternately, use a trailing order, also with a threshold multiplier
#add.rule(strat.st,name='ruleSignal', arguments = list(sigcol="signal.gt.zero",sigval=TRUE, orderqty='all', ordertype='stoptrailing', orderside='long', threshold=-.15,tmult=TRUE, orderset='exit2'),type='risk',label='trailingexit')

# exit
add.rule(strat.st,name='ruleSignal', arguments = list(sigcol="signal.lt.zero",sigval=TRUE, orderqty='all', ordertype='market', orderside='long', threshold=NULL,orderset='exit2'),type='exit',label='exit')

#end rules
####

getSymbols(stock.str,from=initDate, to='2012-06-30')
start_t<-Sys.time()
out<-try(applyStrategy(strat.st , portfolios=portfolio.st,parameters=list(nFast=fastMA, nSlow=slowMA, nSig=signalMA,maType=maType)))
end_t<-Sys.time()
print(end_t-start_t)

start_t<-Sys.time()
updatePortf(Portfolio=portfolio.st,Dates=paste('::',as.Date(Sys.time()),sep=''))
end_t<-Sys.time()
print("trade blotter portfolio update:")
print(end_t-start_t)

chart.Posn(Portfolio=portfolio.st,Symbol=stock.str)
plot(add_MACD(fast=fastMA, slow=slowMA, signal=signalMA,maType="EMA"))

#look at the order book
getOrderBook('macd')

###############################################################################
# R (http://r-project.org/) Quantitative Strategy Model Framework
#
# Copyright (c) 2009-2010
# Peter Carl, Dirk Eddelbuettel, Brian G. Peterson, Jeffrey Ryan, and Joshua Ulrich 
#
# This library is distributed under the terms of the GNU Public License (GPL)
# for full details see the file COPYING
#
# $Id: macd.R 1010 2012-05-04 11:55:18Z braverock $
#
##############################################################################
