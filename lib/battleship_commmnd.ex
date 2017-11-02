defmodule Battleship.Command do

  def command(command_function) do
    with connected      <- connect(),
         {:ok, pid}     <- lookup_service(connected)
    do
      {:ok, message} = command_function.(pid)
      IO.puts message
    else
      {:error, message} -> IO.puts message
      message           -> IO.inspect message
    end
  end

  defp connect() do
    {:ok, hostname} = :inet.gethostname
    Node.connect(:"commander@#{hostname}")
  end

  defp lookup_service(:ignored) do
    {:error, "Battleships is not running"}
  end
  defp lookup_service(false) do
    {:error, "Battleships is not running"}
  end
  defp lookup_service(true) do
    :timer.sleep(1000)
    pid = :global.whereis_name(:players)
    {:ok, pid}
  end
end
