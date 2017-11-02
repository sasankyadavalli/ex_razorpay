defmodule ExRazorpay.Refunds do
  @moduledoc """
    Handles Razorpay refund requests like list all refunds, get a refund.
  """

  @key :ex_razorpay |> Application.fetch_env!(:key)
  @secret :ex_razorpay |> Application.fetch_env!(:secret)
  
  @doc """
  Retrieves list of refunds based on optional parameters. 
  By default this returns recent 10 refunds. 
    
  Optional parameters it supports are:
  * `from`: The timestamp in seconds after which the refunds were created. Accepts only `timestamp (epoch)`
  * `to`:   The timestamp in seconds before which refunds were created. Accepts only `timestamp (epoch)`
  * `count`: The number of refunds to fetch. Accepts only `integer`
  * `skip`:  The number of refunds to be skipped. Accepts only `integer`

  Returns `{:ok, results}` on success, else `{:error, reason}`

  ## Examples

      iex> ExRazorpay.Refunds.list_refunds([count: 2])
      {:ok,
        %{"count" => 2, "entity" => "collection",
          "items" => [%{"amount" => 50000, "created_at" => 1509651274,
          "currency" => "INR", "entity" => "refund", "id" => "rfnd_8wiQVCxaC8lGza",
          "notes" => [], "payment_id" => "pay_8wiNmKrlrzTi7D", "receipt" => nil},
        %{"amount" => 50000, "created_at" => 1509648046, "currency" => "INR",
          "entity" => "refund", "id" => "rfnd_8whVeqyr1zcgTI", "notes" => [],
          "payment_id" => "pay_8whI7Ub0O9YIjF", "receipt" => nil}]}}

  """
  def list_refunds(options \\ []) when is_list(options) do
    "https://api.razorpay.com/v1/refunds"
    |> format_url(options)
    |> HTTPoison.get([], hackney: [basic_auth: {@key, @secret}])
    |> parse_response()
  end

  @doc """
  Retrieves a specific refund by `refund_id`

  Returns `{:ok, result}` on success, else `{:error, reason}`

  ##Example

      iex> ExRazorpay.Refunds.get_refund("rfnd_8wiQVCxaC8lGza")
      {:ok,
        %{"amount" => 50000, "created_at" => 1509651274, "currency" => "INR",
          "entity" => "refund", "id" => "rfnd_8wiQVCxaC8lGza", "notes" => [],
          "payment_id" => "pay_8wiNmKrlrzTi7D", "receipt" => nil}}
          
  """
  def get_refund(refund_id) when is_binary(refund_id) do
    "https://api.razorpay.com/v1/refunds/#{refund_id}"
    |> HTTPoison.get([], hackney: [basic_auth: {@key, @secret}])
    |> parse_response()
  end

  defp format_url(url, options) when is_binary(url) do
    case options do
      [] ->
        url
      _ ->
        url <> "?" <> URI.encode_query(options)
    end
  end

  defp parse_response({:ok, %HTTPoison.Response{body: body, status_code: _status}}) do
    Poison.decode(body)
  end

  defp parse_response({:ok, %HTTPoison.Error{reason: reason}}) do
    {:error, reason}
  end
end