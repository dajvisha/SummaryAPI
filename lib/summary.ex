defmodule Summary do
  @moduledoc """
  Summary is the main module to generate reports.  
  """

  use Timex

  alias Summary.Connection
  alias Summary.Records
  alias Summary.Report

  @doc """
  Starts the process to generates reports.

  ## Examples

      iex(1)> Summary.start()
      :ok

  """
  def start do
    # Configure Server URL
    server = "https://us-central1-prueba-resuelve.cloudfunctions.net"

    # Configure Users enpoint
    user_params = %{"start" => "2017-01-01", "end" => "2017-12-31"}
    user_endpoint = "users/{start}/{end}"

    # Configure Movements endpoint
    movement_params = %{"start" => "2018-01-01", "end" => "2018-12-31"}
    movement_endpoint = "movements/{start}/{end}"

    # Configure Summary endpoint
    summary_server = "#{server}/conta/resumen"

    # Start clock
    start_clock = Duration.now()

    # Get User and Movement records
    users = Records.get(server, user_endpoint, user_params)
    movements = Records.get(server, movement_endpoint, movement_params)

    # Creates Report
    report = Report.create(users["records"], movements["records"])
    post_result = Connection.post(summary_server, report)

    # End clock
    end_clock = Duration.now()

    # Show Summary results
    display_logs(start_clock, end_clock, users["requests"], movements["requests"], post_result)
  end

  #
  # Displays logs after generating and sending a report. 
  # 
  # Parameters
  #
  #   - start_clock: Current Duration when the requesting process start 
  #   - end_clock: Current Duration when the report was sent to the server
  #   - users_requests: The number of requests made to users
  #   - movements_requests: The number of requests mate to movements
  #   - post_result: The result of sending the report to the server {:ok, _} or {:error, _}
  #
  @spec display_logs(Duration.t(), Duration.t(), Integer.t(), Integer.t(), {atom(), String.t()}) ::
          any()
  defp display_logs(start_clock, end_clock, users_requests, movements_requests, post_result) do
    case post_result do
      {:ok, _} ->
        process_duration = Duration.diff(end_clock, start_clock, :seconds)

        IO.puts("\nThe report has been sent correctly.\n")
        IO.puts("Genereting and sending the report took: #{process_duration} seconds")
        IO.puts("The number of requests made to users was: #{users_requests}")
        IO.puts("The number of requests made to movements was: #{movements_requests}\n")

      {:error, _} ->
        IO.puts("An error has occurred processing the report.\n")
    end
  end
end
