defmodule Summary.Report do
  @moduledoc """
  Summary.Report contains functions to process User Records, and
  Movement Records to generate a Report.  
  """

  @doc """
  Recibes a users map and movements list and creates a summarized report.

  ## Parameters
  
    - users: A users list `[%{"uid" => "1", ...}]`
    - movements: A movement list `[%{"ammount" => 1, ...}]`
    
  """
  @spec create(list(map()), list(map())) :: map()
  def create(users, movements) do
    response = %{
      "totalRecords" => 0,
      "totalCredit" => 0,
      "totalDebit" => 0,
      "balance" => 0,
      "byUser" => create_users_map(users)
    }

    summarize_movements(movements, response)
  end

  #
  # Recibes a movements list and a response format and returns the
  # summirized movements.
  #
  # Parameters
  #
  #   - movements: A movements list
  #   - response: A map with the response format
  #
  # Returns
  #
  #   %{
  #     "totalRecords" => 0,
  #     "totalCredit" => 0,
  #     "totalDebit" => 0, 
  #     "balance" => 0,
  #     "byUser" => [
  #       %{
  #           "name" => "name",
  #           "uid" => "uid",
  #           "records" => 0,
  #           "resumen" => % {
  #             "credit" => 0,
  #             "debit" => 0,
  #             "balance" => 0
  #           }  
  #     ]
  #   }
  #
  @spec summarize_movements(list(map()), map()) :: map()
  defp summarize_movements(movements, response) do
    movements_summary =
      Enum.reduce(
        movements,
        response,
        fn movement, response ->
          movement_type = movement["type"]
          movement_amount = movement["amount"]
          movement_account = movement["account"]

          credit = response["totalCredit"]
          debit = response["totalDebit"]

          users = response["byUser"]
          user_records = users[movement_account]["records"] + 1
          users = put_in(users, [movement["account"], "records"], user_records)

          {credit, debit, balance, users} =
            process_amount(
              movement_type,
              movement_amount,
              movement_account,
              credit,
              debit,
              users
            )

          %{
            "totalRecords" => response["totalRecords"] + 1,
            "totalCredit" => credit,
            "totalDebit" => debit,
            "balance" => balance,
            "byUser" => users
          }
        end
      )

    put_in(movements_summary, ["byUser"], Map.values(movements_summary["byUser"]))
  end

  #
  # Recibes a users list and generates a users map with the "uid" as key.
  #
  # Parameters
  #
  #   - users: A users list
  #
  # Returns
  #
  #   %{
  #       "uid" => %{
  #         "name" => "name",
  #         "uid" => "uid",
  #         "records" => 0,
  #         "resumen" => %{
  #           "credit" => 0,
  #           "debit" => 0,
  #           "balance" => 0,
  #         }
  #       }
  #    }
  #
  @spec create_users_map(list()) :: map()
  defp create_users_map(users) do
    users
    |> Enum.chunk_every(1)
    |> Enum.map(fn [user] ->
      user_uid = user["uid"]
      user_name = "#{user["nombre"]}"

      user_struct = %{
        "name" => user_name,
        "uid" => user_uid,
        "records" => 0,
        "resumen" => %{
          "credit" => 0,
          "debit" => 0,
          "balance" => 0
        }
      }

      {user_uid, user_struct}
    end)
    |> Map.new()
  end

  #
  # Processes the amount of a movent given its type and the users map. 
  #
  # Parameters
  #
  #   - type: The movement type "credit" or "debit"
  #   - amount: The movement amount
  #   - credit: The total credit
  #   - debit: The total debit
  #   - users: A map which contains users
  #
  @spec process_amount(String.t(), Integer.t(), String.t(), Integer.t(), Credit.t(), map()) ::
          {Integer.t(), Integer.t(), Integer.t(), map()}
  defp process_amount(type, amount, account, credit, debit, users) do
    user_movement_balance = users[account]["resumen"][type]
    user_movement_balance = user_movement_balance + amount
    users = put_in(users, [account, "resumen", type], user_movement_balance)

    user_balance = users[account]["resumen"]["credit"] - users[account]["resumen"]["debit"]
    users = put_in(users, [account, "resumen", "balance"], user_balance)

    case type do
      "credit" ->
        credit = credit + amount
        balance = credit - debit
        {credit, debit, balance, users}

      "debit" ->
        debit = debit + amount
        balance = credit - debit
        {credit, debit, balance, users}
    end
  end
end
