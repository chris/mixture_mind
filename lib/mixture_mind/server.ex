defmodule MixtureMind.Server do
  use GenServer.Behaviour

  @name :mixture_mind


  def start_link do
    :gen_server.start_link({ :local, @name }, __MODULE__, [], [])
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

  def init do
    { :ok, HashDict.new }
  end

  def handle_call({ :new_game, num_slots }, _from, clients) do
    { :reply, "Ready for your guess.", Dict.put(clients, _from, Game.new_code(num_slots)) }
  end

  def handle_call({ :guess, the_guess }, _from, clients) do
    import MixtureMind.Game, only: [guess: 2]

    case Dict.get(clients, _from, :unknown) do
      :unknown ->
        { :reply, "You haven't started a game.", clients }
      code ->
        case guess(code, the_guess) do
          :win ->
            { :reply, "You guessed the code! I've started a new game for you.", Dict.put(clients, _from, Game.new_code) }
          _ ->
            { :reply, guess(code, the_guess), clients }
        end
    end
  end

  def format_status(_reason, [ _pdict, state ]) do
    info = Enum.map(state, fn({client, code}) -> "Client #{inspect client}'s code: #{code}" end) |> Enum.join("\n")
    [data: [{'State', info}]]
  end
end
