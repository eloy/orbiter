defmodule Orbiter.Web do
  import Plug.Conn
  use Plug.Router
  require EEx
  alias Orbiter.{ConnectionManager, Config, PublicKey}

  plug Plug.Logger, log: :debug
  plug Plug.Parsers, parsers: [:urlencoded, :multipart]

  plug :match
  plug :dispatch

  def dispatch do
    [{:_, [
         # {"/ws", MyApp.SocketHandler, []},
         {"/assets/[...]", :cowboy_static, {:priv_dir, :orbiter, "static"}},
         {:_, Plug.Adapters.Cowboy.Handler, {Orbiter.Web, []}}
       ]
     }]
  end


  @domoio_url Application.get_env(:orbiter, :domoio_url)

  EEx.function_from_file :defp, :tmpl_home_index, "web/views/home/index.html.eex", [:domoio_url]

  get "/" do
    page_contents = tmpl_home_index(@domoio_url)
    conn
    |> put_resp_content_type("text/html") |> send_resp(200, page_contents)
  end

  get "/api/state" do
    state = ConnectionManager.state
    json(conn, state)
  end

  get "/api/auth_request" do
    public_key = Hexate.encode PublicKey.public_key_der
    device_id = Config.get :device_id
    json conn, %{public_key: public_key, device_id: device_id}
  end

  post "/auth_reply" do
    conn = fetch_query_params(conn)
    IO.puts inspect(conn.params)
    %{"device_id" => device_id} = conn.params
    Config.set :device_id, device_id
    Orbiter.ConnectionManager.start_connection
    redirect(conn, to: "/") |> halt
  end

  def json(conn, content) do
    json_content = Poison.encode! content

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, json_content)
  end

  def redirect(conn, [to: url]) do
    html = Plug.HTML.html_escape(url)
    body = "<html><body>You are being <a href=\"#{html}\">redirected</a>.</body></html>"

    conn
    |> put_resp_header("location", url)
    |> send_resp(conn.status || 302, body)
  end
end
