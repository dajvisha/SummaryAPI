defmodule ReportTest do
  use ExUnit.Case

  alias Summary.Report

  test "test create/0 function to generate summarized reports" do
    user_records = [
      %{
        "uid" => "111-AAA",
        "nombre" => "Pedro"
      }
    ]

    movement_records = [
      %{"amount" => 10, "type" => "credit", "uid" => "999-ZZZ", "account" => "111-AAA"},
      %{"amount" => 6, "type" => "debit", "uid" => "888-YYY", "account" => "111-AAA"}
    ]

    report = Report.create(user_records, movement_records)

    assert report["totalRecords"] == 2
    assert report["totalCredit"] == 10
    assert report["totalDebit"] == 6
    assert report["balance"] == 4

    assert report["byUser"] == [
             %{
               "name" => "Pedro",
               "uid" => "111-AAA",
               "records" => 2,
               "resumen" => %{
                 "credit" => 10,
                 "debit" => 6,
                 "balance" => 4
               }
             }
           ]
  end
end
