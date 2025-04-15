require "sinatra"
require "dotenv/load"
require "net/http"
require "json"

#ENVは環境変数を扱うときに使う。ハッシュと似てるが、キーと値に文字列しか取れない。ENVで得られる文字列は変更不可。
CLIENT_ID = ENV.fetch("CLIENT_ID") #fetchはキーに関連付けられた値を返す。
CLIENT_SECRET = ENV.fetch("CLIENT_SECRET")

#レスポンス解析
def parse_response(response)
  #case~when~で条件分岐する。case "対象オブジェクト" when "条件"
  case response
  when Net::HTTPOK #HTTPレスポンス200(OK)を意味する
    JSON.parse(response.body) #JSON形式の文字列をRubyオブジェクトに変換する。
  else
    puts response #データ出力。print的なやつ。最後に改行が入る。
    puts response.body
    {}
  end
end

def exchange_code(code)
  params = {
    "client_id" => CLIENT_ID,
    "client_secret" => CLIENT_SECRET,
    "code" => code
  }
  result = Net::HTTP.post(
    URI("https://github.com/login/oauth/access_token"),
    URI.encode_www_form(params),
    {"Accept" => "application/json"}
  )

  parse_response(result)
end

def user_info(token)
  uri = URI("https://api.github.com/user")

  result = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
    auth = "Bearer #{token}"
    headers = {"Accept" => "application/json", "Content-Type" => "application/json", "Authorization" => auth}

    http.send_request("GET", uri.path, nil, headers)
  end

  parse_response(result)
end

get "/" do
  link = '<a href="https://github.com/login/oauth/authorize?client_id=<%= CLIENT_ID %>">Login with GitHub</a>'
  erb link
end

get "/github/callback" do
  code = params["code"]

  token_data = exchange_code(code)

  if token_data.key?("access_token")
    token = token_data["access_token"]

    user_info = user_info(token)
    handle = user_info["login"]
    name = user_info["name"]

    render = "Successfully authorized! Welcome, #{name} (#{handle})."
    erb render
  else
    render = "Authorized, but unable to exchange code #{code} for token."
    erb render
  end
end
