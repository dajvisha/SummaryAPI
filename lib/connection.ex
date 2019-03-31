defmodule Summary.Connection do
  @moduledoc """
  Summary.Connection provides wrappers to make post and get
  connections to a given URL. 
  """

  @doc """
  Given a string with keys it replaces it with the values in a map. 

  ## Parameters

    - url: A string url, for example `"www.mysite.com"`
    - endpoint: A string endpoint, for `example "people/:id"`
    - params: A map, for example `%{"id" => 1}`

  ## Examples

      iex(1)> Summary.Connection.create_url("www.mysite.com", "people/{id}", %{"id" => 1})
      <<119, 119, 119, 46, 109, 121, 115, 105, 116, 101, 46, 99, 111, 109, 47, 112, 101, 111, 112, 108, 101, 47, 1>>

  """
  @spec create_url(String.t(), String.t(), map()) :: any()
  def create_url(url, endpoint, params) do
    parsed_endpoint =
      Regex.replace(~r/{([a-z]+)?}/, endpoint, fn _, key ->
        params[key]
      end)

    "#{url}/#{parsed_endpoint}"
  end

  @doc """
  Given an url perform a HTTP GET request. 

  ## Parameters

    - url: An string url, for example `"www.mysite.com/people/1"`

  """
  @spec get(String.t()) :: {Integer.t(), any()}
  def get(url) do
    response = HTTPoison.get!(url)

    case response.status_code do
      406 ->
        {:error, response.body}

      200 ->
        {:ok, Poison.decode!(response.body)}
    end
  end

  @doc """
  Given an url perform a HTTP GET request. 

  ## Parameters

    - url: An string url, for example `"www.mysite.com/people/1"`

  """
  @spec post(String.t(), map()) :: {Integer.t(), any()}
  def post(url, body) do
    body = Poison.encode!(body)

    response =
      HTTPoison.post!(url, body, [
        {"Content-Type", "application/json"}
      ])

    case response.status_code do
      406 ->
        {:error, response.body}

      200 ->
        {:ok, response.body}
    end
  end
end
