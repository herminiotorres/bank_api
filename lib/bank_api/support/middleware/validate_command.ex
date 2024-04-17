defmodule BankApi.Support.Middleware.ValidateCommand do
  @behaviour Commanded.Middleware

  alias Phoenix.Controller.Pipeline
  alias Commanded.Middleware.Pipeline

  def before_dispatch(%Pipeline{command: command} = pipeline) do
    case command.__struct__.valid?(command) do
      {:ok, _} ->
        pipeline

      {:error, changeset} ->
        pipeline
        |> Pipeline.respond({:error, :command_validation_failure, command, errors_on(changeset)})
        |> Pipeline.halt()
    end
  end

  def after_dispatch(pipeline), do: pipeline
  def after_failure(pipeline), do: pipeline

  defp errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Regex.replace(~r"%{(\w+)}", message, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
