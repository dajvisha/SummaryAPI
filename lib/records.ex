defmodule Summary.Records do
  @moduledoc """
  Summary.Records deals with the information fetching for
  Users and Movements. 
  """
  use Timex

  alias Summary.Connection

  @doc """
  Given an url, endpoint and a params map fetch information recursively
  until there is not a 406 error. 

  ## Parameters

    - url: A string url, for example `"www.mysite.com"`
    - endpoint: A string endpoint, for example `"people/{id}"`
    - params: A map, for example `%{"id" => 1}`

  """
  @spec get(String.t(), String.t(), map()) :: map()
  def get(url, endpoint, params) do
    requests = 0
    resolve_records(url, endpoint, params, requests)
  end

  #
  # Recursive function to fetch records. If a fetching process fails, it makes
  # two requests more until all requests are completed succesfully. 
  #
  # Parameters
  #   
  #   - url: A string url, for example "www.mysite.com"
  #   - endpoint: A string endpoint, for example "people/{id}"
  #   - params: A map, for example %{"id" => 1}
  #
  # Returns 
  #
  #   %{
  #       "requests" => 1,
  #       "records" => [
  #         %{"uid" => "111-AAA", ...}
  #       ]  
  #    }
  #
  @spec resolve_records(String.t(), String.t(), map(), Integer.t()) :: map()
  defp resolve_records(url, endpoint, params, requests) do
    parsed_url = Connection.create_url(url, endpoint, params)

    case Connection.get(parsed_url) do
      {:ok, response} ->
        %{"records" => response, "requests" => requests + 1}

      {:error, _} ->
        {date_one, date_two, date_three, date_four} =
          date_partition(params["start"], params["end"])

        date_range_one = %{"start" => date_one, "end" => date_two}
        date_range_two = %{"start" => date_three, "end" => date_four}

        response_one = resolve_records(url, endpoint, date_range_one, requests)
        response_two = resolve_records(url, endpoint, date_range_two, requests)

        %{
          "records" => response_one["records"] ++ response_two["records"],
          "requests" => 1 + response_one["requests"] + response_two["requests"]
        }
    end
  end

  @doc """
  Given two dates which represents a range it split into two ranges. 

  ## Parameters

    - first: A string date, for example `"2017-01-01"`
    - last: A string date, for example `"2017-12-31"`

  ## Examples

      iex(1)> Summary.Records.date_partition("2017-01-01", "2017-12-31")
      {"2017-01-01", "2017-07-02", "2017-07-03", "2017-12-31"}

  """
  @spec date_partition(String.t(), String.t()) :: {String.t(), String.t(), String.t(), String.t()}
  def date_partition(first, last) do
    first_date = Timex.parse!(first, "%Y-%m-%d", :strftime)
    last_date = Timex.parse!(last, "%Y-%m-%d", :strftime)

    date_diff = Timex.diff(last_date, first_date, :days)

    half_one = Timex.shift(first_date, days: trunc(date_diff / 2))
    half_two = Timex.shift(half_one, days: 1)

    half_one = Date.to_string(half_one)
    half_two = Date.to_string(half_two)

    {first, half_one, half_two, last}
  end
end
