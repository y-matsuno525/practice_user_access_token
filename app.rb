require "sinatra"
require "dotenv/load"
require "net/http"
require "json"

CLIENT_ID = ENV.fetch("CLIENT_ID")
CLIENT_SECRET = ENV.fetch("CLIENT_SECRET")

#アプリの認証を求めるリンクを表示
get "/" do
    link = '<a href="https://github.com/login/oauth/authorize?client_id=<%= CLIENT_ID %>">Login with GitHub</a>'
    erb link #erbとは？
  end

#call back URLへの要求を処理
get "/y-matsuno525/translation-test" do #CALLBACK_URLはドメインを除いたものにする。テストならlocalhostにすべき？
  code = params["code"]
  render = "Successfully authorized! Got code #{code}."
  erb render
end

