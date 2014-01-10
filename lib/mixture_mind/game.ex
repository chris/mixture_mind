defmodule MixtureMind.Game do
  @colors [ red: "R", green: "G", blue: "B", purple: "P", yellow: "Y", white: "W" ]
  @correct "X"
  @partial "-"
  @nomatch " "

  @doc "Get a new code with `slots` items"
  def new_code(slots) do
    :random.seed(:erlang.now)
    color_vals = Dict.values(@colors)
    Enum.map(1..slots, fn(_) -> Enum.shuffle(color_vals) |> Enum.first end)
  end

  def instructions do
    """
    Guess a color code, where colors are represented by their first letter.
    You may use upper or lower case letters.

    Available colors are:
    #{Dict.keys(@colors) |> Enum.map(&(atom_to_binary(&1))) |> Enum.join(", ")}

    For example, to guess red, blue, white, yellow, you may guess:
    rbwy or RBWY (or rBwY, etc.)

    guess will return an '#{@correct}' in any position that is correct, and
    '#{@partial}' for a correct color, but incorrect position.
    """
  end

  @doc """
  Make a guess. Returns :win if the guess is correct, otherwise returns an
  "#{@correct}" in a correct color & position element, and "#{@partial}" for
  an element that is just the right color, but wrong position.
  """
  def guess(code, guess), do: _guess(code, String.upcase(guess))

  defp _guess(code, code), do: :win

  defp _guess(code, a_guess) do
    guess_list = String.to_char_list!(a_guess)
    code_list = String.to_char_list!(code)

    exact_matches(guess_list, code_list) |>
    partial_matches(guess_list, code_list) |>
    Enum.join
  end

  @doc "Find the exactly correct elements of a guess in a code."
  defp exact_matches(guesses, code) when is_list(guesses) and is_list(code) do
    Enum.zip(guesses, code) |>
    Enum.map fn(x) ->
      case x do
        {g,g} -> @correct
        _ -> @nomatch
      end
    end
  end

  defp remaining_items(exact_matches, code) do
    Enum.zip(exact_matches, code) |>
    Enum.reject(fn(x) ->
      case x do
        {@nomatch, _} -> false
        {@correct, _} -> true
      end
    end) |>
    Dict.values
  end

  @doc """
  Find the remaining partial matches. This finds the remaining elements/colors,
  and then iterates the non-matching guesses to see if they are in the remaining
  colors. If one matches, we mark it a partial match, and remove that instance
  of the color from the remaining and move on to the next one.
  """
  defp partial_matches(exact_matches, guesses, code) do
    remaining_colors = remaining_items(exact_matches, code)

    Enum.zip(guesses, exact_matches) |>
    Enum.map(fn(x) ->
      case x do
        {_, @correct} ->
          @correct
        {g, _} ->
          if Enum.any?(remaining_colors, &(&1 == g)) do
            remaining_colors = List.delete(remaining_colors, g)
            @partial
          else
            @nomatch
          end
      end
    end)
  end

end
