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
        |> Pipeline.respond(
          {:error, :command_validation_failure, command, changeset_error_to_string(changeset)}
        )
        |> Pipeline.halt()
    end
  end

  def after_dispatch(pipeline), do: pipeline
  def after_failure(pipeline), do: pipeline

  defp changeset_error_to_string(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
    |> Enum.reduce("", fn {k, v}, acc ->
      joined_errors = Enum.join(v, "; ")
      "#{acc}#{k}: #{joined_errors}\n"
    end)
  end
end
