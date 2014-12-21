
{OAuth2} = require 'oauth'
querystring = require 'querystring'


argv = require 'argv'
args = argv.option([
  name: 'lang'
  short: 'l'
  type: 'string'
  description: 'Written in language'
  example: "'twitter-search yo --lang=ja' or 'twitter-search yo -l ja'"
,
  name: 'from'
  short:'f'
  type: 'string'
  description: 'sent from <screen_name>'
  example: "'twitter-search yo --from=tuyapin' or 'twitter-search yo -f tuyapin'"
,
  name: 'to'
  short: 't'
  type: 'string'
  description: 'sent to <screen_name>'
  example:"'twitter-search problem --to=TechCrunch' or 'twitter-search problem -t TechCrunch'"
,
  name: 'place'
  short:'p'
  type:'string'
  description: 'Tweeted place near.'
,
  name:'since'
  short: 's'
  type:'string'
  example: '--since=2014-11-12 or -s 2014-11-12'
,
  name: 'until'
  short: 'u'
  type:'string'
  example: '--until=2011-02-25 or -u 2011-12-11'
,
  name: 'rt'
  short:'r'
  type:'boolean'
  description:'include RT?'
,
  name: 'count'
  short: 'c'
  type: 'int'
,
  name: 'rate_limit_status'
  type: 'boolean'




]).run()

baseurl = 'https://api.twitter.com/'
uribase = '1.1/'

client_id = '3nVuSoBZnx6U4vzUxf5w'
client_secret = 'Bcs59EFbbsdF6Sl9Ng71smgStWEGwXXKSjYvPVt7qys'
_access_token = null #@string
_refresh_token= null #@string(null)




Twitter = new OAuth2(client_id,client_secret,baseurl,null,'oauth2/token',null)


getToken = (callback,error)->
  Twitter.getOAuthAccessToken "", {grant_type:'client_credentials'},(e,access_token,refresh_token,res)->
    return error(e)  if e
    _access_token = access_token
    _refresh_token = refresh_token
    Twitter.useAuthorizationHeaderforGET true # queryではなくAuthorizeヘッダでトークンを送る
    callback(access_token)

get = (url,callback)->
  Twitter.get(baseurl+uribase+url,_access_token,callback)

search = (query,callback)->
  q = querystring.stringify(query)
  get('search/tweets.json?'+q,callback)



#testcase
getToken (at)->
  if args.options.rate_limit_status
    get 'application/rate_limit_status.json',(e,result,response)->
      d = JSON.parse(result)
      console.log("rate_limit_context: app: #{d.rate_limit_context.application}")
      for i,f of d.resources
        console.log("#{i}: ")
        for s,v of f
          console.log "\t #{s}:\t#{v.remaining} / #{v.limit}  \treset: #{v.reset} "
  else


    console.log("AccessToken",at)
    args.targets.push("language:#{args.options.lang}") if args.options.lang
    args.targets.push("from:#{args.options.from}") if args.options.from
    args.targets.push("to:#{args.options.to}") if args.options.to
    args.targets.push("place:\"#{args.options.place}\"") if args.options.place
    args.targets.push("since:#{args.options.since}") if args.options.since
    args.targets.push("until:#{args.options.until}") if args.options.until
    args.targets.push("include:retweets") if args.options.rt




    if args.targets.length
      t = args.targets.join(' ')
    else
      return console.error("There is no args. ")

    q =
      q: t
#      cards_platform :'Android-10'
#      include_cards: true
#    console.log t
    q.count = args.options.count if args.options.count
    search q,(err,result,response)->
      return console.error (err)   if err
#      console.log result
      res = JSON.parse(result)
      return console.error "No result." if !res.statuses.length
      console.log "Search query: #{t} / Results:#{res.statuses.length}"
      for s in res.statuses
        console.log("\u001b[35m#{s.user.name}\u001b[0m(\u001b[34m@#{s.user.screen_name}\u001b[0m)",s.text)
        #    console.log(response.statusCode)

,(e)->
  console.error e
console.log args