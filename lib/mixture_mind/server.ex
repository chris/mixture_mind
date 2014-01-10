defmodule MixtureMind.Server do
  use GenServer.Behaviour
  alias MixtureMind.Game

  @name { :global, :mixture_mind }


  def start_link do
    :gen_server.start_link(@name, __MODULE__, [], [])
  end

  @doc "Start a new game for the calling client."
  def new_game(num_slots // 4) do
    :gen_server.call @name, { :new_game, num_slots }
  end

  @doc """
  Make a guess. guess should be a string composed of the supported letters
  corresponding to colors. No spaces. This will send back a corresponding result.
  """
  def guess(guess) when is_binary(guess) do
    :gen_server.call @name, { :guess, guess }
  end

  def init(_start_args) do
    { :ok, HashDict.new }
  end

  def handle_call({ :new_game, num_slots }, { client_pid, _ }, clients) do
    IO.puts "Initiating new game for client #{inspect client_pid}"
    { :reply, "Ready for your guess.", Dict.put(clients, client_pid, Game.new_code(num_slots)) }
  end

  def handle_call({ :guess, the_guess }, { client_pid, _ }, clients) do
    IO.puts "looking up client #{inspect client_pid} in clients:"
    IO.puts "#{inspect clients}"
    case Dict.get(clients, client_pid, :unknown) do
      :unknown ->
        { :reply, "Please start a new game in order to play.", clients }
      code ->
        case Game.guess(code, the_guess) do
          :win -> { :reply, "You guessed the code!", Dict.drop(clients, [client_pid]) }
          _    -> { :reply, Game.guess(code, the_guess), clients }
        end
    end
  end

  def format_status(_reason, [ _pdict, state ]) do
    info = Enum.map(state, fn({client, code}) -> "Client #{inspect client}'s code: #{code}" end) |> Enum.join("\n")
    [data: [{'State', info}]]
  end
end
